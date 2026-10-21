# Arquitetura e escopo

verificado em: 2026-10-20

## TL;DR
- O agente ignora a arquitetura e mexe fora do escopo. Isso e o erro principal a evitar.

## Regras
1. Antes de criar arquivo, classe ou camada, olhe onde codigo parecido ja vive e siga o mesmo padrao.
2. Nao crie novas camadas, abstracoes ou pastas sem pedido.
3. Altere somente o necessario para a tarefa. Nao refatore, renomeie nem "melhore" codigo vizinho.
4. Nao altere regras de negocio fora do que foi pedido; se achar que precisa, pergunte.
5. Nao mude versoes de pacotes nem configuracoes sem pedido.

## Exemplo
Certo: pedido "adicionar campo Email no cadastro" -> altera DTO, entidade, tela e query desse cadastro.
Errado: no mesmo pedido, renomear metodos, mover arquivos ou mudar validacao de outro campo.
