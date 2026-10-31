extends SceneTree
## Utilisé dans des copies isolées du projet ; les réglages viennent du modèle copié.
const Base = preload("res://tests/survey_shop.gd")
const Replay = preload("res://tests/report_replay.gd")
func _initialize() -> void:
	var output: String = "";var parity: int = -1
	var quick: bool = "--quick" in OS.get_cmdline_user_args()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		if argument.begins_with("--parity="): parity = int(argument.trim_prefix("--parity="))
	if output.is_empty() or parity not in [-1,0,1]: push_error("Sortie et filtre de parité requis.");quit(1);return
	var card: Dictionary = Base.Model.Shop.card("horde.grenadier")
	var state: Dictionary = {"checks":0,"failures":[]}
	Base._audit(Base.Model.ROSTER[9].price == card.stats.price,"Prix modèle et catalogue concordants",state)
	Base._audit(is_equal_approx(Base.Model.ROSTER[9].range,card.stats.range),"Portée modèle et catalogue concordantes",state)
	var pairs: Array = []
	for mission in ([5] if quick else range(5,11)):
		if parity >= 0 and mission%2 != parity: continue
		for layout_index in ([1] if quick else range(Base.LAYOUTS.size())):
			for policy in ["substitution","renfort","renfort_prioritaire"]:
				for branch in range(2):
					for talent_mode in (["famille"] if quick else ["aucun","famille"]):
						for seed_value in ([42] if quick else Base.SEEDS):
							var pair: Dictionary = {"card":card.id,"faction":1,"mission":mission,"layout":layout_index,"policy":policy,"branch":branch,"talent_mode":talent_mode,"seed":seed_value}
							for alternative in [false,true]:
								var name: String = "alternative" if alternative else "base"
								var actual_policy: String = "renfort" if policy == "renfort_prioritaire" else policy
								var result: Dictionary = Base.run_case(card,mission,layout_index,actual_policy,branch,talent_mode,seed_value,alternative,300.0,quick,policy == "renfort_prioritaire")
								state.checks += result.audit_checks
								for failure in result.failures:
									if state.failures.size() < 100: state.failures.append(str(pair)+" "+failure)
								if quick:
									var slow: Dictionary = Base.run_case(card,mission,layout_index,actual_policy,branch,talent_mode,seed_value,alternative,0.05,true,policy == "renfort_prioritaire")
									Base._audit(slow.failures.is_empty(),"Petit pas : budget et actions valides",state)
									Base._audit(Replay._difference(result.report,slow.report,"rapport").is_empty(),"Résultats identiques à petits et grands pas",state)
									Base._audit(Replay.verify(result.report).ok,"Rapport expérimental rejouable",state)
									result.erase("report")
								pair[name] = result
							pairs.append(pair)
		print("GRENADIER_PROGRESS mission=%d pairs=%d" % [mission,pairs.size()])
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: push_error("Impossible d’enregistrer le relevé.");quit(1);return
	file.store_string(JSON.stringify({"schema":1,"game_version":ProjectSettings.get_setting("application/config/version"),"engine":Engine.get_version_info().string,"layouts":Base.LAYOUTS,"seeds":Base.SEEDS,"settings":{"price":card.stats.price,"range":card.stats.range},"quick":quick,"audit_checks":state.checks,"failures":state.failures,"pairs":pairs}));file.close()
	print("GRENADIER_SURVEY pairs=%d runs=%d audit_checks=%d failures=%d" % [pairs.size(),pairs.size()*2,state.checks,state.failures.size()]);quit(0 if state.failures.is_empty() else 1)
