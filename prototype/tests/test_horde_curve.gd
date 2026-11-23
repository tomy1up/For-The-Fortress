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
	# Courbe de base (15 novembre 2026) : Horde -10 % à partir de la mission 150, -15 % à la mission 200 ; puis coefficient de rééquilibrage v0.232 (20 novembre 2026), propre à chaque faction.
	for number in range(1,Catalogue.TOTAL_MISSIONS+1):
		var reference: int = Catalogue.hp_percent_for(number)
		for faction in [0,1]:
			var base: float = float(reference)
			if faction == 1 and number == 200: base = float(int(round(reference*0.85)))
			elif faction == 1 and number >= 150: base = float(int(round(reference*0.9)))
			var played: int = Catalogue.faction_hp_percent(number,faction)
			check(played == int(round(base*Catalogue.rebalance_percent(number,faction)/100.0)),"Mission %d, faction %d : PV joués = courbe de base x coefficient de rééquilibrage" % [number,faction])
			check(played >= 100 and played <= 400,"Mission %d, faction %d : PV joués dans les limites valides" % [number,faction])
	for faction in [0,1]:
		check(Catalogue.REBALANCE_PERCENT[faction].size() == Catalogue.TOTAL_MISSIONS,"Faction %d : un coefficient de rééquilibrage par mission" % faction)
		for number in range(1,Catalogue.TOTAL_MISSIONS+1):
			var coefficient: int = Catalogue.REBALANCE_PERCENT[faction][number-1]
			if number in Catalogue.BELOW_CURVE_MISSIONS[faction]: check(coefficient >= 92 and coefficient < 100,"Faction %d, mission %d : sous la courbe de base, de 92 à 99 %% (décision du porteur, 23 novembre 2026)" % [faction,number])
			else: check(coefficient >= 100 and coefficient <= 200,"Faction %d, mission %d : coefficient entre 100 et 200 %%" % [faction,number])
	print("HORDE_CURVE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
