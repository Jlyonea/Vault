# SQL Server

verificado em: 2026-10-20

## TL;DR
- Nada destrutivo sem pedido; nomes em ingles; seguir o padrao de nomes ja existente no banco.

## Regras
1. Nunca gerar/executar DROP, TRUNCATE ou DELETE sem WHERE sem pedido explicito.
2. Nomes de tabelas/colunas novas em ingles, seguindo o padrao ja usado no banco.
3. Nao alterar schema fora do escopo da tarefa.

## Regras especificas (a confirmar)
- <usar /nova-regra para adicionar>

## Exemplo
Certo: `DELETE FROM Customer WHERE CustomerId = @customerId;`
Errado: `DELETE FROM Customer;`
