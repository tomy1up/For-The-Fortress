extends "res://tools/survey_campaign_sample.gd"
## Compare les premières positions autour du chemin commun, sans profil joueur.
func _initialize() -> void:
	spend_all_earned_points = true
	var rows: Array[Dictionary] = []
	var placements: Array = [[1,3,4],[3,4,2],[4,3,2],[3,2,4],[4,2,3]]
	var verify_replay := "--replay" in OS.get_cmdline_user_args()
	for faction in range(2):
		for placement in placements:
			for seed_value in SEEDS:
				for composition in range(COMPOSITIONS.size()):
					for talent in [0,5]:
						var row: Dictionary = play(faction,21,seed_value,0,composition,2,talent,300.0,verify_replay,true,2,{},placement)
						if row.is_empty():
							printerr(error)
							quit(1)
							return
						rows.append(row)
			print("CORE_SURVEY_PROGRESS=",rows.size())
	if rows.size()!=240:
		printerr("Comparaison incomplète.")
		quit(1)
		return
	print("CORE_SURVEY=",JSON.stringify({"profile_loaded":false,"game_version":ProjectSettings.get_setting("application/config/version"),"replay_verified":verify_replay,"placements":placements,"results":rows}))
	quit()
