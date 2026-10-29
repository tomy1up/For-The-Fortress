extends RefCounted
## Courbe de prototype : 51 points à 10 000 XP, soit 100 missions à 100 XP.
## Les montants restent des hypothèses ; aucune règle de répétition n’est déduite ici.
const MAX_POINTS: int = 51
const TARGET_MISSIONS: int = 100
const XP_PER_MISSION: int = 100
const TARGET_XP: int = TARGET_MISSIONS*XP_PER_MISSION

static func points_for_xp(xp: int) -> int:
	return mini(MAX_POINTS,maxi(0,xp)*MAX_POINTS/TARGET_XP)

static func xp_for_points(points: int) -> int:
	if points <= 0: return 0
	if points > MAX_POINTS: return -1
	return (TARGET_XP*points+MAX_POINTS-1)/MAX_POINTS

static func progress(xp: int) -> Dictionary:
	var points: int = points_for_xp(xp)
	var at_cap: bool = points == MAX_POINTS
	var next_xp: int = 0 if at_cap else xp_for_points(points+1)
	return {"xp":maxi(0,xp),"points":points,"at_cap":at_cap,"next_xp":next_xp,"remaining":0 if at_cap else next_xp-maxi(0,xp)}
