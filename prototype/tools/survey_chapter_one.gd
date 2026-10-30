extends "res://tools/survey_campaign_sample.gd"
## Comparaison reproductible des sept nouveaux terrains, sans profil ni talent.
func _initialize() -> void:
	var output: String = "";var smoke: bool = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		elif argument == "--smoke": smoke = true
		else: printerr("Argument inconnu : "+argument);quit(2);return
	if output.is_empty(): printerr("Indiquer --output=<nouveau rapport hors des données du joueur>.");quit(2);return
	output = ProjectSettings.globalize_path(output).replace("\\","/").simplify_path()
	var user_root: String = OS.get_user_data_dir().replace("\\","/").simplify_path().to_lower()
	if not output.is_absolute_path() or output.to_lower() == user_root or output.to_lower().begins_with(user_root+"/") or FileAccess.file_exists(output) or DirAccess.dir_exists_absolute(output):
		printerr("Destination existante ou réservée au joueur refusée.");quit(2);return
	var before: Dictionary = source_hashes();var results: Array = []
	for faction in range(2):
		for mission in range(4,11):
			for seed_value in ([42] if smoke else SEEDS):
				for layout in ([0] if smoke else range(LAYOUTS.size())):
					for composition in ([1 if faction == 1 and mission not in [5,8,9] else 0] if smoke else range(COMPOSITIONS.size())):
						var row: Dictionary = play(faction,mission,seed_value,layout,composition,2,-1,300.0,smoke)
						if row.is_empty(): printerr(error);quit(1);return
						results.append(row)
			print("CHAPTER_SURVEY_PROGRESS=",results.size())
	if before != source_hashes() or results.size() != (14 if smoke else 1008): printerr("Sources modifiées ou comparaison incomplète.");quit(1);return
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: printerr("Rapport non accessible.");quit(1);return
	file.store_string(JSON.stringify({"schema":1,"game_version":ProjectSettings.get_setting("application/config/version"),"human_balance_test":false,"profile_loaded":false,"sources_sha256":before,"tool_sha256":FileAccess.get_sha256("res://tools/survey_chapter_one.gd"),"parent_tool_sha256":FileAccess.get_sha256("res://tools/survey_campaign_sample.gd"),"step":300.0,"smoke_replays":smoke,"case_count":results.size(),"seeds":[42] if smoke else SEEDS,"layouts":LAYOUTS,"compositions":COMPOSITIONS,"points":0,"policy":"Deux recrues au départ ; tentative d’amélioration de la première avant la vague 2 ; troisième recrue à partir de la vague 4 ; améliorations à partir de la vague 5, branche A ; premier bonus proposé. Aucun talent, revenu ajouté ou achat forcé.","results":results},"\t")+"\n");file.close()
	print("CHAPTER_SURVEY_COMPLETE=",results.size());quit()
