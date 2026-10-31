extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var p = Profile.new("")
		for number in range(1,8):
			var run: int = p.begin_mission(faction,"campaign.%03d" % number,60,10,100);p.credit_mission(run,faction,10,true)
		var other: String = JSON.stringify(p.data.banks[1-faction])
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = p;scene._open_campaign(faction)
		var before: String = JSON.stringify(p.data);scene.campaign_menu.shop_button.pressed.emit()
		var shop = scene.shop_menu
		check(shop.visible and shop.faction == faction and scene.campaign_menu.overlay_blocked and JSON.stringify(p.data) == before,"Consulter la boutique ouvre le bon camp sans dépenser et isole le parcours derrière")
		for index in range(2):
			check(shop.cards[index].faction == faction and not shop.buy_buttons[index].disabled and shop.select_buttons[index].disabled,"La fiche du bon camp est achetable mais pas encore sélectionnable")
			check(Rect2(0,0,1280,800).encloses(shop.buy_buttons[index].get_global_rect()) and Rect2(0,0,1280,800).encloses(shop.select_buttons[index].get_global_rect()),"Les actions de boutique tiennent dans la fenêtre")
			for child in shop.card_panels[index].get_children():
				if child is Label: check(child.get_minimum_size().y <= child.size.y,"Le texte de fiche tient dans son emplacement")
		shop.buy_buttons[0].pressed.emit()
		check(p.data.banks[faction].resource == 240 and p.selected_shop_type(faction) == -1 and not shop.select_buttons[0].disabled,"L’achat débite 180 PO et attend un choix explicite")
		shop.select_buttons[0].pressed.emit()
		check(p.selected_shop_type(faction) == shop.cards[0].type and shop.select_buttons[0].disabled,"La première alternative choisie est confirmée et sauvegardée")
		shop.buy_buttons[1].pressed.emit();shop.select_buttons[1].pressed.emit()
		check(p.data.banks[faction].resource == 0 and p.selected_shop_type(faction) == shop.cards[1].type,"Changer l’alternative choisie parmi deux acquisitions")
		shop.close()
		check(scene.campaign_menu.visible and not scene.campaign_menu.overlay_blocked and scene.campaign_menu.shop_note.text.contains(shop.cards[1].name),"Le parcours retrouve ses commandes et annonce l’option choisie")
		check(scene.get_viewport().gui_get_focus_owner() == scene.campaign_menu.shop_button,"Le clavier revient au bouton de boutique")
		scene.campaign_menu._select(0);scene.campaign_menu._launch()
		check(not scene.choosing_faction and scene.model.available_types().size() == 4 and scene.model.available_types()[3] == shop.cards[1].type and p.shop_locked,"La mission fige son quatrième type et verrouille les achats persistants")
		scene.selected = 0;scene.map_view.selected = 0;scene._update_interface()
		check(scene.buy_buttons.filter(func(button):return button.visible).size() == 4,"Quatre options de recrutement visibles pour un emplacement libre")
		for button in scene.buy_buttons:
			check(Rect2(330,608,926,152).encloses(button.get_global_rect()),"Les quatre options restent dans le panneau de recrutement")
		scene.buy_buttons[3].pressed.emit()
		check(scene.model.defenders[0].type == shop.cards[1].type and scene.model.gold == 150-int(shop.cards[1].stats.price),"Recruter la quatrième option utilise le bon type et l’or de combat")
		scene._show_bonuses()
		check(scene.buy_buttons.all(func(button):return button.focus_mode == Control.FOCUS_NONE),"Le panneau de bonus bloque les quatre recrues au clavier")
		scene._close_bonuses()
		scene._open_shop(faction);shop.open(p,faction)
		check(not shop.visible and not p.select_shop_unit(faction,"") and scene.model.auxiliary_type == shop.cards[1].type,"La boutique ne se rouvre pas et le choix ne change pas au milieu d’une mission")
		check(JSON.stringify(p.data.banks[1-faction]) == other,"Aucune acquisition ou sélection transférée au camp opposé")
		scene.free()
	print("SHOP_INTERFACE_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
