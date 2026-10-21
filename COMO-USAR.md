# Como usar o vault

## 1. Usar o vault em qualquer solucao (Visual Studio 2026)
O Copilot do VS carrega skills pessoais de `%USERPROFILE%\.copilot\skills\`. Existe uma junction
`%USERPROFILE%\.copilot\skills\vault` -> `Vault\skills\vault`, entao a skill vale para qualquer solucao aberta,
sem copiar nada para o projeto. Para recriar (ex.: outro PC), rode na pasta do vault:
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.copilot\skills" | Out-Null; New-Item -ItemType Junction -Path "$env:USERPROFILE\.copilot\skills\vault" -Target "$PWD\skills\vault"
```
Comandos no VS: peca "salvar nota", "revisar" ou "nova regra" no chat (a skill aponta para os prompts).
Hooks (`.github/hooks`) sao do VS Code; no VS o bloqueio vale como regra escrita na skill.

## 1b. (So VS Code) Abrir um projeto com o vault
1. Copie
2. Troque o caminho em `folders[0].path` pelo caminho do projeto.
3. No VS Code: File > Open Workspace from File.
4. Confira os nomes das settings `chat.*` em Settings (Ctrl+,). Os hooks estao em preview e os nomes podem mudar; se alguma setting aparecer como desconhecida, procure "hook", "instructions" ou "prompt" em Settings e ajuste.
5. Se mudar o vault de pasta, ajuste o caminho absoluto em `.github/hooks/guard.json` e `audit.json`.

## 2. Criar nota
- Pelo chat: `/salvar-nota` no fim de uma conversa util.
- Na mao: copie `conhecimento/_modelo-nota.md`, preencha, adicione a linha em `conhecimento/indice.md` e no mapa do `AGENTS.md`. Se quiser aplicar por tipo de arquivo, crie `.github/instructions/<tema>.instructions.md` com `applyTo`.

## 3. Comandos /
| Comando | Quando |
|---|---|
| `/salvar-nota` | Gravar o que aprendemos na conversa |
| `/revisar` | Antes de commitar: revisa o diff contra as regras |
| `/nova-regra` | Logo apos corrigir o agente |

## 4. Testar os hooks
Teste local (sem VS Code):
```powershell
'{"tool_name":"run_in_terminal","tool_input":{"command":"git push origin main"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File .github/hooks/guard.ps1
'{"tool_name":"run_in_terminal","tool_input":{"command":"git status"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File .github/hooks/guard.ps1
```
O primeiro deve imprimir `permissionDecision":"deny"`; o segundo, nada.

Teste no chat (modo Agent):
1. Peca "rode git status" -> deve executar. Verifique `.github/hooks/audit.log`.
2. Peca "rode git push" -> deve ser bloqueado com a mensagem do guard.
3. Se nao bloquear: abra `audit.log`, veja o nome real da ferramenta e o campo do comando (ex.: `tool_input.command`, `toolInput`...). Ajuste a lista de campos em `guard.ps1`.
4. Se nada aparecer no `audit.log`: os hooks nao estao carregando. Confira o Output > "GitHub Copilot Chat" e as settings do passo 1.

Observacao: o guard tambem bloqueia edicoes de arquivo cujo conteudo contenha esses termos (ex.: editar `git.md` com "git push"). Se incomodar, restrinja o guard ao nome da ferramenta de terminal descoberto no `audit.log`.
