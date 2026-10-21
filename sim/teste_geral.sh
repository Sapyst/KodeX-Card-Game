#!/bin/bash
# Bateria "o jogo não quebrou": partidas automáticas em vários modos, enigmas, tutorial, todas as telas do menu e o
# servidor. Offline (GD_SEM_REDE=1) para não criar contas no servidor de verdade. Saída: OK/FALHOU por item.
cd "$(dirname "$0")/../godot"
G="$HOME/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
export GD_SEM_REDE=1 GD_HORA_OFFLINE=1
falhas=0
item() {  # item "nome" "padrão esperado" comando...
  local nome="$1" esperado="$2"; shift 2
  local saida; saida=$("$@" 2>&1)
  if echo "$saida" | grep -q "SCRIPT ERROR"; then echo "FALHOU  $nome"; echo "$saida" | grep -A1 "SCRIPT ERROR" | head -4; falhas=$((falhas+1))
  elif [ -n "$esperado" ] && ! echo "$saida" | grep -q "$esperado"; then echo "FALHOU  $nome (sem '$esperado')"; falhas=$((falhas+1))
  else echo "OK      $nome"; fi
}
for M in "" peregrinacao choronzon; do
  item "partida automática ${M:-normal}" "FIM DA PARTIDA" env GD_MODO_TESTE=$M GD_AUTO=1 GD_VELOCIDADE=40 GD_SAIR_NO_FIM=1 GD_SEED=31 timeout 240 "$G" --headless --path . res://mesa.tscn
done
for N in 1 2; do
  item "partida IA×IA níveis $N" "FIM DA PARTIDA" env GD_AUTO=1 GD_IA_0=$N GD_IA_1=$((N-1)) GD_VELOCIDADE=40 GD_SAIR_NO_FIM=1 GD_SEED=$((40+N)) timeout 240 "$G" --headless --path . res://mesa.tscn
done
item "enigma 1 resolvido" "vencedor=0" env GD_ENIGMA=0 GD_SAIR_NO_FIM=1 GD_HUD_TESTE="6:atacar:1:0;9:golpe:0" timeout 60 "$G" --headless --path . res://mesa.tscn
item "enigma 3 resolvido" "vencedor=0" env GD_ENIGMA=2 GD_SAIR_NO_FIM=1 GD_HUD_TESTE="6:atacar:0:0;9:golpe:1" timeout 60 "$G" --headless --path . res://mesa.tscn
item "tutorial completo" "" env GD_TUTORIAL=1 GD_TUTORIAL_AUTO=1 GD_SAIR_NO_FIM=1 GD_VELOCIDADE=6 timeout 240 "$G" --headless --path . res://mesa.tscn
item "tempo por turno" "RELOGIO turno 3" env GD_TEMPO_TURNO=4 GD_SEM_MULLIGAN=1 GD_VELOCIDADE=4 timeout 120 "$G" --headless --path . res://mesa.tscn --quit-after 2400
for T in titulo colecao decks loja cosmeticos opcoes solo pere:indigena diario lendarios livre enigmas historico arcade perfil sugerir; do
  item "tela $T" "" env GD_SOLO_TESTE=$T GD_NOME_TESTE=Teste timeout 30 "$G" --headless --path . res://fluxo.tscn --quit-after 120
done
U=$(python3 -c "import json;print(json.load(open('../servidor.json'))['url'])" 2>/dev/null)
if curl -s -m 10 "$U/v1/saude" | grep -q '"ok":true'; then echo "OK      servidor no ar ($U)"; else echo "FALHOU  servidor no ar"; falhas=$((falhas+1)); fi
echo "----"; [ $falhas -eq 0 ] && echo "TUDO OK" || echo "$falhas FALHA(S)"
