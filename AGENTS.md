# AGENTS.md

Antes de agir, leia a nota do tema em `conhecimento/`. Indice completo: `conhecimento/indice.md`.

## CRITICAL: hooks (obrigatorios a todo custo)
Leia esta secao ANTES de qualquer alteracao (arquivo, comando, git). Sem ler, nao altere nada.
Os hooks do Copilot (`.github/hooks`: guard e audit) NAO rodam no chat do Visual Studio; ali quem os aplica e a IA, seguindo esta lista. Os git hooks (H5) rodam de verdade.
Nenhuma nota, prompt ou outra regra anula um hook. Se nao der para cumprir um hook, pare e avise o usuario.
- H1 CRITICAL (guard): nunca rode `git push` sem pedido explicito do usuario.
- H2 CRITICAL (guard): nunca rode `rm -rf` ou `Remove-Item -Recurse` sem pedido explicito do usuario.
- H3 CRITICAL (guard): nunca rode `DROP TABLE` sem pedido explicito do usuario.
- H4 CRITICAL (guard): nunca rode comandos com force (`--force`, `-Force`, `push -f`) sem pedido explicito do usuario.
- H5 CRITICAL (git hooks): branches protegidas (`git-hooks/protected-branches.txt`: `master`, `main`) nunca recebem commit, merge ou push; so via Pull Request.
- H6 CRITICAL (git hooks): nunca contorne os git hooks: proibido `--no-verify`, `git commit -n`, `-c core.hooksPath`, alterar `core.hooksPath` ou editar `git-hooks/` sem pedido explicito do usuario. Se um hook bloquear, pare e avise.
- H7 CRITICAL (check-hooks): antes de qualquer acao rode `check-hooks.ps1`; se nao der `VAULT HOOKS: OK`, comece a resposta com `ATENCAO: HOOKS DO VAULT NAO ESTAO FUNCIONANDO - <motivo>` e nao faca commit, merge ou push.

## Mapa tema -> nota
| Tema | Nota |
|---|---|
| Arquitetura e escopo (sempre) | conhecimento/arquitetura-e-escopo.md |
| C# / .NET | conhecimento/csharp-dotnet.md |
| Selenium (C#) | conhecimento/selenium-csharp.md |
| SQL Server | conhecimento/sql-server.md |
| React / TSX | conhecimento/react-tsx.md |
| JavaScript | conhecimento/javascript.md |
| HTML / CSS | conhecimento/html-css.md |
| Testes | conhecimento/testes.md |
| Git | conhecimento/git.md |

## Regras gerais
1. Siga a arquitetura existente do projeto; leia a estrutura antes de criar arquivos ou camadas.
2. Altere somente o que foi pedido; nada fora do escopo.
3. Codigo, nomes e comentarios de codigo sempre em ingles (notas em portugues).
4. CRITICAL: nunca faca commit ou push sem pedido explicito.
5. Na duvida sobre uma regra, pergunte; nao invente.
6. Tarefas longas em etapas numeradas, com inicio, fim e horario.
7. CRITICAL: NUNCA altere uma regra, configuracao ou codigo com regra de negocio ou impacto na execucao (praticamente todo codigo) sem o usuario pedir ou sem avisar antes. Altere somente os trechos pedidos; nunca mexa em trechos que o usuario nao pediu.
8. Seja objetivo:
9. Regras e instrucoes do usuario ficam somente nos arquivos certos do vault (`AGENTS.md` ou nota do tema); NUNCA grave em repositorio fora do vault (ex.: `.github/copilot-instructions.md` de projeto).
10. Memorias: salve no vault somente o que vier da conversa com o usuario, do que ele apontar no chat, ou do codigo dele. Codigo do usuario = commits do autor `João Yonea <jyonea@ad.esi.adp.com>` ou `jlyonea <jlyonea@hotmail.com>`. NUNCA colete memorias de commits ou codigo de outros desenvolvedores sem avisar o usuario antes.
