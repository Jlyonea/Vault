# Setup local: VirtualFittingRoom
verificado em: 2026-10-29

## TL;DR
- Tudo o que precisa ser baixado/instalado para rodar o projeto localmente (front React, tratamento de imagens em C#, API e ferramentas do manequim 3D).
- MANTER ATUALIZADO: toda dependencia, ferramenta ou passo adicionado ou removido no projeto (front, back-end, API, ferramentas) deve ser refletido aqui no mesmo chat da alteracao, com registro no historico no fim do arquivo.
- Escopo atual: repositorios `VirtualFittingRoom` (branch `feature/initial-setup`) e `VirtualFittingRoomAPI` (branch `feature/initial-setup`).
- Comandos em PowerShell, no Windows.
- O bloco unico da secao 0 deve ser atualizado junto com as demais secoes.

## 0. Todos os comandos em ordem (bloco unico)
Rodar em um PowerShell como administrador. Antes, trocar o valor de `$connectionString` pela connection string do LocalDB (nao versionar o valor real). Os detalhes de cada passo estao nas secoes 1 a 6.

```powershell
# 0. Variables
$repos = "$env:USERPROFILE\source\repos"
$connectionString = '<your-localdb-connection-string>'

# 1. Machine tools (global install)
winget install --id Git.Git -e
winget install --id Microsoft.DotNet.SDK.10 -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id BlenderFoundation.Blender -e
# MakeHuman: no winget package confirmed; download it from makehumancommunity.org
# SQL Server LocalDB: installed with Visual Studio (ASP.NET workload) or SQL Server Express (LocalDB option)

# Reload PATH in this session (avoids reopening the terminal)
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

# Check versions
git --version; dotnet --version; node -v; npm -v; sqllocaldb info

# 2. Clone repositories (skipped if they already exist)
Set-Location $repos
if (-not (Test-Path "$repos\VirtualFittingRoom")) { git clone -b feature/initial-setup https://github.com/Jlyonea/VirtualFittingRoom.git }
if (-not (Test-Path "$repos\VirtualFittingRoomAPI")) { git clone -b feature/initial-setup https://github.com/Jlyonea/VirtualFittingRoomAPI.git }

# 3. VirtualFittingRoom: image processing (C#)
Set-Location "$repos\VirtualFittingRoom"
dotnet restore VirtualFittingRoom.slnx
dotnet build VirtualFittingRoom.slnx
dotnet test tests/VirtualFittingRoom.Application.Tests
# Put the test images in tools/VirtualFittingRoom.ImageProcessor/SampleImages before running the line below
dotnet run --project tools/VirtualFittingRoom.ImageProcessor

# 4. VirtualFittingRoom: React front-end
Set-Location "$repos\VirtualFittingRoom\src\virtual-fitting-room-web"
npm install
npm test
npm run build

# 5. VirtualFittingRoomAPI
Set-Location "$repos\VirtualFittingRoomAPI"
sqllocaldb start MSSQLLocalDB
dotnet restore VirtualFittingRoomAPI.slnx
dotnet build VirtualFittingRoomAPI.slnx
dotnet user-secrets set "ConnectionStrings:VirtualFittingRoom" $connectionString --project src/VirtualFittingRoomAPI.Host
dotnet test tests/VirtualFittingRoomAPI.Tests
# Only when the API has migrations:
# dotnet tool install --global dotnet-ef
# dotnet ef database update --project src/VirtualFittingRoomAPI.Common --startup-project src/VirtualFittingRoomAPI.Host

# 6. Run: API in a new window, front-end in this one
Start-Process powershell -WorkingDirectory "$repos\VirtualFittingRoomAPI" -ArgumentList '-NoExit', '-Command', 'dotnet run --project src/VirtualFittingRoomAPI.Host'
Set-Location "$repos\VirtualFittingRoom\src\virtual-fitting-room-web"
npm run dev
```

## 1. Ferramentas da maquina (instalacao global)
Instalar como administrador. Depois, fechar e abrir o terminal.

| Ferramenta | Versao | Para que serve | Comando |
|---|---|---|---|
| Git | atual | Clonar os repositorios | `winget install --id Git.Git -e` |
| .NET SDK | 10 | Tratamento de imagens (`VirtualFittingRoom.Application`), ferramenta `ImageProcessor` e API | `winget install --id Microsoft.DotNet.SDK.10 -e` |
| Node.js | LTS (minimo 20.19 ou 22.12, exigido pelo Vite 7) | Front-end React | `winget install --id OpenJS.NodeJS.LTS -e` |
| Blender | atual | Gerar os `.glb` do manequim e dos moldes de roupa (Fase 2) | `winget install --id BlenderFoundation.Blender -e` |
| MakeHuman | atual | Manequim base com shape keys (altura, peito, cintura, quadril) | `winget search makehuman`; se nao houver pacote, baixar em makehumancommunity.org |
| SQL Server LocalDB | vem com o Visual Studio (workload ASP.NET) ou com o instalador do SQL Server Express (opcao LocalDB) | Banco da API e testes de integracao | - |
| dotnet-ef | compativel com EF Core 10 | Criar/aplicar migrations da API (so quando houver migrations) | `dotnet tool install --global dotnet-ef` |

Conferir:
```powershell
git --version; dotnet --version; node -v; npm -v; sqllocaldb info
```

## 2. Clonar os repositorios
```powershell
cd $env:USERPROFILE\source\repos
git clone https://github.com/Jlyonea/VirtualFittingRoom.git
git clone https://github.com/Jlyonea/VirtualFittingRoomAPI.git
cd VirtualFittingRoom; git checkout feature/initial-setup; cd ..
cd VirtualFittingRoomAPI; git checkout feature/initial-setup; cd ..
```

## 3. VirtualFittingRoom: tratamento de imagens (C#)
Pacotes NuGet (baixados pelo `dotnet restore`):
- `VirtualFittingRoom.Application`: `SkiaSharp` 3.119.0, `Microsoft.Extensions.DependencyInjection.Abstractions` 10.0.0.
- `tools/VirtualFittingRoom.ImageProcessor`: `Microsoft.Extensions.DependencyInjection` 10.0.0.
- `tests/VirtualFittingRoom.Application.Tests`: `xunit` 2.9.3, `xunit.runner.visualstudio` 3.1.4, `NSubstitute` 5.3.0, `Microsoft.NET.Test.Sdk` 17.14.1, `coverlet.collector` 6.0.4.

```powershell
cd $env:USERPROFILE\source\repos\VirtualFittingRoom
dotnet restore VirtualFittingRoom.slnx
dotnet build VirtualFittingRoom.slnx
dotnet test tests/VirtualFittingRoom.Application.Tests
```

Observacoes:
- O SkiaSharp traz as bibliotecas nativas do Windows. Em Linux seria preciso o pacote `SkiaSharp.NativeAssets.Linux`.
- Imagens de teste NAO estao no repositorio: baixar manualmente (camiseta oversized PNG transparente do pngtree e camiseta New Era vinho JPG) e colocar em `tools/VirtualFittingRoom.ImageProcessor/SampleImages`.

Processar as imagens (saida PNG + `.landmarks.json` em `ProcessedImages`):
```powershell
dotnet run --project tools/VirtualFittingRoom.ImageProcessor
```

## 4. VirtualFittingRoom: front-end React
Pacotes npm (baixados pelo `npm install`):
- Dependencias: `react` e `react-dom` ^19.1.0, `three` ^0.178.0, `@react-three/fiber` ^9.2.0, `@react-three/drei` ^10.5.0.
- Desenvolvimento: `vite` ^7.0.0, `@vitejs/plugin-react` ^5.0.0, `typescript` ^5.8.3, `vitest` ^3.2.4, `jsdom` ^26.1.0, `@testing-library/react` ^16.3.0, `@testing-library/dom` ^10.4.0, `@testing-library/jest-dom` ^6.6.3, `@testing-library/user-event` ^14.6.1, `@types/react` ^19.1.8, `@types/react-dom` ^19.1.6, `@types/three` ^0.178.0.

```powershell
cd $env:USERPROFILE\source\repos\VirtualFittingRoom\src\virtual-fitting-room-web
npm install
npm test
npm run build
npm run dev
```

Observacao: usar `npm install` (e nao `npm ci`) enquanto o `package-lock.json` nao estiver versionado; depois do primeiro install, commitar o lock.

## 5. VirtualFittingRoomAPI
Pacotes NuGet (baixados pelo `dotnet restore`):
- `Common`: `Microsoft.EntityFrameworkCore.SqlServer` 10.0.0, `Microsoft.AspNetCore.Identity.EntityFrameworkCore` 10.0.0, `FluentValidation.DependencyInjectionExtensions` 12.0.0.
- `Auth`: `Microsoft.AspNetCore.Authentication.JwtBearer` 10.0.0.
- `Host`: `Swashbuckle.AspNetCore` 9.0.4, `Microsoft.EntityFrameworkCore.Design` 10.0.0.
- `tests/VirtualFittingRoomAPI.Tests`: `xunit` 2.9.3, `xunit.runner.visualstudio` 3.1.4, `NSubstitute` 5.3.0, `Microsoft.NET.Test.Sdk` 17.14.1, `coverlet.collector` 6.0.4.

```powershell
cd $env:USERPROFILE\source\repos\VirtualFittingRoomAPI
dotnet restore VirtualFittingRoomAPI.slnx
dotnet build VirtualFittingRoomAPI.slnx
dotnet user-secrets set "ConnectionStrings:VirtualFittingRoom" "<connection-string-do-LocalDB>" --project src/VirtualFittingRoomAPI.Host
dotnet test tests/VirtualFittingRoomAPI.Tests
dotnet run --project src/VirtualFittingRoomAPI.Host
```

Observacoes:
- A connection string fica somente no user-secrets (nunca em `appsettings*.json`); sem ela a API nao sobe.
- Ainda nao ha migrations; quando houver, aplicar com `dotnet ef database update --project src/VirtualFittingRoomAPI.Common --startup-project src/VirtualFittingRoomAPI.Host`.

## 6. Manequim 3D (Fase 2)
- Blender + MakeHuman (secao 1) para gerar os `.glb` do manequim e dos moldes (camiseta/calca com as mesmas shape keys).
- Os `.glb` ainda nao existem no repositorio; o passo a passo de geracao sera escrito pela IA quando essa etapa comecar.

## Pendencias conhecidas
- O codigo foi escrito sem compilar (maquina sem Node e com NuGet bloqueado por TLS); o primeiro build e os primeiros testes podem apontar erros e versoes de pacotes a ajustar.

## Historico
| Data | Alteracao |
|---|---|
| 2026-10-29 | Documento criado: ferramentas, pacotes e comandos do front React, tratamento de imagens C#, API e manequim 3D |
| 2026-10-29 | Secao 0: bloco unico com todos os comandos PowerShell em ordem (instalar, clonar, compilar, testar e rodar) |
