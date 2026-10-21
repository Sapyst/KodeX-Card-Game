-- Banco do KodeX (D1 / SQLite). Aplicar: npx wrangler d1 execute kodex --local --file=schema.sql
CREATE TABLE IF NOT EXISTS contas (id TEXT PRIMARY KEY, segredo_hash TEXT NOT NULL, criado INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS perfis (id TEXT PRIMARY KEY, dados TEXT NOT NULL, atualizado INTEGER NOT NULL);
-- contagem por dia (Nova York) de cada motivo de prêmio, para os tetos diários
CREATE TABLE IF NOT EXISTS limites (id TEXT NOT NULL, dia INTEGER NOT NULL, motivo TEXT NOT NULL, n INTEGER NOT NULL,
  PRIMARY KEY (id, dia, motivo));
-- códigos de transferência para outro aparelho (8 letras, 10 minutos)
CREATE TABLE IF NOT EXISTS codigos (codigo TEXT PRIMARY KEY, id TEXT NOT NULL, expira INTEGER NOT NULL);
-- login por email (opcional): email ligado a uma conta e códigos de 6 dígitos (hash, 10 min, 5 tentativas)
CREATE TABLE IF NOT EXISTS emails (email TEXT PRIMARY KEY, id TEXT NOT NULL, criado INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS email_codigos (email TEXT PRIMARY KEY, codigo_hash TEXT NOT NULL, expira INTEGER NOT NULL,
  tentativas INTEGER NOT NULL, pedido INTEGER NOT NULL);
-- conta Kode: usuário + senha; trocar/recuperar a senha exige a frase de 12 palavras (BIP39). O jogo reforça senha e
-- frase (milhares de rodadas de SHA-256) antes de enviar; aqui fica só o hash com sal do que chegou.
CREATE TABLE IF NOT EXISTS kodes (usuario TEXT PRIMARY KEY, id TEXT NOT NULL, sal TEXT NOT NULL, senha_hash TEXT NOT NULL,
  frase_hash TEXT NOT NULL, criado INTEGER NOT NULL, falhas INTEGER NOT NULL DEFAULT 0, bloqueado_ate INTEGER NOT NULL DEFAULT 0);

-- multiplayer: fila de busca, partidas (lockstep) e ações em ordem
CREATE TABLE IF NOT EXISTS fila (id TEXT PRIMARY KEY, nome TEXT, deck TEXT, pais TEXT, cont TEXT, entrou INTEGER, visto INTEGER, partida TEXT,
  foto TEXT);
CREATE TABLE IF NOT EXISTS partidas (pid TEXT PRIMARY KEY, codigo TEXT, j0 TEXT, j1 TEXT, nome0 TEXT, nome1 TEXT, deck0 TEXT, deck1 TEXT,
  semente INTEGER, primeiro INTEGER, estado TEXT, aceite0 INTEGER DEFAULT 0, aceite1 INTEGER DEFAULT 0, prazo INTEGER,
  contato0 INTEGER, contato1 INTEGER, vencedor INTEGER DEFAULT -1, criado INTEGER, revanche0 INTEGER DEFAULT 0, revanche1 INTEGER DEFAULT 0,
  revanche_pid TEXT, foto0 TEXT, foto1 TEXT, pago0 INTEGER DEFAULT 0, pago1 INTEGER DEFAULT 0);
CREATE TABLE IF NOT EXISTS acoes (pid TEXT, seq INTEGER, jogador INTEGER, dados TEXT, ts INTEGER, PRIMARY KEY (pid, seq));
