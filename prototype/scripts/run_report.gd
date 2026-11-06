extends RefCounted
## Local diagnostic snapshot; never a save game or a source of random draws.
const Model = preload("res://scripts/valley_model.gd")

static func _hp(value: float) -> String:
	return ("%.2f" % value).replace(".",",")

static func boss_encounter(model: RefCounted) -> Dictionary:
	var result: Dictionary = {"status":"not_reached","wave":10,"name":Model.Enemies.for_profile(7,model.faction).name}
	if model.wave != 10: return result
	var boss_id: int = -1
	for index in range(model.spawn_schedule.size()):
		if model.spawn_schedule[index].type == 7:
			boss_id = index
			break
	if boss_id < 0:
		result.status = "unknown"
		return result
	result.merge({"id":boss_id,"max_hp":Model.scaled_enemy_hp(7,model.enemy_hp_percent),"spawn_seconds":model.spawn_schedule[boss_id].time,
		"observed_seconds":model.elapsed,"phase":model.phase})
	if boss_id >= model.spawned:
		result.status = "not_spawned"
		return result
	result.removed_hp = 0.0
	result.remaining_hp = Model.scaled_enemy_hp(7,model.enemy_hp_percent)
	var contributions: Array = model._wave_record.get("performance",[])
	for record in model.wave_history:
		if record.wave != 10: continue
		contributions = record.get("performance",[])
		break
	for unit in contributions: result.removed_hp += unit.get("boss_hp",0.0)
	result.remaining_hp = maxf(0.0,result.max_hp-result.removed_hp)
	for event in model.event_log:
		var words: PackedStringArray = event.split(" ")
		if words.size() < 3 or words[1] not in ["mort","arrivee"] or words[2] != str(boss_id): continue
		result.status = "killed" if words[1] == "mort" else "escaped"
		result.resolved_seconds = float(words[0])
		result.duration_seconds = maxf(0.0,result.resolved_seconds-result.spawn_seconds)
		return result
	for enemy in model.enemies:
		if enemy.id == boss_id and enemy.type == 7:
			result.status = "present"
			result.remaining_hp = enemy.hp
			result.removed_hp = maxf(0.0,result.max_hp-enemy.hp)
			return result
	result.status = "unknown" # Ne pas déduire une élimination de la seule victoire.
	return result

static func boss_description(encounter: Dictionary) -> String:
	match encounter.get("status",""):
		"not_reached": return "Boss final non rencontré : la vague 10 n’a pas été atteinte."
		"not_spawned": return "Le boss final n’était pas encore apparu à la fin du relevé."
		"killed":
			return "Boss final éliminé à %s s de la vague.\n%s s après son apparition.\nPV retirés : %s / %s." % [_hp(encounter.resolved_seconds),_hp(encounter.duration_seconds),_hp(encounter.removed_hp),_hp(encounter.max_hp)]
		"escaped":
			return "Le boss a atteint la forteresse à %s s de la vague.\nIl lui restait %s / %s PV." % [_hp(encounter.resolved_seconds),_hp(encounter.remaining_hp),_hp(encounter.max_hp)]
		"present":
			return ("Boss encore en chemin à la fin de la partie." if encounter.phase in ["victory","defeat"] else "Boss actuellement en chemin.") + "\nPV restants : %s / %s.\nObservation à %s s de la vague." % [_hp(encounter.remaining_hp),_hp(encounter.max_hp),_hp(encounter.observed_seconds)]
	return "Issue du boss non déterminée par le relevé."

static func performance(model: RefCounted) -> Array[Dictionary]:
	var rows: Array[Dictionary] = Model.Metrics.summarize(model.wave_history)
	var present: Array[int] = []
	for unit in model.defenders:
		if not unit.is_empty(): present.append(unit.instance_id)
	for row in rows:
		row["name"] = Model.ROSTER[int(row.type)].name
		row["present_at_end"] = int(row.instance_id) in present
	return rows

static func build(model: RefCounted) -> Dictionary:
	var army: Array = []
	for slot in range(model.defenders.size()):
		if model.defenders[slot].is_empty(): continue
		var unit: Dictionary = model.defenders[slot].duplicate(true)
		unit.erase("last_target_position")
		unit["slot"] = slot
		unit["name"] = Model.ROSTER[unit.type].name
		army.append(unit)
	var bonuses: Array = []
	for code in model.bonuses:
		bonuses.append({"index":code,"code":Model.Campaign.BONUSES[code].code,"name":Model.Campaign.BONUSES[code].name,"description":Model.Campaign.bonus_description(code,model.faction)})
	var report: Dictionary = {"schema_version":2,"game_version":str(ProjectSettings.get_setting("application/config/version","")),"engine_version":Engine.get_version_info().string,
		"faction":model.faction,"faction_name":"Alliance" if model.faction == 0 else "Horde","result":model.phase,"wave":model.wave,
		"enemy_catalog":Model.Enemies.available(model.faction,model.wave_set_id),
		"fortress_hp":model.fortress_hp,"max_hp":model.max_hp,"gold":model.gold,"total_income":model.total_income,"total_killed":model.total_killed,"total_escaped":model.total_escaped,
		"combat_seconds":model.completed_time+model.elapsed,"initial_rng_seed":model.initial_rng_seed,"initial_rng_state":model.initial_rng_state,
		"army":army,"bonuses":bonuses,"waves":model.wave_history.duplicate(true),"actions":model.action_history.duplicate(true),"performance":performance(model),"boss_encounter":boss_encounter(model)}
	if Model.MetaTalents.spent(model.meta_ranks) > 0: report.meta_ranks = model.meta_ranks.duplicate()
	if model.map_definition != Model.Maps.valley(): report.map_definition = Model.Maps.to_data(model.map_definition)
	if not model.routes.is_empty():
		report.route_target_policy = model.route_target_policy
		report.arrivals_by_entry = []
		for index in range(model.routes.size()):
			var route_id: String = model.routes[index].id
			report.arrivals_by_entry.append({"entry": index+1, "route_id": route_id, "arrivals": model.arrivals_by_route.get(route_id, 0)})
	if model.auxiliary_type >= 0:
		report.auxiliary_type = model.auxiliary_type
		report.auxiliary_base_cost = model.base_recruit_cost(model.auxiliary_type)
	if model.enemy_hp_percent != 100: report.enemy_hp_percent = model.enemy_hp_percent
	if model.wave_set_id != "ford": report.wave_set_id = model.wave_set_id
	if not model.combat_affix.is_empty(): report.combat_affix = model.combat_affix.duplicate(true)
	return report

static func markdown(report: Dictionary) -> String:
	var lines: Array[String] = ["# For the Fortress! — Rapport de partie", "", "Version : %s · %s · %s" % [report.game_version,report.faction_name,"Victoire" if report.result == "victory" else "Défaite"],
		"Forteresse : %d/%d PV · Or restant : %d · Combat : %.2f s simulées" % [report.fortress_hp,report.max_hp,report.gold,report.combat_seconds],
		"", "Rapport de débogage local, sans fonction de reprise de partie.", "", "## Vagues", "", "| Vague | Éliminés | Passés | PV perdus | Or gagné | Résultat |", "| --- | --- | --- | --- | --- | --- |"]
	if report.has("enemy_hp_percent"): lines.insert(5,"PV ennemis : %d %% de la référence. Vitesse, dégâts et récompenses de combat inchangés." % report.enemy_hp_percent)
	if report.has("combat_affix"): lines.insert(5,"Vents contraires · −%d %% de cadence pour tous les défenseurs. Les dégâts périodiques déjà appliqués gardent leur rythme." % (100-int(report.combat_affix.cadence_percent)))
	var map: Dictionary = report.get("map_definition",{})
	if map.has("routes"):
		var allocation := "Une apparition par entrée à tour de rôle."
		if map.get("route_pattern") == "alternating_pressure":
			allocation = "À partir de la vague 2, environ deux ennemis sur trois empruntent l’entrée principale, qui change à chaque vague."
		var context := "Atelier multitrajet" if str(map.id).begins_with("workshop_") else "Carte multitrajet"
		lines.insert(5,"%s : %d entrées vers une forteresse. %s" % [context,map.routes.size(),allocation])
		lines.insert(6,"Ciblage : "+("ennemi qui atteindra le plus tôt la forteresse, selon sa vitesse." if report.get("route_target_policy","remaining_distance")=="arrival_time" else "distance restante la plus courte (règle historique)."))
	if report.has("meta_ranks"):
		lines.insert(5,"Talents permanents actifs (rangs par arbre) : "+str(report.meta_ranks)+". Barème de prototype "+("v0.67" if report.meta_ranks.size() == 9 else "v0.68" if report.meta_ranks.size() == 15 else "arbres enrichis")+".")
	for wave in report.waves:
		lines.append("| %d | %d | %d | %d | %d | %s |" % [wave.wave,wave.killed,wave.escaped,wave.hp_lost,wave.income,"Défaite" if wave.result == "defeat" else "Terminée"])
	if report.has("arrivals_by_entry"):
		lines.append("\n## Arrivées par entrée\n")
		lines.append("| Entrée | Ennemis ayant atteint la forteresse |")
		lines.append("| --- | --- |")
		for entry in report.arrivals_by_entry:
			lines.append("| %d | %d |" % [entry.entry, entry.arrivals])
		if report.waves.any(func(wave: Dictionary) -> bool: return wave.has("arrivals_by_route")):
			lines.append("\n### Détail par vague\n")
			var columns := PackedStringArray(["Vague"])
			var separators := PackedStringArray(["---"])
			for entry in report.arrivals_by_entry:
				columns.append("Entrée %d" % entry.entry)
				separators.append("---")
			lines.append("| " + " | ".join(columns) + " |")
			lines.append("| " + " | ".join(separators) + " |")
			for wave in report.waves:
				var cells := PackedStringArray([str(wave.wave)])
				for entry in report.arrivals_by_entry:
					cells.append(str(wave.arrivals_by_route.get(entry.route_id,0)) if wave.has("arrivals_by_route") else "—")
				lines.append("| " + " | ".join(cells) + " |")

	if report.has("boss_encounter"):
		lines.append("\n## Boss final\n")
		lines.append("**%s**\n" % report.boss_encounter.name)
		lines.append(boss_description(report.boss_encounter).replace("\n","  \n"))
		lines.append("\nTemps de simulation depuis le début de la vague, indépendamment de la vitesse d’affichage.")
	if report.has("enemy_catalog"):
		lines.append("\n## Catalogue des attaquants\n")
		lines.append("| Attaquant | Origine | Profil de combat |")
		lines.append("| --- | --- | --- |")
		for enemy in report.enemy_catalog:
			lines.append("| %s | %s | %s |" % [enemy.name,Model.Enemies.origin_label(enemy.origin),Model.enemy_definition(int(enemy.profile)).name])
	if report.has("meta_ranks"):
		var loadout: Dictionary = Model.MetaTalents.loadout_summary(int(report.faction),report.meta_ranks)
		if not loadout.is_empty():
			lines.append("\n## Talents permanents de la partie\n")
			lines.append("%d points actifs · Configuration figée au départ · Règles %s.\n" % [loadout.points,loadout.rules])
			for tree in loadout.trees:
				lines.append("### %s — %d points\n" % [tree.name,tree.points])
				for node in tree.nodes: lines.append("- %s : %d/%d." % [node.name,node.rank,node.maximum])
				if tree.nodes.is_empty(): lines.append("Aucun point investi.")
				lines.append("")
			lines.append("PV supplémentaires au départ : +%d.\n" % loadout.hp)
			for unit in loadout.units: lines.append("- %s : %s." % [Model.ROSTER[unit.type].name,Model.MetaTalents.bonus_line(unit)])
			lines.append("\nLes bonus de partie, synergies et niveaux des unités ne sont pas inclus dans ces seuls bonus permanents.\n")
	lines.append("\n## Activité des défenseurs\n")
	lines.append("PV réellement retirés, sans excédent sur les morts. Les tirs simultanés partagent ces PV proportionnellement à leurs dégâts. Les dégâts contre le boss sont inclus dans le total. Aucun décompte d’éliminations individuelles n’est attribué.\n")
	lines.append("| Recrue | Emplacement | Vagues jouées | Attaques | Coups directs (PV) | Rebonds / explosions (PV) | Malédiction (PV) | Dont boss (PV) | État final |")
	lines.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
	for row in report.get("performance",[]):
		lines.append("| %s (#%d) | E%d | %s | %d | %s | %s | %s | %s | %s |" % [row.name,row.instance_id,row.slot+1,str(row.waves),row.attacks,_hp(row.direct_hp),_hp(row.secondary_hp),_hp(row.curse_hp),_hp(row.boss_hp),"Présente" if row.present_at_end else "Vendue"])
	if report.get("performance",[]).is_empty(): lines.append("\nAucun défenseur n’a participé à une vague.")
	lines.append("\n## Défense finale\n")
	for unit in report.army:
		var branch: String = " · " + Model.stats_for(int(unit.type),4,int(unit.branch)).branch_name if int(unit.level) == 4 else ""
		lines.append("- E%d · %s · Niveau %d%s · %d or investis" % [unit.slot+1,unit.name,unit.level,branch,unit.paid])
	if report.army.is_empty(): lines.append("Aucun défenseur.")
	lines.append("\n## Bonus choisis\n")
	for bonus in report.bonuses: lines.append("- %s · %s : %s" % [bonus.code,bonus.name,bonus.description])
	if report.bonuses.is_empty(): lines.append("Aucun bonus.")
	lines.append("\n## Journal des décisions\n")
	for action in report.actions:
		var detail: String = str(action.kind)
		if action.kind in ["bonus_offer","bonus_choice"]:
			var names: Array[String] = []
			for code in action.offered: names.append(Model.Campaign.BONUSES[int(code)].code + " · " + Model.Campaign.BONUSES[int(code)].name)
			detail = ("Bonus proposés : " if action.kind == "bonus_offer" else "Choix parmi : ") + "; ".join(names)
			if action.kind == "bonus_choice": detail += " → " + Model.Campaign.BONUSES[int(action.chosen)].name
		elif action.kind in ["buy","upgrade","sell"]:
			detail = ("Achat" if action.kind == "buy" else "Amélioration" if action.kind == "upgrade" else "Vente") + " E%d · %s" % [action.slot+1,Model.ROSTER[int(action.type)].name]
			if action.has("cost"): detail += " · %d or dépensés" % action.cost
			if action.has("received"): detail += " · %d or récupérés" % action.received
			if action.kind == "upgrade":
				detail += " · Niveau %d" % action.level
				if int(action.level) == 4: detail += " · " + Model.stats_for(int(action.type),4,int(action.branch)).branch_name
		elif action.kind == "faction": detail = "Faction choisie : " + report.faction_name
		elif action.kind == "wave_prepare": detail = "Préparation de la prochaine vague"
		elif action.kind == "wave_start": detail = "Départ de la vague"
		elif action.kind == "wave_end": detail = "Fin de vague : " + ("défaite" if action.result == "defeat" else "terminée")
		lines.append("- #%d · Vague %d · %.2f s · %s · %d or disponibles" % [action.sequence,action.wave,action.combat_seconds,detail,action.gold])
	lines.append("\nLes identifiants, états du générateur aléatoire et détails complets figurent dans rapport.json.\n")
	return "\n".join(lines)

static func export_local(model: RefCounted, base: String = "user://rapports") -> Dictionary:
	if model.phase not in ["victory","defeat"]: return {"ok":false,"error":"Terminez la partie avant d’exporter son rapport."}
	if FileAccess.file_exists(base): return {"ok":false,"error":"Le dossier des rapports est occupé par un fichier."}
	var folder: String = base.path_join("partie_%s_%d" % [Time.get_datetime_string_from_system().replace(":","-"),Time.get_ticks_usec()])
	var error: int = DirAccess.make_dir_recursive_absolute(folder)
	if error != OK: return {"ok":false,"error":"Impossible de créer le dossier des rapports (code %d)." % error}
	var report: Dictionary = build(model)
	var contents: Dictionary = {"rapport.json":JSON.stringify(report,"\t"),"rapport.md":markdown(report)}
	for name in contents:
		var file := FileAccess.open(folder.path_join(name),FileAccess.WRITE)
		if file == null:
			return {"ok":false,"error":"Écriture du rapport impossible (code %d). Les fichiers incomplets restent dans %s." % [FileAccess.get_open_error(),ProjectSettings.globalize_path(folder)]}
		file.store_string(contents[name])
		file.flush()
		error = file.get_error()
		file.close()
		if error != OK: return {"ok":false,"error":"Écriture du rapport incomplète (code %d)." % error}
	return {"ok":true,"folder":ProjectSettings.globalize_path(folder)}
