extends "res://tests/survey_balance.gd"
## Same fixed policies and seeds as v0.19, with passive v0.38 measurements.
func observe_wave(m: RefCounted, record: Dictionary) -> void:
	record["performance"] = m.wave_history[-1].performance.duplicate(true)
	var total: float = 0.0
	for unit in record.performance:
		for field in ["direct_hp","secondary_hp","curse_hp","boss_hp"]:
			audit(is_finite(unit[field]) and unit[field] >= 0.0,"Mesure négative ou non finie")
		total += unit.direct_hp+unit.secondary_hp+unit.curse_hp
		audit(unit.boss_hp <= unit.direct_hp+unit.secondary_hp+unit.curse_hp+0.000001,"Boss inclus dans le total")
	var available: float = 0.0
	for index in range(m.spawned): available += Model.ENEMY_TYPES[m.spawn_schedule[index].type].hp
	audit(total <= available+0.000001,"Conservation des PV retirés")
	if m.wave != 10: return
	var boss_damage: float = 0.0
	for unit in record.performance: boss_damage += unit.boss_hp
	var boss: Dictionary = {"result":"present","seconds":m.elapsed,"removed_hp":boss_damage,"remaining_hp":maxf(0.0,600.0-boss_damage)}
	for event in m.event_log:
		var words: PackedStringArray = event.split(" ")
		if words.size() < 3 or words[2] != "0": continue
		if words[1] == "mort" or words[1] == "arrivee":
			boss.result = "killed" if words[1] == "mort" else "escaped"
			boss.seconds = float(words[0])
			break
	if boss.result == "killed": audit(absf(boss.remaining_hp) < 0.000001,"Boss éliminé : 600 PV retirés")
	record["boss"] = boss

func _initialize() -> void:
	var results: Array[Dictionary] = []
	for faction in range(2):
		for layout in LAYOUTS:
			for policy in ["reference","renforts","specialisation"]:
				for priority in ["degats","economie","couverture"]:
					for branches in ["A","association"]:
						for seed_value in SEEDS:
							var run: Dictionary = run_case(faction,layout,policy,priority,branches,seed_value,observe_wave)
							run["performance"] = Model.Metrics.summarize(run.waves)
							results.append(run)
	var path: String = "user://metrics_v038.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): path = argument.trim_prefix("--output=")
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		push_error("Impossible d’écrire le relevé : " + path); quit(1); return
	file.store_string(JSON.stringify({"schema":2,"game_version":ProjectSettings.get_setting("application/config/version"),"engine":Engine.get_version_info().string,"seeds":SEEDS,"audit_checks":audit_checks,"failures":failures,"runs":results}))
	file.close()
	print("METRICS_SURVEY runs=%d audit_checks=%d failures=%d output=%s" % [results.size(),audit_checks,failures.size(),path])
	quit(0 if failures.is_empty() else 1)
