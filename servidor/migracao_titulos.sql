-- v0.20.20: título do perfil vai junto do nome para o adversário (fila.titulo, partidas.titulo0/titulo1)
ALTER TABLE fila ADD COLUMN titulo TEXT;
ALTER TABLE partidas ADD COLUMN titulo0 TEXT;
ALTER TABLE partidas ADD COLUMN titulo1 TEXT;
