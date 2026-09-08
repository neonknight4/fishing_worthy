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


if __name__ == '__main__':
    src_path, out_dir = sys.argv[1], sys.argv[2]
    src = Image.open(src_path).convert('RGB')
    # Paneli Palomar sekvence u izvornoj slici (1736x906).
    # Paneli se dodiruju, pa su rezovi zategnuti da ne uvuku susedni crtež.
    boxes = {
        'palomar-1': (0, 55, 922, 375),
        'palomar-2': (955, 15, 1736, 525),
        'palomar-3': (95, 385, 725, 885),
        'palomar-4': (840, 560, 1736, 840),
    }
    for name, box in boxes.items():
        size = panel(src, box, f'{out_dir}/{name}.png')
        print(f'{name}.png {size[0]}x{size[1]}')
