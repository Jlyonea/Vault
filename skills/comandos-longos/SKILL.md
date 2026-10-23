---
name: comandos-longos
description: Regra obrigatoria do usuario para comandos que podem demorar (terminal, varredura de pastas/binarios, build, testes, rede, instalacao). Carregue SEMPRE antes de rodar um comando que possa passar de 30 segundos, em QUALQUER repositorio. Exibe LOGS de progresso para o usuario saber se travou e, se travar, para o comando e retoma o raciocinio sem perder o prompt.
---
# Comandos longos: logs de progresso e recuperacao de travamento

Motivo: um comando que roda sem saida deixa o usuario vendo so o spinner, sem saber se a aplicacao travou.

Causa real ja vista: um comando cancelado pela ferramenta ("A task was canceled") CONTINUA rodando no terminal do agente e bloqueia todos os comandos seguintes (fila). Por isso o trabalho pesado nunca roda direto no terminal.

## Antes de rodar
1. Estime a duracao. Comando curto (< 30 s): pode rodar em background (`background=true`), nunca bloqueante.
2. Comando que pode passar de 30 s (busca recursiva, leitura de binarios grandes, build, testes, rede): rode SEMPRE pelo `run-safe.ps1` do vault:
   `& ../Vault/run-safe.ps1 -Command '<comando>' -TimeoutSec 180 -IdleSec 60`
   - Retorna na hora `RUN-SAFE pid=<pid> log=<caminho>`; o terminal fica livre.
   - Roda em processo oculto separado; um vigia mata a arvore de processos se passar do timeout ou ficar sem saida por `IdleSec` e grava `[run-safe] KILLED: <motivo>` no log.
   - Fim normal: `[run-safe] END` no log.
   - Erro de sintaxe: retorna na hora `RUN-SAFE PARSE ERROR`; corrija o comando (no PowerShell `\"` nao e escape; use aspas simples ou `` ` ``).
   - Processo morreu sem `END`: o log registra `[run-safe] EXITED`. Isso e falha, nao travamento; leia o log e corrija.
   - Nao use `Sort-Object`/`Group-Object` sobre listagens grandes: seguram toda a saida ate o fim e parecem travamento.
3. Faca o comando imprimir progresso (ex.: uma linha por item/pasta). Sem saida o vigia considera travado.
4. Reduza o escopo antes: filtre pastas, tamanho e extensao; limite resultados (`Select-Object -First`). Nunca carregue binarios inteiros na memoria em lote. Prefira as ferramentas de busca do workspace a varrer arvores.

## Durante
5. A cada 15-30 s, leia o log com a ferramenta de leitura de arquivo (caminho absoluto; nao depende do terminal) ou a saida do background (`tailLines`) e mostre ao usuario:
   `LOG [HH:mm:ss] <etapa> - rodando ha <N> s - ultima saida: <linha>`
6. Saida nova desde a ultima leitura = comando vivo; siga monitorando.

## Travou: escada de recuperacao
7. Sinais de travamento: nenhuma saida nova por 60 s, duracao > 3 min sem previsao, `KILLED` no log, ou a ferramenta retornar cancelamento/timeout.
8. Mostre: `LOG [HH:mm:ss] TRAVOU: <etapa> - <motivo provavel>.` e siga em ordem:
   1. Pare o comando (`stop=true`).
   2. Teste o terminal: `Write-Output alive` em background, aguarde ate 10 s.
   3. Se respondeu: siga com abordagem mais leve via `run-safe.ps1`. Nunca repita o mesmo comando sem mudanca.
   4. Se nao respondeu: aguarde mais 20 s e teste de novo (o processo antigo pode estar terminando).
   5. Se continuar bloqueado: NAO envie mais comandos de terminal (eles so entram na fila). Continue o que for possivel com ferramentas que nao usam terminal (leitura de arquivo, busca no workspace, busca de simbolos) e avise o usuario.
   6. So entao peca ao usuario para reiniciar o terminal: fechar a janela Terminal do Visual Studio ou, no Gerenciador de Tarefas, aba "Detalhes", finalizar o `powershell.exe`/`pwsh.exe` mais recente (a aba "Processos" agrupa ele dentro do Visual Studio).

## Retomar sem perder o prompt
9. Releia o pedido original do usuario nesta conversa e mostre um resumo curto: `Retomando: <pedido> - concluido: <etapas> - proxima: <etapa>`.
10. Continue a partir da ultima etapa concluida. Nunca peca ao usuario para repetir o prompt e nao refaca etapas ja concluidas.
11. Se a abordagem alternativa tambem travar, pare e pergunte ao usuario como seguir.
