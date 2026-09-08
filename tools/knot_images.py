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
    # Dupla petlja (surgeon's loop): 4 panela vertikalno (1000x1573).
    'surgeon-loop': {
        'surgeonloop-1': (0, 15, 1000, 400),
        'surgeonloop-2': (0, 460, 1000, 855),
        'surgeonloop-3': (0, 900, 1000, 1225),
        'surgeonloop-4': (0, 1280, 1000, 1490),
    },
    # Hirurški čvor: 4 panela vertikalno, brojevi levo (1199x1312).
    'surgeon': {
        'surgeon-1': (100, 40, 1199, 180),
        'surgeon-2': (100, 270, 1199, 575),
        'surgeon-3': (100, 605, 1199, 980),
        'surgeon-4': (100, 1035, 1199, 1270),
    },
}


if __name__ == '__main__':
    src_path, out_dir = sys.argv[1], sys.argv[2]
    which = sys.argv[3] if len(sys.argv) > 3 else 'palomar'
    src = Image.open(src_path).convert('RGB')
    boxes = PANELS[which]
    for name, box in boxes.items():
        size = panel(src, box, f'{out_dir}/{name}.png')
        print(f'{name}.png {size[0]}x{size[1]}')
