extends SceneTree
## Offres utiles (v0.253, décision du porteur du 24 novembre 2026) : un bonus dont l'effet dépend des défenseurs n'est proposé que si un défenseur déployé en profite.
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
## Bonus conditionnels jugés sur les caractéristiques de combat d'un défenseur seul.
const STAT_CODES: Array[int] = [1,3,4,12,13,14,15,16,17,18,37,47,57]
const KEYS: Array[String] = ["damage","secondary_damage","curse_damage","range","interval","secondary_cap","radius","mark_bonus","loot_bonus","volatile_damage","slow_seconds"]
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	verify_matches_combat()
	verify_levels_and_placement()
	verify_offers()
	verify_versions()
	print("USEFUL_OFFERS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

func lone(type: int, level: int = 1, branch: int = -1):
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.select_faction(0 if Model.family(type) < 3 else 1)
	m.defenders[3] = {"type":type,"level":level,"branch":branch,"invested":0,"instance_id":1}
	return m

func changed(m, slot: int, code: int) -> bool:
	var plain: Dictionary = m._stats_with_bonuses(slot,-1,{},[])
	var boosted: Dictionary = m._stats_with_bonuses(slot,-1,{},[code])
	for key in KEYS:
		if key == "radius" and int(plain.get("secondary_cap",0)) == 0: continue # sans cible secondaire, le rayon n'a aucun effet
		if plain.has(key) != boosted.has(key): return true
		if plain.has(key) and not is_equal_approx(float(plain[key]),float(boosted[key])): return true
	return false

## Pour chaque unité (niveaux 1 et 3, chaque spécialisation), le filtre suit l'effet réel du bonus en combat.
func verify_matches_combat() -> void:
	var useless_somewhere: Dictionary = {}
	for type in range(Model.ROSTER.size()):
		for variant in [[1,-1],[3,-1],[4,0],[4,1]]:
			var m = lone(type,variant[0],variant[1])
			for code in STAT_CODES:
				var real: bool = changed(m,3,code)
				if code == 18 and Model.ROSTER[type].has("aura_bonus"): real = true # l'aura renforcée profite aux voisins
				check(m.bonus_useful(code) == real,"Unité %d, niveau %d, branche %d : bonus %d utile = %s comme en combat" % [type,variant[0],variant[1],code,str(real)])
				if not real: useless_somewhere[code] = true
			var curse: bool = float(Model.ROSTER[type].get("curse_damage",0.0)) > 0.0
			check(m.bonus_useful(38) == curse,"Unité %d : Malédiction tenace utile seulement avec des dégâts sur la durée" % type)
			for code in [0,2,5,6,7,8,9,10,11,19,20,21,22,23,24,27,28,29,30,31,32,33,34,35,36,39,40,41,42,44,45,46,48,49,50,51,52,53,55,56,58,59]:
				check(m.bonus_useful(code),"Unité %d : bonus général %d toujours proposé" % [type,code])
	for code in STAT_CODES: check(useless_somewhere.has(code),"Bonus %d : inutile pour au moins une unité, donc filtrable" % code)

func verify_levels_and_placement() -> void:
	var m = lone(0)
	check(m.bonus_useful(43) and m.bonus_useful(54),"Niveau 1 : Promotion et Ascension utiles")
	m.defenders[3].level = 2
	check(not m.bonus_useful(43) and m.bonus_useful(54),"Niveau 2 : Ascension seulement")
	m.defenders[3].level = 3
	check(not m.bonus_useful(43) and not m.bonus_useful(54) and m.bonus_useful(7) and m.bonus_useful(6) and m.bonus_useful(24),"Niveau 3 : ni Promotion ni Ascension ; les bonus de niveau restent proposés")
	var single = lone(0)
	check(not single.bonus_useful(25) and single.bonus_useful(26),"Défenseur seul : Francs-tireurs, pas Formation serrée")
	var pair = lone(0)
	var near: int = -1
	var far: int = -1
	for slot in range(pair.slots.size()):
		if slot == 3: continue
		var distance: float = pair.slots[3].distance_to(pair.slots[slot])
		if distance <= 3.0 and near < 0: near = slot
		if distance > 4.2 and far < 0: far = slot
	if near >= 0:
		pair.defenders[near] = {"type":0,"level":1,"branch":-1,"invested":0,"instance_id":2}
		check(pair.bonus_useful(25) and not pair.bonus_useful(26),"Deux défenseurs voisins : Formation serrée, pas Francs-tireurs")
	var empty = Model.new(true,Model.Maps.for_id("valley_ford"))
	for code in range(Model.Campaign.BONUSES.size()): check(empty.bonus_useful(code),"Sans défenseur, le bonus %d reste proposable" % code)

## Une armée d'archer et d'arbalétriers ne reçoit jamais d'offre sans effet, y compris après la relance.
func verify_offers() -> void:
	var useless: Array[int] = []
	var probe = army()
	for code in range(Model.Campaign.BONUSES.size()):
		if not probe.bonus_useful(code): useless.append(code)
	check(useless.has(14) and useless.has(15) and useless.has(18) and useless.has(37) and useless.has(57),"L'arc et l'arbalète ne profitent ni des cibles secondaires, ni des dégâts sur la durée, ni des soutiens")
	var offered: int = 0
	for seed in range(60):
		var m = army()
		m.rng.seed = seed
		for wave in [2,4,6,8]:
			m.wave = wave
			m._offer_bonus()
			for code in m.bonus_offer: check(not code in useless,"Tirage %d, vague %d : bonus %d sans effet jamais proposé" % [seed,wave,code])
			check(m.bonus_offer.size() == 3 and m.bonus_offer.duplicate().all(func(code: int) -> bool: return m.bonus_offer.count(code) == 1),"Trois offres distinctes")
			if wave == 4 and m.reroll_bonus():
				for code in m.bonus_offer: check(not code in useless,"Relance : bonus %d sans effet jamais proposé" % code)
			offered += 1
			m.choose_bonus(m.bonus_offer[0])
			m.phase = "preparation"
	check(offered == 240,"240 offres contrôlées")
	var legacy_seen: bool = false
	for seed in range(60):
		var m = army()
		m.rules_v253 = false
		m.rng.seed = seed
		m.wave = 2
		m._offer_bonus()
		for code in m.bonus_offer:
			if code in useless: legacy_seen = true
	check(legacy_seen,"Règles d'avant la v0.253 : les offres sans effet restent possibles (rejeu des anciens rapports)")
	# Continuité : une carte utile reste à sa place, une carte inutile est remplacée sans tirage supplémentaire.
	var replaced: int = 0
	for seed in range(60):
		var old = army();old.rules_v253 = false;old.rng.seed = seed;old.wave = 2;old._offer_bonus()
		var now = army();now.rng.seed = seed;now.wave = 2;now._offer_bonus()
		check(old.rng.state == now.rng.state,"Tirage %d : même état aléatoire après l'offre" % seed)
		for index in range(3):
			if probe.bonus_useful(old.bonus_offer[index]) and old.bonus_offer[index] in now.bonus_offer.slice(0,index):
				check(probe.bonus_useful(now.bonus_offer[index]) and not now.bonus_offer[index] in now.bonus_offer.slice(0,index),"Tirage %d : carte %d déjà prise par un remplacement, remplacée à son tour" % [seed,index])
			elif probe.bonus_useful(old.bonus_offer[index]): check(now.bonus_offer[index] == old.bonus_offer[index],"Tirage %d : carte utile %d inchangée" % [seed,index])
			else:
				replaced += 1
				check(probe.bonus_useful(now.bonus_offer[index]) and Model.Campaign.bonus_rarity(now.bonus_offer[index]) == Model.Campaign.bonus_rarity(old.bonus_offer[index]),"Tirage %d : carte inutile %d remplacée par un bonus utile de même rareté" % [seed,index])
	check(replaced > 0,"Des cartes inutiles ont bien été remplacées (%d)" % replaced)

func army():
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.select_faction(0)
	for slot in [[3,0],[4,1],[2,1]]: m.defenders[slot[0]] = {"type":slot[1],"level":1,"branch":-1,"invested":0,"instance_id":slot[0]+1}
	return m

func verify_versions() -> void:
	check(not Replay.rules_v253_for("0.252") and Replay.rules_v253_for("0.253") and Replay.rules_v253_for("0.300"),"Offres utiles à partir de la v0.253 seulement")
	check(Model.new().rules_v253,"Les nouvelles parties appliquent les offres utiles")
