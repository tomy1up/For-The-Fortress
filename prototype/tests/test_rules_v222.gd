extends SceneTree
## Règles de la v0.222 (décisions du porteur, 16 novembre 2026, suite à l'audit des unités) :
## 1. les talents de l'arbre du Mage s'appliquent aussi aux dégâts sur la durée (dots) du Pyromancien humain ;
## 2. le bonus « Exercice de tir » profite aux alternatives de boutique du chaman (Brûleur de cendres, Chaman des marais) ;
## 3. l'aura du Prêtre guerrier et de l'Ancien des tribus porte à 4,2 cases : au moins un voisin sur chacune des cartes de la campagne.
## Les rapports d'avant la v0.222 se rejouent avec les anciennes règles.
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func pyro_stats(ranks: Array, rules: bool) -> Dictionary:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.rules_v222 = rules
	m.configure_auxiliary(15);m.select_faction(0);m.gold = 5000
	if not ranks.is_empty(): m.meta_ranks = ranks
	m.buy(3,15)
	return m.get_stats(3)

func run_checks() -> void:
	# 1. Dots du Pyromancien et talents du Mage.
	var ranks: Array = Talents.empty_ranks()
	var chosen: int = -1
	for local in range(5):
		var index: int = Talents.index_for(2,local)
		var candidate: Array = Talents.empty_ranks()
		candidate[index] = 1
		if Talents.valid(candidate) and Model.MetaTalents.effects(0,candidate,2).secondary > 0.0:
			ranks = candidate;chosen = index;break
	check(chosen >= 0,"Un talent d'explosion du Mage est utilisable pour l'essai")
	var plain: Dictionary = pyro_stats([],true)
	var boosted: Dictionary = pyro_stats(ranks,true)
	var legacy: Dictionary = pyro_stats(ranks,false)
	check(boosted.curse_damage > plain.curse_damage,"Un talent du Mage augmente la brûlure du Pyromancien (%.2f contre %.2f)" % [boosted.curse_damage,plain.curse_damage])
	check(is_equal_approx(legacy.curse_damage,plain.curse_damage),"Anciennes règles : la brûlure ne progresse pas avec les talents")
	check(is_equal_approx(boosted.curse_damage/plain.curse_damage,1.0+Model.MetaTalents.effects(0,ranks,2).secondary),"Même progression que les explosions du Mage")
	# 2. Exercice de tir (R-02) et alternatives du chaman.
	for type in [21,33,5]:
		var m = Model.new(true,Model.Maps.for_id("valley_ford"))
		m.configure_auxiliary(type if type >= 6 else -1);m.select_faction(1);m.gold = 5000
		m.buy(3,type)
		var before: float = m.get_stats(3).interval
		m.bonuses.assign([1])
		var after: float = m.get_stats(3).interval
		check(is_equal_approx(before/after,1.12 if type >= 6 else 1.0),"R-02 : cadence %s (type %d)" % ["+12 %" if type >= 6 else "inchangée pour le chaman orc de base",type])
		m.rules_v222 = false
		check(is_equal_approx(m.get_stats(3).interval,before),"R-02, anciennes règles : le chaman et ses alternatives sont exclus (type %d)" % type)
	for bonus in Model.Campaign.BONUSES:
		if bonus.code == "R-02": check(str(bonus.description).contains("alternatives de boutique") and str(bonus.faction_descriptions[1]).contains("Brûleur de cendres") and str(bonus.faction_descriptions[1]).contains("Chaman des marais"),"Le texte du bonus R-02 cite les unités incluses")
	# 3. Aura : 4,2 cases, un voisin sur chaque carte de la campagne.
	var seen: Dictionary = {}
	var uncovered: Array = []
	for number in range(1,201):
		var id: String = Catalogue.definition(number).map_id
		if seen.has(id): continue
		seen[id] = true
		var m = Model.new(true,Model.Maps.for_id(id))
		var closest: float = INF
		for a in range(m.slots.size()):
			for b in range(a+1,m.slots.size()): closest = minf(closest,m.slots[a].distance_to(m.slots[b]))
		if closest > Model.AURA_RADIUS: uncovered.append(id)
	check(uncovered.is_empty(),"Chaque carte a deux emplacements à portée de l'aura (%d cartes, hors portée : %s)" % [seen.size(),str(uncovered)])
	check(is_equal_approx(float(Model.ROSTER[32].aura_radius),Model.AURA_RADIUS) and is_equal_approx(float(Model.ROSTER[35].aura_radius),Model.AURA_RADIUS),"Prêtre guerrier et Ancien des tribus : rayon de 4,2")
	var ford = Model.new(true,Model.Maps.for_id("valley_ford"))
	ford.configure_auxiliary(32);ford.select_faction(0);ford.gold = 5000
	ford.buy(1,32);ford.buy(2,0) # emplacements 1 et 2 : 4,12 cases
	check(is_equal_approx(ford.guardian_aura(2),0.4),"Sur la Vallée du Gué, l'aura atteint désormais le voisin à 4,12 cases")
	ford.rules_v222 = false
	check(is_equal_approx(ford.guardian_aura(2),0.0),"Anciennes règles : portée de 3,6, aucun voisin")
	# Rejeu : seuil de version.
	check(not Replay.rules_v222_for("0.221") and Replay.rules_v222_for("0.222") and Replay.rules_v222_for("0.300") and Replay.rules_v222_for("inconnu"),"Seuil de version des règles v0.222")
	# Rejeu d'une partie avec aura et dots : ancien rapport (0.221) rejoué avec les anciennes règles, rapport actuel avec les nouvelles.
	for active in [false,true]:
		var m = Model.new(true,Model.Maps.for_id("ford_woods"))
		m.rules_v232 = false # Le rapport porte une version antérieure à la 0.232 : tirage de douze bonus.
		m.rules_v222 = active
		m.configure_auxiliary(32);m.select_faction(0);m.rng.seed = 9
		m.buy(0,32);m.buy(1,0)
		for wave in range(1,11):
			if not m.start(): break
			while m.active: m.advance(1.0)
			if m.phase == "defeat": break
			if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
			if wave < 10 and not m.prepare_next_wave(): break
		check(m.phase in ["victory","defeat"],"La partie de rejeu se termine (%s)" % m.phase)
		if m.phase in ["victory","defeat"]:
			var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
			report.game_version = "0.222" if active else "0.221"
			var verified: Dictionary = Replay.verify(report)
			check(verified.ok,"Rapport %s rejoué exactement (%s)" % ["actuel" if active else "de la v0.221",verified.get("error","")])
	print("RULES_V222_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
