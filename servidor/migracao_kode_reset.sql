-- reset do Kode pelo suporte (painel): frase invalidada e/ou senha temporária
ALTER TABLE kodes ADD COLUMN refazer_frase INTEGER NOT NULL DEFAULT 0;
ALTER TABLE kodes ADD COLUMN senha_temp INTEGER NOT NULL DEFAULT 0;
