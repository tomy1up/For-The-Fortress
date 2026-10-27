extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
# Les nettoyages de nouvelle partie sont testés après une défaite simulée ; les verrous de parcours sont couverts séparément.
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders])
func escape() -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new(); event.keycode = KEY_ESCAPE; event.pressed = pressed
		root.push_input(event)
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.model.gold = 10000 # Fixture des six recrues et des niveaux, pas une partie d’équilibrage.
		for slot in range(6):
			scene.model.buy(slot,faction*3+slot%3)
			for level in range([1,2,3,4,2,3][slot]-1): scene.model.upgrade(slot,0 if level == 2 else -1)
		scene.model.phase = "bonus"; scene.model.wave = 3
		for code in range(12):
			scene.model.bonus_offer.assign([code]); scene._update_interface(); await process_frame
			var before: String = signature(scene)
			check(scene.bonus_cards[0].visible and scene.bonus_detail_buttons[0].visible and not scene.bonus_descriptions[0].visible and not scene.bonus_impact_scrollers[0].visible,"Lecture initiale condensée, détails non imposés")
			var fits: bool = true
			for pair in [[scene.bonus_names[0],56],[scene.bonus_effects[0],78],[scene.bonus_scopes[0],60],[scene.bonus_notes[0],72]]:
				fits = fits and pair[0].get_line_count()*pair[0].get_line_height() <= pair[1]
			check(fits,"Carte lisible sans débordement : faction %d, bonus %d" % [faction,code])
			if code < 8 or code == 11:
				var count: int = 6
				if code == 1 and faction == 1: count = 4
				if code in [3,4]: count = 2 if faction == 0 else 4
				if code in [6,7]: count = 3
				check(scene.bonus_notes[0].text.begins_with(str(count)+" défenseur"),"Bénéficiaires calculés selon faction, classe et niveau réels")
			scene.bonus_detail_buttons[0].pressed.emit(); await process_frame
			check(scene.bonus_detail_index == 0 and scene.bonus_details_back.has_focus() and scene.bonus_descriptions[0].visible and scene.bonus_impact_scrollers[0].visible,"Détails ouverts explicitement, focus sur Retour")
			check(scene.bonus_descriptions[0].text == scene.Model.Campaign.bonus_description(code,faction) and scene.bonus_impacts[0].text == scene._bonus_impact_text(code),"Règle complète et chiffres exacts conservés")
			scene._process(100)
			check(signature(scene) == before and scene.model.phase == "bonus","Lecture longue sans choix, dépense, tirage ou effet de bonus")
			escape(); await process_frame
			check(scene.bonus_detail_index == -1 and scene.model.phase == "bonus" and scene.bonus_detail_buttons[0].has_focus() and signature(scene) == before,"Échap revient aux cartes sans contourner le choix obligatoire")
		scene.model.bonus_offer.assign([0,8,11]); scene._update_interface(); scene._open_bonus_details(1)
		scene.bonus_buttons[0].pressed.emit()
		check(scene.model.bonuses.is_empty(),"Une offre cachée derrière les détails ne peut être validée par signal forcé")
		scene.bonus_buttons[1].pressed.emit(); scene.bonus_buttons[1].pressed.emit()
		check(scene.model.bonuses == [8] and scene.model.max_hp == 24,"Choix depuis les détails : effet appliqué une seule fois")
		scene._show_bonuses(); scene._open_bonus_details(0)
		check(scene.bonus_descriptions[0].visible and not scene.bonus_buttons[0].visible and scene.overview_open,"Bonus acquis consultable sans nouveau choix")
		scene.model.phase = "bonus"; scene.model.wave = 6; scene.model.bonus_offer.assign([1,2,3]); scene._update_interface()
		check(scene.bonus_detail_index == -1 and not scene.overview_open,"Une nouvelle offre remplace les anciens détails")
		scene._choose_bonus(0); scene.model.phase = "defeat"; scene._reset()
		check(scene.bonus_detail_index == -1 and not scene.bonus_panel.visible,"Nouvel essai sans détails résiduels")
		scene.free()
	for type in range(6):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(int(type/3))
		scene.model.gold = 1000; scene._select_slot(0); scene._buy(type%3); scene._upgrade(); scene._upgrade(); scene._upgrade()
		var before: String = signature(scene)
		await process_frame
		var descriptions_fit: bool = true
		for label in scene.specialisation_descriptions: descriptions_fit = descriptions_fit and label.get_line_count()*label.get_line_height() <= 100
		check(descriptions_fit,"Les deux rôles de spécialisation tiennent dans leur carte")
		check(not scene.specialisation_numbers_visible and not scene.specialisation_stats[0].visible and not scene.specialisation_stats[1].visible,"Spécialisations : compromis lisible avant les chiffres")
		scene.specialisation_numbers_button.pressed.emit()
		check(scene.specialisation_numbers_visible and scene.specialisation_stats[0].visible and scene.specialisation_stats[1].visible and scene.specialisation_stats[0].text.contains("→"),"Les deux comparaisons exactes restent disponibles sur demande")
		scene._process(100)
		check(signature(scene) == before and scene.pending_slot == 0,"Consultation des chiffres sans débit, passage de niveau ou lancement")
		scene.specialisation_numbers_button.pressed.emit(); scene._cancel_specialisation(); scene._upgrade()
		check(not scene.specialisation_numbers_visible and signature(scene) == before,"Annulation puis réouverture : lecture simple et budget conservé")
		var price: int = scene.model.upgrade_cost(0); var gold: int = scene.model.gold
		scene._choose_branch(0); scene._choose_branch(0)
		check(scene.model.defenders[0].level == 4 and scene.model.gold == gold-price,"Confirmation explicite : prix réel payé une seule fois")
		scene.free()
	print("COMPACT_CHOICES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
