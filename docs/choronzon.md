# Conjunto do Abismo — Choronzon (carta já definida, fora do balanceamento)

Módulo de **4 cartas** que pode substituir 4 cartas de qualquer deck. Condição de vitória alternativa ("Exódia"):
reunir as 4 na mão/campo e completar o ritual. Mão inicial de 4 = possibilidade (remota) de vitória no turno 1 — é a aposta do módulo.

## Contexto

Choronzon é o "Habitante do Abismo" da tradição enochiana (John Dee e Edward Kelley, séc. XVI, onde aparece como *Coronzon*, o diabo), retomado por Aleister Crowley. Em dezembro de 1909, no deserto da Argélia, Crowley e Victor Neuburg invocaram o 10º Aethyr (ZAX): Neuburg ficou dentro de um círculo de proteção traçado na areia, Crowley dentro do triângulo da arte, onde Choronzon se manifestou — mudando de forma, tentando convencer Neuburg a sair do círculo, apagando parte da linha com areia e atacando-o. Choronzon é o número **333**: dispersão, a mente que se desfaz quando o ego atravessa o Abismo entre os sefirot. Não é um demônio a ser derrotado — é a dissolução de quem o invoca.

Por isso a carta não ataca nem defende: **se entra na mesa, acabou.**

## As 4 cartas

### 1. Choronzon, Habitante do Abismo — Entidade, Lendária
- Custo: — (não pode ser invocado pagando Fé). ATK 3 / Vida 3 (irrelevante).
- Texto: *"Só pode ser invocado pelo efeito de Sigilo 333. Quando Choronzon entra em campo, você vence o jogo."*
```json
{ "id": "aby_choronzon", "nome": "Choronzon, Habitante do Abismo", "cultura": "abismo", "tipo": "entidade",
  "custo": 99, "atk": 3, "vida": 3, "lendaria": true, "keywords": [], "sacrificio": 0,
  "efeitos": [ { "gatilho": "on_play", "acoes": [ { "op": "win" } ] } ], "usos": null }
```

### 2. Triângulo da Arte — Relíquia
- Custo 2. Equipa uma Entidade aliada: +0/+2. Enquanto estiver em campo, conta como "Triângulo" para o Sigilo 333.
```json
{ "id": "aby_triangulo", "nome": "Triângulo da Arte", "cultura": "abismo", "tipo": "reliquia", "custo": 2,
  "atk": null, "vida": null, "lendaria": true, "keywords": [], "sacrificio": 0,
  "efeitos": [ { "gatilho": "on_equip", "acoes": [ { "op": "buff", "alvo": "equipped", "atk": 0, "vida": 2, "perm": true } ] } ], "usos": null }
```

### 3. Círculo de Proteção — Selo
- Custo 2. Gatilho: quando uma Entidade inimiga atacar, o atacante leva 2 de dano. Enquanto virado para baixo em campo, conta como "Círculo" para o Sigilo 333.
```json
{ "id": "aby_circulo", "nome": "Círculo de Proteção", "cultura": "abismo", "tipo": "selo", "custo": 2,
  "atk": null, "vida": null, "lendaria": true, "keywords": [], "sacrificio": 0,
  "efeitos": [ { "gatilho": "enemy_attacks", "acoes": [ { "op": "damage", "alvo": "attacker", "n": 2 } ] } ], "usos": null }
```

### 4. Sigilo 333 — Rito
- Custo 3. *"Se você controla Triângulo da Arte e Círculo de Proteção e tem Choronzon na mão, invoque-o. Senão, compre 1 carta."*
- Regra especial do motor: `ritual_choronzon` — verificar as duas peças em campo (Círculo pode estar virado para baixo) e Choronzon na mão; invocar ignora custo e slots; se falhar, `draw 1`.
```json
{ "id": "aby_sigilo", "nome": "Sigilo 333", "cultura": "abismo", "tipo": "rito", "custo": 3,
  "atk": null, "vida": null, "lendaria": true, "keywords": [], "sacrificio": 0,
  "efeitos": [ { "gatilho": "on_play", "acoes": [ { "op": "ritual_choronzon" } ] } ], "usos": null }
```

## Notas de design
- Custo total do ritual: 2 + 2 + 3 = **7 Fé** em turnos diferentes, + as 4 cartas certas na mão. Cedo demais é improvável; no meio do jogo o oponente vê Relíquia + Selo e pode destruir a portadora do Triângulo (a Relíquia vai ao cemitério) — contra-jogo existe.
- O simulador **não** inclui estas 4 cartas. Só `ritual_choronzon` e `win` precisam existir no motor para o jogo final.
- Arte: Choronzon muda de forma — a imagem deve ser uma figura instável dentro de um triângulo na areia, sob céu de deserto, com partes do corpo diferentes (mulher, serpente, Crowley velho, Neuburg) se dissolvendo em areia.
