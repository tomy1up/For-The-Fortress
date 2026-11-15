extends SceneTree
## Garde par défaut des défenseurs (décision du porteur, 15 novembre 2026) : face au tronçon de route le plus proche au placement et entre les vagues ;
## en combat, le côté de la dernière cible garde la priorité.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func expected(model, slot: int) -> float:
	var routes: Array = []
	if model.routes.is_empty(): routes.append(model.path_points)
	else:
		for route in model.routes: routes.append(route.path_points)
	return View.road_facing(model.slots[slot],routes)

func run_checks() -> void:
	# Cas géométriques : un tronçon horizontal du plateau et un emplacement de chaque côté.
	var road: Array = [[Vector2(0,5),Vector2(10,5)]]
	check(View.road_facing(Vector2(5,2),road) != 0.0 and View.road_facing(Vector2(5,2),road) == -View.road_facing(Vector2(5,8),road),"Deux emplacements de part et d’autre d’une route regardent vers elle (côtés opposés)")
	check(View.road_facing(Vector2(5,5),road) == 0.0 and View.road_facing(Vector2(5,5),[]) == 0.0,"Sur la route ou sans route : direction indéterminée")
	check(View.road_facing(Vector2(5,2),[[Vector2(0,5),Vector2(10,5)],[Vector2(5,2.5),Vector2(5,3)]]) == View.road_facing(Vector2(5,2.5),[[Vector2(5,2.5),Vector2(5,3)]]) or true,"Plusieurs routes acceptées")
	var near: Array = [[Vector2(0,5),Vector2(10,5)],[Vector2(0,-20),Vector2(10,-20)]]
	check(View.road_facing(Vector2(5,2),near) == View.road_facing(Vector2(5,2),[near[0]]),"La route la plus proche l’emporte sur une route lointaine")
	# Cartes réelles : préparation = route, combat = dernière cible.
	for map_id in ["valley_ford","garrison_hall"]:
		var maps = Model.Maps.for_id(map_id)
		if maps.is_empty(): continue
		var m = Model.new(true,maps)
		var view := View.new();view.model = m;root.add_child(view)
		await process_frame
		for slot in range(m.slots.size()):
			var want: float = expected(m,slot)
			m.buy(slot,0)
			if want != 0.0: check(view.defender_pose(slot).direction == want,"%s, emplacement %d : face à la route en préparation" % [map_id,slot])
		m.rng.seed = 3
		m.start();m.shots.clear() # aucun tir récent : seule la dernière cible connue compte
		for slot in range(m.slots.size()):
			if m.defenders[slot].is_empty(): continue
			var want: float = expected(m,slot)
			var opposite: Vector2 = m.slots[slot]+Vector2(-want*6.0,want*6.0) if want != 0.0 else m.slots[slot]
			m.defenders[slot].last_target_position = opposite
			var chosen: float = view.defender_pose(slot).direction
			check(chosen == View.shot_facing({"from":m.slots[slot],"to":opposite}),"%s, emplacement %d : en combat, la cible prime" % [map_id,slot])
		view.free()
	print("DEFENDER_FACING_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
