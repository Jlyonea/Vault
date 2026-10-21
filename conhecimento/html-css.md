# HTML / CSS

verificado em: 2026-10-20

## TL;DR
- Reutilizar classes e estilos existentes; nao mexer em estilos globais fora do escopo.

## Regras
1. Antes de criar classe CSS nova, procurar uma existente que sirva.
2. Nao alterar estilos globais/compartilhados sem pedido.
3. Nomes de classes/ids em ingles.
4. Ao alterar marcacao de front-end (HTML, JSX/TSX), garantir que toda tag aberta foi fechada (ex.: `<header>` ... `</header>`). Antes de concluir, reler o trecho alterado inteiro e comparar com a versao anterior para confirmar que nenhum conteudo foi cortado.
   - Certo: `<header className="site-header">...<nav>...</nav></header>`
   - Errado: `<header className="site-header">` sem o conteudo nem o `</header>`

## Regras especificas (a confirmar)
- <usar /nova-regra para adicionar>
