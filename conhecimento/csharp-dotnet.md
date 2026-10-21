# C# / .NET

verificado em: 2026-10-20

## TL;DR
- Codigo em ingles, PascalCase para tipos/metodos, camelCase para variaveis/parametros; seguir camadas do projeto.

## Regras
1. PascalCase: classes, metodos, propriedades. camelCase: variaveis locais e parametros.
2. Nomes e comentarios de codigo em ingles.
3. Seguir conhecimento/arquitetura-e-escopo.md.

## Regras especificas (a confirmar)
- <usar /nova-regra para adicionar>

## Exemplo
Certo:
```csharp
public decimal CalculateTotal(Order order) { var itemCount = order.Items.Count; ... }
```
Errado:
```csharp
public decimal calcular_total(Order Pedido) { var QtdItens = Pedido.Items.Count; ... }
```
