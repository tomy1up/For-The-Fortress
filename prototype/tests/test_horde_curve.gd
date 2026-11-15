extends SceneTree
## Révision de la courbe de la Horde (15 novembre 2026) : -10 % de PV ennemis à partir de la mission 150, l'Alliance et le début de campagne inchangés.
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for number in range(1,Catalogue.TOTAL_MISSIONS+1):
		var reference: int = Catalogue.hp_percent_for(number)
		check(Catalogue.faction_hp_percent(number,0) == reference,"Mission %d : l’Alliance garde les PV de référence" % number)
		if number < 150: check(Catalogue.faction_hp_percent(number,1) == reference,"Mission %d : la Horde garde les PV de référence avant la mission 150" % number)
		else: check(Catalogue.faction_hp_percent(number,1) == int(round(reference*(0.85 if number == 200 else 0.9))) and Catalogue.faction_hp_percent(number,1) < reference,"Mission %d : PV de la Horde réduits de 10 %% (15 %% à la mission 200)" % number)
	check(Catalogue.faction_hp_percent(200,0) == 264 and Catalogue.faction_hp_percent(200,1) == 224,"Valeurs de la mission 200 : 264 % (Alliance) et 224 % (Horde)")
	print("HORDE_CURVE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
