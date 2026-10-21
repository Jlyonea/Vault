---
description: Revisa o diff atual contra as regras do vault
agent: agent
---
Revise as alteracoes atuais contra as regras do vault:

1. Obtenha o diff com `git diff` e `git diff --staged` no projeto (somente leitura).
2. Leia `AGENTS.md`, `conhecimento/arquitetura-e-escopo.md` e as notas dos temas dos arquivos alterados (veja `conhecimento/indice.md`).
3. Para cada violacao, liste: arquivo:linha, regra violada (nota + numero), e a correcao sugerida.
4. Aponte especialmente: mudancas fora do escopo, desvio da arquitetura, nomes fora do padrao, codigo/nomes nao em ingles.
5. Nao altere arquivos; apenas reporte. Se nao houver violacoes, diga isso em uma linha.
