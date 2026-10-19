# Gods Kodex — geração e revisão das artes das cartas (handoff para o Antigravity)

Você vai **gerar e revisar no ComfyUI local** as ilustrações das 161 cartas do jogo de cartas *Gods Kodex*
(6 decks mitológicos de 32 cartas + o Conjunto do Abismo de 4). Este arquivo tem tudo: regras de estilo,
Total de cartas neste arquivo: **161**.
configuração do ComfyUI, o fluxo de pesquisa → geração → checagem → regeneração, e a ficha + o prompt de cada carta.

Projeto: `/mnt/d/Projetos de Jogos/GodsKodex/` (Linux; `D:\Projetos de Jogos\GodsKodex` no Windows).
As fichas completas das cartas estão em `cartas/<deck>/NN_<slug>.md` (seções *Contexto mitológico* e *Prompt de arte*).

## 1. Regras de estilo (inegociáveis)

1. **Pixel art** (estilo aprovado), 16-bit, paleta limitada, contorno de pixel nítido. Nada de render 3D, nada de pintura lisa.
2. **SEM CHIBI.** Proporções adultas e realistas: cabeça ≈ 1/7 da altura do corpo em figuras humanas adultas, olhos de tamanho
   normal, mãos e pés proporcionais. Rejeite na hora qualquer imagem com cabeça grande, corpo atarracado, olhos enormes,
   aparência de bebê/criança fofa ou estética *kawaii*. Seres que na tradição SÃO crianças (Saci, Curupira, Nezha) devem ter
   proporção de criança real de 10–12 anos (cabeça ≈ 1/6 da altura), nunca bonequinho.
3. **Fidelidade à tradição:** cada figura precisa dos atributos que a identificam (ex.: Saci = uma perna só, gorro vermelho,
   cachimbo; Curupira = pés virados para trás; Ganesha = cabeça de elefante com uma presa quebrada; serafim = seis asas).
   Se o atributo-chave não aparece, a imagem está reprovada, por mais bonita que seja.
4. **Respeito:** hinduísmo, cristianismo e as culturas indígenas são religiões/culturas vivas. Nada de caricatura, sexualização
   ou gore. Deus e Cristo **não aparecem em figura** (decisão do autor) — milagres dele são mostrados pelo efeito (luz, túmulo vazio).
   Povos indígenas: adornos corretos para o povo citado na ficha (pintura de jenipapo/urucum, cocar, maracá, borduna),
   sem estereótipo de faroeste e sem pele tingida de vermelho/azul como se fosse cor da pele.
5. **Só a ilustração:** sem moldura, sem texto, sem letras/runas legíveis, sem número, sem borda. O frame da carta é aplicado depois.
6. **Formato:** 768×1024 px (3:4, em pé). A arte inteira aparece na carta (janela 3:4), então o assunto deve caber com margem;
   deixe ~8% livres no topo e ~10% embaixo (a pílula do nome e a do efeito cobrem um pouco essas faixas).
7. **Uma figura principal** com silhueta clara sobre fundo escuro com um ponto de luz. O modelo erra muito com multidões,
   geometria exata (pentagramas, círculos com letras) e cenas com 3+ elementos importantes — simplifique quando falhar.

## 2. ComfyUI

- Servidor local: `http://127.0.0.1:8188`. Se não responder, iniciar com `/mnt/d/Comfy-Desktop/run_backend.sh` (log em `/mnt/d/Comfy-Desktop/logs/comfyui.log`).
- GPU: RTX 5070 Laptop 8 GB. Uma imagem leva ~15 s.
- Checkpoint: `Illustrious/pixelPerfect_v20.safetensors` (Illustrious, responde a tags separadas por vírgula, não a frases longas).
- KSampler: `steps 28`, `cfg 6.0`, `sampler euler_ancestral`, `scheduler normal`, `denoise 1.0`, latente 768×1024.
- Seed: livre; registre a seed usada de cada arte aprovada no log (ver §5).
- Script pronto que monta o workflow pela API: `arte/gerar_artes.py` (lê o bloco ```prompt de cada ficha e salva em
  `arte/<deck>/<id>.png`; `--cultura`, `--id`, `--force`, `--seed-offset`, `--dry`). Pode usar ele ou montar o seu workflow.
- Modelos extras disponíveis: `4x-UltraSharp.pth` (upscale — NÃO usar na arte final, quebra o pixel), `Juggernaut_XL`,
  `Animagine_XL_3.1` e `z_image_turbo` (não usar: estilo aprovado é o pixelPerfect).

**Prefixo fixo** (vai antes do prompt de cada carta):
```
pixel art, masterpiece, best quality, detailed pixel art, 16-bit, limited palette, mature, adult proportions, realistic body proportions, tall figure, small head, vertical composition, dark background
```
Em cartas com `no humans` (criaturas, objetos, cenas) **remova** do prefixo as tags `mature, adult proportions, realistic body
proportions, tall figure, small head` — elas só servem para figuras humanoides.

**Negativo fixo:**
```
chibi, super deformed, big head, oversized head, huge eyes, childlike proportions, toddler, cute, kawaii, loli, shota, lowres, blurry, text, watermark, signature, jpeg artifacts, worst quality, bad anatomy, smooth shading, 3d render, frame, border, card, letters, multiple views
```

## 3. Pesquisa e mapeamento de referências (ANTES de gerar)

Para cada carta, monte uma pequena ficha visual — é ela que garante a fidelidade, mesmo em pixel art:

1. **Leia a ficha** (`cartas/<deck>/NN_<slug>.md`): *Contexto mitológico* (fonte primária, povo/região, variantes) e o prompt atual.
2. **Busque imagens de referência** da figura na tradição — priorize fontes iconográficas confiáveis: Wikimedia Commons,
   acervos de museus (British Museum, Met, Museu Nacional, Museu do Índio, Museu Goeldi, National Palace Museum, LACMA),
   ícones e iluminuras para o cristianismo, pinturas de templo e miniaturas para o hinduísmo, xilogravuras e pinturas de
   ano novo (nianhua) para o taoismo, gravuras de grimórios (Collin de Plancy, Lemegeton) para a alta magia, gravuras
   históricas e folclore ilustrado (Bilibin para Baba Yaga) para a bruxaria. Evite fan art e outras IAs como referência.
3. **Extraia uma checklist de 3–6 atributos obrigatórios** visíveis (forma do corpo, objeto que segura, roupa/adorno, cor
   tradicional, animal/montaria, cenário típico) + **o que NÃO pode aparecer** (anacronismos, atributos de outra figura,
   elementos de outra cultura). Ex.: *Mapinguari* → olho único na testa, boca no ventre, pelagem desgrenhada, garras longas;
   NÃO: gorila genérico com dois olhos.
4. **Traduza a checklist em tags** e acrescente/corrija no prompt (mantendo 25–45 tags, inglês, na ordem: sujeito → atributos
   → pose → cenário → luz/cor → enquadramento). Descreva atributos em vez de nomes próprios (o modelo não conhece
   "Curupira"; conhece "feet turned backwards").
5. Salve a checklist e os links das referências em `arte/<deck>/_referencias/<id>.md` (crie a pasta). Opcional: guarde 1–3
   imagens de referência ali (só para consulta; não use como entrada img2img de obra protegida).

## 4. Geração, checagem e regeneração

Para cada carta (todas as 161 — inclusive as marcadas como aprovadas abaixo, que foram revisadas ANTES da regra "sem chibi"):

1. Gere **3 candidatas** com seeds diferentes a partir do prompt corrigido.
2. **Cheque cada candidata visualmente** contra: (a) a checklist do §3, (b) as regras do §1 (sem chibi, sem texto, proporção,
   respeito), (c) a pose combinando com a mecânica da carta (abaixo), (d) qualidade (sem membros extras, rosto derretido,
   figura cortada nas bordas).
3. Escolha a melhor que passe em **tudo**. Se nenhuma passar: ajuste o prompt mirando no que falhou (reforce o atributo
   ausente com 2–3 tags redundantes, tire tags que puxam para o erro, simplifique o cenário) e gere mais 3. Limite: **4 rodadas**
   (12 imagens) por carta; se ainda falhar, marque `PENDENTE` no log com o motivo e siga para a próxima.
4. Salve a escolhida em `arte/<deck>/<id>.png` (substitui a atual; a anterior vai para `arte/<deck>/_v1/` se ainda não estiver lá).
   As outras candidatas podem ficar em `arte/<deck>/_candidatas/`.
5. **Atualize o bloco ```prompt da ficha** (`cartas/<deck>/NN_<slug>.md`, seção *Prompt de arte*) com o prompt que gerou a
   arte aprovada. Não altere nenhuma outra seção da ficha.

**Pose × mecânica:** Entidade com Guarda → postura defensiva, de frente; dano/ataque → gesto de golpe ou disparo;
Relíquia → o objeto em destaque (`object focus, no humans`); Selo → cena de armadilha/proteção escondida, tom escuro;
Rito → o ritual/evento em curso com um ponto focal. Lendárias podem ter mais imponência (enquadramento de baixo para cima).

## 5. Entregáveis

- `arte/<deck>/<id>.png` — 161 artes 768×1024 aprovadas.
- `arte/<deck>/_referencias/<id>.md` — checklist + links.
- `arte/LOG_ANTIGRAVITY.md` — tabela: `id | rodadas | seed final | veredito (APROVADA/PENDENTE) | o que mudou no prompt`.
- Fichas `cartas/**/NN_*.md` com o bloco ```prompt atualizado.

Material de apoio já existente: `arte/<deck>/_v1/` (1ª geração reprovada), `arte/<deck>/_candidatas/<id>_a|b.png`
(2ª tentativa parcial, não revisada), `arte/<deck>/_revisao_artes.md` (revisão anterior com os motivos).

## 6. Cartas

Status = resultado da revisão anterior (antes da regra "sem chibi" — reavalie todas). O prompt listado é o atual da ficha
(já corrigido nas reprovadas). Contexto resumido; o completo está na ficha.

### Indígena brasileira — 25 cartas

#### Saci-Pererê  (`ind_saci_perere`)
- Ficha: `cartas/indigena/01_saci_perere.md` · Entidade · 1/1
- Destino: `arte/indigena/ind_saci_perere.png`
- Texto da carta: Furtivo. Despertar: uma Entidade inimiga não ataca no próximo turno dela.
- Contexto: O Saci é o mais popular dos seres do folclore brasileiro e um dos de origem mais discutida. O registro mais antigo, no Norte, é o de um pássaro — a *matintaperera*, cujo assobio anuncia azar — e o nome vem do tupi *çaa cy perereg*, "olho furado que pula". Câmara Cascudo (*Dicionário do Folclore Brasileiro*) mostra a figura descendo rumo ao Sul e ganhando, pelo caminho, a perna única, a carapuça vermelha e o cachimbo, elementos que o inquérito de Monteiro Lobato (*O Saci-Pererê: resultado de um inquérito*, 1918) já encontrava consolidados em São Paulo. […]
- Revisão anterior: **REPROVADA** — Tem duas pernas (uma dobrada, outra apoiada): falta o atributo-chave, a perna única. Não há redemoinho, só espirais pequenas. Roupa de mago (manto vermelho)
- Prompt atual:
```prompt
1boy, solo, small dark-skinned boy, one-legged, only one leg, single leg standing, red pointed cap, clay pipe in mouth, shirtless, short shorts, mischievous grin, hopping, inside a spinning dust whirlwind, tornado of dry leaves around him, night rainforest clearing, dirt path, moonlight, green and orange, glowing pipe ember, rim lighting, fireflies, deep shadows, full body, centered, clean silhouette, readable shape
```

#### Curupira  (`ind_curupira`)
- Ficha: `cartas/indigena/02_curupira.md` · Entidade · 1/2
- Destino: `arte/indigena/ind_curupira.png`
- Texto da carta: Guarda. Sempre que sofrer dano, causa 1 de dano ao atacante.
- Contexto: O Curupira é o ser do folclore brasileiro com o registro escrito mais antigo: José de Anchieta, na carta de São Vicente de 1560, descreve os *curupiras* que "acometem os índios no mato" e para os quais se deixam penas e flechas nos caminhos. Gabriel Soares de Sousa (*Tratado Descritivo do Brasil*, 1587) repete o relato. Cascudo (*Dicionário do Folclore Brasileiro*) o acompanha de norte a sul: anão de cabelos vermelhos, dentes verdes ou azuis, e sobretudo os **pés virados para trás**, que fazem o rastro apontar para onde ele não está. É o guardião da floresta e da caça. […]
- Revisão anterior: **REPROVADA** — Pés minúsculos e voltados para a frente: falta o atributo-chave, os pés virados para trás. Está de calça. Pose de guarda e cabelo de fogo OK
- Prompt atual:
```prompt
1boy, solo, small forest guardian, flame-red spiky hair, dark skin, black body paint stripes, loincloth, bare legs, feet turned backwards, heels pointing forward, toes pointing behind, visible backward feet, wide defensive stance, arms spread blocking the path, fierce glowing eyes, giant tree roots, dense amazon rainforest, night, green and orange, rim lighting, fireflies, deep shadows, full body, centered, clean silhouette, readable shape
```

#### Caipora  (`ind_caipora`)
- Ficha: `cartas/indigena/03_caipora.md` · Entidade · 2/2
- Destino: `arte/indigena/ind_caipora.png`
- Texto da carta: Despertar: invoca um Queixada 1/2.
- Contexto: *Caa-pora*, "habitante do mato" em tupi. Cascudo (*Dicionário do Folclore Brasileiro*) registra a Caipora (ou Caapora) como senhora dos animais da floresta: ora uma mulher peluda, ora um menino, quase sempre **montada num porco-do-mato** — o queixada ou o caititu — e cercada pela vara inteira. Cobra fumo dos caçadores; quem lhe deixa um rolo de tabaco num toco caça bem, quem não deixa volta de mãos vazias ou com febre. Couto de Magalhães (*O Selvagem*, 1876) e, mais tarde, a tradição amazônica fundiram a Caipora com o Curupira; no Nordeste e no Sudeste ela permanece figura própria, mais ligada aos bichos do que às árvores. […]
- Revisão anterior: **REPROVADA** — Não há a mulher, só o porco-do-mato: a figura principal está ausente
- Prompt atual:
```prompt
1girl, solo, feral forest woman, dark skin, long wild black hair, red body paint, seed necklace, riding on the back of a large wild peccary, sitting astride the boar, holding tobacco roll, charging forward, boar with tusks, jungle trail, night, moonlight, green and orange, rim lighting, dust kicked up, mist, deep shadows, full body, woman clearly visible, clean silhouette, readable shape, high contrast, dramatic lighting
```

#### Iara  (`ind_iara`)
- Ficha: `cartas/indigena/04_iara.md` · Entidade · 2/3
- Destino: `arte/indigena/ind_iara.png`
- Texto da carta: Despertar: devolve uma Entidade inimiga à mão do dono.
- Contexto: A Iara (Uiara, Mãe-d'água) é a sereia dos rios amazônicos: mulher de cabelos longos e cauda de peixe que canta nas tardes e atrai pescadores para o fundo, de onde não voltam — ou voltam "encantados", sem juízo. A forma atual é do século XIX; antes dela, Fernão Cardim (c. 1584) e Gabriel Soares de Sousa (1587) descreviam o **Ipupiara**, "morador do fundo", monstro masculino que abraçava e esmagava os banhistas. Barbosa Rodrigues (*Poranduba Amazonense*, 1890) e Cascudo (*Geografia dos Mitos Brasileiros*) acompanham a transformação do monstro em sereia sob influência romântica. […]
- Revisão anterior: **APROVADA** — Sereia de pele escura, cabelo longo, cauda verde, mão chamando. Sutiã de conchas, sem nudez
- Prompt atual:
```prompt
1girl, solo, river mermaid, mature indigenous woman, dark skin, very long black hair, fish tail with green scales, shell and seed necklace, half submerged, singing, hand outstretched beckoning toward viewer, hypnotic gaze, calm amazon river at dusk, giant water lily pads, flooded forest trees, ripples, reflections on water, jungle, teal and orange, moonlight on water, green and orange, soft glow, mist over water, fireflies, deep shadows, full body
```

#### Boitatá  (`ind_boitata`)
- Ficha: `cartas/indigena/05_boitata.md` · Entidade · 3/4
- Destino: `arte/indigena/ind_boitata.png`
- Texto da carta: Guarda. Sempre que sofrer dano de um ataque, causa 1 de dano ao atacante.
- Contexto: *Mboi-tatá*, "cobra de fogo" em tupi. É um dos seres mais antigos do folclore brasileiro: Anchieta, na carta de 1560, já fala do *Baetatá*, "coisa de fogo", que corre pelos campos à noite e persegue os indígenas. Cascudo (*Geografia dos Mitos Brasileiros*, 1947) reúne as variantes: serpente de fogo que vive nos rios e campos, de olhos enormes e luminosos; no Rio Grande do Sul, *Baitatá*; no sertão, confundida com o fogo-fátuo dos pântanos. A versão gaúcha, fixada por João Simões Lopes Neto em *Lendas do Sul* (1913), conta que, num dilúvio de trevas, uma cobra sobreviveu num buraco comendo os olhos dos animais mortos, até ficar cheia de luz e transparente. […]
- Revisão anterior: **APROVADA** — Serpente de fogo empinada de frente, à beira do rio, à noite. Lê como Guarda
- Prompt atual:
```prompt
no humans, giant fire serpent, serpent made of orange and blue flames, huge glowing yellow eyes, mouth open, glowing fire inside mouth, rearing up protectively, facing viewer, coiled in dark brazilian rainforest at night, river, giant ferns, stars, dark blue trees, rocks on the riverbank, fireflies, embers, firelight, green and orange, reflections on water, dramatic rim lighting, deep shadows, high contrast, scales glowing with inner fire, smoke, night sky, full body
```

#### Anhangá  (`ind_anhanga`)
- Ficha: `cartas/indigena/06_anhanga.md` · Entidade · 3/3
- Destino: `arte/indigena/ind_anhanga.png`
- Texto da carta: Sempre que outra Entidade aliada morrer, invoca um Veado Branco 1/2.
- Contexto: Para os Tupinambá do século XVI, *Anhanga* era o espírito errante dos mortos, o terror das noites: Anchieta (1560) e Cardim (c. 1584) o descrevem como o ser que "anda pelo mato" e de quem todos têm medo; os jesuítas o traduziram como "diabo", o que distorceu a figura. Métraux (*A religião dos Tupinambás*, 1928) a devolve ao lugar: um espectro ligado aos mortos e à floresta, não um princípio do mal. No folclore amazônico posterior, recolhido por Couto de Magalhães (*O Selvagem*, 1876) e Cascudo (*Dicionário do Folclore Brasileiro*), o Anhangá é o **protetor dos animais de caça**, que aparece como um **veado branco de olhos de fogo**. […]
- Revisão anterior: **APROVADA** — Cervo branco espectral com olhos de fogo e névoa. A caveira com costelas aparentes é sombria, mas não é gore
- Prompt atual:
```prompt
no humans, spectral white stag, glowing white fur, large antlers, eyes of fire, ghostly aura, translucent body, wisps of white mist rising from the ground, standing still facing viewer, protective, dark amazon forest at night, dead tree, fallen leaves, animal bones on the ground, giant ferns, moonlight, green and orange, orange glowing eyes, pale blue glow, rim lighting, fireflies, fog, deep shadows, mist on the ground, night sky, ethereal, full body
```

#### Mapinguari  (`ind_mapinguari`)
- Ficha: `cartas/indigena/07_mapinguari.md` · Entidade · 4/5
- Destino: `arte/indigena/ind_mapinguari.png`
- Texto da carta: Sempre que sofrer dano, causa 2 de dano ao atacante.
- Contexto: O Mapinguari é o gigante da floresta amazônica (Acre, Amazonas, Pará, Rondônia): peludo, com um olho só no meio da testa, **a boca aberta no ventre** e um couro tão duro que flechas e balas não entram — só o umbigo é vulnerável. Solta um grito que ensurdece e um cheiro que derruba. Cascudo (*Dicionário do Folclore Brasileiro*) o registra como um dos poucos "monstros" propriamente ditos do folclore de origem indígena; em muitas versões é um antigo pajé que buscou a imortalidade e virou bicho. […]
- Revisão anterior: **REPROVADA** — Gorila genérico com dois olhos, sem a boca na barriga: faltam os dois traços que o identificam (olho único e boca no ventre)
- Prompt atual:
```prompt
no humans, giant shaggy sloth monster, matted brown fur, cyclops, one single huge eye in the middle of forehead, second mouth on belly, big toothy mouth on stomach, long curved claws, broken arrows stuck in fur, roaring, arms raised, dense amazon jungle, night, green and orange, glowing eye, firelight from below, rim lighting, fog, deep shadows, menacing, full body, clean silhouette, readable shape, high contrast, dramatic lighting, moody atmosphere
```

#### Cobra-Grande  (`ind_cobra_grande`)
- Ficha: `cartas/indigena/08_cobra_grande.md` · Entidade · 5/6
- Destino: `arte/indigena/ind_cobra_grande.png`
- Texto da carta: Sempre que uma Entidade inimiga morrer, Cobra-Grande ganha +1/+1 permanente.
- Contexto: A Cobra-Grande, *Boiúna* ou *Mboiúna* ("cobra preta" em tupi), é a serpente colossal dos rios amazônicos: com os olhos acesos como faróis, vira barco iluminado, afunda canoas, abre igarapés com o corpo e vive no fundo dos lagos. Barbosa Rodrigues (*Poranduba Amazonense*, 1890) e Cascudo (*Geografia dos Mitos Brasileiros*) a situam no centro do imaginário ribeirinho do Pará e do Amazonas: toda cidade grande, dizem, tem uma Cobra-Grande dormindo embaixo da igreja. […]
- Revisão anterior: **REPROVADA** — Figura errada: besta humanoide de quatro membros, não uma serpente gigante saindo do rio
- Prompt atual:
```prompt
no humans, no legs, no arms, colossal black anaconda, giant snake, long serpent body, coils rising out of a dark river, huge glowing yellow eyes, open jaws, fangs, forked tongue, small capsized canoe, splashes, amazon river at night, flooded forest, moonlit water, green and orange, eyes reflected on water, rim lighting, mist, deep shadows, menacing, full body, clean silhouette, readable shape, high contrast
```

#### Jaci, a Lua  (`ind_jaci`)
- Ficha: `cartas/indigena/09_jaci.md` · Entidade · 4/5 · Lendária
- Destino: `arte/indigena/ind_jaci.png`
- Texto da carta: Lendária. Despertar: invoca uma Vitória-régia 0/2 com Guarda. No fim do seu turno, cura 2 em todas as Entidades aliadas.
- Contexto: *Jacy* (Jaci, Yacy) é a Lua no ciclo tupi-guarani: feminina, irmã ou esposa do Sol Guaraci, protetora das plantas, da reprodução e dos amantes. Couto de Magalhães (*O Selvagem*, 1876) recolheu cantos em que as mulheres pedem à lua cheia (*Cairé*) e à lua nova (*Catiti*) que tragam o amado de volta; Barbosa Rodrigues (*Poranduba Amazonense*) traz *Jacy-tatá*, "fogo da lua", para as estrelas. Entre os Mbyá-Guarani, *Jasy* é um dos gêmeos míticos, irmão de Kuaray, o Sol (Cadogan, *Ayvu Rapyta*, 1959). Jaci é também a deusa das lendas de transformação por amor. […]
- Revisão anterior: **APROVADA** — Deusa com cocar branco, olhos fechados, lua cheia e vitórias-régias, mãos abertas. Está em pé na água em vez de flutuar, mas é aceitável
- Prompt atual:
```prompt
1girl, solo, indigenous moon goddess, mature woman, dark skin, long flowing black hair, white body paint patterns, white feather headdress, feather arm bands, seed necklaces, serene expression, eyes closed, floating above a lake, palms open downward glowing softly, healing light falling on giant water lily pads, large white water lily flower, calm dark lake, flooded forest shore, jungle, full moon behind her, moonlight, silver and teal, green and orange, soft glow, fireflies, reflections on water, full body
```

#### Tupã, o Trovão  (`ind_tupa`)
- Ficha: `cartas/indigena/10_tupa.md` · Entidade · 6/7 · Lendária
- Destino: `arte/indigena/ind_tupa.png`
- Texto da carta: Lendária. Guarda. Despertar: causa 2 de dano a todas as Entidades inimigas.
- Contexto: Para os Tupinambá da costa, no século XVI, *Tupã* não era um deus supremo: era o **trovão**, a força que faz o céu estrondar. Jean de Léry (*Viagem à Terra do Brasil*, 1578, cap. XVI) escreve que os indígenas chamavam *Toupan* ao trovão e "não lhe prestavam culto"; André Thevet (*Singularidades da França Antártica*, 1557) o descreve como senhor do trovão e da chuva, de quem se tinha medo, mas a quem não se rezava. Alfred Métraux (*A religião dos Tupinambás*, 1928) confirma: não havia sacerdócio nem oferendas para Tupã. Foram os jesuítas — Anchieta à frente — que escolheram "Tupã" para traduzir "Deus" nos catecismos em tupi, por ser a única palavra para uma potência celeste. […]
- Revisão anterior: **APROVADA** — Figura pequena, mas legível: cocar, pintura vermelha, braços erguidos e raios. Segura bastões no lugar do tacape, um desvio menor
- Prompt atual:
```prompt
1boy, solo, giant indigenous thunder god, muscular mature man, dark skin, huge headdress of red and blue macaw feathers, red body paint, black painted stripes, feather arm bands, bone necklace, holding a great wooden war club, standing on storm clouds facing viewer, arms raised calling down lightning, lightning bolts striking the ground below, burning jungle canopy far below, night storm, rain, electric blue lightning, green and orange, firelight, dramatic rim lighting, high contrast, thunderclouds, glowing eyes, feather cloak, towering, full body
```

#### Arapuca  (`ind_arapuca`)
- Ficha: `cartas/indigena/11_arapuca.md` · Selo
- Destino: `arte/indigena/ind_arapuca.png`
- Texto da carta: Quando uma Entidade inimiga atacar uma Entidade sua: ela sofre 1 de dano, não ataca no próximo turno dela, e você compra 1 carta.
- Contexto: A arapuca é a armadilha de pássaros mais difundida do Brasil, e o nome é tupi: *uirá-puca*, "coisa que prende pássaro" (Cascudo, *Dicionário do Folclore Brasileiro*). É uma pirâmide de varetas amarradas com cipó, armada sobre um gatilho com isca de milho ou fruta; quando o pássaro bica a isca, a pirâmide cai e o prende vivo, sem feri-lo. Os cronistas do século XVI já descrevem as técnicas indígenas de captura — Gabriel Soares de Sousa (*Tratado Descritivo do Brasil*, 1587) dedica capítulos aos modos de caçar aves e caça miúda — e a arapuca passou intacta para a cultura caipira e sertaneja, com o mesmo nome e a mesma forma. […]
- Revisão anterior: **REPROVADA** — Não há armadilha: só uma trilha na mata e um pássaro voando. O objeto do Selo está ausente
- Prompt atual:
```prompt
no humans, object focus, close-up, pyramid-shaped bird trap, small pyramid of stacked wooden sticks tied with vines, propped up on a small trigger stick, corn kernels as bait underneath, on dark forest floor, dry leaves, roots, mossy stones, night, dim moonlight, green and orange, faint firelight, deep shadows, ominous, hidden trap, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, rim lighting, moody atmosphere, soft glow
```

#### Mundéu  (`ind_mundeu`)
- Ficha: `cartas/indigena/12_mundeu.md` · Selo
- Destino: `arte/indigena/ind_mundeu.png`
- Texto da carta: Quando uma Entidade inimiga atacar uma Entidade sua: ela sofre 4 de dano e sua Cornucópia cura 4.
- Contexto: O mundéu (do tupi *mundé*, "armadilha") é a armadilha de peso usada para caça grande — anta, veado, porco-do-mato, onça. Um tronco pesado fica suspenso sobre a trilha por uma forquilha ligada a um gatilho de isca ou de passagem; quando o animal toca o gatilho, o tronco cai e o esmaga. Soares de Sousa (*Tratado Descritivo do Brasil*, 1587) e, séculos depois, Cascudo (*Dicionário do Folclore Brasileiro*) descrevem o mundéu como a técnica indígena de caça mais eficiente para animais que o arco não derruba de um tiro. Diferente da arapuca, o mundéu mata. E a caça apanhada no mundéu é a que alimenta a aldeia — a anta ou o queixada rendem o moquém da festa. […]
- Revisão anterior: **REPROVADA** — Árvore com olhos, sem tronco suspenso nem armadilha de queda: o objeto está ausente
- Prompt atual:
```prompt
no humans, object focus, deadfall trap, heavy horizontal log hanging above a jungle trail, log held up by a forked stick, trigger vine stretched across the path, log about to fall, glowing eyes of a beast in the dark beyond, muddy trail, giant roots, night, moonlight shaft, green and orange, dim firelight, deep shadows, ominous, ambush, dramatic low angle, clean silhouette, readable shape, high contrast, dramatic lighting, rim lighting, moody atmosphere, soft glow, sharp focus
```

#### Assovio da Matinta  (`ind_assovio_da_matinta`)
- Ficha: `cartas/indigena/13_assovio_da_matinta.md` · Selo
- Destino: `arte/indigena/ind_assovio_da_matinta.png`
- Texto da carta: No fim do turno do oponente: ele descarta 1 carta aleatória e sua Cornucópia sofre 1 de dano.
- Contexto: A Matinta Perera (Matintaperera, Matinta-Pereira) é figura do Pará e do baixo Amazonas: uma velha que, à noite, se transforma num pássaro e pousa nos telhados assobiando um silvo agudo e repetido — *matinta-perê, matinta-perê* — até que alguém da casa prometa fumo. Na manhã seguinte uma velha da vizinhança aparece para cobrar o tabaco prometido; quem não dá sofre uma desgraça. Cascudo (*Dicionário do Folclore Brasileiro*) e Barbosa Rodrigues (*Poranduba Amazonense*, 1890) registram o mito, aparentado ao Saci do Norte, que também é pássaro e também se chama matinta. […]
- Revisão anterior: **REPROVADA** — O pássaro lê como coruja, não como o saci/peitica rajado de crista. A casa europeia de tijolo, telha e chaminé destoa da aldeia
- Prompt atual:
```prompt
no humans, small slender brown bird, striped cuckoo, streaked brown plumage, raised spiky crest, long tail, beak open whistling, perched on a palm-thatched roof, indigenous village of palm thatch huts, no bricks, no chimney, night, thin crescent moon, one warm lit doorway, green and orange, pale moonlight, fog, bad omen, eerie, deep shadows, full body, clean silhouette, readable shape, high contrast, dramatic lighting, rim lighting
```

#### Sopro do Pajé  (`ind_sopro_do_paje`)
- Ficha: `cartas/indigena/14_sopro_do_paje.md` · Selo
- Destino: `arte/indigena/ind_sopro_do_paje.png`
- Texto da carta: Quando o oponente jogar um Rito: anula esse Rito e você compra 1 carta.
- Contexto: O pajé (do tupi *payé*) é o xamã dos povos tupi-guarani; o *caraíba* (*karaí*) era o pajé-profeta andarilho, que ia de aldeia em aldeia anunciando a Terra sem Males. Jean de Léry (*Viagem à Terra do Brasil*, 1578, cap. XVI) descreve a cena central da pajelança: o caraíba, com um canudo de petim (tabaco) aceso, **sopra a fumaça** sobre os homens dizendo "recebei o espírito de força", e sopra também sobre doentes e lugares para expulsar o mal. Métraux (*A religião dos Tupinambás*, 1928) e Hélène Clastres (*Terra sem Mal*, 1975) analisam o sopro de fumaça como o gesto xamânico tupi por excelência: cura, purifica e desfaz feitiços alheios. […]
- Revisão anterior: **APROVADA** — Pajé idoso de cabelo branco, cocar, fumando o tubo, fumaça, rede, ambiente escuro. Não há a forma da maldição se dissolvendo, mas o conceito se lê
- Prompt atual:
```prompt
1boy, solo, elderly indigenous shaman, wrinkled dark skin, white hair, feather headdress, necklaces of seeds and teeth, red and black body paint, holding a long smoking tobacco tube, blowing a thick cloud of white smoke forward, smoke dissolving a dark purple curse shape, intense gaze, inside a dim thatched hut at night, hammock, clay pots, small fire, firelight, green and orange, glowing embers, smoke swirls, dark atmosphere, deep shadows, woven mats, feather fan, dim light, wrinkled hands, upper body
```

#### Cauim  (`ind_cauim`)
- Ficha: `cartas/indigena/15_cauim.md` · Rito
- Destino: `arte/indigena/ind_cauim.png`
- Texto da carta: Sua Cornucópia cura 2. Compre 1 carta.
- Contexto: O cauim (*kaui*) é a bebida fermentada dos povos tupi: mandioca (ou milho, caju, batata-doce) cozida, **mastigada pelas mulheres** e cuspida de volta no pote, onde a saliva inicia a fermentação; depois de dias, bebe-se morno, em cuias, até acabar. Hans Staden (1557), Jean de Léry (1578, cap. IX) e Fernão Cardim (c. 1584) descrevem com espanto as *cauinagens*: festas de aldeia inteira que duravam dias, acompanhadas de cantos e danças, obrigatórias antes da guerra, na execução de prisioneiros, em casamentos e luto. Léry anota que o cauim "é bebido com grande regozijo" e que os Tupinambá riam dos franceses por comerem enquanto bebiam — comer e beber eram atos separados. […]
- Revisão anterior: **REPROVADA** — Corpo inteiro vermelho: lê como criatura de pele vermelha, não como pintura corporal, e é um estereótipo problemático. Não há a cuia de cauim oferecida, e a fogueira fica entre as pernas
- Prompt atual:
```prompt
1girl, solo, indigenous woman, natural brown skin, long black hair, black and red geometric body paint stripes, bead necklaces, kneeling beside a big decorated clay pot, holding a gourd bowl of frothy white drink toward viewer, smiling, night village festival, bonfire in background, thatched longhouse, sandy ground, firelight, green and orange, warm glow, sparks, full body, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere
```

#### Visão do Caapi  (`ind_visao_do_caapi`)
- Ficha: `cartas/indigena/16_visao_do_caapi.md` · Rito
- Destino: `arte/indigena/ind_visao_do_caapi.png`
- Texto da carta: Compre 2 cartas. Ganhe +1 Fé neste turno.
- Contexto: *Caapi* (ou *kahpi*, em tukano) é o cipó *Banisteriopsis caapi*, base da bebida que no Brasil é mais conhecida pelo nome quéchua *ayahuasca* e que dezenas de povos amazônicos preparam há séculos: os Tukano e Dessana do Rio Negro (*kahpi*), os Huni Kuin do Acre (*nixi pae*), os Yawanawá (*uni*), entre muitos outros. Gerardo Reichel-Dolmatoff (*Amazonian Cosmos*, 1971) descreve as sessões dessana: o pajé toma o caapi e vê as "casas" dos animais, as origens do mundo e as doenças da aldeia. […]
- Revisão anterior: **REPROVADA** — Figura errada: gigante espectral roxo domina a cena. Faltam o pajé bebendo, as serpentes de luz e o jaguar
- Prompt atual:
```prompt
1boy, solo, indigenous shaman, seated cross-legged in foreground, drinking from a small clay bowl, feather headdress, body paint, glowing eyes, luminous serpents of light coiling around him, glowing geometric patterns in the air, faint jaguar face in the dark, forest at night, small fire, purple and teal glow, green and orange, mystical, trance, full body, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow
```

#### Fogo de Monan  (`ind_fogo_de_monan`)
- Ficha: `cartas/indigena/17_fogo_de_monan.md` · Rito
- Destino: `arte/indigena/ind_fogo_de_monan.png`
- Texto da carta: Causa 2 de dano a todas as Entidades inimigas e 1 de dano à Cornucópia inimiga.
- Contexto: Monan é o criador primordial dos Tupinambá segundo André Thevet (*Cosmographie Universelle*, 1575, livro XXI), que recolheu o relato dos pajés da Guanabara. Monan — "o antigo", "o que fez" — criou o céu, a terra, os animais e os primeiros homens, e vivia entre eles. Mas os homens se tornaram ingratos e esqueceram quem os fizera; então Monan mandou **Tatá**, o fogo do céu, que queimou toda a superfície da terra e a deixou com os vales e serras que tem hoje. Só um homem se salvou: **Irin-Magé**, "o que vê", que foi levado ao céu e de lá implorou a Monan que apagasse o fogo. […]
- Revisão anterior: **REPROVADA** — Figura errada: torre de pedra em chamas (lê como farol ou castelo), não fogo caindo do céu sobre a floresta
- Prompt atual:
```prompt
no humans, rain of fire from the sky, giant column of flame falling from storm clouds onto a rainforest, fireballs falling, burning jungle canopy, silhouetted trees, scorched ground, no buildings, no tower, dark storm clouds, red sky, orange and black, green and orange, embers, ash falling, smoke, catastrophe, wide shot, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow
```

#### Dança do Aruanã  (`ind_danca_do_aruana`)
- Ficha: `cartas/indigena/18_danca_do_aruana.md` · Rito
- Destino: `arte/indigena/ind_danca_do_aruana.png`
- Texto da carta: Invoca dois Aruanãs 1/1. Sua Cornucópia cura 2.
- Contexto: Os Karajá — que se chamam **Iny**, "nós" — vivem nas margens do rio Araguaia e na Ilha do Bananal (TO, GO, MT, PA). Sua cerimônia mais visível é a dos **Aruanãs** (*Ijasó*), espíritos do fundo do rio que vêm à aldeia na época das cheias. São personificados por dançarinos mascarados, **sempre em pares**, cobertos de saias de palha de buriti que escondem o corpo inteiro, com máscaras altas de penas e pintura. Cantam em falsete para que a voz não pareça humana, e dançam da casa dos homens até as mulheres, que os recebem com comida. […]
- Revisão anterior: **REPROVADA** — Coroas europeias douradas, saias xadrez tipo kilt e torsos nus (o corpo deveria estar coberto pela palha). Casas de janela europeia
- Prompt atual:
```prompt
2others, duo, two masked dancers, tall cone-shaped straw masks, whole body covered by long straw fringe costume, no visible skin, no crowns, feathers on mask tips, dancing side by side, village plaza at night, sandy ground by a river, palm-thatched huts, bonfire, firelight, green and orange, sparks, stars, solemn ritual, full body, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere
```

#### Dádiva de Mani  (`ind_dadiva_de_mani`)
- Ficha: `cartas/indigena/19_dadiva_de_mani.md` · Rito
- Destino: `arte/indigena/ind_dadiva_de_mani.png`
- Texto da carta: Devolve uma Entidade do seu cemitério à sua mão. Sua Cornucópia cura 6. Compre 1 carta.
- Contexto: A lenda da mandioca foi recolhida por Couto de Magalhães (*O Selvagem*, 1876) entre falantes de nheengatu no Amazonas e é uma das mais contadas do país. A filha de um chefe apareceu grávida sem ter marido; o pai, furioso, só se acalmou quando um homem branco lhe apareceu em sonho dizendo que a moça era inocente. Nasceu uma menina branca, **Mani**, que andou e falou cedo e morreu com um ano, sem doença. Foi enterrada dentro da casa (*oca*), como era o costume, e a sepultura regada com as lágrimas da mãe. Da cova nasceu uma planta desconhecida; a terra rachou e mostrou raízes grossas e brancas como o corpo da menina. […]
- Revisão anterior: **REPROVADA** — Só a porta de uma cabana com rede: faltam a mandioca brotando da cova e as raízes brancas
- Prompt atual:
```prompt
no humans, object focus, cassava plant sprouting from a small grave mound, thick white roots breaking through cracked earth, green palmate leaves, glowing dewdrops, inside a dark thatched hut, moonlight from doorway, clay pots, woven basket, earthen floor, soft silver light, gentle glow on roots, green and orange, mystical, hopeful, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus
```

#### Kuarup  (`ind_kuarup`)
- Ficha: `cartas/indigena/20_kuarup.md` · Rito
- Destino: `arte/indigena/ind_kuarup.png`
- Texto da carta: Traz uma Entidade do seu cemitério de volta ao campo. Compre 1 carta.
- Contexto: O Kuarup (*Kwarìp*, em kamayurá) é a grande festa funerária dos povos do Alto Xingu (MT) — Kamayurá, Kuikuro, Kalapalo, Waurá, Mehinako, Yawalapiti e outros — em homenagem aos mortos ilustres do ano. Troncos da árvore kuarup são cortados, fincados no centro da aldeia, pintados e enfeitados com cocares, braçadeiras e colares: cada tronco **é** um morto, que volta por uma noite. As famílias choram diante dos troncos; ao amanhecer, há lutas de *huka-huka* entre as aldeias convidadas e, ao fim, os troncos são lançados no rio e o luto termina. […]
- Revisão anterior: **REPROVADA** — Cruzes cristãs com caveiras azuis no lugar dos troncos kuarup pintados. Figura humanoide em chamas com olhos de fogo. Erro cultural grave
- Prompt atual:
```prompt
no humans, row of upright wooden log posts in a village plaza, logs painted with red and black geometric patterns, feather headdress and cotton bands tied on each log, central log glowing with blue spirit light, faint spirit rising from it, no crosses, no skulls, bonfire, night, thatched longhouses, sandy ground, stars, firelight, green and orange, solemn ritual, wide shot, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus
```

#### Terra sem Males  (`ind_terra_sem_males`)
- Ficha: `cartas/indigena/21_terra_sem_males.md` · Rito
- Destino: `arte/indigena/ind_terra_sem_males.png`
- Texto da carta: Todas as suas Entidades ganham +1/+1 permanente. Sua Cornucópia cura 4.
- Contexto: *Yvy marã e'ỹ* — a "terra sem mal", "terra indestrutível" — é o lugar que os Guarani buscam há séculos: onde o milho cresce sozinho, as flechas caçam por si, ninguém envelhece nem morre, e a festa não acaba. Curt Nimuendajú (*As lendas da criação e destruição do mundo como fundamentos da religião dos Apapocúva-Guarani*, 1914) foi o primeiro a descrever o profetismo guarani: o pajé-herói **Guyraypoty** dançou com seu povo até o mar e o atravessou; outros grupos caminharam do Paraguai à costa brasileira seguindo pajés que anunciavam a terra prometida, e muitos morreram no caminho. […]
- Revisão anterior: **APROVADA** — Figura de costas no caminho rumo a uma terra luminosa ao nascer do sol. Lê bem como Rito de esperança
- Prompt atual:
```prompt
1boy, solo, indigenous elder shaman seen from behind, feather headdress, gourd rattle raised, standing at the edge of the sea at dawn, footprints in the sand, path of golden light across the water, radiant lush land glowing on the horizon, giant trees, waterfalls, golden corn, flocks of birds, sunrise, golden and green, green and orange, god rays, warm glow, hopeful, clouds, wide shot, calm waves, misty horizon, lush vegetation, dawn glow, full body
```

#### Ibirapema  (`ind_ibirapema`)
- Ficha: `cartas/indigena/22_ibirapema.md` · Relíquia
- Destino: `arte/indigena/ind_ibirapema.png`
- Texto da carta: A portadora ganha +2 ATK e Ímpeto.
- Contexto: A *ywyrapema* (ibirapema, "pau achatado") é o tacape cerimonial dos Tupinambá: uma clava de madeira dura, pesada, de cabeça larga e achatada, enfeitada com penas, pintura e cordões de algodão. Hans Staden (*Warhaftige Historia*, 1557), que quase morreu por ela, descreve-a em detalhe; Jean de Léry (1578) e Gabriel Soares de Sousa (1587) confirmam que era a arma do **sacrifício ritual do prisioneiro**, usada por um só homem, que para isso ganhava um novo nome e se tornava guerreiro pleno. […]
- Revisão anterior: **REPROVADA** — Não há o tacape: só uma fogueira e uma chama no alto. A Relíquia está ausente
- Prompt atual:
```prompt
no humans, object focus, single wooden war club, large flat paddle-shaped club head, dark polished hardwood, red and yellow macaw feathers tied at the handle, cotton tassels, red and black painted bands, club planted upright in sand, close-up, bonfire glow behind, night, green and orange, strong rim lighting, wood grain, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus, vivid colors
```

#### Muiraquitã  (`ind_muiraquita`)
- Ficha: `cartas/indigena/23_muiraquita.md` · Relíquia
- Destino: `arte/indigena/ind_muiraquita.png`
- Texto da carta: A portadora ganha +3 Vida e Renascer.
- Contexto: O muiraquitã é um amuleto de pedra verde — nefrita, jadeíta ou outra rocha dura — esculpido em forma de **rã**, às vezes de peixe ou tartaruga, com um furo para pendurar ao pescoço. Peças arqueológicas foram achadas em toda a bacia do Tapajós e no Marajó, e os colonizadores as encontraram em uso entre os povos do baixo Amazonas no século XVI. João Barbosa Rodrigues dedicou-lhe um livro inteiro, *O Muyrakytã e os ídolos simbólicos* (1899), reunindo as lendas e a arqueologia. […]
- Revisão anterior: **REPROVADA** — Sapo vivo cartunesco em pé na água, com lanternas penduradas dominando a cena. Não é o amuleto de pedra verde em foco
- Prompt atual:
```prompt
no humans, object focus, close-up, small carved green jade frog amulet, stone figurine, polished nephrite, hanging on a plant-fiber cord, glowing faintly emerald, floating above moonlit lake water, ripples, water lilies, full moon reflection, night, green and orange, soft rim lighting, mystical, stone texture, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow
```

#### Maracá do Pajé  (`ind_maraca_do_paje`)
- Ficha: `cartas/indigena/24_maraca_do_paje.md` · Relíquia
- Destino: `arte/indigena/ind_maraca_do_paje.png`
- Texto da carta: A portadora ganha +1/+2. Quando ela morrer, invoca um Espírito 1/1.
- Contexto: O maracá (*mbaraká*) é o chocalho de cabaça com sementes ou pedrinhas dentro, atravessado por um cabo de madeira e enfeitado com penas — o instrumento do pajé por excelência em todo o mundo tupi-guarani. Jean de Léry (*Viagem à Terra do Brasil*, 1578, cap. XVI) descreve, com espanto, os maracás "falantes" dos Tupinambá: os caraíbas sopravam fumaça neles, enfeitavam-nos com as melhores penas, fincavam-nos no chão da casa e lhes ofereciam comida e cauim, pois acreditavam que **um espírito morava dentro** e respondia pelo chocalho. André Thevet (1557) conta o mesmo e acrescenta que os maracás eram consultados antes da guerra. […]
- Revisão anterior: **REPROVADA** — Rede cheia de abóboras e uma abóbora-lanterna de coroa (lê como Halloween). Não há maracá
- Prompt atual:
```prompt
no humans, object focus, single ritual gourd rattle, round gourd on a wooden handle, red and black painted patterns, crown of colorful feathers on top, standing upright on earthen floor, faint blue spirit wisp rising, clay offering bowls, inside a dark thatched hut, small fire, firelight, green and orange, mystical, close-up, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus, vivid colors
```

#### Cocar do Morubixaba  (`ind_cocar_do_morubixaba`)
- Ficha: `cartas/indigena/25_cocar_do_morubixaba.md` · Relíquia
- Destino: `arte/indigena/ind_cocar_do_morubixaba.png`
- Texto da carta: A portadora ganha +3 Vida e Guarda. Enquanto ela estiver em campo, todas as suas Entidades ganham +1 ATK.
- Contexto: *Morubixaba* (*mburuvixá*, "o que é grande") era o título do chefe tupinambá — não um rei, mas o guerreiro mais respeitado, que falava primeiro no conselho e conduzia a guerra, e cuja autoridade dependia de dar o exemplo e de generosidade. Gabriel Soares de Sousa (*Tratado Descritivo do Brasil*, 1587) e Jean de Léry (1578) descrevem os principais pelo ornamento: o **cocar** (*acangatara*, "coisa da cabeça") de penas de arara, guará e tucano, e o manto de penas (*guará-abucu*) reservado às grandes cerimônias. O cocar é, em quase todos os povos indígenas do Brasil, a marca de função e prestígio — nunca enfeite banal. […]
- Revisão anterior: **REPROVADA** — Não há o cocar: só fogueira, estrela e cabanas. A Relíquia está ausente
- Prompt atual:
```prompt
no humans, object focus, close-up, large feather headdress, radiating crown of long red blue and yellow macaw feathers, woven cotton headband with beads, resting on a carved wooden stool, village plaza at night, bonfire behind, firelight, green and orange, golden glow, strong rim lighting, majestic, feather texture, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus, vivid colors
```

### Cristianismo — 28 cartas

#### Anjo da Guarda  (`cri_anjo_da_guarda`)
- Ficha: `cartas/cristianismo/01_anjo_da_guarda.md` · Entidade · 1/2
- Destino: `arte/cristianismo/cri_anjo_da_guarda.png`
- Texto da carta: Guarda. Último Sopro: cura 2 da sua Cornucópia.
- Contexto: A ideia de um anjo designado a cada pessoa vem do Salmo 91,11 ("ele ordenou aos seus anjos que te guardem em todos os teus caminhos") e de Mt 18,10, onde os pequeninos têm "seus anjos nos céus" diante do Pai. A Carta aos Hebreus chama os anjos de "espíritos enviados em serviço" (Hb 1,14), e o Livro de Tobias mostra o modelo completo: Rafael, disfarçado de viajante, acompanha o jovem Tobias por todo o caminho. A devoção aos anjos da guarda ganhou festa própria no calendário romano com Paulo V (1608), fixada em 2 de outubro por Clemente X. Na iconografia popular, o anjo caminha ao lado de uma criança, mão no ombro, cobrindo-a com a asa — é essa imagem, simples e protetora, que a carta evoca. […]
- Revisão anterior: **REPROVADA** — Não há criança: o anjo está sozinho com a mão no rosto, numa capela. Falta o atributo-chave (proteger a criança) e a pose de Guarda.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_anjo_da_guarda_a.png`, `arte/cristianismo/_candidatas/cri_anjo_da_guarda_b.png`
- Prompt atual:
```prompt
1other, solo, guardian angel, two large white feathered wings, golden halo, long white robe, long golden hair, gentle face, eyes open, standing beside small sleeping child in bed, child under blanket, hand on child's shoulder, one wing curved around the child as shield, protective stance, facing viewer, dark stone bedroom at night, small window, moonlight, warm candlelight, soft holy light, gold and white, rim lighting, full body
```

#### Jonas  (`cri_jonas`)
- Ficha: `cartas/cristianismo/02_jonas.md` · Entidade · 1/2
- Destino: `arte/cristianismo/cri_jonas.png`
- Texto da carta: Renascer. (Quando morrer, volta para a sua mão uma vez.)
- Contexto: Jonas, filho de Amitai, recebe ordem de pregar em Nínive e foge no sentido contrário, embarcando para Társis. A tempestade, o sorteio dos marinheiros, o mar que se acalma quando o lançam à água — e então "o Senhor fez vir um grande peixe para engolir Jonas; e Jonas ficou nas entranhas do peixe três dias e três noites" (Jn 2,1). Do ventre do animal ele canta um salmo e é vomitado em terra firme, de onde finalmente vai a Nínive. O texto hebraico diz *dag gadol*, "grande peixe"; a Septuaginta usa *kētos*, monstro marinho, e daí a "baleia" da tradição. […]
- Revisão anterior: **REPROVADA** — Não há peixe gigante nem monstro marinho; aparece só um homem de joelhos no mar com raios. Falta o atributo que identifica Jonas.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_jonas_a.png`, `arte/cristianismo/_candidatas/cri_jonas_b.png`
- Prompt atual:
```prompt
1boy, solo, bearded prophet, wet dark hair, exhausted expression, tattered wet robe, barefoot, kneeling on sandy beach, arms raised in prayer, water dripping, gigantic whale behind him, huge open mouth of giant fish, whale head emerging from the sea, water pouring from its jaws, seaweed, sea foam, stormy sea at night, waves, breaking dawn on horizon, holy light from sky, teal and gold, rim lighting, full body, wide shot
```

#### Davi, o Pastor  (`cri_davi_o_pastor`)
- Ficha: `cartas/cristianismo/03_davi_o_pastor.md` · Entidade · 1/2
- Destino: `arte/cristianismo/cri_davi_o_pastor.png`
- Texto da carta: Ao atacar, causa 2 de dano a uma Entidade inimiga à sua escolha.
- Contexto: Davi, o caçula de Jessé, pastoreia ovelhas em Belém quando Samuel o unge rei em segredo (1Sm 16,1-13). Pouco depois, no vale de Elá, o gigante filisteu Golias desafia Israel por quarenta dias. Davi recusa a armadura de Saul, escolhe cinco pedras lisas no riacho e, com a funda, acerta a testa do gigante antes de decapitá-lo com a própria espada dele (1Sm 17,40-51). "Tu vens a mim com espada e lança; eu venho a ti em nome do Senhor." Antes de ser rei, poeta dos Salmos e ancestral do Messias, Davi é o menino que acerta a pedra *antes* do combate corpo a corpo. […]
- Revisão anterior: **APROVADA** — Pastor jovem com cabelo cacheado, túnica, bolsa e funda na mão, em vale seco. A pose está menos dinâmica que o pedido, mas é legível.
- Prompt atual:
```prompt
1boy, solo, young shepherd boy, teenage, curly brown hair, short wool tunic, leather belt, shepherd's pouch, barefoot, holding leather sling, whirling sling overhead, about to throw, dynamic throwing pose, determined expression, faint golden halo, rocky dry valley, judean desert, dry grass, river stones, distant enemy camp lights, few sheep in background, dusk sky, warm golden light, holy light, gold and white, rim lighting, full body
```

#### Lázaro de Betânia  (`cri_lazaro_de_betania`)
- Ficha: `cartas/cristianismo/04_lazaro_de_betania.md` · Entidade · 2/3
- Destino: `arte/cristianismo/cri_lazaro_de_betania.png`
- Texto da carta: Renascer. (Quando morrer, volta para a sua mão uma vez.)
- Contexto: Lázaro, irmão de Marta e Maria, adoece em Betânia e morre antes que Jesus chegue. Quatro dias depois, diante do sepulcro fechado, com Marta avisando que "já cheira mal", a pedra é removida e o grito "Lázaro, vem para fora!" o faz sair ainda atado nas faixas fúnebres (Jo 11,1-44). É o maior sinal do Evangelho de João antes da Paixão e o episódio que precipita a decisão do Sinédrio. A tradição posterior deu a Lázaro uma segunda vida literal: a *Legenda Áurea* e as lendas provençais o fazem chegar a Marselha com as irmãs e tornar-se o primeiro bispo da cidade; a tradição oriental o leva a Chipre (Larnaca guarda um túmulo com a inscrição "Lázaro, amigo de Cristo"). […]
- Revisão anterior: **REPROVADA** — Parece uma múmia de terror, com olhos vermelhos e cara cadavérica. Não há tumba de rocha nem pedra rolada, e o cenário é uma galeria gótica.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_lazaro_de_betania_a.png`, `arte/cristianismo/_candidatas/cri_lazaro_de_betania_b.png`
- Prompt atual:
```prompt
1boy, solo, adult man, short dark beard, pale face, human eyes open, gentle relieved expression, white linen burial cloth wrapped around body, cloth unwinding, face cloth falling from head, standing at entrance of rock-cut cave tomb, large round stone rolled aside, arms slightly raised, judean hillside, olive tree, night, beam of holy light from above, gold and white, dust particles, rim lighting, full body
```

#### Judite  (`cri_judite`)
- Ficha: `cartas/cristianismo/05_judite.md` · Entidade · 2/1
- Destino: `arte/cristianismo/cri_judite.png`
- Texto da carta: Despertar: destrói uma Entidade inimiga de custo 3 ou menos.
- Contexto: O Livro de Judite (deuterocanônico, séc. II a.C.) conta como a cidade de Betúlia, sitiada pelo general assírio Holofernes, está a dias de se render por sede. Judite, viúva rica e piedosa, repreende os anciãos pela falta de fé, veste-se com esmero e vai ao acampamento inimigo com a sua criada. Holofernes, encantado, oferece um banquete; embriagado, adormece, e Judite "golpeou-lhe duas vezes o pescoço com toda a força e cortou-lhe a cabeça" (Jt 13,8). A cabeça, exposta nas muralhas, desbarata o exército. Judite é modelo de vitória pela astúcia e pela fé, não pela força — o cântico final o resume: "o Senhor Todo-Poderoso os frustrou pela mão de uma mulher" (Jt 16,5). […]
- Revisão anterior: **REPROVADA** — Tem caveira dourada, criatura vermelha e poça de sangue no chão (gore e elementos espúrios). O sorriso e os olhos vermelhos a deixam com cara de vilã, e o cenário é uma catedral, não a tenda.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_judite_a.png`, `arte/cristianismo/_candidatas/cri_judite_b.png`
- Prompt atual:
```prompt
1girl, solo, mature woman, long dark hair, modest dark blue dress, long sleeves, gold headband, veil, holding sword pointed down in right hand, holding closed cloth sack in left hand, calm determined expression, standing at entrance of military tent at night, red tent drapes, overturned wine cup, distant city walls, campfire light, holy light on her face, gold and white, dramatic rim lighting, full body, clean floor
```

#### Gabriel, o Mensageiro  (`cri_gabriel`)
- Ficha: `cartas/cristianismo/06_gabriel.md` · Entidade · 2/3
- Destino: `arte/cristianismo/cri_gabriel.png`
- Texto da carta: Despertar: busque um Rito do seu deck para a mão.
- Contexto: Gabriel ("Fortaleza de Deus") é, com Miguel e Rafael, um dos três anjos nomeados na Bíblia. Aparece primeiro a Daniel, para explicar a visão do carneiro e do bode (Dn 8,16) e a profecia das setenta semanas (Dn 9,21). No Novo Testamento é o anúncio feito pessoa: aparece a Zacarias no Templo para anunciar João Batista (Lc 1,11-20) e a Maria em Nazaré para anunciar o nascimento de Jesus (Lc 1,26-38) — "Ave, cheia de graça". Na tradição ele é o arauto celeste por excelência: o Islã o tem como transmissor do Corão, e na iconografia cristã surge ajoelhado com um lírio ou um cetro, a boca aberta na palavra. Pseudo-Dionísio o coloca entre os arcanjos, o coro dos que levam mensagens de grande peso. […]
- Revisão anterior: **APROVADA** — Arcanjo de joelhos, com asas, auréola, trombeta e pergaminhos. Falta o lírio, mas a trombeta é atributo tradicional de Gabriel.
- Prompt atual:
```prompt
1other, solo, archangel, androgynous, long golden curly hair, serene expression, large white and gold wings, golden halo, white robe with gold trim, kneeling on one knee, holding white lily, long golden trumpet on back, one hand raised in greeting, mouth open speaking, glowing scroll unrolling from his hand, messenger, humble stone room, small arched window, dawn sky, ray of holy light, gold and white, stained glass light, soft rim lighting, floating golden particles, full body
```

#### Rafael, o Curador  (`cri_rafael`)
- Ficha: `cartas/cristianismo/07_rafael.md` · Entidade · 2/3
- Destino: `arte/cristianismo/cri_rafael.png`
- Texto da carta: Despertar: cura 4 de Vida de uma Entidade aliada.
- Contexto: Rafael ("Deus cura") é o protagonista oculto do Livro de Tobias. Disfarçado como o viajante Azarias, acompanha o jovem Tobias de Nínive à Média, ensina-o a tirar o coração, o fígado e o fel de um peixe do Tigre, com a fumaça expulsa o demônio Asmodeu que matara os sete noivos de Sara, e com o fel cura a cegueira do velho Tobit (Tb 6; 8; 11). Só no fim se revela: "Eu sou Rafael, um dos sete anjos que estão diante da glória do Senhor" (Tb 12,15). […]
- Revisão anterior: **APROVADA** — Viajante com chapéu de peregrino, cajado, frasco, cabaça, asas e manto verde, à beira do rio. Falta o peixe, que é secundário.
- Prompt atual:
```prompt
1other, solo, archangel disguised as traveler, young man, short brown hair, large white wings, golden halo, green travel cloak, wide brimmed pilgrim hat, wooden walking staff, large fish hanging from belt, small glass medicine flask, water gourd, one hand extended forward glowing with healing light, gentle smile, standing on dusty road, river bank, reeds, distant ancient city, twilight, warm holy light from hand, gold and white, stained glass light, rim lighting, full body
```

#### Sansão  (`cri_sansao`)
- Ficha: `cartas/cristianismo/08_sansao.md` · Entidade · 3/3
- Destino: `arte/cristianismo/cri_sansao.png`
- Texto da carta: Último Sopro: causa 2 de dano a todas as Entidades inimigas.
- Contexto: Sansão, da tribo de Dã, é nazireu desde o ventre: não corta o cabelo, não bebe vinho, e nele "o espírito do Senhor" desce como força bruta (Jz 13–16). Despedaça um leão com as mãos, mata mil filisteus com a mandíbula fresca de um jumento em Ramat-Leí (Jz 15,15-17), arranca as portas de Gaza e as carrega montanha acima. Traído por Dalila, que lhe corta as sete tranças, é cegado e posto a girar a mó na prisão. O fim é o episódio que a carta captura. […]
- Revisão anterior: **REPROVADA** — Está careca, e o cabelo longo é o atributo-chave. Parece um velho de barba branca e segura correntes em vez de empurrar os pilares.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_sansao_a.png`, `arte/cristianismo/_candidatas/cri_sansao_b.png`
- Prompt atual:
```prompt
1boy, solo, muscular man, very long dark hair, long braids, thick dark beard, blindfold, broken chains on wrists, loincloth, standing between two massive stone pillars, both palms pressed against the pillars, arms spread wide, pushing pillars apart, straining, cracks in pillars, falling stones, dark pagan temple hall, torches, dust, holy light from above, gold and white, warm firelight, strong rim lighting, full body
```

#### Serafim  (`cri_serafim`)
- Ficha: `cartas/cristianismo/09_serafim.md` · Entidade · 4/4
- Destino: `arte/cristianismo/cri_serafim.png`
- Texto da carta: Guarda. Despertar: silencia uma Entidade inimiga (perde palavras-chave e efeitos).
- Contexto: Os serafins ("os ardentes", de *saraf*, queimar) aparecem uma única vez na Bíblia, na visão inaugural de Isaías: "Serafins estavam acima dele; cada um tinha seis asas: com duas cobriam o rosto, com duas cobriam os pés e com duas voavam. E clamavam: Santo, Santo, Santo é o Senhor dos Exércitos" (Is 6,2-3). Quando o profeta se declara "homem de lábios impuros", um serafim voa até ele com uma brasa tirada do altar e toca-lhe a boca: "a tua iniquidade foi tirada e o teu pecado, expiado" (Is 6,6-7). Pseudo-Dionísio (*Da Hierarquia Celeste*, cap. 7) os põe no topo da primeira tríade, mais perto do trono que qualquer outro coro, e interpreta o nome como calor perpétuo, luz que purifica. […]
- Revisão anterior: **REPROVADA** — Tem só 4 asas visíveis e nenhuma cobre rosto ou pés. A parte de baixo vira cauda de serpente (lê como demônio) e há uma figura estranha com raio na base.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_serafim_a.png`, `arte/cristianismo/_candidatas/cri_serafim_b.png`
- Prompt atual:
```prompt
1other, solo, seraph, six fiery wings, two wings crossed over face, two wings crossed over legs, two wings spread wide, body hidden by wings, red and gold feathers, burning feathers, golden halo, glowing ember held in golden tongs, hovering above altar, symmetrical composition, facing viewer, temple interior, incense smoke, pillars, blinding holy light from above, red and gold, embers, full body
```

#### Leviatã  (`cri_leviata`)
- Ficha: `cartas/cristianismo/10_leviata.md` · Entidade · 6/7
- Destino: `arte/cristianismo/cri_leviata.png`
- Texto da carta: Sacrifício 1. Último Sopro: cura 4 da sua Cornucópia.
- Contexto: Leviatã é o monstro marinho primordial da Bíblia. O discurso final de Deus a Jó o descreve em mais de trinta versículos (Jó 40,25–41,26): couraça de escamas, fogo pelas narinas, "faz ferver o abismo como panela", e ninguém o fisga com anzol. Os Salmos lembram que Deus "esmagou as cabeças do Leviatã" (Sl 74,14) e também que o criou "para brincar" no mar (Sl 104,26). Isaías promete que "naquele dia o Senhor castigará com a sua espada o Leviatã, serpente fugidia, e matará o dragão do mar" (Is 27,1). A literatura apocalíptica desenvolve o fim da criatura. […]
- Revisão anterior: **APROVADA** — Serpente marinha colossal, escamas escuras, mandíbulas, barco para dar escala, tempestade.
- Prompt atual:
```prompt
no humans, leviathan, colossal sea serpent, biblical sea monster, dark armored scales, overlapping scale plates, massive jaws, rows of teeth, huge glowing eyes, menacing, fire and smoke from nostrils, boiling sea, steam rising from water, coiled body rising from stormy ocean, waves crashing, sea foam, tiny fishing boat in foreground for scale, night, lightning, moonlight breaking through clouds, holy light ray from sky, gold and white highlights, deep sea blue and gold, dramatic rim lighting, full body
```

#### Elias, Carro de Fogo  (`cri_elias`)
- Ficha: `cartas/cristianismo/11_elias.md` · Entidade · 4/5 · Lendária
- Destino: `arte/cristianismo/cri_elias.png`
- Texto da carta: Lendária. Renascer. Despertar: fogo do céu — 2 de dano a todas as Entidades inimigas.
- Contexto: Elias, o tesbita, surge sem genealogia em 1 Reis 17 anunciando seca ao rei Acab. Alimentado por corvos junto à torrente de Carit, hospeda-se com a viúva de Sarepta, cuja farinha e azeite não acabam; quando o filho dela morre, Elias se estende três vezes sobre o menino e o devolve vivo à mãe — a primeira ressurreição narrada na Bíblia (1Rs 17,17-24). No Monte Carmelo desafia 450 profetas de Baal: o fogo do Senhor desce e consome o holocausto, a lenha, as pedras e a água da vala (1Rs 18,38). Duas vezes mais, fogo do céu consome os cinquenta soldados enviados para prendê-lo (2Rs 1,10-12). Elias não morre. […]
- Revisão anterior: **REPROVADA** — Monta um único cavalo comum, sem carro de fogo nem cavalos de fogo. A figura é pequena e há uma marca vermelha tipo carimbo no canto inferior direito.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_elias_a.png`, `arte/cristianismo/_candidatas/cri_elias_b.png`
- Prompt atual:
```prompt
1boy, solo, old prophet, long white hair, long white beard, hairy brown mantle, standing in two-wheeled chariot of fire, flaming chariot, two horses made of fire, fire horses galloping upward, chariot rising into sky, whirlwind, arm raised to heaven, fire raining from clouds, judean hills far below, night sky, orange flames, embers, holy light, fiery orange and gold, strong rim lighting, side view, full body, wide shot
```

#### São Miguel Arcanjo  (`cri_sao_miguel_arcanjo`)
- Ficha: `cartas/cristianismo/12_sao_miguel_arcanjo.md` · Entidade · 5/6 · Lendária
- Destino: `arte/cristianismo/cri_sao_miguel_arcanjo.png`
- Texto da carta: Lendária. Guarda. Despertar: destrói uma Entidade inimiga.
- Contexto: Miguel ("Quem é como Deus?") é "um dos primeiros príncipes" que vem em socorro de Daniel contra o príncipe da Pérsia (Dn 10,13) e "o grande príncipe que defende os filhos do teu povo" no tempo da angústia final (Dn 12,1). A Epístola de Judas lembra que ele disputou com o diabo o corpo de Moisés sem ousar julgá-lo por conta própria: "O Senhor te repreenda" (Jd 9). E o Apocalipse o faz general da guerra celeste: "Miguel e os seus anjos combateram contra o Dragão... e o grande Dragão foi precipitado, a antiga serpente, chamada Diabo e Satanás" (Ap 12,7-9). A *Legenda Áurea* (cap. […]
- Revisão anterior: **REPROVADA** — Tem asas vermelhas de morcego/demônio (atributo errado) e não há dragão claramente pisado, só uma cauda dourada.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_sao_miguel_arcanjo_a.png`, `arte/cristianismo/_candidatas/cri_sao_miguel_arcanjo_b.png`
- Prompt atual:
```prompt
1other, solo, archangel warrior, large white feathered bird wings, golden halo, golden armor, red cloak, short golden hair, stern face, flaming sword raised high, golden scales in other hand, one foot on the head of a defeated black dragon, dragon lying crushed under his feet, standing guard, defensive heroic stance, facing viewer, dark battlefield in clouds, broken columns, beam of holy light from above, gold and white, dramatic rim lighting, full body
```

#### Cova dos Leões  (`cri_cova_dos_leoes`)
- Ficha: `cartas/cristianismo/13_cova_dos_leoes.md` · Selo
- Destino: `arte/cristianismo/cri_cova_dos_leoes.png`
- Texto da carta: Quando uma Entidade aliada sofrer dano, cure 4 dela e ela ganha +1/+1 permanente.
- Contexto: Daniel, judeu exilado na Babilônia, chega a chefe dos sátrapas sob Dario, o Medo. Os rivais, não achando falha nele, armam um decreto: durante trinta dias ninguém pode fazer súplica a deus ou homem senão ao rei. Daniel continua orando três vezes ao dia, de janela aberta voltada para Jerusalém, e é lançado na cova dos leões; o rei, contrariado, sela a pedra com seu anel (Dn 6,1-18). Ao amanhecer, Dario corre à cova e Daniel responde de dentro: "Meu Deus enviou o seu anjo e fechou a boca dos leões, e eles não me fizeram mal" (Dn 6,23). Daniel sai sem um arranhão — e os acusadores são lançados no lugar dele. […]
- Revisão anterior: **REPROVADA** — Não há leões, o atributo-chave. Aparecem colunas com caveiras, que leem como ossuário.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_cova_dos_leoes_a.png`, `arte/cristianismo/_candidatas/cri_cova_dos_leoes_b.png`
- Prompt atual:
```prompt
1boy, solo, bearded man in simple robe, kneeling, praying with hands clasped, eyes closed, calm, three large lions lying around him, maned lion, lioness, lions resting peacefully, lions with closed mouths, dark stone pit, lion's den, round opening in ceiling, single ray of holy light falling on him, dusty air, dark and gloomy, gold and white, warm golden light against deep shadow, rim lighting, full body, wide shot
```

#### Tumba Vazia  (`cri_tumba_vazia`)
- Ficha: `cartas/cristianismo/14_tumba_vazia.md` · Selo
- Destino: `arte/cristianismo/cri_tumba_vazia.png`
- Texto da carta: Quando uma Entidade aliada morrer, reviva uma Entidade do seu cemitério para o campo.
- Contexto: Na manhã do primeiro dia da semana, as mulheres vão ao sepulcro com aromas e encontram a pedra removida. "Não vos assusteis. Buscais Jesus de Nazaré, o crucificado? Ressuscitou, não está aqui; eis o lugar onde o puseram" (Mc 16,6). João acrescenta a corrida de Pedro e do discípulo amado, as faixas de linho no chão e o sudário dobrado à parte (Jo 20,1-9). O sepulcro aberto e vazio é o centro da fé cristã: não uma descrição da ressurreição em si — nenhum evangelho a narra —, mas o seu sinal. A carta se detém exatamente nesse sinal. Não representa Cristo; representa o **lugar**: a pedra rolada, a entrada escura, as faixas vazias. […]
- Revisão anterior: **REPROVADA** — É o interior de uma igreja gótica com feixe de luz. Faltam a tumba de rocha, a pedra rolada e os lençóis.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_tumba_vazia_a.png`, `arte/cristianismo/_candidatas/cri_tumba_vazia_b.png`
- Prompt atual:
```prompt
no humans, scenery, natural rock-cut tomb in a hillside, open cave entrance, large round millstone rolled aside, dark tomb interior, stone bench, folded white linen burial cloths on stone bench, garden at dawn, olive trees, flowers, dew, dark sky with fading stars, first light of dawn, golden light pouring out of the tomb, holy light, gold and white, soft rim lighting, quiet, mysterious, outdoors
```

#### Portão do Éden  (`cri_portao_do_eden`)
- Ficha: `cartas/cristianismo/15_portao_do_eden.md` · Selo
- Destino: `arte/cristianismo/cri_portao_do_eden.png`
- Texto da carta: Quando o oponente invocar uma Entidade, ela sofre 3 de dano e não ataca no próximo turno dela.
- Contexto: Depois da expulsão de Adão e Eva, "o Senhor Deus pôs, ao oriente do jardim do Éden, os querubins e a espada flamejante que se revolvia, para guardar o caminho da árvore da vida" (Gn 3,24). É a primeira menção a querubins na Bíblia, e já como guardiões de um limiar — função que repetem nas figuras de ouro sobre a Arca (Ex 25,18-22) e nas quatro criaturas de quatro faces que carregam o trono móvel de Ezequiel (Ez 1; 10). Pseudo-Dionísio os coloca no segundo lugar da hierarquia, logo abaixo dos serafins, e interpreta o nome como "plenitude de conhecimento". […]
- Revisão anterior: **APROVADA** — Espada flamejante diante de portão de pedra fechado, querubim de fogo acima e clima noturno de armadilha. O jardim aparece pouco, mas a cena é legível.
- Prompt atual:
```prompt
no humans, giant flaming sword floating in the air, spinning sword of fire, sword turning by itself, motion blur trail of fire, guarding gate, ancient stone gateway, closed garden gate, wall of paradise, lush garden glimpsed through gate, tree of life glowing far inside, winged guardian silhouette with four faces behind the gate, cherub shadow, dark forest outside, dry barren ground in foreground, night, fire reflecting on stones, trap, forbidden threshold, holy light, gold and white, fiery orange and gold, embers, dramatic rim lighting, scenery
```

#### Mudez de Zacarias  (`cri_mudez_de_zacarias`)
- Ficha: `cartas/cristianismo/16_mudez_de_zacarias.md` · Selo
- Destino: `arte/cristianismo/cri_mudez_de_zacarias.png`
- Texto da carta: Quando o oponente jogar um Rito, anule-o. Compre 1 carta.
- Contexto: Zacarias, sacerdote da classe de Abias, está oferecendo incenso no Santuário quando Gabriel aparece à direita do altar e anuncia que sua mulher Isabel, estéril e idosa, terá um filho chamado João. Zacarias duvida: "Como saberei disso? Sou velho e minha mulher é de idade avançada." A resposta é a sentença: "Ficarás mudo e não poderás falar até ao dia em que isto acontecer, porque não acreditaste nas minhas palavras" (Lc 1,18-20). O povo espera do lado de fora e, quando ele sai sem conseguir falar, entende que teve uma visão. […]
- Revisão anterior: **APROVADA** — Sacerdote idoso de turbante e barba, dedo nos lábios e tabuinha na mão, num santuário com incenso.
- Prompt atual:
```prompt
1boy, solo, old priest, long grey beard, priestly robe, blue and white vestments, turban, finger pressed to lips, silence gesture, holding wax writing tablet in other hand, wide shocked eyes, speechless, standing beside golden incense altar, smoke rising, temple sanctuary interior, dark stone columns, menorah, bright blinding light at right of the altar, hidden angelic presence as pure light, holy light, gold and white, stained glass light, incense smoke, rim lighting, dark and solemn, full body
```

#### Sangue nos Umbrais  (`cri_sangue_nos_umbrais`)
- Ficha: `cartas/cristianismo/17_sangue_nos_umbrais.md` · Selo
- Destino: `arte/cristianismo/cri_sangue_nos_umbrais.png`
- Texto da carta: Quando uma Entidade inimiga atacar, destrua-a. Cure 4 da sua Cornucópia.
- Contexto: Na noite da décima praga, cada família israelita marca os umbrais da porta com o sangue do cordeiro. "O Senhor passará para ferir o Egito; e, vendo o sangue na verga e nos dois umbrais, passará adiante daquela porta e não deixará o Destruidor entrar nas vossas casas para ferir" (Ex 12,23). À meia-noite morrem todos os primogênitos do Egito, "desde o primogênito do Faraó até o do cativo no cárcere" (Ex 12,29) — e a Páscoa (*pessach*, "passar por cima") nasce dessa noite. O rito é fixado ali mesmo: cordeiro sem defeito, sangue no umbral, pães sem fermento, ervas amargas, e a ordem de contar a história aos filhos (Ex 12,24-27). […]
- Revisão anterior: **REPROVADA** — Não há marcas vermelhas no lintel nem nos umbrais, o atributo-chave. Aparece um vulto encapuzado de olhos brilhantes diante de uma casa com tochas.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_sangue_nos_umbrais_a.png`, `arte/cristianismo/_candidatas/cri_sangue_nos_umbrais_b.png`
- Prompt atual:
```prompt
no humans, scenery, wooden door of a humble mud brick house, dark red blood marks on the lintel above the door, red marks on both doorposts, hyssop branch on ground, night street of ancient egypt, narrow alley, palm tree silhouette, full moon, dark mist on ground, faceless shadow of destroying angel with sword passing in the distance, warm lamplight from inside the door, ominous, hidden trap, deep blue night and warm gold, rim lighting
```

#### Multiplicação dos Pães  (`cri_multiplicacao_dos_paes`)
- Ficha: `cartas/cristianismo/18_multiplicacao_dos_paes.md` · Rito
- Destino: `arte/cristianismo/cri_multiplicacao_dos_paes.png`
- Texto da carta: Compre 2 cartas. Cure 2 da sua Cornucópia.
- Contexto: É o único milagre narrado pelos quatro evangelhos (Mt 14,13-21; Mc 6,30-44; Lc 9,10-17; Jo 6,1-14). Uma multidão segue Jesus a um lugar deserto; ao entardecer os discípulos querem despedi-la para que compre comida. Há só cinco pães de cevada e dois peixes — em João, trazidos por um menino. Jesus manda sentar o povo na relva em grupos, ergue os olhos, abençoa, parte e distribui. "Todos comeram e ficaram saciados, e recolheram doze cestos cheios dos pedaços que sobraram" — para cerca de cinco mil homens, sem contar mulheres e crianças. […]
- Revisão anterior: **REPROVADA** — Não há pães, cestos nem peixes, só dois pontos dourados num gramado ao pôr do sol. Relíquia/Rito sem objeto em foco.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_multiplicacao_dos_paes_a.png`, `arte/cristianismo/_candidatas/cri_multiplicacao_dos_paes_b.png`
- Prompt atual:
```prompt
no humans, object focus, centered composition, still life, close-up, large wicker basket overflowing with round barley bread loaves, two fish lying on top of the bread, fish scales glinting, more baskets of bread around it, loaves glowing softly, green grassy hillside, wild flowers, sea of galilee at sunset in background, distant crowd silhouettes seated on grass, miracle of abundance, holy light from above, golden particles, gold and white, warm golden hour light, soft rim lighting
```

#### Exorcismo  (`cri_exorcismo`)
- Ficha: `cartas/cristianismo/19_exorcismo.md` · Rito
- Destino: `arte/cristianismo/cri_exorcismo.png`
- Texto da carta: Devolva uma Entidade inimiga à mão do dono. Cure 4 de Vida de uma Entidade aliada.
- Contexto: Expulsar espíritos impuros é a ação mais frequente de Jesus nos evangelhos sinóticos: na sinagoga de Cafarnaum (Mc 1,21-28), o menino epiléptico que os discípulos não conseguem curar (Mc 9,14-29), a filha da sirofenícia (Mc 7,24-30). O caso mais vívido é o geraseno: um homem que vive entre os túmulos, que ninguém consegue acorrentar, e cujo espírito responde "Meu nome é Legião, porque somos muitos". Os espíritos pedem para entrar numa vara de dois mil porcos, que se precipita no lago (Mc 5,1-20). O homem é encontrado depois "sentado, vestido e em perfeito juízo". […]
- Revisão anterior: **REPROVADA** — O próprio padre tem rosto de demônio com chifres (figura errada). Não há possuído, e há gatos-demônio aos pés.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_exorcismo_a.png`, `arte/cristianismo/_candidatas/cri_exorcismo_b.png`
- Prompt atual:
```prompt
1boy, solo, human catholic priest, normal human face, short grey hair, black cassock, purple stole, holding golden cross raised forward, holy water bottle in other hand, stern face, commanding gesture, possessed man kneeling before him, small black horned demon fleeing from the man as dark smoke, swirling dark smoke, candlelit stone room, candles, overturned chair, bright holy light bursting from the cross, purple and gold, dramatic rim lighting, full body
```

#### Praga dos Gafanhotos  (`cri_praga_dos_gafanhotos`)
- Ficha: `cartas/cristianismo/20_praga_dos_gafanhotos.md` · Rito
- Destino: `arte/cristianismo/cri_praga_dos_gafanhotos.png`
- Texto da carta: Causa 2 de dano a todas as Entidades inimigas. O oponente descarta 1 carta aleatória.
- Contexto: A oitava das dez pragas do Egito. Depois do granizo que destruiu o linho e a cevada, Moisés estende o cajado e "o Senhor fez soprar um vento oriental sobre a terra todo aquele dia e toda a noite; quando amanheceu, o vento oriental tinha trazido os gafanhotos. Cobriram toda a superfície do país, de modo que a terra ficou escura; devoraram toda a erva da terra e todos os frutos das árvores que o granizo deixara, e não ficou nada verde em todo o Egito" (Ex 10,13-15). O Faraó pede perdão pela primeira vez, mas endurece de novo quando o vento oeste leva os gafanhotos ao Mar Vermelho. […]
- Revisão anterior: **REPROVADA** — Não há enxame. Um gafanhoto mecânico gigante se fundiu à pirâmide e fica ilegível.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_praga_dos_gafanhotos_a.png`, `arte/cristianismo/_candidatas/cri_praga_dos_gafanhotos_b.png`
- Prompt atual:
```prompt
no humans, scenery, wide shot, massive swarm of locusts filling the sky, thousands of small flying grasshoppers, dark insect cloud, one large detailed locust with wings in the foreground, devoured wheat field, bare stripped stalks, small pyramids on far horizon, nile river, stripped palm trees, dusty orange sky, sun blotted out, swirling dust, ominous, plague, holy light breaking through swarm, sickly yellow and dark brown, rim lighting
```

#### Talita Cumi  (`cri_talita_cumi`)
- Ficha: `cartas/cristianismo/21_talita_cumi.md` · Rito
- Destino: `arte/cristianismo/cri_talita_cumi.png`
- Texto da carta: Reviva uma Entidade do seu cemitério para o campo.
- Contexto: Jairo, chefe da sinagoga de Cafarnaum, cai aos pés de Jesus: a filha de doze anos está morrendo. No caminho, a hemorroíssa é curada ao tocar-lhe o manto, e chega a notícia de que a menina já morreu. Jesus entra na casa só com Pedro, Tiago e João e os pais, afasta os que choram e as carpideiras ("a menina não morreu, está dormindo"), toma-a pela mão e diz em aramaico: "*Talitha kum*" — "menina, eu te digo, levanta-te". "E imediatamente a menina se levantou e começou a andar" (Mc 5,21-43). Ele manda que lhe deem de comer. É uma das três ressurreições dos evangelhos sinóticos, com o filho da viúva de Naim (Lc 7,11-17) e, em João, Lázaro. […]
- Revisão anterior: **REPROVADA** — A menina parece fantasma de terror: pele cinza, olhos vermelhos e véu de noiva. Contradiz a cena de ressurreição.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_talita_cumi_a.png`, `arte/cristianismo/_candidatas/cri_talita_cumi_b.png`
- Prompt atual:
```prompt
1girl, solo, young girl, twelve years old, long dark hair, rosy cheeks, warm skin tone, brown eyes, soft smile, simple white tunic, sitting up in bed, waking up, reaching one hand toward light, humble stone house interior, galilee, oil lamp, warm morning light from window, beam of holy light onto her, golden glow, gold and white, warm colors, warm and tender, soft rim lighting, full body
```

#### Vale dos Ossos Secos  (`cri_vale_dos_ossos_secos`)
- Ficha: `cartas/cristianismo/22_vale_dos_ossos_secos.md` · Rito
- Destino: `arte/cristianismo/cri_vale_dos_ossos_secos.png`
- Texto da carta: Invoque dois Ossos Erguidos 1/1. Reviva uma Entidade aleatória do seu cemitério para a mão.
- Contexto: "A mão do Senhor veio sobre mim e me levou em espírito e me pôs no meio de um vale, que estava cheio de ossos; eram muitíssimos sobre a superfície do vale, e estavam sequíssimos" (Ez 37,1-2). Deus pergunta ao profeta se aqueles ossos podem viver e manda que ele profetize sobre eles. "Houve um ruído, e eis um rebuliço, e os ossos se achegaram, cada osso ao seu osso"; vêm nervos, carne, pele — e então o sopro dos quatro ventos, "e viveram e se puseram em pé, um exército muito grande" (Ez 37,7-10). A visão é dirigida aos exilados na Babilônia — "estes ossos são toda a casa de Israel" — e promete o retorno à terra como ressurreição nacional. […]
- Revisão anterior: **APROVADA** — Esqueleto se erguendo sobre pilha de crânios, árvore morta e vale ao entardecer. Legível.
- Prompt atual:
```prompt
no humans, skeleton standing up from the ground, undead, glowing eye sockets, bones reassembling, bones flying together, flesh and sinews growing back on skeleton, two skeletons rising, vast valley filled with dry bones, scattered skulls and ribcages, cracked dry earth, stones, dead tree, desert valley at dusk, four winds blowing, swirling dust and wind streaks, dark clouds parting, breath of life as glowing golden wind, holy light, gold and white, bone white and gold against dark earth, rim lighting, eerie yet hopeful, wide shot, full body
```

#### Granizo e Fogo  (`cri_granizo_e_fogo`)
- Ficha: `cartas/cristianismo/23_granizo_e_fogo.md` · Rito
- Destino: `arte/cristianismo/cri_granizo_e_fogo.png`
- Texto da carta: Causa 3 de dano a todas as Entidades inimigas e 1 de dano à Cornucópia inimiga.
- Contexto: A sétima praga do Egito. "Moisés estendeu o cajado para o céu, e o Senhor enviou trovões e granizo, e fogo corria pela terra. O Senhor fez chover granizo sobre a terra do Egito; havia granizo, e fogo misturado com o granizo, tão forte como nunca houvera em todo o Egito desde que se tornara nação. O granizo feriu em toda a terra do Egito tudo quanto estava no campo, tanto homens como animais, e feriu toda a erva do campo e quebrou todas as árvores" (Ex 9,23-25). Só a terra de Gósen, onde viviam os israelitas, foi poupada. É a primeira praga que mata pessoas, e a primeira em que o Faraó confessa: "Pequei esta vez". […]
- Revisão anterior: **REPROVADA** — Não há granizo, só uma explosão de fogo sobre a pirâmide. Uma silhueta de demônio com chifres em primeiro plano é elemento espúrio.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_granizo_e_fogo_a.png`, `arte/cristianismo/_candidatas/cri_granizo_e_fogo_b.png`
- Prompt atual:
```prompt
no humans, scenery, wide shot, giant white hailstones falling from the sky, ice chunks wreathed in flames, burning hailstones, motion streaks, hail bouncing on ground, dark storm clouds, lightning, fire running along the ground, burning wheat fields, shattered trees, flattened crops, ancient egypt, pyramid silhouette on horizon, nile river, divine wrath, holy light breaking through clouds, icy blue and fiery orange, embers, dramatic rim lighting
```

#### Juízo Final  (`cri_juizo_final`)
- Ficha: `cartas/cristianismo/24_juizo_final.md` · Rito
- Destino: `arte/cristianismo/cri_juizo_final.png`
- Texto da carta: Destrua todas as Entidades em campo, inimigas e suas. Depois, uma Entidade aleatória do seu cemitério volta à sua mão.
- Contexto: "Quando o Filho do Homem vier na sua glória... todas as nações serão reunidas diante dele, e ele separará uns dos outros, como o pastor separa as ovelhas dos cabritos" (Mt 25,31-33). O Apocalipse descreve a cena final: "Vi um grande trono branco... e vi os mortos, grandes e pequenos, em pé diante do trono; e abriram-se livros" (Ap 20,11-12). Daniel já tinha visto o Ancião de dias sentado, "o seu trono eram chamas de fogo", e os livros abertos (Dn 7,9-10). O Juízo é universal: ninguém fica de pé por conta própria — todos passam pelo mesmo tribunal. […]
- Revisão anterior: **REPROVADA** — Anjo tocando trombeta, mas sentado num trono dentro de igreja. Não há sepulturas se abrindo, mortos se erguendo nem escala apocalíptica.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_juizo_final_a.png`, `arte/cristianismo/_candidatas/cri_juizo_final_b.png`
- Prompt atual:
```prompt
1other, solo, angel blowing long golden trumpet, large white wings, golden halo, white robe, flying high in stormy sky, view from below, open graves in dark earth below him, cracked tombstones, small human silhouettes rising from graves, sky splitting open, blinding light from above, golden clouds, fire on horizon, cosmic scale, apocalypse, solemn, holy light, gold and white, dramatic rim lighting, wide shot, outdoors
```

#### Funda de Davi  (`cri_funda_de_davi`)
- Ficha: `cartas/cristianismo/25_funda_de_davi.md` · Relíquia
- Destino: `arte/cristianismo/cri_funda_de_davi.png`
- Texto da carta: A portadora ganha +2 ATK e Ímpeto. Quando ela ataca, causa 1 de dano a uma Entidade inimiga à sua escolha.
- Contexto: "Tomou o seu cajado na mão, escolheu para si cinco pedras lisas do ribeiro e pô-las no alforje de pastor que trazia, e, com a funda na mão, foi-se aproximando do filisteu" (1Sm 17,40). Golias zomba do menino sem armadura; Davi responde que vem "em nome do Senhor dos Exércitos". "Davi meteu a mão no alforje, tomou dali uma pedra, atirou-a com a funda e feriu o filisteu na testa; a pedra cravou-se-lhe na testa, e ele caiu com o rosto em terra" (1Sm 17,49). Só então Davi corre, toma a espada do gigante e lhe corta a cabeça. […]
- Revisão anterior: **REPROVADA** — Não há funda: a imagem mostra um cajado com esferas douradas, como um candelabro abstrato. O objeto da Relíquia está ausente.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_funda_de_davi_a.png`, `arte/cristianismo/_candidatas/cri_funda_de_davi_b.png`
- Prompt atual:
```prompt
no humans, object focus, centered composition, still life, leather shepherd's sling, weapon, two long braided leather cords, small leather pouch in the middle, smooth round river stone in the pouch, sling hanging in mid-air, five smooth stones on the ground, shepherd's leather bag, dry riverbed, judean valley at dusk, glowing stone, golden particles, holy light on the stone, warm golden light, rim lighting, simple, dark background
```

#### Véu de Verônica  (`cri_veu_de_veronica`)
- Ficha: `cartas/cristianismo/26_veu_de_veronica.md` · Relíquia
- Destino: `arte/cristianismo/cri_veu_de_veronica.png`
- Texto da carta: A portadora ganha +1/+2 e Renascer.
- Contexto: Verônica não está nos evangelhos. A lenda nasce dos *Atos de Pilatos* e da *Cura de Tibério* (séc. IV–VII) e se fixa na *Legenda Áurea*, no relato da *Vindicta Salvatoris*: uma mulher de Jerusalém, Verônica, possui um pano com o retrato de Cristo impresso — não pintado por mão humana — e é levada a Roma, onde o imperador Tibério, doente, é curado ao contemplá-lo. A partir do séc. XIII a história se funde com a Via Sacra: Verônica enxuga o rosto de Jesus a caminho do Calvário e o pano guarda a imagem (6ª estação). O nome é a própria explicação: *vera icona*, a "imagem verdadeira". […]
- Revisão anterior: **REPROVADA** — Lê como figura velada/encapuzada sentada no altar, com rosto. Não é um pano flutuando.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_veu_de_veronica_a.png`, `arte/cristianismo/_candidatas/cri_veu_de_veronica_b.png`
- Prompt atual:
```prompt
no humans, object focus, centered composition, still life, relic, white linen cloth floating in the air, square veil with soft folds, empty cloth, faint golden glow in the center of the cloth, embroidered gold hem, stains at the edges, thin golden rays holding it, dark church interior, gothic arches, stone altar below, candles, incense smoke, golden particles, holy light, gold and white, soft rim lighting, sacred, floating fabric
```

#### Santo Graal  (`cri_santo_graal`)
- Ficha: `cartas/cristianismo/27_santo_graal.md` · Relíquia
- Destino: `arte/cristianismo/cri_santo_graal.png`
- Texto da carta: A portadora ganha +0/+2. Ao equipar, cure 4 da sua Cornucópia. Quando a portadora ataca, cure 2 dela.
- Contexto: O cálice da Última Ceia — "tomou um cálice, deu graças e disse: tomai-o e distribuí-o entre vós" (Lc 22,17-20) — e o *graal* da literatura arturiana são duas tradições que se fundiram. Em Chrétien de Troyes (*Perceval ou le Conte du Graal*, c. 1190) o graal é um prato fundo levado em cortejo no castelo do Rei Pescador, que sustenta o velho rei com uma só hóstia. Robert de Boron (*Joseph d'Arimathie*, c. 1200) o identifica com o cálice da Ceia, no qual José de Arimateia recolheu o sangue de Cristo, e o traz à Bretanha. Daí a *Queste del Saint Graal* (c. 1225), onde só o puro Galaaz consegue contemplá-lo, e Wolfram von Eschenbach, para quem é uma pedra caída do céu. […]
- Revisão anterior: **APROVADA** — Cálice dourado em foco no altar, lança sangrando e capela gótica. Os dois cálices empilhados são estranhos, mas legíveis.
- Prompt atual:
```prompt
no humans, object focus, holy grail, ancient golden chalice, simple goblet with jeweled rim, chalice overflowing with liquid light, light pouring over the rim, floating above a stone altar, white cloth covering the altar, drops of glowing red wine, bleeding spear leaning nearby, ruined gothic chapel, stone floor, broken stained glass window behind, moonlight, mist, dove feathers floating, golden particles, holy light, gold and white, stained glass light, soft rim lighting, floating, healing glow, centered composition
```

#### Arca da Aliança  (`cri_arca_da_alianca`)
- Ficha: `cartas/cristianismo/28_arca_da_alianca.md` · Relíquia
- Destino: `arte/cristianismo/cri_arca_da_alianca.png`
- Texto da carta: A portadora ganha +0/+3 e Guarda. Enquanto a Arca estiver em campo, suas Entidades têm +1 ATK.
- Contexto: Construída por Bezalel no Sinai segundo as medidas dadas a Moisés — madeira de acácia revestida de ouro, dois querubins de ouro batido sobre a tampa, o *propiciatório*, onde Deus "falaria" com Moisés (Ex 25,10-22) —, a Arca guarda as tábuas da Lei, e, segundo Hb 9,4, a vara de Aarão e um vaso de maná. É o objeto mais sagrado de Israel, carregado pelos levitas com varais, nunca tocado. É também um objeto de guerra. Vai à frente do povo na travessia do Jordão, cujas águas param (Js 3), e dá sete voltas em torno de Jericó antes das muralhas caírem (Js 6). Capturada pelos filisteus, derruba a estátua de Dagon e cobre as cidades de tumores até ser devolvida numa carroça (1Sm 5–6). […]
- Revisão anterior: **REPROVADA** — Não há baú: aparece uma estátua dourada alada sobre um estrado. Faltam o baú, os varais e os dois querubins.
- Candidatas já geradas (não revisadas): `arte/cristianismo/_candidatas/cri_arca_da_alianca_a.png`, `arte/cristianismo/_candidatas/cri_arca_da_alianca_b.png`
- Prompt atual:
```prompt
no humans, object focus, centered composition, ark of the covenant, rectangular golden chest, treasure chest, acacia wood box overlaid with gold, flat golden lid, two small golden cherubim kneeling on the lid facing each other, wings touching, two long golden carrying poles through rings, pillar of light rising from the lid, tent sanctuary interior, heavy curtains, incense smoke, lampstand, dark stone floor, radiant holy light, deep gold and dark blue, strong rim lighting, symmetrical composition
```

### Taoismo — 26 cartas

#### Lan Caihe  (`tao_lan_caihe`)
- Ficha: `cartas/taoismo/01_lan_caihe.md` · Entidade · 1/1
- Destino: `arte/taoismo/tao_lan_caihe.png`
- Texto da carta: Despertar: se você controla 2 ou mais Entidades, compre 1 carta.
- Contexto: Lan Caihe (藍采和) é o mais estranho dos Oito Imortais: um andarilho de idade e sexo incertos, que canta pelas ruas batendo o pé, com um pé calçado e o outro nu, vestindo trapos no verão e deitando-se na neve no inverno sem sentir frio. Carrega uma cesta de flores e, nas versões tardias, castanholas de madeira. Quando lhe dão moedas, ele as enfia num cordão e deixa que caiam pelo caminho. A biografia mais antiga está no *Xu xianzhuan* (Biografias Continuadas dos Imortais, Shen Fen, séc. X): Lan Caihe bebe numa taverna, ouve uma flauta, sobe num grou e some no céu, deixando para trás sapato, roupa e castanholas. […]
- Revisão anterior: **APROVADA** — Um pé calçado e outro descalço, cesta de flores, robe azul em trapos, canto. Cabelo verde é estilização.
- Prompt atual:
```prompt
1other, solo, androgynous youth, ragged blue robe, tattered chinese clothes, one bare foot, one shoe, messy hair, carrying flower basket, basket overflowing with flowers, wooden clappers, singing, open mouth, stomping foot, dancing, lively pose, misty mountain path, pine trees, distant pagoda, paper lantern glow, falling petals, jade green and vermilion, mist, ink wash feel, soft rim lighting, full body
```

#### He Xiangu  (`tao_he_xiangu`)
- Ficha: `cartas/taoismo/02_he_xiangu.md` · Entidade · 1/3
- Destino: `arte/taoismo/tao_he_xiangu.png`
- Texto da carta: No fim do seu turno, cure 2 de Vida de uma Entidade aliada.
- Contexto: He Xiangu (何仙姑, "a Imortal He") é a única mulher inequívoca entre os Oito Imortais. Nasceu em Zengcheng, Guangdong, no tempo da imperatriz Wu Zetian (séc. VII), com seis fios de cabelo no alto da cabeça. Aos catorze anos um espírito lhe apareceu em sonho e a instruiu a comer pó de mica (*yunmu*) para tornar o corpo leve e imortal. Ela obedeceu, fez voto de castidade, parou de comer e passou a flutuar de montanha em montanha colhendo frutos para a mãe. As fontes são o *Taiping Guangji* (Song) e, para a versão canônica, o *Dongyou Ji* (Ming), onde Lü Dongbin a instrui e a leva ao grupo. […]
- Revisão anterior: **APROVADA** — Lótus rosa na mão, hanfu branco, lago ao luar.
- Prompt atual:
```prompt
1girl, solo, young woman, flowing white hanfu, long black hair, high topknot, hair ornament, holding lotus flower, pink lotus, long stem, serene expression, gentle smile, graceful hand gesture, floating slightly above water, healing glow from lotus, soft light petals drifting, lotus pond, lily pads, misty mountain lake, mountain peaks in clouds, night, moonlight, soft glowing light, jade green and vermilion, mist, ink wash feel, full body
```

#### Han Xiangzi  (`tao_han_xiangzi`)
- Ficha: `cartas/taoismo/03_han_xiangzi.md` · Entidade · 1/2
- Destino: `arte/taoismo/tao_han_xiangzi.png`
- Texto da carta: Despertar: se você controla 2 ou mais Entidades, ganhe 2 Fé temporária.
- Contexto: Han Xiangzi (韓湘子) é o músico dos Oito Imortais, sempre com uma flauta transversal (*dizi*) nas mãos. A tradição o faz sobrinho-neto de Han Yu (768–824), o grande prosador confuciano dos Tang, que desprezava o taoismo. A lenda inverte o jogo: o jovem Han Xiang, discípulo de Lü Dongbin, faz peônias florescerem no meio do inverno diante do tio, e nas pétalas aparece um dístico que o tio só entenderá anos depois, exilado, na passagem nevada de Lan — episódio que ecoa um poema real de Han Yu ao sobrinho. As fontes são o *Qingsuo gaoyi* (Song), o *Dongyou Ji* e peças de teatro Yuan sobre a conversão de Han Yu. […]
- Revisão anterior: **REPROVADA** — Não se vê a flauta: ele segura um talo ou flor junto à boca. Rosto com borrões vermelhos e um padrão no robe que parece algarismos ("86").
- Prompt atual:
```prompt
1boy, solo, young man, scholar, blue hanfu, white outer robe, plain robe without patterns, black hair, topknot, playing transverse bamboo flute, flute held horizontally at lips, both hands on flute, eyes closed, calm face, glowing wisps from flute, red peony in snow, snowy mountain pass, pine trees, falling snow, stone path, jade green and vermilion, mist, ink wash feel, cool blue shadows, soft golden glow, full body
```

#### Li Tieguai  (`tao_li_tieguai`)
- Ficha: `cartas/taoismo/04_li_tieguai.md` · Entidade · 1/2
- Destino: `arte/taoismo/tao_li_tieguai.png`
- Texto da carta: Renascer.
- Contexto: Li Tieguai (李鐵拐, "Li da Muleta de Ferro") é o Imortal mendigo: coxo, sujo, apoiado numa muleta de ferro, com uma cabaça de remédios pendurada da qual sai fumaça — às vezes com sua própria alma desenhada nela. Sua história é a mais clara parábola de renascimento do grupo. Li era um asceta belo e sério que dominou a arte de deixar o corpo em espírito. Um dia partiu para visitar Laozi no Monte Hua e mandou o discípulo vigiar o corpo por sete dias, com ordem de cremá-lo se não voltasse. No sexto dia o discípulo soube que a mãe estava morrendo, cremou o corpo e partiu. Quando a alma de Li voltou, só encontrou cinzas — e o cadáver de um mendigo coxo que acabara de morrer de fome ali perto. […]
- Revisão anterior: **APROVADA** — Muleta, cabaças no cinto, faixa dourada, peito nu, chamas verdes de espírito. A muleta saiu dourada, o que é aceitável.
- Prompt atual:
```prompt
1boy, solo, old beggar, lame leg, iron crutch, leaning on crutch, ragged robe, unkempt beard, wild hair, gold headband, bare chest, barefoot, double gourd on belt, smoke rising from gourd, tiny glowing spirit figure in the smoke, grinning, dirty, mountain cave entrance, dark rocks, twisted pine, night, jade green and vermilion, mist, ink wash feel, glowing ember light, green smoke glow, full body
```

#### Zhongli Quan  (`tao_zhongli_quan`)
- Ficha: `cartas/taoismo/05_zhongli_quan.md` · Entidade · 2/3
- Destino: `arte/taoismo/tao_zhongli_quan.png`
- Texto da carta: Despertar: devolva uma Entidade do seu cemitério para a sua mão.
- Contexto: Zhongli Quan (鍾離權), também Han Zhongli, é o decano dos Oito Imortais: um homem gordo de barriga à mostra, barba longa e cabelo preso em dois coques, abanando-se com um leque de folha de palmeira ou de plumas. A tradição o faz general da dinastia Han que, derrotado em campanha contra os tibetanos, fugiu para as montanhas e ali encontrou um velho mestre que lhe ensinou a alquimia. Seu leque ressuscita os mortos e transforma pedra em ouro e prata — ouro que ele distribuía aos pobres em anos de fome. […]
- Revisão anterior: **APROVADA** — Barriga de fora, leque, dois coques, barba, robe vermelho, descalço, rindo.
- Prompt atual:
```prompt
1boy, solo, fat old man, exposed belly, long beard, two hair buns, open robe, red robe, bare feet, holding palm leaf fan, waving fan, glowing wind from fan, swirling golden light, spirit rising from the ground, cheerful expression, laughing, mountain terrace, sea of clouds below, pine trees, cliff, jade green and vermilion, mist, ink wash feel, golden light, wind swirling, golden sparks, full body
```

#### Lü Dongbin  (`tao_lu_dongbin`)
- Ficha: `cartas/taoismo/06_lu_dongbin.md` · Entidade · 2/2
- Destino: `arte/taoismo/tao_lu_dongbin.png`
- Texto da carta: Aura: suas outras Entidades têm +1 ATK enquanto Lü Dongbin estiver em campo.
- Contexto: Lü Dongbin (呂洞賓, nome pessoal Lü Yan), o mais popular dos Oito Imortais, é um letrado Tang de túnica de erudito e espada mata-demônios às costas. Sua conversão é o "Sonho do Painço Amarelo": numa pousada de Handan, enquanto Zhongli Quan cozinha painço, Lü adormece e vive uma vida inteira — exames, altos cargos, casamento, filhos, desgraça, exílio, morte. Acorda e o painço ainda não ficou pronto. Compreende que a carreira mundana é sonho e segue o mestre, que o submete a dez provas (dar fortuna, ser caluniado, enfrentar demônios) antes de ensinar a alquimia. […]
- Revisão anterior: **APROVADA** — Espada nas costas, espanador taoista, chapéu de letrado, bigode. Figura pequena, mas legível.
- Prompt atual:
```prompt
1boy, solo, elegant scholar, hanfu, scholar robe, scholar cap, mustache, goatee, sword on back, demon-slaying sword, holding horsetail whisk, fly whisk, calm commanding stance, radiant aura, wind in robes, standing on cloud, mountain lake below, pavilion, pine trees, distant peaks, jade green and vermilion, mist, ink wash feel, golden rim lighting, full body
```

#### Zhang Guolao  (`tao_zhang_guolao`)
- Ficha: `cartas/taoismo/07_zhang_guolao.md` · Entidade · 2/3
- Destino: `arte/taoismo/tao_zhang_guolao.png`
- Texto da carta: Despertar: devolva uma Entidade inimiga à mão do dono.
- Contexto: Zhang Guolao (張果老, "o Velho Zhang Guo") é o único dos Oito Imortais com registro em história oficial: o *Jiu Tang shu* e o *Xin Tang shu* trazem a biografia de Zhang Guo, eremita dos montes Zhongtiao (Shanxi) que dizia ter sido ministro do imperador mítico Yao e que o imperador Xuanzong (r. 712–756) mandou buscar à corte, onde ele fez prodígios e recusou a mão de uma princesa. Seu emblema é a mula branca que monta ao contrário, de costas para a estrada, percorrendo milhares de li por dia. Ao descansar, dobra a mula como se fosse papel e a guarda numa caixinha; quando precisa viajar, borrifa água e a mula se desdobra inteira. […]
- Revisão anterior: **REPROVADA** — Sem a mula: o atributo-chave (montar de costas a mula branca) está ausente; ele está sentado numa nuvem sobre um tronco.
- Prompt atual:
```prompt
1boy, solo, old man, long white beard, small black cap, grey robe, riding white mule, sitting backwards on mule, facing the mule's tail, mule head behind him, white donkey, four legs visible, bamboo fish drum on back, smiling, relaxed, mule walking on clouds, mountain road, sea of clouds, crescent moon, night sky, jade green and vermilion, mist, ink wash feel, soft moonlight, side view, full body
```

#### Cao Guojiu  (`tao_cao_guojiu`)
- Ficha: `cartas/taoismo/08_cao_guojiu.md` · Entidade · 1/4
- Destino: `arte/taoismo/tao_cao_guojiu.png`
- Texto da carta: Guarda. Despertar: cure 2 de Vida de uma Entidade aliada.
- Contexto: Cao Guojiu (曹國舅, "Tio Imperial Cao") é o aristocrata dos Oito Imortais — o único retratado com roupa de corte, chapéu oficial e um tablete de jade (*hu*) nas mãos. A lenda o faz irmão da imperatriz Cao, consorte do imperador Song Renzong (r. 1022–1063), ligando-o a uma família histórica, a do general Cao Bin. O irmão mais novo, protegido pelo parentesco, cometia crimes impunemente; Cao Guojiu, envergonhado, tentou corrigi-lo, fracassou, distribuiu sua fortuna e se retirou para as montanhas. Ali Zhongli Quan e Lü Dongbin o encontram e perguntam o que ele cultiva. "O Dao." "Onde está o Dao?" Ele aponta para o céu. "E onde está o céu?" Ele aponta para o coração. Os dois riem e o aceitam. […]
- Revisão anterior: **REPROVADA** — Chapéu vermelho com aba larga, de aparência ocidental, no lugar do chapéu de oficial preto com asas. O rosto some sob a barba verde. Tabuletas pouco legíveis e pose sem leitura defensiva (Guarda).
- Prompt atual:
```prompt
1boy, solo, court official, red official robe, black futou hat, black winged official hat, long horizontal hat wings, visible face, calm eyes, long black beard, holding pair of jade tablets, jade castanets raised before chest, defensive stance, feet planted, facing viewer, soft green protective glow, palace gate, red pillars, hanging lanterns, stone steps, jade green and vermilion, mist, ink wash feel, warm lantern light, full body
```

#### Nezha  (`tao_nezha`)
- Ficha: `cartas/taoismo/09_nezha.md` · Entidade · 3/3
- Destino: `arte/taoismo/tao_nezha.png`
- Texto da carta: Ímpeto. Renascer.
- Contexto: Nezha (哪吒) é o deus-menino do *Fengshen Yanyi* (Investidura dos Deuses, Ming, caps. 12–14). O nome vem do budismo tântrico (Nalakuvara, filho do rei celeste Vaishravana), mas é a mitologia popular Ming que o reinventa e o taoismo religioso que o absorve como marechal celeste — ele não aparece em texto filosófico algum. Lady Yin, esposa do general Li Jing, fica grávida por três anos e meio e dá à luz uma bola de carne; o pai a corta com a espada e dela salta um menino já grande, com um anel de ouro (Anel do Universo) e uma faixa de seda vermelha (Faixa que Confunde o Céu). O imortal Taiyi Zhenren o toma como discípulo. […]
- Revisão anterior: **REPROVADA** — Faltam as rodas de vento e fogo (as chamas viraram asas) e o anel dourado. A lança fica sob o corpo, como um poste.
- Prompt atual:
```prompt
1boy, solo, child warrior, black hair, two hair buns, red silk sash, long red ribbon floating, golden ring around shoulder, fire-tipped spear in hand, standing on two flaming wheels, wind fire wheels under each foot, spinning fire wheels, charging forward, fierce expression, stormy sea, crashing waves, lotus flowers, lightning, jade green and vermilion, embers, orange fire glow, ink wash feel, motion trail, full body
```

#### Zhong Kui  (`tao_zhong_kui`)
- Ficha: `cartas/taoismo/10_zhong_kui.md` · Entidade · 3/4
- Destino: `arte/taoismo/tao_zhong_kui.png`
- Texto da carta: Despertar: silencie uma Entidade inimiga (ela perde palavras-chave e habilidades).
- Contexto: Zhong Kui (鍾馗) é o caçador de fantasmas da China: homem corpulento de barba eriçada, olhos esbugalhados, túnica de letrado e botas, de espada em punho, cercado de pequenos demônios que ele escraviza ou devora. A lenda, registrada por Shen Kuo no *Mengxi bitan* (séc. XI), conta que Zhong Kui foi um candidato dos exames imperiais nos Tang, brilhante mas feio demais; recusado (ou roubado do primeiro lugar), suicidou-se nos degraus do palácio. O imperador Xuanzong, doente, sonhou com um demônio pequeno roubando-lhe a flauta de jade e a bolsa de perfume; então um gigante de boné rasgado agarrou o ladrão, arrancou-lhe os olhos e o comeu, apresentando-se como Zhong Kui. […]
- Revisão anterior: **APROVADA** — Barba negra, olhos saltados, espada, gesto de apontar, pátio sombrio de porta vermelha. O demônio pequeno ficou como um rosto no céu, o que é aceitável.
- Prompt atual:
```prompt
1boy, solo, burly man, bristling black beard, bulging eyes, fierce, dark official robe, tattered cap, black boots, holding sword, raising sword, pointing at small cowering demon, small demon shrinking, exorcism, gloomy courtyard, red door, night, bats, jade green and vermilion, mist, ink wash feel, red lantern light, dramatic shadows, sword gleam, stone lion statue, full body
```

#### Erlang Shen  (`tao_erlang_shen`)
- Ficha: `cartas/taoismo/11_erlang_shen.md` · Entidade · 3/5
- Destino: `arte/taoismo/tao_erlang_shen.png`
- Texto da carta: Despertar: invoque Xiaotian Quan, o Cão Celestial (2/1), se houver slot livre.
- Contexto: Erlang Shen (二郎神, "o Deus Segundo Filho") é o guerreiro de três olhos do panteão popular: o terceiro olho, vertical no meio da testa, enxerga a verdade por baixo de qualquer transformação. Empunha uma lança de três pontas e dois gumes e anda com o Cão Celestial Uivante (Xiaotian Quan). Sua identidade é múltipla: em Sichuan é o filho de Li Bing, o engenheiro que domou o rio Min em Dujiangyan (séc. III a.C.), que matou um dragão de rio; no *Fengshen Yanyi* é Yang Jian, discípulo de Yuding Zhenren, mestre das 72 transformações; noutras versões é Zhao Yu, governador dos Sui. Seu episódio mais famoso está na *Jornada ao Oeste* (cap. […]
- Revisão anterior: **REPROVADA** — O terceiro olho foi parar na fachada do prédio, não na testa. Falta o cão Xiaotian (é o Despertar da carta). A lança saiu como um cone branco e o rosto tem borrões.
- Prompt atual:
```prompt
1boy, solo, warrior god, black hair, three eyes, vertical third eye on forehead, glowing third eye, handsome face, golden chinese armor, red cape, holding three-pointed double-edged lance, black hunting dog beside him, dog sitting at his feet, confident stance, mountain gate, stone steps, pine trees, full moon, clouds, jade green and vermilion, mist, ink wash feel, cool moonlight, full body
```

#### Guan Yu, Imperador Guan  (`tao_guan_yu`)
- Ficha: `cartas/taoismo/12_guan_yu.md` · Entidade · 4/5
- Destino: `arte/taoismo/tao_guan_yu.png`
- Texto da carta: Guarda. Despertar: uma Entidade aliada ganha +1 ATK permanente.
- Contexto: Guan Yu (關羽, m. 220) foi general de Liu Bei no fim dos Han, um dos três irmãos do Juramento do Jardim dos Pessegueiros no *Sanguo yanyi* (Romance dos Três Reinos, séc. XIV): rosto vermelho, barba de dois chi, a Alabarda do Dragão Verde na mão e o cavalo Lebre Vermelha. Capturado por Sun Quan e executado, a lealdade ao irmão até a morte fez dele, ao longo de mil anos, mais do que um herói: um deus. A divinização é tripla. Os budistas o fazem Sangharama, guardião dos monastérios; os confucianos, modelo de retidão (*yi*); o taoismo religioso o incorpora como deus da guerra e exorcista e, em 1614, o imperador Ming Wanli lhe dá o título de *Guansheng Dijun*, "Imperador Guan, Sábio Santo". […]
- Revisão anterior: **REPROVADA** — Segura uma espada reta no lugar do guandao (a lâmina do Dragão Verde é o atributo-chave). O ornamento de cabeça parece chifres demoníacos.
- Prompt atual:
```prompt
1boy, solo, tall general, red face, dark red skin, very long black beard, green hanfu, green robe over armor, green headscarf, holding guandao, long-handled glaive, crescent blade on long pole, green dragon crescent blade, glaive planted upright beside him, defensive stance, standing guard, stern expression, temple hall, red pillars, incense smoke, candles, red tassel on blade, jade green and vermilion, ink wash feel, warm candlelight, full body
```

#### Xiwangmu, Rainha Mãe do Oeste  (`tao_xiwangmu`)
- Ficha: `cartas/taoismo/13_xiwangmu.md` · Entidade · 4/5 · Lendária
- Destino: `arte/taoismo/tao_xiwangmu.png`
- Texto da carta: Despertar: reviva uma Entidade do seu cemitério para o campo.
- Contexto: Xiwangmu (西王母, Rainha Mãe do Oeste) começa como monstro e termina como soberana. No *Shanhaijing* ("Clássico das Montanhas Oeste") ela "tem forma humana, cauda de leopardo e dentes de tigre, assobia bem, cabelo desgrenhado com um adorno *sheng*; preside às pragas do céu e às cinco punições". Vive na Montanha de Jade, no Kunlun, servida por três pássaros azuis. O *Mu Tianzi zhuan* já a mostra brindando com o rei Mu de Zhou, e nos Han ela se torna a rainha de todos os imortais, objeto de um culto de massas no ano 3 a.C. (registrado no *Hanshu*). […]
- Revisão anterior: **REPROVADA** — Faltam o pêssego da imortalidade e o pássaro azul (qingniao), atributos que a identificam. Do jeito que está, é uma rainha genérica com chamas.
- Prompt atual:
```prompt
1girl, solo, queen, mature woman, black hair, elaborate phoenix crown, golden robes, trailing sleeves, holding immortal peach in palm, large pink peach, blue bird perched beside her, raising other hand, summoning, glowing spirit rising from ground, regal calm expression, jade palace, peach trees, peach blossoms falling, sea of clouds, jade green and vermilion, mist, ink wash feel, golden light, full body
```

#### Imperador de Jade  (`tao_imperador_de_jade`)
- Ficha: `cartas/taoismo/14_imperador_de_jade.md` · Entidade · 5/6 · Lendária
- Destino: `arte/taoismo/tao_imperador_de_jade.png`
- Texto da carta: Aura: suas outras Entidades têm +1/+1 enquanto o Imperador de Jade estiver em campo.
- Contexto: O Imperador de Jade (玉皇大帝, Yuhuang Dadi; também Yudi, "Augusto de Jade") é o soberano do céu na religião chinesa: não o princípio mais alto — acima dele, imóveis, estão os Três Puros —, mas o administrador, aquele que governa deuses, homens e demônios por meio de uma burocracia celeste espelhada na imperial, com ministérios, censos e relatórios anuais (o Deus da Cozinha sobe no fim do ano para contar o que viu em cada casa). Sua escritura própria, o *Gaoshang Yuhuang benxing jijing*, narra como, príncipe de um reino de luz, renunciou ao trono, cultivou o Dao por milhões de kalpas e alcançou a soberania. […]
- Revisão anterior: **REPROVADA** — A coroa é redonda e cheia de joias, não a coroa mian (tábua plana com fios de contas). O rosto é uma mancha sem olhos. Trono, robe e tabuleta estão corretos.
- Prompt atual:
```prompt
1boy, solo, celestial emperor, old man, seated on jade throne, mian crown, flat rectangular board on top of crown, beaded tassels hanging in front of face, visible eyes, calm stern face, long black beard, golden dragon robe, holding jade tablet with both hands, majestic, radiant aura spreading outward, celestial palace hall, golden pillars, clouds, incense smoke, jade green and vermilion, mist, ink wash feel, golden light, front view, full body
```

#### Fulu de Selamento  (`tao_fulu_de_selamento`)
- Ficha: `cartas/taoismo/15_fulu_de_selamento.md` · Selo
- Destino: `arte/taoismo/tao_fulu_de_selamento.png`
- Texto da carta: Quando o oponente jogar um Rito: anule-o (vai ao cemitério sem efeito). Compre 1 carta.
- Contexto: *Fulu* (符籙) são os talismãs escritos do taoismo: tiras de papel amarelo com caracteres em tinta vermelha ou preta numa "escrita celeste" que mistura grafias arcaicas, nomes de deuses, estrelas e ordens ("ao receber esta ordem, obedeça depressa, depressa, conforme a lei"). O *fu* é o talismã; o *lu* é o registro dos espíritos que o sacerdote tem autoridade para comandar. A tradição remonta a Zhang Daoling, fundador dos Mestres Celestiais (142 d.C.), que teria recebido de Laozi o pacto e os selos. Ge Hong, no *Baopuzi* (c. […]
- Revisão anterior: **REPROVADA** — Não há talismã de papel amarelo: só altar, velas e fumaça vermelha. O objeto da carta está ausente.
- Prompt atual:
```prompt
no humans, object focus, taoist paper talisman, single yellow paper strip, vertical talisman floating in center, abstract red brush strokes, glowing vermilion sigils, dark spell shattering into sparks around talisman, warding, dark altar, candles, bronze incense burner, incense smoke, red string, ominous, night, jade green and vermilion, mist, ink wash feel, red glow, dramatic lighting
```

#### Dragão Azul do Leste  (`tao_dragao_azul_do_leste`)
- Ficha: `cartas/taoismo/16_dragao_azul_do_leste.md` · Selo
- Destino: `arte/taoismo/tao_dragao_azul_do_leste.png`
- Texto da carta: No fim do turno do oponente: todas as suas Entidades ganham +1/+1 permanente.
- Contexto: Qinglong (青龍), o Dragão Azul (ou Verde-Azulado) do Leste, é o primeiro dos Quatro Símbolos (*Sixiang*), as quatro criaturas que dividem o céu chinês em quadrantes de sete mansões lunares cada. O *Liji* ("Quli") prescreve a formação de marcha: "à frente o Pássaro Vermelho, atrás a Tartaruga Negra, à esquerda o Dragão Azul, à direita o Tigre Branco" — isto é, os estandartes do exército repetem o mapa do céu. O *Shiji* ("Tianguan shu", de Sima Qian) e o *Huainanzi* ("Tianwen") fixam as correspondências: leste, primavera, madeira, a cor azul-verde, o yang que nasce. […]
- Revisão anterior: **APROVADA** — Dragão chinês serpentino, chifres de cervo, juba, escamas azul-esverdeadas, chuva.
- Prompt atual:
```prompt
no humans, azure dragon, chinese dragon, serpentine body, blue-green scales, antlers, flowing mane, long whiskers, coiling in s shape, rising from clouds, spring rain, blooming trees, misty mountains, dawn, eastern horizon, glowing green aura, jade green and vermilion, mist, ink wash feel, teal glow, glowing eyes, pearl in claw, pine trees, wet rocks, full body
```

#### Tigre Branco do Oeste  (`tao_tigre_branco_do_oeste`)
- Ficha: `cartas/taoismo/17_tigre_branco_do_oeste.md` · Selo
- Destino: `arte/taoismo/tao_tigre_branco_do_oeste.png`
- Texto da carta: Quando uma Entidade inimiga atacar: ela sofre 4 de dano e recebe −1 ATK permanente.
- Contexto: Baihu (白虎), o Tigre Branco do Oeste, é o Símbolo do outono, do metal e do ocaso: a estação em que se colhe e se executa. Na cosmologia dos Cinco Agentes o metal corta e o oeste é o lado do poente e dos mortos; o tigre, único predador que a China antiga temia de fato, é o guardião que pune. O *Shiji* o liga às sete mansões ocidentais; o *Fengsu tongyi* (Ying Shao, séc. II) diz que o tigre é "o senhor das feras", devora demônios e, pintado nas portas, afasta o mal. Em pinturas murais Han, o tigre do oeste caça com as costelas à mostra e a cauda erguida, muitas vezes com asas. […]
- Revisão anterior: **APROVADA** — Tigre branco com presas à mostra, outono, lua, noite (cena de armadilha). Há um tigre minúsculo duplicado no topo do penhasco, mas é discreto.
- Prompt atual:
```prompt
no humans, white tiger, black stripes, snarling, bared fangs, pouncing, leaping, claws out, ambush, autumn forest, red maple leaves, rocky cliff, moon, cold light, jade green and vermilion, mist, ink wash feel, silver moonlight, dynamic pose, glowing eyes, fur bristling, fallen leaves flying, night sky, low angle, full body
```

#### Pássaro Vermelho do Sul  (`tao_passaro_vermelho_do_sul`)
- Ficha: `cartas/taoismo/18_passaro_vermelho_do_sul.md` · Selo
- Destino: `arte/taoismo/tao_passaro_vermelho_do_sul.png`
- Texto da carta: Quando uma Entidade aliada morrer: reviva uma Entidade do seu cemitério para o campo e cure 2 da sua Cornucópia.
- Contexto: Zhuque (朱雀), o Pássaro Vermelho do Sul, governa o verão, o fogo e o meio-dia. Nas fontes Han (*Shiji*, "Tianguan shu"; *Huainanzi*) é a figura das sete mansões meridionais (de Jing, em Gêmeos, a Zhen, em Corvus; Antares, muitas vezes citada por engano, pertence à mansão Xin do Dragão Azul); nas tumbas aparece como ave de longa cauda e crista, asas abertas, entre chamas. Não é a fênix (*fenghuang*), ave de bom augúrio ligada à imperatriz, mas as duas se confundem desde cedo, e a confusão trouxe para Zhuque a ideia que o Ocidente associa à fênix: o fogo que consome e devolve. […]
- Revisão anterior: **APROVADA** — Ave de fogo com asas abertas, renascendo das chamas, pagode.
- Prompt atual:
```prompt
no humans, vermilion bird, phoenix-like bird, crimson plumage, long tail feathers, crest, wings spread, rising from flames, fire, rebirth, southern sky, sunset, clouds, pagoda silhouette, red and gold, jade green and vermilion, embers, ink wash feel, fiery backlight, glowing eyes, sparks flying, feathers trailing light, wind, dark clouds, full body
```

#### Tartaruga Negra do Norte  (`tao_tartaruga_negra_do_norte`)
- Ficha: `cartas/taoismo/19_tartaruga_negra_do_norte.md` · Selo
- Destino: `arte/taoismo/tao_tartaruga_negra_do_norte.png`
- Texto da carta: Quando uma Entidade aliada sofrer dano: cure 4 de Vida dela; ela ganha +0/+1 permanente e Guarda.
- Contexto: Xuanwu (玄武), a Tartaruga Negra — literalmente "Guerreiro Sombrio" —, é o Símbolo do norte, do inverno e da água: uma tartaruga enlaçada por uma serpente, imagem já presente nos espelhos e tijolos Han e explicada por comentadores como a união do yin (a tartaruga, que se fecha) com o yang (a serpente, que se enrola). O norte é a direção da morte e do frio, mas também da longevidade, pois a tartaruga vive mil anos e carrega nas costas o mapa do mundo — os cascos usados nos oráculos Shang eram lidos como céu e terra. O *Liji* põe Xuanwu na retaguarda do exército: quem protege as costas. […]
- Revisão anterior: **REPROVADA** — Falta a serpente enroscada no casco: sem ela não é o Xuanwu, é só uma tartaruga.
- Prompt atual:
```prompt
no humans, black tortoise, giant dark tortoise, black snake coiled around tortoise shell, snake wrapped around body, snake head raised facing tortoise head, two creatures entwined, patterned dark shell, defensive, shell glowing faintly, frozen northern river, snow, ice, winter night, jade green and vermilion, mist, ink wash feel, cold blue light, glowing eyes, falling snow, dark mountains, full body
```

#### Circulação do Qi  (`tao_circulacao_do_qi`)
- Ficha: `cartas/taoismo/20_circulacao_do_qi.md` · Rito
- Destino: `arte/taoismo/tao_circulacao_do_qi.png`
- Texto da carta: Ganhe 1 Fé temporária. Compre 1 carta.
- Contexto: *Qi* (氣) é o sopro: o ar que se respira, o vapor que sobe do arroz (a etimologia do caractere), a energia que anima o corpo e o cosmo. O *Daodejing* pede para "concentrar o sopro e tornar-se macio como um recém-nascido" (cap. 10) e descreve as dez mil coisas "carregando o yin, abraçando o yang, harmonizadas pelo sopro do vazio" (cap. 42). O *Zhuangzi* (cap. 6) diz que "o homem verdadeiro respira pelos calcanhares; o homem comum, pela garganta". Daí nasce toda a ginástica taoista: *daoyin* (guiar e esticar), *tuna* (expirar o velho, inspirar o novo), a respiração embrionária (*taixi*) descrita por Ge Hong no *Baopuzi* (cap. […]
- Revisão anterior: **APROVADA** — Monge em lótus, olhos fechados, orbe de qi diante do ventre, robe cinza, coque.
- Prompt atual:
```prompt
1boy, solo, taoist monk, meditating, lotus position, eyes closed, calm, deep breathing, glowing energy circuit, luminous ring of light flowing around torso, swirling qi, glowing orb at belly, mountaintop, pine trees, sea of clouds, dawn, jade green and vermilion, mist, ink wash feel, soft teal glow, grey robe, topknot, incense, white hair, wisps of light, full body
```

#### Flechas de Houyi  (`tao_flechas_de_houyi`)
- Ficha: `cartas/taoismo/21_flechas_de_houyi.md` · Rito
- Destino: `arte/taoismo/tao_flechas_de_houyi.png`
- Texto da carta: Cause 3 de dano a uma Entidade inimiga. Compre 1 carta.
- Contexto: No tempo do imperador Yao, os dez sóis — filhos de Di Jun e Xihe, que deviam revezar-se um por dia no alto da amoreira Fusang — subiram todos ao céu de uma vez. As colheitas queimaram, as pedras derreteram, monstros saíram dos pântanos. Yao ordenou ao arqueiro Yi (后羿, Houyi, "o senhor Yi") que resolvesse: ele retesou o arco vermelho e derrubou nove sóis, que caíram como corvos de três patas mortos, deixando só o que ainda nos aquece; depois matou o Chiselado-de-Dentes, as Nove Crianças, o Grande Javali e a serpente Xiushe (a Bashe do *Shanhaijing*). Fonte: *Huainanzi*, "Benjing xun"; *Shanhaijing* ("Haiwai dong" e "Dahuang nan"); *Chuci*, "Tianwen". […]
- Revisão anterior: **REPROVADA** — Faltam os sóis múltiplos no céu (o centro do mito). A cabeça do arqueiro é uma massa verde sem rosto.
- Prompt atual:
```prompt
1boy, solo, archer hero, muscular, human face, tanned skin, topknot, fur cape, red bow, drawing bow, aiming upward, arrow of light, ten suns in sky, multiple blazing suns, three-legged black crow falling, scorched cracked earth, heat haze, jade green and vermilion, embers, ink wash feel, orange glow, dramatic backlighting, low angle, side view, full body
```

#### Pílula de Ouro  (`tao_pilula_de_ouro`)
- Ficha: `cartas/taoismo/22_pilula_de_ouro.md` · Rito
- Destino: `arte/taoismo/tao_pilula_de_ouro.png`
- Texto da carta: Reviva uma Entidade do seu cemitério para o campo. Compre 1 carta.
- Contexto: *Jindan* (金丹), a "pílula de ouro" ou "elixir dourado", é o objeto central da alquimia taoista. Na alquimia externa (*waidan*) é uma substância real: cinábrio (sulfeto de mercúrio) aquecido no caldeirão vira mercúrio, que recombinado com enxofre volta a ser cinábrio — um ciclo de morte e retorno que, repetido nove vezes (*jiuzhuan huandan*, "o elixir que retorna nove vezes"), produziria o remédio da imortalidade. Ge Hong, no *Baopuzi* (cap. 4, "Jindan"), diz que ervas e exercícios prolongam a vida, mas só o elixir dourado dá a imortalidade verdadeira: "o ouro não apodrece nem no fogo nem na terra; quem o ingere adquire a mesma natureza". O *Zhouyi cantong qi* (séc. […]
- Revisão anterior: **REPROVADA** — Não há pílula dourada (o objeto da carta). O caldeirão é um caldeirão de bruxa ocidental, não um ding de três pés.
- Prompt atual:
```prompt
no humans, object focus, single glowing golden pill, round golden elixir floating above cauldron, bronze ding cauldron, tripod cauldron, three legs, bagua carvings on cauldron, cinnabar red flames below, golden sparks, faint spirit figure in the light, dark alchemist cave, medicine jars, red candles, jade green and vermilion, mist, ink wash feel, golden light, dramatic lighting, night
```

#### Banquete dos Pêssegos  (`tao_banquete_dos_pessegos`)
- Ficha: `cartas/taoismo/23_banquete_dos_pessegos.md` · Rito
- Destino: `arte/taoismo/tao_banquete_dos_pessegos.png`
- Texto da carta: Todas as suas Entidades ganham +1/+1 permanente. Cure 2 da sua Cornucópia.
- Contexto: O Pantao Hui (蟠桃會), Banquete dos Pêssegos Achatados, é a festa que Xiwangmu oferece no Palácio de Jade do Kunlun quando os pêssegos da imortalidade amadurecem. Na *Jornada ao Oeste* (cap. 5) o pomar tem três mil e seiscentas árvores: as da frente dão fruto a cada três mil anos e tornam quem os come leve e sadio; as do meio, a cada seis mil, e dão o voo e a vida eterna; as do fundo, a cada nove mil, e fazem o comensal durar tanto quanto céu e terra. Sun Wukong, nomeado guardião do pomar, come os melhores, invade o banquete antes dos convidados, bebe o vinho imperial e engole o elixir de Laozi — o que desencadeia a guerra contra o céu. […]
- Revisão anterior: **APROVADA** — Mesa com pêssegos, pessegueiros floridos, lanternas, grous. Há um pequeno artefato (rostinho) sobre a pilha dourada, mas é quase invisível.
- Prompt atual:
```prompt
no humans, banquet table, piles of glowing peaches, wine jars, jade cups, peach blossom branches, jade palace terrace, above the clouds, floating lanterns, cranes flying, celebration, feast, jade green and vermilion, mist, ink wash feel, warm golden light, pink blossoms, red tablecloth, golden plates, blooming peach trees, pink petals falling, jade pillars, sunset sky, soft glow, scenery
```

#### Taiji  (`tao_taiji`)
- Ficha: `cartas/taoismo/24_taiji.md` · Rito
- Destino: `arte/taoismo/tao_taiji.png`
- Texto da carta: Uma Entidade aliada ganha +2/+2 permanente e uma Entidade inimiga recebe −2/−2 permanente.
- Contexto: *Taiji* (太極), a "Polaridade Suprema", é o nome que o *Yijing* dá ao estado anterior à divisão: "a Mudança tem o Taiji; este gera as Duas Potências (yin e yang); as duas geram as Quatro Imagens; as quatro geram os Oito Trigramas" ("Xici" I.11). O *Daodejing* (cap. 42) diz o mesmo em outra chave: "o Dao gera o Um, o Um gera o Dois, o Dois gera o Três, o Três gera as dez mil coisas; elas carregam o yin e abraçam o yang". Yin (陰, a encosta sombria da montanha) e yang (陽, a encosta ensolarada) não são bem e mal: são o par que só existe junto, cada um crescendo enquanto o outro míngua, cada um com a semente do outro — os dois pontos no diagrama. […]
- Revisão anterior: **REPROVADA** — Só há um koi branco: falta o koi preto e não se forma o yin-yang. Olhos vermelhos inquietantes.
- Prompt atual:
```prompt
no humans, object focus, from above, two koi fish, one black koi, one white koi, black and white koi swimming in a circle, chasing each other's tail, forming yin yang symbol, symmetric composition, dark pond, swirling water, ripples, lotus leaves, moon reflection, balance, high contrast, glowing white fish, jade green and vermilion, mist, ink wash feel, night
```

#### Pêssego da Imortalidade  (`tao_pessego_da_imortalidade`)
- Ficha: `cartas/taoismo/25_pessego_da_imortalidade.md` · Relíquia
- Destino: `arte/taoismo/tao_pessego_da_imortalidade.png`
- Texto da carta: Equipe uma Entidade aliada: +1/+2. A portadora ganha Renascer.
- Contexto: O pêssego (*tao*, 桃) é a fruta da longevidade na China desde antes do taoismo: a madeira de pessegueiro afasta espíritos (os *taofu*, tabuletas de pessegueiro penduradas nas portas no Ano-Novo, antecedem os dísticos de papel), a flor é a primavera, e o fruto, com seu sulco e sua forma, é a vida que se renova. Um trecho atribuído ao *Shanhaijing* (citado no *Lunheng* de Wang Chong, séc. I, mas ausente do texto que chegou até nós) fala de uma árvore de pêssego de três mil li no Monte Dushuo, sob cuja porta dos fantasmas montam guarda Shentu e Yulü. […]
- Revisão anterior: **REPROVADA** — O objeto não lê como pêssego: é um cacho rosa de nuvem ou flor, em chamas, sobre um vaso. Para uma Relíquia em foco, o objeto precisa ser inequívoco.
- Prompt atual:
```prompt
no humans, object focus, still life, single giant peach, round peach fruit, pink and gold skin, peach with cleft, two green leaves on stem, glowing, floating above jade pedestal, peach blossom branch, soft golden light radiating, mist swirling, mountain garden, clouds, jade green and vermilion, ink wash feel, warm glow, dewdrops, falling petals, soft sparkles, night sky
```

#### Espelho de Bronze  (`tao_espelho_de_bronze`)
- Ficha: `cartas/taoismo/26_espelho_de_bronze.md` · Relíquia
- Destino: `arte/taoismo/tao_espelho_de_bronze.png`
- Texto da carta: Equipe uma Entidade aliada: +1/+1 e Furtivo. Ao equipar, silencie uma Entidade inimiga.
- Contexto: "As coisas velhas, de dez mil anos, são capazes de tomar forma humana para iludir os olhos dos homens — mas não conseguem alterar sua forma verdadeira dentro de um espelho." A frase é de Ge Hong, *Baopuzi*, cap. 17 ("Dengshe", "Subir montanhas e atravessar rios"), que recomenda ao taoista que entra nas montanhas levar às costas um espelho de bronze de nove polegadas ou mais: os espíritos, ao se aproximarem por trás, veem-se refletidos como são — raposa, tartaruga, árvore velha — e fogem, ou ficam paralisados de vergonha. O espelho não mata: desmascara. […]
- Revisão anterior: **REPROVADA** — Parece um filtro dos sonhos verde, não um espelho de bronze polido. A raposa aparece sentada fora do espelho, não refletida nele.
- Prompt atual:
```prompt
no humans, object focus, round chinese bronze mirror, polished reflective disc, ornate bronze rim, green patina, red tassel hanging from knob, mirror standing upright on stand, fox demon reflection inside mirror, fox spirit revealed in reflection, ghostly glow, dark forest, night, mountain path, jade green and vermilion, mist, ink wash feel, cold glint, cold moonlight, dramatic lighting
```

### Hinduísmo — 29 cartas

#### Matsya, o Peixe  (`hin_matsya`)
- Ficha: `cartas/hinduismo/01_matsya.md` · Entidade · 0/1
- Destino: `arte/hinduismo/hin_matsya.png`
- Texto da carta: Despertar: busque uma Relíquia do seu deck para a mão.
- Contexto: Matsya ("peixe") é o primeiro dos dez avatares de Vishnu. Na versão mais antiga (Shatapatha Brahmana 1.8.1), um peixinho pede proteção a Manu, o primeiro homem; Manu o cria num pote, depois num tanque, depois no mar, e o peixe, já imenso, avisa-o do dilúvio que vem e lhe manda construir uma barca. Quando as águas sobem, Manu amarra a barca ao chifre do peixe, que a reboca até a montanha do norte — e a humanidade recomeça dali. O Bhagavata Purana (8.24) amplia a história: o asura Hayagriva rouba os Vedas da boca de Brahma adormecido, e Vishnu, na forma de Matsya, os recupera do fundo do oceano e os devolve ao criador. […]
- Revisão anterior: **REPROVADA** — Saiu uma sereia (torso feminino humanoide, braços) e não o peixe colossal com chifre. Figura errada.
- Candidatas já geradas (não revisadas): `arte/hinduismo/_candidatas/hin_matsya_a.png`, `arte/hinduismo/_candidatas/hin_matsya_b.png`
- Prompt atual:
```prompt
no humans, animal focus, colossal golden fish, giant carp, fish only, horned fish, single horn on head, small golden crown, shining golden scales, long flowing fins, flowing tail, glowing eyes, golden scroll in mouth, swimming upward, side view, deep dark ocean, underwater, rays of light from above, bubbles, floating lotus petals, saffron and blue, glowing scales, rim lighting, majestic, full body
```

#### Garuda  (`hin_garuda`)
- Ficha: `cartas/hinduismo/02_garuda.md` · Entidade · 1/2
- Destino: `arte/hinduismo/hin_garuda.png`
- Texto da carta: Ímpeto.
- Contexto: Garuda é o rei das aves e a montaria (vahana) de Vishnu: corpo de homem, asas, bico e garras de águia, dourado como o sol. Sua história está no Astika Parva do Mahabharata (Adi Parva): nasce de Vinata, que fora escravizada pela irmã Kadru, mãe das nagas (serpentes). Para libertar a mãe, Garuda aceita o preço exigido pelas serpentes — a amrita dos deuses — e sobe ao céu, derrota Indra e os devas em pleno voo e traz o néctar, sem beber uma gota. Vishnu, impressionado com a força e com a renúncia, oferece-lhe a imortalidade e o lugar de sua montaria; Indra, derrotado, recupera a amrita e sela com Garuda um pacto: as serpentes serão para sempre seu alimento. […]
- Revisão anterior: **APROVADA** — Cabeça de águia, asas douradas, coroa, tanga vermelha, garras. Está pousado e não mergulhando, mas é legível.
- Prompt atual:
```prompt
1boy, solo, bird man, eagle head, golden beak, golden feathers, huge outstretched wings, muscular human body, bare chest, eagle talons, jeweled crown, gold ornaments, red loincloth, diving down from the sky, dynamic pose, attacking, talons forward, serpent in talons, speed lines, wind, mountain peaks below, sunset clouds, saffron and blue, golden light, sun behind, rim lighting, full body
```

#### Jatayu  (`hin_jatayu`)
- Ficha: `cartas/hinduismo/03_jatayu.md` · Entidade · 1/1
- Destino: `arte/hinduismo/hin_jatayu.png`
- Texto da carta: Ímpeto. Último Sopro: compre 1 carta.
- Contexto: Jatayu é o rei dos abutres do Ramayana, velho amigo do rei Dasharatha, pai de Rama. No Aranya Kanda, quando Ravana sobrevoa a floresta de Dandaka levando Sita raptada em seu carro voador, Jatayu é o único a enfrentá-lo: ataca o carro, quebra o arco e mata as mulas, e por um instante força o rei de Lanka a descer. Ravana então saca a espada e corta-lhe as asas. Rama e Lakshmana encontram o pássaro agonizando. Antes de morrer, Jatayu conta o que viu — quem levou Sita e para que lado — e é esse último sopro que dá rumo à busca de Rama. Rama realiza para ele os ritos funerários como faria para o próprio pai. […]
- Revisão anterior: **REPROVADA** — O abutre coroado está bom, mas há um ícone parecido com marca d'água no canto inferior direito e uma silhueta humana sem sentido no morro. Se der, basta apagar o ícone à mão.
- Candidatas já geradas (não revisadas): `arte/hinduismo/_candidatas/hin_jatayu_a.png`, `arte/hinduismo/_candidatas/hin_jatayu_b.png`
- Prompt atual:
```prompt
no humans, giant old vulture, king of vultures, ragged grey and brown feathers, bald wrinkled head, hooked beak, white neck ruff, small golden crown, wings spread wide, huge wingspan, swooping attack, talons forward, falling feathers, fierce eyes, dense forest canopy below, dusk sky, dark storm clouds, saffron and blue, orange sunset glow, rim lighting, dramatic shadows, low angle, full body
```

#### Ganesha, Removedor de Obstáculos  (`hin_ganesha`)
- Ficha: `cartas/hinduismo/04_ganesha.md` · Entidade · 2/3
- Destino: `arte/hinduismo/hin_ganesha.png`
- Texto da carta: Despertar: devolva uma Entidade inimiga à mão do dono.
- Contexto: Ganesha (Ganapati, Vinayaka) é o deus de cabeça de elefante, filho de Parvati e Shiva, e uma das divindades mais amadas da Índia: é invocado antes de qualquer começo — uma viagem, um casamento, a primeira página de um livro. Seu epíteto mais comum é *Vighnaharta* ou *Vighneshvara*, "o que remove (e governa) os obstáculos". O Shiva Purana (Rudra Samhita) conta a origem da cabeça: Parvati molda um menino com a pasta do próprio banho e o põe de guarda à porta. Shiva, voltando, é barrado pelo guardião desconhecido e, na luta, corta-lhe a cabeça. […]
- Revisão anterior: **APROVADA** — Cabeça de elefante, quatro braços, barriga, machado, coroa e lâmpadas no templo. Faltam o rato e o doce, que são detalhes menores.
- Prompt atual:
```prompt
1boy, solo, elephant head, elephant-headed god, one broken tusk, curled trunk, large ears, orange skin, pot belly, four arms, multiple arms, golden crown, gold ornaments, red silk dhoti, holding axe, holding bowl of sweets, raised palm, blessing gesture, pushing aside a boulder, small mouse at his feet, temple gateway, lotus pond, oil lamps, saffron and blue, warm lamplight, rim lighting, full body
```

#### Arjuna  (`hin_arjuna`)
- Ficha: `cartas/hinduismo/05_arjuna.md` · Entidade · 2/2
- Destino: `arte/hinduismo/hin_arjuna.png`
- Texto da carta: Furtivo. Ao atacar, causa 1 de dano a uma Entidade inimiga à sua escolha.
- Contexto: Arjuna é o terceiro dos cinco Pandavas, filho de Kunti com o deus Indra, e o maior arqueiro do Mahabharata. Discípulo predileto de Drona, ganha o arco Gandiva e duas aljavas inesgotáveis no incêndio da floresta de Khandava (Adi Parva). No Vana Parva, pratica ascese no Himalaia até que Shiva, disfarçado de caçador kirata, o testa em combate e lhe concede o Pashupatastra. É a Arjuna que Krishna, seu auriga, ensina a Bhagavad Gita no campo de Kurukshetra, quando o herói hesita diante de matar parentes e mestres. […]
- Revisão anterior: **REPROVADA** — Falta o arco: os braços cruzados sobre o rosto seguram só uma flecha, e a anatomia dos braços ficou confusa.
- Candidatas já geradas (não revisadas): `arte/hinduismo/_candidatas/hin_arjuna_a.png`, `arte/hinduismo/_candidatas/hin_arjuna_b.png`
- Prompt atual:
```prompt
1boy, solo, archer, warrior prince, adult man, long black hair, golden crown, gold armor, muscular, holding great longbow, large curved bow, bow fully visible, drawing bowstring, arrow nocked, aiming, side view, focused expression, standing on war chariot, war banner with monkey emblem, swirling dust, battlefield at dawn, low light, saffron and blue, golden light, rim lighting, dramatic shadows, full body
```

#### Hanuman  (`hin_hanuman`)
- Ficha: `cartas/hinduismo/06_hanuman.md` · Entidade · 3/2
- Destino: `arte/hinduismo/hin_hanuman.png`
- Texto da carta: Ímpeto. Sempre que atacar, ganha +1 ATK permanente.
- Contexto: Hanuman é o vanara (homem-macaco) filho do deus do vento Vayu — por isso Anjaneya, Pavanaputra, Maruti — e o devoto perfeito de Rama. No Sundara Kanda do Ramayana, quando os aliados de Rama chegam à beira do oceano sem saber como alcançar Lanka, Hanuman cresce até o tamanho de uma montanha e salta os cem *yojanas* de mar num único impulso. Em Lanka, encolhe ao tamanho de um gato para procurar Sita, encontra-a no bosque de ashoka, deixa-se capturar para falar com Ravana e, quando os rakshasas incendeiam sua cauda, usa o fogo para queimar a cidade inteira antes de voltar. […]
- Revisão anterior: **APROVADA** — Macaco de rosto vermelho, coroa, cauda e maça em salto aéreo. A montanha não aparece, mas ele é reconhecível.
- Prompt atual:
```prompt
1boy, solo, monkey man, monkey face, red face, long tail, muscular, golden crown, gold ornaments, red loincloth, golden mace, holding mace, leaping through the air, flying, dynamic pose, determined expression, carrying a mountain on one palm, mountain with glowing green herbs, ocean far below, night sky, clouds, saffron and blue, moonlight, golden rim lighting, wind, full body
```

#### Narasimha  (`hin_narasimha`)
- Ficha: `cartas/hinduismo/07_narasimha.md` · Entidade · 3/2
- Destino: `arte/hinduismo/hin_narasimha.png`
- Texto da carta: Despertar: destrua uma Entidade inimiga de custo 3 ou menos.
- Contexto: Narasimha ("homem-leão") é o quarto avatar de Vishnu. O Bhagavata Purana (livro 7) conta que o rei asura Hiranyakashipu, querendo vingar o irmão Hiranyaksha morto por Varaha, obteve de Brahma uma bênção quase perfeita: não poderia ser morto por homem nem animal, por deva nem asura, de dia nem de noite, dentro nem fora de casa, no chão nem no ar, por arma alguma. Tornou-se tirano dos três mundos e perseguiu o próprio filho, o menino Prahlada, devoto de Vishnu, tentando matá-lo com veneno, elefantes, fogo e precipícios — sem sucesso. […]
- Revisão anterior: **APROVADA** — Cabeça de leão rugindo, quatro braços com garras e pilares.
- Prompt atual:
```prompt
1boy, solo, lion head, man-lion, lion-headed god, flowing golden mane, fierce, roaring, glowing eyes, fangs, sharp claws, four arms, multiple arms, muscular, golden crown, gold ornaments, bursting out of a shattered stone pillar, lunging forward, claws raised, flying stone debris, palace threshold, twilight sky, saffron and blue, orange dusk light, dramatic rim lighting, full body
```

#### Rama, Príncipe de Ayodhya  (`hin_rama`)
- Ficha: `cartas/hinduismo/08_rama.md` · Entidade · 3/4
- Destino: `arte/hinduismo/hin_rama.png`
- Texto da carta: Renascer.
- Contexto: Rama é o sétimo avatar de Vishnu e o herói do Ramayana de Valmiki. Nasce em Ayodhya como filho mais velho do rei Dasharatha, ganha Sita ao erguer e partir o arco Pinaka de Shiva no torneio de Janaka, e, na véspera de ser coroado, aceita sem queixa catorze anos de exílio na floresta para que o pai honre uma promessa antiga à rainha Kaikeyi. Na floresta, Ravana rapta Sita; Rama alia-se ao rei vanara Sugriva e a Hanuman, atravessa o oceano por uma ponte de pedras e, em Lanka, mata Ravana — a quem a bênção de Brahma tornara invulnerável a deuses e demônios, mas não a um homem. Por isso Vishnu desceu como humano. […]
- Revisão anterior: **REPROVADA** — O arco não está claro (só um arco dourado atrás da cabeça que parece halo) e as proporções são chibi (cabeça grande, corpo pequeno).
- Candidatas já geradas (não revisadas): `arte/hinduismo/_candidatas/hin_rama_a.png`, `arte/hinduismo/_candidatas/hin_rama_b.png`
- Prompt atual:
```prompt
1boy, solo, young adult prince, tall, realistic proportions, dark blue skin, long black hair, serene face, tall golden crown, gold ornaments, saffron dhoti, quiver on back, holding great longbow in left hand, large curved bow, bow fully visible, arrow in right hand, standing tall, heroic, halo of sunlight, forest riverbank, lotus flowers, saffron and blue, sunrise, golden light, rim lighting, glowing aura, full body
```

#### Krishna, o Auriga  (`hin_krishna`)
- Ficha: `cartas/hinduismo/09_krishna.md` · Entidade · 3/4
- Destino: `arte/hinduismo/hin_krishna.png`
- Texto da carta: Enquanto Krishna estiver em campo, suas Entidades têm Ímpeto.
- Contexto: Krishna é o oitavo avatar de Vishnu e, para muitas tradições vaishnavas, a própria divindade suprema de quem os outros avatares emanam. O Bhagavata Purana (livro 10) narra sua infância em Vrindavan — o bebê que rouba manteiga, o menino que ergue o monte Govardhana num dedo para abrigar os pastores da tempestade de Indra, o jovem flautista das gopis — e a juventude em Mathura, onde mata o tirano Kamsa. No Mahabharata ele é o estrategista e o auriga: recusa-se a lutar na guerra de Kurukshetra, mas conduz o carro de Arjuna. […]
- Revisão anterior: **REPROVADA** — Monta um cavalo em vez de conduzir a carruagem, o que tira a identidade do "Auriga". Também faltam a pena de pavão na coroa e o rosto adulto.
- Candidatas já geradas (não revisadas): `arte/hinduismo/_candidatas/hin_krishna_a.png`, `arte/hinduismo/_candidatas/hin_krishna_b.png`
- Prompt atual:
```prompt
1boy, solo, adult man, charioteer, blue skin, peacock feather in crown, golden crown, long black hair, yellow silk dhoti, gentle smile, holding reins, pointing forward, standing in golden war chariot, chariot wheel visible, two white horses galloping ahead, flowing manes, dust clouds, war banners, battlefield at dawn, dynamic pose, speed lines, saffron and blue, golden light, rim lighting, full body
```

#### Durga, a Fortaleza  (`hin_durga`)
- Ficha: `cartas/hinduismo/10_durga.md` · Entidade · 4/5
- Destino: `arte/hinduismo/hin_durga.png`
- Texto da carta: Ímpeto. Guarda.
- Contexto: Durga ("a inacessível", "a fortaleza") é a forma guerreira da Deusa (Devi, Shakti). O Devi Mahatmya, inserido no Markandeya Purana (séc. V–VI) e recitado inteiro nos nove dias do Navaratri, conta sua origem: o asura-búfalo Mahishasura expulsou os deuses do céu, protegido por uma bênção que o tornava invencível a qualquer homem ou deus. Da cólera reunida de Vishnu, Shiva, Brahma, Indra e todos os demais saiu uma luz que tomou forma de mulher, e cada deus lhe entregou uma arma: o tridente de Shiva, o disco de Vishnu, a concha de Varuna, a lança de Agni, o arco de Vayu, o raio de Indra, o laço de Yama. Himavat lhe deu o leão. […]
- Revisão anterior: **REPROVADA** — Falta o leão (o vahana, atributo-chave). As armas se repetem (dois tridentes) em vez de serem variadas. A pose frontal de Guarda está boa e pode ser mantida.
- Candidatas já geradas (não revisadas): `arte/hinduismo/_candidatas/hin_durga_a.png`, `arte/hinduismo/_candidatas/hin_durga_b.png`
- Prompt atual:
```prompt
1girl, solo, warrior goddess, adult woman, eight arms, multiple arms, different weapon in each hand, trident, sword, golden discus, conch shell, bow, shield, long black hair, golden crown, red sari, calm fierce face, seated on a large lion, lion beneath her, lion roaring, facing viewer, frontal, protective stance, mountain battlefield, saffron and blue, golden halo, rim lighting, glowing aura, full body
```

#### Kali  (`hin_kali`)
- Ficha: `cartas/hinduismo/11_kali.md` · Entidade · 4/5 · Lendária
- Destino: `arte/hinduismo/hin_kali.png`
- Texto da carta: Despertar: 1 de dano a todas as Entidades inimigas. Sempre que uma Entidade inimiga morrer, Kali ganha +1 ATK permanente.
- Contexto: Kali ("a negra", "a do tempo") é a face mais terrível da Deusa. No Devi Mahatmya (cap. 7), quando os generais asuras Chanda e Munda avançam contra Durga, a testa da deusa escurece de cólera e dela salta Kali: pele negra, língua pendente, colar de cabeças, saia de braços cortados, espada e laço nas mãos. Ela devora elefantes, carros e cavalos, mata os dois generais e traz suas cabeças a Durga — ganhando o nome Chamunda. No capítulo seguinte, o asura Raktabija ("semente de sangue") gera um novo asura de cada gota do próprio sangue que toca o chão; o exército dos deuses se afoga em réplicas. Kali então estende a língua e bebe cada gota antes que caia — e Raktabija, exaurido, morre. […]
- Revisão anterior: **APROVADA** — Pele escura, terceiro olho, língua de fora, quatro braços com espadas curvas, caveiras e fogo de cremação.
- Prompt atual:
```prompt
1girl, solo, fierce goddess, dark blue-black skin, four arms, multiple arms, third eye, tongue out, red tongue, wild long black hair, skull necklace, golden crown, gold ornaments, red silk sari, holding curved sword, sword raised, dancing wildly, dynamic pose, mid-stride, cremation ground at night, funeral fires, smoke, saffron and blue, red fire glow, embers, glowing eyes, full body
```

#### Shiva Nataraja  (`hin_shiva_nataraja`)
- Ficha: `cartas/hinduismo/12_shiva_nataraja.md` · Entidade · 5/5 · Lendária
- Destino: `arte/hinduismo/hin_shiva_nataraja.png`
- Texto da carta: Ímpeto. Despertar: destrua uma Entidade inimiga.
- Contexto: Shiva é o terceiro da Trimurti, o deus que dissolve o universo no fim de cada ciclo para que ele possa ser criado de novo — destruição como transformação. Herda o Rudra do Rigveda (2.33), o arqueiro temível das montanhas, e nos Puranas e no Shvetashvatara Upanishad torna-se Mahadeva, o grande deus: asceta de Kailash coberto de cinzas, com a lua na cabeleira, o Ganges caindo pelos cabelos, a serpente Vasuki ao pescoço, o terceiro olho que incinera o que fixa, o tridente Trishula e o tambor damaru. Bebe o veneno Halahala que ameaçava os mundos no batimento do oceano e fica de garganta azul, Neelakantha. […]
- Revisão anterior: **REPROVADA** — Tem cerca de seis braços (o certo são quatro), as pernas viraram um bloco só e não há a pose de perna erguida nem o anel de fogo. O tambor saiu como discos pendurados.
- Prompt atual:
```prompt
1boy, solo, adult man, dancing god, blue-grey skin, four arms, third eye, long matted hair flying outward, crescent moon in hair, serpent around neck, damaru drum in upper right hand, flame in upper left hand, tiger skin loincloth, standing on right leg, left leg raised across body, dancing, ring of fire around him, circle of flames, dark cosmic void, stars, saffron and blue, fire glow, embers, rim lighting, full body
```

#### Chamas de Agni  (`hin_chamas_de_agni`)
- Ficha: `cartas/hinduismo/13_chamas_de_agni.md` · Selo
- Destino: `arte/hinduismo/hin_chamas_de_agni.png`
- Texto da carta: Quando o oponente invocar uma Entidade, ela sofre 1 de dano e a Cornucópia inimiga sofre 1.
- Contexto: Agni é o fogo e o deus do fogo, uma das três divindades centrais do Rigveda ao lado de Indra e Soma: o primeiro hino do primeiro livro (RV 1.1) começa com seu nome — "Agni eu invoco, o sacerdote posto à frente". Ele é a boca dos deuses: tudo o que se verte no fogo do sacrifício — manteiga clarificada, grãos, soma — é Agni quem leva ao céu. Tem duas cabeças (o fogo doméstico e o fogo sacrificial), sete línguas de chama, cabelos em brasa, e cavalga um carneiro. Agni é também o fogo que purifica e o que consome: é ele quem, faminto, pede a Krishna e Arjuna que lhe deem a floresta de Khandava para devorar (Mahabharata, Adi Parva) e, em troca, lhes entrega o Gandiva e o Sudarshana Chakra. […]
- Revisão anterior: **APROVADA** — Fogo saindo do altar num pátio escuro, com rachaduras de fogo no chão. Clima de armadilha.
- Prompt atual:
```prompt
no humans, sacred fire trap, flames erupting from hidden square brick altar, seven tongues of fire, living flames, fire swirling, faint face formed in the flames, fire reaching outward, burst of fire, glowing cracks in the floor, dark temple courtyard, stone floor, marigold petals scattered, ambush, hidden, trap, smoke, embers, saffron and blue, orange firelight, deep shadows, dark tone, ominous, high contrast, dramatic lighting, centered composition
```

#### Roda do Samsara  (`hin_roda_do_samsara`)
- Ficha: `cartas/hinduismo/14_roda_do_samsara.md` · Selo
- Destino: `arte/hinduismo/hin_roda_do_samsara.png`
- Texto da carta: Quando uma Entidade aliada morrer, devolva uma Entidade do seu cemitério à sua mão e compre 1 carta.
- Contexto: Samsara ("fluxo", "vagar") é o ciclo de nascimento, morte e renascimento a que todo ser está preso, movido pelo karma — o fruto inevitável das ações. A ideia aparece formulada nas Upanishads mais antigas: no Brihadaranyaka (4.4.5), "conforme age, conforme se conduz, assim o homem se torna; quem faz o bem torna-se bom, quem faz o mal torna-se mau". A Bhagavad Gita (2.22) usa a imagem que todo hindu conhece: "assim como um homem deixa as roupas gastas e veste roupas novas, a alma encarnada deixa os corpos gastos e entra em outros, novos". A roda (chakra) é o símbolo visual do ciclo — a mesma roda que está na bandeira da Índia, herdada da iconografia budista e hindu do dharma. […]
- Revisão anterior: **REPROVADA** — Não há roda. Saíram um emblema em cruz numa porta, lanternas e um círculo no chão com pseudo-glifos parecidos com letras.
- Prompt atual:
```prompt
no humans, object focus, giant carved stone wheel, ancient chariot wheel, eight spokes, stone hub, wheel standing upright, wheel fills the frame, intricate carvings, glowing golden rim, ghostly soul lights circling the wheel, lotus petals swirling, falling leaves, dark temple wall, overgrown ruins, vines, night, saffron and blue, soft golden glow, faint mist, deep shadows, dark tone, mysterious, centered composition
```

#### Lei do Karma  (`hin_lei_do_karma`)
- Ficha: `cartas/hinduismo/15_lei_do_karma.md` · Selo
- Destino: `arte/hinduismo/hin_lei_do_karma.png`
- Texto da carta: Quando uma Entidade inimiga atacar, ela sofre 3 de dano. Compre 1 carta.
- Contexto: Karma significa simplesmente "ação" — e, por extensão, a lei pela qual toda ação produz um fruto (phala) que retorna a quem a praticou, nesta vida ou em outra. Nos Vedas a palavra designa sobretudo o ato ritual; nas Upanishads passa a abarcar toda conduta e torna-se o motor do samsara. A Bhagavad Gita (2.47) dá o verso mais citado sobre o tema: "tens direito à ação, nunca a seus frutos" — o ensinamento de agir por dever, sem apego ao resultado, que Krishna chama de karma-yoga. Não há juiz na lei do karma; ela opera como a gravidade. A violência lançada volta ao violento, com a mesma medida. […]
- Revisão anterior: **REPROVADA** — Só um lótus dourado com feixes verticais. Não aparece a lâmina se quebrando ou o golpe refletido que expressa o efeito.
- Prompt atual:
```prompt
no humans, ghostly sword, sword striking a glowing lotus mandala shield, blade shattering on impact, broken blade fragments flying back, burst of light reflecting back, sparks, shockwave, golden barrier, sacred geometry, counterattack, trap, dark temple hall, stone pillars, oil lamps, saffron and blue, golden glow, deep shadows, dark tone, ominous, high contrast, dramatic lighting, centered composition
```

#### Véu de Maya  (`hin_veu_de_maya`)
- Ficha: `cartas/hinduismo/16_veu_de_maya.md` · Selo
- Destino: `arte/hinduismo/hin_veu_de_maya.png`
- Texto da carta: Quando o oponente jogar um Rito, anule-o e devolva uma Entidade inimiga à mão do dono.
- Contexto: Maya é o poder de ilusão que faz o Uno aparecer como múltiplo e o eterno como passageiro. No Rigveda a palavra ainda designa a "arte", o poder mágico dos deuses (e dos asuras) de criar formas. No Shvetashvatara Upanishad (4.10) ela já é o véu: "saiba que a natureza (prakriti) é maya, e o grande Senhor é o mestre da maya". Nos Puranas, Maya é a Shakti de Vishnu, a energia com que ele projeta e recolhe os mundos; na Bhagavad Gita (7.14), Krishna a chama de "minha maya divina, feita dos três gunas, difícil de transpor". […]
- Revisão anterior: **APROVADA** — Véu iridescente com silhueta escura e reflexo, num salão escuro com pilares.
- Prompt atual:
```prompt
no humans, object focus, shimmering translucent silk veil, veil billowing in the air, veil woven with stars, flowing fabric, ghostly silhouette dissolving behind the veil, fading into sparkles, swirling illusion, mirage, glittering particles, distorted reflections, dark palace hall, carved pillars, reflecting pool, floating lotus, saffron and blue, iridescent shimmer, soft blue haze, dim light, dark tone, mysterious, ominous, dramatic lighting, centered composition
```

#### Incêndio de Lanka  (`hin_incendio_de_lanka`)
- Ficha: `cartas/hinduismo/17_incendio_de_lanka.md` · Selo
- Destino: `arte/hinduismo/hin_incendio_de_lanka.png`
- Texto da carta: No fim do turno do oponente, 1 de dano a todas as Entidades inimigas e 1 à Cornucópia inimiga.
- Contexto: No Sundara Kanda do Ramayana, Hanuman, depois de encontrar Sita no bosque de ashoka e lhe entregar o anel de Rama, decide se deixar capturar para medir a força do inimigo e falar com Ravana cara a cara. Levado à corte como prisioneiro, fala como embaixador: pede ao rei de Lanka que devolva Sita e se poupe. Ravana, enfurecido, manda matá-lo; o irmão Vibhishana lembra que um mensageiro não se mata, e a pena vira humilhação — embrulhar a cauda do macaco em panos embebidos em óleo e atear fogo. Hanuman faz a cauda crescer, e crescer, e os rakshasas gastam quase todo o pano da cidade. […]
- Revisão anterior: **APROVADA** — Silhueta de macaco com cauda diante de palácios em chamas, em tom escuro.
- Prompt atual:
```prompt
1boy, solo, monkey man silhouette, long tail on fire, burning tail, leaping across rooftops, from behind, dynamic pose, golden city burning at night, palaces and towers in flames, golden domes, ocean in the distance, smoke, flying embers, sparks, fire spreading, ambush, chaos, saffron and blue, red fire glow, orange sky, dramatic shadows, dark tone, high contrast, wide shot, full body
```

#### Pashupatastra  (`hin_pashupatastra`)
- Ficha: `cartas/hinduismo/18_pashupatastra.md` · Selo
- Destino: `arte/hinduismo/hin_pashupatastra.png`
- Texto da carta: Quando uma Entidade inimiga atacar, destrua-a. Compre 1 carta.
- Contexto: O Pashupatastra é a arma pessoal de Shiva em sua forma de Pashupati, "senhor das criaturas": a mais destrutiva de todas as armas divinas, capaz de aniquilar a criação inteira se disparada sem alvo à altura. Pode ser lançada pela mente, pelo olhar, pela palavra ou pelo arco, e não tem contra-arma. O Mahabharata (Vana Parva, episódio Kairata) conta como Arjuna a obteve. Durante o exílio, ele sobe ao Himalaia e pratica ascese severa para agradar a Shiva. Um javali o ataca; Arjuna o flecha, mas um caçador kirata reivindica a presa, e os dois lutam — Arjuna, pela primeira vez na vida, é derrotado. O caçador então revela-se Shiva, que estava testando o herói. […]
- Revisão anterior: **REPROVADA** — Não há flecha: saiu um cálice/tocha de chama azul sobre um altar com uma cruz flor-de-lis, que é um símbolo culturalmente errado.
- Prompt atual:
```prompt
no humans, object focus, single divine arrow, long arrow, ornate golden arrowhead, feathered fletching, arrow floating horizontally, large in frame, arrow wreathed in blue-white fire, crackling blue lightning, divine weapon, hovering above stone altar, snowy mountain cave, icicles, crescent moon, dark night, trap, waiting, saffron and blue, cold glow, deep shadows, dark tone, ominous, dramatic lighting, centered composition
```

#### Om  (`hin_om`)
- Ficha: `cartas/hinduismo/19_om.md` · Rito
- Destino: `arte/hinduismo/hin_om.png`
- Texto da carta: Compre 1 carta e ganhe 1 de Fé temporária.
- Contexto: Om (Aum, ॐ) é a sílaba sagrada que abre e fecha toda recitação védica, todo mantra, toda oração hindu. É o som primordial — a vibração de que o universo emerge — e o nome sonoro de Brahman, o absoluto. O Mandukya Upanishad é inteiramente dedicado a ela: seus três sons, A-U-M, correspondem aos estados de vigília, sonho e sono profundo, e o silêncio que segue o M é o quarto estado (turiya), a consciência pura. Na Bhagavad Gita (8.13), Krishna diz que quem deixa o corpo pronunciando "Om" e lembrando-se dele alcança a meta suprema; em 9.17 ele mesmo se declara "a sílaba Om". […]
- Revisão anterior: **REPROVADA** — O sábio asceta saiu como uma menina chibi de cabelo azul. Figura errada.
- Prompt atual:
```prompt
1boy, solo, elderly ascetic sage, old man, thin, long grey beard, long hair in topknot, ash on skin, saffron robe, rudraksha prayer beads, sitting in lotus position, meditating, eyes closed, hands in mudra, serene, concentric rings of golden light radiating outward, glowing ripples, sound waves, sacred river at dawn, stone steps, mist over water, saffron and blue, golden light, sunrise, rim lighting, full body
```

#### Yajna, o Fogo Sacrificial  (`hin_yajna`)
- Ficha: `cartas/hinduismo/20_yajna.md` · Rito
- Destino: `arte/hinduismo/hin_yajna.png`
- Texto da carta: Cause 2 de dano a uma Entidade inimiga e ganhe 2 de Fé temporária.
- Contexto: O yajna é o sacrifício védico: o rito central da religião mais antiga da Índia, descrito e regulado nos quatro Vedas e nos Brahmanas. Sacerdotes acendem o fogo em altares de tijolo dispostos segundo a geometria dos Shulba Sutras, recitam hinos e vertem oblações — ghee (manteiga clarificada), grãos, leite, soma — nas chamas, enquanto Agni, o fogo, as leva aos deuses. O universo mesmo, diz o Rigveda (10.90, Purusha Sukta), nasceu de um sacrifício primordial; e os deuses dependem das oferendas dos homens tanto quanto os homens das chuvas dos deuses. […]
- Revisão anterior: **APROVADA** — Altar de fogo em santuário escuro com fogo ritual. O telhado em chamas é estranho, mas lê como fogo sagrado e ofensivo.
- Prompt atual:
```prompt
no humans, sacrificial fire, square brick fire altar, roaring flames rising high, brass ladle pouring ghee into the fire, offerings of grain and flowers, marigold garlands, brass vessels, oil lamps, fire bolt shooting forward, fire tongues, heat haze, flames lashing out, temple courtyard at night, carved stone pillars, smoke, embers, sparks, saffron and blue, gold ornaments, strong firelight, rim lighting, dramatic shadows, high contrast, centered composition
```

#### Samudra Manthan  (`hin_samudra_manthan`)
- Ficha: `cartas/hinduismo/21_samudra_manthan.md` · Rito
- Destino: `arte/hinduismo/hin_samudra_manthan.png`
- Texto da carta: Compre 2 cartas, ganhe 2 de Fé temporária e cure 2 da sua Cornucópia.
- Contexto: O Samudra Manthan, batimento do oceano de leite, é um dos episódios mais contados dos Puranas (Bhagavata 8.6–12, Vishnu Purana 1.9, Mahabharata Adi Parva). Os devas, enfraquecidos por uma maldição, aceitam o conselho de Vishnu: unir-se aos asuras para bater o oceano cósmico e extrair dele a amrita, o néctar da imortalidade. Arrancam o monte Mandara para servir de batedor, Vishnu toma a forma da tartaruga Kurma para sustentá-lo, e a serpente Vasuki vira a corda — devas na cauda, asuras na cabeça, engolindo o veneno que ela exala. Do oceano batido sai primeiro o Halahala, veneno capaz de destruir os mundos; Shiva o bebe e Parvati o detém na garganta, que fica azul (Neelakantha). […]
- Revisão anterior: **REPROVADA** — Ficou ilegível: uma cúpula dourada (parece água-viva/cogumelo) sobre uma coluna. Não se lê a serpente enrolada na montanha nem o batimento do oceano.
- Prompt atual:
```prompt
no humans, wide shot, tall rocky mountain rising from the ocean, giant serpent coiled around the mountain, serpent wrapped many times, serpent stretched taut to both sides, giant turtle beneath the mountain, churning milky white ocean, swirling foam, whirlpool, splashing waves, golden pot of nectar rising from the waves, night sky, full moon, stars, saffron and blue, golden glow, moonlight, rim lighting, epic scale, dramatic lighting
```

#### Brahmastra  (`hin_brahmastra`)
- Ficha: `cartas/hinduismo/22_brahmastra.md` · Rito
- Destino: `arte/hinduismo/hin_brahmastra.png`
- Texto da carta: Destrua uma Entidade inimiga.
- Contexto: O Brahmastra é a arma de Brahma, o criador — a mais temida das astras (armas invocadas por mantra) das epopeias. Não é um objeto: é um mantra que se infunde em qualquer flecha ou mesmo numa folha de grama, e que só se aprende de um mestre após longa disciplina. Uma vez disparada, não pode ser retirada; só outro Brahmastra a neutraliza, e onde ela cai a terra fica estéril por gerações. No Ramayana, Rama a recebe do sábio Agastya e com ela, no último dia da guerra, mata Ravana — a flecha de Brahma atravessa o peito do rei de Lanka e volta à aljava. No Mahabharata, Drona a ensina a Arjuna e a Ashwatthama; Karna a aprende de Parashurama, mas é amaldiçoado a esquecê-la na hora decisiva. […]
- Revisão anterior: **APROVADA** — Raio/flecha de fogo caindo do céu, explosão e chão rachado.
- Prompt atual:
```prompt
no humans, divine arrow of blinding fire, flaming arrow streaking across the sky, glowing arrowhead, trail of golden fire, arrow diving down, impact explosion on the ground, pillar of fire, column of smoke, shockwave, flying debris, cracked earth, scorched ground, barren battlefield, dark storm clouds, ash falling, saffron and blue, blinding white-gold light, embers, speed lines, dramatic lighting, high contrast, rim lighting, epic scale, wide shot
```

#### Descida do Avatar  (`hin_descida_do_avatar`)
- Ficha: `cartas/hinduismo/23_descida_do_avatar.md` · Rito
- Destino: `arte/hinduismo/hin_descida_do_avatar.png`
- Texto da carta: Reviva uma Entidade do seu cemitério para o campo.
- Contexto: *Avatara* significa literalmente "descida": o deus que desce ao mundo numa forma — peixe, tartaruga, javali, homem-leão, anão, guerreiro, príncipe, pastor — para restaurar o que se perdeu. O princípio está formulado na Bhagavad Gita (4.7–8), na voz de Krishna: "Sempre que o dharma declina e o adharma se levanta, ó Bharata, eu me manifesto. Para proteger os bons, destruir os maus e restabelecer o dharma, eu nasço era após era." A lista dos dez avatares (Dashavatara) se fixa nos Puranas — Bhagavata 1.3 enumera mais de vinte manifestações antes de dizer que "as encarnações do Senhor são incontáveis, como os riachos que nascem de um lago inesgotável". […]
- Revisão anterior: **REPROVADA** — Tem seis ou mais braços (Vishnu tem quatro), faltam a concha e o disco, e o rosto é chibi/feminino.
- Prompt atual:
```prompt
1boy, solo, adult man, realistic proportions, blue skin, four arms, upper right hand holding golden discus, upper left hand holding conch shell, lower right hand holding mace, lower left hand holding lotus, tall golden crown, gold ornaments, yellow silk dhoti, serene expression, descending from the sky, floating, column of golden light, parting clouds, halo, sacred river below, saffron and blue, god rays, rim lighting, full body
```

#### Vishvarupa, a Forma Universal  (`hin_vishvarupa`)
- Ficha: `cartas/hinduismo/24_vishvarupa.md` · Rito
- Destino: `arte/hinduismo/hin_vishvarupa.png`
- Texto da carta: Uma Entidade aliada passa a ter ATK 6 e Vida 6 e ganha Ímpeto.
- Contexto: No capítulo 11 da Bhagavad Gita, Arjuna, depois de ouvir Krishna explicar que ele é a origem e o fim de todas as coisas, pede para ver essa forma. Krishna lhe dá um olho divino, e Arjuna vê a Vishvarupa — a forma universal: incontáveis bocas e olhos, ornamentos e armas erguidas, sóis a arder ao mesmo tempo, todos os deuses e todos os seres contidos num só corpo sem começo, meio ou fim. Vê os guerreiros dos dois exércitos — Bhishma, Drona, Karna, os Kauravas — já entrando nas bocas em chamas do deus. Aterrorizado, pergunta quem é aquele, e a resposta é o verso mais lembrado do capítulo: "Eu sou o Tempo, destruidor dos mundos, que vem consumir todos os seres" (BG 11.32). […]
- Revisão anterior: **APROVADA** — Gigante cósmico azul de muitos braços, coroado e flamejante, acima das nuvens. Rosto simplificado, mas legível.
- Prompt atual:
```prompt
1boy, solo, cosmic giant, colossal divine figure, multiple heads, many arms, multiple arms, holding weapons, blue skin, body filled with stars and galaxies, golden crown, gold ornaments, radiant like a thousand suns, flaming mouths, glowing eyes, towering above mountains, arms spread, above the clouds, starry void, nebula, cosmic, saffron and blue, blinding golden light, rim lighting, epic scale, from below, full body
```

#### Tandava  (`hin_tandava`)
- Ficha: `cartas/hinduismo/25_tandava.md` · Rito
- Destino: `arte/hinduismo/hin_tandava.png`
- Texto da carta: 2 de dano a todas as Entidades inimigas e 3 de dano à Cornucópia inimiga.
- Contexto: Tandava é a dança cósmica de Shiva — nome derivado de Tandu, o servo a quem Shiva a ensinou e que a transmitiu ao sábio Bharata, autor do Natya Shastra, tratado fundador da dança e do teatro indianos. Há duas faces: o Ananda Tandava, a dança do êxtase, em que Shiva, como Nataraja, sustenta o ritmo do universo dentro do círculo de fogo; e o Rudra Tandava, a dança da fúria, em que o mesmo ritmo acelera até desfazer a criação no fim do ciclo (pralaya). […]
- Revisão anterior: **APROVADA** — Silhueta escura de muitos braços com tridente, tambor, olhos brilhantes e fogo de destruição.
- Prompt atual:
```prompt
1boy, solo, dark silhouette of dancing god, backlit, four arms, multiple arms, wild loose hair flying, glowing third eye, holding trident, holding small hourglass drum, serpent around neck, stomping foot, dynamic pose, ground cracking, shockwave, flying rocks, cosmic destruction, falling stars, burning sky, crumbling mountains, saffron and blue, red fire glow, embers, from below, wide shot, full body
```

#### Vajra  (`hin_vajra`)
- Ficha: `cartas/hinduismo/26_vajra.md` · Relíquia
- Destino: `arte/hinduismo/hin_vajra.png`
- Texto da carta: Portadora: +2 ATK. Ao equipar, causa 2 de dano a uma Entidade inimiga.
- Contexto: O Vajra ("raio", "diamante") é a arma de Indra, rei dos devas e deus da tempestade — o deus mais invocado do Rigveda, com cerca de 250 hinos. O hino 1.32 é o mais célebre: Indra, embriagado de soma, ergue o vajra forjado por Tvashtar e mata Vritra, a serpente-dragão que represava as águas do mundo; os rios rompem como vacas soltas do curral e o céu e a terra tremem. O vajra é a força do trovão em forma de arma: a cabeça de raios cruzados, dura como o diamante, que nenhuma defesa resiste. […]
- Revisão anterior: **REPROVADA** — O objeto é pequeno, cortado na borda inferior e ofuscado pelos raios. Uma Relíquia precisa do objeto em foco, com as duas pontas visíveis.
- Prompt atual:
```prompt
no humans, object focus, close-up, vajra, double-ended thunderbolt scepter, curved golden prongs at both ends, central sphere grip, whole object visible, large in frame, floating horizontally, glowing diamond core, crackling lightning around it, electricity arcing, divine weapon, storm clouds, rain, dark sky, saffron and blue, electric blue lightning, golden glow, rim lighting, high contrast, centered composition
```

#### Sudarshana Chakra  (`hin_sudarshana_chakra`)
- Ficha: `cartas/hinduismo/27_sudarshana_chakra.md` · Relíquia
- Destino: `arte/hinduismo/hin_sudarshana_chakra.png`
- Texto da carta: Portadora: +2 ATK / +1 Vida e Ímpeto. Quando a portadora atacar, causa 1 de dano a uma Entidade inimiga.
- Contexto: O Sudarshana Chakra ("disco de boa visão") é a arma de Vishnu: um disco de 108 dentes serrilhados que gira no indicador de sua mão direita, dispara à velocidade do pensamento, destrói o alvo e volta à mão. Nos bronzes e pinturas, aparece com chamas ao redor e, em templos do sul, é adorado como uma divindade própria (Chakrattalvar). […]
- Revisão anterior: **REPROVADA** — Lê como braseiro/tocha com anel de fogo. Não há disco serrilhado visível.
- Prompt atual:
```prompt
no humans, object focus, close-up, golden spinning discus, flat disc facing viewer, round disc with serrated teeth around the edge, ornate golden hub, many spokes, ring of fire on the rim, spinning, motion lines, sparks flying, floating in the air, divine weapon, large in frame, dark night sky, temple spire silhouette, saffron and blue, orange fire glow, golden light, embers, rim lighting, high contrast, centered composition
```

#### Gandiva  (`hin_gandiva`)
- Ficha: `cartas/hinduismo/28_gandiva.md` · Relíquia
- Destino: `arte/hinduismo/hin_gandiva.png`
- Texto da carta: Portadora: +3 ATK / +1 Vida. Quando a portadora atacar, causa 1 de dano a todas as Entidades inimigas.
- Contexto: O Gandiva é o arco de Arjuna, o mais famoso do Mahabharata. Feito por Brahma, passou por Prajapati, Indra, Soma e Varuna até que, no episódio do incêndio de Khandava (Adi Parva), Agni, querendo devorar a floresta protegida por Indra, pede ajuda a Krishna e Arjuna; para que o herói possa enfrentar a chuva de Indra, Varuna lhe entrega o Gandiva, duas aljavas inesgotáveis e um carro com cavalos brancos. O arco é indestrutível e sua corda, ao vibrar, soa como o trovão; as aljavas que o acompanham nunca se esvaziam. Com o Gandiva, Arjuna vence os deuses em Khandava, derrota sozinho o exército Kaurava em Virata, mata Jayadratha, Karna e milhares de guerreiros ao longo dos dezoito dias. […]
- Revisão anterior: **REPROVADA** — Não há arco: saiu uma criatura com chifres sob raios.
- Prompt atual:
```prompt
no humans, object focus, close-up, divine longbow, huge recurved bow, bow of dark wood and gold, ornate golden tips, glowing bowstring, whole bow visible, floating upright, large in frame, quiver full of arrows beside it, glowing aura, rain of glowing arrows in background, dark storm sky, faint lightning, saffron and blue, golden glow, rim lighting, dramatic lighting, high contrast, centered composition
```

#### Trishula  (`hin_trishula`)
- Ficha: `cartas/hinduismo/29_trishula.md` · Relíquia
- Destino: `arte/hinduismo/hin_trishula.png`
- Texto da carta: Portadora: +3 ATK / +1 Vida. Quando atacar, 1 de dano a uma Entidade inimiga. Quando morrer, 2 de dano a todas as Entidades inimigas.
- Contexto: O Trishula ("três pontas") é o tridente de Shiva, a arma que o identifica em toda imagem — ao lado do damaru, o tambor em forma de ampulheta que costuma estar amarrado ao cabo. As três pontas foram lidas de muitas maneiras: os três gunas (sattva, rajas, tamas) que compõem a natureza; os três tempos (passado, presente, futuro); as três funções de criação, preservação e destruição; os três canais sutis do yoga (ida, pingala, sushumna), com o cabo como a coluna. É também a arma de Durga, que a recebe de Shiva no Devi Mahatmya e com ela atravessa Mahishasura. […]
- Revisão anterior: **REPROVADA** — O objeto central virou uma ampulheta ("hourglass drum" interpretado literalmente), e os tridentes estão pequenos e espalhados no fundo. O tridente não está em foco.
- Prompt atual:
```prompt
no humans, object focus, close-up, single large trident, three-pronged trident, silver blades, long shaft, large in frame, planted upright in rock, small damaru drum tied below the blades, saffron cloth ribbon, glowing blades, divine weapon, shockwave of light from the base, cracked rock, snowy mountain peak, crescent moon, night sky, stars, saffron and blue, blue-white glow, rim lighting, high contrast, centered composition
```

### Bruxaria — 25 cartas

#### Sapo Familiar  (`bru_sapo_familiar`)
- Ficha: `cartas/bruxaria/01_sapo_familiar.md` · Entidade · 0/1
- Destino: `arte/bruxaria/bru_sapo_familiar.png`
- Texto da carta: Último Sopro: uma Entidade inimiga à escolha perde 1 ATK e 1 Vida permanentemente.
- Contexto: Nos processos de Zugarramurdi (Navarra, 1609–1610) os acusados descreviam sapos vestidos com roupinhas de pano, guardados em casa e alimentados pelas bruxas, que os levavam ao *akelarre* e deles extraíam venenos. A imagem é tão recorrente nas confissões que o inquisidor Alonso de Salazar y Frías, ao reexaminar os casos, usou a falta de qualquer sapo apreendido como um dos argumentos de que tudo era fabricado sob pressão (Henningsen, *The Witches' Advocate*, 1980). […]
- Revisão anterior: **REPROVADA** — Figura errada: saiu um humanoide com chapéu de cogumelo, não um sapo.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_sapo_familiar_a.png`, `arte/bruxaria/_candidatas/bru_sapo_familiar_b.png`
- Prompt atual:
```prompt
no humans, animal focus, single large warty brown toad, realistic toad anatomy, wide flat body, four short legs, webbed feet, no hat, no mushroom, tiny tattered cloth vest on its back, bulging glowing green eyes, puffed throat sac, green poison dripping from warts, slimy skin, sitting on a low wooden stool, dark witch's cottage interior, clay bowl of milk on the floor, dried herbs hanging, single candle beside it, cobwebs, purple and green, green poison glow, candlelight, rim lighting, dark atmosphere, full body
```

#### Gato Preto  (`bru_gato_preto`)
- Ficha: `cartas/bruxaria/02_gato_preto.md` · Entidade · 1/1
- Destino: `arte/bruxaria/bru_gato_preto.png`
- Texto da carta: Furtivo. Renascer. *(Sete vidas: quando morre, volta à sua mão uma vez.)*
- Contexto: O gato preto é o familiar por excelência da bruxaria insular. No primeiro grande julgamento inglês, em Chelmsford (1566), Elizabeth Francis confessou ter recebido da avó um gato malhado chamado "Sathan", que alimentava com pão, leite e gotas do próprio sangue, e que lhe trazia ovelhas e maridos em troca. A partir daí os tribunais ingleses procuraram sistematicamente o animal doméstico da acusada como prova do pacto — o familiar como pequeno demônio em forma de bicho. No continente a associação é mais antiga e vem de cima: a bula *Vox in Rama* (1233), de Gregório IX, descreve hereges renanos beijando um gato preto durante seus ritos, e já no séc. […]
- Revisão anterior: **APROVADA** — Gato preto de olhos amarelos, aura roxa espectral, cemitério e lua crescente.
- Prompt atual:
```prompt
no humans, black cat, sleek black fur, glowing yellow eyes, arched back, raised fur, slinking low, tail raised, claws out, stepping along a crooked wooden fence, faint purple ghostly aura around the cat, village rooftops, chimneys, old graveyard behind, crooked gravestones, crescent moon, drifting mist, bare branches, night sky, stars, purple and green, moonlight, rim lighting, mysterious, dark atmosphere, full body
```

#### Corvo Agourento  (`bru_corvo_agourento`)
- Ficha: `cartas/bruxaria/03_corvo_agourento.md` · Entidade · 1/2
- Destino: `arte/bruxaria/bru_corvo_agourento.png`
- Texto da carta: Despertar: o oponente descarta 1 carta aleatória da mão.
- Contexto: Em toda a Europa o corvo e a gralha são aves de agouro: comem os mortos nos campos de batalha, gritam sobre as casas onde alguém vai morrer e repetem palavras humanas. Na Irlanda são a forma da Morrigan e de Badb, a "corvo-de-batalha", que pousa no ombro de Cú Chulainn morto para que seus inimigos saibam que ele já não é perigoso (*Aided Con Culainn*, "A morte de Cú Chulainn", no ciclo do Ulster). No Norte, Huginn e Muninn — Pensamento e Memória — voam o mundo todo e voltam a sussurrar no ouvido de Odin (*Grímnismál* 20). […]
- Revisão anterior: **APROVADA** — Corvo de asas abertas sob a lua cheia, sombrio e legível. A chaminé virou torre e falta o bico com o objeto roubado (detalhe menor).
- Prompt atual:
```prompt
no humans, large black raven, glossy black feathers, spread wings, landing on a crooked chimney, head tilted, open beak, glowing purple eye, stolen shiny trinket clutched in its beak, thatched cottage roof, moss, dead tree branches, full moon, drifting clouds, mist, night sky, bats in the distance, feathers falling, purple and green, moonlight, rim lighting, ominous, dark atmosphere, detailed feathers, full body
```

#### Strega de Benevento  (`bru_strega_de_benevento`)
- Ficha: `cartas/bruxaria/04_strega_de_benevento.md` · Entidade · 2/3
- Destino: `arte/bruxaria/bru_strega_de_benevento.png`
- Texto da carta: Despertar: invoque uma Strix 1/1 (coruja familiar).
- Contexto: *Strega*, bruxa em italiano, vem do latim *strix*, a coruja-das-torres. Para os romanos a *strix* era um pássaro noturno que entrava pelas janelas e sugava o sangue e as entranhas dos recém-nascidos; Ovídio dá o remédio — ramos de medronheiro e espinheiro na porta, entranhas de leitoa em troca (*Fastos* VI.131–168) — e Petrônio conta uma *striga* roubando o corpo de um menino (*Satyricon* 63). Em Apuleio (*Asno de Ouro* III.21) a bruxa Pânfila unta-se, bate os braços e vira coruja: a bruxa e a ave são a mesma coisa. Benevento, na Campânia, é a capital italiana das streghe. […]
- Revisão anterior: **REPROVADA** — Não há coruja: as asas dela grudaram na bruxa, que virou uma mulher alada. A nogueira está genérica e falta a serpente.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_strega_de_benevento_a.png`, `arte/bruxaria/_candidatas/bru_strega_de_benevento_b.png`
- Prompt atual:
```prompt
1girl, solo, mature woman, italian witch, long dark wavy hair, dark red dress, black lace shawl, gold earrings, knowing smile, human arms only, no wings on her back, left arm extended forward, large barn owl perched on her forearm, white heart-shaped owl face, owl wings spread, giant gnarled walnut tree behind her, twisted roots, serpent coiled on the roots, river in the background, fireflies, night, purple and green, moonlight, rim lighting, full body
```

#### Benandante  (`bru_benandante`)
- Ficha: `cartas/bruxaria/05_benandante.md` · Entidade · 2/3
- Destino: `arte/bruxaria/bru_benandante.png`
- Texto da carta: Despertar: congele uma Entidade inimiga à escolha (ela não ataca no próximo turno).
- Contexto: Os *benandanti* ("os que andam bem") do Friul, nordeste da Itália, são o achado de Carlo Ginzburg em *Os Andarilhos do Bem* (1966). Entre 1575 e 1675 dezenas de camponeses contaram à Inquisição de Aquileia e Concórdia a mesma história: nascidos "com a camisa" (a membrana amniótica), eram chamados quatro vezes por ano, nas noites das Têmporas, a sair do corpo em espírito — em forma de rato ou borboleta, ou montados em lebres e gatos — para lutar nos campos de Josafat contra os bruxos (*malandanti*). Os benandanti iam armados de ramos de funcho; os bruxos, de canas de sorgo. Se os benandanti vencessem, a colheita seria farta; se perdessem, viria a fome. […]
- Revisão anterior: **REPROVADA** — Segura uma espada no lugar do talo de funcho (atributo-chave). Não é espectral, falta o inimigo caído, rosto quase chibi.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_benandante_a.png`, `arte/bruxaria/_candidatas/bru_benandante_b.png`
- Prompt atual:
```prompt
1boy, solo, adult peasant man, realistic proportions, short brown hair, white linen shirt, brown trousers, rope belt, barefoot, gripping a long green fennel stalk with feathery leaves and yellow flower umbels, no sword, no metal, swinging the fennel stalk like a club, battle stance, translucent ghostly body, pale spectral glow, shadowy witch figure fallen at his feet, broken sorghum cane, night wheat field, fog, stars, purple and green, moonlight, rim lighting, dynamic pose, full body
```

#### Circe  (`bru_circe`)
- Ficha: `cartas/bruxaria/06_circe.md` · Entidade · 3/3
- Destino: `arte/bruxaria/bru_circe.png`
- Texto da carta: Despertar: uma Entidade inimiga à escolha vira porco — seu ATK e sua Vida passam a ser 1/1.
- Contexto: Circe (*Kirke*), filha de Hélio e da oceânide Perse, vive na ilha de Eeia entre lobos e leões que já foram homens. Em *Odisseia* X, os companheiros de Odisseu bebem de sua taça de queijo, farinha, mel e "drogas funestas" (*pharmaka lygra*), ela os toca com a varinha e eles ganham cabeça, voz e cerdas de porco — mas conservam a mente humana. Odisseu resiste graças à erva *moly* dada por Hermes, obriga-a a desfazer o encanto e fica um ano em sua cama; é ela quem lhe ensina o caminho ao Hades e o modo de passar pelas Sereias e por Cila. […]
- Revisão anterior: **REPROVADA** — Faltam o porco (núcleo da mecânica) e a taça. Roupa com fenda muito reveladora.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_circe_a.png`, `arte/bruxaria/_candidatas/bru_circe_b.png`
- Prompt atual:
```prompt
1girl, solo, sorceress goddess, adult woman, long auburn hair, golden circlet, long purple greek chiton covering her legs, gold jewelry, cruel smile, golden goblet held up in one hand, slender wand pointing down in the other hand, small pink pig at her feet looking up in fear, wolf and lion lying behind her, marble columns, night sea behind, glowing wand tip, purple and green, moonlight, candlelight, rim lighting, elegant, full body
```

#### Medeia, a Envenenadora  (`bru_medeia`)
- Ficha: `cartas/bruxaria/07_medeia.md` · Entidade · 3/4
- Destino: `arte/bruxaria/bru_medeia.png`
- Texto da carta: Despertar: uma Entidade inimiga à escolha perde 2 ATK permanentemente.
- Contexto: Medeia, princesa da Cólquida, é neta de Hélio, sobrinha de Circe e sacerdotisa de Hécate. Em Apolônio de Rodes (*Argonáuticas* III) ela se apaixona por Jasão e lhe dá o unguento de Prometeu, que o torna invulnerável ao fogo dos touros de bronze; no livro IV é ela quem adormece com cantos e drogas o dragão guardião do Velo de Ouro e quem arma a emboscada em que Jasão mata seu irmão Apsirto. Em Apolodoro (*Biblioteca* I.9.24) e Ovídio (*Tristia* III.9) a versão é mais crua: Medeia mesma esquarteja o irmão e espalha os pedaços para atrasar a perseguição do pai. É a feiticeira que trai a casa pelo estrangeiro — e será traída por ele. […]
- Revisão anterior: **REPROVADA** — Falta o frasco de veneno e o tosão. Proporções infantis/chibi, galho dourado solto flutuando.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_medeia_a.png`, `arte/bruxaria/_candidatas/bru_medeia_b.png`
- Prompt atual:
```prompt
1girl, solo, adult woman, tall sorceress, realistic proportions, long black hair, gold diadem, dark green robe, gold bracelets, cold stare, outstretched hand holding a small glass vial, green poison dripping from the vial, bundle of dark herbs in other hand, huge serpent dragon coiled asleep behind her, golden fleece hanging on an oak branch, night grove, fog, purple and green, green poison glow, moonlight, rim lighting, menacing, full body
```

#### A Bruxa de Endor  (`bru_bruxa_de_endor`)
- Ficha: `cartas/bruxaria/08_bruxa_de_endor.md` · Entidade · 2/4
- Destino: `arte/bruxaria/bru_bruxa_de_endor.png`
- Texto da carta: Furtivo. Despertar: devolva uma Entidade do seu cemitério à sua mão.
- Contexto: Em 1 Samuel 28, na véspera da batalha de Gilboa contra os filisteus, o rei Saul — que havia expulsado de Israel os necromantes e adivinhos — disfarça-se e vai de noite a Endor consultar "uma mulher que tem um *ôb*" (um espírito familiar, ou o próprio ofício de evocar os mortos). Ela teme uma armadilha; ele jura por Yahweh que nada lhe acontecerá. Ela faz subir da terra um ancião envolto num manto: é Samuel, que pergunta por que o perturbaram e anuncia que Saul e seus filhos morrerão no dia seguinte. A mulher, vendo o rei prostrado, mata um bezerro e assa pães para que ele coma antes de partir. […]
- Revisão anterior: **REPROVADA** — Falta o espírito de Samuel se erguendo (atributo-chave e mecânica de devolver do cemitério). Só há uma chama-fantasma na mão.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_bruxa_de_endor_a.png`, `arte/bruxaria/_candidatas/bru_bruxa_de_endor_b.png`
- Prompt atual:
```prompt
1girl, solo, mature woman, necromancer witch, hooded dark cloak, grey streaked hair, wrinkles, kneeling on the floor, both arms raised, translucent ghost of an old bearded man in a long robe rising from the ground in front of her, ghost larger than her, pale blue spectral glow, swirling spirit mist, dark cave dwelling, small fire pit, clay pots, purple and green, candlelight, rim lighting, eerie, dark atmosphere, full body
```

#### Baba Yaga  (`bru_baba_yaga`)
- Ficha: `cartas/bruxaria/09_baba_yaga.md` · Entidade · 3/5
- Destino: `arte/bruxaria/bru_baba_yaga.png`
- Texto da carta: Sacrifício 1. Despertar: devore uma Entidade inimiga à escolha (destrua-a).
- Contexto: Baba Yaga é a velha da floresta dos contos russos e eslavos: nariz que toca o teto, perna de osso, dentes de ferro. Mora numa *izbá* que gira sobre pés de galinha e só se abre quando se diz "cabaninha, cabaninha, fica de costas para a floresta e de frente para mim"; a cerca é de ossos humanos e os postes têm caveiras cujos olhos brilham à noite. Voa num pilão, remando com o socador e apagando o rastro com a vassoura. Fareja o visitante — "cheira a russo aqui!" — e come quem não cumpre suas tarefas. […]
- Revisão anterior: **REPROVADA** — Ficou jovem e quase chibi. Sem pilão gigante (almofariz), sem cabana em pés de galinha, não está voando.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_baba_yaga_a.png`, `arte/bruxaria/_candidatas/bru_baba_yaga_b.png`
- Prompt atual:
```prompt
1girl, solo, very old crone, hag, deeply wrinkled face, long hooked nose, wild grey hair, headscarf, iron teeth, patched peasant dress, sitting inside a giant wooden mortar, mortar flying in the air, holding a large pestle like an oar, swooping over a dark pine forest, wooden hut standing on two giant chicken legs below, fence of bones with glowing skulls, full moon, purple and green, moonlight, glowing eyes, rim lighting, dark atmosphere, dynamic pose, full body
```

#### Cerridwen, Senhora do Caldeirão  (`bru_cerridwen`)
- Ficha: `cartas/bruxaria/10_cerridwen.md` · Entidade · 4/4
- Destino: `arte/bruxaria/bru_cerridwen.png`
- Texto da carta: Despertar: compre 2 cartas.
- Contexto: Cerridwen é a feiticeira do *Hanes Taliesin* ("História de Taliesin"), conto galês posto por escrito no séc. XVI por Elis Gruffydd a partir de tradição bem mais antiga. Vive no lago Bala com o marido Tegid Foel e dois filhos: a bela Creirwy e o feioso Morfran, apelidado Afagddu ("Trevas Totais"). Para compensar o filho, decide fervê-lo um caldeirão de inspiração e ciência (*Awen*) que precisa cozinhar por um ano e um dia; o cego Morda cuida do fogo e o menino Gwion Bach mexe o caldo. No último dia três gotas escaldantes saltam na mão de Gwion, que as leva à boca — e recebe toda a sabedoria destinada a Afagddu. O resto do caldeirão vira veneno e racha o vaso. […]
- Revisão anterior: **APROVADA** — Mexe o caldeirão à beira do lago, com robe verde de capuz e fogo. Há duas pás duplicadas e faltam as três gotas (detalhes menores).
- Prompt atual:
```prompt
1girl, solo, mature woman, welsh sorceress, long dark braided hair, deep green hooded robe, silver torc, serious focused face, stirring a huge black iron cauldron with a wooden paddle, three glowing golden drops leaping from the brew, hand cupped to catch them, bubbling green steam, fire under the cauldron, lakeside at night, still water, reeds, dark mountains, stars, fireflies, mist over the water, purple and green, green glow from the cauldron, moonlight, rim lighting, detailed background, full body
```

#### A Morrigan  (`bru_a_morrigan`)
- Ficha: `cartas/bruxaria/11_a_morrigan.md` · Entidade · 5/5 · Lendária
- Destino: `arte/bruxaria/bru_a_morrigan.png`
- Texto da carta: Ímpeto. Sempre que uma Entidade — aliada ou inimiga — morrer, invoque um Corvo 1/1.
- Contexto: *An Mórrígan*, "a Grande Rainha" (ou "Rainha dos Fantasmas"), é a deusa irlandesa da guerra, da profecia e da soberania da terra. Aparece quase sempre como uma de três irmãs — com Badb ("corvo-de-batalha") e Macha, ou Nemain — e por isso é também "as Morrígna". No *Cath Maige Tuired* ("A Segunda Batalha de Mag Tuired") ela se une ao Dagda no Samhain, à beira de um rio, com um pé em cada margem, e promete a vitória aos Tuatha Dé Danann; depois da batalha profetiza o fim dos tempos. […]
- Revisão anterior: **APROVADA** — Guerreira de lança, manto de penas pretas e lua vermelha, carga dinâmica. Os corvos aparecem pequenos no céu.
- Prompt atual:
```prompt
1girl, solo, fierce war goddess, long wild black hair, black feathered cloak, dark leather armor, bronze torc, war paint, raising a spear, battle cry, charging forward, crows erupting from her cloak, flock of crows in the sky, misty river ford, shallow water, fallen weapons on the ground, broken shields, standing stones, red moon, night sky, purple and green, moonlight, rim lighting, dramatic, dynamic pose, full body
```

#### Hécate, Senhora das Encruzilhadas  (`bru_hecate`)
- Ficha: `cartas/bruxaria/12_hecate.md` · Entidade · 5/7 · Lendária
- Destino: `arte/bruxaria/bru_hecate.png`
- Texto da carta: Sacrifício 1. Despertar: todas as Entidades inimigas perdem 2 ATK e 2 Vida permanentemente.
- Contexto: Hécate (*Hekátē*) é a deusa grega das encruzilhadas, da noite, dos fantasmas, dos cães e da magia. Hesíodo lhe dedica o hino mais longo da *Teogonia* (411–452): filha dos titãs Perses e Astéria, Zeus a honrou acima de todos e lhe deu parte na terra, no mar e no céu estrelado; concede vitória nas assembleias, na guerra, nos jogos, na pesca e na criação de gado, e é a ama de todos os jovens. No *Hino Homérico a Deméter* é ela quem, com a tocha na mão, ouve o grito de Perséfone raptada e acompanha a mãe na busca — por isso é companheira da rainha do Hades. […]
- Revisão anterior: **REPROVADA** — Tem um rosto só (as três faces são o atributo-chave). As tochas estão em postes e não nas mãos, há só um cão e o rosto é infantil.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_hecate_a.png`, `arte/bruxaria/_candidatas/bru_hecate_b.png`
- Prompt atual:
```prompt
1girl, solo, goddess with three faces, three heads on one body, one face front one face left one face right, adult woman, tall imposing, long dark hair, black and purple robes, silver crescent crown, holding a burning torch in each hand, iron key on her belt, two black dogs at her feet, standing where three dirt roads meet, offering bowl on the ground, dead trees, dark moon, mist, purple and green, torch firelight, rim lighting, imposing, full body
```

#### Mau-Olhado  (`bru_mau_olhado`)
- Ficha: `cartas/bruxaria/13_mau_olhado.md` · Selo
- Destino: `arte/bruxaria/bru_mau_olhado.png`
- Texto da carta: Quando o oponente invocar uma Entidade, ela fica congelada e perde 1 ATK e 1 Vida permanentemente.
- Contexto: O mau-olhado (*fascinatio*, *malocchio*, *ayin ha-ra*) é a crença mediterrânea e oriental de que um olhar — em especial o olhar da inveja — pode ferir, secar o leite da vaca, murchar a criança, quebrar a sorte. Plutarco dedica-lhe um debate inteiro (*Quaestiones Convivales* V.7), tentando explicar como partículas saídas dos olhos atingem a vítima; Plínio (*História Natural* VII.16–18) fala de famílias africanas que matavam com o olhar e com o elogio. É um poder tão difundido que raramente é "bruxaria" formal: qualquer um pode ter o olho-gordo sem saber. […]
- Revisão anterior: **REPROVADA** — Figura errada: sai uma menina-fantasma chibi com chifres numa porta. Não há olho gigante nem cabra congelada.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_mau_olhado_a.png`, `arte/bruxaria/_candidatas/bru_mau_olhado_b.png`
- Prompt atual:
```prompt
no humans, no girl, giant floating eye in the night sky, single huge veined eyeball, purple iris, slit pupil, staring down, dark smoke and shadow tendrils around the eye, small white goat below covered in frost, ice crystals, frozen breath, withered grass, dark village street, cobblestones, garlic and red ribbon on a doorway, closed shutters, fog, purple and green, eerie glow, moonlight, rim lighting, ominous, dark atmosphere
```

#### Círculo de Sal  (`bru_circulo_de_sal`)
- Ficha: `cartas/bruxaria/14_circulo_de_sal.md` · Selo
- Destino: `arte/bruxaria/bru_circulo_de_sal.png`
- Texto da carta: Quando uma Entidade inimiga atacar, devolva-a à mão do dono; o oponente descarta 1 carta aleatória e você compra 1.
- Contexto: O sal é o purificador universal da magia popular europeia: jogado por cima do ombro esquerdo contra o azar de derrubá-lo, posto no berço e no bolso do recém-nascido antes do batismo, misturado à água benta na liturgia (que o exorciza expressamente, "para que o inimigo fuja de onde for aspergido"), espalhado na soleira para que a bruxa não entre. É o que não apodrece e por isso o que o apodrecido — o morto, o demônio, o malefício — não cruza. […]
- Revisão anterior: **REPROVADA** — Não há círculo de sal nem a mão do monstro repelida. A cena é só um caldeirão pendurado.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_circulo_de_sal_a.png`, `arte/bruxaria/_candidatas/bru_circulo_de_sal_b.png`
- Prompt atual:
```prompt
no humans, high angle, wide circle of white salt poured on a dark wooden floor, glowing salt ring, pale blue barrier light rising from the ring, sparks, shadowy black clawed hand reaching in and recoiling from the barrier, dark smoke, candles at the edge of the circle, scattered salt grains, no cauldron, dark cottage interior, wooden beams, herbs hanging, purple and green, candlelight, moonlight through the window, rim lighting, magic trap, dark atmosphere
```

#### Garrafa de Bruxa  (`bru_garrafa_de_bruxa`)
- Ficha: `cartas/bruxaria/15_garrafa_de_bruxa.md` · Selo
- Destino: `arte/bruxaria/bru_garrafa_de_bruxa.png`
- Texto da carta: Quando o oponente jogar um Rito, anule-o; o oponente descarta 1 carta aleatória.
- Contexto: A garrafa de bruxa (*witch bottle*) é um dos poucos objetos de magia popular que a arqueologia encontra em quantidade: jarras de grés de barba (tipo *Bellarmine*, importadas da Renânia), do séc. XVII em diante, enterradas de boca para baixo sob a lareira ou a soleira de casas inglesas, cheias de urina, pregos e alfinetes dobrados, cabelo, unhas, às vezes um coração de pano espetado. Ralph Merrifield (*The Archaeology of Ritual and Magic*, 1987) catalogou dezenas; a garrafa de Greenwich (2004) chegou lacrada e com conteúdo intacto. A prática atravessou o Atlântico e seguiu até o séc. XX. […]
- Revisão anterior: **REPROVADA** — Garrafa de vidro com vela, lê como poção. Sem face barbada de bellarmine, pregos ou maldição refletida.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_garrafa_de_bruxa_a.png`, `arte/bruxaria/_candidatas/bru_garrafa_de_bruxa_b.png`
- Prompt atual:
```prompt
no humans, object focus, single brown stoneware jug, bellarmine bottle, grim bearded man face molded on the bottle neck, salt glaze, round belly, cork sealed with red wax, bent iron nails and pins spilling from a crack, strands of hair, bottle half buried under a brick hearth, red curse energy striking the bottle and bouncing back, faint purple runes on the floor, embers, soot, cobwebs, purple and green, red glow, candlelight, rim lighting, ominous, dark atmosphere
```

#### Boneco de Cera  (`bru_boneco_de_cera`)
- Ficha: `cartas/bruxaria/16_boneco_de_cera.md` · Selo
- Destino: `arte/bruxaria/bru_boneco_de_cera.png`
- Texto da carta: Quando uma Entidade aliada sofrer dano de um ataque, o atacante sofre 4 de dano e perde 2 ATK e 2 Vida permanentemente.
- Contexto: O boneco (*poppet*, *dagyde*, *kolossós*) é a forma mais antiga da magia simpática: o que se faz à imagem acontece ao corpo. Teócrito (*Idílio* 2, séc. III a.C.) mostra a jovem Simeta derretendo cera ao fogo para que o amante Delfis derreta de amor; os gregos enterravam *kolossoi* de chumbo com as mãos atadas junto a *defixiones* (tabuletas de maldição) traspassadas por pregos; Ovídio faz uma rival "espetar o fígado de agulhas finas" numa imagem de cera (*Amores* III.7.29–30). No Egito, figuras de cera dos inimigos do faraó eram queimadas nos templos. […]
- Revisão anterior: **REPROVADA** — Figura errada: um gato preto deitado na mesa com líquido vermelho escorrendo (parece sangue, beira o gore). Não há boneco de cera.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_boneco_de_cera_a.png`, `arte/bruxaria/_candidatas/bru_boneco_de_cera_b.png`
- Prompt atual:
```prompt
no humans, no animals, object focus, close-up, crude humanoid wax doll, pale yellow wax poppet, arms and legs, pierced with long needles and thorns, red thread wrapped around it, lock of hair tied to it, lying on a dark wooden table, melting candle beside it, scattered pins, small knife, dried herbs, dark cottage interior, cobwebs, moonlight through the window, purple and green, candlelight, red glow from the needle tips, rim lighting, ominous, dark atmosphere
```

#### Poção de Beladona  (`bru_pocao_de_beladona`)
- Ficha: `cartas/bruxaria/17_pocao_de_beladona.md` · Rito
- Destino: `arte/bruxaria/bru_pocao_de_beladona.png`
- Texto da carta: Uma Entidade aliada à escolha cura 2 de Vida e ganha +1 ATK e +1 Vida permanentemente.
- Contexto: *Atropa belladonna*: o gênero leva o nome de Átropos, a Moira que corta o fio da vida, e a espécie o das damas venezianas que pingavam seu suco nos olhos para dilatar as pupilas e parecer mais belas. Toda a planta é carregada de atropina, hiosciamina e escopolamina (hioscina) — os alcaloides tropânicos que, em dose pequena, aceleram o coração, secam a boca e provocam visões; em dose maior, matam. É a erva da bruxa por definição: remédio e veneno na mesma raiz. A beladona é ingrediente constante das receitas de **unguento de voo** que os eruditos do séc. […]
- Revisão anterior: **REPROVADA** — Três frascos genéricos sem beladona (bagas pretas e flores de sino), e o foco do objeto se dilui. Pergaminho com rabiscos que imitam texto.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_pocao_de_beladona_a.png`, `arte/bruxaria/_candidatas/bru_pocao_de_beladona_b.png`
- Prompt atual:
```prompt
no humans, object focus, close-up, single small glass potion vial in the center, glowing purple liquid, swirling vapor, cork stopper, sprig of deadly nightshade beside it, glossy black berries, purple bell-shaped flowers, dark green leaves, mortar and pestle with crushed black berries, dark wooden table, dried herbs, dark cottage interior, shadows, moonlight through the window, purple and green, purple glow, candlelight, rim lighting, dark atmosphere, detailed texture
```

#### Pacto na Encruzilhada  (`bru_pacto_na_encruzilhada`)
- Ficha: `cartas/bruxaria/18_pacto_na_encruzilhada.md` · Rito
- Destino: `arte/bruxaria/bru_pacto_na_encruzilhada.png`
- Texto da carta: Ganhe 2 de Fé temporária (só neste turno).
- Contexto: O pacto é o coração da bruxaria tal como os teólogos a definiram: não o feitiço, mas o acordo. A lenda mais antiga é a de Teófilo de Adana (séc. VI, grego; latim no séc. IX), ecônomo que vende a alma por escrito a um demônio para recuperar um cargo e é salvo pela Virgem, que rouba o contrato do inferno — fonte de todos os "Faustos". A *Historia von D. Johann Fausten* (Frankfurt, 1587) fixa o modelo moderno: o sábio assina com sangue, recebe vinte e quatro anos de poder e paga no fim. Em Loudun (1634) o pacto de Urbain Grandier com Lúcifer, Belzebu e Leviatã, "assinado" por eles em latim invertido, foi apresentado em juízo e sobrevive na Biblioteca Nacional da França. […]
- Revisão anterior: **REPROVADA** — Falta a silhueta chifruda (a outra parte do pacto) e o poste da encruzilhada. O rosto verde-monstro da bruxa confunde a leitura.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_pacto_na_encruzilhada_a.png`, `arte/bruxaria/_candidatas/bru_pacto_na_encruzilhada_b.png`
- Prompt atual:
```prompt
1girl, solo, hooded witch, dark cloak, human face in shadow, kneeling at a crossroads, offering a small bundle with both hands, bleeding palm, glowing blood drops on the dirt, crooked wooden signpost, giant horned demon silhouette towering in the mist behind her, glowing green eyes of the demon, raven on the post, lantern on the ground, dirt roads, dead trees, fog, purple and green, moonlight, rim lighting, ominous, dark atmosphere, full body
```

#### Seiðr  (`bru_seidr`)
- Ficha: `cartas/bruxaria/19_seidr.md` · Rito
- Destino: `arte/bruxaria/bru_seidr.png`
- Texto da carta: Busque uma Entidade do seu deck e ponha-a na mão. Embaralhe.
- Contexto: *Seiðr* é a magia nórdica de transe, adivinhação e manipulação da sorte — a mais próxima de uma "bruxaria" no mundo escandinavo pré-cristão. Snorri Sturluson conta, na *Ynglinga saga* (cap. 4), que foi **Freyja** quem ensinou o *seiðr* aos Æsir, como era costume entre os Vanir; e que Odin o praticava, embora a arte carregasse tal *ergi* (desonra, falta de virilidade) que os homens a deixavam às sacerdotisas (cap. 7). Freyja, senhora do amor, da guerra e da metade dos mortos em batalha, é assim a padroeira da feiticeira nórdica. A descrição mais rica é a da *völva* Þorbjörg lítilvölva em *Eiríks saga rauða* (cap. […]
- Revisão anterior: **APROVADA** — Völva de manto azul, trança loira e cajado, em transe sobre plataforma, com o fio do destino.
- Prompt atual:
```prompt
1girl, solo, norse seeress, mature woman, long blonde braided hair, blue cloak studded with stones, black lambskin hood, cat fur gloves, glass bead necklace, holding a tall brass staff, seated on a high wooden platform, eyes closed in trance, glowing thread of fate floating in the air before her, viking longhouse interior, central fire pit, smoke, carved wooden pillars, hanging furs, shadows, purple and green, firelight, candlelight, rim lighting, mystical, full body
```

#### Pó de Ossos  (`bru_po_de_ossos`)
- Ficha: `cartas/bruxaria/20_po_de_ossos.md` · Rito
- Destino: `arte/bruxaria/bru_po_de_ossos.png`
- Texto da carta: Todas as Entidades inimigas sofrem 2 de dano; o oponente descarta 1 carta aleatória.
- Contexto: Osso moído, cinza de pira e terra de sepultura são os ingredientes da necromancia clássica. Erictho, a bruxa tessália de Lucano (*Farsália* VI.533–569), recolhe nos campos de batalha e nas piras funerárias "as cinzas que ainda fumegam e os ossos que ainda ardem dos jovens", arranca com os dentes os pregos e as cordas dos enforcados, e com isso prepara o caldo que fará um soldado morto falar. Medeia, no caldeirão de Ovídio (*Metamorfoses* VII.264–274), junta ossos, asas de coruja e a cabeça de um corvo de nove gerações. As *defixiones* gregas e romanas eram depositadas em túmulos para que os mortos as levassem aos deuses de baixo. […]
- Revisão anterior: **REPROVADA** — Não sopra pó (a mecânica de área). A figura é uma massa mal definida segurando uma caveira.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_po_de_ossos_a.png`, `arte/bruxaria/_candidatas/bru_po_de_ossos_b.png`
- Prompt atual:
```prompt
1girl, solo, hooded witch, face hidden in shadow, bony pale hands, side view, palm held to her lips, blowing a large cloud of pale grey bone dust, ash and bone fragments swirling, small skulls in the dust cloud, green ghostly glow in the dust, wind, dark graveyard at night, tilted gravestones, open burial urn, iron fence, fog, bats, purple and green, moonlight, rim lighting, ominous, dark atmosphere, upper body
```

#### Malefício  (`bru_maleficio`)
- Ficha: `cartas/bruxaria/21_maleficio.md` · Rito
- Destino: `arte/bruxaria/bru_maleficio.png`
- Texto da carta: Uma Entidade inimiga à escolha perde 3 ATK e 2 Vida permanentemente e é silenciada (perde palavras-chave e habilidades).
- Contexto: *Maleficium* — "mal-feito" — é a palavra latina para o dano causado por magia, e é o que a bruxaria foi, antes de tudo, aos olhos de vizinhos e juízes: a vaca que seca, o leite que não vira manteiga, a criança que definha, o homem que fica impotente na noite de núpcias, a tempestade de granizo sobre a vinha. Os tribunais seculares puniam o *maleficium* como crime de dano muito antes de a Igreja o tratar como heresia (Brian Levack, *The Witch-Hunt in Early Modern Europe*); o próprio título do *Malleus Maleficarum* — "martelo das malfeitoras" — toma a palavra como nome do ofício. […]
- Revisão anterior: **APROVADA** — Bruxa lançando energia roxa do dedo sob tempestade, com cerca e árvores mortas. Leitura clara de maldição.
- Prompt atual:
```prompt
1girl, solo, powerful witch, long black hair blowing in the wind, dark tattered dress, black shawl, pointing finger, hateful glare, dark purple curse energy shooting from her fingertip, crackling magic, withered shriveling crops around her, dead cow silhouette in the field, crows, night farmland, wooden fence, dark cottage in the background, storm clouds, dead tree, lightning in the distance, purple and green, moonlight, glowing purple eyes, rim lighting, ominous, dark atmosphere, full body
```

#### Sabá de Walpurgis  (`bru_saba_de_walpurgis`)
- Ficha: `cartas/bruxaria/22_saba_de_walpurgis.md` · Rito
- Destino: `arte/bruxaria/bru_saba_de_walpurgis.png`
- Texto da carta: Todas as Entidades aliadas ganham +1 ATK e +1 Vida permanentemente. Invoque uma Lebre 1/2.
- Contexto: O **sabá** — a assembleia noturna em que as bruxas chegam voando, dançam de costas, banqueteiam-se, beijam o bode e recebem ordens do Diabo — é, como Carlo Ginzburg demonstra em *História Noturna* (1989), uma construção dos juízes e inquisidores dos Alpes ocidentais a partir de 1430 (*Formicarius* de Johannes Nider, *Errores Gazariorum*), que fundiu a velha acusação de reunião secreta feita a judeus, leprosos e hereges com um material folclórico real: os cortejos noturnos da "senhora do jogo" (Diana, Holda, Perchta, Richella, Oriente), as batalhas em espírito dos benandanti, as viagens em êxtase das *völur*. […]
- Revisão anterior: **REPROVADA** — Só uma fogueira na floresta. Não há deus chifrudo, bruxas dançando, lebre (o token invocado) nem vassouras.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_saba_de_walpurgis_a.png`, `arte/bruxaria/_candidatas/bru_saba_de_walpurgis_b.png`
- Prompt atual:
```prompt
1other, solo, wide shot, tall horned antlered god figure standing behind a great bonfire, dark silhouette, glowing eyes, small witch silhouettes dancing around the fire, brown hare sitting in the foreground, hare with tall raised ears, witches on broomsticks flying across the full moon, rocky mountain summit, boulders, sparks and embers, swirling smoke, pine forest below, night sky, purple and green, firelight, moonlight, rim lighting, dark atmosphere, full body
```

#### Vassoura  (`bru_vassoura`)
- Ficha: `cartas/bruxaria/23_vassoura.md` · Relíquia
- Destino: `arte/bruxaria/bru_vassoura.png`
- Texto da carta: A portadora ganha +1 ATK e +2 Vida e Ímpeto.
- Contexto: A imagem mais antiga que se conhece de mulheres voando — uma em vassoura, outra num bastão — está nas margens de um manuscrito de *Le Champion des Dames*, poema de Martin Le Franc (1451), com a legenda "des vaudoises" (as valdenses, nome que então servia para bruxas). A associação se fixa rápido: a vassoura é o instrumento doméstico por excelência, e a bruxa é a mulher que o vira do avesso — monta nele, em vez de varrer com ele, e sai pela chaminé em vez de ficar junto ao fogo. Os tratados descrevem o unguento de voo esfregado no cabo; a farmacologia explica o resto. […]
- Revisão anterior: **REPROVADA** — É Relíquia, mas a vassoura não aparece: só uma silhueta minúscula na lua. O foco fica na igreja.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_vassoura_a.png`, `arte/bruxaria/_candidatas/bru_vassoura_b.png`
- Prompt atual:
```prompt
no humans, object focus, close-up, single old twig besom broom filling the frame, diagonal composition, dynamic angle, worn wooden handle, bundle of birch twigs tied with cord, broom flying by itself, no rider, trailing green sparks and purple smoke, motion blur on the bristles, speed lines, full moon behind, village rooftops far below, church spire, bats, clouds, purple and green, moonlight, glowing green sparks, rim lighting, dark atmosphere
```

#### Livro das Sombras  (`bru_livro_das_sombras`)
- Ficha: `cartas/bruxaria/24_livro_das_sombras.md` · Relíquia
- Destino: `arte/bruxaria/bru_livro_das_sombras.png`
- Texto da carta: Usos 4. A portadora ganha +1 ATK e +1 Vida enquanto o porta. Sempre que ela atacar, compre 1 carta e gaste 1 Uso.
- Contexto: O **Livro das Sombras** é a contribuição mais duradoura de Gerald Gardner (1884–1964) à bruxaria: o caderno manuscrito de rituais, invocações, leis e receitas que cada iniciado de um coven wiccano copia à mão do livro de quem o iniciou, e ao qual acrescenta o seu. Gardner compilou o primeiro entre 1949 e 1953 (um rascunho, *Ye Bok of ye Art Magical*, sobrevive), afirmando ter recebido o material de um coven antigo de New Forest; Ronald Hutton (*The Triumph of the Moon*, 1999) mostra as fontes reais — a *Clavicula Salomonis* na edição de Mathers, Crowley, a maçonaria, Leland e Murray — e defende que isso não lhe tira o valor: a Wicca é uma religião nova, honestamente costurada. […]
- Revisão anterior: **REPROVADA** — O foco é uma chama roxa no altar. Os livros são pequenos no rodapé, sem pentáculo, com páginas de rabiscos que imitam texto.
- Candidatas já geradas (não revisadas): `arte/bruxaria/_candidatas/bru_livro_das_sombras_a.png`, `arte/bruxaria/_candidatas/bru_livro_das_sombras_b.png`
- Prompt atual:
```prompt
no humans, object focus, close-up, single large ancient leather grimoire in the center, black leather cover, silver pentacle embossed on the cover, brass clasps, book floating open above a wooden altar, glowing blank pages, no writing, swirling purple light rising from the pages, loose blank pages drifting, candles on both sides, antlers on the wall, dark cottage interior, dust motes, purple and green, candlelight, purple glow, rim lighting, dark atmosphere, detailed texture
```

#### Caldeirão de Renascimento  (`bru_caldeirao_de_renascimento`)
- Ficha: `cartas/bruxaria/25_caldeirao_de_renascimento.md` · Relíquia
- Destino: `arte/bruxaria/bru_caldeirao_de_renascimento.png`
- Texto da carta: A portadora ganha +1 ATK e +2 Vida. Quando ela morrer, reviva uma Entidade do seu cemitério para o campo.
- Contexto: O caldeirão é o objeto da bruxa por excelência — Cerridwen o ferve um ano e um dia pela inspiração (*Hanes Taliesin*), Medeia rejuvenesce Éson nele e mata Pélias por ele (Ovídio, *Metamorfoses* VII), as Três Irmãs de *Macbeth* (IV.1) jogam nele "olho de salamandra e dedo de rã" para ver o futuro. Mas o caldeirão deste nome específico vem do segundo ramo do *Mabinogion*, *Branwen ferch Llŷr*: o *Pair Dadeni*, "Caldeirão de Renascimento", trazido da Irlanda por um gigante que saía de um lago com a mulher, e dado por Bendigeidfran (Brân, o Abençoado) ao rei irlandês Matholwch como presente de casamento com sua irmã Branwen. […]
- Revisão anterior: **APROVADA** — Guerreiro de elmo e lança saindo do caldeirão de líquido verde no lago, e a Relíquia está em destaque. Rosto meio chibi (aceitável).
- Prompt atual:
```prompt
1boy, solo, dead celtic warrior rising from a huge black iron cauldron, pale skin, glowing green eyes, bronze helmet, chainmail, holding a spear, closed mouth, stiff pose, green glowing liquid pouring over the cauldron rim, swirling green steam, cauldron decorated with embossed figures, fire under the cauldron, lakeshore at night, reeds, still water, mist, stars, purple and green, green glow, moonlight, rim lighting, dark atmosphere, full body
```

### Alta magia — 24 cartas

#### Homúnculo  (`alt_homunculo`)
- Ficha: `cartas/alta_magia/01_homunculo.md` · Entidade · 1/2
- Destino: `arte/alta_magia/alt_homunculo.png`
- Texto da carta: Último Sopro: compre 1 carta.
- Contexto: O homúnculo ("homenzinho") é a criatura artificial da alquimia. A receita mais famosa está no *De natura rerum* (1537) atribuído a Paracelso: sêmen humano selado num vaso de vidro, posto a putrefazer quarenta dias em esterco de cavalo até começar a mexer-se, depois nutrido com o *arcanum* do sangue humano por quarenta semanas, em calor constante. Nasce um ser pequeno, transparente, "com todos os membros de uma criança nascida de mulher", que pode ser criado e educado — e que, por ter nascido da arte e não da natureza, conhece segredos ocultos aos homens. […]
- Revisão anterior: **REPROVADA** — A criatura está fora do frasco, sentada embaixo dele. O frasco tem uma vela no gargalo. O atributo-chave (homúnculo dentro do vaso selado) não aparece.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_homunculo_a.png`, `arte/alta_magia/_candidatas/alt_homunculo_b.png`
- Prompt atual:
```prompt
1other, solo, tiny homunculus inside a glass flask, creature enclosed in glass, curled up fetal pose, pale translucent skin, oversized head, closed eyes, tiny hands pressed against the inner glass, round glass flask, sealed red wax stopper, amber liquid, bubbles, warm glow from inside the flask, flask centered, alchemist table, brass alembic, open grimoire, candles, dark laboratory, stone wall, black and gold, red candlelight, rim lighting, object focus, close-up
```

#### Edward Kelley, o Vidente  (`alt_edward_kelley`)
- Ficha: `cartas/alta_magia/03_edward_kelley.md` · Entidade · 1/1
- Destino: `arte/alta_magia/alt_edward_kelley.png`
- Texto da carta: Furtivo. Despertar: busque uma Relíquia do seu deck.
- Contexto: Edward Kelley (1555–1597) foi o *skryer* — vidente — de John Dee de 1582 a 1589. Dee, matemático e astrólogo de Elizabeth I, não via nada no cristal; Kelley via. Sentado diante da pedra de visão, descrevia anjos, tábuas de letras e cenas que Dee anotava palavra por palavra em latim e inglês. Dessas sessões saiu o sistema enochiano inteiro: as 48 Chaves, as Tábuas de Vigia, os 30 Aethyrs. Casaubon publicou os diários em 1659 como *A True & Faithful Relation*, para desacreditar Dee — e acabou criando o cânone. […]
- Revisão anterior: **REPROVADA** — Figura errada: chifres, caveira no peito e pele azul fazem dele um demônio, não o vidente humano elisabetano. Faltam a gola rufo e o barrete. A bola de cristal está ok.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_edward_kelley_a.png`, `arte/alta_magia/_candidatas/alt_edward_kelley_b.png`
- Prompt atual:
```prompt
1boy, solo, human elizabethan scholar, ordinary man, long dark beard, black skull cap covering his ears, white ruff collar, dark scholar robe, sitting at a desk, leaning forward, gazing into a crystal ball, hands cupped around the crystal, crystal on a pale wax disc, swirling visions inside the crystal, pale blue glow lighting his face, half in shadow, candlelit study, bookshelves, scattered papers, inkwell, black and gold, red candlelight, upper body
```

#### Silfo  (`alt_silfo`)
- Ficha: `cartas/alta_magia/04_silfo.md` · Entidade · 1/2
- Destino: `arte/alta_magia/alt_silfo.png`
- Texto da carta: Ímpeto. Furtivo.
- Contexto: Os silfos são os espíritos do ar na classificação de Paracelso (*Liber de nymphis, sylphis, pygmaeis et salamandris*, publicado postumamente em 1566). Cada elemento tem seu povo: gnomos ou pigmeus na terra, ninfas ou ondinas na água, salamandras no fogo, silfos no ar. São "entre homem e espírito": têm corpo, comem, dormem e morrem, mas não têm alma — e por isso buscam o homem, seja para servir, seja para casar e ganhar alma pelo matrimônio (a história de Melusina). Paracelso descreve os silfos como mais altos e esguios que os homens, rápidos, quase invisíveis, vivendo no ar como o peixe na água. […]
- Revisão anterior: **APROVADA** — Espírito translúcido azul-branco, cabelo ao vento, janela ao luar, corpo que vira névoa. Pose pouco "em investida", mas legível. Ressalva: corpo sem roupa, mas sem anatomia (ok).
- Prompt atual:
```prompt
1other, solo, sylph, air elemental spirit, tall slender figure, androgynous, translucent body, pale blue-white skin, semi-transparent, hair flowing like wind, body trailing into wisps of cloud, lunging forward, mid-flight, arms swept back, bursting through an open window, ritual chamber, billowing dark curtains, candle flames bent by the wind, loose pages flying, wind streaks, moonlit night outside, stone floor with chalk circle, black and gold, pale moonlight, soft inner glow, dust particles, dramatic shadows, victorian interior, full body
```

#### Vassago, o Príncipe que Acha  (`alt_vassago`)
- Ficha: `cartas/alta_magia/05_vassago.md` · Entidade · 2/3
- Destino: `arte/alta_magia/alt_vassago.png`
- Texto da carta: Despertar: busque um Selo do seu deck.
- Contexto: Vassago é o terceiro espírito da *Ars Goetia* (Lemegeton, séc. XVII), um Príncipe "da mesma natureza de Agares", de boa índole. Seu ofício é declarar coisas passadas e futuras e **descobrir tudo o que está escondido ou perdido**; governa 26 legiões. É um dos poucos espíritos da lista que o próprio texto descreve como benigno ("of a good nature"), e por isso virou favorito dos magos que querem adivinhação sem risco. Detalhe de filologia: Vassago **não consta** na *Pseudomonarchia Daemonum* de Weyer (1577), fonte dos outros 68; é um dos quatro espíritos (com Seere, Dantalion e Andromalius) acrescentados pelo compilador do Lemegeton no século XVII — provavelmente de outra lista hoje perdida. […]
- Revisão anterior: **REPROVADA** — Segura algo que parece um cigarro aceso. O selo não está nas mãos: ele está ajoelhado sobre um disco gigante. A ação-chave (achar/erguer o selo) falta.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_vassago_a.png`, `arte/alta_magia/_candidatas/alt_vassago_b.png`
- Prompt atual:
```prompt
1boy, solo, old hooded spirit, long white beard, serene wrinkled face, dark hooded robe with golden trim, pale glowing eyes, kneeling on one knee, both hands lifting a small round golden seal, seal held at chest height, seal glowing gold, looking down at the seal, light from the seal on his face, loose flagstone beside him, chalk circle on stone floor, candles, incense burner, heavy curtains, black and gold, red candlelight, dramatic shadows, full body
```

#### Orobas, o Príncipe Fiel  (`alt_orobas`)
- Ficha: `cartas/alta_magia/07_orobas.md` · Entidade · 1/4
- Destino: `arte/alta_magia/alt_orobas.png`
- Texto da carta: Guarda. No início do seu turno, Orobas cura 2 de Vida de si mesmo.
- Contexto: Orobas é o 55º espírito da *Ars Goetia*, um Príncipe que aparece primeiro como cavalo e, a pedido do mago, toma forma humana. Revela passado, presente e futuro, concede dignidades e o favor de amigos e inimigos, e — o traço que o distingue de quase todos os outros — **é fiel ao exorcista e não permite que ele seja tentado por espírito algum**. Governa 20 legiões. Weyer (*Pseudomonarchia*, 1577) já o descreve assim, e Collin de Plancy o desenhou como cavalo de pé, ereto, no *Dictionnaire Infernal* (1863). Num catálogo onde Andras mata o mago distraído e Furfur mente fora do triângulo, Orobas é a exceção: o espírito que protege. […]
- Revisão anterior: **APROVADA** — Cavalo negro de frente, diante de uma porta, guardando. Combina com Guarda. Não está empinado, mas a forma goética de cavalo está correta.
- Prompt atual:
```prompt
no humans, demonic horse, black horse, standing upright on its hind legs, noble posture, flowing dark mane, glowing golden eyes, hooves planted firmly, standing guard, in front of a tall closed door, facing viewer, protective stance, faint golden healing aura, golden sparks around its body, stone archway, iron candle sconces, heavy dark curtains, stone floor, faded chalk circle, black and gold, red candlelight, glowing sigils on the door, incense smoke, flickering flames, dramatic shadows, victorian interior, gothic architecture, full body
```

#### Andras, o Semeador de Discórdia  (`alt_andras`)
- Ficha: `cartas/alta_magia/08_andras.md` · Entidade · 3/2
- Destino: `arte/alta_magia/alt_andras.png`
- Texto da carta: Despertar: destrua uma Entidade inimiga de custo 3 ou menos.
- Contexto: Andras é o 63º espírito da *Ars Goetia*: um Grande Marquês que aparece com corpo de anjo e cabeça de corvo noturno (ou coruja), montado num forte lobo negro e brandindo uma espada afiada e brilhante. Seu ofício é **semear discórdias** — e a Goetia acrescenta a advertência mais dura da lista: "se o exorcista não tomar cuidado, ele o matará, e aos seus companheiros". Governa 30 legiões. Weyer (1577) repete a descrição e o aviso. É o espírito assassino do catálogo, aquele que os grimórios recomendam evocar só com o círculo perfeitamente traçado, porque busca qualquer brecha. Collin de Plancy o desenhou exatamente assim: asas abertas, cabeça de coruja, lobo a galope, espada erguida. […]
- Revisão anterior: **REPROVADA** — Cabeça de lobo/chacal em vez de corvo, e não há lobo montado. Os dois atributos que identificam Andras estão ausentes.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_andras_a.png`, `arte/alta_magia/_candidatas/alt_andras_b.png`
- Prompt atual:
```prompt
1other, solo, raven-headed demon, black raven head, long sharp black beak, bird head, black feathered wings spread, dark armor, riding a huge black wolf, mounted on the wolf's back, wolf snarling, wolf lunging forward, rider raising a gleaming sword, charging toward viewer, dark ritual hall, cracked stone floor, broken candles, black and gold, red candlelight, embers, dust, dramatic shadows, gothic architecture, full body
```

#### Marbas, o Leão das Doenças  (`alt_marbas`)
- Ficha: `cartas/alta_magia/09_marbas.md` · Entidade · 3/4
- Destino: `arte/alta_magia/alt_marbas.png`
- Texto da carta: Despertar: silencie uma Entidade inimiga (ela perde palavras-chave e efeitos).
- Contexto: Marbas (ou Barbas) é o quinto espírito da *Ars Goetia*, um Grande Presidente que aparece como um grande leão e, a pedido, toma forma humana. Responde com verdade sobre coisas ocultas e secretas, **causa doenças e as cura**, dá sabedoria nas artes mecânicas e **muda homens para outras formas**. Governa 36 legiões. Weyer o lista como Marbas *alias* Barbas na *Pseudomonarchia Daemonum* (1577), com os mesmos ofícios. Entre os 72, Marbas é o espírito do corpo: o que adoece e sara, o que desfigura e repara. Os grimórios o associam à medicina e à engenharia — ao que se pode consertar ou quebrar com conhecimento. […]
- Revisão anterior: **APROVADA** — Leão grande, juba dourada, pata erguida, sombra escura no chão. Lê-se como Marbas. O sigilo sob a pata não aparece, mas não é essencial.
- Prompt atual:
```prompt
no humans, giant lion, huge male lion, golden mane, stern human-like eyes, glowing eyes, mouth closed, pressing one heavy paw down, snuffing out a glowing sigil under its paw, sigil fading into grey smoke, extinguished candles, thin smoke trails, shadow on the wall shaped like a man, dark ritual chamber, stone pillars, heavy curtains, stone floor, black and gold, red candlelight, glowing sigils, incense burner, wax drippings, dust particles, dramatic shadows, victorian interior, gothic architecture, high contrast, full body
```

#### Astaroth, o Duque Revelador  (`alt_astaroth`)
- Ficha: `cartas/alta_magia/10_astaroth.md` · Entidade · 3/5
- Destino: `arte/alta_magia/alt_astaroth.png`
- Texto da carta: Sacrifício 1. Despertar: compre 2 cartas.
- Contexto: Astaroth é o 29º espírito da *Ars Goetia*, um Grande Duque que aparece como um anjo "danoso" montado num dragão infernal, com uma víbora na mão direita. O mago não deve deixá-lo aproximar-se, por causa do hálito pestilento — deve segurar o Anel mágico diante do rosto. Ele responde com verdade sobre passado, presente e futuro, **revela todos os segredos**, conta de bom grado como os anjos caíram (e como ele próprio caiu) e ensina as ciências liberais. Governa 40 legiões. O nome é a forma masculinizada de Astarte, a deusa fenícia (Ashtoreth na Bíblia), via os demonólogos medievais; o *Grimorium Verum* e o *Grimório do Papa Honório* o colocam na tríade suprema ao lado de Lúcifer e Belzebu. […]
- Revisão anterior: **REPROVADA** — Só um dragão com coroa: não há anjo cavaleiro nem víbora na mão. Leitura confusa.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_astaroth_a.png`, `arte/alta_magia/_candidatas/alt_astaroth_b.png`
- Prompt atual:
```prompt
1other, solo, angel rider, gaunt ugly human face, golden crown on the rider's head, dark feathered wings, rider seated on the back of a black dragon, dragon below the rider, red glowing veins on the dragon, green viper in the rider's right hand, snake raised toward viewer, left hand open, green pestilent breath, dark ritual hall, cracked stone floor, candles, black and gold, red candlelight, dramatic shadows, full body
```

#### Dantalion, das Mil Faces  (`alt_dantalion`)
- Ficha: `cartas/alta_magia/11_dantalion.md` · Entidade · 3/4
- Destino: `arte/alta_magia/alt_dantalion.png`
- Texto da carta: Sacrifício 1. Despertar: tome o controle permanente de uma Entidade inimiga.
- Contexto: Dantalion é o 71º e penúltimo espírito da *Ars Goetia*, um Grande Duque que aparece "na forma de um homem com muitas faces, todas de homens e mulheres", segurando um livro na mão direita. Ensina todas as artes e ciências e revela o conselho secreto de qualquer pessoa, "pois **conhece os pensamentos de todos os homens e mulheres e pode mudá-los à sua vontade**"; provoca amor e mostra a semelhança de qualquer pessoa em visão, em qualquer parte do mundo. Governa 36 legiões. Como Vassago, Seere e Andromalius, **não aparece em Weyer** (1577): foi acrescentado pelo compilador do Lemegeton no século XVII, o que faz dele um dos espíritos mais "jovens" do catálogo. […]
- Revisão anterior: **REPROVADA** — Tem quatro mãos (membros extras). A "multidão de faces" virou só duas cabeças empilhadas.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_dantalion_a.png`, `arte/alta_magia/_candidatas/alt_dantalion_b.png`
- Prompt atual:
```prompt
1other, solo, robed demon with many faces, head made of many overlapping human faces, faces of men and women, cluster of faces, golden crown, long dark robe with golden trim, two arms, open book in the right hand, left hand reaching toward viewer, glowing fingertips, threads of light from the fingertips, hypnotic gaze, candlelit ritual chamber, heavy curtains, stone floor, black and gold, red candlelight, glowing sigils, dramatic shadows, full body
```

#### Paimon, Rei do Oeste  (`alt_paimon`)
- Ficha: `cartas/alta_magia/12_paimon.md` · Entidade · 4/5
- Destino: `arte/alta_magia/alt_paimon.png`
- Texto da carta: Despertar: invoque dois Espíritos de Paimon 1/1.
- Contexto: Paimon é o nono espírito da *Ars Goetia*, um Grande Rei "muito obediente a Lúcifer". Aparece como um homem coroado sentado num dromedário, com rosto de mulher segundo algumas versões, **precedido por uma hoste de espíritos tocando trombetas, címbalos e toda sorte de instrumentos**. Sua voz é estrondosa; o mago deve obrigá-lo a falar mais baixo. Ensina todas as artes, filosofias e ciências, revela o que é a Terra e o que a sustenta, concede dignidades e familiares. Governa 200 legiões, "parte da ordem dos Anjos, parte das Potestades". Se o mago faz oferenda ou sacrifício, vêm com ele dois reis menores, Labal e Abalim, e outros espíritos. […]
- Revisão anterior: **REPROVADA** — Ele está num trono, tocando a trombeta. Faltam o dromedário e os dois espíritos com trombetas, que são o atributo e a própria mecânica (invoca dois espíritos).
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_paimon_a.png`, `arte/alta_magia/_candidatas/alt_paimon_b.png`
- Prompt atual:
```prompt
1other, solo, demon king, androgynous face, golden crown, long black hair, dark robe with gold embroidery, riding a dromedary camel, seated on the camel, one hand raised in command, two tiny winged spirits flying beside him, small spirits blowing trumpets, entering through a great doorway, grand dark hall, tall candles, heavy curtains, stone floor, black and gold, red candlelight, dust in the air, dramatic shadows, wide shot, full body
```

#### Babalon, a Mulher Escarlate  (`alt_babalon`)
- Ficha: `cartas/alta_magia/13_babalon.md` · Entidade · 5/6 · Lendária
- Destino: `arte/alta_magia/alt_babalon.png`
- Texto da carta: Sacrifício 1. Sempre que qualquer Entidade morrer, Babalon ganha +1/+1 permanente.
- Contexto: Babalon é a deusa central da Thelema de Aleister Crowley. Nasce da leitura invertida do Apocalipse 17 — a "grande prostituta" montada na Besta de sete cabeças, com a taça cheia de abominações — e se revela a Crowley nos Aethyrs enochianos em 1909 (*The Vision and the Voice*, Liber 418), sobretudo nos Aethyrs 15º a 12º. Ali ela é a Mulher Escarlate, a Mãe das Abominações, a Cidade das Pirâmides: a porta do Abismo. Sua Taça é o símbolo decisivo. Quem quer atravessar o Abismo entre Chesed e Binah precisa **verter nela cada gota do próprio sangue** — isto é, dissolver inteiramente o ego — para renascer como Magister Templi. Quem guarda uma gota é despedaçado por Choronzon. […]
- Revisão anterior: **REPROVADA** — Falta a Besta de muitas cabeças, atributo central de Babalon. Ela segura duas taças em vez de um cálice transbordando.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_babalon_a.png`, `arte/alta_magia/_candidatas/alt_babalon_b.png`
- Prompt atual:
```prompt
1girl, solo, scarlet woman, long red hair, flowing red dress, fully clothed, golden crown, one golden chalice raised high, chalice overflowing with glowing red liquid, riding a monstrous black beast, seated on the beast's back, seven-headed beast, many dragon heads, horns, skulls at the beast's feet, triumphant expression, dark ritual hall, tall candles, black and gold, scarlet and gold, red candlelight, dramatic shadows, wide shot, full body
```

#### Anjo Guardião Sagrado  (`alt_anjo_guardiao`)
- Ficha: `cartas/alta_magia/14_anjo_guardiao.md` · Entidade · 4/8 · Lendária
- Destino: `arte/alta_magia/alt_anjo_guardiao.png`
- Texto da carta: Guarda. Renascer. Despertar: cure 4 da sua Cornucópia.
- Contexto: O Anjo Guardião Sagrado é o objetivo de toda a alta magia a partir de Abramelin. *O Livro da Magia Sagrada de Abramelin o Mago*, atribuído a Abraão de Worms (c. 1458; mss. alemães dos séc. XVII–XVIII, versão francesa traduzida por Mathers em 1898), prescreve uma operação de seis meses (dezoito, nos mss. alemães) de oração, jejum e reclusão num oratório com janela para o oriente. Ao fim, o Anjo aparece ao mago, e só então — com a autoridade do Anjo — ele convoca os quatro príncipes infernais e seus servos e os obriga a jurar obediência; a partir daí os quadrados mágicos do livro funcionam. […]
- Revisão anterior: **APROVADA** — Asas de luz dourada, braços abertos em postura protetora, contra a janela do amanhecer, altar. Combina com Guarda. Ressalva: o corpo é uma silhueta escura em contraluz, não "feito de luz", e está em cima do altar. Aceitável.
- Prompt atual:
```prompt
1other, solo, angel made of golden light, radiant humanoid silhouette, faceless, great wings of light, arms spread wide, protective stance, standing in front of a small altar, shielding it, body glowing from within, rays of golden light, healing glow, candles on the altar, oratory, tall window facing east, dawn light through the window, stone floor, black and gold, golden light, dust particles, soft shadows, gothic architecture, warm glow, high contrast, serene atmosphere, full body
```

#### Pentagrama Flamejante  (`alt_pentagrama_flamejante`)
- Ficha: `cartas/alta_magia/15_pentagrama_flamejante.md` · Selo
- Destino: `arte/alta_magia/alt_pentagrama_flamejante.png`
- Texto da carta: Quando o oponente jogar um Rito, anule-o, compre 1 carta e cure 2 da sua Cornucópia.
- Contexto: O pentagrama é o sinal de proteção mais antigo da magia ocidental — aparece como *Drudenfuss* ("pé de bruxa") nas portas alemãs, no Pentáculo de Salomão do Lemegeton, e nos talismãs de Agrippa (*De occulta philosophia* II.27, onde a estrela de cinco pontas contém o homem de braços abertos). Mas foi Éliphas Lévi quem o fez emblema da alta magia moderna: no *Dogma* (1854), cap. V, a "estrela flamejante" com uma ponta para cima é o microcosmo, o domínio do espírito sobre os quatro elementos — e invertida, com duas pontas para cima, é a cabeça do bode, o signo da matéria que domina. […]
- Revisão anterior: **REPROVADA** — Não há pentagrama de fogo no ar nem raio sendo anulado. É só um braseiro com fogo.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_pentagrama_flamejante_a.png`, `arte/alta_magia/_candidatas/alt_pentagrama_flamejante_b.png`
- Prompt atual:
```prompt
no humans, giant flaming pentagram floating in the air, five-pointed star made of fire, burning star lines, star centered, purple magic bolt hitting the star, bolt shattering into sparks, star blocking the attack, fire shield, dark ritual chamber, chalk circle on stone floor, candles, heavy curtains, stone pillars, black and gold, red candlelight, embers, dramatic shadows, high contrast, dark scene
```

#### Selo de Salomão  (`alt_selo_de_salomao`)
- Ficha: `cartas/alta_magia/17_selo_de_salomao.md` · Selo
- Destino: `arte/alta_magia/alt_selo_de_salomao.png`
- Texto da carta: Quando o oponente invocar uma Entidade, anule-a (ela vai ao cemitério) e compre 1 carta.
- Contexto: O Selo de Salomão é o sinal gravado no anel que, segundo o *Testamento de Salomão* (séc. I–III d.C.), o arcanjo Miguel entregou ao rei para que ele **comandasse os demônios** e os pusesse a trabalhar na construção do Templo. Na tradição islâmica e na magia medieval o selo é o hexagrama — duas triângulos entrelaçados, fogo e água, acima e abaixo — e é com ele que Salomão aprisiona os espíritos no Vaso de Latão, que lança ao lago (Lemegeton, "Observações"). […]
- Revisão anterior: **REPROVADA** — Vaso vermelho, sem o hexagrama na tampa, e nenhum demônio sendo sugado. A armadilha (anular invocação) não se lê.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_selo_de_salomao_a.png`, `arte/alta_magia/_candidatas/alt_selo_de_salomao_b.png`
- Prompt atual:
```prompt
no humans, object focus, sealed brass jar, brass vessel, glowing hexagram seal on the lid, ghostly demon being sucked into the jar, screaming spectral demon face, demon body stretched into smoke, smoke spiraling down into the jar, chains of light wrapped around the jar, trap, dark ritual chamber, stone floor, candles, black and gold, red candlelight, dramatic shadows, high contrast, dark scene
```

#### Solve et Coagula  (`alt_solve_et_coagula`)
- Ficha: `cartas/alta_magia/18_solve_et_coagula.md` · Selo
- Destino: `arte/alta_magia/alt_solve_et_coagula.png`
- Texto da carta: Quando uma Entidade aliada morrer no turno do oponente, devolva uma Entidade do seu cemitério à mão e compre 1 carta.
- Contexto: *Solve et coagula* — "dissolve e coagula" — é o lema da Grande Obra alquímica. A matéria-prima deve ser dissolvida (nigredo, putrefação, a morte do corpo) para que o espírito se separe dela e volte a fixar-se num corpo novo e purificado (albedo, rubedo). O *Rosarium Philosophorum* (1550) mostra o rei e a rainha morrendo no banho, a alma subindo e descendo, e o Rebis ressurgindo. A fórmula circula como máxima anônima nos tratados dos séculos XVI–XVII (Khunrath, Maier, o corpus de "Basílio Valentim") antes de ganhar a forma lapidar que hoje se cita. […]
- Revisão anterior: **REPROVADA** — Só uma lareira/forno. Faltam o vaso, o corpo dissolvendo e o espírito subindo.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_solve_et_coagula_a.png`, `arte/alta_magia/_candidatas/alt_solve_et_coagula_b.png`
- Prompt atual:
```prompt
no humans, object focus, round glass alchemical vessel, vessel centered on an athanor furnace, pale body dissolving inside the glass, black liquid in the vessel, small glowing white spirit rising out of the vessel, furnace glowing red below, alchemist laboratory, retorts, copper pipes, candles, dark stone chamber, black and gold, red candlelight, embers, dramatic shadows, high contrast, dark scene, close-up
```

#### Sigilo de Spare  (`alt_sigilo_de_spare`)
- Ficha: `cartas/alta_magia/20_sigilo_de_spare.md` · Selo
- Destino: `arte/alta_magia/alt_sigilo_de_spare.png`
- Texto da carta: No fim do turno do oponente, ele descarta 1 carta aleatória da mão e você compra 1 carta.
- Contexto: Austin Osman Spare (1886–1956), artista londrino que a imprensa chamou de "o novo Beardsley" aos dezoito anos, abandonou as galerias para desenvolver uma magia pessoal, descrita em *The Book of Pleasure (Self-Love): The Psychology of Ecstasy* (1913). Seu método — a **sigilização** — tornou-se a técnica mais influente da magia moderna: escreve-se o desejo numa frase, eliminam-se as letras repetidas, condensam-se as restantes num glifo abstrato, carrega-se o glifo num momento de exaustão ou êxtase (o "vazio", a *death posture*) e, essencial, **esquece-se o desejo**, para que trabalhe no subconsciente sem a interferência da mente consciente. […]
- Revisão anterior: **REPROVADA** — Não há o sigilo único em pergaminho em foco: é um corredor com porta. Os estandartes têm glifos parecidos com caracteres escritos (texto).
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_sigilo_de_spare_a.png`, `arte/alta_magia/_candidatas/alt_sigilo_de_spare_b.png`
- Prompt atual:
```prompt
no humans, object focus, close-up, single scrap of parchment pinned to a wooden wall, one abstract symbol of tangled black ink lines, symbol glowing faintly red, torn paper scraps drifting down, playing cards falling from a table edge, dead candle, dusty victorian study, cobwebs, ink stains, wooden panel wall, black and gold, dim red candlelight, dust particles, dramatic shadows, dark scene
```

#### Lemegeton, a Chave Menor  (`alt_lemegeton`)
- Ficha: `cartas/alta_magia/21_lemegeton.md` · Rito
- Destino: `arte/alta_magia/alt_lemegeton.png`
- Texto da carta: Busque uma Entidade do seu deck e coloque-a na mão.
- Contexto: O *Lemegeton Clavicula Salomonis* — a Chave Menor de Salomão — é o grimório mais influente da magia ocidental. Compilado em inglês no século XVII (Sloane MSS 2731 e 3825, British Library) a partir de materiais mais antigos, reúne cinco livros: a **Ars Goetia**, catálogo dos 72 espíritos com selos, ofícios, legiões e as conjurações para chamá-los; a *Theurgia-Goetia* (espíritos dos pontos cardeais); a *Ars Paulina* (anjos das horas e dos signos); a *Ars Almadel* (anjos das quatro altitudes, via tábua de cera); e a *Ars Notoria* (orações para a ciência instantânea). […]
- Revisão anterior: **REPROVADA** — O grimório (a própria carta) não aparece. O mago aponta para um altar/vitral.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_lemegeton_a.png`, `arte/alta_magia/_candidatas/alt_lemegeton_b.png`
- Prompt atual:
```prompt
1boy, solo, hooded magician seen from behind, over the shoulder view, dark robe, pointing at an open ancient grimoire, large book on a wooden lectern, book in the foreground, open pages covered with circular seals, one seal glowing gold, faint spectral shape rising from the page, candles, ritual chamber, chalk circle on stone floor, black and gold, red candlelight, dust particles, dramatic shadows, close-up, upper body
```

#### Azoth  (`alt_azoth`)
- Ficha: `cartas/alta_magia/23_azoth.md` · Rito
- Destino: `arte/alta_magia/alt_azoth.png`
- Texto da carta: Sua Fé máxima aumenta em 1 (até 8). Ganhe 1 de Fé neste turno. Compre 1 carta.
- Contexto: Azoth é o nome alquímico do **mercúrio universal** — o solvente e a semente de todas as coisas, o princípio que dissolve os metais e os refaz. A palavra é construída com a primeira letra dos alfabetos (A) e a última de cada um: Z do latino, Ω (ômega) do grego, ת (tav) do hebraico — o princípio e o fim, "Alfa e Ômega" em três línguas sagradas. Paracelso o usa como nome do remédio universal, e a lenda diz que o levava dentro do pomo da espada que nunca largava. […]
- Revisão anterior: **REPROVADA** — O líquido é vermelho (lê-se como sangue/poção), não mercúrio prateado-dourado. Há uma vela no gargalo do frasco.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_azoth_a.png`, `arte/alta_magia/_candidatas/alt_azoth_b.png`
- Prompt atual:
```prompt
no humans, object focus, round glass flask, sealed stopper, glowing liquid mercury, silver quicksilver, silver liquid swirling with golden light, silver fountain spilling from the flask, silver droplets floating upward, flask on an athanor furnace, furnace glowing red, brass alembics, alchemist laboratory, open grimoire, scales, candles, dark stone chamber, black and gold, silver and gold glow, dramatic shadows, high contrast
```

#### Conjuração dos Elementais  (`alt_conjuracao_elementais`)
- Ficha: `cartas/alta_magia/25_conjuracao_elementais.md` · Rito
- Destino: `arte/alta_magia/alt_conjuracao_elementais.png`
- Texto da carta: Invoque dois Elementais 1/1 (se houver slots livres).
- Contexto: Paracelso descreveu, no *Liber de nymphis, sylphis, pygmaeis et salamandris* (publicado em 1566, vinte e cinco anos após sua morte), os quatro povos elementais: **gnomos** (pigmeus) na terra, que atravessam a rocha como nós o ar; **ondinas** (ninfas) na água; **silfos** no ar; **salamandras** no fogo. Não são demônios nem anjos — são criaturas de Deus, com corpo e sem alma, que vivem no seu elemento e às vezes aparecem aos homens. A magia cerimonial dos séculos XIX e XX os organizou nos quatro quadrantes: a Golden Dawn consagra as quatro Armas Elementais e abre as Tábuas de Vigia enochianas de cada elemento; Lévi, no *Ritual* cap. […]
- Revisão anterior: **REPROVADA** — Faltam os dois elementais, que são a mecânica (invoca dois). Também falta a adaga. O mago virou figura sombria de cartola, rosto vazio.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_conjuracao_elementais_a.png`, `arte/alta_magia/_candidatas/alt_conjuracao_elementais_b.png`
- Prompt atual:
```prompt
1boy, solo, magician, hooded dark robe with golden trim, human face, arms raised, ritual dagger in the right hand, standing inside a chalk circle, two small elemental spirits at his sides, small fire spirit on the left, small wind spirit on the right, spirits emerging from swirling smoke, ritual chamber, candles, incense burner, heavy curtains, stone floor, black and gold, red candlelight, glowing sigils, embers, dramatic shadows, full body
```

#### Ritual Menor do Pentagrama  (`alt_ritual_menor_pentagrama`)
- Ficha: `cartas/alta_magia/27_ritual_menor_pentagrama.md` · Rito
- Destino: `arte/alta_magia/alt_ritual_menor_pentagrama.png`
- Texto da carta: Devolva todas as Entidades inimigas à mão do dono.
- Contexto: O Ritual Menor de Banimento do Pentagrama (LBRP, *Lesser Banishing Ritual of the Pentagram*) é o rito fundamental da Golden Dawn, ensinado ao Neófito no grau 0=0 e praticado diariamente por todos os graus. O mago faz a **Cruz Cabalística** (toca testa, peito, ombros com as palavras *Ateh, Malkuth, ve-Geburah, ve-Gedulah, le-Olam, Amen*), traça com a adaga um pentagrama flamejante em cada quadrante vibrando um nome divino (YHVH ao leste, Adonai ao sul, Eheieh ao oeste, AGLA ao norte), une-os num círculo e invoca os quatro arcanjos — "diante de mim Rafael, atrás de mim Gabriel, à minha direita Miguel, à minha esquerda Uriel" — fechando com a Cruz de novo. […]
- Revisão anterior: **REPROVADA** — Não traça a estrela, não tem adaga e não há espíritos sendo expulsos. Só bolas de fogo nas mãos (mago de cartola).
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_ritual_menor_pentagrama_a.png`, `arte/alta_magia/_candidatas/alt_ritual_menor_pentagrama_b.png`
- Prompt atual:
```prompt
1boy, solo, magician, hooded black robe, human face, ritual dagger in the right hand, arm extended forward, tracing a glowing pentagram in the air, five-pointed star of light, shadowy spirits blown outward away from him, spirits dissolving into smoke, strong wind, robe billowing, chalk circle on stone floor, four candles at the circle edges, ritual chamber, black and gold, red candlelight, dynamic pose, dramatic shadows, full body
```

#### Abrahadabra  (`alt_abrahadabra`)
- Ficha: `cartas/alta_magia/28_abrahadabra.md` · Rito
- Destino: `arte/alta_magia/alt_abrahadabra.png`
- Texto da carta: Cause 3 de dano à Cornucópia inimiga.
- Contexto: *Abrahadabra* é a Palavra do Aeon na Thelema. Abre o terceiro capítulo do *Liber AL vel Legis* (Cairo, abril de 1904): "Abrahadabra! a recompensa de Ra Hoor Khut" (AL III.1). Crowley a formou a partir do antigo *Abracadabra* dos amuletos (atestado em Sereno Samônico, séc. III) trocando o C pelo H — a letra de Hórus, o deus-criança do novo Aeon. A palavra tem **onze letras**, número da magia e da união do microcosmo (5) com o macrocosmo (6), e soma **418** na gematria hebraica — valor também de *Cheth* escrito por extenso (חית), da Casa de Boleskine na contagem de Crowley, e o título de *The Vision and the Voice* (Liber 418). Crowley o chama "o número da Grande Obra realizada". […]
- Revisão anterior: **REPROVADA** — Texto na imagem: "STONE OF WORD" no pedestal. O resto (grito, fogo, falcão) está bom.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_abrahadabra_a.png`, `arte/alta_magia/_candidatas/alt_abrahadabra_b.png`
- Prompt atual:
```prompt
1boy, solo, magician, hooded red and black robe, one wand raised, shouting a word of power, mouth open, blast of golden fire from the wand tip, fire toward viewer, hawk silhouette inside the flames, candles knocked over, dark ritual chamber, stone pillars, heavy curtains, black and gold, red candlelight, golden flames, embers, sparks, dramatic shadows, upper body
```

#### Anel de Salomão  (`alt_anel_de_salomao`)
- Ficha: `cartas/alta_magia/29_anel_de_salomao.md` · Relíquia
- Destino: `arte/alta_magia/alt_anel_de_salomao.png`
- Texto da carta: A Entidade equipada ganha +1/+2 e Ímpeto. Sempre que ela atacar, silencie uma Entidade inimiga.
- Contexto: O Anel de Salomão é a relíquia fundadora da magia cerimonial. No *Testamento de Salomão* (texto grego dos séc. I–III d.C.), o rei reza pelo seu operário atormentado por um demônio, e o arcanjo Miguel desce com um anel gravado com um selo: com ele Salomão convoca Ornias, Belzebu, Asmodeu e dezenas de outros, **interroga cada um sobre seu nome, seu ofício e o anjo que o frustra**, e os põe a carregar pedra para o Templo. É a origem de toda a literatura dos catálogos de espíritos — inclusive da Goetia. No Lemegeton, o Anel é de prata e serve para proteger o mago do hálito de Astaroth e de Beleth: "segure-o diante do rosto". […]
- Revisão anterior: **REPROVADA** — Não há anel: o objeto é uma lâmpada de gênio sobre o altar. Objeto errado.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_anel_de_salomao_a.png`, `arte/alta_magia/_candidatas/alt_anel_de_salomao_b.png`
- Prompt atual:
```prompt
no humans, object focus, close-up, single silver ring, signet ring, ring floating above a dark stone altar, hexagram engraved on the bezel, hexagram glowing, rings of light circling the ring, ghostly demon face behind the ring, demon mouth sealed shut, spectral face fading, velvet cloth on the altar, candles, dark chamber, black and gold, red candlelight, dust particles, dramatic shadows, high contrast, dark scene
```

#### Sigillum Dei Aemeth  (`alt_sigillum_dei_aemeth`)
- Ficha: `cartas/alta_magia/30_sigillum_dei_aemeth.md` · Relíquia
- Destino: `arte/alta_magia/alt_sigillum_dei_aemeth.png`
- Texto da carta: A Entidade equipada ganha +0/+3 e Guarda. Quando ela morrer, compre 1 carta.
- Contexto: O *Sigillum Dei Aemeth* — "Selo de Deus da Verdade" (*Aemeth*, אמת, "verdade" em hebraico) — é o disco de cera de nove polegadas que John Dee recebeu, letra por letra, de Edward Kelley em março de 1582, nas primeiras sessões com a pedra de visão (Sloane MS 3188, *Mysteriorum Liber Primus*). Traz um heptagrama dentro de heptágonos concêntricos, com nomes de Deus e dos sete anjos planetários dispostos em tabelas de letras e números, e um pentagrama central. Dee fez cinco: quatro sob os pés da Mesa Sagrada e um sobre ela, **debaixo da pedra de visão** — o cristal repousava sobre o selo, que o protegia e autenticava a visão. O desenho descende do *Sigillum Dei* do *Liber Juratus Honorii* (séc. […]
- Revisão anterior: **REPROVADA** — Virou uma esfera armilar/ostensório dourado em pé. Faltam o disco de cera pálida plano e a bola de cristal sobre ele.
- Candidatas já geradas (não revisadas): `arte/alta_magia/_candidatas/alt_sigillum_dei_aemeth_a.png`, `arte/alta_magia/_candidatas/alt_sigillum_dei_aemeth_b.png`
- Prompt atual:
```prompt
no humans, object focus, close-up, high angle view, large flat pale beeswax disc, round wax tablet, engraved star in the center, concentric rings of carved symbols, disc lying flat on a dark wooden table, small crystal ball resting on top of the disc, soft golden glow around the disc, candles, quill, inkwell, stacked books, old study, black and gold, red candlelight, wax drippings, soft shadows, high contrast
```

#### Pedra de Visão de Dee  (`alt_pedra_de_visao`)
- Ficha: `cartas/alta_magia/31_pedra_de_visao.md` · Relíquia
- Destino: `arte/alta_magia/alt_pedra_de_visao.png`
- Texto da carta: A Entidade equipada ganha +1/+3.
- Contexto: A pedra de visão (*shew-stone*) é o cristal em que Edward Kelley via os anjos enquanto John Dee anotava. Dee possuía mais de uma: uma **bola de cristal** de quartzo, e o **espelho de obsidiana** polida — um espelho asteca de Tezcatlipoca, trazido do México após a conquista, que a tradição desde Horace Walpole associa a Dee e cuja origem mexicana a análise geoquímica confirmou em 2021 (Campbell et al., *Antiquity*). Ambos estão no British Museum ao lado dos discos de cera do Sigillum Dei Aemeth. […]
- Revisão anterior: **APROVADA** — Bola de cristal em foco, sobre um suporte dourado, na mesa de estudo com velas, pena e livro. Relíquia como objeto central. Faltam o espelho de obsidiana e o disco de cera, mas não são essenciais.
- Prompt atual:
```prompt
no humans, object focus, crystal ball, on a dark wooden table, crystal on a pale wax disc, black obsidian mirror leaning behind it, visions of angels inside the crystal, glowing eye inside the crystal, glowing from within, old study, candles, open grimoire, quill, inkwell, dark curtains, black and gold, red candlelight, pale blue glow from the crystal, wooden panel wall, wax drippings, dust particles, dramatic shadows, victorian interior, high contrast, close-up
```

### Conjunto do Abismo — 4 cartas

#### Choronzon, Habitante do Abismo  (`aby_choronzon`)
- Ficha: `cartas/abismo/01_choronzon.md` · Entidade · 3/3
- Destino: `arte/abismo/aby_choronzon.png`
- Texto da carta: Só pode ser invocado pelo efeito de Sigilo 333. Quando Choronzon entra em campo, você vence o jogo.
- Contexto: Choronzon aparece primeiro nos diários enochianos de John Dee e Edward Kelley (1580s) como *Coronzon*, nome que os anjos dão ao "grande inimigo" — o diabo expulso do Éden. Fica adormecido por três séculos até Aleister Crowley, que o transforma na figura central da travessia do Abismo: o vazio entre os sefirot inferiores e os três supernos da Árvore da Vida, onde a personalidade se dissolve. Em dezembro de 1909, no deserto perto de Bou Saâda (Argélia), Crowley e Victor Neuburg invocam o 10º Aethyr, ZAX. Neuburg permanece dentro de um círculo traçado na areia; Crowley entra no triângulo da arte. […]
- Revisão anterior: **SEM REVISÃO**
- Prompt atual:
```prompt
1other, shapeshifting demon, unstable body made of swirling sand, multiple faces merging, woman face, serpent body, old man face, dissolving into sand, standing inside a glowing triangle drawn on desert sand, desert night, starry sky, sand yellow and void black, eerie pale light, full body
```

#### Triângulo da Arte  (`aby_triangulo`)
- Ficha: `cartas/abismo/02_triangulo_da_arte.md` · Relíquia
- Destino: `arte/abismo/aby_triangulo.png`
- Texto da carta: Equipe numa Entidade aliada: +0/+2. Conta como "Triângulo" para Sigilo 333.
- Contexto: O Triângulo da Arte (ou Triângulo de Salomão) é o espaço, fora do círculo do mago, onde o espírito evocado é obrigado a se manifestar. Na *Goetia* (Lemegeton, séc. XVII) ele é desenhado a dois pés do círculo, com os nomes Tetragrammaton, Primeumaton e Anaphaxeton nos lados e "Michael" dividido nos vértices; dentro dele fica o espelho negro ou o incensório. Na operação de Bou Saâda, Crowley fez o inverso do protocolo: entrou ele mesmo no triângulo, oferecendo o próprio corpo como receptáculo para Choronzon, enquanto Neuburg guardava o círculo. Daí a carta ser uma Relíquia **equipada** numa Entidade: alguém tem que ficar dentro do triângulo.
- Revisão anterior: **SEM REVISÃO**
- Prompt atual:
```prompt
no humans, object focus, glowing triangle drawn on desert sand, hebrew letters along the edges, black scrying mirror in the center, smoking incense burner, candles, desert night, starry sky, sand yellow and void black, eerie pale glow, from above
```

#### Círculo de Proteção  (`aby_circulo`)
- Ficha: `cartas/abismo/03_circulo_de_protecao.md` · Selo
- Destino: `arte/abismo/aby_circulo.png`
- Texto da carta: Quando uma Entidade inimiga atacar, o atacante sofre 2 de dano. Enquanto virado para baixo, conta como "Círculo" para Sigilo 333.
- Contexto: O círculo mágico é a fronteira entre o operador e o que ele evoca. Na *Goetia* tem nove pés de diâmetro, com os nomes divinos e os nomes dos sefirot escritos na banda externa; na tradição da Golden Dawn é traçado com a adaga ou a varinha, sempre no sentido do sol. Sair do círculo durante a evocação é a falha clássica — e exatamente o que Choronzon tenta provocar. Em Bou Saâda, Neuburg ficou dentro do círculo de areia com a adaga mágica. Choronzon, com conversa, apagou parte da linha com areia e se atirou sobre ele; Neuburg o repeliu e refez o círculo. A carta é um Selo porque o círculo é passivo até ser testado: só revela sua força quando algo tenta atravessá-lo.
- Revisão anterior: **SEM REVISÃO**
- Prompt atual:
```prompt
no humans, glowing magic circle drawn on desert sand, concentric rings, hebrew letters and sigils, ritual dagger stuck in the sand at the center, part of the line being erased by blowing sand, desert night, starry sky, sand yellow and void black, pale blue glow, from above
```

#### Sigilo 333  (`aby_sigilo`)
- Ficha: `cartas/abismo/04_sigilo_333.md` · Rito
- Destino: `arte/abismo/aby_sigilo.png`
- Texto da carta: Se você controla Triângulo da Arte e Círculo de Proteção e tem Choronzon na mão, invoque-o. Senão, compre 1 carta.
- Contexto: 333 é o número de Choronzon na gematria de Crowley (*Liber 777*; *The Vision and the Voice*, 10º Aethyr). É a metade de 666 — a Besta inteira contra a dispersão pela metade — e o número da "mente falsa", o tagarelar que impede o silêncio. No ZAX, Choronzon fala sem parar; cada frase é uma tentativa de dispersar a atenção de quem o ouve. Um sigilo, na magia cerimonial, é a assinatura gráfica de um espírito: traçá-lo e vibrar o nome é chamá-lo. Este Rito é o ato de pronunciar o nome com as peças no lugar. Sem as peças, é só um rabisco na areia — e o mago volta ao livro (compra 1 carta).
- Revisão anterior: **SEM REVISÃO**
- Prompt atual:
```prompt
no humans, object focus, occult sigil glowing red carved into dark sand, the number 333 formed by burning lines, swirling black smoke rising from the sigil, scattered ritual tools, desert night, sand yellow and void black, red glow, from above
```

