# Git

verificado em: 2026-10-21

## TL;DR
- Conventional Commits, branch `feature/<nome>`, nunca commit/push sem pedido.
- Branches protegidas (`master`, `main`) so mudam via Pull Request; nunca contornar os git hooks.

## Regras
1. Mensagem: `tipo(escopo opcional): descricao` (feat, fix, refactor, docs, test, chore), em ingles.
2. Branch por feature: `feature/<descricao-curta>`.
3. Nunca commit, push, force ou reset sem pedido explicito.
4. Branches protegidas (lista em `git-hooks/protected-branches.txt`): nunca commit, merge ou push; so via Pull Request. Os git hooks do vault bloqueiam.
5. Nunca contornar os hooks: proibido `--no-verify`, `git commit -n`, `-c core.hooksPath`, alterar `core.hooksPath` ou editar `git-hooks/` sem pedido explicito. Se um hook bloquear, parar e avisar.

## Exemplo
Certo: `feat(customer): add email field to registration`
Errado: `ajustes`
