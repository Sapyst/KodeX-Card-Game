-- Banco do KodeX (D1 / SQLite), igual ao banco na Cloudflare em 13/11/2026 (exportado com
--   npx wrangler d1 export kodex --remote --no-data).
-- Banco novo no PC: npx wrangler d1 execute kodex --local --file=schema.sql
-- Mudanças no banco online: um arquivo migracao_*.sql novo (aplicar com --remote) e exportar este de novo.
-- O que cada tabela guarda: contas/perfis (conta anônima e o perfil com a economia), limites (tetos por dia, ranqueadas),
-- codigos (transferência, 10 min), emails/email_codigos, kodes (usuário + senha), fila/partidas/acoes (online; acoes é
-- do protocolo antigo sem juiz), erros (relatórios enviados), diario (Desafio do dia), sinais/punicoes/revisoes/notas/
-- admin_log/vistos/admin_pacotes (moderação e painel). Limpeza diária: index.js → limpeza().
CREATE TABLE IF NOT EXISTS contas (id TEXT PRIMARY KEY, segredo_hash TEXT NOT NULL, criado INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS perfis (id TEXT PRIMARY KEY, dados TEXT NOT NULL, atualizado INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS limites (id TEXT NOT NULL, dia INTEGER NOT NULL, motivo TEXT NOT NULL, n INTEGER NOT NULL,
  PRIMARY KEY (id, dia, motivo));
CREATE TABLE IF NOT EXISTS codigos (codigo TEXT PRIMARY KEY, id TEXT NOT NULL, expira INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS emails (email TEXT PRIMARY KEY, id TEXT NOT NULL, criado INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS email_codigos (email TEXT PRIMARY KEY, codigo_hash TEXT NOT NULL, expira INTEGER NOT NULL,
  tentativas INTEGER NOT NULL, pedido INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS kodes (usuario TEXT PRIMARY KEY, id TEXT NOT NULL, sal TEXT NOT NULL, senha_hash TEXT NOT NULL,
  frase_hash TEXT NOT NULL, criado INTEGER NOT NULL, falhas INTEGER NOT NULL DEFAULT 0, bloqueado_ate INTEGER NOT NULL DEFAULT 0, refazer_frase INTEGER NOT NULL DEFAULT 0, senha_temp INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS fila (id TEXT PRIMARY KEY, nome TEXT, deck TEXT, pais TEXT, cont TEXT, entrou INTEGER, visto INTEGER, partida TEXT,
  foto TEXT, sombra INTEGER DEFAULT 0, juiz INTEGER DEFAULT 0, titulo TEXT);
CREATE TABLE IF NOT EXISTS partidas (pid TEXT PRIMARY KEY, codigo TEXT, j0 TEXT, j1 TEXT, nome0 TEXT, nome1 TEXT, deck0 TEXT, deck1 TEXT,
  semente INTEGER, primeiro INTEGER, estado TEXT, aceite0 INTEGER DEFAULT 0, aceite1 INTEGER DEFAULT 0, prazo INTEGER,
  contato0 INTEGER, contato1 INTEGER, vencedor INTEGER DEFAULT -1, criado INTEGER, revanche0 INTEGER DEFAULT 0, revanche1 INTEGER DEFAULT 0,
  revanche_pid TEXT, foto0 TEXT, foto1 TEXT, pago0 INTEGER DEFAULT 0, pago1 INTEGER DEFAULT 0, juiz INTEGER DEFAULT 0, titulo0 TEXT, titulo1 TEXT, casual INTEGER DEFAULT 0);
CREATE TABLE IF NOT EXISTS acoes (pid TEXT, seq INTEGER, jogador INTEGER, dados TEXT, ts INTEGER, PRIMARY KEY (pid, seq));
CREATE TABLE IF NOT EXISTS erros (id TEXT, ts INTEGER, versao TEXT, so TEXT, texto TEXT);
CREATE TABLE IF NOT EXISTS sinais (id TEXT, dia INTEGER, ts INTEGER, tipo TEXT, detalhe TEXT, peso INTEGER, UNIQUE (id, dia, tipo, detalhe));
CREATE TABLE IF NOT EXISTS punicoes (id TEXT PRIMARY KEY, tipo TEXT, ate INTEGER, motivo TEXT, ts INTEGER);
CREATE TABLE IF NOT EXISTS revisoes (id TEXT PRIMARY KEY, ts INTEGER);
CREATE TABLE IF NOT EXISTS notas (id TEXT, ts INTEGER, texto TEXT);
CREATE TABLE IF NOT EXISTS admin_log (ts INTEGER, acao TEXT, alvo TEXT, detalhe TEXT);
CREATE TABLE IF NOT EXISTS vistos (id TEXT PRIMARY KEY, ts INTEGER, moedas INTEGER, xp INTEGER);
CREATE TABLE IF NOT EXISTS admin_pacotes (id TEXT PRIMARY KEY, nome TEXT UNIQUE NOT NULL, dados TEXT NOT NULL, ts INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS diario (dia INTEGER, id TEXT, venceu INTEGER DEFAULT 0, turnos INTEGER DEFAULT 0, ts INTEGER, PRIMARY KEY (dia, id));
CREATE INDEX IF NOT EXISTS sinais_id ON sinais (id);
CREATE INDEX IF NOT EXISTS diario_dia ON diario (dia);
CREATE INDEX IF NOT EXISTS partidas_criado ON partidas (criado);
CREATE INDEX IF NOT EXISTS partidas_sala ON partidas (codigo) WHERE estado = 'sala';
CREATE INDEX IF NOT EXISTS emails_id ON emails (id);
CREATE INDEX IF NOT EXISTS kodes_id ON kodes (id);
