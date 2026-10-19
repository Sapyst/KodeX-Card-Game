# Bruxaria — revisão (design + pesquisa)

Revisão feita sobre a tabela §10 **oficial** de `docs/regras.md` (freeze 1,5 · silence 2 · buff em todas as aliadas = unitário × 3 · Relíquia com Usos = efeito × N × 0,7 · gatilhos repetíveis valem cheio · Sacrifício conta como morte mas **não** aciona Renascer) e sobre a semântica de `usos` de `docs/dsl_efeitos.md` (buffs de `on_equip` somem quando a Relíquia sai, inclusive por Usos esgotados). `python3 sim/validar.py cartas/bruxaria` → `OK` após as correções.

## Carta a carta

| NN | Carta | O que mudou | Por quê |
|---|---|---|---|
| 01 | Sapo Familiar | Contexto: citação do *Malleus* generalizada para "parte II, q.1"; Balanço anota que `on_death` vale cheio. | O capítulo II.1.15 do *Malleus* trata de tempestades; a referência exata a sapos é incerta. Orçamento 3/3, ok. |
| 02 | Gato Preto | Contexto: substituída a frase sobre "gravura de gato em Guazzo" (não verificável) por Alain de Lille (*cattus* → cátaros, séc. XII). **Papel no jogo reescrito**: o Gato sacrificado **não volta**. | Renascer não dispara em Sacrifício (§2). A carta contava com "sacrifica, volta, sacrifica de novo". 5/5 pts, ok. |
| 03 | Corvo Agourento | Contexto: corvo no ombro de Cú Chulainn atribuído a *Aided Con Culainn*, não ao *Táin*. | Erro de fonte: a morte do herói é um relato separado do ciclo do Ulster. 5/5, ok. |
| 04 | Strega de Benevento | ok | 7/7. Fontes conferidas (Ovídio *Fastos* VI, Petrônio 63, Apuleio III.21, Piperno 1635). |
| 05 | Benandante | Balanço refeito: freeze 1,5 → 6,5/7. | Deck usava freeze = 2. Fica 0,5 abaixo; dentro da tolerância, não precisa fortalecer. |
| 06 | Circe | ok | 9/9 com `set_stats` = 3 (convenção do deck, registrada em `_deck.md`). Fontes corretas. |
| 07 | Medeia | Contexto: o dragão é adormecido no livro IV das *Argonáuticas* (não III); em Apolônio quem mata Apsirto é **Jasão**, em emboscada armada por Medeia — a versão em que ela própria o esquarteja é de Apolodoro/Ovídio (*Tristia*). | Erros de pesquisa. 9/9, ok. |
| 08 | Bruxa de Endor | Contexto: midrash corrigido (os evocados sobem de cabeça para baixo, **menos** Samuel, que sobe em pé — *Hagigá* 4b, *Lev. Rabá* 26); removida a referência "I, q.16" do *Malleus* (não verificável). | Erros de pesquisa. 9/9, ok. |
| 09 | Baba Yaga | Papel: "Gato (que volta à mão)" corrigido. | Renascer não dispara em Sacrifício. 13/13 (P inclui +2 do Sacrifício 1), ok. |
| 10 | Cerridwen | ok | 11/11. *Hanes Taliesin* conferido. |
| 11 | A Morrigan | **5/6 → 5/5.** Contexto: corvo no ombro atribuído a *Aided Con Culainn*. Balanço refeito. | Com gatilhos repetíveis valendo cheio (2 + 2) + Ímpeto 1 + 5/6 = 16 > teto lendário 15. Cortou-se 1 de Vida → 15 exato. |
| 12 | Hécate | Contexto: Ovídio chama Hécate *triformis* em *Met.* VII.94 e *triceps* em VII.194 (a carta citava *triformis* em 194). Balanço reescrito: P = 17, teto lendário 19, gasto 19. | Erro de citação. Debuff em área precificado a 1,5/ponto por analogia com dano em área (a tabela não cobre); se o simulador usar o espelho de "buff em aliadas" (×3), a carta estoura — anotado. |
| 13 | Mau-Olhado | Balanço refeito: freeze 1,5 → 3,5/4. | Dentro, 0,5 de folga. |
| 14 | Círculo de Sal | Papel: avisa que `enemy_attacks` não dispara em ataque à Cornucópia (campo vazio). | Gatilho real, mas condicionado a haver familiar na mesa. 5,5/6, ok. |
| 15 | Garrafa de Bruxa | ok | 5/6. Tipo Selo mantido: é objeto **enterrado e escondido** que reage ao feitiço lançado contra a casa — a natureza é de armadilha, não de item portado. |
| 16 | Boneco de Cera | Texto já dizia "atacante"/"de um ataque"; Papel ganha aviso sobre dano vindo de Rito (Selo dispara em branco). | Pela regra de resolução o `attacker` inexistente é pulado, mas o Selo é consumido. 7/8, ok. |
| 17 | Poção de Beladona | Contexto: "hioscina e escopolamina" são a mesma substância → "atropina, hiosciamina e escopolamina (hioscina)"; receita de della Porta corrigida (solano, pentafilo, sangue de morcego, fuligem; meimendro/papoula vêm de Cardano). Papel: as duas ações devem cair na mesma Entidade. | Erros farmacológicos/de fonte; JSON tem dois alvos `ally_entity` escolhidos. 3/3, ok. |
| 18 | Pacto na Encruzilhada | Papel: "Malefício + Benandante no turno 3" → "Malefício + Vassoura no turno 3". | Conta errada: 3 − 1 + 2 = 4 Fé, não 6. 3/3, ok. |
| 19 | Seiðr | ok | 2/3, 1 pt abaixo de propósito (tutor). Fontes corretas. |
| 20 | Pó de Ossos | ok | 5/5. |
| 21 | Malefício | Papel: as duas ações recaem na mesma Entidade escolhida. | JSON tem dois alvos `enemy_entity`. 6/7, ok. |
| 22 | Sabá de Walpurgis | **Custo 3 → 4.** Balanço e Papel refeitos. | Pela tabela oficial, +1/+1 em todas = 2 × 3 = 6, + Lebre 2 = 8 > 7. A custo 4 (P = 9) fica em 8. Mantém o combo Strega T3 → Sabá T4. |
| 23 | Vassoura | ok | 3/4. |
| 24 | Livro das Sombras | **Usos 2 → 3**; texto diz "+1/+1 enquanto o porta"; Papel corrige "o +1/+1 fica" → some. | Pela regra oficial o buff de `on_equip` some com os Usos e a compra vale ×N×0,7: a versão antiga somava 3,1 (< P−2 = 4). Com Usos 3: 1,4 + 3,15 = 4,55, dentro. |
| 25 | Caldeirão de Renascimento | Papel: confirma pela regra de resolução que a própria portadora pode ser revivida; levanta a questão do Despertar ao reviver. | 8/8, ok. Ver ponto 1 do simulador. |
| — | `_deck.md` | Tabela de convenções enxugada (freeze/silence/×3/×0,7/gatilhos cheios agora são oficiais); nova convenção "buff `on_equip` com Usos × 0,7"; lista atualizada (Morrigan 5/5, Sabá 4, Livro Usos 3); identidade e linha "Pacto" corrigem o Gato; seção "Sanidade do deck". | — |
| — | `_estudo.md` | Entradas 5 (Morrigan) e 31 (Sapo) alinhadas com as correções acima. | — |

Tipos: nenhuma troca necessária — objetos portados são Relíquias (Vassoura, Livro, Caldeirão); objetos escondidos/proteções/malefícios passivos são Selos (Garrafa, Boneco, Círculo, Mau-Olhado); poções e cerimônias são Ritos; seres são Entidades. 14/6/8/4 mantidos.

## Erros de pesquisa encontrados

1. **Corvo no ombro de Cú Chulainn atribuído ao *Táin Bó Cúailnge*** (Corvo, Morrigan, `_estudo`): é de *Aided Con Culainn*, relato separado do ciclo do Ulster.
2. **Medeia**: dragão adormecido em *Argonáuticas* IV, não III; em Apolônio quem mata Apsirto é Jasão (a versão do esquartejamento por Medeia é Apolodoro/Ovídio).
3. **Hécate**: Ovídio, *Met.* VII.194 diz *triceps*; *triformis* está em VII.94.
4. **Bruxa de Endor**: o midrash diz que Samuel subiu **em pé**, ao contrário dos outros evocados; referência "Malleus I, q.16" não verificável, removida.
5. **Poção de Beladona**: "hioscina" = escopolamina (duplicado); receita de della Porta misturava ingredientes de Cardano/Weyer.
6. **Sapo Familiar / `_estudo`**: "Malleus II.1.15" (capítulo sobre tempestades) → generalizado.
7. **Gato Preto**: "gravura de gato em Guazzo" não verificável → substituída por Alain de Lille (*cattus*/cátaros).
8. **Pacto na Encruzilhada**: conta de Fé errada no Papel (Malefício + Benandante não cabe no turno 3).

Sem erros encontrados em: Strega (Ovídio, Petrônio, Apuleio, Piperno), Benandante (Ginzburg), Circe (Homero, Ovídio, Apolônio), Baba Yaga (Afanasiev 104, Propp), Cerridwen (*Hanes Taliesin*), Seiðr (*Ynglinga saga* 4/7, *Eiríks saga* 4), Boneco (Teócrito, *Amores* III.7.29–30, Lancashire, North Berwick), Garrafa (Merrifield, Blagrave), Sabá (Ginzburg HN, Praetorius, Gowdie), Vassoura (Le Franc 1451), Caldeirão (*Branwen*, Gundestrup), Mau-Olhado (Plutarco, Plínio VII.16), Pacto (Teófilo, *Historia* 1587, Loudun, *Malleus* II.1.2).

## Sanidade do deck

- Dano direto à Cornucópia: **0** (confirmado — nenhum `damage` em `enemy_cornucopia`).
- `counter`: 1 (Garrafa) ≤ 3. `destroy`: 1 (Baba Yaga) ≤ 4.
- `discard`: **5 ocorrências** (Corvo 1, Círculo ×2, Garrafa 1, Pó de Ossos 1) — exatamente no limite; qualquer carta nova com descarte deve substituir uma destas.
- Combos turno 3–4: Strega T3 → Sabá T4 (agora 4 Fé: 3/4 + 2/2 + Lebre) é o combo de curva pretendido e cabe no orçamento. Pacto T4 → Baba Yaga T4 (4/5 + destroy) exige Pacto + Baba Yaga + familiar em campo, três cartas de 1 cópia: raro, aceitável. Vassoura + Morrigan: só 1 Relíquia por Entidade e ela já tem Ímpeto — a Vassoura nela é só +1/+1 (6/6 Ímpeto no T6, ou T5 com Pacto); forte, mas é a Lendária.
- Selos: todos com gatilhos reais (invocar, atacar Entidade, jogar Rito, aliada ferida). Ressalvas anotadas nas cartas: Círculo não dispara em ataque à Cornucópia; Boneco dispara em branco se o dano vier de Rito.

## 3 pontos para o simulador observar

1. **Reviver para o campo e Despertar.** O Caldeirão de Renascimento pode trazer de volta a própria portadora (ela já está no cemitério quando `equipped_dies` resolve). Se `revive` → `field` disparar `on_play`, Baba Yaga volta destruindo outra Entidade e Hécate volta com outro −2/−2 em área — e sem pagar Sacrifício. Medir a taxa de vitória com e sem Despertar no revive; se for preciso, a regra "revive não dispara Despertar" resolve sem mexer na carta.
2. **Debuff em área (Hécate) e `set_stats` (Circe) não estão na tabela §10.** Hécate foi precificada a 1,5/ponto (6 pts para −2/−2 em todas); se os dados mostrarem que o −2/−2 em área varre o campo inimigo com frequência maior que um "dano 2 em área" equivalente, reprecificar (o espelho de "buff em aliadas ×3" daria 12 pts e exigiria −1/−1). Circe a 3 pts assume que deixar um 1/1 no slot inimigo vale ~1 pt menos que destruir.
3. **Mesmo alvo em duas ações escolhidas.** Poção de Beladona (`heal` + `buff` em `ally_entity`) e Malefício (`buff` + `silence` em `enemy_entity`) têm duas ações com alvo "escolhido" no mesmo efeito. O texto das cartas exige **uma** escolha aplicada às duas ações; o motor deve reutilizar o alvo escolhido dentro do mesmo efeito (não pedir duas escolhas, nem sortear). Também vigiar o Livro das Sombras: com draw ×0,7 ele ficou 1,45 pt abaixo do orçamento — se três compras por 2 Fé se mostrarem fortes na prática (como suspeitamos), voltar a Usos 2.
