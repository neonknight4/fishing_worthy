#!/usr/bin/env python3
"""Build offline Serbian fishing-waters dataset from raw Overpass JSON.
Input:  data_raw/rivers.json, data_raw/water.json
Output: assets/data/serbia_waters.json
"""
import json, os

CYR2LAT = {
    'а':'a','б':'b','в':'v','г':'g','д':'d','ђ':'đ','е':'e','ж':'ž','з':'z',
    'и':'i','ј':'j','к':'k','л':'l','љ':'lj','м':'m','н':'n','њ':'nj','о':'o',
    'п':'p','р':'r','с':'s','т':'t','ћ':'ć','у':'u','ф':'f','х':'h','ц':'c',
    'ч':'č','џ':'dž','ш':'š',
    'А':'A','Б':'B','В':'V','Г':'G','Д':'D','Ђ':'Đ','Е':'E','Ж':'Ž','З':'Z',
    'И':'I','Ј':'J','К':'K','Л':'L','Љ':'Lj','М':'M','Н':'N','Њ':'Nj','О':'O',
    'П':'P','Р':'R','С':'S','Т':'T','Ћ':'Ć','У':'U','Ф':'F','Х':'H','Ц':'C',
    'Ч':'Č','Џ':'Dž','Ш':'Š',
}

def translit(s):
    return ''.join(CYR2LAT.get(ch, ch) for ch in s)

def best_name(tags):
    # prefer Latin name tags, else transliterate
    for k in ('name:sr-Latn', 'name:sr-Latin', 'int_name'):
        if tags.get(k):
            return tags[k].strip()
    n = tags.get('name', '').strip()
    return translit(n) if n else ''

def load(path):
    with open(path) as f:
        return json.load(f).get('elements', [])

def center(el):
    lat = el.get('lat') or (el.get('center') or {}).get('lat')
    lon = el.get('lon') or (el.get('center') or {}).get('lon')
    return (lat, lon)

# name -> {type, points:set}
waters = {}

def classify_river(tags):
    return 'river'

def classify_water(tags):
    wt = tags.get('water')
    if wt in ('river', 'oxbow', 'canal', 'stream_pool'):
        return 'river'
    return 'lake'

def is_junk(name):
    # must contain at least 2 alphabetic chars
    letters = [c for c in name if c.isalpha()]
    if len(letters) < 2:
        return True
    low = name.lower()
    # fountains / drinking fountains — not fishing waters
    for bad in ('fontana', 'česma', 'cesma', 'česme', 'sebilj'):
        if bad in low:
            return True
    return False

def is_non_fishing(tags):
    if tags.get('amenity') == 'fountain':
        return True
    if tags.get('water') in ('fountain', 'wastewater', 'reflecting_pool'):
        return True
    return False

def add(el, kind):
    tags = el.get('tags', {})
    if is_non_fishing(tags):
        return
    name = best_name(tags)
    if not name or is_junk(name):
        return
    lat, lon = center(el)
    if lat is None or lon is None:
        return
    typ = classify_river(tags) if kind == 'river' else classify_water(tags)
    key = (name, typ)
    if key not in waters:
        waters[key] = set()
    # grid-snap to ~0.01 deg (~1.1km) to thin dense river segments
    waters[key].add((round(lat, 2), round(lon, 2)))

for el in load('data_raw/rivers.json'):
    add(el, 'river')
for el in load('data_raw/water.json'):
    add(el, 'water')

# Build output, cap points per water to bound size
MAX_PTS = 60
out = []
for (name, typ), pts in waters.items():
    plist = sorted(pts)
    if len(plist) > MAX_PTS:
        # evenly sample
        step = len(plist) / MAX_PTS
        plist = [plist[int(i * step)] for i in range(MAX_PTS)]
    out.append({
        'n': name,
        't': typ,
        'p': [[lat, lon] for lat, lon in plist],
    })

out.sort(key=lambda w: w['n'].lower())

os.makedirs('assets/data', exist_ok=True)
with open('assets/data/serbia_waters.json', 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, separators=(',', ':'))

rivers = sum(1 for w in out if w['t'] == 'river')
lakes = sum(1 for w in out if w['t'] == 'lake')
total_pts = sum(len(w['p']) for w in out)
size = os.path.getsize('assets/data/serbia_waters.json')
print(f'distinct waters: {len(out)} (rivers {rivers}, lakes {lakes})')
print(f'total points: {total_pts}')
print(f'file size: {size/1024:.1f} KB')
print('sample:', [w['n'] for w in out[:15]])
