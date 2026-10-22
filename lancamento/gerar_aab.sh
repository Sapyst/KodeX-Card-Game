#!/bin/bash
# Gera o AAB da Play Store (NÃO rodar sem a liberação da Sapyst: regra "build só com liberação").
# Usa o build Gradle do Godot (exige o template Android instalado em godot/android/build) e assina com a CHAVE DE UPLOAD
# (~/.local/share/kodex_keys/kodex_upload.keystore, senha em senha.txt ao lado; nunca no repositório).
# A Play guarda a chave de app (Play App Signing); se a chave de upload se perder, dá para pedir a troca no Console.
set -e
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
G="$HOME/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
CHAVES="$HOME/.local/share/kodex_keys"
VER=$(grep '^version/name=' "$RAIZ/godot/export_presets.cfg" | head -1 | cut -d'"' -f2)
SAIDA="$RAIZ/godot/export/KodeX-v$VER.aab"

# 1. template Android do Gradle (uma vez): o mesmo zip que o editor instala em Projeto > Instalar template de build Android
if [ ! -f "$RAIZ/godot/android/build/build.gradle" ]; then
  mkdir -p "$RAIZ/godot/android/build"
  unzip -q "$HOME/.local/share/godot/export_templates/4.7.2.stable/android_source.zip" -d "$RAIZ/godot/android/build"
  cat "$HOME/.local/share/godot/export_templates/4.7.2.stable/version.txt" > "$RAIZ/godot/android/.build_version"
  touch "$RAIZ/godot/android/build/.gdignore"
fi

# 2. exporta com o preset "Android (Play AAB)" — mesmo preset do APK com Gradle ligado e formato AAB (ver checklist.md)
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$CHAVES/kodex_upload.keystore"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="kodex_upload"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$(cat "$CHAVES/senha.txt")"
mkdir -p "$RAIZ/godot/export"
"$G" --headless --path "$RAIZ/godot" --export-release "Android (Play AAB)" "$SAIDA"

# 3. confere a assinatura
keytool -printcert -jarfile "$SAIDA" | grep -E "Owner|SHA256:" | head -2
echo "AAB: $SAIDA"
