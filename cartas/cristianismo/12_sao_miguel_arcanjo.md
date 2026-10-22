# São Miguel Arcanjo

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 7 Fé |
| ATK / Vida | 5 / 6 |
| Palavras-chave | Guarda, Despertar, Lendária |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Guarda. Despertar: Destrua uma Entidade inimiga.

## Contexto mitológico
Miguel ("Quem é como Deus?") é "um dos primeiros príncipes" que vem em socorro de Daniel contra o príncipe da Pérsia (Dn 10,13) e "o grande príncipe que defende os filhos do teu povo" no tempo da angústia final (Dn 12,1). A Epístola de Judas lembra que ele disputou com o diabo o corpo de Moisés sem ousar julgá-lo por conta própria: "O Senhor te repreenda" (Jd 9). E o Apocalipse o faz general da guerra celeste: "Miguel e os seus anjos combateram contra o Dragão... e o grande Dragão foi precipitado, a antiga serpente, chamada Diabo e Satanás" (Ap 12,7-9).

A *Legenda Áurea* (cap. "São Miguel Arcanjo") acrescenta as aparições no Monte Gargano, na Apúlia, e o papel de psicopompo que recebe as almas e combaterá o Anticristo. A iconografia desenvolveu daí a psicostasia: é Miguel quem pesa as almas na balança no Juízo Final, como se vê nos tímpanos de Autun e Bourges e no políptico de Rogier van der Weyden em Beaune. Na iconografia é um guerreiro de armadura, lança ou espada em riste, o pé sobre o dragão derrubado, muitas vezes com a balança na outra mão.

A carta é o juiz-guerreiro: ao chegar, **julga** — destrói uma Entidade inimiga sem condição — e depois fica de **Guarda** entre o inimigo e os seus.

## Papel no jogo
O momento "uau" do deck e a única remoção incondicional. Chega no turno 7, elimina a maior ameaça do oponente e planta um 5/6 com Guarda que protege os Renascidos. Com a Arca da Aliança vira 5/9 e dá +1 ATK a todos. Revivê-lo por Talita Cumi ou Tumba Vazia devolve a muralha, não o julgamento: reviver para o campo não dispara Despertar (regras §8). Por ser caro, mãos sem Entidades baratas ficam a descoberto até ele chegar; e um `bounce` inimigo devolve 7 Fé de investimento à mão.

## Balanço
Orçamento P = 2·C+1 = 15 pts; Lendária pode passar até +2 → 17. Gasto: ATK 5 + Vida 6 + Guarda 1 + destruir Entidade inimiga escolhida 5 = 17. Lendária +2.
Rodada 1 de balanceamento: era 6/6 (18 com `destroy` a 5 pts, acima do teto; 81 % de WR global).

## Dados
```json
{
  "id": "cri_sao_miguel_arcanjo",
  "nome": "São Miguel Arcanjo",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 7,
  "atk": 5,
  "vida": 6,
  "lendaria": true,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "destroy", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, archangel warrior, large white feathered bird wings, golden halo, golden armor, red cloak, short golden hair, stern face, flaming sword raised high, golden scales in other hand, one foot on the head of a defeated black dragon, dragon lying crushed under his feet, standing guard, defensive heroic stance, facing viewer, dark battlefield in clouds, broken columns, beam of holy light from above, gold and white, dramatic rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: espada flamejante na mão direita · balança dourada na esquerda · armadura dourada e capa vermelha · pé sobre a cabeça do dragão · asas brancas e auréola
```krea
A tall adult warrior archangel, Saint Michael, with a stern youthful face, olive skin and short golden curly hair, standing firmly and facing the viewer in a defensive guarding stance. Two large white feathered wings spread behind him and a golden halo circles his head. He wears gold Roman-style armor with a breastplate, a red cloak and armored sandals. He has two normal arms and two hands: his right hand raises a flaming sword high, and his left hand holds a pair of golden balance scales. His right foot rests on the head of a defeated black dragon lying crushed beneath him. Storm clouds and broken columns, with a strong beam of light from above.
```
