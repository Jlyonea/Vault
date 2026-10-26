# Git

verificado em: 2026-10-26

## TL;DR
- Conventional Commits, branch `feature/<nome>`, nunca commit/push sem pedido.
- Branches protegidas (`master`, `main`) so mudam via Pull Request; nunca contornar os git hooks.

## Regras
1. Mensagem: `tipo(escopo opcional): descricao` (feat, fix, refactor, docs, test, chore), em ingles.
2. Branch por feature: `feature/<descricao-curta>`.
3. Nunca commit, push, force ou reset sem pedido explicito.
4. Branches protegidas (lista em `git-hooks/protected-branches.txt`): nunca commit, merge ou push; so via Pull Request. Os git hooks do vault bloqueiam.
5. Nunca contornar os hooks: proibido `--no-verify`, `git commit -n`, `-c core.hooksPath`, alterar `core.hooksPath` ou editar `git-hooks/` sem pedido explicito. Se um hook bloquear, parar e avisar.
6. CRITICAL: identidade do autor (regra geral 16 do `AGENTS.md`): e-mail da ADP (`jyonea@ad.esi.adp.com`) so em projetos da ADP/ADPR; em todos os outros projetos (pessoais e o vault), `jlyonea <jlyonea@hotmail.com>`. Conferir antes de todo commit e, se errado, ajustar com `git config --local`.

## Exemplo
Certo: `feat(customer): add email field to registration`
Errado: `ajustes`
Certo (projeto pessoal): autor `jlyonea <jlyonea@hotmail.com>`
Errado (projeto pessoal): autor `João Yonea <jyonea@ad.esi.adp.com>`
