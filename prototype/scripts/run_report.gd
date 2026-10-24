extends RefCounted
## Local diagnostic snapshot; never a save game or a source of random draws.
const Model = preload("res://scripts/valley_model.gd")

static func build(model: RefCounted) -> Dictionary:
	var army: Array = []
	for slot in range(model.defenders.size()):
		if model.defenders[slot].is_empty(): continue
		var unit: Dictionary = model.defenders[slot].duplicate(true)
		unit["slot"] = slot
		unit["name"] = Model.ROSTER[unit.type].name
		army.append(unit)
	var bonuses: Array = []
	for code in model.bonuses:
		bonuses.append({"index":code,"code":Model.Campaign.BONUSES[code].code,"name":Model.Campaign.BONUSES[code].name,"description":Model.Campaign.bonus_description(code,model.faction)})
	return {"schema_version":1,"game_version":str(ProjectSettings.get_setting("application/config/version","")),"engine_version":Engine.get_version_info().string,
		"faction":model.faction,"faction_name":"Alliance" if model.faction == 0 else "Horde","result":model.phase,"wave":model.wave,
		"fortress_hp":model.fortress_hp,"max_hp":model.max_hp,"gold":model.gold,"total_income":model.total_income,"total_killed":model.total_killed,"total_escaped":model.total_escaped,
		"combat_seconds":model.completed_time+model.elapsed,"initial_rng_seed":model.initial_rng_seed,"initial_rng_state":model.initial_rng_state,
		"army":army,"bonuses":bonuses,"waves":model.wave_history.duplicate(true),"actions":model.action_history.duplicate(true)}

static func markdown(report: Dictionary) -> String:
	var lines: Array[String] = ["# For the Fortress! — Rapport de partie", "", "Version : %s · %s · %s" % [report.game_version,report.faction_name,"Victoire" if report.result == "victory" else "Défaite"],
		"Forteresse : %d/%d PV · Or restant : %d · Combat : %.2f s simulées" % [report.fortress_hp,report.max_hp,report.gold,report.combat_seconds],
		"", "Rapport de débogage local, sans fonction de reprise de partie.", "", "## Vagues", "", "| Vague | Éliminés | Passés | PV perdus | Or gagné | Résultat |", "| --- | --- | --- | --- | --- | --- |"]
	for wave in report.waves:
		lines.append("| %d | %d | %d | %d | %d | %s |" % [wave.wave,wave.killed,wave.escaped,wave.hp_lost,wave.income,"Défaite" if wave.result == "defeat" else "Terminée"])
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
