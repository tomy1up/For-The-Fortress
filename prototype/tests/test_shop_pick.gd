extends SceneTree
## Choix de l'unité de boutique dans la mission, avant la vague 1 (décision du porteur, 16 novembre 2026) : valable pour la mission seulement.
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	for faction in range(2):
		var p = Profile.new("")
		p.grant_all_shop_units()
		var first: Dictionary = Shop.for_faction(faction)[1]
		var second: Dictionary = Shop.for_faction(faction)[3]
		p.select_shop_unit(faction,first.id) # un choix préalable fait dans la boutique ne vaut que pour la mission qui démarre
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = p
		scene._open_campaign(faction)
		scene.campaign_menu._launch()
		await process_frame
		check(not scene.choosing_faction and scene.model.phase == "preparation" and scene.model.wave == 1,"Faction %d : la mission démarre en préparation" % faction)
		check(scene.shop_pick_open and scene.shop_pick_panel.visible,"Le choix de l'unité de boutique s'ouvre avant la vague 1")
		check(scene.model.auxiliary_type == first.type,"Le choix préalable de la boutique sert de point de départ")
		check(p.selected_shop_type(faction) == -1,"Le choix n'est pas conservé pour la mission suivante")
		check(scene.shop_pick_list.get_child_count() == 21 or scene.shop_pick_list.get_child_count() > 0,"La liste propose les unités possédées")
		scene._pick_shop_unit(second.type)
		check(scene.model.auxiliary_type == second.type and scene.model.available_types().size() == 4 and scene.model.available_types()[3] == second.type,"Choisir une unité ajoute son bouton d'achat")
		scene._pick_shop_unit(-1)
		check(scene.model.auxiliary_type == -1 and scene.model.available_types().size() == 3,"« Sans unité de boutique » revient aux trois unités habituelles")
		scene._pick_shop_unit(first.type)
		scene._close_shop_pick()
		check(not scene.shop_pick_open and scene.shop_pick_button.visible,"Fermer le choix laisse un bouton pour le rouvrir")
		scene._open_shop_pick()
		check(scene.shop_pick_open,"Le bouton rouvre le choix tant que rien n'est acheté")
		scene._close_shop_pick()
		# Après un premier achat, le choix est fixé.
		scene.model.buy(0,faction*3)
		scene._update_interface()
		check(not scene._shop_pick_available() and not scene.shop_pick_button.visible,"Après un achat, le choix est fixé pour la mission")
		var before: int = scene.model.auxiliary_type
		scene._pick_shop_unit(-1)
		check(scene.model.auxiliary_type == before,"Un changement tardif est refusé")
		scene.free()
	# Rejeu : une unité choisie après le choix de faction est retrouvée par le rapport.
	for faction in range(2):
		var type: int = Shop.for_faction(faction)[1].type
		var m = Model.new()
		check(m.select_faction(faction) and m.change_auxiliary(type) and m.auxiliary_type == type,"Choix de l'unité de boutique après la faction")
		check(not m.change_auxiliary(Shop.for_faction(1-faction)[0].type),"Une unité de l'autre faction est refusée")
		m.rng.seed = 11
		m.buy(0,faction*3)
		check(not m.change_auxiliary(-1) and m.auxiliary_type == type,"Après un achat le changement est refusé")
		m.buy(1,type)
		for wave in range(1,11):
			if not m.start(): break
			while m.active: m.advance(1.0)
			if m.phase == "defeat": break
			if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
			if wave < 10 and not m.prepare_next_wave(): break
		if m.phase in ["victory","defeat"]:
			var verified: Dictionary = Replay.verify(JSON.parse_string(JSON.stringify(Report.build(m))))
			check(verified.ok,"Le rapport d'une partie avec choix tardif se rejoue exactement (%s)" % verified.get("error",""))
	print("SHOP_PICK_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
