#!/usr/bin/env python3
"""Build tehnika ikonice iz fotografija pribora.

Ulaz:  data_raw/tech_icons/{feeder.jpg, varalica.webp, plovak.jpg}
Izlaz: assets/icons/{tech_feeder.png, tech_varalica.png, tech_plovak.png}

Fotografije su na beloj podlozi. Skripta izvadi subjekat, autokropuje,
uklopi u kvadrat i kvantizuje na paletu (mrežica feedera inače pravi
PNG od 250 kB umesto 14 kB).

Prikazuju se na 34 px pločici u `_TechniqueTabs` (result_screen.dart),
pa je 256 px dovoljno i za 3x ekran.

Zahteva: Pillow.
"""
from PIL import Image, ImageChops, ImageFilter

SIZE = 256
FILL = 0.88  # koliki deo kvadrata subjekat popunjava

SRC = 'data_raw/tech_icons/'
DST = 'assets/icons/'


def dist_from_white(rgb):
    """Po pikselu: max(255-R, 255-G, 255-B). Bela = 0, krem ~55, crna = 255.
    Radi tamo gde bi obična luminansa pojela svetlo telo plovka."""
    r, g, b = rgb.split()
    inv = [ImageChops.invert(c) for c in (r, g, b)]
    return ImageChops.lighter(ImageChops.lighter(inv[0], inv[1]), inv[2])


def cutout(src, lo=14, hi=34):
    """Belu pozadinu u providno, sa mekim prelazom na ivici."""
    im = Image.open(src).convert('RGB')
    d = dist_from_white(im).filter(ImageFilter.GaussianBlur(0.6))
    span = hi - lo
    a = d.point(lambda v: 0 if v <= lo else (255 if v >= hi else int(255 * (v - lo) / span)))
    # ubij JPEG šum u pozadini, pa vrati punoću subjektu
    a = a.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.MaxFilter(3))
    out = im.copy()
    out.putalpha(a)
    return out.crop(out.getbbox())


def row_widths(img):
    a = img.split()[3]
    w, h = a.size
    out = []
    for y in range(h):
        row = a.crop((0, y, w, y + 1)).point(lambda v: 255 if v > 96 else 0)
        bb = row.getbbox()
        out.append(0 if bb is None else bb[2] - bb[0])
    return out


def trim_thin_tail(img, body_at=0.5, ext=0.22):
    """Plovak je 90% tanka žica + antena; bbox ispadne ogroman a telo
    mikroskopsko. Zadrži telo i komad antene/žice, ostalo odseci.
    Očekuje uspravljen plovak."""
    ws = row_widths(img)
    mx = max(ws)
    body = [y for y, w in enumerate(ws) if w >= body_at * mx]
    top, bot = body[0], body[-1]
    pad = int(ext * (bot - top + 1))
    cut = img.crop((0, max(0, top - pad), img.width, min(img.height, bot + pad)))
    return cut.crop(cut.getbbox())


def finish(img, name, rotate=0.0, fill=FILL):
    if rotate:
        img = img.rotate(rotate, resample=Image.BICUBIC, expand=True)
        img = img.crop(img.getbbox())
    target = int(SIZE * fill)
    w, h = img.size
    s = target / max(w, h)
    img = img.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)

    canvas = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    canvas.paste(img, ((SIZE - img.width) // 2, (SIZE - img.height) // 2), img)
    canvas.quantize(colors=128, method=Image.FASTOCTREE).save(DST + name, optimize=True)

    cover = sum(canvas.split()[3].histogram()[200:]) / (SIZE * SIZE)
    print(f'{DST}{name}  pokrivenost {cover:.1%}')


finish(cutout(SRC + 'feeder.jpg'), 'tech_feeder.png', rotate=-12)
finish(cutout(SRC + 'varalica.webp'), 'tech_varalica.png')

# Plovak stoji pod ~49° — uspravi ga, skini žicu, pa blagi nagib nazad.
# Vitak je, pa ide do same ivice kvadrata da mu težina prati ostale dve.
p = cutout(SRC + 'plovak.jpg')
p = p.rotate(41, resample=Image.BICUBIC, expand=True)
p = trim_thin_tail(p.crop(p.getbbox()))
finish(p, 'tech_plovak.png', rotate=30, fill=1.0)
