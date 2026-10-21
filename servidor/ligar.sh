#!/bin/bash
# Liga o servidor do KodeX no PC agora (o mesmo que o serviço automático faz). Use se o serviço estiver desligado.
#   systemctl --user start kodex-servidor   (recomendado)   ·   ou: ./ligar.sh  (fica rodando neste terminal)
cd "$(dirname "$0")" && exec ./vigia.sh
