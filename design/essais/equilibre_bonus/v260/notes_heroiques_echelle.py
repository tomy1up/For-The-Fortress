import pathlib, statistics as st, json, sys
SP = pathlib.Path(__file__).parent
lines = (SP / "heroic_values260.txt").read_text(encoding="utf-8").split("\n")
REF = {0: {0: 51, 36: 82, 53: 93}, 1: {0: 31, 36: 59, 53: 93}}
base_max = {}
rows = []
for line in lines:
    p = line.split()
    if len(p) < 8: continue
    mission, faction, seed, code, result, hp, mx = int(p[1]), int(p[2]), p[3], int(p[4]), p[5], int(p[6]), int(p[7])
    rows.append((mission, faction, seed, code, hp, mx))
    if code == -1: base_max[(mission, faction, seed)] = mx
score = {}
for mission, faction, seed, code, hp, mx in rows:
    denom = base_max.get((mission, faction, seed), mx)
    score.setdefault((faction, code), []).append(100.0 * hp / denom)
values = {}
for f in (0, 1):
    xs = [st.mean(score[(f, c)]) for c in (0, 36, 53)]
    ys = [REF[f][c] for c in (0, 36, 53)]
    mx_, my = st.mean(xs), st.mean(ys)
    slope = sum((x-mx_)*(y-my) for x, y in zip(xs, ys)) / sum((x-mx_)**2 for x in xs)
    inter = my - slope*mx_
    print("faction", f, "anchors ctx", [round(x, 1) for x in xs], "ref", ys, "slope %.2f inter %.1f" % (slope, inter), "baseline ctx %.1f" % st.mean(score[(f, -1)]))
    values[f] = []
    for code in range(60, 75):
        ctx = st.mean(score[(f, code)])
        v = max(0, min(100, round(inter + slope*ctx)))
        values[f].append(v)
        print("  %d ctx %.1f -> %d (n=%d)" % (code, ctx, v, len(score[(f, code)])))
(SP / "heroic_values_fit.json").write_text(json.dumps(values), encoding="utf-8")
