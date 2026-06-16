#!/usr/bin/env python3
"""Build RHMZ hydrological station coordinate bundle.
Parses data_raw/stanje_voda.html for stations, geocodes each town via
Open-Meteo, writes assets/data/rhmz_stations.json.
"""
import re, html, json, os, time, urllib.parse, urllib.request

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
def tr(s):
    return ''.join(CYR2LAT.get(c, c) for c in s)

def titlecase(s):
    return ' '.join(w.capitalize() for w in s.split())

t = open('data_raw/stanje_voda.html', encoding='utf-8', errors='replace').read()
rows = re.findall(r'<tr[^>]*>(.*?)</tr>', t, re.S)
def txt(td):
    return html.unescape(re.sub('<[^>]+>', '', td)).replace('\xa0', ' ').strip()

stations = []
for r in rows:
    tds = re.findall(r'<td.*?</td>', r, re.S)
    if len(tds) < 6:
        continue
    river = txt(tds[0])
    if not river or 'Река' in river:
        continue
    m = re.search(r'hm_id=(\d+)', r)
    if not m:
        continue
    hm = m.group(1)
    station = ''
    for td in tds:
        if 'hm_id=' + hm in td:
            station = txt(td); break
    if not station:
        continue
    stations.append({
        'hm': hm,
        'river': titlecase(tr(river)),
        'station': titlecase(tr(station)),
        'station_cyr': station,
    })

print(f'stations parsed: {len(stations)}')

def geocode(name):
    q = urllib.parse.urlencode({'name': name, 'count': '10', 'language': 'sr-Latn', 'format': 'json'})
    url = f'https://geocoding-api.open-meteo.com/v1/search?{q}'
    try:
        with urllib.request.urlopen(url, timeout=15) as resp:
            d = json.load(resp)
    except Exception:
        return None
    for res in d.get('results', []):
        if res.get('country_code') == 'RS':
            return (round(res['latitude'], 4), round(res['longitude'], 4))
    return None

out = []
misses = []
for s in stations:
    coord = geocode(s['station'])
    if coord is None:
        misses.append(s['station'])
        continue
    out.append({'hm': s['hm'], 'r': s['river'], 's': s['station'], 'lat': coord[0], 'lon': coord[1]})
    time.sleep(0.15)

os.makedirs('assets/data', exist_ok=True)
with open('assets/data/rhmz_stations.json', 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, separators=(',', ':'))

print(f'geocoded: {len(out)} / {len(stations)}')
print(f'misses ({len(misses)}): {misses}')
print(f'file size: {os.path.getsize("assets/data/rhmz_stations.json")/1024:.1f} KB')
