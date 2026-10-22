# KodeX: divergências entre o texto antigo e o efeito programado

Fonte da verdade: JSON `efeitos` das fichas (idêntico ao de `godot/dados/cartas.json`, conferido carta a carta) e a semântica de `godot/motor_efeitos.gd` (o servidor `regras.js` segue as mesmas regras de `interativo`, `on_damaged` e Selos). Nenhum JSON foi alterado.

## A. O texto prometia escolha de alvo, mas o motor escolhe sozinho

Gatilhos `on_attack`, `equipped_attacks` e `on_death` rodam sem `interativo` (só Despertar, Rito e Ao equipar são interativos). Com mais de um alvo, `_escolher` usa `ia_alvo` (dano: a que morre e vale mais; senão a de maior ATK; debuff: a de maior valor). O jogador não escolhe.

### `cri_davi_o_pastor` (Davi, o Pastor)
- **Antigo PT:** Ao atacar, causa 2 de dano a uma Entidade inimiga à sua escolha.
- **Antigo EN:** When this attacks, deal 2 damage to an enemy Entity of your choice.
- **JSON:** `[{"gatilho":"on_attack","acoes":[{"op":"damage","alvo":"enemy_entity","n":2}]}]`
- **Novo EN:** Whenever this attacks, deal 2 damage to an enemy Entity.
- **Novo PT:** Sempre que esta atacar, cause 2 de dano a uma Entidade inimiga.
- **Novo ES:** Cada vez que esta ataque, inflige 2 de daño a una Entidad enemiga.

### `hin_arjuna` (Arjuna)
- **Antigo PT:** Furtivo. Ao atacar, causa 1 de dano a uma Entidade inimiga à sua escolha.
- **Antigo EN:** Stealth. When this attacks, deal 1 damage to an enemy Entity of your choice.
- **JSON:** `[{"gatilho":"on_attack","acoes":[{"op":"damage","alvo":"enemy_entity","n":1}]}]`
- **Novo EN:** Stealth. Whenever this attacks, deal 1 damage to an enemy Entity.
- **Novo PT:** Furtivo. Sempre que esta atacar, cause 1 de dano a uma Entidade inimiga.
- **Novo ES:** Furtivo. Cada vez que esta ataque, inflige 1 de daño a una Entidad enemiga.

### `cri_funda_de_davi` (Funda de Davi)
- **Antigo PT:** A portadora ganha +2 ATK e Ímpeto. Quando ela ataca, causa 1 de dano a uma Entidade inimiga à sua escolha.
- **Antigo EN:** The bearer gains +2 ATK and Rush. When it attacks, deal 1 damage to an enemy Entity of your choice.
- **JSON:** `[{"gatilho":"on_equip","acoes":[{"op":"buff","alvo":"equipped","atk":2,"vida":0,"perm":true},{"op":"give_keyword","alvo":"equipped","keyword":"impeto"}]},{"gatilho":"equipped_attacks","acoes":[{"op":"damage","alvo":"enemy_entity","n":1}]}]`
- **Novo EN:** The bearer gains +2 ATK and Rush. Whenever the bearer attacks, deal 1 damage to an enemy Entity.
- **Novo PT:** A portadora ganha +2 ATK e Ímpeto. Sempre que ela atacar, cause 1 de dano a uma Entidade inimiga.
- **Novo ES:** La portadora gana +2 ATK e Ímpetu. Cada vez que ataque, inflige 1 de daño a una Entidad enemiga.

### `bru_sapo_familiar` (Sapo Familiar)
- **Antigo PT:** Último Sopro: uma Entidade inimiga à escolha perde 1 ATK e 1 Vida permanentemente.
- **Antigo EN:** Last Breath: An enemy Entity of your choice loses 1 ATK and 1 Health permanently.
- **JSON:** `[{"gatilho":"on_death","acoes":[{"op":"buff","alvo":"enemy_entity","atk":-1,"vida":-1,"perm":true}]}]`
- **Novo EN:** Last Breath: An enemy Entity gets -1/-1.
- **Novo PT:** Último Sopro: Uma Entidade inimiga recebe -1/-1.
- **Novo ES:** Último Aliento: Una Entidad enemiga recibe -1/-1.

## B. "Busque" no deck: o jogador não escolhe a carta

`op: search` (`_buscar`) pega sozinho a carta do tipo pedido mais cara jogável no próximo turno (senão a mais barata), embaralha o deck e põe na mão. "Busque" sugere que o jogador escolhe. Novo molde: "Compre uma Relíquia do seu deck" / "Draw a Relic from your deck" / "Roba una Reliquia de tu mazo". Kelley e Vassago também não diziam que a carta vai para a mão. **O molde de busca do guia de estilo precisa ser atualizado.**

### `cri_gabriel` (Gabriel, o Mensageiro)
- **Antigo PT:** Despertar: busque um Rito do seu deck para a mão.
- **Antigo EN:** Awaken: Search your deck for a Rite and put it into your hand.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"search","tipo":"rito"}]}]`
- **Novo EN:** Awaken: Draw a Rite from your deck.
- **Novo PT:** Despertar: Compre um Rito do seu deck.
- **Novo ES:** Despertar: Roba un Rito de tu mazo.

### `hin_matsya` (Matsya, o Peixe)
- **Antigo PT:** Despertar: busque uma Relíquia do seu deck para a mão.
- **Antigo EN:** Awaken: Search your deck for a Relic and put it into your hand.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"search","tipo":"reliquia"}]}]`
- **Novo EN:** Awaken: Draw a Relic from your deck.
- **Novo PT:** Despertar: Compre uma Relíquia do seu deck.
- **Novo ES:** Despertar: Roba una Reliquia de tu mazo.

### `alt_edward_kelley` (Edward Kelley, o Vidente)
- **Antigo PT:** Furtivo. Despertar: busque uma Relíquia do seu deck.
- **Antigo EN:** Stealth. Awaken: Search your deck for a Relic.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"search","tipo":"reliquia"}]}]`
- **Novo EN:** Stealth. Awaken: Draw a Relic from your deck.
- **Novo PT:** Furtivo. Despertar: Compre uma Relíquia do seu deck.
- **Novo ES:** Furtivo. Despertar: Roba una Reliquia de tu mazo.

### `alt_vassago` (Vassago, o Príncipe que Acha)
- **Antigo PT:** Despertar: busque um Selo do seu deck.
- **Antigo EN:** Awaken: Search your deck for a Seal.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"search","tipo":"selo"}]}]`
- **Novo EN:** Awaken: Draw a Seal from your deck.
- **Novo PT:** Despertar: Compre um Selo do seu deck.
- **Novo ES:** Despertar: Roba un Sello de tu mazo.

### `bru_seidr` (Seiðr)
- **Antigo PT:** Busque uma Entidade do seu deck e ponha-a na mão. Embaralhe.
- **Antigo EN:** Search your deck for an Entity and put it into your hand. Shuffle.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"search","tipo":"entidade"}]}]`
- **Novo EN:** Draw an Entity from your deck.
- **Novo PT:** Compre uma Entidade do seu deck.
- **Novo ES:** Roba una Entidad de tu mazo.

### `alt_lemegeton` (Lemegeton, a Chave Menor)
- **Antigo PT:** Busque uma Entidade do seu deck e coloque-a na mão.
- **Antigo EN:** Search your deck for an Entity and put it into your hand.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"search","tipo":"entidade"}]}]`
- **Novo EN:** Draw an Entity from your deck.
- **Novo PT:** Compre uma Entidade do seu deck.
- **Novo ES:** Roba una Entidad de tu mazo.

## C. "Sempre que sofrer dano" só dispara com dano de atacante

`on_damaged` com alvo `attacker`: `pos_dano` só passa `attacker` quando a Entidade é atacada (defensora). Dano de Rito/efeito e o contragolpe quando ela mesma ataca não têm atacante, então nada acontece. Boitatá já dizia "de um ataque", mas era ambíguo (vale também quando ela ataca?); agora as três usam o mesmo molde.

### `ind_curupira` (Curupira)
- **Antigo PT:** Guarda. Sempre que sofrer dano, causa 1 de dano ao atacante.
- **Antigo EN:** Guard. Whenever this takes damage, deal 1 damage to the attacker.
- **JSON:** `[{"gatilho":"on_damaged","acoes":[{"op":"damage","alvo":"attacker","n":1}]}]`
- **Novo EN:** Guard. Whenever an attacker damages this, the attacker takes 1 damage.
- **Novo PT:** Guarda. Sempre que um atacante a ferir, ele sofre 1 de dano.
- **Novo ES:** Guardia. Cada vez que un atacante la dañe, recibe 1 de daño.

### `ind_mapinguari` (Mapinguari)
- **Antigo PT:** Sempre que sofrer dano, causa 2 de dano ao atacante.
- **Antigo EN:** Whenever this takes damage, deal 2 damage to the attacker.
- **JSON:** `[{"gatilho":"on_damaged","acoes":[{"op":"damage","alvo":"attacker","n":2}]}]`
- **Novo EN:** Whenever an attacker damages this, the attacker takes 2 damage.
- **Novo PT:** Sempre que um atacante a ferir, ele sofre 2 de dano.
- **Novo ES:** Cada vez que un atacante la dañe, recibe 2 de daño.

### `ind_boitata` (Boitatá)
- **Antigo PT:** Guarda. Sempre que sofrer dano de um ataque, causa 1 de dano ao atacante.
- **Antigo EN:** Guard. Whenever this takes damage from an attack, deal 1 damage to the attacker.
- **JSON:** `[{"gatilho":"on_damaged","acoes":[{"op":"damage","alvo":"attacker","n":1}]}]`
- **Novo EN:** Guard. Whenever an attacker damages this, the attacker takes 1 damage.
- **Novo PT:** Guarda. Sempre que um atacante a ferir, ele sofre 1 de dano.
- **Novo ES:** Guardia. Cada vez que un atacante la dañe, recibe 1 de daño.

## D. Boneco de Cera se gasta com qualquer dano

`ally_damaged` (Selo) dispara com qualquer dano numa aliada no turno do oponente, inclusive dano de efeito. Sem atacante, as ações não têm alvo, mas o Selo vai ao cemitério do mesmo jeito. O texto antigo dizia que só disparava com dano de ataque.

### `bru_boneco_de_cera` (Boneco de Cera)
- **Antigo PT:** Quando uma Entidade aliada sofrer dano de um ataque, o atacante sofre 4 de dano e perde 2 ATK e 2 Vida permanentemente.
- **Antigo EN:** When an allied Entity takes damage from an attack, the attacker takes 4 damage and loses 2 ATK and 2 Health permanently.
- **JSON:** `[{"gatilho":"ally_damaged","acoes":[{"op":"damage","alvo":"attacker","n":4},{"op":"buff","alvo":"attacker","atk":-2,"vida":-2,"perm":true}]}]`
- **Novo EN:** When an allied Entity takes damage: if an attacker dealt it, the attacker takes 4 damage and gets -2/-2.
- **Novo PT:** Quando uma Entidade aliada sofrer dano: se veio de um atacante, ele sofre 4 de dano e recebe -2/-2.
- **Novo ES:** Cuando una Entidad aliada reciba daño: si vino de un atacante, este recibe 4 de daño y -2/-2.

## E. "Quando uma Entidade inimiga atacar": não vale para golpe direto

`enemy_attacks` só dispara quando o alvo do ataque é uma Entidade sua. O golpe direto na Cornucópia usa outro gatilho (`enemy_attacks_cornucopia`). Novo molde: "When one of your Entities is attacked" / "Quando atacarem uma Entidade sua" / "Cuando ataquen a una Entidad tuya". Arapuca e Mundéu já estavam certos e só mudaram de molde.

### `cri_sangue_nos_umbrais` (Sangue nos Umbrais)
- **Antigo PT:** Quando uma Entidade inimiga atacar, destrua-a. Cure 4 da sua Cornucópia.
- **Antigo EN:** When an enemy Entity attacks, destroy it. Heal your Cornucopia for 4.
- **JSON:** `[{"gatilho":"enemy_attacks","acoes":[{"op":"destroy","alvo":"attacker"},{"op":"heal","alvo":"ally_cornucopia","n":4}]}]`
- **Novo EN:** When one of your Entities is attacked, destroy the attacker. Heal your Cornucopia for 4.
- **Novo PT:** Quando atacarem uma Entidade sua, destrua o atacante. Cure 4 da sua Cornucópia.
- **Novo ES:** Cuando ataquen a una Entidad tuya, destruye al atacante. Cura 4 a tu Cornucopia.

### `tao_tigre_branco_do_oeste` (Tigre Branco do Oeste)
- **Antigo PT:** Quando uma Entidade inimiga atacar: ela sofre 4 de dano e recebe −1 ATK permanente.
- **Antigo EN:** When an enemy Entity attacks: it takes 4 damage and gets permanent −1 ATK.
- **JSON:** `[{"gatilho":"enemy_attacks","acoes":[{"op":"damage","alvo":"attacker","n":4},{"op":"buff","alvo":"attacker","atk":-1,"vida":0,"perm":true}]}]`
- **Novo EN:** When one of your Entities is attacked, the attacker takes 4 damage and gets -1 ATK.
- **Novo PT:** Quando atacarem uma Entidade sua, o atacante sofre 4 de dano e recebe -1 ATK.
- **Novo ES:** Cuando ataquen a una Entidad tuya, el atacante recibe 4 de daño y -1 ATK.

### `hin_lei_do_karma` (Lei do Karma)
- **Antigo PT:** Quando uma Entidade inimiga atacar, ela sofre 3 de dano. Compre 1 carta.
- **Antigo EN:** When an enemy Entity attacks, it takes 3 damage. Draw 1 card.
- **JSON:** `[{"gatilho":"enemy_attacks","acoes":[{"op":"damage","alvo":"attacker","n":3},{"op":"draw","n":1}]}]`
- **Novo EN:** When one of your Entities is attacked, the attacker takes 3 damage. Draw 1 card.
- **Novo PT:** Quando atacarem uma Entidade sua, o atacante sofre 3 de dano. Compre 1 carta.
- **Novo ES:** Cuando ataquen a una Entidad tuya, el atacante recibe 3 de daño. Roba 1 carta.

### `hin_pashupatastra` (Pashupatastra)
- **Antigo PT:** Quando uma Entidade inimiga atacar, destrua-a. Compre 1 carta.
- **Antigo EN:** When an enemy Entity attacks, destroy it. Draw 1 card.
- **JSON:** `[{"gatilho":"enemy_attacks","acoes":[{"op":"destroy","alvo":"attacker"},{"op":"draw","n":1}]}]`
- **Novo EN:** When one of your Entities is attacked, destroy the attacker. Draw 1 card.
- **Novo PT:** Quando atacarem uma Entidade sua, destrua o atacante. Compre 1 carta.
- **Novo ES:** Cuando ataquen a una Entidad tuya, destruye al atacante. Roba 1 carta.

### `bru_circulo_de_sal` (Círculo de Sal)
- **Antigo PT:** Quando uma Entidade inimiga atacar, devolva-a à mão do dono; o oponente descarta 1 carta aleatória e você compra 1.
- **Antigo EN:** When an enemy Entity attacks, return it to its owner's hand; your opponent discards 1 random card and you draw 1.
- **JSON:** `[{"gatilho":"enemy_attacks","acoes":[{"op":"bounce","alvo":"attacker"},{"op":"discard","alvo":"enemy_hand_random","n":1},{"op":"draw","n":1}]}]`
- **Novo EN:** When one of your Entities is attacked, return the attacker to its owner's hand. Your opponent discards 1 random card. Draw 1 card.
- **Novo PT:** Quando atacarem uma Entidade sua, devolva o atacante para a mão do dono. O oponente descarta 1 carta aleatória. Compre 1 carta.
- **Novo ES:** Cuando ataquen a una Entidad tuya, devuelve el atacante a su mano. Tu oponente descarta 1 carta al azar. Roba 1 carta.

### `aby_circulo` (Círculo de Proteção)
- **Antigo PT:** Quando uma Entidade inimiga atacar, o atacante sofre 2 de dano. Enquanto virado para baixo, conta como "Círculo" para Sigilo 333.
- **Antigo EN:** When an enemy Entity attacks, the attacker takes 2 damage. While face down, counts as "Circle" for Sigil 333.
- **JSON:** `[{"gatilho":"enemy_attacks","acoes":[{"op":"damage","alvo":"attacker","n":2}]}]`
- **Novo EN:** When one of your Entities is attacked, the attacker takes 2 damage. While face down, counts as the Circle for Sigil 333.
- **Novo PT:** Quando atacarem uma Entidade sua, o atacante sofre 2 de dano. Virado para baixo, conta como o Círculo do Sigilo 333.
- **Novo ES:** Cuando ataquen a una Entidad tuya, el atacante recibe 2 de daño. Boca abajo, cuenta como el Círculo del Sigilo 333.

## F. "Quando o oponente invocar": só dispara com Entidade jogada da mão

`enemy_plays_entity` só é disparado em `_jogar_entidade` (carta jogada da mão). Tokens invocados por efeito, Entidades revividas para o campo e Choronzon pelo Sigilo 333 não disparam. Novo molde: "When your opponent plays an Entity" / "Quando o oponente jogar uma Entidade" / "Cuando tu oponente juegue una Entidad".

### `cri_portao_do_eden` (Portão do Éden)
- **Antigo PT:** Quando o oponente invocar uma Entidade, ela sofre 3 de dano e não ataca no próximo turno dela.
- **Antigo EN:** When your opponent summons an Entity, it takes 3 damage and can't attack on its next turn.
- **JSON:** `[{"gatilho":"enemy_plays_entity","acoes":[{"op":"damage","alvo":"triggering","n":3},{"op":"freeze","alvo":"triggering"}]}]`
- **Novo EN:** When your opponent plays an Entity, it takes 3 damage and is frozen.
- **Novo PT:** Quando o oponente jogar uma Entidade, ela sofre 3 de dano e fica congelada.
- **Novo ES:** Cuando tu oponente juegue una Entidad, esta recibe 3 de daño y queda congelada.

### `hin_chamas_de_agni` (Chamas de Agni)
- **Antigo PT:** Quando o oponente invocar uma Entidade, ela sofre 1 de dano e a Cornucópia inimiga sofre 1.
- **Antigo EN:** When your opponent summons an Entity, it takes 1 damage and the enemy Cornucopia takes 1.
- **JSON:** `[{"gatilho":"enemy_plays_entity","acoes":[{"op":"damage","alvo":"triggering","n":1},{"op":"damage","alvo":"enemy_cornucopia","n":1}]}]`
- **Novo EN:** When your opponent plays an Entity, it takes 1 damage and the enemy Cornucopia takes 1 damage.
- **Novo PT:** Quando o oponente jogar uma Entidade, ela sofre 1 de dano e a Cornucópia inimiga sofre 1.
- **Novo ES:** Cuando tu oponente juegue una Entidad, esta recibe 1 de daño y la Cornucopia enemiga también.

### `bru_mau_olhado` (Mau-Olhado)
- **Antigo PT:** Quando o oponente invocar uma Entidade, ela fica congelada e perde 1 ATK e 1 Vida permanentemente.
- **Antigo EN:** When your opponent summons an Entity, it is frozen and loses 1 ATK and 1 Health permanently.
- **JSON:** `[{"gatilho":"enemy_plays_entity","acoes":[{"op":"freeze","alvo":"triggering"},{"op":"buff","alvo":"triggering","atk":-1,"vida":-1,"perm":true}]}]`
- **Novo EN:** When your opponent plays an Entity, it is frozen and gets -1/-1.
- **Novo PT:** Quando o oponente jogar uma Entidade, ela fica congelada e recebe -1/-1.
- **Novo ES:** Cuando tu oponente juegue una Entidad, esta queda congelada y recibe -1/-1.

### `alt_selo_de_salomao` (Selo de Salomão)
- **Antigo PT:** Quando o oponente invocar uma Entidade, anule-a (ela vai ao cemitério) e compre 1 carta.
- **Antigo EN:** When your opponent summons an Entity, counter it (it goes to the graveyard) and draw 1 card.
- **JSON:** `[{"gatilho":"enemy_plays_entity","acoes":[{"op":"counter"},{"op":"draw","n":1}]}]`
- **Novo EN:** When your opponent plays an Entity, counter it (it goes to the graveyard). Draw 1 card.
- **Novo PT:** Quando o oponente jogar uma Entidade, anule-a (ela vai ao cemitério). Compre 1 carta.
- **Novo ES:** Cuando tu oponente juegue una Entidad, anúlala (va al cementerio). Roba 1 carta.

## G. "Qualquer Entidade": não conta a própria carta

`ally_dies`/`enemy_dies` disparam depois que a carta que morreu sai do campo, então a própria Babalon ou Morrígan não conta. Agora o texto diz "outra Entidade".

### `alt_babalon` (Babalon, a Mulher Escarlate)
- **Antigo PT:** Sacrifício 1. Sempre que qualquer Entidade morrer, Babalon ganha +1/+1 permanente.
- **Antigo EN:** Sacrifice 1. Whenever any Entity dies, Babalon gains permanent +1/+1.
- **JSON:** `[{"gatilho":"ally_dies","acoes":[{"op":"buff","alvo":"self","atk":1,"vida":1,"perm":true}]},{"gatilho":"enemy_dies","acoes":[{"op":"buff","alvo":"self","atk":1,"vida":1,"perm":true}]}]`
- **Novo EN:** Sacrifice 1. Whenever another Entity dies, this gains +1/+1.
- **Novo PT:** Sacrifício 1. Sempre que outra Entidade morrer, esta ganha +1/+1.
- **Novo ES:** Sacrificio 1. Cada vez que otra Entidad muera, esta gana +1/+1.

### `bru_a_morrigan` (A Morrigan)
- **Antigo PT:** Ímpeto. Sempre que uma Entidade — aliada ou inimiga — morrer, invoque um Corvo 1/1.
- **Antigo EN:** Rush. Whenever an Entity — allied or enemy — dies, summon a 1/1 Crow.
- **JSON:** `[{"gatilho":"ally_dies","acoes":[{"op":"summon","atk":1,"vida":1,"nome":"Corvo","n":1}]},{"gatilho":"enemy_dies","acoes":[{"op":"summon","atk":1,"vida":1,"nome":"Corvo","n":1}]}]`
- **Novo EN:** Rush. Whenever another Entity dies, summon a 1/1 Raven.
- **Novo PT:** Ímpeto. Sempre que outra Entidade morrer, invoque um Corvo 1/1.
- **Novo ES:** Ímpetu. Cada vez que otra Entidad muera, invoca un Cuervo 1/1.

## H. Caracteres que a fonte do texto (Fonte57) não tem: apareciam como "?"

A Fonte57 (texto da carta) não tem glifo para `*` nem para o sinal de menos `−` (U+2212). Gato Preto tinha `*(...)*`; Taiji e Tigre Branco usavam `−`. Agora tudo usa o hífen ASCII `-` ("-2/-2"), e o lembrete do Gato Preto vai sem asteriscos.

### `bru_gato_preto` (Gato Preto)
- **Antigo PT:** Furtivo. Renascer. *(Sete vidas: quando morre, volta à sua mão uma vez.)*
- **Antigo EN:** Stealth. Rebirth. *(Nine lives: when it dies, it returns to your hand once.)*
- **JSON:** `[]`
- **Novo EN:** Stealth. Rebirth. (Nine lives: when it dies, it returns to your hand once.)
- **Novo PT:** Furtivo. Renascer. (Sete vidas: quando morrer, volta para a sua mão uma vez.)
- **Novo ES:** Furtivo. Renacer. (Siete vidas: cuando muera, vuelve a tu mano una vez.)

### `tao_taiji` (Taiji)
- **Antigo PT:** Uma Entidade aliada ganha +2/+2 permanente e uma Entidade inimiga recebe −2/−2 permanente.
- **Antigo EN:** An allied Entity gains permanent +2/+2 and an enemy Entity gets permanent −2/−2.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"buff","alvo":"ally_entity","atk":2,"vida":2,"perm":true},{"op":"buff","alvo":"enemy_entity","atk":-2,"vida":-2,"perm":true}]}]`
- **Novo EN:** An allied Entity gains +2/+2 and an enemy Entity gets -2/-2.
- **Novo PT:** Uma Entidade aliada ganha +2/+2 e uma Entidade inimiga recebe -2/-2.
- **Novo ES:** Una Entidad aliada gana +2/+2 y una Entidad enemiga recibe -2/-2.

### `tao_tigre_branco_do_oeste` (Tigre Branco do Oeste)
- **Antigo PT:** Quando uma Entidade inimiga atacar: ela sofre 4 de dano e recebe −1 ATK permanente.
- **Antigo EN:** When an enemy Entity attacks: it takes 4 damage and gets permanent −1 ATK.
- **JSON:** `[{"gatilho":"enemy_attacks","acoes":[{"op":"damage","alvo":"attacker","n":4},{"op":"buff","alvo":"attacker","atk":-1,"vida":0,"perm":true}]}]`
- **Novo EN:** When one of your Entities is attacked, the attacker takes 4 damage and gets -1 ATK.
- **Novo PT:** Quando atacarem uma Entidade sua, o atacante sofre 4 de dano e recebe -1 ATK.
- **Novo ES:** Cuando ataquen a una Entidad tuya, el atacante recibe 4 de daño y -1 ATK.

## I. Nome do token no texto diferente do nome do token

Com o jogo em inglês, o token entra com `tokens.json["en"]`. Os textos citavam outro nome: Peccary × White-lipped Peccary, Water Lily × Giant Water Lily, Aruanãs × Arowana, Crow × Raven. Em PT, Erlang Shen dizia "Xiaotian Quan, o Cão Celestial", e a chave é "Xiaotian Quan, Cão Celestial". Ficou decidido (seção `tokens` de cartas.json): **Peccary**, **Water Lily**, **Arowana**, **Raven**, **Xiaotian Quan, Celestial Hound**. Ao integrar, atualize o campo `en` de tokens.json para Peccary e Water Lily.

### `ind_caipora` (Caipora)
- **Antigo PT:** Despertar: invoca um Queixada 1/2.
- **Antigo EN:** Awaken: Summon a 1/2 Peccary.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"summon","atk":1,"vida":2,"nome":"Queixada","n":1}]}]`
- **Novo EN:** Awaken: Summon a 1/2 Peccary.
- **Novo PT:** Despertar: Invoque um Queixada 1/2.
- **Novo ES:** Despertar: Invoca un Pecarí 1/2.

### `ind_jaci` (Jaci, a Lua)
- **Antigo PT:** Lendária. Despertar: invoca uma Vitória-régia 0/2 com Guarda. No fim do seu turno, cura 2 em todas as Entidades aliadas.
- **Antigo EN:** Legendary. Awaken: Summon a 0/2 Water Lily with Guard. At the end of your turn, heal all allied Entities for 2.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"summon","atk":0,"vida":2,"nome":"Vitória-régia","keywords":["guarda"],"n":1}]},{"gatilho":"end_turn","acoes":[{"op":"heal","alvo":"all_ally_entities","n":2}]}]`
- **Novo EN:** Awaken: Summon a 0/2 Water Lily with Guard. At the end of your turn, heal all your Entities for 2.
- **Novo PT:** Despertar: Invoque uma Vitória-régia 0/2 com Guarda. No fim do seu turno, cure 2 de Vida de todas as suas Entidades.
- **Novo ES:** Despertar: Invoca una Victoria Regia 0/2 con Guardia. Al final de tu turno, cura 2 de Vida a todas tus Entidades.

### `ind_danca_do_aruana` (Dança do Aruanã)
- **Antigo PT:** Invoca dois Aruanãs 1/1. Sua Cornucópia cura 2.
- **Antigo EN:** Summon two 1/1 Aruanãs. Your Cornucopia heals 2.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"summon","atk":1,"vida":1,"nome":"Aruanã","n":2},{"op":"heal","alvo":"ally_cornucopia","n":2}]}]`
- **Novo EN:** Summon two 1/1 Arowanas. Heal your Cornucopia for 2.
- **Novo PT:** Invoque dois Aruanãs 1/1. Cure 2 da sua Cornucópia.
- **Novo ES:** Invoca dos Arahuanas 1/1. Cura 2 a tu Cornucopia.

### `bru_a_morrigan` (A Morrigan)
- **Antigo PT:** Ímpeto. Sempre que uma Entidade — aliada ou inimiga — morrer, invoque um Corvo 1/1.
- **Antigo EN:** Rush. Whenever an Entity — allied or enemy — dies, summon a 1/1 Crow.
- **JSON:** `[{"gatilho":"ally_dies","acoes":[{"op":"summon","atk":1,"vida":1,"nome":"Corvo","n":1}]},{"gatilho":"enemy_dies","acoes":[{"op":"summon","atk":1,"vida":1,"nome":"Corvo","n":1}]}]`
- **Novo EN:** Rush. Whenever another Entity dies, summon a 1/1 Raven.
- **Novo PT:** Ímpeto. Sempre que outra Entidade morrer, invoque um Corvo 1/1.
- **Novo ES:** Ímpetu. Cada vez que otra Entidad muera, invoca un Cuervo 1/1.

### `tao_erlang_shen` (Erlang Shen)
- **Antigo PT:** Despertar: invoque Xiaotian Quan, o Cão Celestial (2/1), se houver slot livre.
- **Antigo EN:** Awaken: Summon Xiaotian Quan, the Celestial Hound (2/1), if there's a free slot.
- **JSON:** `[{"gatilho":"on_play","acoes":[{"op":"summon","atk":2,"vida":1,"nome":"Xiaotian Quan, Cão Celestial","n":1}]}]`
- **Novo EN:** Awaken: Summon a 2/1 Xiaotian Quan, Celestial Hound.
- **Novo PT:** Despertar: Invoque Xiaotian Quan, Cão Celestial 2/1.
- **Novo ES:** Despertar: Invoca a Xiaotian Quan, Perro Celestial 2/1.

## J. Mudanças de padronização (o texto antigo não estava errado)

- **"Lendária." saiu do texto de regra** de Jaci, Tupã, Elias e São Miguel. Só 4 das 15 Lendárias traziam a palavra; a moldura dourada já marca a carta e isso não é habilidade.
- **"Aura:" saiu** de Lü Dongbin e do Imperador de Jade (não é palavra-chave do glossário). Efeito estático de Entidade ou Relíquia usa o molde "Suas (outras) Entidades têm …".
- **"Permanente" saiu dos buffs.** Todo `buff` de efeito é permanente (`perm: true`); os temporários do motor só vêm de auras. Molde: "ganha +1/+1" (permanente) × "têm +1 ATK" (aura). Perda de atributo: "recebe -1/-1".
- **"À escolha" saiu** das cartas interativas (Benandante, Circe, Medeia, Baba Yaga, Malefício, Poção de Beladona). "Uma Entidade inimiga" já indica alvo escolhido no Despertar e no Rito.
- **Saíram de Solve et Coagula "no turno do oponente", de Seiðr "Embaralhe." e de Erlang Shen e Conjuração "(se houver slot livre)".** É regra geral: todo Selo só dispara no turno do oponente, toda busca embaralha e toda invocação precisa de slot.
- **Enfeites que saíram do texto de regra:** "fogo do céu —" (Elias), "devore" (Baba Yaga), "vira porco" (Circe), "(coruja familiar)" (Strega). Circe só redefine ATK/Vida (`set_stats`) e mantém palavras-chave e efeitos, então "porco" sugeria que ela perdia tudo.
- Relíquias: "Equipe uma Entidade aliada: +1/+2" e "Portadora: +2 ATK" viraram o molde único "A portadora ganha …". Cura em Entidade: "Cure N de Vida de …"; cura na Cornucópia: "Cure N da sua Cornucópia"; Fé temporária: "Ganhe N de Fé neste turno".

## K. Comportamentos do motor que não estão no texto (para avaliar; texto não mudou por falta de espaço ou por ser regra geral)

- **Sigilo 333:** com o campo cheio, o motor **destrói a Entidade do 1º slot** (sem Renascer) para dar lugar a Choronzon.
- **Reviver para o campo** (Kuarup, Talita Cumi, Tumba Vazia etc.) **não dispara Despertar** nem os Selos de "jogar Entidade".
- **Furtivo protege dos Selos de entrada:** contra uma Entidade com Furtivo, Portão do Éden, Mau-Olhado e Chamas de Agni não causam dano nem congelam (`triggering` protegido), e mesmo assim o Selo vai ao cemitério (em Chamas, o dano na Cornucópia acontece).
- **Ataque de Ímpeto congelado na entrada:** Mau-Olhado ou Portão do Éden congelam, mas uma Entidade com Ímpeto ainda ataca no turno em que entra (o congelamento vale para o próximo turno dela).
- **Escolha automática** (seção A) também vale para alvos de Selos (Véu de Maya, Tumba Vazia, Pássaro Vermelho etc.) e para o fim de turno de He Xiangu. Se a ideia é o jogador escolher, a mudança é no motor (passar `interativo`), não no texto.

## Nomes PT alterados

- `alt_vassago`: **Vassago, o Príncipe que Acha → Vassago, o Príncipe que Encontra.** Em português, "o Príncipe que Acha" se lê primeiro como "que opina" e soa cômico; "Encontra" mantém o sentido da Goétia (o que encontra coisas perdidas e ocultas) e bate com o EN "the Prince Who Finds".

Nenhum outro nome PT mudou. Os nomes EN também ficaram iguais aos de `cartas_en.json`.

## Textos PT/ES acima de +10% do PT antigo (passaram 1 ou 2 caracteres, menos em Abrahadabra)

- `cri_sangue_nos_umbrais`: PT antigo 72 car.; novo PT 79, ES 80.
- `hin_pashupatastra`: PT antigo 62 car.; novo PT 69, ES 70.
- `hin_vajra`: PT antigo 70 car.; novo PT 77, ES 78.
- `alt_abrahadabra`: PT antigo 37 car.; novo PT 37, ES 42.
