# Classificação etária (IARC) e Segurança dos dados (rascunho das respostas)

## Questionário IARC (Play Console › Classificação do conteúdo)
Categoria: **Jogo** (cartas / estratégia).

| Pergunta | Resposta | Observação |
|---|---|---|
| Violência | Sim, **fantasia, sem sangue realista** | criaturas e demônios se atacam em cartas ilustradas; sem sangue nem desmembramento |
| Violência contra humanos realistas | Não | |
| Sangue / gore | Não | conferir as artes de Kali, Hécate e da Goetia antes de enviar (se houver sangue visível, responder "sangue leve") |
| Conteúdo sexual / nudez | Não | conferir artes (Babalon, súcubos) — nada de nudez explícita |
| Linguagem imprópria | Não | |
| Drogas / álcool / tabaco | Não | (pílula da imortalidade taoista é referência mítica) |
| Jogos de azar simulados | Não | boosters são comprados só com moedas do jogo, sem dinheiro real |
| Compra de itens aleatórios com dinheiro real (loot box) | Não | não há compras no app |
| Temas assustadores / terror | **Sim, leve** | demônios, Abismo, Choronzon |
| Interação entre usuários | **Sim** | duelo online com nome e imagem de perfil do adversário e 4 emotes fixos; **sem chat livre** |
| Compartilha localização | Não | o país da conexão é usado só na fila de busca e não é guardado |
| Compras digitais | Não | |
| Referências religiosas | Sim (informativo) | figuras de seis tradições, tratadas com respeito e com fontes no Códice |

Expectativa: **PEGI 12 / ESRB Teen / ClassInd 12** (por fantasia sombria e temas de terror leve). Se a Play sugerir 7/10, aceitar.

## Segurança dos dados (Play Console › Segurança dos dados)
- Coleta dados? **Sim.** Compartilha com terceiros? **Não** (Cloudflare e Resend são processadores, não "compartilhamento").
- Criptografia em trânsito: **Sim** (HTTPS / WSS).
- O usuário pode pedir exclusão: **Sim**, no app (Opções › Excluir conta) — informar também uma URL de exclusão (página do GitHub).

| Tipo de dado (Play) | Coletado | Obrigatório? | Finalidade |
|---|---|---|---|
| Informações pessoais › Nome (nome de jogador, apelido) | Sim | Sim (online) | funcionalidade do app, gerenciamento da conta |
| Informações pessoais › Email | Sim | **Opcional** | gerenciamento da conta (login por código) |
| Fotos | Sim, **efêmero** | Opcional | funcionalidade (miniatura 60×80 para o adversário, apagada em até 3 h) |
| Atividade no app › Interações / progresso do jogo | Sim | Sim (online) | funcionalidade, prevenção de fraude e segurança (moderação) |
| Informações e desempenho do app › Registros de falhas | Sim | **Opcional** (o jogador escolhe enviar) | diagnóstico |
| Identificadores do dispositivo ou outros IDs | Sim (ID de conta aleatório) | Sim (online) | funcionalidade, prevenção de fraude |
| Localização aproximada | **Não** (país só na fila, não guardado) | — | — |

## ⚠️ Ajustar a política de privacidade ANTES de enviar
A política atual (dados/privacidade.json) tem dois pontos que não batem com o servidor de hoje:
1. "Não guardamos o IP" — o servidor guarda um **hash com sal** do IP por dia, para o limite de criação de contas e o bloqueio
   do painel de administração. Dizer isso ("guardamos só uma impressão irreversível do IP por 24 h, contra abuso").
2. "Não usa rastreamento nem análise de uso" + a moderação: o servidor registra **sinais de comportamento suspeito**
   (ganhos fora do normal, partidas abandonadas) para a moderação. Isso é prevenção de fraude, permitido, mas tem que estar escrito.
3. O trecho "Não guardamos email" (seção Conta online) contradiz a seção de email opcional: trocar por "sem o email opcional".
Também falta uma **URL pública** da política (a Play exige link): publicar PRIVACIDADE.md no GitHub Pages ou usar o link do arquivo no repositório.
