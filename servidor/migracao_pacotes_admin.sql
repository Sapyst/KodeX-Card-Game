-- pacotes salvos do painel (combinações prontas para dar com um clique)
CREATE TABLE IF NOT EXISTS admin_pacotes (id TEXT PRIMARY KEY, nome TEXT UNIQUE NOT NULL, dados TEXT NOT NULL, ts INTEGER NOT NULL);
