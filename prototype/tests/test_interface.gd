extends SceneTree

const Main = preload("res://scripts/main.gd")
const MapView = preload("res://scripts/valley_view.gd")
const Model = preload("res://scripts/valley_model.gd")
var failures: int = 0
var checks: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func select_slot(scene: Node, slot: int) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = MapView.project(Model.SLOTS[slot])
	scene._unhandled_input(event)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var scene = Main.new()
	root.add_child(scene)
	scene.set_process(false)
	scene.model.synergies_enabled = false
	check(scene.choosing_faction and scene.faction_panel.visible and scene.start_button.disabled, "Choix de faction obligatoire")
	scene.faction_buttons[0].pressed.emit()
	check(scene.model.fortress_hp == 20 and scene.model.gold == 150 and not scene.start_button.disabled, "Préparation initiale")
	check(scene.buy_buttons.size() == 3 and scene.buy_buttons[0].disabled, "Choix d'emplacement obligatoire")
	for i in range(Model.SLOTS.size()):
		select_slot(scene, i)
		check(scene.selected == i and scene.title_label.text.begins_with("E%d" % (i + 1)), "Inspection E%d" % (i + 1))
	select_slot(scene, 0)
	check(not scene.buy_buttons[0].disabled and scene.buy_buttons[0].visible, "Boutique disponible")
	check(scene.details_label.text.contains("Un défenseur par emplacement") and scene.details_label.text.contains("comparer"), "Emplacement libre explique le recrutement")
	scene.buy_buttons[0].pressed.emit()
	check(scene.model.gold == 100 and scene.model.count_type(0) == 1, "Achat par le bouton")
	check(scene.sell_button.visible and not scene.buy_buttons[0].visible and scene.sell_button.text.contains("35"), "Remboursement visible avant vente")
	scene.sell_button.pressed.emit()
	check(scene.model.gold == 135 and scene.model.defenders[0].is_empty() and scene.buy_buttons[0].visible, "Vente et retour à la boutique")
	scene.buy_buttons[1].pressed.emit()
	check(scene.model.gold == 60 and scene.sell_button.text.contains("52"), "Arbalétrier et arrondi de vente")
	check(scene.details_label.text.contains("Dégâts : 24") and scene.details_label.text.contains("Intervalle : 2,5 s"), "Statistiques affichées correctement")
	select_slot(scene, 1)
	check(scene.buy_buttons[1].disabled and scene.buy_buttons[1].tooltip_text.contains("Achat impossible : Or insuffisant."), "Motif d'achat impossible")
	scene.buy_buttons[0].pressed.emit()
	check(scene.model.gold == 10 and scene.gold_label.text.contains("10"), "Or affiché après achat")
	scene.start_button.pressed.emit()
	check(scene.model.active and scene.start_button.disabled and scene.reset_button.disabled, "Lancement et commandes de relance bloquées")
	check(scene.sell_button.disabled, "Vente bloquée en combat")
	var before_gold: int = scene.model.gold
	scene.sell_button.pressed.emit()
	scene._reset()
	check(scene.model.gold == before_gold and scene.model.count_type(0) == 1 and scene.model.active, "Actions forcées sans effet en combat")
	select_slot(scene, 2)
	check(scene.buy_buttons[0].disabled and scene.buy_buttons[0].tooltip_text.contains("entre les vagues"), "Boutique verrouillée pendant la vague")
	scene.buy_buttons[0].pressed.emit()
	check(scene.model.defenders[2].is_empty(), "Pas de construction en combat")
	scene.speed_button.pressed.emit()
	check(scene.speed == 2.0 and scene.speed_button.text == "Vitesse ×2", "Commande de vitesse")
	scene._process(50)
	check(scene.model.phase == "finished" and scene.status_label.text.contains("terminée"), "Retour de fin de vague")
	check(scene.model.killed == 10 and scene.model.escaped == 0 and scene.hp_label.text.contains("20 / 20"), "Première composition gagnante contre les dix Pillards")
	check(scene.model.gold == 40 and scene.gold_label.text.contains("40"), "Récompenses affichées, sans prime de vague")
	select_slot(scene, 0)
	check(not scene.sell_button.disabled and not scene.start_button.disabled and not scene.reset_button.disabled, "Préparation suivante disponible après vague")
	scene.reset_button.pressed.emit()
	check(scene.speed == 1 and scene.model.phase == "preparation" and scene.model.gold == 150 and scene.model.fortress_hp == 20, "Nouvel essai propre")
	check(scene.selected == -1 and scene.model.count_type(0) == 0 and scene.model.count_type(1) == 0, "Défense et sélection réinitialisées")
	scene.faction_buttons[0].pressed.emit()
	select_slot(scene, 5)
	scene.buy_buttons[2].pressed.emit()
	check(scene.details_label.text.contains("10,8") and scene.model.gold == 50, "Description des dégâts secondaires du mage")
	scene._reset()
	check(scene.choosing_faction and scene.faction_panel.visible, "Nouvel essai : retour au choix de faction")
	scene.faction_buttons[1].pressed.emit()
	check(scene.model.faction == 1 and not scene.choosing_faction and scene.faction_label.text.contains("HORDE"), "Sélection de la Horde")
	select_slot(scene, 0)
	check(scene.buy_buttons[0].text.contains("haches") and scene.buy_buttons[2].text.contains("Chaman"), "Boutique propre à la faction")
	scene.buy_buttons[2].pressed.emit()
	check(scene.model.defenders[0].type == 5 and scene.details_label.text.contains("4,8"), "Achat et description du chaman")
	scene._choose_faction(0)
	check(scene.model.faction == 1, "Pas de changement de faction après sélection")
	scene.start_button.pressed.emit()
	scene._process(1)
	check(scene.model.curses.size() > 0 and scene.model.enemies.size() > 0, "Malédiction visible dans la boucle réelle")
	print("INTERFACE_TESTS checks=%d failures=%d" % [checks, failures])
	scene.queue_free()
	quit(0 if failures == 0 else 1)
