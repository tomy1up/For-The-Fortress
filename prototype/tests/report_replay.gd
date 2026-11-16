extends RefCounted
## Read-only model replay of a schema-2 report. No GUI, save, or external code execution.
const Model = preload("res://scripts/valley_model.gd")
const Report = preload("res://scripts/run_report.gd")
const MAX_BYTES: int = 8 * 1024 * 1024
const MAX_ACTIONS: int = 4096
const EPSILON: float = 0.0000001

static func _fail(message: String) -> Dictionary:
	return {"ok":false,"error":message}

static func _integer(value: Variant, minimum: int, maximum: int) -> bool:
	if not (value is int or value is float): return false
	return is_finite(float(value)) and float(value) == floorf(float(value)) and value >= minimum and value <= maximum

static func _rng_integer(value: Variant) -> bool:
	return value is String and value.length() <= 20 and value.is_valid_int() and str(int(value)) == value

static func _difference(expected: Variant, actual: Variant, path: String) -> String:
	if expected is Dictionary and actual is Dictionary:
		if expected.size() != actual.size(): return path + " : nombre de champs différent"
		for key in actual:
			if not expected.has(key): return path + "." + str(key) + " : champ absent"
			var detail: String = _difference(expected[key],actual[key],path+"."+str(key))
			if not detail.is_empty(): return detail
		return ""
	if expected is Array and actual is Array:
		if expected.size() != actual.size(): return path + " : taille différente"
		for index in range(actual.size()):
			var detail: String = _difference(expected[index],actual[index],path+"[%d]" % index)
			if not detail.is_empty(): return detail
		return ""
	if (expected is int or expected is float) and (actual is int or actual is float):
		return "" if is_finite(float(expected)) and is_finite(float(actual)) and absf(float(expected)-float(actual)) <= EPSILON else path + " : valeur numérique différente"
	return "" if typeof(expected) == typeof(actual) and expected == actual else path + " : valeur différente"

static func load_and_verify(path: String) -> Dictionary:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return _fail("Rapport illisible.")
	if file.get_length() > MAX_BYTES:
		file.close(); return _fail("Rapport trop volumineux (maximum 8 Mio).")
	var text: String = file.get_as_text(); file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK: return _fail("JSON invalide, ligne %d." % parser.get_error_line())
	return verify(parser.data)

## Jeu de règles des arbres de talents d'un rapport : valeurs d'origine avant la v0.168, équilibrage de la v0.168
## pour cette version, valeurs en vigueur ensuite (talents de l'Alliance alignés sur ceux de la Horde depuis la v0.169).
static func _minor_version(version: String) -> int:
	var parts: PackedStringArray = version.split(".")
	return int(parts[1]) if parts.size() >= 2 and parts[0] == "0" and parts[1].is_valid_int() else 1000000

static func talent_rules_for(version: String) -> int:
	var parts: PackedStringArray = version.split(".")
	if parts.size() < 2 or parts[0] != "0" or not parts[1].is_valid_int(): return Model.MetaTalents.Expanded.RULES_CURRENT
	var minor: int = int(parts[1])
	if minor < 168: return Model.MetaTalents.Expanded.RULES_HISTORICAL
	return Model.MetaTalents.Expanded.RULES_V168 if minor == 168 else Model.MetaTalents.Expanded.RULES_CURRENT

## La brûlure du Pyromancien humain s'applique depuis la v0.221 : les rapports plus anciens se rejouent sans elle.
static func burn_rules_for(version: String) -> bool:
	var parts: PackedStringArray = version.split(".")
	if parts.size() < 2 or parts[0] != "0" or not parts[1].is_valid_int(): return true
	return int(parts[1]) >= 221

## Règles de la v0.222 (talents du Mage sur les dots du Pyromancien, Exercice de tir étendu aux alternatives du chaman, rayon d'aura de 4,2) : les rapports plus anciens se rejouent sans elles.
static func rules_v222_for(version: String) -> bool:
	var parts: PackedStringArray = version.split(".")
	if parts.size() < 2 or parts[0] != "0" or not parts[1].is_valid_int(): return true
	return int(parts[1]) >= 222

static func verify(data: Variant) -> Dictionary:
	if not data is Dictionary: return _fail("Le rapport doit être un objet JSON.")
	if data.get("schema_version") != 2: return _fail("Seuls les rapports au format 2 sont pris en charge.")
	if data.get("result") not in ["victory","defeat"]: return _fail("Le rapport doit provenir d’une partie terminée.")
	if not data.get("game_version") is String: return _fail("Version source absente ou invalide.")
	if not _rng_integer(data.get("initial_rng_seed")) or not _rng_integer(data.get("initial_rng_state")):
		return _fail("Graine ou état initial aléatoire invalide : texte entier 64 bits requis.")
	var actions: Variant = data.get("actions")
	if not actions is Array or actions.is_empty() or actions.size() > MAX_ACTIONS:
		return _fail("Journal absent ou trop volumineux (maximum 4096 actions).")
	var definition: Dictionary = {}
	if data.has("map_definition"):
		definition = Model.Maps.from_data(data.map_definition)
		if definition.is_empty(): return _fail("Définition de carte invalide.")
	var model = Model.new(true,definition)
	model.burn_for_all_curse_units = burn_rules_for(data.game_version)
	model.rules_v222 = rules_v222_for(data.game_version)
	model.talent_rules = talent_rules_for(data.game_version) # Chaque rapport garde les valeurs de talents de sa version.
	if data.has("combat_affix") and not model.configure_combat_affix(data.combat_affix): return _fail("Affixe de combat invalide.")
	if not model.routes.is_empty():
		if not model.configure_route_target_policy(data.get("route_target_policy","remaining_distance")): return _fail("Règle de ciblage multitrajet invalide.")
	elif data.has("route_target_policy"): return _fail("Règle multitrajet sans réseau de routes.")
	if data.has("wave_set_id") and not model.configure_wave_set(data.wave_set_id): return _fail("Rencontres de mission invalides.")
	if data.has("auxiliary_type") and not model.configure_auxiliary(data.auxiliary_type): return _fail("Alternative de boutique invalide.")
	if data.has("auxiliary_base_cost"):
		if not model.configure_auxiliary_cost(data.auxiliary_base_cost): return _fail("Coût historique d’alternative invalide.")
	elif model.auxiliary_type == 9 and data.game_version in ["0.99","0.99.1","0.100"]:
		if not model.configure_auxiliary_cost(90): return _fail("Coût du grenadier historique indisponible.")
	if data.has("enemy_hp_percent") and not model.configure_enemy_hp(data.enemy_hp_percent): return _fail("Pourcentage de PV ennemis invalide.")
	if data.has("meta_ranks"):
		if not Model.MetaTalents.valid(data.meta_ranks): return _fail("Talents permanents invalides.")
		model.meta_ranks = data.meta_ranks.duplicate()
	model.rng.seed = int(data.initial_rng_seed); model.rng.state = int(data.initial_rng_state)
	for index in range(actions.size()):
		var action: Variant = actions[index]
		if not action is Dictionary or not action.get("kind") is String: return _fail("Action %d mal formée." % (index+1))
		if action.kind not in ["faction","buy","upgrade","sell","wave_prepare","wave_start","wave_end","bonus_offer","bonus_choice"]:
			return _fail("Action %d inconnue." % (index+1))
		if index >= model.action_history.size():
			var required: Array = {"faction":["faction"],"buy":["slot","type"],"upgrade":["slot","branch"],"sell":["slot"],"bonus_choice":["chosen"]}.get(action.kind,[])
			for field in required:
				var bounds: Array = {"faction":[0,1],"slot":[0,5],"type":[0,Model.ROSTER.size()-1],"branch":[-1,1],"chosen":[0,11]}[field]
				if not _integer(action.get(field),bounds[0],bounds[1]): return _fail("Action %d : champ %s invalide." % [index+1,field])
			var accepted: bool = false
			match action.kind:
				"faction": accepted = model.select_faction(int(action.faction))
				"buy": accepted = model.buy(int(action.slot),int(action.type))
				"upgrade": accepted = model.upgrade(int(action.slot),int(action.branch))
				"sell": accepted = model.sell(int(action.slot))
				"wave_prepare": accepted = model.prepare_next_wave()
				"bonus_choice": accepted = model.choose_bonus(int(action.chosen))
				"wave_start":
					accepted = model.start()
					if accepted: model.advance(10000)
			if not accepted: return _fail("Action %d refusée par les règles actuelles (%s)." % [index+1,action.kind])
		var detail: String = _difference(action,JSON.parse_string(JSON.stringify(model.action_history[index])),"actions[%d]" % index)
		if not detail.is_empty(): return _fail(detail)
	var observed: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
	# Older reports recorded the total per entrance, but omitted the wave breakdown.
	var recorded_waves: Variant = data.get("waves")
	if recorded_waves is Array:
		for index in range(mini(recorded_waves.size(), observed.waves.size())):
			if recorded_waves[index] is Dictionary and not recorded_waves[index].has("arrivals_by_route"):
				observed.waves[index].erase("arrivals_by_route")
	if data.has("enemy_catalog") and _minor_version(str(data.get("game_version",""))) < 176:
		# Avant la v0.176, Gueule-de-Vase s'appelait « Noyé » dans le catalogue des ennemis.
		for item in observed.enemy_catalog:
			if item.id == "enemy.neutral.drowned": item.name = "Noyé"
	if not data.has("enemy_catalog"):
		# Les rapports historiques gardent les noms de profils et le libellé R-12.
		observed.boss_encounter.name = Model.ENEMY_TYPES[7].name
		for bonus in observed.bonuses:
			bonus.description = bonus.description.replace("ours, unités lourdes, gardes d’élite et boss","Brutes, Colosses, Élites et boss")
	for field in observed:
		if field in ["game_version","engine_version"]: continue
		if field == "arrivals_by_entry" and not data.has(field): continue # Optional detail absent from earlier route reports.
		if field=="route_target_policy" and not data.has(field): continue # v0.106 : distance restante, restaurée avant les actions.
		if field == "boss_encounter" and not data.has(field): continue # Champ ajouté en v0.50 ; rapports historiques au format 2.
		if field == "enemy_catalog" and not data.has(field): continue # Champ facultatif ajouté en v0.65.
		if field == "auxiliary_base_cost" and not data.has(field): continue # Les premiers rapports de boutique n’enregistraient pas le prix de base.
		if not data.has(field): return _fail("Champ absent : " + field)
		var detail: String = _difference(data[field],observed[field],field)
		if not detail.is_empty(): return _fail(detail)
	var current: String = str(ProjectSettings.get_setting("application/config/version"))
	return {"ok":true,"source_version":data.game_version,"current_version":current,"same_version":data.game_version == current,
		"result":model.phase,"faction":model.faction,"wave":model.wave,"gold":model.gold,"fortress_hp":model.fortress_hp,"actions":actions.size()}
