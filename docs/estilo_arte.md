# Estilo de arte — pixel art (aprovado em 2026-10-18)

Teste de referência: `cartas/_teste_estilo/boitata_A_pixel.png` (estilo A).
Modelo: ComfyUI local, checkpoint `Illustrious/pixelPerfect_v20.safetensors`, 768×1024 (3:4 em pé),
euler_ancestral / normal, 28 passos, CFG 6, seed derivada do id da carta (reprodutível).

Só a **ilustração**: sem moldura, sem texto, sem número, sem borda. O frame da carta entra depois.

## Prefixo fixo (o script adiciona; NÃO repetir no prompt da carta)
```
pixel art, masterpiece, best quality, detailed pixel art, 16-bit, limited palette, vertical composition, dark background
```

## Negativo fixo (o script adiciona)
```
lowres, blurry, text, watermark, signature, jpeg artifacts, worst quality, bad anatomy, smooth shading, 3d render, frame, border, card, letters, multiple views
```

## O que escrever no `## Prompt de arte` de cada carta
Um único bloco ```prompt com **tags separadas por vírgula** no estilo Illustrious (não frases longas), 25–45 tags, nesta ordem:
1. **Sujeito** (1 figura principal; `no humans` se for criatura/objeto; `1girl`/`1boy`/`1other` se humanoide — o modelo responde a isso), espécie/forma, 3–5 atributos visuais que identificam a figura na tradição (ex.: `four arms`, `blue skin`, `elephant head`, `single leg`, `red cap`).
2. **Pose/ação** que ecoa o efeito da carta (Guarda → postura defensiva de frente; Rito de dano → gesto de lançar; Relíquia → o objeto em destaque, flutuando ou em uma mão sem mostrar o rosto).
3. **Cenário** da tradição (floresta amazônica, deserto da Judeia, montanha de nuvens taoista, templo com lótus, clareira de sabá à luz da lua, câmara de ritual com círculo no chão).
4. **Luz e cor**: 2–4 tags (`rim lighting`, `glowing eyes`, `embers`, `moonlight`, `golden light`, `teal and orange`).
5. `full body` ou `upper body`/`portrait` — Entidades preferem `full body`; Relíquias `object focus, no humans`; Ritos podem ser cena.

Tags em inglês. Sem nomes próprios que o modelo não conhece (não escreva "Curupira": descreva "feet turned backwards, red hair, forest boy"). Para Selos, prefira a cena da armadilha (ex.: `trap, glowing runes on ground, ambush, hidden`), em tom mais escuro. Mantenha um ponto focal: pixel art em 768×1024 perde detalhe fino; evite multidões.

### Exemplo (Boitatá, aprovado)
```prompt
no humans, giant fire serpent, serpent made of orange and blue flames, huge glowing yellow eyes, coiled in dark brazilian rainforest at night, river, giant ferns, fireflies, embers, dramatic rim lighting, full body
```

## Paleta por cultura (1–2 tags de cor a incluir)
| Cultura | Tags |
|---|---|
| indígena | `green and orange`, `jungle`, `firelight` |
| cristianismo | `gold and white`, `stained glass light`, `holy light` |
| taoismo | `jade green and vermilion`, `mist`, `ink wash feel` |
| hinduísmo | `saffron and blue`, `gold ornaments`, `lotus` |
| bruxaria | `purple and green`, `moonlight`, `candlelight` |
| alta magia | `black and gold`, `red candlelight`, `glowing sigils` |
| abismo (Choronzon) | `sand yellow and void black`, `desert night` |
