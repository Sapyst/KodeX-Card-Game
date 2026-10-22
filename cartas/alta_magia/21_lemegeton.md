# Lemegeton, a Chave Menor

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Rito |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Compre uma Entidade do seu deck.

## Contexto mitológico
O *Lemegeton Clavicula Salomonis* — a Chave Menor de Salomão — é o grimório mais influente da magia ocidental. Compilado em inglês no século XVII (Sloane MSS 2731 e 3825, British Library) a partir de materiais mais antigos, reúne cinco livros: a **Ars Goetia**, catálogo dos 72 espíritos com selos, ofícios, legiões e as conjurações para chamá-los; a *Theurgia-Goetia* (espíritos dos pontos cardeais); a *Ars Paulina* (anjos das horas e dos signos); a *Ars Almadel* (anjos das quatro altitudes, via tábua de cera); e a *Ars Notoria* (orações para a ciência instantânea).

A Goetia deriva da *Pseudomonarchia Daemonum* de Johann Weyer (1577), que listou 69 demônios mas omitiu de propósito os selos e o modo de conjurar — o Lemegeton os restitui. Mathers traduziu o texto para a Golden Dawn; Crowley o publicou em 1904 com introdução, a famosa explicação psicológica ("os espíritos da Goetia são porções do cérebro humano"), a Invocação Preliminar (o Rito do Sem-Cabeça) e as conjurações vertidas para o enochiano. Peterson editou criticamente os manuscritos em 2001.

A carta é o grimório aberto: você procura o nome do espírito certo e o chama à mão. É a Clavícula — a chave que abre a lista.

## Papel no jogo
Tutor universal de Entidades por 1 Fé: no turno 1 busca Homúnculo ou Kelley, no turno 4 busca Astaroth ou Dantalion, no turno 6 busca Babalon ou o Anjo. Garante que o deck de controle, que joga poucas Entidades, sempre tenha a certa. É carta de "troca 1 por 1": não gera vantagem, só precisão.

## Balanço
Orçamento P = 2·1+1 = 3 pts. Gasto: buscar carta de tipo específico do deck (2) = 2. Dentro (1 pt abaixo, aceitável para um tutor sem restrição de custo).

## Dados
```json
{
  "id": "alt_lemegeton",
  "nome": "Lemegeton, a Chave Menor",
  "cultura": "alta_magia",
  "tipo": "rito",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "search", "tipo": "entidade" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, hooded magician seen from behind, over the shoulder view, dark robe, pointing at an open ancient grimoire, large book on a wooden lectern, book in the foreground, open pages covered with circular seals, one seal glowing gold, faint spectral shape rising from the page, candles, ritual chamber, chalk circle on stone floor, black and gold, red candlelight, dust particles, dramatic shadows, close-up, upper body
```

## Prompt Krea 2
Atributos obrigatórios: grimório antigo grande e aberto num atril de madeira · páginas cobertas de selos circulares · um selo brilhando em dourado · forma espectral subindo da página · mão do mago apontando
```krea
A large ancient grimoire lies open on a carved wooden lectern, its yellowed pages covered with circular demon seals and dense handwritten script. One seal on the right page glows bright gold, and a faint spectral shape of smoke and light rises from it. The hand of an unseen magician in a dark sleeve points at the glowing seal with one finger. Around the lectern, a chalk circle on a stone floor and a few candles in a dark ritual chamber. The glow of the seal is the strongest light, lighting the pages from within.
```
