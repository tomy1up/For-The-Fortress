"""Échelle des renforts essayés en v0.252 (commune aux grilles et à la garde).
S(k) : k sprinters (type 2) aux vagues 3, 5 et 7 ; M(k) : k maraudeurs (type 4) aux vagues 4, 6 et 8 ; B(k) : k brutes (type 3) aux vagues 4, 6 et 8 ; E(k) : k élites (type 6) aux vagues 5, 7 et 9."""
def S(k): return ["%d:2:%d:0.6" % (w, k) for w in (3, 5, 7)]
def M(k): return ["%d:4:%d:1.5" % (w, k) for w in (4, 6, 8)]
def B(k): return ["%d:3:%d:2.0" % (w, k) for w in (4, 6, 8)]
def E(k): return ["%d:6:%d:3.0" % (w, k) for w in (5, 7, 9)]
LADDER = {"S1": S(1), "S2": S(2), "S3": S(3), "S4": S(4), "S5": S(5), "S6": S(6), "S7": S(7), "S8": S(8), "S10": S(10),
          "S8M1": S(8)+M(1), "S8M2": S(8)+M(2), "S12M3": S(12)+M(3), "S12M5": S(12)+M(5), "S16M6": S(16)+M(6),
          "B2": B(2), "B4": B(4), "B6": B(6), "E1": E(1), "E2": E(2), "S8B3": S(8)+B(3), "S12B4": S(12)+B(4),
          "SL8": ["%d:2:8:0.6" % w for w in (5, 7, 9)], "SL12": ["%d:2:12:0.6" % w for w in (5, 7, 9)],
          "SL8ML2": ["%d:2:8:0.6" % w for w in (5, 7, 9)] + ["%d:4:2:1.5" % w for w in (6, 8)], "SL12ML3": ["%d:2:12:0.6" % w for w in (5, 7, 9)] + ["%d:4:3:1.5" % w for w in (6, 8)],
          "EL1": ["%d:6:1:3.0" % w for w in (7, 9)], "EL2": ["%d:6:2:3.0" % w for w in (7, 9)], "EL3": ["%d:6:3:3.0" % w for w in (7, 9)],
          "M1": M(1), "M2": M(2), "S9": S(9), "S6M1": S(6)+M(1), "S1M1": S(1)+M(1), "S10M1": S(10)+M(1)}
