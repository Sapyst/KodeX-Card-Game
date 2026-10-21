# Workflows de IA local

## comfyui/
Workflows do KodeX (abrir no ComfyUI: arrastar o .json para a tela, ou copiar para
`D:\Comfy-Desktop\ComfyUI\user\default\workflows\`).

| arquivo | uso |
|---|---|
| KodeX - Cartas (Krea2 + Chaotic Shapes) | artes normais das cartas (8 passos, CFG 1, LoRA 1.0, 768×1024) |
| KodeX - Krea2 puro (composicao) | Krea sem LoRA (base das foils difíceis) |
| KodeX - Foil lendarias (S.A.R.S) | ultra raras dark fantasy (25 passos, CFG 5, clip skip 2, 840×1120) |
| KodeX - Foil img2img (S.A.R.S) | redesenho de uma imagem no estilo S.A.R.S (denoise 0.45) |
| KodeX - Recorte de fundo (BiRefNet) | máscara de recorte do personagem |
| KodeX - Efeitos sonoros (Stable Audio Open) | efeitos sonoros por texto em inglês, até 47 s, 44,1 kHz estéreo (50 passos, CFG 5, dpmpp_3m_sde_gpu/exponential). Modelos: `checkpoints/stable-audio-open-1.0.safetensors` + `text_encoders/t5_base.safetensors`. Ajuste a duração nos dois nós (EmptyLatentAudio e ConditioningStableAudio). |

Stable Audio Open: Stability AI Community License (grátis abaixo de US$ 1 mi/ano; uso comercial pede cadastro em
stability.ai/community-license). Ao distribuir o modelo ou produto que o use: "This Stability AI Model is licensed
under the Stability AI Community License, Copyright © Stability AI Ltd. All Rights Reserved" + "Powered by Stability AI".

## audiogen/
Efeitos sonoros por texto com Meta AudioCraft (AudioGen medium), fora do ComfyUI.
Instalação: `instalar.sh` (venv em `D:\AI_LOCAL\AudioGen`, torch cu128 para RTX 5070; o xformers
é substituído por um stub e a atenção usada é a do PyTorch).
Uso: `D:\AI_LOCAL\AudioGen\venv\bin\python gerar.py "fire crackling, roaring flames" fogo.wav 3 1`
→ WAV 16 kHz mono (o modelo fica em `D:\AI_LOCAL\AudioGen\hf`).
