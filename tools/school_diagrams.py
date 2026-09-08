"""Izvor SVG dijagrama za Školu.

Naučeno na hranilicama: dijagram ne sme da crta prazan predmet iz istog ugla —
onda sve familije izgledaju isto. Crta se ONO ŠTO PREDMET RADI: tačkice
(primama), strelice (kuda izlazi), linija dna, linija površine.

Sve je jednobojno preko currentColor + fill-opacity, da isti crtež radi u light
i dark temi bez dve verzije (SvgPicture.string + colorFilter).

Iteracija: `python3 tools/school_diagrams.py out.html` pa headless Chrome
screenshot — crtati naslepo ne radi.
"""
import math

W, H = 100, 120
INK = 'currentColor'


def wrap(body):
    return (f'<svg viewBox="0 0 {W} {H}" fill="none" stroke="{INK}" '
            f'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
            f'{body}</svg>')


def arrow(x, y, deg, ln=9, op=0.75):
    """Strelica iz (x,y) pod uglom deg (0 = desno, 90 = dole)."""
    r = math.radians(deg)
    x2, y2 = x + ln * math.cos(r), y + ln * math.sin(r)
    a1 = math.radians(deg + 148)
    a2 = math.radians(deg - 148)
    h = 3.6
    return (f'<path d="M{x:.1f} {y:.1f}L{x2:.1f} {y2:.1f}'
            f'm0 0l{h*math.cos(a1):.1f} {h*math.sin(a1):.1f}'
            f'M{x2:.1f} {y2:.1f}l{h*math.cos(a2):.1f} {h*math.sin(a2):.1f}" '
            f'stroke-width="1.7" stroke-opacity="{op}"/>')


def dots(pts, r=1.7, op=0.5):
    """Primama unutar hranilice."""
    return ''.join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{INK}" '
                   f'fill-opacity="{op}" stroke="none"/>' for x, y in pts)


def ground(y=110):
    return (f'<path d="M14 {y}H86" stroke-width="1.6" stroke-opacity="0.45" '
            f'stroke-dasharray="4 4"/>')


SWIVEL = '<circle cx="50" cy="9" r="4.5"/><path d="M50 13.5V20"/>'

# ── CAGE: mrežasti kavez, pušta sa svih strana već dok pada ────────────────
CAGE = wrap(
    SWIVEL
    + '<rect x="32" y="20" width="36" height="64" rx="7" fill="currentColor" fill-opacity="0.04"/>'
    + '<path d="M41 23V81M50 23V81M59 23V81" stroke-opacity="0.5" stroke-width="1.3"/>'
    + '<path d="M35 36H65M35 50H65M35 64H65" stroke-opacity="0.5" stroke-width="1.3"/>'
    + dots([(45, 30), (55, 43), (44, 57), (56, 70), (50, 36), (50, 64)])
    + '<rect x="32" y="72" width="36" height="12" rx="6" fill="currentColor" fill-opacity="0.4" stroke="none"/>'
    + '<rect x="32" y="72" width="36" height="12" rx="6"/>'
    # pušta u svim smerovima, i u padu
    + arrow(70, 32, -12) + arrow(70, 52, 8) + arrow(30, 40, 192) + arrow(30, 62, 168)
    + f'<path d="M50 92v10m0 0-4-4m4 4 4-4" stroke-width="1.6" stroke-opacity="0.4"/>'
)

# ── OPEN-END: cev otvorena na oba kraja, pušta kad legne ───────────────────
OPEN_END = wrap(
    SWIVEL
    + '<ellipse cx="50" cy="27" rx="17" ry="6"/>'
    + '<path d="M33 27V88"/><path d="M67 27V88"/>'
    + '<path d="M33 88a17 6 0 0 0 34 0" stroke-dasharray="3 3" stroke-opacity="0.55"/>'
    + '<path d="M33 88a17 6 0 0 1 34 0"/>'
    + dots([(44, 40), (56, 48), (45, 58), (57, 66), (50, 74), (43, 72)])
    + '<rect x="33" y="36" width="8" height="46" rx="4" fill="currentColor" fill-opacity="0.4" stroke="none"/>'
    + '<rect x="33" y="36" width="8" height="46" rx="4" stroke-width="1.6"/>'
    # izlazi na oba otvora
    + arrow(50, 22, -90) + arrow(50, 95, 90)
    + ground()
)

# ── WINDOW: kugla za daljinu, olovo u bazi, pušta samo kroz prozore ────────
WINDOW = wrap(
    SWIVEL
    + '<path d="M35 34C35 34 39 21 50 21s15 13 15 13"/>'
    + '<path d="M35 34v46"/><path d="M65 34v46"/>'
    + '<rect x="39" y="40" width="22" height="13" rx="3"/>'
    + '<rect x="39" y="59" width="22" height="13" rx="3"/>'
    + dots([(45, 46), (55, 46), (45, 65), (55, 65)], r=1.6, op=0.55)
    + '<path d="M35 80h30v11a5 5 0 0 1-5 5H40a5 5 0 0 1-5-5z" fill="currentColor" fill-opacity="0.45" stroke="none"/>'
    + '<path d="M35 80h30v11a5 5 0 0 1-5 5H40a5 5 0 0 1-5-5z"/>'
    # samo kroz prozore
    + arrow(64, 46, 0) + arrow(64, 65, 0)
    # linije brzine uz nos — leti najdalje
    + '<path d="M76 26h9M78 32h7" stroke-width="1.5" stroke-opacity="0.4"/>'
    + ground()
)

# ── METHOD: ravno dno, primama oblepljena spolja, mamac na vrhu ────────────
METHOD = wrap(
    '<path d="M50 12v18" stroke-opacity="0.35" stroke-width="1.6" stroke-dasharray="3 3"/>'
    # oblepljena primama = spoljni obris
    + '<path d="M50 26C72 36 76 66 69 90H31C24 66 28 36 50 26Z" fill="currentColor" fill-opacity="0.14" stroke-dasharray="4 3" stroke-width="1.6" stroke-opacity="0.7"/>'
    # telo hranilice unutra
    + '<path d="M50 38C62 45 65 68 61 84H39C35 68 38 45 50 38Z" fill="currentColor" fill-opacity="0.05"/>'
    + '<path d="M43 52h14M41 62h18M40 72h20" stroke-opacity="0.45" stroke-width="1.3"/>'
    + dots([(35, 55), (65, 58), (34, 75), (66, 76)], r=1.6, op=0.5)
    # ravna teška baza
    + '<rect x="28" y="90" width="44" height="12" rx="3" fill="currentColor" fill-opacity="0.5" stroke="none"/>'
    + '<rect x="28" y="90" width="44" height="12" rx="3"/>'
    # mamac + udica na vrhu
    + f'<circle cx="50" cy="30" r="4.5" fill="{INK}" fill-opacity="0.55"/>'
    + '<path d="M58 24a5 5 0 0 0-8 4" stroke-width="1.7"/>'
    + ground(y=106)
)

# ── PELLET: zatvorena sa strane, riba pristupa SAMO s prednje ──────────────
# Identitet = pun zadnji zid vs otvoren prednji obod. Zato zid ide kao ispunjen
# panel (levo), a obod kao svetla elipsa (desno) — 3/4 ugao da se vidi da je kapa.
PELLET = wrap(
    '<path d="M14 38h12" stroke-opacity="0.35" stroke-width="1.6" stroke-dasharray="3 3"/>'
    # zadnji zid — ispunjen, zatvoren
    + '<path d="M26 36h10v52H26a4 4 0 0 1-4-4V40a4 4 0 0 1 4-4Z" fill="currentColor" fill-opacity="0.55" stroke="none"/>'
    + '<path d="M26 36h10v52H26a4 4 0 0 1-4-4V40a4 4 0 0 1 4-4Z"/>'
    # telo kape
    + '<path d="M36 36h24a8 8 0 0 1 8 8v36a8 8 0 0 1-8 8H36" fill="currentColor" fill-opacity="0.05"/>'
    # otvoren prednji obod
    + '<ellipse cx="68" cy="62" rx="5" ry="26" stroke-width="2.2"/>'
    + dots([(44, 46), (54, 54), (45, 64), (57, 70), (48, 78), (60, 60)])
    + '<rect x="22" y="88" width="52" height="12" rx="3" fill="currentColor" fill-opacity="0.5" stroke="none"/>'
    + '<rect x="22" y="88" width="52" height="12" rx="3"/>'
    # izlaz samo naprijed
    + arrow(75, 52, 0, ln=12) + arrow(75, 72, 0, ln=12)
    + ground(y=106)
)

# ── HYBRID: duboka kapa, visoke strane čuvaju mamac u padu ─────────────────
# Razlika od Method-a: kod Method-a je primama OKO hranilice, kod Hybrid-a
# UNUTRA između visokih zidova. Zato pun zid levo/desno + primama duboko unutra.
HYBRID = wrap(
    '<path d="M50 10v14" stroke-opacity="0.35" stroke-width="1.6" stroke-dasharray="3 3"/>'
    # visoki zidovi kao ispunjeni paneli
    + '<path d="M31 30h7v54h-7z" fill="currentColor" fill-opacity="0.45" stroke="none"/>'
    + '<path d="M62 30h7v54h-7z" fill="currentColor" fill-opacity="0.45" stroke="none"/>'
    + '<path d="M31 30h7v54h-7zM62 30h7v54h-7z" stroke-width="1.7"/>'
    # duboka šupljina između njih
    + '<path d="M38 30h24v54H38z" fill="currentColor" fill-opacity="0.05"/>'
    + '<path d="M38 30h24" stroke-dasharray="3 3" stroke-opacity="0.6" stroke-width="1.7"/>'
    + dots([(45, 40), (55, 46), (44, 56), (56, 62), (50, 70), (46, 76)])
    # kontrolisan izlaz kroz proreze u gornjoj polovini
    + '<path d="M69 44h5M69 56h5" stroke-width="1.7" stroke-opacity="0.75"/>'
    + '<rect x="27" y="84" width="46" height="12" rx="3" fill="currentColor" fill-opacity="0.5" stroke="none"/>'
    + '<rect x="27" y="84" width="46" height="12" rx="3"/>'
    + f'<circle cx="50" cy="27" r="4" fill="{INK}" fill-opacity="0.6"/>'
    + arrow(78, 50, -6, ln=8, op=0.6)
    + ground(y=104)
)




# ── MAGGOT: zatvorena poklopcima, puni se živim crvima ────────────────────
# Identitet: poklopci na krajevima (zato živi mamac ne izleti pri udaru) +
# crvi unutra umesto praškaste primame.
def _worm(x, y, w=9):
    return (f'<path d="M{x} {y}q{w/3:.1f} -3 {w*2/3:.1f} 0t{w/3:.1f} 0" '
            f'stroke-width="2" stroke-opacity="0.7"/>')


MAGGOT = wrap(
    SWIVEL
    # poklopci — odvojeni, malo odmaknuti da se vidi da se skidaju
    + '<rect x="26" y="24" width="48" height="8" rx="4" fill="currentColor" fill-opacity="0.5" stroke="none"/>'
    + '<rect x="26" y="24" width="48" height="8" rx="4"/>'
    + '<rect x="26" y="86" width="48" height="8" rx="4" fill="currentColor" fill-opacity="0.5" stroke="none"/>'
    + '<rect x="26" y="86" width="48" height="8" rx="4"/>'
    # telo
    + '<path d="M31 32v54"/><path d="M69 32v54"/>'
    + '<path d="M36 40h2M62 40h2M36 54h2M62 54h2M36 68h2M62 68h2" stroke-width="1.6" stroke-opacity="0.6"/>'
    # crvi unutra
    + _worm(38, 44) + _worm(52, 50) + _worm(37, 60) + _worm(51, 66) + _worm(43, 76)
    # olovo
    + '<rect x="31" y="76" width="8" height="10" rx="4" fill="currentColor" fill-opacity="0.4" stroke="none"/>'
    # poklopci se skidaju
    + arrow(80, 28, -35, ln=8, op=0.6) + arrow(80, 90, 35, ln=8, op=0.6)
    + ground()
)

FEEDERS = [
    ('cage', 'Cage / kavez', CAGE),
    ('open', 'Open-end', OPEN_END),
    ('window', 'Window', WINDOW),
    ('method', 'Method', METHOD),
    ('pellet', 'Pellet', PELLET),
    ('hybrid', 'Hybrid', HYBRID),
    ('maggot', 'Maggot / za crve', MAGGOT),
]


# ═══════════════════════════════════════════════════════════════════════════
# MONTAŽE (feeder) — razlika je u tome KUDA ide najlon i šta radi kad pukne
# ═══════════════════════════════════════════════════════════════════════════

def _hook(x, y, s=1.0):
    """Udica, vrh nalevo."""
    return (f'<path d="M{x} {y}v{7*s}a{4*s} {4*s} 0 0 0 {-8*s} 0" '
            f'stroke-width="1.8"/>')


def surface(y=14):
    return (f'<path d="M8 {y}q6 -3 12 0t12 0t12 0t12 0t12 0t12 0t12 0" '
            f'stroke-width="1.5" stroke-opacity="0.4"/>')


# Inline: najlon prolazi KROZ telo, hranilica spada ako pukne
RIG_INLINE = wrap(
    surface()
    + '<path d="M50 16v22" stroke-width="1.6"/>'
    # telo hranilice sa kanalom kroz centar
    + '<path d="M50 38C64 45 67 66 63 82H37C33 66 36 45 50 38Z" fill="currentColor" fill-opacity="0.07"/>'
    + '<path d="M50 38v44" stroke-dasharray="3 3" stroke-opacity="0.85" stroke-width="1.7"/>'
    + '<rect x="30" y="82" width="40" height="10" rx="3" fill="currentColor" fill-opacity="0.45" stroke="none"/>'
    + '<rect x="30" y="82" width="40" height="10" rx="3"/>'
    # predvez + udica ispod
    + '<path d="M50 92v10" stroke-width="1.6"/>'
    + _hook(50, 102)
    # oznaka: spada s najlona
    + arrow(74, 62, -30, ln=9, op=0.65)
)

# Free-running: hranilica visi sa prstena koji klizi PO najlonu
RIG_RUNNING = wrap(
    surface()
    + '<path d="M50 16v88" stroke-width="1.6"/>'
    # prsten koji klizi
    + '<circle cx="50" cy="40" r="6" stroke-width="2"/>'
    + arrow(50, 30, -90, ln=7, op=0.6) + arrow(50, 50, 90, ln=7, op=0.6)
    # hranilica visi sa strane
    + '<path d="M56 40h8" stroke-width="1.6"/>'
    + '<rect x="64" y="30" width="20" height="34" rx="6" fill="currentColor" fill-opacity="0.07"/>'
    + '<rect x="64" y="30" width="20" height="34" rx="6"/>'
    + '<path d="M70 34v26M77 34v26" stroke-opacity="0.45" stroke-width="1.3"/>'
    + '<rect x="64" y="56" width="20" height="8" rx="4" fill="currentColor" fill-opacity="0.45" stroke="none"/>'
    # perla + predvez + udica
    + f'<circle cx="50" cy="76" r="3.5" fill="{INK}" fill-opacity="0.5"/>'
    + _hook(50, 104)
)

# Paternoster: hranilica na kratkom donjem kraku, predvez na petlji iznad
RIG_PATERNOSTER = wrap(
    surface()
    + '<path d="M50 16v42" stroke-width="1.6"/>'
    # petlja za predvez
    + '<path d="M50 58a7 7 0 1 0 0 14a7 7 0 1 0 0-14" stroke-width="1.7"/>'
    # predvez u stranu + udica
    + '<path d="M43 65H22" stroke-width="1.6"/>'
    + _hook(22, 65)
    # donji krak sa hranilicom
    + '<path d="M57 65h6v20" stroke-width="1.6"/>'
    + '<rect x="54" y="85" width="18" height="16" rx="5" fill="currentColor" fill-opacity="0.07"/>'
    + '<rect x="54" y="85" width="18" height="16" rx="5"/>'
    + '<rect x="54" y="95" width="18" height="6" rx="3" fill="currentColor" fill-opacity="0.45" stroke="none"/>'
)

RIGS = [
    ('inline', 'Inline', RIG_INLINE),
    ('running', 'Free-running', RIG_RUNNING),
    ('paternoster', 'Paternoster', RIG_PATERNOSTER),
]


# ═══════════════════════════════════════════════════════════════════════════
# OLOVLJAVANJE — razlika je u tome KAKO mamac pada kroz vodu
# ═══════════════════════════════════════════════════════════════════════════

def _float(x, y_top, y_body, body_h=14, w=4.5):
    """Plovak: antena + telo."""
    return (f'<path d="M{x} {y_top}v{y_body - y_top}" stroke-width="1.8"/>'
            f'<ellipse cx="{x}" cy="{y_body + body_h/2}" rx="{w}" ry="{body_h/2}" '
            f'fill="currentColor" fill-opacity="0.35"/>')


def _shot(x, y, r=2.6):
    return (f'<circle cx="{x}" cy="{y}" r="{r}" fill="{INK}" '
            f'fill-opacity="0.75" stroke="none"/>')


def _bed(y=112):
    return (f'<path d="M6 {y}q8 -4 16 0t16 0t16 0t16 0t16 0t16 0" '
            f'stroke-width="1.6" stroke-opacity="0.5"/>')


# Bulk uz plovak: sve olovo gore -> mamac pada kao kamen
SHOT_BULK = wrap(
    surface(y=26) + _float(50, 8, 26)
    + '<path d="M50 40v66" stroke-width="1.5"/>'
    + _shot(50, 46) + _shot(50, 52) + _shot(50, 58)
    + _shot(50, 84, r=1.9) + _shot(50, 92, r=1.9)
    + _hook(50, 104, s=0.9)
    # brz pad
    + arrow(66, 50, 78, ln=26, op=0.55)
    + _bed()
)

# Stringer: opadajuće sačme -> mamac lebdi nadole
SHOT_STRINGER = wrap(
    surface(y=26) + _float(50, 8, 26)
    + '<path d="M50 40v66" stroke-width="1.5"/>'
    + _shot(50, 48, r=2.6) + _shot(50, 60, r=2.3) + _shot(50, 71, r=2.0)
    + _shot(50, 81, r=1.8) + _shot(50, 90, r=1.6)
    + _hook(50, 104, s=0.9)
    # spor, prirodan pad
    + '<path d="M66 46q7 10 0 20t0 20t0 16" stroke-width="1.5" stroke-opacity="0.5"/>'
    + arrow(66, 100, 82, ln=6, op=0.5)
    + _bed()
)

# Struja: bulk na 2/3 + jedna sačma uz udicu -> drži liniju
SHOT_STREAM = wrap(
    surface(y=26) + _float(50, 8, 26)
    + '<path d="M50 40q4 20 0 34t2 30" stroke-width="1.5"/>'
    + _shot(52, 70) + _shot(52, 76) + _shot(52, 82)
    + _shot(52, 98, r=1.9)
    + _hook(52, 104, s=0.9)
    # strelice struje
    + arrow(14, 40, 0, ln=12, op=0.45) + arrow(14, 62, 0, ln=12, op=0.45)
    + arrow(14, 84, 0, ln=12, op=0.45)
    + _bed()
)

SHOTTING = [
    ('bulk', 'Bulk uz plovak', SHOT_BULK),
    ('stringer', 'Stringer', SHOT_STRINGER),
    ('stream', 'Struja', SHOT_STREAM),
]


# ═══════════════════════════════════════════════════════════════════════════
# PLOVCI — razlika je u tome NA KOLIKO TAČAKA se vezuje za strunu
# ═══════════════════════════════════════════════════════════════════════════

FLOAT_WAGGLER = wrap(
    surface(y=44)
    # struna prolazi samo kroz donji prsten
    + '<path d="M28 18h30" stroke-width="1.6"/>'
    + '<circle cx="62" cy="18" r="4.5" stroke-width="2"/>'
    + '<path d="M62 22v10" stroke-width="1.6"/>'
    # duga tanka antena + telo nisko
    + '<path d="M62 32v34" stroke-width="2.4"/>'
    + '<ellipse cx="62" cy="80" rx="7" ry="15" fill="currentColor" fill-opacity="0.35"/>'
    + '<path d="M62 95v13" stroke-width="1.6"/>'
)

FLOAT_BOLO = wrap(
    surface(y=40)
    + '<path d="M62 6v104" stroke-width="1.6"/>'
    # dve gumice — gore i dole
    + '<rect x="57" y="24" width="10" height="7" rx="2" fill="currentColor" fill-opacity="0.6" stroke="none"/>'
    + '<rect x="57" y="82" width="10" height="7" rx="2" fill="currentColor" fill-opacity="0.6" stroke="none"/>'
    + '<path d="M62 12v12" stroke-width="2.4"/>'
    # zaobljeno telo između
    + '<path d="M62 31c9 6 11 30 0 51c-11-21-9-45 0-51Z" fill="currentColor" fill-opacity="0.28"/>'
)

FLOAT_TROT = wrap(
    surface(y=40)
    + '<path d="M62 6v104" stroke-width="1.6"/>'
    + '<rect x="57" y="26" width="10" height="7" rx="2" fill="currentColor" fill-opacity="0.6" stroke="none"/>'
    + '<rect x="57" y="76" width="10" height="7" rx="2" fill="currentColor" fill-opacity="0.6" stroke="none"/>'
    # kratka debela antena (vidljivost) + zdepasto telo
    + '<path d="M62 10v16" stroke-width="4"/>'
    + '<path d="M62 33c12 8 13 28 0 43c-13-15-12-35 0-43Z" fill="currentColor" fill-opacity="0.32"/>'
    # vođenje niz vodu
    + arrow(18, 52, 0, ln=14, op=0.5) + arrow(18, 68, 0, ln=14, op=0.5)
)

FLOATS = [
    ('waggler', 'Waggler', FLOAT_WAGGLER),
    ('bolo', 'Bolonjez', FLOAT_BOLO),
    ('trot', 'Za otpuštanje', FLOAT_TROT),
]


# ═══════════════════════════════════════════════════════════════════════════
# VARALICE — razlika je u SILUETI i u tome šta radi u vodi
# ═══════════════════════════════════════════════════════════════════════════

def _treble(x, y):
    return (f'<path d="M{x} {y}v5" stroke-width="1.5"/>'
            f'<path d="M{x} {y+5}l-4 4M{x} {y+5}l4 4M{x} {y+5}v5" stroke-width="1.5"/>')


LURE_SHAD = wrap(
    # jig glava — teška, sa ušicom i okom
    '<circle cx="36" cy="46" r="13" fill="currentColor" fill-opacity="0.5"/>'
    + '<circle cx="36" cy="46" r="13" stroke-width="1.8"/>'
    + '<path d="M36 33V21" stroke-width="1.6"/><circle cx="36" cy="18" r="3.5"/>'
    + f'<circle cx="31" cy="42" r="2.2" fill="{INK}"/>'
    # meko telo — glatko suženo ka repu
    + '<path d="M48 37c14 2 22 6 26 11c-4 5-12 9-26 11Z" fill="currentColor" fill-opacity="0.16"/>'
    + '<path d="M48 37c14 2 22 6 26 11c-4 5-12 9-26 11" stroke-width="1.8"/>'
    # PADDLE rep — ravna uspravna lopatica, to je razlika od tvistera
    + '<path d="M74 48h3a5 5 0 0 1 5 5v14a4 4 0 0 1-7 3l-3-4Z" fill="currentColor" fill-opacity="0.32"/>'
    + '<path d="M74 48h3a5 5 0 0 1 5 5v14a4 4 0 0 1-7 3l-3-4" stroke-width="1.7"/>'
    # udica izlazi kroz gornju stranu tela
    + '<path d="M36 59v13a11 11 0 0 0 19 5" stroke-width="1.8"/>'
    # lopatica vibrira
    + '<path d="M88 54q6 8 0 16" stroke-width="1.4" stroke-opacity="0.4"/>'
)

LURE_TVISTER = wrap(
    '<path d="M30 40c0-7 6-12 13-12s12 5 12 12s-5 12-12 12s-13-5-13-12Z" fill="currentColor" fill-opacity="0.5"/>'
    + '<path d="M43 28V18" stroke-width="1.6"/><circle cx="43" cy="15" r="3.5"/>'
    # kovrdžavi rep
    + '<path d="M55 40h6c14 0 18 12 18 22c0 12-10 18-18 14c8-2 12-8 12-16c0-10-6-14-12-14" fill="currentColor" fill-opacity="0.14" stroke-width="1.8"/>'
    + '<path d="M43 52v16a10 10 0 0 0 18 4" stroke-width="1.8"/>'
    + f'<circle cx="40" cy="37" r="2" fill="{INK}"/>'
)

LURE_MINO = wrap(
    '<circle cx="16" cy="46" r="3.5"/>'
    # vitko telo
    + '<path d="M24 46c8-8 34-12 52 0c-18 12-44 8-52 0Z" fill="currentColor" fill-opacity="0.14"/>'
    + '<path d="M24 46c8-8 34-12 52 0c-18 12-44 8-52 0Z" stroke-width="1.8"/>'
    # rep
    + '<path d="M76 46l10-8v16Z" fill="currentColor" fill-opacity="0.3" stroke-width="1.6"/>'
    # mala usna
    + '<path d="M24 46l-7 6" stroke-width="2.4"/>'
    + f'<circle cx="32" cy="43" r="2" fill="{INK}"/>'
    + _treble(44, 54) + _treble(66, 54)
)

LURE_DEEP = wrap(
    '<circle cx="14" cy="34" r="3.5"/>'
    # zdepasto telo
    + '<path d="M28 40c8-10 30-12 44 0c-12 14-34 12-44 0Z" fill="currentColor" fill-opacity="0.14"/>'
    + '<path d="M28 40c8-10 30-12 44 0c-12 14-34 12-44 0Z" stroke-width="1.8"/>'
    + '<path d="M72 40l10-8v16Z" fill="currentColor" fill-opacity="0.3" stroke-width="1.6"/>'
    # VELIKA usna pod uglom — to je cela poenta
    + '<path d="M28 40L10 64" stroke-width="4"/>'
    + '<path d="M10 64l6 4" stroke-width="2"/>'
    + f'<circle cx="36" cy="37" r="2" fill="{INK}"/>'
    + _treble(46, 49) + _treble(64, 49)
    # ide duboko
    + arrow(50, 76, 90, ln=16, op=0.55)
)

LURE_SPOON = wrap(
    '<circle cx="50" cy="12" r="3.5"/>'
    + '<path d="M50 16v5" stroke-width="1.6"/>'
    # vrtilo
    + '<path d="M47 21h6v4h-6z" fill="currentColor" fill-opacity="0.6" stroke="none"/>'
    # izduženo konkavno telo — jedna ivica puna, druga svetla (udubljenje)
    + '<path d="M50 26c13 10 15 38 6 54c-4 7-9 9-13 7c-9-4-11-16-7-30c4-14 9-25 14-31Z" fill="currentColor" fill-opacity="0.3"/>'
    + '<path d="M50 26c13 10 15 38 6 54c-4 7-9 9-13 7c-9-4-11-16-7-30c4-14 9-25 14-31Z" stroke-width="1.8"/>'
    # unutrašnja ivica = udubljenje kašike
    + '<path d="M50 34c8 10 9 30 3 42c-3 6-6 7-9 6" stroke-width="1.5" stroke-opacity="0.55"/>'
    + _treble(44, 90)
    # klati se levo-desno
    + arrow(76, 52, 20, ln=9, op=0.5) + arrow(24, 52, 160, ln=9, op=0.5)
    + '<path d="M70 66q8 6 0 12" stroke-width="1.4" stroke-opacity="0.35"/>'
)

LURE_SPINNER = wrap(
    # L-žica
    '<path d="M34 30h20" stroke-width="2"/>'
    + '<circle cx="30" cy="30" r="3.5"/>'
    + '<path d="M54 30v10c0 8-6 12-12 14" stroke-width="2"/>'
    # listovi
    + '<path d="M54 30l14-8c4 6 4 14 0 20l-14-8Z" fill="currentColor" fill-opacity="0.35" stroke-width="1.6"/>'
    + '<path d="M62 44l10-4c2 5 2 10 0 14l-10-4Z" fill="currentColor" fill-opacity="0.25" stroke-width="1.5"/>'
    # suknja + udica
    + '<path d="M42 54c-6 4-10 12-10 22M42 54c-2 6-4 14-4 24M42 54c2 6 5 14 6 22" stroke-width="1.6" stroke-opacity="0.65"/>'
    + '<path d="M42 54v18a9 9 0 0 0 16 4" stroke-width="1.8"/>'
)

LURES = [
    ('shad', 'Shad na jig glavi', LURE_SHAD),
    ('tvister', 'Tvister', LURE_TVISTER),
    ('mino', 'Mino vobler', LURE_MINO),
    ('deep', 'Dubokoronac', LURE_DEEP),
    ('spoon', 'Kašika', LURE_SPOON),
    ('spinner', 'Spinnerbait', LURE_SPINNER),
]



# ═══════════════════════════════════════════════════════════════════════════
# NAJLONI — razlika je u rastezanju, prenosu trzaja i vidljivosti u vodi
# ═══════════════════════════════════════════════════════════════════════════

def _sinker(x, y):
    return (f'<path d="M{x-5} {y}h10l-2 9h-6Z" fill="{INK}" fill-opacity="0.55" '
            f'stroke-width="1.5"/>')


# Monofil: rasteže se — opruga gasi trzaj
LINE_MONO = wrap(
    surface(y=22)
    + '<path d="M50 6v34" stroke-width="2"/>'
    # opruga = rastezanje
    + '<path d="M50 40l-9 5l18 7l-18 7l18 7l-18 7l14 5" stroke-width="2"/>'
    + '<path d="M50 78v20" stroke-width="2"/>'
    + _sinker(50, 98)
    # dvoglava strelica = rastezanje
    + '<path d="M76 44v36" stroke-width="1.6" stroke-opacity="0.55"/>'
    + arrow(76, 44, -90, ln=7, op=0.55) + arrow(76, 80, 90, ln=7, op=0.55)
)

# Upletenica: nula rastezanja — trzaj dolazi ceo
LINE_BRAID = wrap(
    surface(y=22)
    + '<path d="M50 6v92" stroke-width="3"/>'
    # pletenica: dve nitke koje se prepliću
    + '<path d="M50 30q6 8 0 16t0 16t0 16t0 16" stroke-width="1.3" stroke-opacity="0.5"/>'
    + '<path d="M50 30q-6 8 0 16t0 16t0 16t0 16" stroke-width="1.3" stroke-opacity="0.5"/>'
    + _sinker(50, 98)
    # trzaj putuje ceo, do gore
    + '<path d="M72 88l-8-10l10-6l-8-10l10-6l-6-8" stroke-width="1.8" stroke-opacity="0.75"/>'
    + arrow(70, 44, -70, ln=9, op=0.75)
)

# Fluorokarbon: u vodi se praktično ne vidi
LINE_FLUORO = wrap(
    surface(y=30)
    + '<path d="M50 6v24" stroke-width="2"/>'
    # pod vodom — skoro nevidljiv
    + '<path d="M50 30v68" stroke-width="2" stroke-dasharray="2 7" stroke-opacity="0.4"/>'
    + _sinker(50, 98)
    # riba gleda i ne vidi
    + '<path d="M14 62c8-7 20-7 26 0c-6 7-18 7-26 0Z" fill="currentColor" fill-opacity="0.14" stroke-width="1.6"/>'
    + '<path d="M14 62l-6-5v10Z" fill="currentColor" fill-opacity="0.3" stroke-width="1.4"/>'
    + f'<circle cx="34" cy="60" r="1.8" fill="{INK}"/>'
)

LINES = [
    ('mono', 'Monofil', LINE_MONO),
    ('braid', 'Upletenica', LINE_BRAID),
    ('fluoro', 'Fluorokarbon', LINE_FLUORO),
]



# ═══════════════════════════════════════════════════════════════════════════
# DUŽINA PREDVEZA — traženje sloja u kome se riba hrani
# Riba ne mora biti na dnu; duži predvez podiže mamac u sloj gde jede.
# ═══════════════════════════════════════════════════════════════════════════

def _fish(x, y, w=16, flip=False):
    d = -1 if flip else 1
    return (f'<path d="M{x} {y}c{4*d} -5 {12*d} -5 {16*d} 0c{-4*d} 5 {-12*d} 5 {-16*d} 0Z" '
            f'fill="currentColor" fill-opacity="0.18" stroke-width="1.6"/>'
            f'<path d="M{x} {y}l{-5*d} -4v8Z" fill="currentColor" fill-opacity="0.35" stroke-width="1.4"/>'
            f'<circle cx="{x + 11*d}" cy="{y - 1}" r="1.6" fill="{INK}" stroke="none"/>')


def _layer(hook_y, fish_y):
    """Hranilica na dnu, predvez nagore, mamac i riba u istom sloju."""
    return wrap(
        surface(y=12)
        # čestice koje propadaju drže ribu u sloju
        + ''.join(f'<circle cx="{x}" cy="{y}" r="1.4" fill="{INK}" fill-opacity="0.35" '
                  f'stroke="none"/>' for x, y in
                  [(24, 30), (33, 46), (26, 62), (35, 78), (22, 90), (30, 34)])
        # hranilica na dnu
        + '<rect x="34" y="94" width="20" height="12" rx="4" fill="currentColor" fill-opacity="0.14"/>'
        + '<rect x="34" y="94" width="20" height="12" rx="4"/>'
        + '<rect x="34" y="100" width="20" height="6" rx="3" fill="currentColor" fill-opacity="0.45" stroke="none"/>'
        + '<path d="M44 12v82" stroke-width="1.6"/>'
        # predvez ide u stranu od glavnog najlona — inače se stope u jednu liniju
        + f'<path d="M52 96Q62 {(96 + hook_y) // 2} 58 {hook_y + 5}" '
          f'stroke-width="1.5" stroke-dasharray="4 3" stroke-opacity="0.85"/>'
        + f'<circle cx="58" cy="{hook_y}" r="3.5" fill="{INK}" fill-opacity="0.6"/>'
        + f'<circle cx="58" cy="{hook_y}" r="3.5" stroke-width="1.4"/>'
        # riba u tom sloju
        + _fish(70, fish_y)
        + _bed(y=108)
    )


LAYER_50 = _layer(hook_y=84, fish_y=84)
LAYER_75 = _layer(hook_y=62, fish_y=62)
LAYER_125 = _layer(hook_y=34, fish_y=34)

LAYERS = [
    ('kratak', 'Predvez 50 cm', LAYER_50),
    ('srednji', 'Predvez 75 cm', LAYER_75),
    ('dug', 'Predvez 125 cm', LAYER_125),
]



# ═══════════════════════════════════════════════════════════════════════════
# ČVOROVI — helperi
#
# ⚠ Koraci čvorova NISU nacrtani. Dva pokušaja (2026-09-08) dala su nečitljivu
# topologiju: udica je tačna, ali se ne vidi kuda kraj prolazi i šta ide ispod
# čega. Nejasan dijagram čvora je gori od nikakvog — po njemu se veže loše.
# Rešenje je fotografija ruku (vidi docs/PROJECT_STATUS.md); komponenta
# `StepSequence` prima i `imageAsset`, pa slike ulaze bez prepravke koda.
#
# `hook()` je proveren i čita se — ostaje za druge dijagrame.
# ═══════════════════════════════════════════════════════════════════════════

def hook(x, y, s=1.0):
    """Udica: velika ušica na (x,y) da se provlačenje strune vidi, prav struk,
    U-krivina i kljun sa bodljom. Kvadratna krivina umesto luka — luk sa
    pogrešnim sweep-om daje oblik sidra."""
    eye_r = 7 * s
    shank = y + 34 * s
    return (
        f'<circle cx="{x}" cy="{y}" r="{eye_r:.1f}" stroke-width="{2*s:.1f}"/>'
        f'<path d="M{x} {y + eye_r:.1f}V{shank:.1f}" stroke-width="{2.4*s:.1f}"/>'
        f'<path d="M{x} {shank:.1f}Q{x + 11*s:.1f} {shank + 15*s:.1f} '
        f'{x + 20*s:.1f} {shank - 2*s:.1f}" stroke-width="{2.4*s:.1f}"/>'
        f'<path d="M{x + 20*s:.1f} {shank - 2*s:.1f}V{y + 14*s:.1f}" '
        f'stroke-width="{2.4*s:.1f}"/>'
        f'<path d="M{x + 20*s:.1f} {y + 14*s:.1f}l{-5*s:.1f} {7*s:.1f}" '
        f'stroke-width="{1.8*s:.1f}"/>'
    )


def tag(path):
    """Slobodan kraj — tanji potez, da se razlikuje od radne strune."""
    return f'<path d="{path}" stroke-width="1.5" stroke-opacity="0.6"/>'


def line(path, w=2.4):
    return f'<path d="{path}" stroke-width="{w}"/>'


def pull(x, y, deg, ln=11):
    """Strelica „vuci ovde"."""
    return arrow(x, y, deg, ln=ln, op=0.85)


W2, H2 = 110, 150


def wrap2(body):
    """Veće platno za čvorove — sitan crtež se ne čita."""
    return (f'<svg viewBox="0 0 {W2} {H2}" fill="none" stroke="currentColor" '
            f'stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
            f'{body}</svg>')




def wraps(x, y0, n, dy=7.0, w=7.0):
    """n namotaja oko struka na `x`, od `y0` nadole.

    Namotaj se vidi sa strane kao kratka dijagonala PREKO struka — to je
    standardni način crtanja bandažiranja i čita se odmah. Struk se crta pre
    namotaja, pa namotaji leže preko njega."""
    out = []
    for i in range(n):
        y = y0 + i * dy
        out.append(f'<path d="M{x - w:.1f} {y + 3:.1f}L{x + w:.1f} {y - 3:.1f}" '
                   f'stroke-width="2"/>')
    return ''.join(out)


def spade(x, y, s=1.0):
    """Udica bez ušice — lopatica na vrhu struka."""
    shank = y + 34 * s
    return (
        f'<path d="M{x - 4.5*s:.1f} {y:.1f}h{9*s:.1f}v{5*s:.1f}h{-9*s:.1f}Z" '
        f'fill="currentColor" fill-opacity="0.4" stroke-width="{1.8*s:.1f}"/>'
        f'<path d="M{x} {y + 5*s:.1f}V{shank:.1f}" stroke-width="{2.4*s:.1f}"/>'
        f'<path d="M{x} {shank:.1f}Q{x + 11*s:.1f} {shank + 15*s:.1f} '
        f'{x + 20*s:.1f} {shank - 2*s:.1f}" stroke-width="{2.4*s:.1f}"/>'
        f'<path d="M{x + 20*s:.1f} {shank - 2*s:.1f}V{y + 14*s:.1f}" '
        f'stroke-width="{2.4*s:.1f}"/>'
        f'<path d="M{x + 20*s:.1f} {y + 14*s:.1f}l{-5*s:.1f} {7*s:.1f}" '
        f'stroke-width="{1.8*s:.1f}"/>'
    )


# ── VEZIVANJE UDICE, KORAK PO KORAK ───────────────────────────────────────
# Dijagram po koraku, ne jedan po čvoru — razlika između koraka (koliko je
# namotaja, gde je kraj) je baš ono što uči. Namotaji se crtaju kao dijagonale
# preko struka, što se čita odmah; petlja preko udice (Palomar) se NE crta.

def _tie_knotless(stage):
    """Knotless: kroz ušicu → namotaji nadole → kraj NATRAG kroz ušicu."""
    body = hook(46, 32) + line('M46 12V25')
    if stage == 1:
        # struna legla uz struk, nit za mamac ostavljena
        body += tag('M53 30V96') + pull(46, 16, -90, ln=10)
    elif stage == 2:
        body += wraps(46, 43, 3, dy=5.0) + tag('M53 66V96')
    elif stage == 3:
        body += wraps(46, 42, 6, dy=4.2) + line('M46 70V100', w=1.8)
        # kraj se vraća kroz ušicu spolja — poenta čvora
        body += line('M46 102q20 -6 17 -38q-2 -28 -14 -34', w=2)
        body += pull(66, 78, -60, ln=9)
    else:
        body += wraps(46, 42, 6, dy=4.2)
        body += line('M46 92q18 -6 15 -36q-2 -26 -13 -32', w=2)
        body += f'<circle cx="61" cy="88" r="5" fill="{INK}" fill-opacity="0.5"/>'
        body += pull(46, 16, -90, ln=10)
    return wrap2(body)


def _tie_snell(stage):
    """Šnelovanje: struna uz struk → namotaji preko nje → izlaz u osi."""
    body = hook(46, 32) + line('M46 12V25')
    if stage == 1:
        body += tag('M52 28V92') + pull(46, 16, -90, ln=10)
    elif stage == 2:
        body += tag('M52 28V92') + wraps(46, 43, 3, dy=5.0)
    elif stage == 3:
        body += wraps(46, 42, 6, dy=4.2) + line('M46 70V104') + pull(46, 112, 90, ln=9)
    else:
        body += wraps(46, 42, 6, dy=4.2) + line('M46 70V104')
        body += pull(46, 16, -90, ln=10) + pull(46, 112, 90, ln=10)
    return wrap2(body)


def _tie_spade(stage):
    """Lopatica: bez ušice — namotaji su jedino što drži strunu uz struk."""
    body = spade(46, 28) + line('M46 8V24')
    if stage == 1:
        body += tag('M52 30V92') + pull(46, 12, -90, ln=10)
    elif stage == 2:
        body += tag('M52 30V92') + wraps(46, 40, 4, dy=5.0)
    elif stage == 3:
        body += wraps(46, 39, 7, dy=3.8) + line('M46 68V104') + pull(46, 112, 90, ln=9)
    else:
        # zategnuto: struna izlazi sa UNUTRAŠNJE strane struka
        body += wraps(46, 39, 7, dy=3.8) + line('M46 68V104')
        body += arrow(60, 96, 200, ln=9, op=0.8)
        body += pull(46, 12, -90, ln=10)
    return wrap2(body)


def _tie_uni(stage):
    """Uni: kraj kroz ušicu, pa petlja i namotaji oko OBA najlona iznad ušice.
    Ušica stoji nisko da čvor ima mesta gore, gde se i pravi."""
    base = hook(46, 96, s=0.75) + line('M46 8V89')
    if stage == 1:
        # kraj provučen kroz ušicu i ostavljen slobodan
        return wrap2(base + tag('M46 92q18 -4 20 -20') + pull(46, 12, -90, ln=10))
    if stage == 2:
        # kraj vraćen nagore, formira petlju uz stajaću strunu
        return wrap2(base
                     + tag('M46 92q20 -6 20 -26V34q0 -10 -10 -10')
                     + arrow(70, 40, 180, ln=9, op=0.65))
    if stage == 3:
        # namotaji UNUTAR petlje, oko oba najlona
        return wrap2(base
                     + tag('M46 92q20 -6 20 -26V36')
                     + wraps(53, 30, 5, dy=6.0, w=9))
    # zategnuto pa privučeno do ušice
    return wrap2(base
                 + wraps(46, 66, 5, dy=4.6, w=7)
                 + tag('M53 64l13-9')
                 + pull(46, 12, -90, ln=10))


KNOTLESS_STEPS = [(f'k{i}', f'Knotless {i}', _tie_knotless(i)) for i in (1, 2, 3, 4)]
SNELL_STEPS = [(f'k{i}', f'Šnelovanje {i}', _tie_snell(i)) for i in (1, 2, 3, 4)]
SPADE_STEPS = [(f'k{i}', f'Lopatica {i}', _tie_spade(i)) for i in (1, 2, 3, 4)]
UNI_STEPS = [(f'k{i}', f'Uni {i}', _tie_uni(i)) for i in (1, 2, 3, 4)]

# Zbirni crteži (za comparator i preglede) = zadnja faza.
TIE_KNOTLESS = _tie_knotless(4)
TIE_SNELL = _tie_snell(4)
TIE_SPADE = _tie_spade(4)
TIE_UNI = _tie_uni(4)

TIES = [
    ('uni', 'Uni / grinner', TIE_UNI),
    ('knotless', 'Knotless / no-knot', TIE_KNOTLESS),
    ('snell', 'Šnelovanje', TIE_SNELL),
    ('spade', 'Lopatica (bez ušice)', TIE_SPADE),
]



# ── ČVOROVI ZA SPAJANJE NAJLONA, korak po korak ───────────────────────────
# Vertikalna postavka: jedan najlon dolazi odozgo, drugi ide nadole. Namotaji
# su i ovde dijagonale preko linije. Gde struna ide ISPOD druge, njen segment
# se ne crta (prekid) — tako se preklapanje čita bez pozadinske boje.

def _uloop(x, y_top, y_bot, w=11):
    """Petlja u obliku U: dva kraka i zaobljeni vrh na dnu."""
    return (f'<path d="M{x - w} {y_top}V{y_bot - w}'
            f'a{w} {w} 0 0 0 {2 * w} 0V{y_top}" stroke-width="2.4"/>')


def _albright(stage):
    """Albright: petlja u DEBLJEM najlonu, tanji se namota oko nje."""
    # debljи najlon dolazi odozgo i savija se u petlju
    thick = f'<path d="M35 10V70a11 11 0 0 0 22 0V16" stroke-width="3.2"/>'
    if stage == 1:
        return wrap2(thick + tag('M84 30q-20 4 -30 14') + pull(84, 26, 200, ln=9))
    if stage == 2:
        return wrap2(thick + tag('M84 30q-24 4 -38 10V96'))
    if stage == 3:
        return wrap2(thick + tag('M84 30q-24 4 -38 10')
                     + tag('M46 40V96')
                     + wraps(46, 26, 8, dy=4.4, w=13))
    if stage == 4:
        return wrap2(thick
                     + wraps(46, 26, 8, dy=4.4, w=13)
                     + tag('M46 62V96')
                     + tag('M60 24q16 0 20 8')
                     + arrow(78, 26, 200, ln=9, op=0.8))
    return wrap2(f'<path d="M35 10V52a11 11 0 0 0 22 0V16" stroke-width="3.2"/>'
                 + wraps(46, 22, 7, dy=4.2, w=12)
                 + tag('M46 54V96')
                 + pull(46, 12, -90, ln=10) + pull(46, 104, 90, ln=10))


def _uni2uni(stage):
    """Uni-na-uni: dva najlona paralelno, po jedan uni čvor sa svake strane."""
    a = '<path d="M38 10V78" stroke-width="2.6"/>'   # gornji najlon
    b = '<path d="M54 46V140" stroke-width="2.6"/>'  # donji najlon
    if stage == 1:
        return wrap2(a + b + tag('M38 78q8 6 16 4') + tag('M54 46q-8 -6 -16 -4'))
    if stage == 2:
        return wrap2(a + b + wraps(46, 54, 5, dy=5.4, w=10)
                     + tag('M38 78q10 4 18 0'))
    if stage == 3:
        return wrap2(a + b + wraps(46, 54, 5, dy=5.4, w=10)
                     + wraps(46, 92, 5, dy=5.4, w=10))
    return wrap2('<path d="M46 10V60" stroke-width="2.6"/>'
                 + '<path d="M46 84V140" stroke-width="2.6"/>'
                 + wraps(46, 62, 4, dy=5.0, w=9)
                 + wraps(46, 74, 4, dy=5.0, w=9)
                 + pull(46, 14, -90, ln=10) + pull(46, 132, 90, ln=10))


def _loop2loop(stage):
    """Loop-to-loop: petlja kroz petlju, pa ceo predvez kroz svoju petlju."""
    top = '<path d="M46 6V40" stroke-width="2.6"/>' + _uloop(46, 40, 66)
    if stage == 1:
        # dve petlje jedna prema drugoj
        return wrap2(top
                     + '<path d="M46 142V116" stroke-width="2.6"/>'
                     + f'<path d="M35 116V96a11 11 0 0 1 22 0v20" stroke-width="2.4"/>')
    if stage == 2:
        # donja petlja provučena kroz gornju — prekid gde ide ispod
        return wrap2(top
                     + '<path d="M46 142V104" stroke-width="2.6"/>'
                     + '<path d="M35 104V74" stroke-width="2.4"/>'
                     + '<path d="M57 104V74" stroke-width="2.4"/>'
                     + '<path d="M35 74a11 11 0 0 1 22 0" stroke-width="2.4" stroke-dasharray="3 3"/>'
                     + arrow(74, 70, 200, ln=10, op=0.8))
    # zategnuto: dva spojena prstena
    return wrap2('<path d="M46 8V34" stroke-width="2.6"/>'
                 + '<ellipse cx="46" cy="52" rx="10" ry="18" stroke-width="2.4"/>'
                 + '<path d="M46 96V140" stroke-width="2.6"/>'
                 + '<ellipse cx="46" cy="78" rx="10" ry="18" stroke-width="2.4"/>'
                 + f'<path d="M36 66h20" stroke-width="2.4" stroke-opacity="0.25"/>'
                 + pull(46, 14, -90, ln=9) + pull(46, 132, 90, ln=9))


ALBRIGHT_STEPS = [(f'k{i}', f'Albright {i}', _albright(i)) for i in (1, 2, 3, 4, 5)]
UNI2UNI_STEPS = [(f'k{i}', f'Uni-na-uni {i}', _uni2uni(i)) for i in (1, 2, 3, 4)]
LOOP2LOOP_STEPS = [(f'k{i}', f'Loop-to-loop {i}', _loop2loop(i)) for i in (1, 2, 3)]



# ⚠ DUPLA PETLJA (surgeon's loop) NIJE nacrtana. Pokušano 2026-09-08: koraci
# "običan uzao" i "provuci petlju drugi put" izlaze kao balon, ne kao uzao —
# ista topologija koja je pala i kod Palomara. Ide na ilustraciju po koraku
# (vidi tools/knot_images.py), kao Palomar.

FAMILIES = [
    ('Feeder', 'kFeeder', FEEDERS),
    ('Rig', 'kRig', RIGS),
    ('Shot', 'kShot', SHOTTING),
    ('Float', 'kFloat', FLOATS),
    ('Lure', 'kLure', LURES),
    ('Line', 'kLine', LINES),
    ('Layer', 'kLayer', LAYERS),
    ('Tie', 'kTie', TIES),
    ('TieKnotless', 'kStepKnotless', KNOTLESS_STEPS),
    ('TieSnell', 'kStepSnell', SNELL_STEPS),
    ('TieSpade', 'kStepSpade', SPADE_STEPS),
    ('TieUni', 'kStepUni', UNI_STEPS),
    ('Albright', 'kStepAlbright', ALBRIGHT_STEPS),
    ('Uni2Uni', 'kStepUni2uni', UNI2UNI_STEPS),
    ('Loop2Loop', 'kStepLoop2loop', LOOP2LOOP_STEPS),
]


def emit_dart(path):
    """Piše lib/data/school_diagrams.dart iz istih SVG-ova koji idu u preview."""
    out = [
        "// GENERISANO iz tools/school_diagrams.py — ne menjaj ručno.\n",
        "// Regeneriši: python3 tools/school_diagrams.py --dart\n",
        "//\n",
        "// Shematski dijagrami za Školu. Jednobojni preko currentColor +\n",
        "// fill-opacity, pa isti crtež radi u light i dark temi (SvgPicture.string\n",
        "// sa colorFilter). Crta se ono što predmet RADI, ne samo obris.\n",
    ]
    for label, prefix, family in FAMILIES:
        out.append("\n// ── %s ──\n" % label)
        for key, name, svg in family:
            esc = svg.replace("\\", "\\\\").replace("'", "\\'")
            out.append("\n/// %s\nconst %s%s = '%s';\n"
                       % (name, prefix, key.capitalize(), esc))
    open(path, 'w').write(''.join(out))


def emit_html(path):
    rows = []
    for label, _, family in FAMILIES:
        cells = ''.join(
            f'<figure><div class="art">{svg}</div><figcaption>{name}</figcaption></figure>'
            for _, name, svg in family)
        rows.append(f'<h4>{label}</h4><div class="row">{cells}</div>')
    body = ''.join(rows)
    html = f"""<!doctype html><meta charset="utf-8"><style>
    body{{margin:0;font:14px system-ui;display:grid;grid-template-columns:1fr 1fr}}
    section{{padding:14px}}
    .light{{background:#F6F3EA;color:#22301F}}
    .dark{{background:#141A15;color:#E8E4D8}}
    .row{{display:flex;gap:2px;margin-bottom:6px}}
    figure{{margin:0;width:106px;text-align:center}}
    .art svg{{width:98px;height:118px}}
    figcaption{{font-size:10px;font-weight:700;opacity:.75}}
    h3{{margin:0 0 6px;font-size:11px;letter-spacing:1.5px;opacity:.55}}
    h4{{margin:8px 0 2px;font-size:10px;letter-spacing:1.2px;opacity:.5}}
    </style>
    <section class="light"><h3>LIGHT</h3>{body}</section>
    <section class="dark"><h3>DARK</h3>{body}</section>"""
    open(path, 'w').write(html)


if __name__ == '__main__':
    import sys
    if '--dart' in sys.argv:
        emit_dart('lib/data/school_diagrams.dart')
    else:
        emit_html(sys.argv[1])
