# KodeX: guia de estilo dos textos (EN base → PT-BR e ES)

Regra-mãe: **o texto nasce em inglês** e depois é **adaptado** (não traduzido palavra por palavra) para português do Brasil e
espanhol. Quem lê em PT ou ES tem que sentir que o texto foi escrito na língua dele. Brasileiro percebe tradução literal na
hora e critica, então nada de "calque" (ex.: "Você tem certeza?" para *Are you sure?* serve, mas "Realize o descarte"
não; "Bem jogado." soa traduzido, "Boa jogada." soa nativo).

## Tom por contexto
| Contexto | Tom | Exemplo de alvo |
|---|---|---|
| Texto de regra da carta | seco, preciso, sempre o mesmo molde; zero enfeite | "Awaken: Deal 2 damage to an enemy Entity." |
| Nome de carta | nome próprio do mito; epíteto curto e evocativo | "Matsya, the Fish" / "Matsya, o Peixe" / "Matsya, el Pez" |
| Fala de chefe/personagem | voz da personagem: bruta quando ameaça, drástica no clímax, sutil e meiga quando consola | ver lore.json |
| Codex (lore das cartas) | enciclopédico mas vivo: frase curta, verbo forte, imagem concreta; **fatos e fontes intactos** | — |
| Interface (botões, avisos) | curto, direto, ativo; botão = verbo ou substantivo, 1–2 palavras | "Play", "Jogar", "Jugar" |
| Avisos de erro / suspensão | calmo, claro, sem culpar o jogador, diz o que fazer | — |
| Dicas de carregamento | uma ideia por dica, voz de mentor experiente, às vezes com um pingo de humor | — |
| Missões/conquistas | imperativo curto + número | "Win 3 matches" |
| Privacidade / legal | preciso e simples; **nunca** dramatizar nem mudar o sentido | — |
| Novidades (patch notes) | informativo, frase curta, começa pelo que mudou para o jogador | — |

Drástico quando precisa (vitória, derrota, chefe final, Choronzon), bruto quando a personagem é bruta, delicado quando a cena
pede (derrota do jogador, presente, mensagem de consolo). Variar o ritmo: frase curta depois de frase longa.

## Português do Brasil
- "Você"; nada de "tu" conjugado de Portugal. Interface usa "para"; falas de personagem podem usar "pra", "tá", "né" se combinar.
- **Acentos e Ç sempre** (a fonte do jogo tem todos os glifos). Nunca tirar acento para caber: encurtar a frase.
- Evitar gerúndio de telemarketing ("vou estar enviando"), voz passiva pesada, "o mesmo" como pronome, "realizar".
- Termos de jogo de cartas que o brasileiro usa: comprar carta, descartar, embaralhar, deck, mão, cemitério, invocar.

## Espanhol
- Espanhol **neutro latino-americano**: "tú" (nunca "vos"/"vosotros"), "ustedes" no plural, sem gíria regional forte.
- Acentos, **ñ, ¿ ?, ¡ !** obrigatórios.
- Vocabulário de TCG em espanhol: **robar** (comprar carta), **mazo** (deck), **mano**, **cementerio**, **descartar**, **barajar**,
  **invocar**, **sobre** (booster), **turno**.
- Espanhol costuma ser ~15–25% mais longo que inglês: onde há limite de espaço, reescrever mais curto em vez de cortar sentido.

## Limites de espaço
- Texto de regra da carta: no máximo o comprimento do texto PT atual + 10% (a caixa da carta é fixa).
- Botões e rótulos em MAIÚSCULAS da mesa: no máximo o comprimento do original + 2 letras.
- Strings com `%d`, `%s`, `%02d` etc.: manter **os mesmos marcadores na mesma ordem** (ou reordenar só se a frase exigir e
  o código usar `%s` posicional — na dúvida, manter a ordem).

## Glossário fixo (não variar)
| EN | PT-BR | ES |
|---|---|---|
| Faith | Fé | Fe |
| Cornucopia (vida do jogador) | Cornucópia | Cornucopia |
| Entity / Entities | Entidade / Entidades | Entidad / Entidades |
| Seal | Selo | Sello |
| Trap (Selo sem palavra-chave, rótulo da moldura) | Armadilha | Trampa |
| Rite | Rito | Rito |
| Relic | Relíquia | Reliquia |
| Legendary | Lendária | Legendaria |
| Last Breath | Último Sopro | Último Aliento |
| Awaken | Despertar | Despertar |
| Rebirth | Renascer | Renacer |
| Guard | Guarda | Guardia |
| Stealth | Furtivo | Furtivo |
| Rush | Ímpeto | Ímpetu |
| Sacrifice N | Sacrifício N | Sacrificio N |
| Graveyard | cemitério | cementerio |
| deck | deck | mazo |
| hand | mão | mano |
| draw a card | comprar uma carta | robar una carta |
| discard | descartar | descartar |
| shuffle | embaralhar | barajar |
| summon | invocar | invocar |
| destroy | destruir | destruir |
| return to hand | devolver para a mão | devolver a la mano |
| freeze / frozen | congelar / congelada | congelar / congelada |
| silence | silenciar | silenciar |
| take control | dominar | dominar |
| direct hit (ataque à Cornucópia) | golpe direto | golpe directo |
| Essence | Essência | Esencia |
| Koins | Koins | Koins |
| coins | moedas | monedas |
| booster | booster | sobre |
| Tradition (deck temático) | Tradição | Tradición |
| Indigenous / Christianity / Taoism / Hinduism / Witchcraft / High Magic / the Abyss | Indígena / Cristianismo / Taoísmo / Hinduísmo / Bruxaria / Alta Magia / Abismo | Indígena / Cristianismo / Taoísmo / Hinduismo / Brujería / Alta Magia / Abismo |
| the Codex (o livro do mundo) | o Códice | el Códice |
| KodeX (nome do jogo) | KodeX | KodeX |
| Arcade / Pilgrimage / Tournament / Enigma / Daily | Arcade / Peregrinação / Torneio / Enigma / Diário | Arcade / Peregrinación / Torneo / Enigma / Diario |

Entidade, Selo, Rito, Relíquia, nomes de palavras-chave e Fé/Cornucópia são **termos de jogo**: sempre com maiúscula inicial no
texto de regra, nos três idiomas.

## Moldes do texto de regra (EN → PT → ES)
- `Awaken: X.` → `Despertar: X.` → `Despertar: X.`
- `Last Breath: X.` → `Último Sopro: X.` → `Último Aliento: X.`
- `Deal N damage to an enemy Entity.` → `Cause N de dano a uma Entidade inimiga.` → `Inflige N de daño a una Entidad enemiga.`
- `Draw N cards.` → `Compre N cartas.` → `Roba N cartas.`
- `Search your deck for a Relic and put it into your hand.` → `Busque uma Relíquia do seu deck para a mão.` → `Busca una Reliquia en tu mazo y ponla en tu mano.`
- `Summon a 1/2 Peccary.` → `Invoque um Queixada 1/2.` → `Invoca un Pecarí 1/2.`
- `Whenever this takes damage, …` → `Sempre que esta sofrer dano, …` → `Cada vez que esta reciba daño, …`
- `This turn` / `neste turno` / `este turno`; `your next turn` / `seu próximo turno` / `tu próximo turno`.
- Imperativo na 2ª pessoa (você/tú) em PT e ES; palavra-chave isolada no começo termina em ponto: `Guard.` / `Guarda.` / `Guardia.`

O texto tem que bater **exatamente** com o efeito programado (JSON `efeitos` da ficha da carta). Na dúvida, o JSON manda.
