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
	if data.has("auxiliary_type") and not model.configure_auxiliary(data.auxiliary_type): return _fail("Alternative de boutique invalide.")
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
	if not data.has("enemy_catalog"):
		# Les rapports historiques gardent les noms de profils et le libellé R-12.
		observed.boss_encounter.name = Model.ENEMY_TYPES[7].name
		for bonus in observed.bonuses:
			bonus.description = bonus.description.replace("ours, unités lourdes, gardes d’élite et boss","Brutes, Colosses, Élites et boss")
	for field in observed:
		if field in ["game_version","engine_version"]: continue
		if field == "boss_encounter" and not data.has(field): continue # Champ ajouté en v0.50 ; rapports historiques au format 2.
		if field == "enemy_catalog" and not data.has(field): continue # Champ facultatif ajouté en v0.65.
		if not data.has(field): return _fail("Champ absent : " + field)
		var detail: String = _difference(data[field],observed[field],field)
		if not detail.is_empty(): return _fail(detail)
	var current: String = str(ProjectSettings.get_setting("application/config/version"))
	return {"ok":true,"source_version":data.game_version,"current_version":current,"same_version":data.game_version == current,
		"result":model.phase,"faction":model.faction,"wave":model.wave,"gold":model.gold,"fortress_hp":model.fortress_hp,"actions":actions.size()}
