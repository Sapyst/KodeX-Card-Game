# Checklist de lançamento na Play Store (guardado: não vamos lançar agora)

## Já pronto
- [x] **Chave de upload** (item 57): `~/.local/share/kodex_keys/kodex_upload.keystore`, alias `kodex_upload`, RSA 4096, 30 anos,
      dono "CN=Sapyst" (sem nome real). Senha em `senha.txt` na mesma pasta (permissão 600). Fora do repositório.
      SHA-256: `8D:D6:39:97:B7:0E:31:27:7D:33:9B:E5:26:E7:92:5D:A1:56:30:12:96:CD:B1:11:DA:0D:AA:74:30:48:8A:1A`.
      **Fazer backup** desta pasta num lugar seguro (pendrive / gerenciador de senhas). O APK de teste continua com a chave de teste.
- [x] Textos da ficha da loja em en-US, pt-BR e es-419: `loja_play.md`.
- [x] Respostas da classificação etária e da Segurança dos dados: `classificacao_e_dados.md`.
- [x] Script do AAB: `gerar_aab.sh` (não rodado — build só com liberação).
- [x] Teste automático de equilíbrio no motor real: `sim/balanco_auto.sh` (item 60).
- [x] Espanhol (item 62): sistema de 3 idiomas + textos reescritos (EN base → PT/ES).

## Falta (na ordem)
1. **Política de privacidade**: corrigir os 3 pontos de `classificacao_e_dados.md` e publicar numa URL pública.
2. **Preset "Android (Play AAB)"** no Godot: duplicar o preset Android, ligar `gradle_build/use_gradle_build`,
   `gradle_build/export_format = AAB`, `gradle_build/target_sdk = 35` (ou o que a Play exigir na data), `min_sdk = 24`,
   arquiteturas arm64-v8a **e** armeabi-v7a (a Play recomenda as duas). Rodar `gerar_aab.sh` com liberação.
3. **Conta de desenvolvedor** da Play (taxa única US$ 25). Conta pessoal nova exige **teste fechado com 12 testadores por 14 dias**
   antes de liberar a produção — dá para usar os amigos que já testam o APK.
4. **Play App Signing**: na 1ª subida, deixar a Google gerar a chave do app e enviar o AAB assinado com a chave de upload.
5. Ícone 512, imagem de destaque 1024×500 e capturas nos 3 idiomas (ver `loja_play.md`).
6. Classificação (IARC) e Segurança dos dados com as respostas prontas.
7. Público-alvo: **13+** (evita as exigências de "Famílias"; o jogo tem demônios e terror leve).
8. Servidor: o túnel/Worker da Cloudflare aguenta? Plano grátis do Workers: 100 mil requisições/dia; Durable Objects
   cobram por uso — rever com o número de jogadores esperado antes de abrir.
9. Item 61 (celular fraco): testar num aparelho de entrada (2–3 GB de RAM) — a medir com amigos.
