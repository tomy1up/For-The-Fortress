extends SceneTree
## Calibrage de l'Héroïque (v0.262, lot 5 ; cible validée par le porteur le 27 novembre 2026) : un coefficient de PV par mission et par faction,
## appliqué aux PV du Normal de la faction ; PV bornés de 100 à 800 % ; Normal inchangé ; écran de campagne et lancement.
## Plancher (v0.263, décision du porteur du 28 novembre 2026) : l'Héroïque a toujours plus de PV que le Normal (coefficient d'au moins 105).
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	verify_table()
	verify_launch()
	print("HEROIC_CALIBRATION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

func verify_table() -> void:
	check(Catalogue.HEROIC_HP_COEFFICIENTS.size() == 2 and Catalogue.HEROIC_HP_COEFFICIENTS.all(func(row): return row.size() == 200),"Un coefficient par mission et par faction")
	var below: int = 0
	var raised: int = 0
	for faction in [0,1]:
		for number in range(1,201):
			var coefficient: int = Catalogue.heroic_hp_coefficient(number,faction)
			var calibrated: int = int(Catalogue.HEROIC_HP_COEFFICIENTS[faction][number-1])
			check(calibrated >= 30 and calibrated <= 320,"Mission %d, faction %d : coefficient calibré dans les bornes de la recherche (%d)" % [number,faction,calibrated])
			check(coefficient == maxi(calibrated,Catalogue.HEROIC_MIN_COEFFICIENT) and coefficient >= 105,"Mission %d, faction %d : coefficient relevé au plancher" % [number,faction])
			var normal: int = Catalogue.faction_hp_percent(number,faction)
			var heroic: int = Catalogue.faction_hp_percent(number,faction,Catalogue.HEROIC)
			check(heroic == clampi(int(round(normal*coefficient/100.0)),100,Model.MAX_ENEMY_HP_PERCENT) and Model.valid_enemy_hp_percent(heroic),"Mission %d, faction %d : PV héroïques = PV du Normal × coefficient, bornés" % [number,faction])
			check(Catalogue.faction_hp_percent(number,faction,Catalogue.NORMAL) == normal,"Mission %d : Normal inchangé" % number)
			check(heroic > normal,"Mission %d, faction %d : l'Héroïque a plus de PV que le Normal (%d contre %d)" % [number,faction,heroic,normal])
			if heroic <= normal: below += 1
			if coefficient > calibrated: raised += 1
	print("HEROIC_NOT_ABOVE_NORMAL=",below," HEROIC_RAISED_TO_FLOOR=",raised)
	check(below == 0 and raised == 149,"Plancher : aucun réglage au niveau du Normal ou dessous, 149 réglages relevés")
	check(Catalogue.heroic_hp_coefficient(0,0) == 100 and Catalogue.heroic_hp_coefficient(201,1) == 100 and Catalogue.heroic_hp_coefficient(5,2) == 100,"Hors campagne : coefficient neutre")

func winner(faction: int, normal: int, heroic: int) -> Profile:
	var profile := Profile.new("")
	for item in [[0,normal],[1,heroic]]:
		for number in range(1,int(item[1])+1):
			var id: int = profile.begin_mission(faction,Catalogue.id_for(number,int(item[0])),1,10,0)
			profile.credit_mission(id,faction,10,true)
	return profile

func verify_launch() -> void:
	for faction in [0,1]:
		var game = Main.new();root.add_child(game);game.set_process(false)
		game.meta_profile = winner(faction,100,100)
		game._open_campaign(faction)
		game.campaign_menu._difficulty(1)
		var expected: int = Catalogue.faction_hp_percent(101,faction,Catalogue.HEROIC)
		check(game.campaign_menu.mission_detail.text.contains("PV ennemis : %d %%" % expected),"Faction %d : PV héroïques calibrés affichés pour la mission 101" % faction)
		game.campaign_menu._launch()
		check(not game.choosing_faction and game.model.enemy_hp_percent == expected,"Faction %d : mission héroïque 101 lancée avec ses PV calibrés" % faction)
		game.free()
