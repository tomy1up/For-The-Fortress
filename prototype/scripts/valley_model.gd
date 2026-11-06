extends RefCounted

const Campaign = preload("res://scripts/campaign_data.gd")
const Metrics = preload("res://scripts/combat_metrics.gd")
const Progression = preload("res://scripts/progression_data.gd")
const Enemies = preload("res://scripts/enemy_catalogue.gd")
const MetaTalents = preload("res://scripts/meta_talents.gd")
## Distances dans le plan logique du GDD, avant projection isométrique.

const Shop = preload("res://scripts/shop_catalogue.gd")
var auxiliary_type: int = -1
var auxiliary_base_cost: int = -1 # Coût historique de diagnostic ; jamais chargé depuis une sauvegarde joueur.
const Maps = preload("res://scripts/map_definition.gd")
const Routes = preload("res://scripts/route_geometry.gd")
# Alias conservés pour les outils et références historiques du Gué.
const PATH_POINTS: Array[Vector2] = Maps.VALLEY_PATH
const SLOTS: Array[Vector2] = Maps.VALLEY_SLOTS
const PATH_LENGTH: float = Maps.VALLEY_LENGTH
var map_definition: Dictionary
var map_error: String = ""
const Banks = preload("res://scripts/bank_encounters.gd")
var wave_set_id: String = "ford"
var route_target_policy: String = "arrival_time"
var protection_events: Array[Dictionary] = [] # Observation visuelle, aucun effet de jeu.
var enemy_hp_percent: int = 100
var path_points: Array[Vector2] = []
var slots: Array[Vector2] = []
var path_length: float
var routes: Array[Dictionary] = []
const INITIAL_GOLD: int = 150
const INITIAL_HP: int = 20

const EPS: float = 0.000000001
const ROSTER: Array[Dictionary] = [
	{"name": "Archer elfe", "price": 50, "damage": 8.0, "interval": 1.0, "range": 4.0},
	{"name": "Arbalétrier nain", "price": 75, "damage": 24.0, "interval": 2.5, "range": 5.0},
	{"name": "Mage humain", "price": 100, "damage": 27.0, "interval": 2.5, "range": 3.5, "secondary_damage": 10.8, "secondary_cap": 2, "radius": 1.0},
	{"name": "Lanceur de haches troll", "short_name": "Lanceur de haches", "price": 50, "damage": 16.0, "interval": 2.0, "range": 3.5, "secondary_damage": 8.0, "secondary_cap": 1, "radius": 1.0},
	{"name": "Sapeur gobelin", "price": 75, "damage": 24.0, "interval": 2.5, "range": 3.0, "secondary_damage": 9.6, "secondary_cap": 3, "radius": 1.0},
	{"name": "Chaman orc", "price": 100, "damage": 12.0, "interval": 2.0, "range": 4.5, "curse_damage": 4.8},
	{"name":"Rôdeur elfe","price":60,"damage":6.0,"interval":0.7,"range":3.5},
	{"name":"Mousquetaire nain","price":90,"damage":38.0,"interval":4.0,"range":6.0},
	{"name":"Traqueur troll","price":65,"damage":10.0,"interval":1.25,"range":4.0,"secondary_damage":4.0,"secondary_cap":1,"radius":1.0},
	{"name":"Grenadier gobelin","price":75,"damage":18.0,"interval":2.0,"range":2.7,"secondary_damage":6.0,"secondary_cap":4,"radius":1.15},
]

const ENEMY_TYPES: Array[Dictionary] = [
	{"name": "Grouillant", "hp": 12.0, "speed": 1.15, "fortress_damage": 1, "reward": 1},
	{"name": "Pillard", "hp": 40.0, "speed": 1.0, "fortress_damage": 1, "reward": 3},
	{"name": "Sprinter", "hp": 24.0, "speed": 1.65, "fortress_damage": 1, "reward": 3},
	{"name": "Brute", "hp": 120.0, "speed": 0.7, "fortress_damage": 2, "reward": 7},
	{"name": "Maraudeur", "hp": 80.0, "speed": 1.2, "fortress_damage": 2, "reward": 6},
	{"name": "Colosse", "hp": 240.0, "speed": 0.5, "fortress_damage": 3, "reward": 14},
	{"name": "Élite", "hp": 360.0, "speed": 0.75, "fortress_damage": 4, "reward": 20},
	{"name": "Seigneur de siège", "hp": 600.0, "speed": 0.45, "fortress_damage": 20, "reward": 40},
]

var wave: int = 1
var max_hp: int = INITIAL_HP
var total_killed: int = 0
var total_escaped: int = 0
var arrivals_by_route: Dictionary = {}
var wave_arrivals_by_route: Dictionary = {}
var total_income: int = 0
var completed_time: float = 0.0
var bonuses: Array[int] = [] # indices 0..11 du catalogue R
var bonus_offer: Array[int] = []
var rng := RandomNumberGenerator.new()
var synergies_enabled: bool = true # Désactivé uniquement dans les références historiques de test.
var faction: int = 0
var meta_ranks: Array = MetaTalents.empty_ranks()
var next_instance_id: int = 0
var curses: Array[Dictionary] = []
var spawn_schedule: Array[Dictionary] = []
var gold: int = INITIAL_GOLD
var fortress_hp: int = INITIAL_HP
var elapsed: float = 0.0
var phase: String = "preparation"
var active: bool:
	get:
		return phase == "combat"
var spawned: int = 0
var killed: int = 0
var escaped: int = 0
var enemies: Array[Dictionary] = []
var defenders: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var damage_events: Array[Dictionary] = [] # Observation des pertes réelles, réservée au rendu.
var elimination_events: Array[Dictionary] = [] # Observation visuelle, sans effet de jeu.
var event_log: Array[String] = []
var wave_history: Array[Dictionary] = []
var _wave_record: Dictionary = {}
var action_history: Array[Dictionary] = []
var initial_rng_seed: String = ""
var initial_rng_state: String = ""

func _init(enable_synergies: bool = true, definition: Dictionary = {}) -> void:
	var source: Dictionary = Maps.valley() if definition.is_empty() else definition
	map_error = Maps.validation_error(source)
	map_definition = (source if map_error.is_empty() else Maps.valley()).duplicate(true)
	path_points.assign(map_definition.path_points)
	slots.assign(map_definition.slots)
	path_length = map_definition.path_length
	if map_definition.has("routes"): routes = Routes.network_copy(map_definition.routes)
	synergies_enabled = enable_synergies
	rng.randomize()
	reset()

func reset() -> void:
	auxiliary_base_cost = -1
	meta_ranks = MetaTalents.empty_ranks()
	action_history.clear()
	initial_rng_seed = ""
	initial_rng_state = ""
	wave_history.clear()
	_wave_record.clear()
	gold = INITIAL_GOLD
	faction = 0
	next_instance_id = 0
	curses.clear()
	wave = 1
	max_hp = INITIAL_HP
	total_killed = 0
	total_escaped = 0
	arrivals_by_route.clear()
	total_income = 0
	completed_time = 0.0
	bonuses.clear()
	bonus_offer.clear()
	spawn_schedule = Campaign.schedule(wave,wave_set_id)
	fortress_hp = INITIAL_HP
	elapsed = 0.0
	phase = "preparation"
	spawned = 0
	killed = 0
	escaped = 0
	wave_arrivals_by_route.clear()
	enemies.clear()
	shots.clear()
	damage_events.clear()
	protection_events.clear()
	elimination_events.clear()
	event_log.clear()
	defenders.clear()
	for index in range(slots.size()):
		defenders.append({})
	if not map_error.is_empty(): phase = "invalid_map"

func available_types() -> Array[int]:
	var result: Array[int] = []
	result.assign([0,1,2] if faction == 0 else [3,4,5])
	var extra: Dictionary = Shop.for_type(auxiliary_type)
	if not extra.is_empty() and extra.faction == faction: result.append(auxiliary_type)
	return result

static func family(type: int) -> int:
	return Shop.family(type)

func configure_auxiliary(value: Variant) -> bool:
	if not (value is int or value is float) or not is_finite(float(value)) or value != floorf(float(value)): return false
	if int(value) != -1 and Shop.for_type(int(value)).is_empty(): return false
	if not action_history.is_empty() or phase != "preparation" or wave != 1 or gold != INITIAL_GOLD: return false
	auxiliary_type = int(value);auxiliary_base_cost = -1;return true

func configure_auxiliary_cost(value: Variant) -> bool:
	if not (value is int or value is float) or not is_finite(float(value)) or value != floorf(float(value)) or value < 1 or value > 1000000: return false
	if auxiliary_type < 0 or not action_history.is_empty() or phase != "preparation" or wave != 1 or gold != INITIAL_GOLD: return false
	auxiliary_base_cost = int(value);return true

func base_recruit_cost(type: int) -> int:
	return auxiliary_base_cost if type == auxiliary_type and auxiliary_base_cost > 0 else int(ROSTER[type].price)

func select_faction(choice: int) -> bool:
	if choice not in [0, 1] or wave != 1 or not bonuses.is_empty() or phase != "preparation" or spawned != 0 or gold != INITIAL_GOLD:
		return false
	if auxiliary_type >= 0 and Shop.for_type(auxiliary_type).get("faction",-1) != choice: return false
	for defender in defenders:
		if not defender.is_empty():
			return false
	faction = choice
	max_hp = INITIAL_HP+MetaTalents.extra_hp(faction,meta_ranks)
	fortress_hp = max_hp
	_record_action("faction",{"faction":choice})
	return true

func _record_action(kind: String, details: Dictionary = {}) -> void:
	var entry: Dictionary = {"sequence":action_history.size()+1,"kind":kind,"wave":wave,"phase":phase,
		"combat_seconds":snappedf(completed_time+elapsed,0.000001),"gold":gold,"fortress_hp":fortress_hp}
	entry.merge(details.duplicate(true))
	action_history.append(entry)

static func valid_enemy_hp_percent(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floorf(float(value)) and value >= 100 and value <= 127

func configure_enemy_hp(value: Variant) -> bool:
	if not valid_enemy_hp_percent(value) or not action_history.is_empty() or phase != "preparation" or gold != INITIAL_GOLD: return false
	enemy_hp_percent = int(value);return true

func configure_wave_set(value: Variant) -> bool:
	if not Banks.valid_set(value) or not action_history.is_empty() or phase != "preparation" or wave != 1 or gold != INITIAL_GOLD: return false
	wave_set_id = value;spawn_schedule = Campaign.schedule(wave,wave_set_id);return true

static func enemy_definition(type: int) -> Dictionary:
	return Banks.GUARD if type == Banks.GUARD_TYPE else ENEMY_TYPES[type]

static func scaled_enemy_hp(type: int, percent: int = 100) -> float:
	return float(enemy_definition(type).hp) if percent == 100 else float(enemy_definition(type).hp)*(float(percent)/100.0)

static func make_enemy(id: int, type: int, spawn_time: float, defending_faction: int = -1, hp_percent: int = 100) -> Dictionary:
	var definition: Dictionary = enemy_definition(type)
	var enemy: Dictionary = {"id": id, "type": type, "spawn_time": spawn_time, "distance": 0.0,
		"hp": scaled_enemy_hp(type,hp_percent), "max_hp": scaled_enemy_hp(type,hp_percent), "speed": definition.speed,
		"fortress_damage": definition.fortress_damage, "reward": definition.reward}
	if defending_faction != -1:
		var identity: Dictionary = Enemies.for_profile(type,defending_faction)
		if identity.is_empty(): return {}
		enemy.merge({"identity_id":identity.id,"name":identity.name,"origin":identity.origin})
	return enemy

static func wave_forecast(number: int, defending_faction: int = -1, hp_percent: int = 100, set_id: String = "ford") -> Dictionary:
	if not Banks.valid_set(set_id): return {}
	if number < 1 or number > Campaign.WAVES.size() or not valid_enemy_hp_percent(hp_percent): return {}
	if defending_faction != -1 and defending_faction not in [0,1]: return {}
	var schedule: Array[Dictionary] = Campaign.schedule(number,set_id)
	var groups: Array[Dictionary] = []
	var offset: int = 0
	var income: int = 0
	for source in Campaign.waves_for(set_id)[number-1]:
		var type: int = source[0]
		var count: int = source[1]
		var enemy: Dictionary = enemy_definition(type)
		groups.append({"type":type,"count":count,"name":enemy.name,"hp":scaled_enemy_hp(type,hp_percent),"fortress_damage":enemy.fortress_damage,"reward":enemy.reward,"interval":source[2],"first_at":schedule[offset].time,"last_at":schedule[offset+count-1].time})
		if defending_faction != -1:
			var identity: Dictionary = Enemies.for_profile(type,defending_faction)
			groups[-1].merge({"name":identity.name,"identity_id":identity.id,"origin":identity.origin},true)
		income += count*enemy.reward
		offset += count
	return {"wave":number,"groups":groups,"total":schedule.size(),"income":income}

func spawn_route_id(index: int, entry: Dictionary, forecast_wave: int = -1) -> String:
	if routes.is_empty(): return ""
	if entry.has("route_id"): return str(entry.route_id)
	var number := wave if forecast_wave < 0 else forecast_wave
	var route_index := index%routes.size()
	if number > 1 and map_definition.get("route_pattern") == "alternating_pressure":
		var preferred := number%2
		route_index = 1-preferred if index%3 == 2 else preferred
	return routes[route_index].id

func forecast_for_routes(number: int) -> Dictionary:
	var data: Dictionary = wave_forecast(number,faction,enemy_hp_percent,wave_set_id)
	if data.is_empty() or routes.is_empty(): return data
	var indices: Dictionary = {}
	data.entries = []
	for index in range(routes.size()):
		indices[routes[index].id] = index
		data.entries.append({"route_id":routes[index].id,"number":index+1,"count":0,"first_at":-1.0,"last_at":-1.0})
	var schedule: Array[Dictionary] = Campaign.schedule(number,wave_set_id)
	var offset: int = 0
	for group in data.groups:
		var allocations: Array[Dictionary] = []
		for entry in data.entries:
			allocations.append({"route_id":entry.route_id,"number":entry.number,"count":0,"first_at":-1.0,"last_at":-1.0})
		for index in range(offset,offset+group.count):
			var route_id: String = spawn_route_id(index,schedule[index],number)
			if not indices.has(route_id): return {}
			for allocation in [data.entries[indices[route_id]],allocations[indices[route_id]]]:
				if allocation.count==0: allocation.first_at=schedule[index].time
				allocation.count+=1
				allocation.last_at=schedule[index].time
		group.entries=allocations.filter(func(entry: Dictionary)->bool:return entry.count>0)
		offset+=group.count
	return data

func can_build() -> bool:
	return phase == "preparation" or phase == "finished"

func count_type(type: int) -> int:
	var count: int = 0
	for defender in defenders:
		if not defender.is_empty() and defender.type == type:
			count += 1
	return count

func purchase_error(slot: int, type: int) -> String:
	if not can_build():
		return "Achats possibles uniquement entre les vagues."
	if slot < 0 or slot >= slots.size():
		return "Sélectionnez un emplacement."
	if type < 0 or type >= ROSTER.size():
		return "Défenseur inconnu."
	if type not in available_types():
		if Shop.for_type(type).get("faction",-1) == faction: return "Cette alternative n’a pas été choisie pour la mission."
		return "Ce défenseur appartient à l’autre faction."
	if not defenders[slot].is_empty():
		return "Cet emplacement est occupé."
	if count_type(type) >= 2:
		return "Deux exemplaires de ce type sont déjà déployés."
	if gold < purchase_cost(type):
		return "Or insuffisant."
	return ""

func buy(slot: int, type: int) -> bool:
	if not purchase_error(slot, type).is_empty():
		return false
	var stats: Dictionary = ROSTER[type]
	defenders[slot] = {"instance_id": next_instance_id, "type": type, "level": 1, "branch": -1, "paid": purchase_cost(type), "ready_at": 0.0,
		"windows": coverage_windows(slots[slot], stats.range, path_points)}
	next_instance_id += 1
	gold -= purchase_cost(type)
	_refresh_windows()
	_record_action("buy",{"slot":slot,"type":type,"instance_id":defenders[slot].instance_id,"cost":defenders[slot].paid})
	return true

static func stats_for(type: int, level: int = 1, branch: int = -1) -> Dictionary:
	var stats: Dictionary = ROSTER[type].duplicate(true)
	var multiplier: float = Progression.DAMAGE_MULTIPLIERS[level - 1]
	stats.damage *= multiplier
	stats.secondary_damage = stats.get("secondary_damage", 0.0) * multiplier
	stats.curse_damage = stats.get("curse_damage", 0.0) * multiplier
	stats.secondary_cap = stats.get("secondary_cap", 0)
	stats.radius = stats.get("radius", 1.0)
	stats.branch_name = ""
	if level == 4 and branch in [0, 1]:
		var specialization: Dictionary = Progression.BRANCHES[type * 2 + branch] if type < 6 else Shop.BRANCHES[type][branch]
		for key in specialization:
			if key == "name":
				stats.branch_name = specialization.name
			else:
				stats[key] = specialization[key]
	return stats

func synergy_partners(slot: int, rule: Dictionary, branch_override: int = -1, candidate: Dictionary = {}) -> Array[int]:
	var partners: Array[int] = []
	if not synergies_enabled or slot < 0 or slot >= defenders.size(): return partners
	var unit: Dictionary = defenders[slot] if candidate.is_empty() else candidate
	if unit.is_empty(): return partners
	var side: int = rule.types.find(family(unit.type))
	if side < 0: return partners
	var specialised: bool = rule.has("branches")
	var level: int = 4 if branch_override >= 0 else unit.level
	var branch: int = branch_override if branch_override >= 0 else unit.branch
	if specialised and (level != 4 or branch != rule.branches[side]): return partners
	for other_slot in range(defenders.size()):
		var partner: Dictionary = defenders[other_slot]
		if other_slot == slot or partner.is_empty() or family(partner.type) != rule.types[1-side]: continue
		if specialised:
			if partner.level != 4 or partner.branch != rule.branches[1-side]: continue
		elif slots[slot].distance_squared_to(slots[other_slot]) > 25.0: continue
		partners.append(other_slot)
	return partners

func synergy_effects(slot: int, branch_override: int = -1, candidate: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0,"codes":[]}
	for rule in Campaign.PROXIMITY + Campaign.SPECIALISATIONS:
		if synergy_partners(slot, rule, branch_override, candidate).is_empty(): continue
		var side: int = rule.types.find(family((defenders[slot] if candidate.is_empty() else candidate).type))
		for i in range(4):
			result[["direct","secondary","curse","range"][i]] += rule.effects[side][i]
		result.codes.append(rule.code) # Un même code une seule fois, même avec plusieurs partenaires.
	return result

func purchase_preview_stats(slot: int, type: int) -> Dictionary:
	# Requête seule : ni recrutement, ni paiement, ni changement des unités ou du générateur.
	if slot < 0 or slot >= defenders.size() or not defenders[slot].is_empty() or type not in available_types(): return {}
	return get_stats(slot, -1, {"type":type,"level":1,"branch":-1})

func upgrade_preview_stats(slot: int, branch: int = -1) -> Dictionary:
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty(): return {}
	if defenders[slot].type not in available_types(): return {}
	var candidate: Dictionary = defenders[slot].duplicate(true)
	if candidate.level >= 4 or (candidate.level == 3 and branch not in [0,1]) or (candidate.level < 3 and branch != -1): return {}
	candidate.level += 1
	if candidate.level == 4: candidate.branch = branch
	return get_stats(slot, -1, candidate)

func get_stats(slot: int, branch_override: int = -1, candidate: Dictionary = {}) -> Dictionary:
	return _stats_with_bonuses(slot,branch_override,candidate,bonuses)

func _stats_with_bonuses(slot: int, branch_override: int, candidate: Dictionary, active_bonuses: Array) -> Dictionary:
	if slot < 0 or slot >= defenders.size(): return {}
	var defender: Dictionary = defenders[slot] if candidate.is_empty() else candidate
	if defender.is_empty(): return {}
	var level: int = 4 if branch_override >= 0 else defender.get("level",1)
	var stats: Dictionary = stats_for(defender.type,level,branch_override if branch_override >= 0 else defender.get("branch",-1))
	stats.price = base_recruit_cost(defender.type)
	var synergy: Dictionary = synergy_effects(slot,branch_override,candidate)
	var meta: Dictionary = MetaTalents.effects(faction,meta_ranks,defender.type)
	var common: float = (0.10 if 0 in active_bonuses else 0.0) + (0.15 if 6 in active_bonuses and level <= 2 else 0.0) + (0.12 if 7 in active_bonuses and level >= 3 else 0.0)
	stats.reference_damage = stats.damage
	stats.reference_secondary = stats.secondary_damage
	stats.reference_curse = stats.curse_damage
	stats.direct_bonus = common + synergy.direct + meta.direct + (0.15 if 5 in active_bonuses else 0.0)
	stats.secondary_bonus = common + synergy.secondary + meta.secondary + (0.20 if 3 in active_bonuses and family(defender.type) in [2,3,4] else 0.0)
	stats.curse_bonus = common + synergy.curse + meta.curse
	stats.damage = stats.reference_damage * (1.0+stats.direct_bonus)
	stats.secondary_damage = stats.reference_secondary * (1.0+stats.secondary_bonus)
	stats.curse_damage = stats.reference_curse * (1.0+stats.curse_bonus)
	stats.range += synergy.range + meta.range + (0.5 if 2 in active_bonuses else 0.0)
	if 1 in active_bonuses and family(defender.type) != 5: stats.interval /= 1.12
	if 4 in active_bonuses and family(defender.type) in [2,3,4]: stats.radius += 0.2
	stats.synergies = synergy.codes
	return stats

func damage_for(stats: Dictionary, component: String, victim: Dictionary) -> float:
	return _damage_with_bonuses(stats,component,victim,bonuses)

func _damage_with_bonuses(stats: Dictionary, component: String, victim: Dictionary, active_bonuses: Array) -> float:
	var reference: float = stats[{"direct":"reference_damage","secondary":"reference_secondary","curse":"reference_curse"}[component]]
	var extra: float = 0.20 if 11 in active_bonuses and victim.type in [3,5,6,7] else 0.0
	return reference * (1.0+stats[component+"_bonus"]+extra)

func _refresh_windows() -> void:
	for slot in range(defenders.size()):
		if not defenders[slot].is_empty():
			defenders[slot].windows = coverage_windows(slots[slot], get_stats(slot).range, path_points)
			if not routes.is_empty(): defenders[slot].route_windows = Routes.network_coverage(slots[slot],get_stats(slot).range,routes)

func purchase_cost(type: int) -> int:
	return _discounted_cost(base_recruit_cost(type),10,bonuses)

func _discounted_cost(base: float, discount_code: int, active_bonuses: Array) -> int:
	return maxi(1,int(ceil(base * (0.9 if discount_code in active_bonuses else 1.0))))

func bonus_preview(code: int) -> Dictionary:
	# Lecture seule : aucun choix, soin, paiement, recalcul de fenêtres ou tirage.
	if code < 0 or code >= Campaign.BONUSES.size() or code in bonuses: return {}
	var projected: Array = bonuses.duplicate()
	projected.append(code)
	var units: Array[Dictionary] = []
	for slot in range(defenders.size()):
		if defenders[slot].is_empty(): continue
		var before: Dictionary = get_stats(slot)
		var after: Dictionary = _stats_with_bonuses(slot,-1,{},projected)
		var large_before: Dictionary = {}
		var large_after: Dictionary = {}
		for component in ["direct","secondary","curse"]:
			large_before[component] = damage_for(before,component,{"type":7})
			large_after[component] = _damage_with_bonuses(after,component,{"type":7},projected)
		var level: int = defenders[slot].level
		units.append({"slot":slot,"type":defenders[slot].type,"before":before,"after":after,
			"large_before":large_before,"large_after":large_after,
			"upgrade_before":upgrade_cost(slot),"upgrade_after":_discounted_cost(Progression.UPGRADE_COSTS[level-1],9,projected) if level < 4 else 0})
	var purchases: Array[Dictionary] = []
	for type in available_types():
		purchases.append({"type":type,"before":purchase_cost(type),"after":_discounted_cost(base_recruit_cost(type),10,projected)})
	var upgrades: Array[Dictionary] = []
	for cost in Progression.UPGRADE_COSTS:
		upgrades.append({"before":_discounted_cost(cost,9,bonuses),"after":_discounted_cost(cost,9,projected)})
	return {"units":units,"purchases":purchases,"upgrades":upgrades,
		"hp_before":fortress_hp,"hp_after":fortress_hp+(4 if code == 8 else 0),
		"max_before":max_hp,"max_after":max_hp+(4 if code == 8 else 0)}

func prepare_next_wave() -> bool:
	if phase != "finished" or wave >= 10: return false
	completed_time += elapsed
	wave += 1
	elapsed = 0.0
	spawned = 0
	killed = 0
	escaped = 0
	wave_arrivals_by_route.clear()
	shots.clear()
	damage_events.clear()
	protection_events.clear()
	elimination_events.clear()
	curses.clear()
	event_log.clear()
	spawn_schedule = Campaign.schedule(wave,wave_set_id)
	phase = "preparation"
	_record_action("wave_prepare")
	return true

func choose_bonus(code: int) -> bool:
	if phase != "bonus" or code not in bonus_offer or code in bonuses: return false
	var offered: Array[int] = bonus_offer.duplicate()
	bonuses.append(code)
	bonus_offer.clear()
	if code == 8:
		max_hp += 4
		fortress_hp += 4
	_refresh_windows()
	phase = "finished"
	_record_action("bonus_choice",{"offered":offered,"chosen":code})
	return true

func _offer_bonus() -> void:
	var state_before: String = str(rng.state)
	var pool: Array[int] = []
	for code in range(Campaign.BONUSES.size()):
		if code not in bonuses: pool.append(code)
	bonus_offer.clear()
	for index in range(3):
		var selected_index: int = rng.randi_range(0,pool.size()-1)
		bonus_offer.append(pool[selected_index])
		pool.remove_at(selected_index)
	phase = "bonus"
	_record_action("bonus_offer",{"offered":bonus_offer.duplicate(),"rng_state_before":state_before,"rng_state_after":str(rng.state)})

func upgrade_cost(slot: int) -> int:
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty():
		return 0
	var level: int = defenders[slot].get("level", 1)
	return _discounted_cost(Progression.UPGRADE_COSTS[level-1],9,bonuses) if level < 4 else 0

func upgrade_error(slot: int, branch: int = -1) -> String:
	if not can_build():
		return "Améliorations possibles uniquement entre les vagues."
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty():
		return "Sélectionnez un défenseur."
	if defenders[slot].type not in available_types():
		return "Ce défenseur appartient à l’autre faction."
	var level: int = defenders[slot].get("level", 1)
	if level >= 4:
		return "Niveau maximum atteint."
	if gold < upgrade_cost(slot):
		return "Or insuffisant."
	if level == 3 and branch not in [0, 1]:
		return "Choisissez une spécialisation pour atteindre le niveau 4."
	if level < 3 and branch != -1:
		return "La spécialisation se choisit au passage au niveau 4."
	return ""

func upgrade(slot: int, branch: int = -1) -> bool:
	if not upgrade_error(slot, branch).is_empty():
		return false
	var paid: int = upgrade_cost(slot)
	var defender: Dictionary = defenders[slot]
	defender.level += 1
	if defender.level == 4:
		defender.branch = branch
	defender.paid += paid
	gold -= paid
	_refresh_windows()
	_record_action("upgrade",{"slot":slot,"type":defender.type,"instance_id":defender.instance_id,"level":defender.level,"branch":defender.branch,"cost":paid})
	return true

func refund(slot: int) -> int:
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty():
		return 0
	return int(floor(defenders[slot].paid * 70.0 / 100.0))

func sell(slot: int) -> bool:
	if not can_build() or refund(slot) <= 0:
		return false
	var unit: Dictionary = defenders[slot].duplicate(true)
	var received: int = refund(slot)
	gold += received
	defenders[slot] = {}
	_refresh_windows()
	_record_action("sell",{"slot":slot,"type":unit.type,"instance_id":unit.instance_id,"received":received,"invested":unit.paid})
	return true

func start() -> bool:
	if phase != "preparation":
		return false
	for entry in spawn_schedule:
		if entry.has("route_id") and route_by_id(entry.route_id).is_empty(): return false
	if initial_rng_state.is_empty():
		initial_rng_seed = str(rng.seed)
		initial_rng_state = str(rng.state)
	var army: Array[Dictionary] = []
	for slot in range(defenders.size()):
		var unit: Dictionary = defenders[slot]
		if not unit.is_empty(): army.append({"slot":slot,"type":unit.type,"level":unit.level,"branch":unit.branch,"paid":unit.paid,"instance_id":unit.instance_id})
	_wave_record = {"wave":wave,"hp_before":fortress_hp,"max_hp":max_hp,"income_before":total_income,"army":army,"bonuses":bonuses.duplicate(),"planned":spawn_schedule.size()}
	_wave_record["performance"] = Metrics.create(army)
	phase = "combat"
	for defender in defenders:
		if not defender.is_empty():
			defender.ready_at = 0.0
	_record_action("wave_start",{"army":army.duplicate(true),"bonuses":bonuses.duplicate()})
	_resolve_instant()
	return true

func advance(seconds: float) -> void:
	if not active or seconds <= 0.0 or not is_finite(seconds):
		return
	var target_time: float = elapsed + seconds
	# Résoudre les événements à leur instant exact, même si un écran saute une image.
	while active:
		var next_time: float = _next_event_time()
		if next_time > target_time + EPS:
			elapsed = target_time
			_update_positions()
			return
		elapsed = maxf(elapsed, next_time)
		_resolve_instant()

func _next_event_time() -> float:
	var next_time: float = INF
	if spawned < spawn_schedule.size():
		next_time = spawn_schedule[spawned].time
	for curse in curses:
		next_time = minf(next_time, curse.next_at)
	for enemy in enemies:
		next_time = minf(next_time, enemy.spawn_time + enemy_route_length(enemy) / enemy.get("speed", 1.0))
	for defender in defenders:
		if defender.is_empty():
			continue
		for enemy in enemies:
			for window in _windows_for(defender,enemy):
				var first: float = maxf(defender.ready_at, enemy.spawn_time + window.first / enemy.get("speed", 1.0))
				var last: float = enemy.spawn_time + window.last / enemy.get("speed", 1.0)
				if first > elapsed + EPS and first <= last + EPS:
					next_time = minf(next_time, first)
	return next_time

func _update_positions() -> void:
	for enemy in enemies:
		enemy.distance = clampf((elapsed - enemy.spawn_time) * enemy.get("speed", 1.0), 0.0, enemy_route_length(enemy))

func _resolve_instant() -> void:
	# 1. Apparitions et positions ; les arrivants restent ciblables jusqu'à la phase 4.
	while spawned < spawn_schedule.size() and spawn_schedule[spawned].time <= elapsed + EPS:
		var entry: Dictionary = spawn_schedule[spawned]
		var enemy: Dictionary = make_enemy(spawned, entry.type, entry.time,faction,enemy_hp_percent)
		if not routes.is_empty(): enemy.route_id = spawn_route_id(spawned,entry)
		enemies.append(enemy)
		spawned += 1
	_update_positions()
	# 2. Anciens ticks additionnés, puis morts retirés avant le choix des nouveaux tirs.
	var damage: Dictionary = {}
	var hits: Array[Dictionary] = []
	var pending: Array[Dictionary] = []
	for curse in curses:
		if curse.next_at <= elapsed + EPS:
			_add_damage(damage, curse.enemy_id, curse.damage)
			hits.append({"source_id":curse.source_id,"enemy_id":curse.enemy_id,"component":"curse","amount":curse.damage})
			event_log.append("%.9f tick source %d cible %d" % [elapsed, curse.source_id, curse.enemy_id])
			curse.ticks_left -= 1
			curse.next_at += 1.0
		if curse.ticks_left > 0:
			pending.append(curse)
	curses = pending
	_apply_damage(damage,hits)
	# 3. Tous les défenseurs visent le même état des survivants, sans ordre privilégié.
	damage = {}
	hits = []
	var applications: Array[Dictionary] = []
	for slot in range(defenders.size()):
		var defender: Dictionary = defenders[slot]
		if defender.is_empty() or defender.ready_at > elapsed + EPS:
			continue
		var stats: Dictionary = get_stats(slot)
		var targets: Array[Dictionary] = []
		for enemy in enemies:
			for window in _windows_for(defender,enemy):
				if enemy.distance >= window.first - EPS and enemy.distance <= window.last + EPS:
					targets.append(enemy)
					break
		if targets.is_empty():
			continue
		targets.sort_custom(_target_priority)
		var primary: Dictionary = targets[0]
		var impact: Vector2 = enemy_position(primary)
		defender.last_target_position = impact
		var direct_damage: float = damage_for(stats,"direct",primary)
		_add_damage(damage, primary.id, direct_damage)
		hits.append({"source_id":defender.instance_id,"enemy_id":primary.id,"component":"direct","amount":direct_damage})
		var shot: Dictionary = {"time": elapsed, "slot": slot, "type": defender.type,
			"target_id": primary.id, "from": slots[slot], "to": impact, "secondary": [], "radius": stats.radius}
		event_log.append("%.9f tir E%d cible %d" % [elapsed, slot + 1, primary.id])
		if family(defender.type) in [2, 3, 4]:
			var hit_ids: Array[int] = [primary.id]
			var origin: Dictionary = primary
			for hit in range(stats.secondary_cap):
				var candidates: Array[Dictionary] = []
				for enemy in enemies:
					var squared: float = enemy_separation_squared(origin,enemy)
					if enemy.id not in hit_ids and squared < stats.radius * stats.radius:
						candidates.append({"enemy": enemy, "squared": squared})
				if candidates.is_empty():
					break
				candidates.sort_custom(_nearby_priority)
				var victim: Dictionary = candidates[0].enemy
				var secondary_damage: float = damage_for(stats,"secondary",victim)
				_add_damage(damage, victim.id, secondary_damage)
				hits.append({"source_id":defender.instance_id,"enemy_id":victim.id,"component":"secondary","amount":secondary_damage})
				hit_ids.append(victim.id)
				shot.secondary.append(enemy_position(victim))
				# Les explosions restent centrées sur l'impact ; les ricochets avancent.
				if family(defender.type) == 3:
					origin = victim
		elif family(defender.type) == 5:
			applications.append({"source_id": defender.instance_id, "enemy_id": primary.id, "damage": damage_for(stats,"curse",primary)})
		shots.append(shot)
		defender.ready_at = elapsed + stats.interval
	_apply_damage(damage,hits)
	for application in applications:
		if _has_enemy(application.enemy_id):
			_apply_curse(application.source_id, application.enemy_id, application.damage)
	# 4. Les survivants arrivés infligent leurs dégâts sans récompense.
	var survivors: Array[Dictionary] = []
	var arrival_damage: int = 0
	for enemy in enemies:
		if enemy.distance >= enemy_route_length(enemy) - EPS:
			escaped += 1
			total_escaped += 1
			if not routes.is_empty():
				var route_id: String = enemy.route_id
				arrivals_by_route[route_id] = arrivals_by_route.get(route_id, 0)+1
				wave_arrivals_by_route[route_id] = wave_arrivals_by_route.get(route_id, 0)+1
			arrival_damage += enemy.get("fortress_damage", 1)
			event_log.append("%.9f arrivee %d" % [elapsed, enemy.id])
		else:
			survivors.append(enemy)
	enemies = survivors
	_purge_curses()
	fortress_hp = maxi(0, fortress_hp - arrival_damage)
	# 5. Défaite prioritaire sur le choix, la fin et la victoire.
	if fortress_hp == 0:
		phase = "defeat"
	elif spawned == spawn_schedule.size() and enemies.is_empty():
		if wave == 10:
			phase = "victory"
		elif wave in [3,6,9]:
			_offer_bonus()
		else:
			phase = "finished"
	if not active: _finish_wave_record()

func _finish_wave_record() -> void:
	if _wave_record.is_empty() or _wave_record.wave != wave: return
	var record: Dictionary = _wave_record.duplicate(true)
	if not routes.is_empty():
		record["arrivals_by_route"] = wave_arrivals_by_route.duplicate()
	record.merge({"hp_after":fortress_hp,"hp_lost":record.hp_before-fortress_hp,"income":total_income-record.income_before,"killed":killed,"escaped":escaped,"spawned":spawned,"remaining":enemies.size(),"seconds":elapsed,"result":"defeat" if phase == "defeat" else "cleared"})
	wave_history.append(record)
	_record_action("wave_end",{"result":record.result,"killed":killed,"escaped":escaped,"income":record.income,"seconds":elapsed})
	_wave_record.clear()

func _has_enemy(id: int) -> bool:
	for enemy in enemies:
		if enemy.id == id:
			return true
	return false

func _purge_curses() -> void:
	var surviving: Array[Dictionary] = []
	for curse in curses:
		if _has_enemy(curse.enemy_id):
			surviving.append(curse)
	curses = surviving

func _apply_damage(damage: Dictionary, hits: Array = []) -> void:
	if enemies.any(func(enemy): return enemy.get("type",1) == Banks.GUARD_TYPE):
		var positions: Dictionary = {}
		for enemy in enemies: positions[enemy.id] = enemy_position(enemy)
		var redirected: Dictionary = Banks.redirect(enemies,damage,hits,positions)
		damage = redirected.damage;hits = redirected.hits
		for transfer in redirected.transfers:
			if transfer.amount <= 0.0: continue
			protection_events.append({"time":elapsed,"from":positions[transfer.protected_id],"to":positions[transfer.guardian_id],
				"amount":transfer.amount,"guardian_id":transfer.guardian_id,"protected_id":transfer.protected_id})
		while protection_events.size() > 24: protection_events.pop_front()
	Metrics.credit(_wave_record.get("performance",[]),enemies,damage,hits)
	var survivors: Array[Dictionary] = []
	for enemy in enemies:
		var hp_before: float = enemy.hp
		enemy.hp -= damage.get(enemy.id, 0.0)
		if enemy.hp < hp_before:
			damage_events.append({"time":elapsed,"enemy_id":enemy.id,"hp_before":hp_before,"hp_after":maxf(0.0,enemy.hp)})
		if enemy.hp <= 0.0:
			elimination_events.append({"time":elapsed,"enemy_id":enemy.id,"type":enemy.get("type",1),"point":enemy_position(enemy)})
			killed += 1
			total_killed += 1
			var reward: int = enemy.get("reward", 3)
			gold += reward
			total_income += reward
			event_log.append("%.9f mort %d +%d" % [elapsed, enemy.id, reward])
		else:
			survivors.append(enemy)
	enemies = survivors
	_purge_curses()

func _apply_curse(source_id: int, enemy_id: int, damage: float) -> void:
	var surviving: Array[Dictionary] = []
	for curse in curses:
		if curse.source_id != source_id or curse.enemy_id != enemy_id:
			surviving.append(curse)
	surviving.append({"source_id": source_id, "enemy_id": enemy_id,
		"damage": damage, "next_at": elapsed + 1.0, "ticks_left": 2})
	curses = surviving

static func _add_damage(damage: Dictionary, id: int, amount: float) -> void:
	damage[id] = damage.get(id, 0.0) + amount

func _target_priority(a: Dictionary, b: Dictionary) -> bool:
	if not routes.is_empty():
		var first: float = enemy_arrival_delay(a) if route_target_policy=="arrival_time" else enemy_route_length(a)-a.distance
		var second: float = enemy_arrival_delay(b) if route_target_policy=="arrival_time" else enemy_route_length(b)-b.distance
		if first != second: return first < second
		return a.id < b.id
	return _progress_priority(a,b)

func configure_route_target_policy(value: Variant) -> bool:
	# Historical diagnostics only; freeze the rule before any player decision.
	if not value is String or value not in ["arrival_time","remaining_distance"] or routes.is_empty(): return false
	if not action_history.is_empty() or phase!="preparation" or wave!=1 or gold!=INITIAL_GOLD: return false
	route_target_policy=value
	return true

static func _progress_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.distance != b.distance:
		return a.distance > b.distance
	return a.id < b.id

func _nearby_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.squared != b.squared: return a.squared < b.squared
	return _target_priority(a.enemy,b.enemy)

static func _secondary_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.squared != b.squared:
		return a.squared < b.squared
	return _progress_priority(a.enemy, b.enemy)

func point_on_path(progress: float) -> Vector2:
	return position_at(progress, path_points, path_length)

func route_by_id(id: Variant) -> Dictionary:
	if not id is String: return {}
	for route in routes:
		if route.id==id: return route
	return {}

func enemy_route(enemy: Dictionary) -> Dictionary:
	return route_by_id(enemy.get("route_id",""))

func enemy_route_length(enemy: Dictionary) -> float:
	return path_length if routes.is_empty() else float(enemy_route(enemy).path_length)

func enemy_arrival_delay(enemy: Dictionary) -> float:
	return maxf(0.0,enemy_route_length(enemy)-enemy.distance)/float(enemy.get("speed",1.0))

func enemy_route_points(enemy: Dictionary) -> Array[Vector2]:
	if routes.is_empty(): return path_points
	var route: Dictionary = enemy_route(enemy)
	var points: Array[Vector2] = [];points.assign(route.path_points);return points

func enemy_position(enemy: Dictionary) -> Vector2:
	return position_at(enemy.distance,enemy_route_points(enemy),enemy_route_length(enemy))

func enemy_separation_squared(first: Dictionary, second: Dictionary) -> float:
	return Routes.cross_separation_squared(first.distance,enemy_route_points(first),enemy_route_length(first),second.distance,enemy_route_points(second),enemy_route_length(second))

func _windows_for(defender: Dictionary, enemy: Dictionary) -> Array:
	return defender.get("route_windows",{}).get(enemy.get("route_id",""),[]) if not routes.is_empty() else defender.windows

static func coverage_windows(center: Vector2, radius: float, route_points: Array[Vector2] = PATH_POINTS) -> Array[Dictionary]:
	return Routes.coverage_windows(center,radius,route_points)

static func position_components(progress: float, route_points: Array[Vector2] = PATH_POINTS, route_length: float = PATH_LENGTH) -> Dictionary:
	return Routes.position_components(progress,route_points,route_length)

static func separation_squared(first: float, second: float, route_points: Array[Vector2] = PATH_POINTS, route_length: float = PATH_LENGTH) -> float:
	return Routes.separation_squared(first,second,route_points,route_length)

static func position_at(progress: float, route_points: Array[Vector2] = PATH_POINTS, route_length: float = PATH_LENGTH) -> Vector2:
	return Routes.position_at(progress,route_points,route_length)
