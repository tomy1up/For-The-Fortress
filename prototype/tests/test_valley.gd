extends SceneTree

const Model = preload("res://scripts/valley_model.gd")
var failures: int = 0
var checks: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var total: float = 0.0
	for i in range(Model.PATH_POINTS.size() - 1):
		total += Model.PATH_POINTS[i].distance_to(Model.PATH_POINTS[i + 1])
	check(is_equal_approx(total, 28.0), "Le chemin doit mesurer 28 unités")
	check(Model.SLOTS.size() == 6, "Six emplacements")
	var distances: Array[float] = [0, 4, 8, 13, 17, 22, 25, 28]
	for i in range(distances.size()):
		check(Model.position_at(distances[i]).is_equal_approx(Model.PATH_POINTS[i]), "Virage %d" % i)
	check(Model.position_at(-1) == Model.PATH_POINTS[0], "Borne initiale")
	check(Model.position_at(40) == Model.PATH_POINTS[-1], "Borne finale")
	var model = Model.new()
	model.advance(40)
	check(model.distance == 0 and model.fortress_hp == 20, "Préparation immobile")
	model.start()
	model.advance(27.5)
	check(model.active and not model.arrived and model.fortress_hp == 20, "Aucun dégât avant arrivée")
	model.advance(0.5)
	check(model.arrived and not model.active and model.fortress_hp == 19, "Arrivée à 28 s, moins 1 PV")
	check(model.gold == 150, "Aucune récompense à l'arrivée")
	model.advance(100)
	model.start()
	model.advance(100)
	check(model.fortress_hp == 19, "Une arrivée ne doit pas se répéter")
	model.reset()
	check(model.fortress_hp == 20 and model.gold == 150 and not model.arrived and model.elapsed == 0, "Réinitialisation complète")
	model.start()
	model.advance(30)
	check(model.elapsed == 28 and model.fortress_hp == 19, "Grand pas franchissant l'arrivée")
	var normal = Model.new()
	var accelerated = Model.new()
	normal.start()
	accelerated.start()
	for i in range(1680):
		normal.advance(1.0 / 60.0)
	for i in range(840):
		accelerated.advance(2.0 / 60.0)
	check(normal.arrived and accelerated.arrived, "Arrivée à ×1 et ×2")
	check(normal.fortress_hp == accelerated.fortress_hp and normal.gold == accelerated.gold, "Même résultat aux deux vitesses")
	print("VALLEY_TESTS checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)
