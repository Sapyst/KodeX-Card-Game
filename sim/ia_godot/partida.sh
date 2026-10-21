#!/bin/bash
# uso: partida.sh seed ia0 ia1 deckA deckB  → imprime "seed ia0 ia1 deckA deckB resultado turno"
cd "/mnt/d/Projetos de Jogos/GodsKodex/godot"
G="$HOME/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
R=$(GD_AUTO=1 GD_IA_0=$2 GD_IA_1=$3 GD_DECK_A=$4 GD_DECK_B=$5 GD_VELOCIDADE=40 GD_SAIR_NO_FIM=1 GD_SEED=$1 timeout 240 "$G" --headless --path . res://mesa.tscn 2>&1 | grep "FIM DA PARTIDA" | head -1)
res=$(echo "$R" | grep -oE "vitória|derrota|empate" | head -1); tur=$(echo "$R" | grep -oE "turno [0-9]+" | grep -oE "[0-9]+")
echo "$1 $2 $3 $4 $5 ${res:-erro} ${tur:-0}"
