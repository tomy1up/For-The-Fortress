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

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var scene = Main.new()
	root.add_child(scene)
	scene.set_process(false)
	check(scene.model.fortress_hp == 20 and not scene.start_button.disabled, "Préparation initiale")
	scene.start_button.pressed.emit()
	check(scene.model.active and scene.start_button.disabled, "Bouton de lancement")
	scene.speed_button.pressed.emit()
	check(scene.speed == 2.0 and scene.speed_button.text == "Vitesse ×2", "Commande ×2")
	scene._process(14.0)
	check(scene.model.arrived and scene.model.fortress_hp == 19, "Arrivée via la boucle à ×2")
	check(scene.status_label.text.contains("aucun or gagné"), "Retour sur l'arrivée")
	scene._process(14.0)
	check(scene.model.fortress_hp == 19, "Pas de second dégât après l'arrivée")
	for i in range(Model.SLOTS.size()):
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		event.position = MapView.project(Model.SLOTS[i])
		scene._unhandled_input(event)
		check(scene.selected == i and scene.details_label.text.begins_with("E%d" % (i + 1)), "Inspection E%d" % (i + 1))
	scene._reset()
	check(scene.speed == 1 and scene.model.elapsed == 0 and scene.model.fortress_hp == 20, "Relance propre")
	check(not scene.start_button.disabled, "Relance disponible")
	scene.start_button.pressed.emit()
	scene._process(28.0)
	check(scene.model.arrived and scene.model.fortress_hp == 19, "Nouvel essai complet")
	print("INTERFACE_TESTS checks=%d failures=%d" % [checks, failures])
	scene.queue_free()
	quit(0 if failures == 0 else 1)
