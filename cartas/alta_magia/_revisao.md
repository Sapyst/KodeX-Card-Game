# Revisão — Deck Alta magia (`alt`)

Revisão de design e de pesquisa sobre a primeira versão do deck, com a tabela §10 oficial de `docs/regras.md` (freeze 1,5 · silence 2 · cura/buff em todas ×3 · aura 3 · Usos ×N×0,7 · gatilhos repetíveis cheio · Sacrifício conta como morte mas não aciona Renascer) e a DSL atual. `python3 sim/validar.py cartas/alta_magia` → **OK** (1 aviso informativo na Babalon, explicado abaixo).

## Carta a carta

| # | Carta | Orçamento (P → gasto) | O que mudou e por quê |
|---|---|---|---|
| 01 | Homúnculo ×2 | 5 → 1+2+1,5 = 4,5 | ok. |
| 03 | Edward Kelley | 5 → 0+2+1+2 = 5 | ok. Pesquisa conferida (1555–1597, Rodolfo II, Casaubon 1659). |
| 04 | Silfo | 5 → 1+2+1+1 = 5 | ok. |
| 05 | Vassago ×2 | 7 → 2+3+2 = 7 | **Pesquisa**: removida a afirmação de que "Crowley o classifica entre os bons" (não existe tal classificação na edição de 1904; é a própria Goetia que diz *of a good nature*). Acrescentado que Vassago **não consta em Weyer** — é um dos quatro espíritos (Vassago, Seere, Dantalion, Andromalius) acrescentados pelo compilador do Lemegeton. |
| 07 | Orobas | 7 → 1+4+1+1 = 7 | ok. Cura 2 em si no `start_turn` contada como 1 (valor cheio, uma vez). |
| 08 | Andras | 9 → 3+3+4×0,7 = 8,8 | ok. `destroy` condicional `target_cost_max 2`. |
| 09 | Marbas | 9 → 3+4+2 = 9 | ok (silence agora tabelado = 2, bate com a estimativa do autor). |
| 10 | Astaroth | 9+2 = 11 → 3+5+3 = 11 | ok. |
| 11 | Dantalion | 11+2 = 13 → 3+4+6 = 13 | ok. `swap_control` permanente mantido em 6 pts (destruir 4 + ganhar o corpo 2); custo 5 + Sacrifício 1 confere. Pesquisa: acrescentado que também é um dos quatro ausentes em Weyer. |
| 12 | Paimon | 13+2 = 15 → 4+5+4+1,5 = 14,5 | ok. Pesquisa: explicado o título "Rei do Oeste" (Weyer: observado para o Ocidente; Lemegeton: Noroeste). |
| 13 | Babalon (Lend.) | 13+2+2 = 17 → **4/6** = 10 + 2 gatilhos ×2 = 14 (tabela) / 16 (3 mortes esperadas) | **Corte**: era 5/6. Com `ally_dies` + `enemy_dies` num deck de Sacrifício e tokens, 3 mortes enquanto ela vive são o caso normal → 11+6 = 17–19, acima do teto. Com 4/6 fica 16 (3 mortes) a 18 só no caso raro de 4. Corrigido também o "Papel": o Sacrifício que paga a invocação ocorre **antes** de ela entrar, portanto **não** a alimenta (texto antigo dizia "entra 6/7"). Pesquisa: "156 = número da Cidade das Pirâmides" estava errado — 156 é BABALON e *Tzion*; a Taça está em *Liber Cheth* (Liber 156). O validador avisa que o corpo é baixo para P: é intencional, o crescimento é a habilidade. |
| 14 | Anjo Guardião (Lend.) | 15+2 = 17 → 4+8+1+2+2 = 17 | ok, no teto (como o roteiro previa). Lembrete: Renascer devolve à mão e permite curar 4 de novo por mais 7 Fé. |
| 15 | Pentagrama Flamejante ×2 | 5+1 = 6 → 3+1,5 = 4,5 | ok. **Pesquisa**: "Crowley recomenda trazer o pentagrama ao peito" → é o **Lemegeton** que manda vestir o Pentagrama de Salomão ao peito; a edição de 1904 só reproduz a figura. |
| 17 | Selo de Salomão | 7+1 = 8 → (4+1)+1,5 = 6,5 | **×2 → ×1** para o deck ficar com 3 contadores (Pentagrama ×2 + este). Anular Entidade valorado em 5 (destruir 4 + nega Despertar/Sacrifício já pago), não 4 — com isso fica dentro de P−2 e não precisa ser fortalecido. Pesquisa: a frase "em Agrippa III.11 o hexagrama encerra o Tetragrammaton" não se sustenta; trocada por referência correta (nomes divinos em Agrippa III.11 e Reuchlin 1494). |
| 18 | Solve et Coagula ×2 | 3+1 = 4 → 2+1,5 = 3,5 | ok. Renumerado 19→18. Pesquisa: "Basílio Valentim repete o lema no *Azoth*" removido (o lema é máxima anônima dos séc. XVI–XVII). |
| 20 | Sigilo de Spare | 3+1 = 4 → 2+1,5 = 3,5 | **Rito → Selo** (custo 1, `enemy_end_turn`: oponente descarta 1 aleatória, você compra 1). Motivo duplo: (a) natureza — o sigilo de Spare é carregado, **esquecido** e dispara sozinho mais tarde: é armadilha, não operação imediata; (b) estrutura — com Selo de Salomão em ×1 faltava um Selo e não há outro Selo em ×1 para subir. Compra 1 adicionada para fechar o orçamento. Pesquisa: Crowley **admitiu** Spare na A∴A∴ como *Probationer* (1909) e o perdeu em seguida — o texto antigo dizia que Spare "recusou o convite". Arquivo 26→20. |
| 21 | Lemegeton ×2 | 3 → 2 | ok (P−1, tutor puro). Pesquisa: "Chave enochiana preliminar" → Invocação Preliminar (Rito do Sem-Cabeça) + conjurações em enochiano. |
| 23 | Azoth ×2 | **7 → 4+1,5 = 5,5** | **Custo 2 → 3, +"compre 1 carta"**. Dois Azoth a custo 2 davam Astaroth no T3 e Dantalion no T4 num deck que também nega tudo; a custo 3 a rampa chega um turno depois e a compra evita perda de carta. Pesquisa: *Azoth* de "Basílio Valentim" é Frankfurt 1613 (Paris é a versão francesa, 1624). |
| 25 | Conjuração dos Elementais | 7 → 6 | **×1 → ×2** para repor o slot de Rito do Sigilo. É o Rito de *invocação* do deck (metade da identidade) e gera o fodder dos pactos. |
| 27 | Ritual Menor do Pentagrama | 9 → 2×n (4–8) | ok. Pesquisa conferida (nomes, quadrantes, arcanjos, Liber O). |
| 28 | Abrahadabra | 9 → 6+1,5 = 7,5 | ok. Pesquisa: "418 = número de Hórus" era impreciso → 418 = Abrahadabra = *Cheth* por extenso = Boleskine (na contagem de Crowley) = Liber 418, "número da Grande Obra realizada". |
| 29 | Anel de Salomão | 5+1 = 6 → 2+1+2 = 5 | ok (silence em `equipped_attacks` contado cheio, uma vez). |
| 30 | Sigillum Dei Aemeth | 5+1 = 6 → 3+1+1,5 = 5,5 | ok. Pesquisa: precisado que o British Museum guarda **três** discos (o grande e dois pequenos). |
| 31 | Pedra de Visão de Dee ×2 | 3+1 = 4 → 2+1,5 = 3,5 | ok. |

**Tipos**: 14/6/8/4 mantidos (troca em par: Sigilo de Spare Rito→Selo, Selo de Salomão ×2→×1, Conjuração ×1→×2). Lemegeton (livro) e Azoth (substância) foram avaliados para Relíquia e **mantidos como Rito**: a carta representa a *operação* (abrir o grimório e chamar o nome; a Obra que acelera), não o objeto equipado — e `search`/`gain_fe` não têm leitura sensata como Relíquia equipada.

**JSON × texto**: conferidos um a um; todos ≤ 30 palavras (máx. 21, Solve et Coagula).

## Erros de pesquisa encontrados (resumo)

1. Vassago — "Crowley o classifica entre os bons" (inexistente); omitia que Vassago e Dantalion não estão em Weyer.
2. Pentagrama Flamejante — atribuía a Crowley a prescrição do pentáculo ao peito, que é do Lemegeton.
3. Selo de Salomão — "Agrippa III.11: hexagrama encerra o Tetragrammaton" (não é o que o capítulo diz).
4. Babalon — 156 chamado de "número da Cidade das Pirâmides" (é BABALON/Tzion; Liber Cheth = 156).
5. Abrahadabra — 418 chamado de "número de Hórus" (impreciso).
6. Solve et Coagula — lema atribuído ao *Azoth* de Basílio Valentim.
7. Azoth — "Paris, 1613" (Frankfurt 1613; Paris 1624).
8. Sigilo de Spare — "Spare recusou o convite de Crowley" (foi admitido como Probationer e saiu).
9. Lemegeton — "Chave enochiana preliminar" (confusão entre a Invocação Preliminar e as conjurações em enochiano).
10. Sigillum Dei Aemeth — "os discos" sem número (são três no BM).

Hierarquias e legiões goéticas conferidas e corretas: Vassago príncipe 26 · Marbas presidente 36 · Paimon rei 200 · Astaroth duque 40 · Orobas príncipe 20 · Andras marquês 30 · Dantalion duque 36.

## Sanidade do deck

| Medida | Antes | Depois | Teto |
|---|---|---|---|
| `counter` (cópias) | 4 | **3** | 3 |
| `destroy` | 1 | 1 | 4 |
| Dano direto à Cornucópia | 3 | 3 | 8 |
| `search` (com cópias) | 5 | 5 | 5 |
| Combo de 2 cartas que vence no T3–4 | não | não | — |
| Selos com gatilho real | 6/6 | 6/6 | — |

## Três pontos para o simulador observar

1. **Rampa + negação.** Azoth ×2 (custo 3) + 3 contadores + bounce em massa: medir a taxa de vitória contra decks de agressão (bruxaria, indígena) e, sobretudo, a **duração das partidas** — se o deck empurra os jogos acima de 10 turnos, cortar Azoth para ×1 ou Ritual Menor do Pentagrama para custo 5. Também verificar a leitura do motor: `gain_fe perm` deve subir a **Fé máxima** (sem restaurar a Fé atual no turno), teto 8.
2. **Babalon e a contagem de mortes.** Registrar quantas vezes `ally_dies`/`enemy_dies` disparam enquanto ela vive (tokens de Paimon e Elementais contam; o Sacrifício que a invoca **não** conta, pois ela ainda não está em campo). Se a média passar de 4 gatilhos, voltar a avaliar (4/5); se ficar abaixo de 2, o corte foi excessivo (5/6).
3. **Dantalion `swap_control` permanente** sobre a Lendária inimiga e **Selo de Salomão** anulando uma Entidade de custo 6–8: medir o *swing* por partida. Se Dantalion roubar a Lendária em mais de ~30% dos jogos em que entra, acrescentar `cond: target_cost_max` (ex.: 5) ou subir para custo 6; se o Selo de Salomão anular a Lendária inimiga em mais de metade dos jogos em que é colocado, limitar com `target_cost_max`. Observar ainda a interação Sacrifício × Último Sopro × Solve et Coagula: o Sacrifício ocorre no turno do dono, então o Selo **não** dispara — confirmar que o motor respeita isso.
