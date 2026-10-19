# Template de carta

Arquivo: `cartas/<cultura>/<NN>_<slug>.md` (NN = 01–32 na ordem do deck; cópias duplicadas **não** ganham arquivo próprio — a seção Deck lista "×2").
Idioma: português. Nome da carta pode ficar no original (Xiwangmu, Hanuman) com tradução no contexto.

```markdown
# <Nome da carta>

| Campo | Valor |
|---|---|
| Cultura | <indígena brasileira / cristianismo / taoismo / hinduísmo / bruxaria / alta magia> |
| Tipo | Entidade / Selo / Rito / Relíquia |
| Custo | N Fé |
| ATK / Vida | a / v (só Entidade) |
| Palavras-chave | … |
| Lendária | sim / não |
| Cópias no deck | 1 / 2 |

## Texto da carta
<Texto curto como aparece na carta, ≤ 30 palavras. Ex.: "Guarda. Sempre que outra Entidade aliada for atacada, causa 1 de dano ao atacante.">

## Contexto mitológico
<2–4 parágrafos: quem/o que é, fonte (texto, região, povo), variantes, por que virou carta desse tipo.>

## Papel no jogo
<1 parágrafo: função no deck, sinergias com outras cartas do deck, contra o que é boa/ruim.>

## Balanço
Orçamento P = 2·C+1 = <n> pts. Gasto: ATK <a> + Vida <v> + <habilidade X = y pts> = <total>. <Dentro / Lendária +k>.

## Dados
```json
{ ...conforme docs/dsl_efeitos.md... }
```

## Prompt de arte
_(preenchido na fase de arte)_
```

Cada pasta de cultura também tem `_deck.md`: identidade mecânica do deck (2 parágrafos), lista das 32 cartas (com ×2), contagem por tipo (14/6/8/4), curva de custo das Entidades, e `_estudo.md`: o catálogo da pesquisa (figuras, relíquias, ritos, fontes) de onde as cartas saíram — inclusive o que ficou de fora e por quê.
