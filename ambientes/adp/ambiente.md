# Ambiente: ADP
verificado em: 2026-10-20
## TL;DR
- Robos de automacao em C# + Selenium. Seguir SEMPRE o padrao dos projetos e da organizacao; nao inventar arquitetura.
- Vault publico: NUNCA gravar dados de clientes da ADP (regra geral 15). So arquitetura, padroes e workflows, de forma generica.
## Stack
- C# / .NET
- Selenium (C#)
## Arquitetura
1. Siga a estrutura e o padrao do robo/projeto atual e da organizacao (ver `conhecimento/arquitetura-e-escopo.md`).
2. Nao crie camadas, abstracoes, pastas, helpers ou frameworks novos sem pedido.
3. Reutilize metodos, esperas e utilitarios que ja existem no projeto antes de criar novos.
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
## Padrao dos robos ADP (a preencher com o robo de referencia)
Preencher de forma generica, sem nomes de clientes, URLs internas ou dados reais.
- Estrutura de pastas/projetos: <a definir>
- Fluxo de execucao (entrada, processamento, saida): <a definir>
- Esperas e sincronizacao: <a definir>
- Retentativas e tratamento de erro: <a definir>
- Logs: <a definir>
- Configuracao (parametros, ambientes): <a definir>
