extends RefCounted
## Proposition de chapitre 2. Noms, statistiques et composition H.
const ID := "ford_banks"
const GUARD_TYPE := 8
const GUARD := {"name":"Tortue gardienne des berges","hp":180.0,"speed":0.8,"fortress_damage":2,"reward":8}
const RADIUS := 2.0
const SHARE := 0.25
const WAVES: Array = [
	[[1,10,2.5]],
	[[8,1,0.0],[1,8,2.0],[0,6,0.65]],
	[[1,8,1.8],[2,8,1.4]],
	[[8,2,3.0],[0,16,0.5]],
	[[4,6,2.0],[8,2,3.0],[2,8,1.2]],
	[[5,2,4.0],[8,2,2.2],[0,12,0.5]],
	[[6,1,0.0],[5,2,4.0],[4,8,1.6]],
	[[8,3,2.0],[0,20,0.35],[2,10,1.0],[4,6,1.2]],
	[[6,2,5.0],[5,2,4.0],[8,2,2.2],[4,6,1.4]],
	[[7,1,0.0],[6,2,5.0],[8,1,0.0],[2,6,1.0]]
]

static func valid_set(id: Variant) -> bool:
	return id is String and id in ["ford",ID,"marsh_drowned"]

static func guardian_for(enemy: Dictionary, guards: Array, positions: Dictionary, damage: Dictionary = {}) -> int:
	if enemy.get("type",1) in [GUARD_TYPE,7] or enemy.hp <= 0.0: return -1
	var chosen: int = -1
	var nearest: float = INF
	for guard in guards:
		if guard.get("type",1) != GUARD_TYPE or guard.hp <= damage.get(guard.id,0.0): continue
		var distance: float = positions[enemy.id].distance_squared_to(positions[guard.id])
		if distance <= RADIUS*RADIUS and (distance < nearest or (distance == nearest and guard.id < chosen)):
			chosen = guard.id;nearest = distance
	return chosen

static func redirect(enemies: Array, damage: Dictionary, hits: Array, positions: Dictionary) -> Dictionary:
	# Une seule attribution sur l’état précédant les dégâts. Ni auto-protection,
	# ni protection de gardienne ou boss ; aucun renvoi récursif.
	var guards: Array = []
	for enemy in enemies:
		if enemy.get("type",1) == GUARD_TYPE and enemy.hp > 0.0: guards.append(enemy)
	if guards.is_empty(): return {"damage":damage,"hits":hits,"transfers":[]}
	var claims: Dictionary = {}
	for enemy in enemies:
		if enemy.get("type",1) in [GUARD_TYPE,7] or enemy.hp <= 0.0 or damage.get(enemy.id,0.0) <= 0.0: continue
		var chosen: int = guardian_for(enemy,guards,positions,damage)
		if chosen >= 0: claims[enemy.id] = chosen
	var demand: Dictionary = {}
	for id in claims: demand[claims[id]] = demand.get(claims[id],0.0)+float(damage[id])*SHARE
	var scales: Dictionary = {}
	for guard in guards:
		if demand.get(guard.id,0.0) > 0.0:
			scales[guard.id] = minf(1.0,maxf(0.0,guard.hp-damage.get(guard.id,0.0))/demand[guard.id])
	var adjusted: Dictionary = damage.duplicate()
	var transfers: Array[Dictionary] = []
	for id in claims:
		var guardian: int = claims[id]
		var amount: float = damage[id]*SHARE*scales[guardian]
		adjusted[id] -= amount
		adjusted[guardian] = adjusted.get(guardian,0.0)+amount
		transfers.append({"protected_id":id,"guardian_id":guardian,"amount":amount})
	var attributed: Array[Dictionary] = []
	for hit in hits:
		if not claims.has(hit.enemy_id): attributed.append(hit);continue
		var guardian: int = claims[hit.enemy_id]
		var share: float = hit.amount*SHARE*scales[guardian]
		var kept: Dictionary = hit.duplicate();kept.amount -= share;attributed.append(kept)
		if share > 0.0:
			var absorbed: Dictionary = hit.duplicate();absorbed.enemy_id = guardian;absorbed.amount = share;attributed.append(absorbed)
	return {"damage":adjusted,"hits":attributed,"transfers":transfers}
