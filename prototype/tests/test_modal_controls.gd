extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func inject(code: int) -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.keycode = code; event.physical_keycode = code; event.pressed = pressed
		root.push_input(event)
func background(scene: Node) -> Array:
	return [scene.start_button,scene.speed_button,scene.reset_button,scene.sell_button,scene.upgrade_button,scene.bonus_summary_button,scene.summary_button,scene.inspection_numbers_button]+scene.buy_buttons
func fingerprint(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),scene.model.defenders,scene.model.enemies,str(scene.model.rng.state),scene.speed,scene.choosing_faction])
func protected_commands(scene: Node) -> void:
	var locked: bool = true
	for control in background(scene):
		locked = locked and control.focus_mode == Control.FOCUS_NONE and not control.has_focus()
	check(locked,"Les commandes de fond ne peuvent plus recevoir le focus")
	check(scene.reset_button.disabled and scene.speed_button.disabled,"Redémarrage et vitesse désactivés derrière le panneau")
	var before: String = fingerprint(scene)
	scene.reset_button.pressed.emit(); scene.speed_button.pressed.emit(); scene.start_button.pressed.emit()
	scene.sell_button.pressed.emit(); scene.upgrade_button.pressed.emit(); scene.buy_buttons[0].pressed.emit()
	check(fingerprint(scene) == before,"Même des signaux forcés ne dépensent, ne relancent et ne changent pas la vitesse")
func available_again(scene: Node) -> void:
	var restored: bool = true
	for control in background(scene): restored = restored and control.focus_mode == Control.FOCUS_ALL
	check(restored,"Les modes de focus normaux reviennent après fermeture")
	scene.start_button.grab_focus()
	check(scene.start_button.has_focus(),"Une commande redevenue disponible peut recevoir le focus")
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false)
		protected_commands(scene)
		scene.faction_buttons[faction].grab_focus()
		scene._process(0.01)
		check(scene.faction_buttons[faction].has_focus(),"Les boutons de faction restent accessibles")
		scene._choose_faction(faction); available_again(scene)
		scene.model.gold = 10000 # Contrôle d’interface sans partie d’équilibrage.
		scene._select_slot(0); scene._buy(0)
		scene.start_button.grab_focus(); scene._show_bonuses(); protected_commands(scene)
		scene.bonus_close.grab_focus()
		scene._process(0.01)
		check(scene.bonus_close.has_focus(),"Fermer le récapitulatif reste accessible au clavier")
		scene.bonus_close.pressed.emit(); available_again(scene)
		scene.model.upgrade(0); scene.model.upgrade(0); scene._update_interface()
		scene.upgrade_button.grab_focus(); scene._upgrade(); protected_commands(scene)
		scene.specialisation_cancel.grab_focus()
		check(scene.specialisation_cancel.has_focus(),"L’annulation N4 reste accessible")
		scene.specialisation_cancel.pressed.emit(); available_again(scene)
		check(scene.model.defenders[0].level == 3,"Fermer le choix n’achète pas une branche")
		scene.model.phase = "bonus"; scene.model.wave = 3; scene.model.bonus_offer.assign([0,1,2]); scene._update_interface()
		protected_commands(scene)
		scene.bonus_buttons[1].grab_focus()
		check(scene.bonus_buttons[1].has_focus(),"Les propositions restent accessibles au clavier")
		scene.bonus_buttons[1].pressed.emit()
		check(scene.model.bonuses == [1] and scene.model.phase == "finished","Le choix explicite valide le bonus prévu")
		available_again(scene)
		scene.model.phase = "defeat"; scene._update_interface(); scene._show_run_summary(); protected_commands(scene)
		scene.summary_close.grab_focus()
		check(scene.summary_close.has_focus(),"Le bouton Fermer du bilan reste accessible")
		scene.summary_tabs[1].pressed.emit()
		check(scene.summary_tab == 1,"Les onglets du bilan ne sont pas bloqués avec le fond")
		scene._close_run_summary()
		check(scene.reset_button.focus_mode == Control.FOCUS_ALL and not scene.reset_button.disabled,"Rejouer retrouve son état normal après le bilan")
		scene._reset()
		check(scene.choosing_faction and scene.model.gold == 150 and scene.speed == 1,"Le redémarrage explicite reste possible après fermeture")
		scene.free()
	# Les touches passent par le viewport et le système GUI, sans appel au gestionnaire de choix.
	var scene = Main.new(); root.add_child(scene); scene.set_process(false)
	scene.meta_profile = Profile.new("")
	await process_frame
	check(scene.faction_buttons[0].has_focus(),"Le panneau possède un focus initial pour amorcer Tab")
	inject(KEY_TAB); await process_frame
	check(scene.faction_buttons[1].has_focus(),"Tab atteint la seconde faction, pas une commande de fond")
	inject(KEY_ENTER); await process_frame
	check(scene.choosing_faction and scene.campaign_menu.visible and scene.campaign_menu.faction == 1,"Entrée ouvre le parcours de la faction sans lancer de mission")
	inject(KEY_ENTER); await process_frame
	check(not scene.choosing_faction and scene.model.faction == 1 and scene.model.gold == 150,"Entrée choisit la faction ciblée, sans lancer de vague")
	scene._show_bonuses()
	check(scene.bonus_close.has_focus(),"Le récapitulatif donne le focus à sa fermeture")
	for step in range(4):
		inject(KEY_TAB); await process_frame
		check(root.gui_get_focus_owner() == scene.bonus_close or root.gui_get_focus_owner() in scene.bonus_detail_buttons,"Tab reste dans les commandes du récapitulatif")
	inject(KEY_ENTER); await process_frame
	check(not scene.overview_open and not scene.choosing_faction and scene.model.gold == 150 and scene.model.phase == "preparation","Entrée ferme le récapitulatif au lieu de redémarrer ou démarrer")
	check(scene.start_button.has_focus(),"Un focus utilisable est restauré au retour au jeu")
	scene.free()
	# Les boutons devenus indisponibles ne doivent pas retenir le focus entre deux phases.
	for faction in range(2):
		scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene._select_slot(0); scene._buy(0); scene._select_slot(1); scene._buy(1)
		scene.start_button.grab_focus(); scene._start()
		check(scene.start_button.disabled and scene.bonus_summary_button.has_focus(),"Début de combat : focus déplacé du lancement inactif au récapitulatif disponible")
		var before: String = fingerprint(scene)
		inject(KEY_ENTER); await process_frame
		check(scene.overview_open and scene.bonus_close.has_focus() and fingerprint(scene) == before,"Entrée ouvre une commande utilisable sans changer la simulation")
		inject(KEY_ENTER); await process_frame
		check(not scene.overview_open and scene.bonus_summary_button.has_focus(),"Fermer en combat rend le focus à une commande active")
		scene.speed_button.grab_focus(); scene._update_interface()
		check(scene.speed_button.has_focus(),"Une commande toujours disponible conserve son focus")
		scene._process(1000)
		check(scene.model.phase == "finished" and scene.speed_button.has_focus(),"La fin de vague ne vole pas un focus encore valide")
		scene._select_slot(0); scene.upgrade_button.grab_focus(); scene._process(30)
		check(scene.model.active and scene.upgrade_button.disabled and scene.bonus_summary_button.has_focus(),"Le lancement automatique libère aussi une amélioration devenue inactive")
		scene.free()
	print("MODAL_CONTROLS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
