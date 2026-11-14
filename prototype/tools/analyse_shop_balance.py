"""Agrège les sorties de balance_shop.gd : rapport de puissance de chaque alternative à la référence de sa faction.
Usage : python analyse_shop_balance.py <dossier des sorties> <étiquette>
Le rapport d'une unité est la moyenne, sur cartes et ordres, de seuil(unité) / seuil(référence) ; 1,00 = parité avec l'unité de référence remplacée."""
import re, sys, pathlib, statistics
folder = pathlib.Path(sys.argv[1]); tag = sys.argv[2]
rows = {}
for f in folder.glob(tag + '_*.out'):
    for line in f.read_text(encoding='utf-8', errors='replace').splitlines():
        m = re.match(r'SHOP (\S+) map=(\S+) order=\[(.*?)\] thr=(\d+)', line)
        if m: rows.setdefault(m[1], {})[(m[2], m[3])] = int(m[4])
def ratio(unit):
    base = rows['base0' if unit.startswith('alliance') else 'base1']
    vals = [rows[unit][k]/base[k] for k in rows[unit] if k in base and base[k] > 0]
    return statistics.mean(vals), min(vals), max(vals), len(vals)
print('unité'.ljust(26), 'moyenne', 'min', 'max', 'n')
out = []
for unit in sorted(u for u in rows if not u.startswith('base')):
    mean, lo, hi, n = ratio(unit)
    out.append((unit, mean, lo, hi, n))
    print(unit.ljust(26), '%.2f' % mean, '%.2f' % lo, '%.2f' % hi, n)
means = [o[1] for o in out]
print('ensemble : moyenne %.2f, écart-type %.2f, min %.2f, max %.2f' % (statistics.mean(means), statistics.pstdev(means), min(means), max(means)))
