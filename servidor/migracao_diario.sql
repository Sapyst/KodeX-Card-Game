-- v0.20.21: placar público do Desafio do dia
CREATE TABLE IF NOT EXISTS diario (dia INTEGER, id TEXT, venceu INTEGER DEFAULT 0, turnos INTEGER DEFAULT 0, ts INTEGER, PRIMARY KEY (dia, id));
CREATE INDEX IF NOT EXISTS diario_dia ON diario (dia);
