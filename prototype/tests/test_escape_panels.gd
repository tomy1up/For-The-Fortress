extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func fingerprint(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),scene.model.defenders,str(scene.model.rng.state),scene.speed,scene.countdown_remaining])
func escape(modifier: String = "", pressed: bool = true, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE; event.physical_keycode = KEY_ESCAPE
	event.pressed = pressed; event.echo = echo
	if not modifier.is_empty(): event.set(modifier,true)
	root.push_input(event)
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false)
		await process_frame
		var before: String = fingerprint(scene); escape(); await process_frame
		check(scene.choosing_faction and fingerprint(scene) == before,"Échap ne ferme pas le choix de faction et ne choisit aucun camp")
		scene._choose_faction(faction); before = fingerprint(scene); escape(); await process_frame
		check(not scene.overview_open and fingerprint(scene) == before,"Échap hors panneau ne modifie ni la partie ni la vitesse")
		scene._show_bonuses()
		for modifier in ["ctrl_pressed","alt_pressed","meta_pressed"]:
			escape(modifier); await process_frame
			check(scene.overview_open,"Combinaison système ignorée")
		escape("",false); escape("",true,true); await process_frame
		check(scene.overview_open,"Relâchement et répétition ne ferment pas le panneau")
		before = fingerprint(scene); escape(); await process_frame
		check(not scene.overview_open and fingerprint(scene) == before and scene.start_button.has_focus(),"Fermeture du récapitulatif : aucune action de jeu et focus disponible")
		scene.model.gold = 1000 # Contrôle des panneaux, pas une partie d’équilibrage.
		scene._select_slot(0); scene._buy(0); scene._upgrade(); scene._upgrade()
		scene._start(); scene._process(1000); scene._process(12)
		var remaining: float = scene.countdown_remaining
		scene._upgrade(); scene._process(20); before = fingerprint(scene)
		check(scene.pending_slot == 0 and scene.countdown_remaining == remaining,"Spécialisation ouverte pendant une préparation suspendue")
		escape(); await process_frame
		check(scene.pending_slot == -1 and scene.model.defenders[0].level == 3 and fingerprint(scene) == before,"Échap annule la spécialisation sans paiement ni changement de modèle")
		scene._process(1)
		check(scene.countdown_remaining == remaining-1,"Annulation reprend le temps restant, sans nouveau délai")
		scene._show_bonuses(); before = fingerprint(scene); escape(); await process_frame
		check(not scene.overview_open and fingerprint(scene) == before,"Récapitulatif fermé pendant la préparation sans consommer le temps")
		scene._start(); scene._show_bonuses(); before = fingerprint(scene); escape(); await process_frame
		check(scene.model.active and not scene.overview_open and fingerprint(scene) == before,"Récapitulatif fermé en combat sans accélérer ou suspendre la simulation")
		scene.model.phase = "bonus"; scene.model.wave = 3; scene.model.bonus_offer.assign([0,1,2]); scene._update_interface()
		before = fingerprint(scene); escape(); await process_frame
		check(scene.bonus_panel.visible and scene.model.phase == "bonus" and scene.model.bonuses.is_empty() and fingerprint(scene) == before,"Choix roguelite obligatoire conservé, sans attribution de bonus")
		scene.model.phase = "defeat"; scene._update_interface(); scene._show_run_summary(); before = fingerprint(scene)
		escape(); await process_frame
		check(not scene.summary_open and not scene.choosing_faction and fingerprint(scene) == before and scene.summary_button.has_focus(),"Bilan fermé sans rejouer ni effacer le rapport")
		var fits: bool = true
		for button in [scene.bonus_close,scene.specialisation_cancel,scene.summary_close]:
			fits = fits and button.text.contains("Échap") and button.get_theme_font("font").get_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size")).x < button.size.x-12
		check(fits,"Raccourci visible dans les trois boutons sans débordement")
		scene.free()
	print("ESCAPE_PANELS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
