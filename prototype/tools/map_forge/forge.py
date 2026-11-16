"""Forge de cartes : gabarits de tracés, évaluation de la couverture et placement des six emplacements.
Plateau 18 x 10, forteresse à (17, 6). Les tracés sont rectilignes (axes) comme les cartes existantes."""
import math, random, itertools, json

W, H = 18, 10
EXIT = (17, 6)
RANGE = 4.0

# ---------- géométrie ----------
def seg_len(a, b): return math.dist(a, b)
def poly_len(pts): return sum(seg_len(pts[i], pts[i+1]) for i in range(len(pts)-1))

def point_seg_dist(p, a, b):
    ax, ay = a; bx, by = b; px, py = p
    dx, dy = bx-ax, by-ay
    l2 = dx*dx+dy*dy
    t = 0.0 if l2 == 0 else max(0.0, min(1.0, ((px-ax)*dx+(py-ay)*dy)/l2))
    return math.hypot(px-(ax+t*dx), py-(ay+t*dy))

def point_poly_dist(p, pts):
    return min(point_seg_dist(p, pts[i], pts[i+1]) for i in range(len(pts)-1))

def coverage_windows(center, radius, pts):
    out, cum = [], 0.0
    for i in range(len(pts)-1):
        a, b = pts[i], pts[i+1]
        vx, vy = b[0]-a[0], b[1]-a[1]
        length = math.hypot(vx, vy)
        dx, dy = vx/length, vy/length
        ox, oy = center[0]-a[0], center[1]-a[1]
        proj = ox*dx+oy*dy
        perp2 = max(0.0, ox*ox+oy*oy-proj*proj)
        disc = radius*radius-perp2
        if disc >= 0:
            half = math.sqrt(disc)
            first, last = max(0.0, proj-half), min(length, proj+half)
            if first <= last:
                w = (cum+first, cum+last)
                if out and w[0] <= out[-1][1]+1e-6: out[-1] = (out[-1][0], max(out[-1][1], w[1]))
                else: out.append(w)
        cum += length
    return out

def union_len(intervals):
    total, cur = 0.0, None
    for a, b in sorted(intervals):
        if cur is None or a > cur[1]:
            if cur: total += cur[1]-cur[0]
            cur = [a, b]
        else: cur[1] = max(cur[1], b)
    if cur: total += cur[1]-cur[0]
    return total

def metrics(routes, slots, radius=RANGE):
    cover, expo, firsthalf = [], [], []
    for pts in routes:
        L = poly_len(pts)
        wins = [w for s in slots for w in coverage_windows(s, radius, pts)]
        cover.append(union_len(wins)/L)
        expo.append(sum(b-a for a, b in wins)/L)
        half = [(max(a, 0), min(b, L/2)) for a, b in wins if a < L/2]
        firsthalf.append(union_len(half)/(L/2))
    n = len(routes)
    return {"cover": sum(cover)/n, "expo": sum(expo)/n, "first_half": sum(firsthalf)/n, "min_cover": min(cover), "length": sum(poly_len(p) for p in routes)/n}

# ---------- construction rectiligne ----------
def rect(waypoints):
    """Relie des points clés par des segments axiaux (x puis y alternés, selon l'ordre donné)."""
    pts = [waypoints[0]]
    for p in waypoints[1:]:
        q = pts[-1]
        if q[0] != p[0] and q[1] != p[1]:
            pts.append((p[0], q[1]))
        pts.append(p)
    # supprime points alignés redondants
    clean = [pts[0]]
    for i in range(1, len(pts)-1):
        a, b, c = clean[-1], pts[i], pts[i+1]
        if (a[0] == b[0] == c[0]) or (a[1] == b[1] == c[1]): continue
        clean.append(b)
    clean.append(pts[-1])
    return clean

def turns(pts): return max(0, len(pts)-2)

# ---------- gabarits ----------
def serpent_v(k, y0, y1, x0, x1):
    """Serpentin vertical entre x0 et x1 avec k colonnes."""
    xs = [x0+(x1-x0)*i/(k-1) for i in range(k)] if k > 1 else [x0]
    wp = []
    for i, x in enumerate(xs):
        top = i % 2 == 0
        wp += [(round(x), y0 if top else y1), (round(x), y1 if top else y0)]
    return wp

def templates(rng):
    """Retourne une liste de (nom, routes) tirée au hasard."""
    out = []
    # 1. serpentin vertical à un seul chemin, 3 à 5 colonnes
    k = rng.choice([3, 4, 5])
    xs = sorted(rng.sample(range(2, 15), k))
    wp = [(0, rng.choice([2, 5, 8]))]
    for i, x in enumerate(xs):
        up = i % 2 == 0
        wp += [(x, wp[-1][1]), (x, rng.choice([1, 2]) if up else rng.choice([8, 9]))]
    wp += [(17, wp[-1][1]), EXIT]
    out.append(("serpent_v", [rect(wp)]))
    # 2. serpentin horizontal : trois rangées
    ys = sorted(rng.sample(range(1, 10), 3))
    rows = [(0, ys[0]), (rng.randint(13, 16), ys[0]), (rng.randint(13, 16), ys[1]), (rng.randint(1, 4), ys[1]), (rng.randint(1, 4), ys[2]), (17, ys[2]), EXIT]
    out.append(("serpent_h", [rect(rows)]))
    # 3. spirale vers le centre puis sortie
    wp = [(0, 1), (16, 1), (16, 8), (2, 8), (2, 3), (13, 3), (13, 6), (5, 6), (5, 5), (14, 5), EXIT] if rng.random() < 0.5 else [(0, 8), (15, 8), (15, 1), (3, 1), (3, 6), (12, 6), (12, 3), (6, 3), (6, 4), (9, 4), (9, 5), (17, 5), EXIT]
    out.append(("spirale", [rect(wp)]))
    # 4. deux routes en Y : bras longs séparés puis tronc commun tardif
    mx = rng.choice([9, 10, 11, 12])
    my = rng.choice([4, 5, 6])
    up = [(0, rng.choice([1, 2])), (rng.randint(3, 6), 1), (rng.randint(3, 6), rng.choice([3, 4])), (mx, my)]
    lo = [(0, rng.choice([8, 9])), (rng.randint(3, 6), 9), (rng.randint(3, 6), rng.choice([6, 7])), (mx, my)]
    tail = [(rng.randint(mx+2, 15), my), (rng.randint(mx+2, 15), rng.choice([2, 3, 8, 9])), (17, rng.choice([2, 3, 8, 9])), EXIT]
    tail = [(t if i else (max(mx+2, t[0]), t[1])) for i, t in enumerate(tail)]
    r1, r2 = rect(up+tail), rect(lo+tail)
    out.append(("Y_tardif", [r1, r2]))
    # 5. deux routes qui se croisent au centre
    cx = rng.choice([7, 8, 9, 10])
    a = rect([(0, 1), (cx-3, 1), (cx-3, 5), (cx+1, 5), (cx+1, 8), (15, 8), EXIT])
    b = rect([(0, 9), (cx-2, 9), (cx-2, 4), (cx+2, 4), (cx+2, 2), (14, 2), (14, 6), EXIT])
    out.append(("croisement", [a, b]))
    # 6. trois routes : haut / milieu / bas qui rejoignent la forteresse à des abscisses différentes
    r1 = rect([(0, 1), (rng.randint(4, 7), 1), (rng.randint(4, 7), 3), (rng.randint(9, 12), 3), (rng.randint(9, 12), 1), (16, 1), (16, 5), EXIT])
    r2 = rect([(0, 5), (rng.randint(3, 6), 5), (rng.randint(3, 6), 7), (rng.randint(8, 11), 7), (rng.randint(8, 11), 5), (15, 5), (15, 6), EXIT])
    r3 = rect([(0, 9), (rng.randint(5, 8), 9), (rng.randint(5, 8), 8), (rng.randint(10, 13), 8), (rng.randint(10, 13), 9), (16, 9), (16, 7), EXIT])
    out.append(("trois_bras", [r1, r2, r3]))
    # 7. aller-retour : la route longe le haut, revient par le milieu, repart par le bas
    wp = [(0, 2), (rng.randint(13, 16), 2), (rng.randint(13, 16), 4), (rng.randint(2, 5), 4), (rng.randint(2, 5), 7), (rng.randint(14, 16), 7), (rng.randint(14, 16), 6), EXIT]
    out.append(("aller_retour", [rect(wp)]))
    # 8. peigne : dents hautes et basses
    xs = sorted(rng.sample(range(2, 15), 4))
    wp = [(0, 5)]
    for i, x in enumerate(xs):
        wp += [(x, 5), (x, 1 if i % 2 == 0 else 9), (x+1, 1 if i % 2 == 0 else 9), (x+1, 5)] if x+1 <= 15 else []
    wp += [(17, 5), EXIT]
    out.append(("peigne", [rect(wp)]))
    # 9. entrées haute et basse, tronc central en boucle
    loop = [(8, 5), (12, 5), (12, 2), (8, 2), (8, 5)] if rng.random() < 0.0 else None
    r1 = rect([(0, 1), (5, 1), (5, 4), (11, 4), (11, 7), (15, 7), (15, 6), EXIT])
    r2 = rect([(rng.randint(3, 7), 0), (rng.randint(3, 7), 3), (rng.randint(9, 13), 3), (rng.randint(9, 13), 8), (rng.randint(14, 16), 8), (rng.randint(14, 16), 6), EXIT])
    out.append(("haut_et_gauche", [r1, r2]))
    # 10. trois entrées qui fusionnent puis un long tronc commun en serpentin
    mx = rng.choice([6, 7, 8]); my = rng.choice([4, 5, 6])
    top = [(0, rng.choice([1, 2])), (rng.randint(2, 4), 1), (rng.randint(2, 4), rng.choice([2, 3])), (mx, rng.choice([2, 3])), (mx, my)]
    mid = [(0, my), (mx, my)]
    low = [(0, rng.choice([8, 9])), (rng.randint(2, 4), 9), (rng.randint(2, 4), rng.choice([7, 8])), (mx, rng.choice([7, 8])), (mx, my)]
    t1 = rng.randint(mx+3, mx+4); t2 = rng.randint(min(t1+2, 15), 15)
    tail = [(t1, my), (t1, rng.choice([1, 2, 3])), (t2, rng.choice([1, 2, 3])), (t2, rng.choice([8, 9])), (16, rng.choice([8, 9])), (16, 6), EXIT]
    tail = rect([(mx, my)] + tail)[1:]
    out.append(("fusion3", [rect(top)+tail, rect(mid)+tail, rect(low)+tail]))
    # 11. deux routes qui se croisent puis fusionnent dans un tronc commun
    x1 = rng.randint(3, 6); mx = rng.randint(x1+4, 10); my = 5
    A = rect([(0, rng.choice([1, 2])), (x1, rng.choice([1, 2])), (x1, rng.choice([8, 9])), (mx, rng.choice([8, 9])), (mx, my)])
    B = rect([(0, my), (mx, my)])
    t1 = rng.randint(mx+2, mx+4); t2 = rng.randint(min(t1+2, 15), 15)
    tail = rect([(mx, my), (t1, my), (t1, rng.choice([1, 2, 3])), (t2, rng.choice([1, 2, 3])), (t2, rng.choice([7, 8, 9])), (16, rng.choice([7, 8, 9])), (16, 6), EXIT])[1:]
    out.append(("croisement_fusion", [A+tail, B+tail]))
    # 12. deux entrées (haut, bas) qui fusionnent puis un tronc en serpentin
    mx = rng.choice([6, 7, 8, 9]); my = rng.choice([4, 5, 6])
    top = [(0, rng.choice([1, 2])), (rng.randint(2, 5), 1), (rng.randint(2, 5), rng.choice([2, 3])), (mx, rng.choice([2, 3])), (mx, my)]
    low = [(0, rng.choice([8, 9])), (rng.randint(2, 5), 9), (rng.randint(2, 5), rng.choice([7, 8])), (mx, rng.choice([7, 8])), (mx, my)]
    t1 = rng.randint(mx+3, mx+4); t2 = rng.randint(min(t1+2, 15), 15)
    tail = rect([(mx, my), (t1, my), (t1, rng.choice([1, 2, 3])), (t2, rng.choice([1, 2, 3])), (t2, rng.choice([8, 9])), (16, rng.choice([8, 9])), (16, 6), EXIT])[1:]
    out.append(("fusion2", [rect(top)+tail, rect(low)+tail]))
    return out

# ---------- validation ----------
def seg_cross_or_touch(a, b, c, d, margin=0.9):
    """Distance minimale entre deux segments axiaux ; retourne vrai s'ils se touchent ou s'approchent à moins de `margin` sans se croiser perpendiculairement."""
    # croisement perpendiculaire strict : accepté
    def horiz(p, q): return p[1] == q[1]
    if horiz(a, b) != horiz(c, d):
        h = (a, b) if horiz(a, b) else (c, d)
        v = (c, d) if horiz(a, b) else (a, b)
        if min(h[0][0], h[1][0]) < v[0][0] < max(h[0][0], h[1][0]) and min(v[0][1], v[1][1]) < h[0][1] < max(v[0][1], v[1][1]): return False
    dist = min(point_seg_dist(a, c, d), point_seg_dist(b, c, d), point_seg_dist(c, a, b), point_seg_dist(d, a, b))
    return dist < margin

def valid_routes(routes, tail_shared=False):
    for pts in routes:
        for p in pts:
            if not (0 <= p[0] <= W and 0 <= p[1] <= H): return False
        if pts[0][0] != 0 and pts[0][1] not in (0, H): return False
        if pts[-1] != EXIT: return False
        for i in range(len(pts)-1):
            if seg_len(pts[i], pts[i+1]) < 1.0: return False
        # segments non adjacents d'une même route
        for i in range(len(pts)-1):
            for j in range(i+2, len(pts)-1):
                if seg_cross_or_touch(pts[i], pts[i+1], pts[j], pts[j+1]): return False
    # routes entre elles : on ignore la queue partagée (points communs)
    for r1, r2 in itertools.combinations(routes, 2):
        shared = 0
        while shared < min(len(r1), len(r2)) and r1[-1-shared] == r2[-1-shared]: shared += 1
        a_pts = r1[: len(r1)-shared+1] if shared else r1
        b_pts = r2[: len(r2)-shared+1] if shared else r2
        for i in range(len(a_pts)-1):
            for j in range(len(b_pts)-1):
                if i == len(a_pts)-2 and j == len(b_pts)-2 and shared: continue
                if seg_cross_or_touch(a_pts[i], a_pts[i+1], b_pts[j], b_pts[j+1], 0.9): return False
    return True

def crossings(routes):
    count = 0
    segs = [(r, i) for r in routes for i in range(len(r)-1)]
    for (ra, i), (rb, j) in itertools.combinations(segs, 2):
        if ra is rb and abs(i-j) < 2: continue
        a, b, c, d = ra[i], ra[i+1], rb[j], rb[j+1]
        if (a[1] == b[1]) != (c[1] == d[1]):
            h = (a, b) if a[1] == b[1] else (c, d)
            v = (c, d) if a[1] == b[1] else (a, b)
            if min(h[0][0], h[1][0]) < v[0][0] < max(h[0][0], h[1][0]) and min(v[0][1], v[1][1]) < h[0][1] < max(v[0][1], v[1][1]): count += 1
    return count

# ---------- placement des emplacements ----------
def candidate_points(routes):
    cands = []
    for xi in range(2, 35):
        for yi in range(2, 19):
            p = (xi/2.0, yi/2.0)
            if not (0.8 <= p[0] <= 17.2 and 0.8 <= p[1] <= 9.2): continue
            d = min(point_poly_dist(p, r) for r in routes)
            if 1.1 <= d <= 2.3: cands.append(p)
    return cands

def place_slots(routes, rng, target_expo=2.1, iterations=600):
    cands = candidate_points(routes)
    if len(cands) < 6: return None
    def score(slots):
        m = metrics(routes, slots)
        penalty = abs(m["expo"]-target_expo)*1.5
        useful = 0.0
        for s in slots:
            length = sum(b-a for r in routes for a, b in coverage_windows(s, RANGE, r))
            useful += min(1.0, length/9.0)
        return m["cover"]*2.0 + m["first_half"]*1.0 + m["min_cover"] + useful*0.25 - penalty
    def spread_ok(slots):
        return all(math.dist(a, b) >= 1.8 for a, b in itertools.combinations(slots, 2))
    best, best_score = None, -1e9
    for restart in range(6):
        cur = []
        pool = cands[:]
        rng.shuffle(pool)
        for p in pool:
            if all(math.dist(p, q) >= 1.8 for q in cur): cur.append(p)
            if len(cur) == 6: break
        if len(cur) < 6: continue
        cs = score(cur)
        for it in range(iterations):
            i = rng.randrange(6)
            p = rng.choice(cands)
            new = cur[:i]+[p]+cur[i+1:]
            if not spread_ok(new): continue
            s = score(new)
            if s > cs: cur, cs = new, s
        if cs > best_score: best, best_score = cur, cs
    return best

def gd_board(route_ids, routes, slots, map_id):
    """Ligne GDScript _board(...)."""
    def v(p): return "Vector2(%s,%s)" % (fmt(p[0]), fmt(p[1]))
    def fmt(x):
        return str(int(x)) if float(x).is_integer() else ("%.1f" % x)
    route_txt = ",".join('["%s",[%s]]' % (rid, ",".join(v(p) for p in r)) for rid, r in zip(route_ids, routes))
    return '\t\t"%s": return _board(id,[%s],[%s],false)' % (map_id, route_txt, ",".join(v(s) for s in slots))

if __name__ == "__main__":
    rng = random.Random(7)
    for name, routes in templates(rng):
        ok = valid_routes(routes)
        print(name, "valide" if ok else "invalide", [turns(r) for r in routes], [round(poly_len(r)) for r in routes], "croisements", crossings(routes))


# ---------- calibrage par exposition absolue des trois meilleurs emplacements ----------
def top3_abs(routes, slots):
    """Temps passé (en longueur de trajet) dans la portée des trois emplacements les plus utiles, minimum sur les routes."""
    ranked = sorted(slots, key=lambda s: -sum(b-a for r in routes for a, b in coverage_windows(s, RANGE, r)))[:3]
    per = []
    for r in routes:
        per.append(sum(b-a for s in ranked for a, b in coverage_windows(s, RANGE, r)))
    return min(per), ranked

def place_slots_target(routes, rng, target, iterations=500, restarts=4):
    cands = candidate_points(routes)
    if len(cands) < 6: return None
    def spread_ok(slots): return all(math.dist(a, b) >= 1.8 for a, b in itertools.combinations(slots, 2))
    def score(slots):
        m = metrics(routes, slots)
        a, _ = top3_abs(routes, slots)
        useful = sum(min(1.0, sum(b-a2 for r in routes for a2, b in coverage_windows(s, RANGE, r))/9.0) for s in slots)
        return m["cover"]*2.0 + m["first_half"] + m["min_cover"] + useful*0.2 - abs(a-target)*0.12
    best, best_score = None, -1e9
    for _ in range(restarts):
        cur = []
        pool = cands[:]; rng.shuffle(pool)
        for p in pool:
            if all(math.dist(p, q) >= 1.8 for q in cur): cur.append(p)
            if len(cur) == 6: break
        if len(cur) < 6: continue
        cs = score(cur)
        for _ in range(iterations):
            i = rng.randrange(6); p = rng.choice(cands)
            new = cur[:i]+[p]+cur[i+1:]
            if not spread_ok(new): continue
            s = score(new)
            if s > cs: cur, cs = new, s
        if cs > best_score: best, best_score = cur, cs
    return best

def order_slots(routes, slots):
    """Indices 3, 4, 2 = les trois emplacements les plus utiles (convention des tests de chapitre)."""
    ranked = sorted(slots, key=lambda s: -sum(b-a for r in routes for a, b in coverage_windows(s, RANGE, r)))
    out = [None]*6
    out[3], out[4], out[2] = ranked[0], ranked[1], ranked[2]
    out[0], out[1], out[5] = ranked[3], ranked[4], ranked[5]
    return out
