"""Vídeo com todos os efeitos sonoros (arte/som/sfx_catalogo.mp4): nome, para que serve, variação, onda e espectrograma.
Depende de sfx_previa.wav/.json gerados por sintetizar_sfx.py. Uso: python3 arte/som/video_sfx.py"""
import json, os, subprocess
AQUI = os.path.dirname(os.path.abspath(__file__))
m = json.load(open(os.path.join(AQUI, "sfx_previa.json")))
DESC = {
 "carta_comprar": "Comprar / distribuir carta (mesmo material do embaralhar)", "deck_cascata": "As 32 cartas caindo e formando o monte",
 "embaralhar_corte": "Corte do maço", "carta_cair_campo": "Carta caindo no campo", "selo_colocar": "Selo colocado virado (abafado)",
 "ataque_investida": "Entidade toma impulso e avança", "ataque_impacto": "Impacto do ataque", "golpe_direto": "Golpe direto na Cornucópia",
 "cornucopia_dano": "Cornucópia perdendo vida", "cornucopia_cura": "Cornucópia ganhando vida", "entidade_morte": "Entidade se estilhaçando",
 "turno_inicio": "Início de turno", "efeito_dano": "Efeito de dano", "efeito_cura": "Efeito de cura", "efeito_buff": "Fortalecer (+ATK/+DEF)",
 "vitrine_carta": "Carta apresentada no centro", "selo_revelar": "Selo disparando (armadilha)", "rito_lancar": "Rito lançado",
 "lendaria_entrada": "Entrada de Lendária", "vitoria": "Vitória", "derrota": "Derrota", "transicao_tela": "Troca de tela",
 "botao": "Botão", "pergaminho_abrir": "Pergaminho abrindo", "moedas_voando": "Moedas voando até o contador",
 "booster_comprar": "Comprar booster", "booster_cortar": "Cortar a ponta do booster", "booster_rasgar": "Rasgar o booster",
 "booster_cartas_saem": "Cartas saindo do booster", "booster_revelar": "Revelar carta do booster"}
VAR = {"leve": "leve", "medio": "médio", "pesado": "pesado", "indigena": "Indígena (madeira)", "cristianismo": "Cristianismo (vitral)",
 "taoismo": "Taoísmo (porcelana)", "hinduismo": "Hinduísmo (bronze)", "bruxaria": "Bruxaria (ossos)", "alta_magia": "Alta Magia (cristal)",
 "abismo": "Abismo", "meu": "seu turno", "dele": "turno dele", "comum": "comum", "fogo": "fogo (Hinduísmo)", "trovao": "trovão (Indígena)",
 "sagrado": "luz sagrada (Cristianismo)", "sombrio": "sombrio (Bruxaria, Alta Magia, Abismo)", "celestial": "celestial (anjos, Cristianismo)",
 "natureza": "natureza: maracá e flauta (Indígena)", "agua": "água e jade (Taoísmo)", "ameaca": "do oponente (ameaça)", "minha": "sua",
 "raro": "Lendária ou foil"}


def ts(t):
    return f"{int(t // 3600)}:{int(t % 3600 // 60):02d}:{t % 60:05.2f}"


linhas = []
for i, e in enumerate(m):
    nome = e["nome"]
    base = next(k for k in sorted(DESC, key=len, reverse=True) if nome.startswith(k))
    suf = nome[len(base):].strip("_")
    if suf in VAR:
        v = VAR[suf]
    elif suf:
        partes = suf.split("_")
        v = " ".join(VAR.get(p, p) for p in partes if not p.isdigit()) or f"variação {partes[-1]}"
        if partes[-1].isdigit() and partes[0] in VAR:
            v += f" · variação {partes[-1]}"
    else:
        v = ""
    fim = m[i + 1]["ini"] if i + 1 < len(m) else e["ini"] + e["dur"] + 0.45
    t1 = DESC[base] + (f"\\N{{\\fs34\\c&H9AD0FF&}}{v}" if v else "")
    linhas.append(f"Dialogue: 0,{ts(e['ini'])},{ts(fim)},T,,0,0,0,,{{\\fs20\\c&H888888&}}{i + 1}/{len(m)}  ·  {nome}\\N{{\\fs44\\c&H9AE3FF&}}{t1}")
ASS = os.path.join(AQUI, "_sons.ass")
open(ASS, "w").write("""[Script Info]
ScriptType: v4.00+
PlayResX: 1280
PlayResY: 720

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: T,DejaVu Sans,40,&H00FFFFFF,&H00FFFFFF,&H00100C14,&H00000000,1,0,0,0,100,100,0,0,1,3,0,8,40,40,60,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
""" + "\n".join(linhas) + "\n")
filtro = ("[0:a]volume=10dB,showspectrum=s=1280x440:mode=combined:color=fire:scale=cbrt:slide=scroll:fscale=log,format=yuv420p[sp];"
          f"color=c=0x0d0b12:s=1280x720:r=30[bg];[bg][sp]overlay=0:240:shortest=1,subtitles={ASS}[v]")
subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", os.path.join(AQUI, "sfx_previa.wav"), "-filter_complex", filtro, "-map", "[v]",
                "-map", "0:a", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "23", "-c:a", "aac", "-b:a", "160k", "-movflags", "faststart",
                os.path.join(AQUI, "sfx_catalogo.mp4")], check=True)
os.remove(ASS)
print("ok")
