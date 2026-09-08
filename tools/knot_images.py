"""Priprema fotografija/ilustracija čvorova za Školu.

Ulaz je jedna složena slika sa više panela (crne linije na beloj pozadini).
Izlaz je po jedan PNG na korak, sa PROZIRNOM pozadinom i crnim linijama u
alfa kanalu — tako `Image.asset(color: ..., colorBlendMode: srcIn)` može da
oboji linije po temi, isto kao SVG dijagrame.

Belo se ne briše pragom nego ide u alfu preko luminancije, da anti-aliasing
ivica ostane gladak.
"""
import sys
from PIL import Image


MAX_SIDE = 820  # line art se ne gleda veće; drži PNG male


def auto_rows(src, expected, gap=14, step=3):
    """Nalazi panele u slici složenoj vertikalno, po prazninama u tinti.

    Ručno pogađanje koordinata je već jednom odsekло dno crteža (dupla petlja,
    panel 4). Ovo meri gde tinta zaista počinje i staje, pa reza nema šanse da
    promaši. `step` preskače piksele po x — detekcija ne traži tačnost.
    """
    g = src.convert('L')
    w, h = g.size
    px = g.load()
    ink = []
    for y in range(h):
        for x in range(0, w, step):
            if px[x, y] < 128:
                ink.append(y)
                break
    if not ink:
        raise SystemExit('nema tinte u slici')
    bands = []
    start = prev = ink[0]
    for y in ink[1:]:
        if y - prev > gap:
            bands.append((start, prev))
            start = y
        prev = y
    bands.append((start, prev))
    # Odbaci šum (jedan red piksela na ivici screenshot-a i sl.)
    bands = [(a, b) for a, b in bands if b - a >= 8]
    # Naslov slike je uvek prvi band, paneli idu posle — uzmi poslednjih n.
    if len(bands) < expected:
        raise SystemExit(
            f'nadjeno {len(bands)} bandova, treba {expected}: {bands}')
    return bands[-expected:]


def panel(src, box, out, pad=14):
    im = src.crop(box).convert('L')
    # luminancija -> alfa: belo (255) prozirno, crno (0) puno
    alpha = im.point(lambda v: 255 - v)
    black = Image.new('RGB', im.size, (0, 0, 0))
    rgba = black.convert('RGBA')
    rgba.putalpha(alpha)
    # tesno opseci na stvarni sadržaj, pa dodaj marginu
    bbox = rgba.getbbox()
    if bbox:
        rgba = rgba.crop(bbox)
    w, h = rgba.size
    canvas = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    canvas.paste(rgba, (pad, pad))
    if max(canvas.size) > MAX_SIDE:
        r = MAX_SIDE / max(canvas.size)
        canvas = canvas.resize(
            (round(canvas.width * r), round(canvas.height * r)), Image.LANCZOS)
    canvas.save(out, optimize=True)
    return canvas.size


# Paneli po izvornoj slici. Paneli se dodiruju, pa su rezovi zategnuti da ne
# uvuku susedni crtež — proveri preview posle svake promene.
PANELS = {
    # Palomar: 2x2 raspored (1736x906).
    'palomar': {
        'palomar-1': (0, 55, 922, 375),
        'palomar-2': (955, 15, 1736, 525),
        'palomar-3': (95, 385, 725, 885),
        'palomar-4': (840, 560, 1736, 840),
    },
    # Vertikalno složene sekvence — paneli se nalaze automatski.
    # ('rows', broj_panela, prefiks, x_od) — x_od odseca brojeve koraka levo.
    'surgeon-loop': ('rows', 4, 'surgeonloop', 0),
    'surgeon': ('rows', 4, 'surgeon', 100),
    # Slike u boji (plava + bela sa crnim obrisom). Luminancija -> alfa čuva
    # razliku: plava ostaje poluispunjena, bela postaje šuplji obris.
    'albright': ('rows', 5, 'albright', 0),
    'loop2loop': ('rows', 4, 'loop2loop', 0),
    'uniknot': ('rows', 4, 'uniknot', 0),
    # Uni na pravoj udici, bez engleskih labela. Paneli 2 i 3 se dodiruju bez
    # praznine, pa auto-detekcija ne pomaže — rez je na najmanjoj gustini
    # tinte (y=586), izmerenoj, ne pogođenoj.
    'uni-hook': {
        'unihook-1': (0, 40, 1536, 292),
        'unihook-2': (0, 312, 1536, 586),
        'unihook-3': (0, 586, 1536, 764),
        'unihook-4': (0, 810, 1536, 992),
    },
    # Knotless („dlaka"): kroz ušicu, namotaji nadole, kraj natrag kroz
    # ušicu — tag koji ostaje desno je nit za mamac.
    'knotless': ('rows', 4, 'knotless', 0),
}


if __name__ == '__main__':
    src_path, out_dir = sys.argv[1], sys.argv[2]
    which = sys.argv[3] if len(sys.argv) > 3 else 'palomar'
    src = Image.open(src_path).convert('RGB')
    spec = PANELS[which]
    if isinstance(spec, tuple):
        _, n, prefix, x0 = spec
        bands = auto_rows(src, n)
        boxes = {f'{prefix}-{i}': (x0, a - 4, src.width, b + 4)
                 for i, (a, b) in enumerate(bands, 1)}
    else:
        boxes = spec
    for name, box in boxes.items():
        size = panel(src, box, f'{out_dir}/{name}.png')
        print(f'{name}.png {size[0]}x{size[1]}')
