# React / TSX

verificado em: 2026-10-20

## TL;DR
- Componentes PascalCase, props/variaveis camelCase, codigo em ingles; seguir estrutura de pastas existente.

## Regras
1. Componente e arquivo do componente em PascalCase; hooks, props e variaveis em camelCase.
2. Nao adicionar bibliotecas (estado, estilo, UI) sem pedido.
3. Seguir conhecimento/arquitetura-e-escopo.md.

## Regras especificas (a confirmar)
- <usar /nova-regra para adicionar>

## Exemplo
Certo: `export function UserCard({ userName }: UserCardProps) { ... }`
Errado: `export function cartao_usuario({ NomeUsuario }) { ... }`
