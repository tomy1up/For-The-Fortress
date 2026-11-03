extends SceneTree
const Main=preload("res://scripts/main.gd")
const Profile=preload("res://scripts/meta_profile.gd")
const Model=preload("res://scripts/valley_model.gd")
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func escape() -> void:
	var event:=InputEventKey.new();event.keycode=KEY_ESCAPE;event.pressed=true
	Input.parse_input_event(event)
	await process_frame
	event=InputEventKey.new();event.keycode=KEY_ESCAPE;event.pressed=false;Input.parse_input_event(event)
func run_checks() -> void:
	for camp in range(2):
		var profile=Profile.new("")
		profile.data.banks[camp].resource=420
		var scene=Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile=profile
		scene._open_campaign(camp);scene._open_shop(camp)
		var shop=scene.shop_menu
		await process_frame
		for index in range(2):
			var before: String=JSON.stringify(profile.data)
			shop.compare_buttons[index].pressed.emit()
			check(shop.comparison_overlay.visible and scene.campaign_menu.overlay_blocked,"La comparaison est modale, avec le parcours toujours bloqué")
			var card: Dictionary=shop.cards[index];var base: Dictionary=Model.ROSTER[card.family]
			check(shop.comparison_title.text.contains(card.name) and shop.comparison_headers[1].text==base.name and shop.comparison_headers[2].text==card.name,"Chaque alternative est comparée à son propre défenseur de départ")
			check(shop.comparison_rows[0][1].text=="%d or"%base.price and shop.comparison_rows[0][2].text=="%d or"%card.stats.price,"Les recrutements comparés utilisent l'or de combat")
			check(shop.comparison_note.text.contains("%d PO une seule fois"%card.po) and shop.comparison_note.text.contains("%d or de combat"%card.stats.price),"Le déblocage permanent est distinct du recrutement")
			check(shop.comparison_rows[4][0].visible==(camp==1),"Les effets secondaires sont présentés seulement aux unités qui en disposent")
			for foreign in Model.Shop.for_faction(1-camp):
				check(not shop.comparison_title.text.contains(foreign.name) and not shop.comparison_headers[1].text.contains(foreign.name),"Aucun bénéficiaire étranger")
			for button in shop.buy_buttons+shop.select_buttons+shop.compare_buttons+[shop.none_button,shop.back_button]:
				check(button.focus_mode==Control.FOCUS_NONE,"Les commandes derrière la comparaison ne prennent pas le focus")
			shop.buy_buttons[0].pressed.emit();shop.select_buttons[0].pressed.emit();shop._none()
			check(JSON.stringify(profile.data)==before,"Comparer et tenter une action derrière ne dépense ni ne sélectionne rien")
			check(Rect2(0,0,1280,800).encloses(shop.comparison_panel.get_global_rect()),"Le comparatif reste dans la fenêtre")
			for row in shop.comparison_rows:
				for label in row:
					if label.visible: check(label.get_minimum_size().y<=label.size.y,"Les valeurs tiennent dans leurs lignes")
			await escape()
			check(shop.visible and not shop.comparison_overlay.visible and scene.campaign_menu.visible,"Échap ferme seulement la comparaison")
			check(root.gui_get_focus_owner()==shop.compare_buttons[index],"Le clavier revient au bouton qui a ouvert la comparaison")
			check(JSON.stringify(profile.data)==before,"La fermeture ne modifie pas la progression")
		shop._buy(0);shop._select(0)
		check(profile.data.banks[camp].resource==240 and profile.selected_shop_type(camp)==shop.cards[0].type,"Les achats et choix fonctionnent après retour")
		shop._compare(0);shop.close()
		check(not shop.visible and not shop.comparison_overlay.visible,"Fermer la boutique efface aussi son comparatif")
		scene._open_shop(1-camp)
		check(shop.faction==1-camp and not shop.comparison_overlay.visible,"Changer de faction ne conserve pas un ancien comparatif")
		scene.free()
	print("SHOP_COMPARISON_TESTS checks=%d failures=%d"%[checks,failures])
	quit(0 if failures==0 else 1)
