extends SceneTree
## Armée de référence en joueur avisé (v0.255, décision du porteur du 25 novembre 2026 : « Garantie des tests seulement ») : notes des bonus, choix, relance.
const Model = preload("res://scripts/valley_model.gd")
const Reference = preload("res://tests/reference_army.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func bonus_phase(faction: int, offer: Array) -> Model:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.select_faction(faction)
	m.phase = "bonus"
	m.wave = 2
	m.bonus_offer.assign(offer)
	return m

func run_checks() -> void:
	check(Reference.BONUS_VALUES.size() == 2 and Reference.REROLL_BELOW.size() == 2,"Une table de notes et un seuil par faction")
	for faction in [0,1]:
		check(Reference.BONUS_VALUES[faction].size() == Model.Campaign.BONUSES.size(),"Faction %d : une note par bonus" % faction)
		check(Reference.BONUS_VALUES[faction].all(func(v): return int(v) >= 0 and int(v) <= 100),"Faction %d : notes entre 0 et 100" % faction)
		var sorted_values: Array = Reference.BONUS_VALUES[faction].slice(0,Model.Campaign.HEROIC_FIRST) # médiane des 60 bonus ordinaires (v0.260 : les héroïques n'entrent pas dans les offres du Normal)
		sorted_values.sort()
		check(abs(Reference.REROLL_BELOW[faction]-int(sorted_values[sorted_values.size()/2])) <= 1,"Faction %d : seuil de relance à la médiane des notes" % faction)
	# Choix de la carte la mieux notée ; à égalité, la première de l'offre.
	for faction in [0,1]:
		var offer: Array = [0,53,10]
		check(Reference.best_bonus(faction,offer) == 53,"Faction %d : Armée d'élite préférée à un commun" % faction)
		var tied: Array = [0,0]
		check(Reference.best_bonus(faction,[5,5,5]) == 5 and Reference.best_bonus(faction,tied) == 0,"Faction %d : égalité, première carte" % faction)
	# Offre forte : pas de relance. Offre faible : relance, puis meilleure carte des nouvelles offres.
	var strong = bonus_phase(0,[53,0,1])
	check(Reference.choose_bonus(strong) and strong.bonuses == [53] and strong.rerolls_left == Model.REROLLS_PER_RUN,"Offre forte : choisie sans relance")
	var weak_codes: Array = []
	for code in range(Model.Campaign.BONUSES.size()):
		if Reference.bonus_value(1,code) < Reference.REROLL_BELOW[1]: weak_codes.append(code)
	var weak = bonus_phase(1,weak_codes.slice(0,3))
	weak.rng.seed = 7
	check(Reference.choose_bonus(weak) and weak.rerolls_left == Model.REROLLS_PER_RUN-1 and weak.bonuses.size() == 1,"Offre faible : relance une fois puis choisit")
	var spent = bonus_phase(1,weak_codes.slice(0,3))
	spent.rerolls_left = 0
	check(Reference.choose_bonus(spent) and spent.bonuses == [Reference.best_bonus(1,weak_codes.slice(0,3))],"Sans relance disponible : meilleure carte de l'offre")
	var idle = Model.new(true,Model.Maps.for_id("valley_ford"))
	idle.select_faction(0)
	check(not Reference.choose_bonus(idle) and idle.bonuses.is_empty(),"Hors de la phase de bonus : aucun choix")
	print("REFERENCE_WISE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
