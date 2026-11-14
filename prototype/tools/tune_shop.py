"""Applique des réglages de valeurs aux alternatives de boutique : met à jour la fiche d'unité (ROSTER), la carte (CARDS) et les spécialisations (BRANCHES).
Usage : python tune_shop.py <fichier JSON {id de carte: {champ: valeur}}>
Les spécialisations des types 10 et suivants sont recalculées à partir des statistiques de base (mêmes recettes que la création des lots)."""
import json, re, sys, pathlib
ROOT = pathlib.Path(__file__).resolve().parent.parent
RULE_KEYS = ("wounded_bonus", "heavy_mult", "small_mult", "fast_mult", "slow_seconds", "mark_seconds", "mark_bonus", "aura_radius", "aura_bonus", "loot_seconds", "loot_bonus", "entrance_mult", "exit_mult", "volatile_seconds", "volatile_damage", "volatile_radius", "pivot_bonus")
ORDER = ("price", "damage", "interval", "range", "secondary_damage", "secondary_cap", "radius", "curse_damage") + RULE_KEYS

def fmt(key, value):
    if key in ("secondary_cap", "price"): return str(int(value))
    s = ('%.3f' % value).rstrip('0').rstrip('.')
    return s if '.' in s else s + '.0'

def parse(text):
    return {k: float(v) for k, v in re.findall(r'"(\w+)":(-?[\d.]+)', text)}

def render(stats):
    keys = [k for k in ORDER if k in stats]
    return ','.join('"%s":%s' % (k, fmt(k, stats[k])) for k in keys)

def branches(base, names):
    a = {"damage": base["damage"]*4.875, "interval": round(base["interval"]*1.43, 3), "range": base["range"]+1.0}
    b = {"damage": base["damage"]*2.4375, "interval": round(base["interval"]*0.6, 3), "range": max(1.5, base["range"]-0.5)}
    if "secondary_damage" in base:
        a["secondary_damage"] = base["secondary_damage"]*3.0; b["secondary_damage"] = base["secondary_damage"]*3.25
        b["secondary_cap"] = base["secondary_cap"]+2; b["radius"] = round(base["radius"]+0.25, 2)
    if "curse_damage" in base:
        a["curse_damage"] = base["curse_damage"]*4.875; b["curse_damage"] = base["curse_damage"]*2.4375
    descriptions = ("Impact et portée renforcés, tirs moins fréquents.", "Cadence renforcée, portée réduite.")
    if "secondary_damage" in base: descriptions = ("Impact renforcé, éclats plus puissants.", "Chaîne étendue à plus de voisins, impact réduit.")
    if "curse_damage" in base: descriptions = ("Brûlure beaucoup plus forte, impact réduit.", "Brûlure plus modérée, tirs plus fréquents.")
    out = []
    for name, desc, d in ((names[0], descriptions[0], a), (names[1], descriptions[1], b)):
        fields = ['"name":"%s"' % name, '"description":"%s"' % desc]
        for key in ("damage", "interval", "range", "secondary_damage", "secondary_cap", "radius", "curse_damage"):
            if key in d: fields.append('"%s":%s' % (key, fmt(key, d[key])))
        out.append('{' + ','.join(fields) + '}')
    return '[' + ','.join(out) + ']'

def main():
    tuning = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding='utf-8'))
    model_path = ROOT / 'scripts/valley_model.gd'; shop_path = ROOT / 'scripts/shop_catalogue.gd'
    model = model_path.read_bytes().decode('utf-8'); crlf_m = '\r\n' in model; model = model.replace('\r\n', '\n')
    shop = shop_path.read_bytes().decode('utf-8'); crlf_s = '\r\n' in shop; shop = shop.replace('\r\n', '\n')
    for card_id, changes in tuning.items():
        card_line = next(l for l in shop.split('\n') if ('"id":"%s"' % card_id) in l)
        name = re.search(r'"name":"([^"]+)"', card_line)[1]
        type_id = int(re.search(r'"type":(\d+)', card_line)[1])
        stats_text = re.search(r'"stats":\{([^}]*)\}', card_line)[1]
        stats = parse(stats_text); stats.update(changes)
        new_card_line = card_line.replace('"stats":{%s}' % stats_text, '"stats":{%s}' % render(stats))
        shop = shop.replace(card_line, new_card_line)
        roster_line = next(l for l in model.split('\n') if l.strip().startswith('{"name":"%s"' % name) and '"price"' in l)
        roster_stats = {k: v for k, v in stats.items()}
        new_roster = '\t{"name":"%s",%s},' % (name, render(roster_stats))
        model = model.replace(roster_line, new_roster)
        if type_id >= 10:
            base = {k: v for k, v in stats.items() if k not in RULE_KEYS and k != 'price'}
            line = next(l for l in shop.split('\n') if l.startswith('\t%d:[' % type_id))
            names = re.findall(r'"name":"([^"]+)"', line)
            shop = shop.replace(line, '\t%d:%s%s' % (type_id, branches(base, names[:2]), ',' if line.endswith(',') else ''))
    model_path.write_bytes((model.replace('\n', '\r\n') if crlf_m else model).encode('utf-8'))
    shop_path.write_bytes((shop.replace('\n', '\r\n') if crlf_s else shop).encode('utf-8'))
    print('réglages appliqués :', len(tuning))

main()
