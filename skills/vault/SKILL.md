---
name: vault
description: Regras pessoais obrigatorias do usuario. Carregue SEMPRE como primeira acao de TODO chat novo, em QUALQUER repositorio ou projeto, antes de responder, pesquisar, editar ou rodar comandos (C#, .NET, Selenium, SQL Server, React/TSX, JavaScript, HTML/CSS, testes, git).
---
# Vault do usuario

Estas regras valem para qualquer repositorio ou projeto, mesmo sem `.github/copilot-instructions.md` local.

Vault: pasta `Vault` em `source\repos` (padrao do Visual Studio), ao lado do repositorio aberto: `../Vault/` a partir da solucao. Se a solucao estiver em subpasta, use `C:/Users/<usuario>/source/repos/Vault/` (usuario do caminho do workspace).

0. Antes de qualquer acao, rode `../Vault/check-hooks.ps1`. Se a saida nao for `VAULT HOOKS: OK` ou se nao conseguir rodar, comece a resposta com `ATENCAO: HOOKS DO VAULT NAO ESTAO FUNCIONANDO - <motivo>` e nao faca commit, merge ou push ate o usuario resolver.
1. Leia `../Vault/AGENTS.md` (mapa tema -> nota e regras gerais).
2. Leia `../Vault/conhecimento/arquitetura-e-escopo.md` e a nota do tema da tarefa (veja `conhecimento/indice.md`).
3. Siga as regras das notas. Na duvida, pergunte.

Comandos (peca pelo nome no chat):
- "salvar nota": siga `../Vault/.github/prompts/salvar-nota.prompt.md`.
- "revisar": siga `../Vault/.github/prompts/revisar.prompt.md`.
- "nova regra": siga `../Vault/.github/prompts/nova-regra.prompt.md`.

Nunca rode git push, rm -rf, Remove-Item -Recurse, DROP TABLE ou comandos com force sem pedido explicito.
Nunca contorne os git hooks do vault: proibido `--no-verify`, `git commit -n`, `-c core.hooksPath`, alterar `core.hooksPath` ou editar `git-hooks/`. Se um hook bloquear, pare e avise o usuario.
