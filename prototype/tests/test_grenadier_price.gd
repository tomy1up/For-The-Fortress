extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Survey = preload("res://tests/survey_shop.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void:
	var card: Dictionary = Model.Shop.card("horde.grenadier")
	check(Model.ROSTER[9].price == 75 and card.stats.price == 75 and card.po == 240,"Seul le recrutement passe à 75 or ; le déblocage reste à 240 PO")
	check(card.stats.range == 2.7 and card.stats.damage == 18.0 and card.stats.interval == 2.0,"Portée, dégâts et cadence conservés")
	var m = Model.new();m.configure_auxiliary(9);m.select_faction(1)
	var preview: Dictionary = m.bonus_preview(10)
	var offered: Dictionary = preview.purchases[-1]
	check(offered.type == 9 and offered.before == 75 and offered.after == 68,"R-11 utilise le nouveau coût et son arrondi supérieur")
	check(m.buy(0,9) and m.gold == 75 and m.defenders[0].paid == 75,"Recrutement : débit réel de 75 or")
	check(m.refund(0) == 52,"Revente à 70 % du montant réellement payé")
	check(not m.configure_auxiliary_cost(90) and m.purchase_cost(9) == 75,"Le coût ne peut pas changer une fois la mission commencée")
	var historical = Model.new();historical.configure_auxiliary(9)
	check(historical.configure_auxiliary_cost(90) and historical.purchase_cost(9) == 90,"Le diagnostic peut restaurer le coût historique avant le départ")
	historical.select_faction(1)
	check(historical.bonus_preview(10).purchases[-1].after == 81,"R-11 historique garde 90 → 81 or")
	historical.buy(0,9)
	check(historical.gold == 60 and historical.get_stats(0).price == 90 and historical.refund(0) == 63,"Paiement, inspection et revente cohérents dans le diagnostic historique")
	historical.reset()
	check(historical.auxiliary_base_cost == -1 and historical.purchase_cost(9) == 75,"Réinitialiser retire le réglage historique")
	for value in [true,"75",0,-1,1.5,INF,null,1000001]:
		var invalid = Model.new();invalid.configure_auxiliary(9)
		check(not invalid.configure_auxiliary_cost(value) and invalid.auxiliary_base_cost == -1,"Coût historique invalide refusé")
	var no_extra = Model.new();check(not no_extra.configure_auxiliary_cost(90),"Pas de coût d’alternative sans alternative choisie")
	for name in ["normal","discount"]:
		var path: String = "res://tests/fixtures/grenadier_v0100_"+name+".json"
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		check(data.game_version == "0.100" and not data.has("auxiliary_base_cost"),"Fixture réellement capturée avant le changement de format")
		check(Replay.verify(data).ok,"Le rapport historique à 90 or se rejoue : "+name)
		for version in ["0.99","0.99.1"]:
			var other: Dictionary = data.duplicate(true);other.game_version = version
			check(Replay.verify(other).ok,"Même règle de prix pour les premières versions de boutique")
	var run: Dictionary = Survey.run_case(card,5,1,"substitution",1,"famille",42,true,300.0,true)
	var report: Dictionary = run.report
	check(report.auxiliary_base_cost == 75 and Replay.verify(report).ok,"Les nouveaux rapports enregistrent le coût de base et se rejouent")
	for value in [true,"75",0,-1,1.5,INF,null,1000001,90]:
		var invalid: Dictionary = report.duplicate(true);invalid.auxiliary_base_cost = value
		check(not Replay.verify(invalid).ok,"Métadonnée de prix invalide ou incohérente refusée")
	var missing: Dictionary = report.duplicate(true);missing.erase("auxiliary_type")
	check(not Replay.verify(missing).ok,"Le prix ne permet pas d’inventer une alternative non choisie")
	var plain = Model.new();plain.select_faction(0)
	check(not Report.build(plain).has("auxiliary_base_cost"),"Les rapports sans unité de boutique gardent leur format")
	print("GRENADIER_PRICE_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
