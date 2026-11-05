extends SceneTree
## Comparaison de politiques fixes. Aucun profil joueur n'est chargé ou modifié.
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Experience = preload("res://scripts/talent_experience.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const SEEDS: Array[int] = [7,42,2026]
const LAYOUTS: Array = [[0,1,2],[1,2,4],[1,3,4],[0,2,4],[2,4,5],[2,3,5]]
const COMPOSITIONS: Array = [[0,1,2],[0,2,1],[1,1,0],[0,0,2]]
var error: String = ""
var spend_all_earned_points := false

static func source_hashes() -> Dictionary:
	var result: Dictionary = {}
	for name in DirAccess.get_files_at("res://scripts"):
		if name.ends_with(".gd"): result[name] = FileAccess.get_sha256("res://scripts/"+name)
	return result

func play(faction: int, mission: int, seed_value: int, layout: int, composition: int, early: int, talent: int, step: float, replay: bool, full_tree: bool = false, recruit_from: int = 4, workshop: Dictionary = {}) -> Dictionary:
	var definition: Dictionary = Catalogue.definition(mission)
	var board := Model.Maps.for_id(definition.map_id) if workshop.is_empty() else workshop
	var m = Model.new(true,board)
	var wave_set: String = definition.get("wave_set_id","ford")
	if not m.configure_wave_set(wave_set): error = "Rencontres de mission refusées.";return {}
	if not m.configure_enemy_hp(definition.hp_percent): error = "PV de mission refusés.";return {}
	var ranks: Array = Talents.empty_ranks()
	if talent >= 0:
		var available := 1
		var picks: Array[int] = [talent]
		if full_tree:
			var xp := 0
			for previous in range(1,mission): xp += int(Catalogue.definition(previous).xp)
			available = Experience.points_for_xp(xp)
			picks = [talent,talent,talent,talent,talent,Talents.index_for(Talents.coordinates(talent).x,1)]
		for pick in picks:
			var allocation: String = Talents.allocation_error(ranks,pick,available,faction)
			if not allocation.is_empty(): error = "Point non accessible : "+allocation;return {}
			ranks[pick] += 1
		if full_tree and spend_all_earned_points:
			var tree: int = Talents.coordinates(talent).x
			for remaining in range(available-Talents.spent(ranks)):
				var allocated := false
				for local in range(21):
					var index: int = Talents.index_for(tree,local)
					if Talents.allocation_error(ranks,index,available,faction).is_empty():
						ranks[index] += 1
						allocated = true
						break
				if not allocated: error = "Budget de points non répartissable dans cet arbre.";return {}
	if not Talents.valid(ranks): error = "Configuration de talents invalide.";return {}
	m.meta_ranks = ranks
	if not m.select_faction(faction): error = "Faction refusée.";return {}
	m.rng.seed = seed_value
	var slots: Array = LAYOUTS[layout];var types: Array = COMPOSITIONS[composition]
	if not m.buy(slots[0],faction*3+types[0]) or not m.buy(slots[1],faction*3+types[1]): error = "Composition initiale hors budget.";return {}
	var recruited_at := 0
	for wave in range(1,11):
		if wave == early: m.upgrade(slots[0]) # Une tentative, uniquement si les règles normales le permettent.
		if wave >= recruit_from and m.defenders[slots[2]].is_empty():
			if m.buy(slots[2],faction*3+types[2]): recruited_at = wave
		if wave >= 5:
			for slot in slots:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): error = "Départ de vague refusé.";return {}
		while m.active: m.advance(step)
		if m.phase == "defeat": break
		if m.phase == "bonus" and not m.choose_bonus(m.bonus_offer[0]): error = "Choix de bonus refusé.";return {}
		if wave < 10 and not m.prepare_next_wave(): error = "Préparation refusée.";return {}
	var paid: int = 0
	for action in m.action_history:
		if action.kind in ["buy","upgrade"]: paid += int(action.cost)
	if m.phase not in ["victory","defeat"] or m.gold < 0 or m.gold != Model.INITIAL_GOLD+m.total_income-paid:
		error = "Résultat ou conservation de l’or invalide.";return {}
	if replay:
		var verified: Dictionary = Replay.verify(JSON.parse_string(JSON.stringify(Report.build(m))))
		if not verified.ok: error = "Rejeu refusé : "+verified.get("error","");return {}
	return {"faction":faction,"mission":mission,"map_id":board.id,"wave_set_id":wave_set,"enemy_hp_percent":definition.hp_percent,"seed":seed_value,"layout":layout,"composition":composition,"early_upgrade_wave":early,"talent":talent,"talent_name":"Aucun" if talent < 0 else Talents.node(faction,talent).name,"points":Talents.spent(ranks),"result":m.phase,"recruited_at":recruited_at,"reached_wave":m.wave,"hp":m.fortress_hp,"max_hp":m.max_hp,"gold":m.gold,"income":m.total_income,"spent":paid,"combat_seconds":m.completed_time+m.elapsed,"bonuses":m.bonuses.duplicate(),"arrivals_by_route":m.arrivals_by_route.duplicate(),"leaked":m.total_escaped,"killed":m.total_killed}

func _initialize() -> void:
	var output: String = "";var smoke: bool = false;var step: float = 300.0
	var banks := false
	var horde_focus := false
	var slate_pass := false
	var recruit_from := 4
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		elif argument == "--smoke": smoke = true
		elif argument == "--banks": banks = true
		elif argument == "--horde-14-talents": horde_focus = true
		elif argument == "--slate-pass": slate_pass = true
		elif argument == "--all-earned-points": spend_all_earned_points = true
		elif argument == "--early-recruit": recruit_from = 2
		elif argument == "--small-steps": step = 0.05
		else: printerr("Argument inconnu : "+argument);quit(2);return
	if output.is_empty(): printerr("Indiquer --output=<nouveau rapport hors des données du joueur>.");quit(2);return
	output = ProjectSettings.globalize_path(output).replace("\\","/").simplify_path()
	var user_root: String = OS.get_user_data_dir().replace("\\","/").simplify_path().to_lower()
	if not output.is_absolute_path() or output.to_lower() == user_root or output.to_lower().begins_with(user_root+"/") or FileAccess.file_exists(output) or DirAccess.dir_exists_absolute(output):
		printerr("Destination existante ou réservée au joueur refusée.");quit(2);return
	var before: Dictionary = source_hashes();var results: Array = []
	if int(banks)+int(horde_focus)+int(slate_pass)>1: printerr("Choisir un seul périmètre.");quit(2);return
	var mission_range := [21,21] if slate_pass else [14,14] if horde_focus else [11,20] if banks else [1,3]
	for faction in ([1] if horde_focus else range(2)):
		for mission in range(mission_range[0],mission_range[1]+1):
			for seed_value in ([42] if smoke else SEEDS):
				for layout in ([1] if smoke else range(LAYOUTS.size())):
					for composition in ([0] if smoke else range(COMPOSITIONS.size())):
						for early in ([2] if smoke else [1,2,3]):
							for talent in ([-1,Talents.index_for(0,0),Talents.index_for(1,0),Talents.index_for(2,0)] if mission == 3 or horde_focus or slate_pass else [-1]):
								var row: Dictionary = play(faction,mission,seed_value,layout,composition,early,talent,step,smoke,horde_focus or slate_pass,recruit_from)
								if row.is_empty(): printerr(error);quit(1);return
								results.append(row)
			print("CAMPAIGN_SURVEY_PROGRESS=",results.size())
	var expected := (8 if smoke else 1728) if slate_pass else (4 if smoke else 864) if horde_focus else (20 if smoke else 4320) if banks else (12 if smoke else 2592)
	if before != source_hashes() or results.size() != expected: printerr("Sources modifiées ou échantillon incomplet.");quit(1);return
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: printerr("Rapport non accessible.");quit(1);return
	file.store_string(JSON.stringify({"schema":1,"game_version":ProjectSettings.get_setting("application/config/version"),"human_balance_test":false,"mission_range":mission_range,"talent_mode":"all_earned_in_one_tree" if spend_all_earned_points else "six_in_one_tree" if horde_focus or slate_pass else "initial","profile_loaded":false,"sources_sha256":before,"step":step,"smoke_replays":smoke,"case_count":results.size(),"seeds":[42] if smoke else SEEDS,"layouts":LAYOUTS,"compositions":COMPOSITIONS,"recruit_from":recruit_from,"policy":"Deux recrues au départ ; tentative d’amélioration de la première aux vagues 1, 2 ou 3 ; troisième recrue à partir de la vague %d ; améliorations à partir de la vague 5, branche A ; premier bonus proposé. Aucun revenu ajouté, aucune opération forcée. Le relevé de la mission 14 compare chaque arbre avec six points et un témoin sans talent. Les variantes avec un point concernent les missions 1 à 3." % recruit_from,"results":results},"\t")+"\n");file.close()
	print("CAMPAIGN_SURVEY_COMPLETE=",results.size());quit()
