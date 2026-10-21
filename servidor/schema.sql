-- Banco do KodeX (D1 / SQLite). Aplicar: npx wrangler d1 execute kodex --local --file=schema.sql
CREATE TABLE IF NOT EXISTS contas (id TEXT PRIMARY KEY, segredo_hash TEXT NOT NULL, criado INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS perfis (id TEXT PRIMARY KEY, dados TEXT NOT NULL, atualizado INTEGER NOT NULL);
-- contagem por dia (Nova York) de cada motivo de prêmio, para os tetos diários
CREATE TABLE IF NOT EXISTS limites (id TEXT NOT NULL, dia INTEGER NOT NULL, motivo TEXT NOT NULL, n INTEGER NOT NULL,
  PRIMARY KEY (id, dia, motivo));
-- códigos de transferência para outro aparelho (8 letras, 10 minutos)
CREATE TABLE IF NOT EXISTS codigos (codigo TEXT PRIMARY KEY, id TEXT NOT NULL, expira INTEGER NOT NULL);
