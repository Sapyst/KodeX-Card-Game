# KodeX — Modos solo (itens 19 a 25)

Desenho de 2026-10-21. Tudo offline, usando a mesa, a IA (Aprendiz/Mestre/Arquimago) e o pergaminho que já existem.
Números são o ponto de partida; o balanço muda depois de jogar.

## Onde ficam
Card novo **Solo** no leque do Início, que abre uma tela com os modos em lista (rolagem): Peregrinação, Desafio do dia,
Desafios lendários, Enigmas, Modo livre e, depois de vencer o Torneio, **Choronzon** (antes disso aparece trancado com
"vença o Torneio para abrir").

## 19. Peregrinação (roguelike)
- Escolhe uma tradição. Deck inicial: as **32 cartas temáticas da tradição** (o deck do personagem).
- **8 paradas** em sequência; em cada uma, escolhe entre **2 caminhos** sorteados: Batalha (Mestre), Elite (Arquimago,
  prêmio maior), Santuário (+5 de Cornucópia), Mercador (troca 1 carta por outra entre 3).
- A **Cornucópia persiste** entre as batalhas (começa em 15, máximo 20). Zerou = fim da peregrinação.
- **Deck vazio reembaralha de graça** (sem pagar 5 de Cornucópia, sem exigir 6+), para os dois lados — regra só deste modo.
- Depois de cada vitória: escolhe **1 de 3 cartas** (de todas as tradições, sem Abismo) para **trocar** por uma carta do
  deck à sua escolha, ou pular.
- **Bênçãos** (relíquias passivas), 1 por Elite vencida, escolhida entre 3: +1 Fé no 1º turno; +3 Cornucópia máxima;
  a 1ª Entidade de cada batalha tem Ímpeto; compra 1 carta extra no 1º turno; Selos custam 1 a menos (mínimo 0);
  Ritos de dano causam +1.
- **Parada 8 = chefe**: Arquimago com a Lendária da tradição sorteada e 20 de Cornucópia.
- Prêmio: 20 moedas por vitória e, ao vencer o chefe, +100 moedas e 1 booster grátis.
- Progresso salvo no perfil (dá para fechar o app no meio).

## 20. Enigmas ("vença neste turno")
- Mesa montada: suas Entidades, as dele, sua mão, sua Fé e a Cornucópia dele. Um turno só: zerar a Cornucópia vence;
  passar o turno sem vencer = tentar de novo.
- Enigmas guardados em `godot/dados/enigmas.json` e **conferidos por busca** (o planejador do Arquimago testa se há
  solução e se ela não é trivial). Primeira leva: 12 enigmas, 3 por dificuldade (1 a 4 estrelas).
- Prêmio: 10 moedas por enigma resolvido pela 1ª vez.

## 21. Desafios lendários
- Um por Lendária (12). Você joga com o **seu deck em uso** contra o campeão da tradição da Lendária, no nível mais
  difícil, com o deck temático dele e a **Lendária garantida na mão inicial** do oponente.
- Vencer pela 1ª vez: ganha a **Lendária** (ou, se já tiver, 60 moedas). Vencer de novo: 15 moedas.

## 22. História em capítulos
- O Torneio vira **6 capítulos** com tela de título ("Capítulo 3 · A Guardiã da Mata"), as falas que já existem antes e
  depois de cada luta, epílogo e **créditos** no fim.
- Capítulos vencidos ficam marcados; dá para rever as falas na Coleção (aba de lore do personagem).

## 23. Choronzon (chefe secreto)
- Abre depois de vencer o Torneio. Choronzon joga com o **Conjunto do Abismo** misturado a cartas das 6 tradições.
- Regras do chefe: Choronzon começa com **30 de Cornucópia**, IA Arquimago, e a cada 3 turnos dele invoca um Sigilo.
- Vencer: título "Selador do Abismo", 200 moedas e 2 boosters (uma vez).

## 24. Desafio do dia
- Todo dia (hora do servidor, igual ao presente diário): mesma partida para todo mundo — oponente, decks e embaralhamento
  sorteados com a **semente do dia** (número do dia de Brasília).
- Uma tentativa valendo prêmio por dia: vitória = 30 moedas. Pode jogar de novo, sem prêmio.

## 25. Modo livre
- Deck montado com **qualquer carta**, mesmo sem tê-la (mesmas regras: 32 cartas, Lendária 1, demais 2).
- Joga contra a IA no nível que escolher. **Sem prêmios**; serve para testar ideias de deck.
