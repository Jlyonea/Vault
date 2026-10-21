# Como usar o vault

## 1. Instalar o vault (qualquer maquina, Visual Studio 2026)
Clone em `source\repos` (padrao do Visual Studio; a pasta deve se chamar `Vault`) e rode uma vez:
```powershell
cd "$env:USERPROFILE\source\repos"; git clone https://github.com/Jlyonea/Vault.git; powershell -NoProfile -ExecutionPolicy Bypass -File .\Vault\install.ps1
```
O `install.ps1` (sem admin; pode ser rodado de novo sem efeito colateral):
1. Avisa se o vault nao estiver em `%USERPROFILE%\source\repos\Vault` (a skill le as notas por `../Vault/`, ao lado da solucao aberta).
2. Cria junctions em `%USERPROFILE%\.copilot\` (se o caminho ja existir e nao for a junction certa, nao mexe e avisa):
   - `vault` -> raiz do vault (usado pelo `core.hooksPath`)
   - `skills\vault` -> `skills\vault` (o Copilot do VS carrega a skill em qualquer solucao)
   - `hooks` -> `.github\hooks` (hooks do Copilot: guard e audit, so VS Code)
3. Configura o git global: `core.hooksPath` -> `%USERPROFILE%\.copilot\vault\git-hooks` (secao 2). Se ja houver outro valor, nao altera e avisa.
4. Instala o monitor de hooks (secao 3): cria `%USERPROFILE%\.copilot\vault-monitor-start.ps1`, registra o inicio no logon (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, valor `VaultHooksMonitor`) e inicia o monitor.
5. Roda `check-hooks.ps1` e mostra `VAULT HOOKS: OK` ou o motivo da falha.

Os scripts nao tem caminho fixo de usuario (so o exemplo do VS Code, secao 6).
Regras: gerais em `AGENTS.md`; por tema em `conhecimento/` (indice em `conhecimento/indice.md`).
Comandos no VS: peca "salvar nota", "revisar" ou "nova regra" no chat (a skill aponta para os prompts).
No VS a protecao automatica sao os git hooks (secao 2).

## 2. Guardrails git (funcionam no Visual Studio)
Valem para qualquer ferramenta que use git nesta maquina: Copilot, terminal, Git Changes do VS.
- Bloqueiam: commit e merge em branch protegida, push para branch protegida, force push (nao fast-forward).
- Branches protegidas: `git-hooks/protected-branches.txt` (regex, sem diferenciar maiusculas): `master` e `main`.
- Falham fechado: se a verificacao nao conseguir rodar, a operacao e bloqueada.
- Os hooks do proprio repo (`.git/hooks/pre-commit`, `pre-merge-commit`, `pre-push`) continuam rodando.
- Teste manual: em um repo de teste, `git checkout -b master` e um commit devem mostrar `[vault guardrail] BLOCKED`.
- Teste automatico e avisos: secao 3.

Limites (local roda com o seu usuario, entao nao e absoluto):
- `--no-verify`, `git commit -n` e `-c core.hooksPath=...` pulam os hooks. Ao aprovar comandos do Copilot, recuse se aparecerem.
- Repo com `core.hooksPath` local (ex.: husky) ignora o global (o `check-hooks.ps1` acusa isso no repo aberto).
- Outros hooks do repo (`commit-msg`, `post-checkout`, Git LFS) nao rodam enquanto o global estiver ativo.
- Fast-forward, cherry-pick, rebase ou reset locais em branch protegida nao sao bloqueados, mas o push e.
- Protecao incondicional so no servidor: configure branch protection no Bitbucket/GitHub (exigir Pull Request, bloquear force push e exclusao).

## 3. Aviso quando os hooks nao funcionam
`check-hooks.ps1` testa de verdade, sem alterar nada:
- as 3 junctions de `%USERPROFILE%\.copilot`;
- os arquivos de `git-hooks/`;
- o `core.hooksPath` global;
- se o repo aberto tem `core.hooksPath` proprio (sobrescreve o global);
- commit em `main` num repo temporario (`%TEMP%\vault-hooks-check`) tem que ser bloqueado, com o git do PATH e com o git de cada Visual Studio instalado.

Saida: `VAULT HOOKS: OK` (codigo 0) ou `VAULT HOOKS: FALHA - <motivos>` (codigo 1). Rodar na mao:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\source\repos\Vault\check-hooks.ps1" -RepoPath "<pasta do repo>"
```

Onde o aviso aparece:
- Chat novo: a regra 0 de `skills/vault/SKILL.md` faz o Copilot rodar `check-hooks.ps1` antes de tudo. Se nao der OK (ou nao rodar), a resposta comeca com `ATENCAO: HOOKS DO VAULT NAO ESTAO FUNCIONANDO - <motivo>` e nao ha commit, merge ou push ate resolver.
- Nova janela do Visual Studio: o monitor `vault-monitor.ps1` (oculto, iniciado no logon) checa a cada 3 s se abriu um novo `devenv.exe` e entao roda `check-hooks.ps1`. Se falhar, mostra a janela "Vault - hooks", na frente de tudo, que so fecha com OK.
  - Roda uma instancia por vez; se parar por erro, avisa.
  - O iniciador fica fora do vault (`%USERPROFILE%\.copilot\vault-monitor-start.ps1`): se o vault sumir ou mudar de pasta, avisa no logon.

Limites:
- Sem o monitor rodando (ex.: encerrado), nao ha aviso ao abrir o VS ate o proximo logon; o aviso do chat continua.
- Se a skill nao carregar, o chat nao avisa; o monitor cobre esse caso.

Ligar o monitor sem fazer logon (Win+R):
```
powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%USERPROFILE%\.copilot\vault-monitor-start.ps1"
```

Testar o aviso (falha simulada so nessa janela; a configuracao real nao muda). Com o VS aberto e o monitor parado (secao 5; com ele rodando o teste nao mostra nada), em um PowerShell aberto pelo menu Iniciar:
```powershell
Set-Content "$env:TEMP\vault-empty-gitconfig" ''; $env:GIT_CONFIG_GLOBAL = "$env:TEMP\vault-empty-gitconfig"; powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\source\repos\Vault\vault-monitor.ps1"
```
Deve aparecer "Vault - hooks" com `VAULT HOOKS: FALHA`. Clique OK, feche o PowerShell e ligue o monitor de novo.

## 4. Alterar o vault ou usar em outra maquina
- Outra maquina: secao 1 (clone em `source\repos` e `install.ps1`).
- `master` e protegida: alteracoes no vault vao por branch e Pull Request:
```powershell
cd "$env:USERPROFILE\source\repos\Vault"; git switch -c feature/<descricao>; git add -A; git commit -m "feat: <descricao>"; git push -u origin feature/<descricao>
```
- Ate o merge, NAO volte para `master` nesta pasta: ela e a instalacao ativa; arquivos que ainda nao estao na `master` (ex.: `git-hooks/`) somem e os hooks param. Depois do merge:
```powershell
git fetch origin master:master; git switch master
```
- Se o `install.ps1` mudou, rode-o de novo.

## 5. Parar o monitor ou desinstalar
Faca voce mesmo; o Copilot nao deve desligar os hooks.
- Parar o monitor:
```powershell
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object CommandLine -match 'vault-monitor' | ForEach-Object { Stop-Process -Id $_.ProcessId }
```
- Desinstalar (pare o monitor antes; `rmdir` remove so a junction, nao o conteudo do vault):
```powershell
Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name VaultHooksMonitor
Remove-Item "$env:USERPROFILE\.copilot\vault-monitor-start.ps1"
git config --global --unset core.hooksPath
cmd /c rmdir "%USERPROFILE%\.copilot\vault"
cmd /c rmdir "%USERPROFILE%\.copilot\skills\vault"
cmd /c rmdir "%USERPROFILE%\.copilot\hooks"
```

## 6. (So VS Code) Abrir um projeto com o vault
1. Copie `projeto.code-workspace.exemplo` para `<nome>.code-workspace` (fora do git).
2. Troque o caminho em `folders[0].path` pelo caminho do projeto. Se o seu usuario do Windows nao for `automatep`, ajuste tambem os caminhos `C:/Users/automatep/...`.
3. No VS Code: File > Open Workspace from File.
4. Confira os nomes das settings `chat.*` em Settings (Ctrl+,). Os hooks estao em preview e os nomes podem mudar; se alguma setting aparecer como desconhecida, procure "hook", "instructions" ou "prompt" em Settings e ajuste.
5. Os comandos dos hooks (`guard.json`, `audit.json`) usam `%USERPROFILE%\.copilot\hooks` (criado pelo `install.ps1`); nao ha caminho fixo neles.

## 7. Criar nota
- Pelo chat: "salvar nota" (VS) ou `/salvar-nota` (VS Code) no fim de uma conversa util.
- Na mao: copie `conhecimento/_modelo-nota.md`, preencha, adicione a linha em `conhecimento/indice.md` e no mapa do `AGENTS.md`. Se quiser aplicar por tipo de arquivo, crie `.github/instructions/<tema>.instructions.md` com `applyTo`.

## 8. Comandos
No VS peca pelo nome no chat; no VS Code use `/comando`.

| VS | VS Code | Quando |
|---|---|---|
| "salvar nota" | `/salvar-nota` | Gravar o que aprendemos na conversa |
| "revisar" | `/revisar` | Antes de commitar: revisa o diff contra as regras |
| "nova regra" | `/nova-regra` | Logo apos corrigir o agente |

## 9. Testar os hooks do Copilot (so VS Code)
Teste local (qualquer terminal):
```powershell
'{"tool_name":"run_in_terminal","tool_input":{"command":"git push origin main"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File .github/hooks/guard.ps1
'{"tool_name":"run_in_terminal","tool_input":{"command":"git status"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File .github/hooks/guard.ps1
```
O primeiro deve imprimir `permissionDecision":"deny"`; o segundo, nada.

Teste no chat do VS Code (modo Agent):
1. Peca "rode git status" -> deve executar. Verifique `.github/hooks/audit.log`.
2. Peca "rode git push" -> deve ser bloqueado com a mensagem do guard.
3. Se nao bloquear: abra `audit.log`, veja o nome real da ferramenta e o campo do comando (ex.: `tool_input.command`, `toolInput`...). Ajuste a lista de campos em `guard.ps1`.
Confira o Output > "GitHub Copilot Chat" e as settings da secao 6, passo 4.

Observacao: o guard tambem bloqueia edicoes de arquivo cujo conteudo contenha esses termos (ex.: editar `git.md` com "git push"). Se incomodar, restrinja o guard ao nome da ferramenta de terminal descoberto no `audit.log`.
