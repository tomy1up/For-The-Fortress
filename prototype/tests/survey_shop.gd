extends SceneTree
## Comparaisons appariées de politiques fixes ; aucune écriture de profil joueur.
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Experience = preload("res://scripts/talent_experience.gd")
const Report = preload("res://scripts/run_report.gd")
const SEEDS: Array[int] = [1,42,77]
const LAYOUTS: Array = [[0,1,2,4],[1,2,4,5],[1,3,4,0],[0,2,4,5],[2,4,5,1],[2,3,5,0]]

static func budget_before(mission: int) -> Dictionary:
	var result: Dictionary = {"po":0,"xp":0,"points":0}
	for number in range(1,mission):
		var entry: Dictionary = Catalogue.definition(number)
		if not entry.get("available",false): return {}
		result.po += entry.po;result.xp += entry.xp
	result.points = Experience.points_for_xp(result.xp)
	return result

static func family_ranks(card: Dictionary,points: int) -> Array:
	var ranks: Array = Talents.empty_ranks()
	for rank_number in range(points):
		var chosen: int = -1;var best: float = 0.0
		for index in range(Talents.NODE_COUNT):
			if not Talents.allocation_error(ranks,index,points,card.faction).is_empty(): continue
			var effect: Dictionary = Talents.node(card.faction,index).effect
			if card.family not in effect.get("types",[]): continue
			var score: float = float(effect.get("direct",0))+float(effect.get("secondary",0))+float(effect.get("curse",0))+float(effect.get("range",0))/10.0
			if score > best: chosen = index;best = score
		if chosen < 0: break
		ranks[chosen] += 1
	return ranks

static func plan(card: Dictionary,policy: String,alternative: bool) -> Array:
	var types: Array = []
	if policy == "substitution":
		types.append(card.type if alternative else card.family)
		for type in range(card.faction*3,card.faction*3+3):
			if type != card.family: types.append(type)
	else:
		for type in range(card.faction*3,card.faction*3+3): types.append(type)
		types.append(card.type if alternative else card.family)
	return types

static func _audit(ok: bool,message: String,state: Dictionary) -> void:
	state.checks += 1
	if not ok and state.failures.size() < 100: state.failures.append(message)

static func run_case(card: Dictionary,mission: int,layout_index: int,policy: String,branch: int,talent_mode: String,seed_value: int,alternative: bool,step: float = 300.0,include_report: bool = false) -> Dictionary:
	var state: Dictionary = {"checks":0,"failures":[]}
	var entry: Dictionary = Catalogue.definition(mission)
	var budget: Dictionary = budget_before(mission)
	_audit(not budget.is_empty() and budget.po >= card.po,"Achat étudié finançable avant cette mission",state)
	var ranks: Array = family_ranks(card,budget.points) if talent_mode == "famille" else Talents.empty_ranks()
	_audit(Talents.valid(ranks) and Talents.spent(ranks) <= budget.points,"Talents valides et accessibles avec les premières victoires antérieures",state)
	var m = Model.new(true,Model.Maps.for_id(entry.map_id))
	_audit(m.configure_enemy_hp(entry.hp_percent) and m.configure_auxiliary(card.type if alternative else -1),"Règles de mission et choix d’unité configurés",state)
	m.meta_ranks = ranks.duplicate();_audit(m.select_faction(card.faction),"Faction cohérente",state);m.rng.seed = seed_value
	var types: Array = plan(card,policy,alternative)
	var slots: Array = LAYOUTS[layout_index]
	var deployed_auxiliary: bool = false;var first_auxiliary_wave: int = 0
	var waves: Array = []
	for wave in range(1,11):
		for index in range(types.size()):
			var threshold: int = 1 if index < 2 else 4 if policy == "substitution" or index == 3 else 3
			if wave >= threshold and m.defenders[slots[index]].is_empty(): m.buy(slots[index],types[index])
		if wave == 2 and not m.defenders[slots[0]].is_empty(): m.upgrade(slots[0])
		if wave >= 5:
			for index in range(types.size()):
				var unit: Dictionary = m.defenders[slots[index]]
				if not unit.is_empty(): m.upgrade(slots[index],branch if unit.level == 3 else -1)
		var paid: int = 0
		for unit in m.defenders:
			if unit.is_empty(): continue
			paid += int(unit.paid)
			_audit(unit.type in m.available_types() and m.count_type(unit.type) <= 2,"Faction et quota de recrutement",state)
			if unit.type == card.type:
				deployed_auxiliary = true
				if first_auxiliary_wave == 0: first_auxiliary_wave = wave
		_audit(m.gold >= 0 and m.gold == Model.INITIAL_GOLD+m.total_income-paid,"Conservation de l’or avant combat",state)
		_audit(m.start(),"Départ de vague valide",state)
		while m.active: m.advance(step)
		_audit(m.gold >= 0 and m.gold == Model.INITIAL_GOLD+m.total_income-paid,"Conservation de l’or après combat",state)
		waves.append({"wave":wave,"hp":m.fortress_hp,"phase":m.phase,"paid":paid,"gold":m.gold})
		if m.phase in ["victory","defeat"]: break
		if m.phase == "bonus": _audit(m.choose_bonus(m.bonus_offer[0]),"Choix du premier bonus proposé",state)
		_audit(m.prepare_next_wave(),"Préparation de la vague suivante",state)
	_audit(m.phase in ["victory","defeat"],"Résultat terminal",state)
	var units: Array = []
	for slot in range(m.defenders.size()):
		var unit: Dictionary = m.defenders[slot]
		if not unit.is_empty(): units.append({"slot":slot,"type":unit.type,"level":unit.level,"branch":unit.branch,"paid":unit.paid})
	var result: Dictionary = {"alternative":alternative,"result":m.phase,"wave":m.wave,"hp":m.fortress_hp,"max_hp":m.max_hp,"gold":m.gold,"income":m.total_income,"kills":m.total_killed,"escapes":m.total_escaped,"combat_seconds":m.completed_time+m.elapsed,"bonuses":m.bonuses.duplicate(),"talent_ranks":ranks,"talent_points_available":budget.points,"po_before_purchase":budget.po,"deployed_auxiliary":deployed_auxiliary,"first_auxiliary_wave":first_auxiliary_wave,"units":units,"waves":waves,"audit_checks":state.checks,"failures":state.failures}
	if include_report: result.report = JSON.parse_string(JSON.stringify(Report.build(m)))
	return result

func _initialize() -> void:
	var output: String = ""
	var card_filter: String = ""
	var parity: int = -1
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		if argument.begins_with("--card="): card_filter = argument.trim_prefix("--card=")
		if argument.begins_with("--parity="): parity = int(argument.trim_prefix("--parity="))
	if output.is_empty(): push_error("Préciser --output=chemin.json ; aucun profil joueur n’est utilisé.");quit(1);return
	if parity not in [-1,0,1] or (not card_filter.is_empty() and Model.Shop.card(card_filter).is_empty()): push_error("Filtre d’essai inconnu.");quit(1);return
	var pairs: Array = [];var checks: int = 0;var failures: Array = []
	for card in Model.Shop.CARDS:
		if not card_filter.is_empty() and card.id != card_filter: continue
		for mission in range(1,Catalogue.available_count()+1):
			if parity >= 0 and mission%2 != parity: continue
			if budget_before(mission).po < card.po: continue
			for layout_index in range(LAYOUTS.size()):
				for policy in ["substitution","renfort"]:
					for branch in range(2):
						for talent_mode in ["aucun","famille"]:
							for seed_value in SEEDS:
								var pair: Dictionary = {"card":card.id,"faction":card.faction,"mission":mission,"layout":layout_index,"policy":policy,"branch":branch,"talent_mode":talent_mode,"seed":seed_value}
								for alternative in [false,true]:
									var result: Dictionary = run_case(card,mission,layout_index,policy,branch,talent_mode,seed_value,alternative)
									checks += result.audit_checks
									for failure in result.failures:
										if failures.size() < 100: failures.append(str(pair)+" "+failure)
									pair["alternative" if alternative else "base"] = result
								pairs.append(pair)
			print("SHOP_SURVEY_PROGRESS card=%s mission=%d pairs=%d" % [card.id,mission,pairs.size()])
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: push_error("Impossible d’enregistrer le relevé.");quit(1);return
	file.store_string(JSON.stringify({"schema":1,"game_version":ProjectSettings.get_setting("application/config/version"),"engine":Engine.get_version_info().string,"layouts":LAYOUTS,"seeds":SEEDS,"audit_checks":checks,"failures":failures,"pairs":pairs}));file.close()
	print("SHOP_SURVEY pairs=%d runs=%d audit_checks=%d failures=%d output=%s" % [pairs.size(),pairs.size()*2,checks,failures.size(),output]);quit(0 if failures.is_empty() else 1)
