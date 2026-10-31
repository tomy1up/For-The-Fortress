extends SceneTree
## Même grille que le renfort initial, avec épargne pour le quatrième défenseur.
const Base = preload("res://tests/survey_shop.gd")
func _initialize() -> void:
	var output: String = "";var card_filter: String = "";var parity: int = -1
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		if argument.begins_with("--card="): card_filter = argument.trim_prefix("--card=")
		if argument.begins_with("--parity="): parity = int(argument.trim_prefix("--parity="))
	if output.is_empty() or parity not in [-1,0,1] or (not card_filter.is_empty() and Base.Model.Shop.card(card_filter).is_empty()): push_error("Préciser une sortie et des filtres valides.");quit(1);return
	var pairs: Array = [];var checks: int = 0;var failures: Array = []
	for card in Base.Model.Shop.CARDS:
		if not card_filter.is_empty() and card.id != card_filter: continue
		for mission in range(1,Base.Catalogue.available_count()+1):
			if Base.budget_before(mission).po < card.po or (parity >= 0 and mission%2 != parity): continue
			for layout_index in range(Base.LAYOUTS.size()):
				for branch in range(2):
					for talent_mode in ["aucun","famille"]:
						for seed_value in Base.SEEDS:
							var pair: Dictionary = {"card":card.id,"faction":card.faction,"mission":mission,"layout":layout_index,"policy":"renfort_prioritaire","branch":branch,"talent_mode":talent_mode,"seed":seed_value}
							for alternative in [false,true]:
								var result: Dictionary = Base.run_case(card,mission,layout_index,"renfort",branch,talent_mode,seed_value,alternative,300.0,false,true)
								checks += result.audit_checks
								for failure in result.failures:
									if failures.size() < 100: failures.append(str(pair)+" "+failure)
								pair["alternative" if alternative else "base"] = result
							pairs.append(pair)
			print("SHOP_SURVEY_PROGRESS card=%s mission=%d pairs=%d" % [card.id,mission,pairs.size()])
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: push_error("Impossible d’enregistrer le relevé.");quit(1);return
	file.store_string(JSON.stringify({"schema":1,"game_version":ProjectSettings.get_setting("application/config/version"),"engine":Engine.get_version_info().string,"layouts":Base.LAYOUTS,"seeds":Base.SEEDS,"audit_checks":checks,"failures":failures,"pairs":pairs}));file.close()
	print("SHOP_SURVEY pairs=%d runs=%d audit_checks=%d failures=%d output=%s" % [pairs.size(),pairs.size()*2,checks,failures.size(),output]);quit(0 if failures.is_empty() else 1)
