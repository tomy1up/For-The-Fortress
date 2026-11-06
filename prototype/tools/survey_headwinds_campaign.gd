extends "res://tools/survey_campaign_sample.gd"
## Comparaison reproductible, sans chargement d'un profil joueur.
## --missions=34,35 --output=chemin_absolu [--smoke] [--branch=1] [--major-path]
## Renfort optionnel --recruit-slot=0 --recruit-family=0 --recruit-wave=3.
func _initialize() -> void:
	spend_all_earned_points = true
	var missions: Array[int] = [34,35]
	var output := ""
	var smoke := false
	var extra_slot := -1
	var extra_family := -1
	var extra_wave := 3
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		elif argument.begins_with("--missions="):
			missions.clear()
			for text in argument.trim_prefix("--missions=").split(","):
				if not text.is_valid_int() or int(text) in missions: _abort("Liste de missions invalide.");return
				missions.append(int(text))
		elif argument=="--smoke": smoke = true
		elif argument=="--branch=1": specialisation_branch = 1
		elif argument=="--major-path": prefer_major_path = true
		elif argument.begins_with("--bonus-priority="):
			bonus_priority.clear()
			for code in argument.trim_prefix("--bonus-priority=").split(","):
				var index := -1
				for candidate in range(Model.Campaign.BONUSES.size()):
					if Model.Campaign.BONUSES[candidate].code==code: index = candidate;break
				if index<0 or index in bonus_priority: _abort("Préférence de bonus invalide.");return
				bonus_priority.append(index)
		elif argument.begins_with("--recruit-slot="):
			var text := argument.trim_prefix("--recruit-slot=")
			if not text.is_valid_int(): _abort("Emplacement de renfort invalide.");return
			extra_slot = int(text)
		elif argument.begins_with("--recruit-family="):
			var text := argument.trim_prefix("--recruit-family=")
			if not text.is_valid_int(): _abort("Famille de renfort invalide.");return
			extra_family = int(text)
		elif argument.begins_with("--recruit-wave="):
			var text := argument.trim_prefix("--recruit-wave=")
			if not text.is_valid_int(): _abort("Vague de renfort invalide.");return
			extra_wave = int(text)
		else: _abort("Option inconnue : "+argument);return
	if output.is_empty() or missions.is_empty(): _abort("Missions et destination requises.");return
	var extra: Array = []
	if extra_slot!=-1 or extra_family!=-1:
		if extra_slot not in [0,1,5] or extra_family<0 or extra_family>2 or extra_wave<2 or extra_wave>10: _abort("Renfort incompatible avec les placements comparés.");return
		extra = [[extra_slot,extra_family,extra_wave]]
	for number in missions:
		var definition: Dictionary = Catalogue.definition(number)
		if not definition.get("available",false) or definition.get("combat_affix",{}).get("id","")!="headwinds": _abort("Mission sans Vents contraires disponible.");return
	var seeds: Array = [7] if smoke else [7,42,2026]
	var placements: Array = [[3,4,2]] if smoke else [[3,4,2],[4,3,2],[2,3,4]]
	var compositions: Array = [0,3] if smoke else [0,1,2,3]
	var trees: Array = [0,5,10]
	var rows: Array = []
	for number in missions:
		for faction in range(2):
			for placement in placements:
				for seed_value in seeds:
					for composition in compositions:
						for talent in trees:
							var row: Dictionary = play(faction,number,seed_value,0,composition,2,talent,300.0,smoke,true,2,{},placement,extra)
							if row.is_empty(): _abort(error);return
							rows.append(row)
		print("HEADWINDS_SURVEY_PROGRESS=",rows.size())
	var document := {"profile_loaded":false,"game_version":str(ProjectSettings.get_setting("application/config/version")),"source_sha256":source_hashes(),"tool_sha256":{"protocol":FileAccess.get_sha256("res://tools/survey_headwinds_campaign.gd"),"policies":FileAccess.get_sha256("res://tools/survey_campaign_sample.gd")},"protocol":{"missions":missions,"seeds":seeds,"placements":placements,"compositions":compositions,"trees":trees,"branch":specialisation_branch,"major_path":prefer_major_path,"early_upgrade_wave":2,"recruit_from":2,"extra_recruits":extra,"bonus_choice":"first_offer" if bonus_priority.is_empty() else "first_available_in_priority","bonus_priority":bonus_priority.map(func(index):return Model.Campaign.BONUSES[index].code),"all_earned_points":true,"smoke":smoke,"reports_replayed":smoke},"results":rows}
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file==null: _abort("Destination inaccessible.");return
	file.store_string(JSON.stringify(document));file.close()
	print("HEADWINDS_SURVEY_COMPLETE=",rows.size())
	quit()

func _abort(message: String) -> void:
	printerr(message)
	quit(1)
