"""Carrega cartas (.md com bloco ```json) em dataclasses e monta decks de 32."""
from __future__ import annotations

import glob
import json
import os
import re
from dataclasses import dataclass, field, replace
from typing import Optional

TIPOS = ("entidade", "selo", "rito", "reliquia")
KEYWORDS = ("impeto", "guarda", "renascer", "furtivo")
OPS = ("damage", "heal", "draw", "search", "buff", "destroy", "bounce", "summon", "revive", "discard",
       "gain_fe", "silence", "freeze", "counter", "give_keyword", "set_stats", "copy_stats",
       "swap_control", "win", "ritual_choronzon")
TAMANHO_DECK = 32
MAX_COPIAS = 2


class DeckInvalido(Exception):
    pass


@dataclass(frozen=True)
class Efeito:
    gatilho: str
    acoes: tuple
    cond: Optional[dict] = None


@dataclass(eq=False)
class Card:
    id: str
    nome: str
    cultura: str
    tipo: str
    custo: int
    atk: Optional[int]
    vida: Optional[int]
    lendaria: bool
    keywords: tuple
    sacrificio: int
    efeitos: tuple
    usos: Optional[int]
    copias: int = 1
    token: bool = False

    @property
    def eh_entidade(self) -> bool:
        return self.tipo == "entidade"

    def efeitos_de(self, gatilho: str):
        return [e for e in self.efeitos if e.gatilho == gatilho]

    def sem_renascer(self) -> "Card":
        return replace(self, keywords=tuple(k for k in self.keywords if k != "renascer"))

    def __repr__(self):
        return f"Card({self.id})"


@dataclass
class Deck:
    nome: str
    distintas: list = field(default_factory=list)

    @property
    def cartas(self) -> list:
        """Lista expandida (uma referência por cópia)."""
        out = []
        for c in self.distintas:
            out.extend([c] * c.copias)
        return out

    def __len__(self):
        return sum(c.copias for c in self.distintas)


def extrair_json(md: str):
    m = re.search(r"```json\s*(\{.*?\})\s*```", md, re.S)
    if not m:
        raise DeckInvalido("sem bloco ```json")
    return json.loads(m.group(1))


def extrair_todos_json(md: str):
    return [json.loads(m) for m in re.findall(r"```json\s*(\{.*?\})\s*```", md, re.S)]


def extrair_copias(md: str) -> int:
    m = re.search(r"\|\s*C[óo]pias no deck\s*\|\s*(\d)\s*\|", md)
    return int(m.group(1)) if m else 1


def carta_de_json(d: dict, copias: int = 1) -> Card:
    if d.get("tipo") not in TIPOS:
        raise DeckInvalido(f"{d.get('id')}: tipo inválido {d.get('tipo')!r}")
    efeitos = []
    for ef in d.get("efeitos") or []:
        for a in ef.get("acoes", []):
            if a.get("op") not in OPS:
                raise DeckInvalido(f"{d.get('id')}: op desconhecida {a.get('op')!r}")
        efeitos.append(Efeito(ef["gatilho"], tuple(dict(a) for a in ef.get("acoes", [])), ef.get("cond")))
    return Card(
        id=d["id"], nome=d.get("nome", d["id"]), cultura=d.get("cultura", ""), tipo=d["tipo"],
        custo=int(d.get("custo", 0)), atk=d.get("atk"), vida=d.get("vida"),
        lendaria=bool(d.get("lendaria", False)), keywords=tuple(d.get("keywords") or ()),
        sacrificio=int(d.get("sacrificio") or 0), efeitos=tuple(efeitos), usos=d.get("usos"),
        copias=copias,
    )


def _ler(caminho: str) -> str:
    with open(caminho, encoding="utf-8") as f:
        return f.read()


def carta_de_md(caminho: str) -> Card:
    md = _ler(caminho)
    return carta_de_json(extrair_json(md), extrair_copias(md))


def cartas_de_md_multiplo(caminho: str) -> list:
    """Todos os blocos ```json de um .md (ex.: docs/choronzon.md)."""
    md = _ler(caminho)
    return [carta_de_json(d) for d in extrair_todos_json(md)]


def validar_deck(deck: Deck, estrito: bool = True) -> list:
    erros = []
    ids = set()
    for c in deck.distintas:
        if c.id in ids:
            erros.append(f"id duplicado: {c.id}")
        ids.add(c.id)
        if not 1 <= c.copias <= MAX_COPIAS:
            erros.append(f"{c.id}: {c.copias} cópias")
        if c.lendaria and c.copias != 1:
            erros.append(f"{c.id}: Lendária com {c.copias} cópias")
        if c.eh_entidade and (c.atk is None or c.vida is None or c.vida < 1):
            erros.append(f"{c.id}: Entidade sem atk/vida válidos")
    if estrito and len(deck) != TAMANHO_DECK:
        erros.append(f"deck com {len(deck)} cartas (esperado {TAMANHO_DECK})")
    return erros


def carregar_pasta(pasta: str, estrito: bool = True) -> Deck:
    pasta = pasta.rstrip("/\\")
    deck = Deck(nome=os.path.basename(pasta))
    arquivos = sorted(glob.glob(os.path.join(pasta, "*.md")))
    for f in arquivos:
        if os.path.basename(f).startswith("_"):
            continue
        try:
            deck.distintas.append(carta_de_md(f))
        except (DeckInvalido, json.JSONDecodeError, KeyError) as e:
            raise DeckInvalido(f"{os.path.basename(f)}: {e}") from e
    erros = validar_deck(deck, estrito)
    if erros:
        raise DeckInvalido(f"[{deck.nome}] " + "; ".join(erros))
    return deck


def deck_de_cartas(nome: str, cartas: list) -> Deck:
    """Monta um Deck a partir de uma lista expandida de Cards (para testes)."""
    deck = Deck(nome=nome)
    vistos = {}
    for c in cartas:
        if c.id in vistos:
            vistos[c.id].copias += 1
        else:
            vistos[c.id] = replace(c, copias=1)
    deck.distintas = list(vistos.values())
    return deck
