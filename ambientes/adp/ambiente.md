# Ambiente: ADP
verificado em: 2026-10-26
## TL;DR
- Robos de automacao em C# + Selenium. Seguir SEMPRE o padrao dos projetos e da organizacao; nao inventar arquitetura.
- CRITICAL: um robo NUNCA referencia outro projeto de robo; so `ADPR.Bootstrapper` ou `ADPR.Common`.
- Vault publico: NUNCA gravar dados de clientes da ADP (regra geral 15). So arquitetura, padroes e workflows, de forma generica.
## Stack
- C# / .NET
- Selenium (C#)
## Arquitetura
1. Siga a estrutura e o padrao do robo/projeto atual e da organizacao (ver `conhecimento/arquitetura-e-escopo.md`).
2. Nao crie camadas, abstracoes, pastas, helpers ou frameworks novos sem pedido.
3. Reutilize metodos, esperas e utilitarios que ja existem no projeto antes de criar novos.
depois de confirmar com ele; nunca aplicar mudancas por conta propria.
## Selenium
1. Nao introduzir Page Object sem pedido; seguir o que o projeto ja faz.
## Testes
1. Nao ha framework de teste definido. Nao adicionar xUnit/NUnit/MSTest sem pedido, nem criar projeto de teste.
2. Quando houver teste, nomear `Metodo_NumeroTarefa_Resultado` (em ingles, exceto o numero). Ex.: `CalculateTotal_1234_ReturnsZeroWhenEmpty`.
3. Um arquivo de teste por arquivo de codigo testado.
## Notas que se aplicam
- conhecimento/arquitetura-e-escopo.md
- conhecimento/csharp-dotnet.md
- conhecimento/selenium-csharp.md
- conhecimento/testes.md
- conhecimento/git.md
## Padrao dos robos ADP
Preencher de forma generica, sem nomes de clientes, URLs internas ou dados reais. Robo de referencia: `ADPR.MX.SUAPagos`.
- Estrutura de pastas/projetos (todos os robos seguem):
  - `Instructions/`: fluxo principal do robo. Deve ser simples: so orquestra, chamando metodos das classes de `Worksteps/`.
  - `Models/`: classes de objetos e enums, como `Constants` e `ProcessData`.
  - `Services/`: arquivo de configuracao do projeto (servico do robo).
  - `Worksteps/`: uma classe por contexto/plataforma, com os metodos daquele contexto. Ex.: `FactoryOperations` (tudo que trabalha com a plataforma Factory), `FileOperations` (operacoes de arquivos), `IdseOperations` (plataforma IDSE). Padrao de nome: `<Contexto>Operations`.
com os metodos que interagem com aquela tela.
  - `Elements/<Plataforma>/Pages/`: seletores (elementos) de cada tela mapeada; `Actions/` usa esses elementos nos metodos de interacao.
So pode referenciar `ADPR.Bootstrapper` e `ADPR.Common`.
- Fluxo de execucao:
  1. Todo robo comeca pelo `ADPR.Bootstrapper`, que traz uma requisicao da plataforma ADPR.
  2. A requisicao chega com os dados no Payload, que preenche o `WorkflowData`.
  3. O Bootstrapper executa o `ExecuteProcess` da classe em `Instructions/` do robo.
  4. Status final da requisicao no ADPR:
     - `ExecuteProcess` termina sem erro: Sucesso.
     - Excecao lancada: System Exception ou Business Exception (`BusinessException`).
     - Defer: so quando o robo lanca (`throw`) uma excecao do tipo defer (`DeferredException`, em `ADPR.Common.Exceptions`).
- Esperas e sincronizacao: <a definir>
- Retentativas e tratamento de erro: <a definir>
- Logs: <a definir>
- Configuracao (parametros, ambientes): <a definir>
