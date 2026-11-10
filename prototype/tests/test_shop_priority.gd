extends SceneTree
const Survey = preload("res://tests/survey_shop.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void:
	Survey.historical_talents = true # Le relevé validé date d'avant l'équilibrage des talents.
	var path: String = ProjectSettings.globalize_path("res://").path_join("../design/essais/boutique_v0991_releves.json.gz").simplify_path()
	var archive: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var historical: Variant = JSON.parse_string(archive.decompress_dynamic(20000000,FileAccess.COMPRESSION_GZIP).get_string_from_utf8())
	check(historical is Dictionary and historical.pairs.size() == 3744,"Archive historique complète disponible pour le contrôle de compatibilité")
	if not historical is Dictionary: quit(1);return
	for card in Survey.Model.Shop.CARDS:
		var mission: int = 4 if card.po == 180 else 5
		var reference: Dictionary = {}
		for pair in historical.pairs:
			if pair.card == card.id and pair.mission == mission and pair.layout == 1 and pair.policy == "renfort" and pair.branch == 1 and pair.talent_mode == "famille" and pair.seed == 42: reference = pair;break
		check(not reference.is_empty(),"Scénario de référence retrouvé dans le relevé validé")
		for alternative in [false,true]:
			var normal: Dictionary = Survey.run_case(card,mission,1,"renfort",1,"famille",42,alternative,300.0,false,false,90 if card.type == 9 else -1)
			check(Replay._difference(JSON.parse_string(JSON.stringify(normal)),reference["alternative" if alternative else "base"],"historique").is_empty(),"La politique historique reste exactement identique")
			for branch in range(2):
				var slow: Dictionary = Survey.run_case(card,mission,1,"renfort",branch,"famille",42,alternative,0.05,true,true)
				var fast: Dictionary = Survey.run_case(card,mission,1,"renfort",branch,"famille",42,alternative,300.0,true,true)
				check(slow.failures.is_empty() and fast.failures.is_empty(),"Épargne sans or ajouté, unités et talents autorisés")
				check(Replay._difference(slow.report,fast.report,"rapport").is_empty(),"Priorité et épargne identiques à petits et grands pas")
				check(Replay.verify(fast.report).ok,"Le rapport avec priorité du quatrième défenseur se rejoue")
	print("SHOP_PRIORITY_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
