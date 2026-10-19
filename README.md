# Gods Kodex

Jogo de cartas mobile (Godot 4.7, retrato) com seis tradições mitológicas — indígena brasileira, cristianismo,
taoismo, hinduísmo, bruxaria e alta magia — e o Conjunto do Abismo (Choronzon).

**© 2026 Sapyst — todos os direitos reservados. Veja [LICENSE](LICENSE).**

📖 **[Wiki KodeX](wiki/README.md)** — todas as cartas com arte, atributos, texto e contexto mitológico.

## Jogar (teste)
Baixe o APK na aba **Releases** e instale no Android (permitir "fontes desconhecidas").
- **Torneio:** escolha um deck e enfrente os cinco campeões na Encruzilhada e, por fim, Silas Ashcombe, o Magus do Triângulo.
- **Arcade:** escolha oponente (ou aleatório), seu deck (temático, misto ou aleatório) e o deck do oponente.

## Estrutura
| Pasta | Conteúdo |
|---|---|
| `docs/` | regras, linguagem de efeitos, lore do torneio |
| `cartas/<deck>/` | fichas das 161 cartas (estudo, contexto, balanço, JSON, prompts de arte) |
| `sim/` | simulador de duelos em Python e relatórios de balanceamento |
| `arte/` | artes aprovadas (Krea 2 + LoRA Chaotic Shapes), frame do mapa e scripts de geração/montagem |
| `godot/` | o jogo (mesa em pixel art 360×640 ×2, torneio, arcade) |

## Regerar
```
python3 godot/exportar_cartas.py                      # fichas → godot/dados/cartas.json
python3 arte/montar_cartas.py --versao v1             # artes → cartas no frame (cartas_finais/)
python3 godot/preparar_assets.py --versao v1          # imagens em tamanho de celular
```
