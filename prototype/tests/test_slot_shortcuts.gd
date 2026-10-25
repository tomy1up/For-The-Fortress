extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func key(scene: Node, code: int, physical: int = 0, modifier: String = "", echo: bool = false, pressed: bool = true) -> void:
	var event := InputEventKey.new()
	event.keycode = code; event.physical_keycode = physical
	event.pressed = pressed; event.echo = echo
	if not modifier.is_empty(): event.set(modifier,true)
	scene._unhandled_key_input(event)
func snapshot(m: RefCounted) -> String:
	return JSON.stringify([Report.build(m),str(m.rng.state),m.defenders,m.enemies])
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false)
		key(scene,KEY_1)
		check(scene.selected == -1,"Pas de sélection derrière le choix de faction")
		scene._choose_faction(faction)
		var before: String = snapshot(scene.model)
		for slot in range(6):
			key(scene,KEY_1+slot)
			check(scene.selected == slot and scene.map_view.selected == slot and scene.title_label.text.begins_with("E%d" % (slot+1)),"Touches de la rangée supérieure : sélection et interface concordent")
			key(scene,KEY_KP_1+slot)
			check(scene.selected == slot and scene.model.defenders[slot].is_empty(),"Pavé numérique : sélection sans recrutement")
		check(snapshot(scene.model) == before,"Aucun paiement, événement, attaque, tirage ou temps consommé")
		key(scene,KEY_AMPERSAND,KEY_1)
		check(scene.selected == 0,"AZERTY : touche physique 1 acceptée sans Maj")
		key(scene,KEY_2,KEY_2,"shift_pressed")
		check(scene.selected == 1,"Chiffre avec Maj accepté")
		for modifier in ["ctrl_pressed","alt_pressed","meta_pressed"]:
			key(scene,KEY_6,KEY_6,modifier)
			check(scene.selected == 1,"Raccourcis système modifiés ignorés")
		for code in [KEY_0,KEY_7,KEY_A,KEY_ESCAPE,KEY_SPACE]:
			key(scene,code)
			check(scene.selected == 1,"Aucune commande ajoutée aux autres touches")
		key(scene,KEY_6,KEY_6,"",true); key(scene,KEY_6,KEY_6,"",false,false)
		check(scene.selected == 1,"Répétition et relâchement ignorés")
		check(not scene._select_slot(-1) and not scene._select_slot(6),"Emplacement invalide refusé")
		scene._show_bonuses(); key(scene,KEY_6)
		check(scene.selected == 1,"Pas de sélection derrière le récapitulatif")
		scene._close_bonuses(); scene.model.phase = "bonus"; key(scene,KEY_6)
		check(scene.selected == 1,"Choix roguelite protégé")
		scene.model.phase = "preparation"; scene.model.gold = 10000
		scene.model.buy(0,faction*3); scene.model.upgrade(0); scene.model.upgrade(0)
		scene._select_slot(0); scene._upgrade(); key(scene,KEY_6)
		check(scene.pending_slot == 0 and scene.selected == 0,"Pas de sélection pendant le choix de spécialisation")
		scene._cancel_specialisation()
		scene.model.phase = "finished"; scene.autoplay_started = true; scene._update_interface(); scene._process(1)
		var remaining: float = scene.countdown_remaining
		before = snapshot(scene.model); key(scene,KEY_6)
		check(scene.selected == 5 and scene.countdown_remaining == remaining and snapshot(scene.model) == before,"La sélection laisse la préparation et l’économie inchangées")
		scene._process(1)
		check(scene.countdown_remaining == remaining-1,"Le décompte continue normalement")
		scene._start(); before = snapshot(scene.model); key(scene,KEY_1)
		check(scene.selected == 0 and scene.sell_button.disabled and scene.upgrade_button.disabled and snapshot(scene.model) == before,"Inspection au clavier en combat, sans changement du modèle")
		scene.model.phase = "defeat"; scene._update_interface(); scene._show_run_summary(); key(scene,KEY_6)
		check(scene.selected == 0,"Bilan protégé des sélections derrière le panneau")
		scene._close_run_summary(); scene._reset()
		check(scene.selected == -1 and scene.map_view.selected == -1,"Nouvel essai efface la sélection au clavier")
		scene.free()
	print("SLOT_SHORTCUTS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
