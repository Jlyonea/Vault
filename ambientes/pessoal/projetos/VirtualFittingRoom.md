# Projeto: VirtualFittingRoom
verificado em: 2026-10-23
## Resumo
- Objetivo: aplicacao web publica de provador virtual para uma loja de roupas (ex.: camisetas X, Y, Z e calcas A, B, C). O usuario configura um avatar com as medidas do proprio corpo, combina produtos (cada produto tem suas medidas) e visualiza o resultado sem experimentar fisicamente.
- Repositorio: pasta `source/repos/VirtualFittingRoom`; remoto `https://github.com/Jlyonea/VirtualFittingRoom.git`.
- Prioridades: usabilidade, manutenibilidade para o desenvolvedor e velocidade de navegacao (publico aberto).
## Stack
- Front-end: React + TypeScript (SPA).
- Dados mock: camada de servicos (ex.: `productService.getAll()`) lendo JSON local; ao criar a API, troca-se apenas a implementacao dos servicos.
- Estilos: CSS Modules + variaveis CSS compartilhadas (tema).
- Textos da interface: ingles (todo o codigo em ingles).
- AvatarView3D (substituiu o AvatarView2D na branch `feature/initial-setup`): desenha corpo e roupas em 3D (three + @react-three/fiber + @react-three/drei) com as medidas da propria peca (so visual, sem calculo de caimento); usuario gira com o mouse (sem zoom/pan).
- Testes do front-end em pasta separada `tests/` (espelhando `src/`).
- Fluxo de dados no front: paginas compoem componentes; componentes so exibem e emitem eventos; hooks guardam estado e chamam servicos; so `services/` sabe a origem dos dados.
- Testes do front isolados com `vi.mock` (paginas mockam hooks/componentes filhos; hooks mockam servicos); dados de teste compartilhados em `tests/fixtures/`.
- Navegacao sem React Router: `App.tsx` troca de pagina por estado (`catalog`, `avatar`, `fittingRoom`).
- Rotas: React Router planejado, mas SEM a dependencia por enquanto; apenas estrutura de pastas por pagina.
- Maquina atual sem Node.js (nao pode instalar): o codigo do front-end e escrito sem rodar/compilar aqui; build e testes serao feitos depois em outra maquina.
- Avatar: 3D no front React (2D removido); manter a logica de caimento fora da camada de desenho.
- Back-end: C#, Entity Framework, IoC (injecao de dependencia).
- Banco de dados: SQL Server.
## Arquitetura
- Padrao: React (SPA) consumindo uma Web API propria em C# (projeto separado), que acessa o SQL Server do usuario (produtos, login etc.).
- Granularidade da API: monolito (modular). Microservicos so no futuro, se necessario.
- Ordem de construcao: primeiro o front-end com dados mock; depois a API.
- Autenticacao: propria (ASP.NET Core Identity) + JWT.
- Estrutura de pastas (aprovada):
```
VirtualFittingRoom/
  src/
    VirtualFittingRoom.Controllers/     (antes "Api": controllers, configuracao de DI)
    VirtualFittingRoom.Application/     (servicos, uma responsabilidade por classe)
    VirtualFittingRoom.Domain/          (entidades, calculo de caimento corpo x produto)
    VirtualFittingRoom.Infrastructure/  (EF Core, SQL Server, migrations)
    virtual-fitting-room-web/           (React + TypeScript + Vite)
  tests/
    VirtualFittingRoom.Application.Tests/
    VirtualFittingRoom.Domain.Tests/
```
- DTOs e classes de modelo ficam separados em uma pasta `Models` (local exato a confirmar quando a API for construida).
## Boas praticas
1. Foco em componentes reutilizaveis: NUNCA repetir codigo.
2. Cada metodo tem uma unica responsabilidade (SRP / SOLID).
## Testes
- Testes isolados de cada parte do codigo (unitarios).
- Framework back-end: xUnit + NSubstitute.
- Framework front-end: Vitest + React Testing Library.
- Convencao de nomes: `Metodo_Cenario_ResultadoEsperado` (ex.: `CalculateFit_ShirtSmallerThanChest_ReturnsTight`).
## Padrao de fotos dos produtos
Quando o usuario pedir o padrao das fotos dos produtos, enviar EXATAMENTE o texto abaixo (aprovado em 2026-10-26):

| Item | Padrao sugerido |
|---|---|
| Vistas | Frente **e** costas (2 fotos) |
| Tipo | Peca estendida (flat lay) ou manequim invisivel (ghost mannequin); **sem pessoa vestindo** |
| Fundo | PNG transparente (ideal) ou fundo liso branco/cinza claro |
| Enquadramento | Peca centralizada, reta, mangas abertas e simetricas, sem dobras |
| Resolucao | Minimo 1024 px no lado maior; maximo 2048 px |
| Proibido | Marca d'agua, sombra forte, outros objetos, recorte cortando a peca |
| Formato | PNG ou JPG, sRGB |

Com esse padrao, o sistema detecta o contorno da peca (gola, ombros, barra, mangas) sem IA e "encaixa" a foto no molde 3D.

## Decisoes
| Data | Decisao | Motivo |
|---|---|---|
| 2026-10-23 | Nota do projeto criada a partir de `_modelo.md` | Pedido do usuario no inicio do chat |
| 2026-10-23 | Back-end C# + Entity Framework + IoC; banco SQL Server; arquitetura MVC consumindo API externa | Definido pelo usuario |
| 2026-10-23 | Componentizacao obrigatoria (sem codigo repetido) e um metodo = uma responsabilidade | Definido pelo usuario |
| 2026-10-23 | API propria em projeto separado, apontando para o SQL Server do usuario | Definido pelo usuario |
| 2026-10-23 | Front-end React + TypeScript consumindo a Web API (substitui MVC com views) | Definido pelo usuario |
| 2026-10-23 | Avatar 2D na v1, 3D em versao futura | Definido pelo usuario |
| 2026-10-23 | Testes back-end com xUnit + NSubstitute | Definido pelo usuario |
| 2026-10-23 | Remoto git: GitHub `Jlyonea/VirtualFittingRoom` | Definido pelo usuario |
| 2026-10-23 | API como monolito; comecar pelo front-end com mocks e construir a API depois | Definido pelo usuario |
| 2026-10-23 | Projeto "Api" renomeado para "Controllers"; DTOs em pasta `Models` | Definido pelo usuario |
| 2026-10-23 | Testes front-end com Vitest + React Testing Library; nomes `Metodo_Cenario_ResultadoEsperado` | Definido pelo usuario |
| 2026-10-23 | Autenticacao propria (ASP.NET Core Identity) + JWT | Definido pelo usuario |
| 2026-10-23 | Mocks via camada de servicos com JSON local | Definido pelo usuario |
| 2026-10-23 | Sem Node.js nesta maquina; front-end escrito agora e testado em outra maquina | Restricao do usuario |
| 2026-10-23 | Estilos com CSS Modules + variaveis CSS compartilhadas | Definido pelo usuario |
| 2026-10-23 | React Router sem dependencia por agora; so pastas por pagina | Definido pelo usuario |
| 2026-10-23 | Testes do front-end em pasta `tests/` separada; sem calculo de caimento no front por enquanto | Definido pelo usuario |
| 2026-10-23 | Estrutura do front aprovada + `vite-env.d.ts`, `tests/setup.ts`, `constants/measurementLabels.ts`, `avatarGeometry.ts` | Definido pelo usuario |
| 2026-10-23 | Interface em ingles; roupas desenhadas com as medidas da peca (so visual) | Definido pelo usuario |
| 2026-10-23 | Esqueleto do front criado em `feature/initial-setup` (sem commit), ainda nao compilado/testado (sem Node nesta maquina) | Execucao do pedido |
| 2026-10-23 | Identidade git local do repo: `jlyonea <jlyonea@hotmail.com>` (nunca o e-mail da ADP neste projeto) | Definido pelo usuario |
| 2026-10-23 | Commit `e3e06ee` enviado para `origin/feature/initial-setup`; `main` ainda nao existe no remoto | Pedido do usuario |
| 2026-10-23 | Nova branch orphan `feature/non-react-setup`: projeto sem React/Node, rodando nesta maquina | Pedido do usuario |
| 2026-10-23 | Nessa branch: ASP.NET Core MVC (Razor) + jQuery via LibMan; projeto web `VirtualFittingRoom.Controllers` | Definido pelo usuario |
| 2026-10-23 | Nessa branch: estrutura completa (Controllers, Application, Domain, Infrastructure) com dados mock; API futura em repositorio separado (Infrastructure: mock agora, cliente HTTP depois) | Definido pelo usuario |
| 2026-10-23 | Nessa branch: projetos de teste so para Domain e Application | Definido pelo usuario |
| 2026-10-23 | Nessa branch: SVG do avatar 2D desenhado no navegador com jQuery (sem testes de JS; ciente dos contras) | Definido pelo usuario |
| 2026-10-23 | Nessa branch: .NET 10; jQuery como arquivo `jquery.min.js` versionado em `wwwroot/lib` (sem LibMan) | Definido pelo usuario |
| 2026-10-23 | Nessa branch: Bootstrap 5.3.3 local em `wwwroot/lib/bootstrap` (mesmo padrao do jQuery, sem CDN) | Definido pelo usuario |
| 2026-10-23 | Nessa branch: regra `dist/` (Vite) removida do `.gitignore` para versionar `wwwroot/lib/*/dist` | Definido pelo usuario |
| 2026-10-23 | Commit `73b6790` enviado para `origin/feature/non-react-setup` (upstream configurado) | Pedido do usuario |
| 2026-10-26 | Front React: avatar 3D com three + @react-three/fiber + @react-three/drei; AvatarView2D e seus testes removidos; interacao so de girar com o mouse | Definido pelo usuario |
| 2026-10-26 | Commit `b8947b7` (avatar 3D) enviado para `origin/feature/initial-setup`; ainda nao compilado/testado (sem Node nesta maquina) | Pedido do usuario |
| 2026-10-26 | Roupas a partir de fotos em fases: (1) foto do produto como textura sobre molde 3D por categoria, ajustado pelas medidas; (2) manequim mais realista; (3) IA image-to-3D no futuro | Definido pelo usuario |
| 2026-10-26 | Custo zero por enquanto (sem GPU nem API paga de IA); meta: o mais realista possivel sem IA | Definido pelo usuario |
| 2026-10-26 | Clientes sempre enviam as medidas da peca; foto define so a aparencia, nunca o tamanho | Definido pelo usuario |
| 2026-10-26 | Padrao de fotos dos produtos aprovado (secao "Padrao de fotos dos produtos"); enviar exatamente esse texto quando pedido | Definido pelo usuario |
| 2026-10-26 | Imagens de teste: pngtree (camiseta oversized, PNG transparente) e camiseta New Era vinho (JPG de loja); podem ser versionadas no repo (projeto de teste, nao compartilhado) | Definido pelo usuario |
| 2026-10-26 | Remocao de fundo das fotos: algoritmo simples sem IA (remove a cor de fundo a partir das bordas) | Definido pelo usuario |
| 2026-10-26 | Tratamento das imagens neste repositorio: agora no front (funcoes TS puras, testaveis); quando a API existir, migrar para o back-end C# da mesma solucao, processando uma vez por produto e guardando o resultado | Delegado pelo usuario a IA |
| 2026-10-26 | Manequim (Fase 2) com MakeHuman | Definido pelo usuario |
| 2026-10-26 | Molde 3D: manequim MakeHuman com shape keys (altura, peito, cintura, quadril); camiseta/calca do acervo MakeHuman ou modeladas no Blender sobre ele com as mesmas shape keys; foto aplicada por projecao frente/costas | Definido pelo usuario |
| 2026-10-26 | Blender + MakeHuman serao instalados pelo usuario na maquina com Node; a IA escreve o passo a passo e o usuario gera os `.glb` | Definido pelo usuario |
| 2026-10-26 | Primeira entrega: remocao de fundo + deteccao de contorno das fotos, com testes (independe dos `.glb`) | Definido pelo usuario |
| 2026-10-26 | Tratamento das imagens em C# dentro de `VirtualFittingRoom.Application` (substitui a decisao de fazer no front); futuramente pode ser movido | Definido pelo usuario |
| 2026-10-26 | Pipeline sem IA: remove fundo (flood fill pela borda) -> maior componente -> recorte -> landmarks da camiseta (gola, pescoco, mangas, axilas, barra) normalizados; saida PNG + `.landmarks.json` | Execucao do pedido |
| 2026-10-26 | Codec de imagem com SkiaSharp 3.119.0 (MIT); testes em `tests/VirtualFittingRoom.Application.Tests`; ferramenta `tools/VirtualFittingRoom.ImageProcessor` le `SampleImages` e grava em `ProcessedImages` | Execucao do pedido |
| 2026-10-26 | Codigo C# escrito sem compilar (NuGet bloqueado por TLS nesta maquina); imagens de teste serao baixadas manualmente pelo usuario; sem commit | Restricao do usuario |
