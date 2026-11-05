extends "res://tools/survey_campaign_sample.gd"
## Comparaison isolée des deux ateliers. Aucun profil ni gain de campagne.

func _initialize() -> void:
	var rows: Array[Dictionary] = []
	for board in [Model.Maps.converging_workshop(),Model.Maps.mountain_workshop()]:
		for faction in range(2):
			for seed_value in SEEDS:
				for layout in [0,2,4]:
					var row := play(faction,1,seed_value,layout,0,2,-1,300.0,true,false,4,board)
					if row.is_empty():
						printerr(error)
						quit(1)
						return
					rows.append(row)
	print("WORKSHOP_SURVEY=",JSON.stringify({"results":rows,"layouts":LAYOUTS}))
	quit()
