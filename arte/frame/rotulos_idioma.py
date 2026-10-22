"""Rótulos fixos das molduras de carta por idioma (tipo, Lendária, palavras-chave, tradições, pílula de Selo).
Glossário: docs/textos/guia_de_estilo.md."""
ROTULOS = {
    "en": {"tipo": {"entidade": "Entity", "selo": "Seal", "rito": "Rite", "reliquia": "Relic"}, "lendaria": "LEGENDARY",
           "keys": ["Legendary", "Last Breath", "Awaken", "Rebirth", "Guard", "Stealth", "Rush", "Sacrifice"], "armadilha": "Trap",
           "cult": {"indigena": "Indigenous", "cristianismo": "Christianity", "taoismo": "Taoism", "hinduismo": "Hinduism",
                    "bruxaria": "Witchcraft", "alta_magia": "High Magic"}, "def": "Def", "usos": "Uses"},
    "es": {"tipo": {"entidade": "Entidad", "selo": "Sello", "rito": "Rito", "reliquia": "Reliquia"}, "lendaria": "LEGENDARIA",
           "keys": ["Legendaria", "Último Aliento", "Despertar", "Renacer", "Guardia", "Furtivo", "Ímpetu", "Sacrificio"], "armadilha": "Trampa",
           "cult": {"indigena": "Indígena", "cristianismo": "Cristianismo", "taoismo": "Taoísmo", "hinduismo": "Hinduismo",
                    "bruxaria": "Brujería", "alta_magia": "Alta Magia"}, "def": "Def", "usos": "Usos"},
}
# palavras-chave do JSON → rótulo em MAIÚSCULAS (frame full-art das Lendárias)
KW_MAIUSC = {"en": {"guarda": "GUARD", "impeto": "RUSH", "furtivo": "STEALTH", "renascer": "REBIRTH"},
             "es": {"guarda": "GUARDIA", "impeto": "ÍMPETU", "furtivo": "FURTIVO", "renascer": "RENACER"}}
