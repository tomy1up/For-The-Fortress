import sys, collections, statistics as st, pathlib
def load(paths):
    best = {}
    wins = collections.Counter(); total = collections.Counter()
    for s, p in paths:
        for l in open(p, encoding="utf-8"):
            f = l.split()
            if len(f) < 8 or f[0] != "STUDY": continue
            m, fac = int(f[1]), int(f[2]); res = f[5]; left, mx = float(f[6]), float(f[7])
            v = left/mx if res == "victory" and mx > 0 else 0.0
            k = (m, fac, s); best[k] = max(best.get(k, 0.0), v)
            total[(m, fac)] += 1; wins[(m, fac)] += res == "victory"
    return best, wins, total
D = "C:/Projet/For the Fortress!/design/essais/equilibre_bonus/"
old, _, _ = load([(s, D+f"parties_v236_{s}.txt") for s in (7,8,9)])
label = sys.argv[1] if len(sys.argv) > 1 else "actuel"
new, w, t = load([(s, f"v244/{label}_{s}.txt") for s in (7,8,9)])
ms = sorted({k[0] for k in new})
print("chapitre faction  avant  après  dans_cible  <40  >70  perdues(tous tirages)")
for ch in (3,7,11,13,17):
    for fac in (0,1):
        sel = [m for m in ms if (m-1)//10+1 == ch]
        a = [st.mean(old[(m,fac,s)] for s in (7,8,9)) for m in sel]
        b = [st.mean(new[(m,fac,s)] for s in (7,8,9)) for m in sel]
        lost = sum(all(new[(m,fac,s)] == 0 for s in (7,8,9)) for m in sel)
        print(f"{ch:>8} {'AH'[fac]:>7} {st.mean(a)*100:6.1f} {st.mean(b)*100:6.1f} {sum(.4<=x<=.7 for x in b):>10} {sum(x<.4 for x in b):>4} {sum(x>.7 for x in b):>4} {lost:>5}")
