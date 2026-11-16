import random, sys, json, math
from PIL import Image, ImageDraw
import forge as F

SC = 36
COLORS = [(230, 170, 60), (90, 200, 220), (200, 110, 230), (140, 220, 110)]

def draw(map_name, routes, slots, m):
    img = Image.new("RGB", (F.W*SC+20, F.H*SC+60), (16, 28, 24))
    d = ImageDraw.Draw(img)
    ox, oy = 10, 40
    for x in range(F.W+1): d.line([(ox+x*SC, oy), (ox+x*SC, oy+F.H*SC)], fill=(30, 48, 40))
    for y in range(F.H+1): d.line([(ox, oy+y*SC), (ox+F.W*SC, oy+y*SC)], fill=(30, 48, 40))
    for s in slots:
        r = F.RANGE*SC
        d.ellipse([ox+s[0]*SC-r, oy+s[1]*SC-r, ox+s[0]*SC+r, oy+s[1]*SC+r], outline=(60, 90, 70))
    for i, pts in enumerate(routes):
        c = COLORS[i % len(COLORS)]
        d.line([(ox+p[0]*SC, oy+p[1]*SC) for p in pts], fill=c, width=5)
        d.ellipse([ox+pts[0][0]*SC-6, oy+pts[0][1]*SC-6, ox+pts[0][0]*SC+6, oy+pts[0][1]*SC+6], fill=c)
    for k, s in enumerate(slots):
        d.rectangle([ox+s[0]*SC-9, oy+s[1]*SC-9, ox+s[0]*SC+9, oy+s[1]*SC+9], fill=(40, 120, 90), outline=(220, 240, 220))
        d.text((ox+s[0]*SC-3, oy+s[1]*SC-6), str(k+1), fill=(255, 255, 255))
    d.ellipse([ox+F.EXIT[0]*SC-9, oy+F.EXIT[1]*SC-9, ox+F.EXIT[0]*SC+9, oy+F.EXIT[1]*SC+9], fill=(200, 60, 50))
    d.text((12, 4), "%s · routes %d · virages %s · couverture %.0f%% · 1re moitié %.0f%% · expo %.2f" % (map_name, len(routes), [F.turns(r) for r in routes], m["cover"]*100, m["first_half"]*100, m["expo"]), fill=(240, 235, 210))
    d.text((12, 20), "longueurs %s" % [round(F.poly_len(r)) for r in routes], fill=(180, 200, 190))
    return img

def candidates(seed_start, count, allowed=None):
    out = []
    for seed in range(seed_start, seed_start+count):
        rng = random.Random(seed)
        for name, routes in F.templates(rng):
            if allowed and name not in allowed: continue
            if not F.valid_routes(routes): continue
            cr = F.crossings(routes)
            if name != "croisement" and cr > 0: continue
            if cr > 2: continue
            slots = F.place_slots(routes, random.Random(seed*7+1), iterations=140)
            if not slots: continue
            m = F.metrics(routes, slots)
            out.append({"name": name, "seed": seed, "routes": routes, "slots": slots, "m": m, "cr": cr})
    return out

if __name__ == "__main__":
    cands = candidates(1, 60)
    print(len(cands), "candidats")
    good = [c for c in cands if c["m"]["cover"] >= 0.84 and c["m"]["first_half"] >= 0.55 and 1.8 <= c["m"]["expo"] <= 2.6]
    print(len(good), "retenus")
    from collections import Counter
    print(Counter(c["name"] for c in good))
    json.dump([{k: v for k, v in c.items()} for c in good], open("cands.json", "w"))
    sheet = Image.new("RGB", (2*(F.W*SC+20), 3*(F.H*SC+60)))
    shown = []
    seen = set()
    for c in sorted(good, key=lambda c: -c["m"]["cover"]):
        if c["name"] in seen: continue
        seen.add(c["name"]);shown.append(c)
    for i, c in enumerate(shown[:6]):
        im = draw(c["name"], c["routes"], c["slots"], c["m"])
        sheet.paste(im, ((i % 2)*(F.W*SC+20), (i//2)*(F.H*SC+60)))
    sheet.save("forge_sheet.png")
    print([ (c["name"], round(c["m"]["cover"],2), round(c["m"]["first_half"],2), round(c["m"]["expo"],2)) for c in shown])
