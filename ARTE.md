# KodeX — Artes (base da versão Alpha)

Este documento descreve **como as artes do KodeX foram feitas** e a configuração usada.
As 161 ilustrações deste repositório são as **cartas base da versão Alpha (v0.1.0-alpha)**: servem para jogar e testar,
e podem ser refeitas, refinadas ou substituídas antes de uma versão final.

© 2026 Sapyst — todos os direitos reservados (ver [LICENSE](LICENSE)).

## O que está no repositório

| Pasta | Conteúdo |
|---|---|
| `arte/<deck>/<id>.png` | ilustração escolhida de cada carta (768×1024, 3:4) — 161 cartas + 12 tokens em `arte/tokens/` |
| `cartas_finais/v1/<deck>/<id>.png` | carta montada no frame (720×1008, proporção 63×88 mm) |
| `cartas_finais/v1/_backup/` | gerador do frame e configuração exata usada na montagem da v1 |
| `arte/personagens/<deck>.png` | os 6 personagens do torneio, recortados (fundo transparente) |
| `arte/logo/` | logo KodeX (gerado por código) |
| `godot/assets/` | as mesmas artes em tamanho de celular, usadas pelo jogo |

Decks: indígena brasileira (`ind_`), cristianismo (`cri_`), taoismo (`tao_`), hinduísmo (`hin_`), bruxaria (`bru_`),
alta magia (`alt_`) e o Conjunto do Abismo (`aby_`).

| Tipo | Cartas |
|---|---|
| Entidades | 73 |
| Ritos | 38 |
| Selos (armadilhas) | 29 |
| Relíquias | 21 |

## 1. Ilustrações das cartas

Geradas localmente no **ComfyUI** (GPU de 8 GB), uma a uma, a partir do prompt escrito na ficha de cada carta.

| Item | Valor |
|---|---|
| Modelo | **Krea 2 Turbo** — `krea2_turbo_nvfp4.safetensors` (Comfy-Org/Krea-2, Hugging Face) |
| Codificador de texto | `qwen3vl_4b_bf16.safetensors` (CLIPLoader, tipo `krea2`) |
| VAE | `qwen_image_vae.safetensors` |
| LoRA de estilo | **Chaotic Shapes** (Krea 2) — `Chaotic_Shapes_krea2.safetensors`, força 1,0 (Civitai, modelo 2990211) |
| Gatilho do LoRA | `Abstract composition. Cubism art style, ChaLOSTIC, The illustration has a stylized, geometric, and somewhat abstract art style, abstract,` (no início do prompt) |
| Sufixo fixo | `Dark, moody, deep shadows. Single subject, full body, no text, no frame.` |
| Resolução | 768×1024 (3:4) |
| Amostragem | 8 passos · CFG 1,0 · Euler · scheduler simple · denoise 1,0 · negativo zerado (`ConditioningZeroOut`) |
| Seed | derivada do id da carta: `sha1("<id>#<n>")`, reproduzível |
| Script | `arte/gerar_krea.py` (usa `arte/pipeline_pixel.py` → função `krea2`) |
| Prompt | seção **“## Prompt Krea 2”** de cada ficha em `cartas/<deck>/NN_*.md` |

### Como os prompts foram escritos
Um agente por deck leu a ficha (contexto mitológico, texto e papel da carta) e escreveu um prompt em frases, em inglês,
com uma lista de **atributos obrigatórios**. Regras aplicadas em todas as cartas:
- etnia, aparência e idade explícitas; proporções adultas e realistas (sem chibi);
- deficiências e traços físicos da tradição descritos de forma clínica e redundante (ex.: o Saci com a perna
  “amputated at the hip and completely missing” e “two normal arms”) — formas como “one leg” falhavam;
- figuras vestidas, figuras femininas sempre com o peito coberto, sem gore;
- no cristianismo, Deus e Cristo não aparecem em figura (decisão do autor);
- pose de acordo com a mecânica (Guarda defensiva, Relíquia como objeto em destaque, Selo como armadilha, Rito como ritual).

### Seleção e revisão
1. Duas candidatas por carta (seeds `a`, `b`) → revisão por agentes, carta a carta, contra os atributos obrigatórios.
2. Reprovadas: prompt corrigido e mais três candidatas (`c`, `d`, `e`) → segunda revisão.
3. As que ainda falharam em algum detalhe entraram como **provisórias** (a menos ruim) e ganharam uma terceira rodada
   (`f`, `g`, `h`). Relatórios em `arte/<deck>/_revisao_krea.md` (local).

Cartas provisórias nesta Alpha (13 — ainda falta algum atributo; as outras 10 da 3ª rodada foram aprovadas):
`bru_baba_yaga`, `ind_curupira`, `ind_mapinguari`, `ind_ibirapema`, `hin_shiva_nataraja`, `hin_vishvarupa`, `cri_anjo_da_guarda`, `tao_lan_caihe`, `tao_flechas_de_houyi`, `alt_homunculo`, `alt_dantalion`, `alt_paimon`, `bru_benandante`.

### Tokens
As 12 Entidades invocadas por efeito (Cão Celestial, Corvo, Lebre, Elemental…) usam o mesmo setup (Krea 2 + Chaotic Shapes),
3 candidatas cada, prompts em `godot/dados/tokens.json`, script `arte/gerar_tokens.py`. Arte em `arte/tokens/`, cartas montadas
no frame da tradição de origem em `cartas_finais/v1/tokens/` (`arte/montar_tokens.py`).

## 2. Frame das cartas

Desenhado **por código** (sem IA) seguindo o mapa de layout do autor: `arte/frame/gerar_frame_v2.py`.
- 720×1008 (5:7 = 63×88 mm); janela de arte 555×740 (3:4 exato, a ilustração aparece inteira).
- Pílula do nome (prata = comum, ouro = lendária, arco-íris = especial), pílula de efeito + ATK, pílula de DEF,
  faixa externa com padrão de cada tradição, painel marmorizado.
- Custo direto sobre o canto, em prata, sem círculo.
- Montagem: `arte/montar_cartas.py --versao v1` → `cartas_finais/v1/` (cada versão guarda o próprio `_backup/`).

Fontes: **Matcha Style** (Khurasan Studio, gratuita para uso pessoal e comercial — `arte/fontes/CREDITOS.txt`)
nos títulos e números; Noto Sans (SIL OFL) no texto das cartas.

## 3. Personagens do torneio

| Item | Valor |
|---|---|
| Modelo | **S.A.R.S** (checkpoint Illustrious, Civitai modelo 2961732) — sem LoRA |
| Configuração | 840×1120 → 768×1024 · 25 passos · CFG 5 · Euler a · clip skip 2 |
| Recorte | **BiRefNet** (nó `RemoveBackground` nativo do ComfyUI) → PNG transparente |
| Scripts | `arte/gerar_retratos_sars.py`, `arte/recortar_personagens.py` |
| Fichas | `docs/lore_torneio.md`, `godot/dados/lore.json` |

## 4. Logo e interface

- **Logo KodeX**: `arte/logo/gerar_logo.py` — ΚΟΔΕ em pixel art (letras gregas desenhadas à mão, ouro sem contorno)
  e um X de pincel seco gerado proceduralmente. Sem IA.
- **Mesa, menus, ícone, fonte pixel e efeitos** do jogo: desenhados por código no Godot (`godot/*.gd`).

## Licenças de terceiros (ferramentas)
- Krea 2 — Krea AI Community License.
- LoRA Chaotic Shapes — termos do autor no Civitai (modelo 2990211).
- S.A.R.S — Illustrious License (Civitai, modelo 2961732).
- BiRefNet — licença do projeto BiRefNet.
- Godot Engine — MIT.
Antes de uma versão comercial, confirmar os termos de uso comercial de cada modelo usado.
