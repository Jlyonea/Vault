---
description: Grava minha correcao como regra na nota certa
agent: agent
---
Eu acabei de corrigir voce. Transforme a correcao em regra:

1. Resuma a correcao em uma regra curta e objetiva e me mostre antes de gravar. Se houver ambiguidade, pergunte.
2. Use `conhecimento/indice.md` para escolher a nota do tema. Se nenhuma servir, crie uma a partir de `conhecimento/_modelo-nota.md` e atualize `indice.md` e o mapa do `AGENTS.md`.
3. Adicione a regra na secao "Regras" (ou substitua "a confirmar") com exemplo certo/errado se couber.
4. Atualize `verificado em:` para a data de hoje.
5. Nao altere outras regras. Nao faca commit.

Correcao: ${input:correcao:Descreva a correcao (ou deixe vazio para usar a conversa)}
