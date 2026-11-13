-- 13/11/2026 — otimização do online (aplicar: npx wrangler d1 execute kodex --remote --file=migracao_otimizacao.sql)
-- partida casual (sala com código, com um amigo): fora do ranking e sem moedas
ALTER TABLE partidas ADD COLUMN casual INTEGER DEFAULT 0;
UPDATE partidas SET casual = 1 WHERE codigo IS NOT NULL;
-- ranking da semana, limpeza e fotos de 3 h: só a faixa de datas, sem varrer a tabela
CREATE INDEX IF NOT EXISTS partidas_criado ON partidas (criado);
-- entrar na sala pelo código: só as salas abertas ficam no índice
CREATE INDEX IF NOT EXISTS partidas_sala ON partidas (codigo) WHERE estado = 'sala';
-- /v1/perfil procura email e Kode pela conta
CREATE INDEX IF NOT EXISTS emails_id ON emails (id);
CREATE INDEX IF NOT EXISTS kodes_id ON kodes (id);
