-- colunas novas do multiplayer (bancos criados antes): rodar uma vez
ALTER TABLE fila ADD COLUMN foto TEXT;
ALTER TABLE partidas ADD COLUMN foto0 TEXT;
ALTER TABLE partidas ADD COLUMN foto1 TEXT;
ALTER TABLE partidas ADD COLUMN pago0 INTEGER DEFAULT 0;
ALTER TABLE partidas ADD COLUMN pago1 INTEGER DEFAULT 0;
