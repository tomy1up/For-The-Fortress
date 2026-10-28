extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Maps = Model.Maps
const View = preload("res://scripts/valley_view.gd")
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
static func synthetic() -> Dictionary:
	var data: Dictionary = Maps.valley()
	data.id = "test_straight";data.title = "Carte synthétique (test)"
	data.path_points = [Vector2(0,3),Vector2(8,3)];data.path_length = 8.0
	data.slots = [Vector2(1,1),Vector2(2,5),Vector2(4,1),Vector2(5,5),Vector2(6,1),Vector2(7,5)]
	data.trees = [];data.decoration = "none"
	return data
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var original: Dictionary = synthetic()
	var model = Model.new(true,original)
	check(Maps.validation_error(Maps.valley()).is_empty() and model.map_error.is_empty(),"Cartes de référence valides")
	check(Maps.measured_length(Model.PATH_POINTS) == 28.0 and model.path_length == 8.0,"Longueurs mesurées du Gué et de la carte synthétique")
	original.slots[0] = Vector2.ZERO;original.path_points[1] = Vector2(10,3);original.title = "modifié"
	check(model.slots[0] == Vector2(1,1) and model.point_on_path(100) == Vector2(8,3) and model.map_definition.title != original.title,"Le modèle possède sa copie et ne suit pas les modifications de l'appelant")
	var another = Model.new(true,synthetic());another.slots[0] = Vector2.ZERO
	check(model.slots[0] == Vector2(1,1),"Deux parties ne partagent pas leurs emplacements")
	for distance in [-1.0,0.0,2.0,6.0,8.0,100.0]:
		check(model.point_on_path(distance) == Vector2(clampf(distance,0,8),3),"Position bornée sur le vrai chemin")
	var route: Array[Vector2] = [Vector2(8,2),Vector2(3,2),Vector2(3,6)]
	check(Model.position_at(6,route,9) == Vector2(3,3),"Position après un virage sur une géométrie différente")
	check(View.enemy_facing({"distance":1},route,9) == -1.0,"Orientation sur un segment allant vers la gauche")
	check(Model.separation_squared(1,6,route,9) == 17.0,"Distances secondaires sur la géométrie fournie")
	check(model.select_faction(0) and model.buy(0,0),"Recrutement sur la carte synthétique")
	var expected: Array[Dictionary] = Model.coverage_windows(model.slots[0],4,model.path_points)
	check(model.defenders[0].windows == expected and expected != Model.coverage_windows(model.slots[0],4),"Couverture calculée sur le tracé de cette partie")
	model.gold = 500;model.upgrade(0)
	check(model.defenders[0].windows == Model.coverage_windows(model.slots[0],model.get_stats(0).range,model.path_points),"Amélioration : recalcul sur le bon tracé")
	var sections = View.covered_route(model.slots[0],4,model.path_points,model.path_length)
	check(sections.size() == 1 and sections[0][0] == View.project(model.point_on_path(expected[0].first)) and sections[0][-1] == View.project(model.point_on_path(expected[0].last)),"Portée dessinée conforme aux fenêtres du combat")
	model.reset();check(model.path_length == 8 and model.slots[0] == Vector2(1,1) and model.defenders[0].is_empty(),"Reset conserve la carte en vidant la partie")
	model.select_faction(1);model.start();model.advance(8)
	check(model.escaped == 1 and model.fortress_hp == 19,"Arrivée à 8 secondes, pas à 28")
	model.advance(100);check(model.phase == "finished" and model.escaped == 10,"Tous les ennemis suivent la longueur de la carte")
	while model.phase not in ["victory","defeat"]:
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if model.phase == "finished": model.prepare_next_wave()
		model.start();model.advance(10000)
	var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
	check(report.has("map_definition") and Replay.verify(report).ok,"Rapport synthétique complet rejouable sans profil utilisateur")
	var tampered: Dictionary = report.duplicate(true);tampered.map_definition.path_length = 28
	check(not Replay.verify(tampered).ok,"Rapport : longueur falsifiée rejetée")
	tampered = report.duplicate(true);tampered.erase("map_definition")
	check(not Replay.verify(tampered).ok,"Rapport synthétique sans sa carte ne peut être rejoué comme le Gué")
	check(not Report.build(Model.new()).has("map_definition"),"Format historique du Gué inchangé")
	for data in [Maps.valley(),synthetic()]:
		check(Maps.from_data(JSON.parse_string(JSON.stringify(Maps.to_data(data)))) == data,"Aller-retour JSON exact de la définition")
	var invalid: Array[Dictionary] = []
	for key in synthetic():
		var data: Dictionary = synthetic();data.erase(key);invalid.append(data)
	for change in [{"id":""},{"title":3},{"size":Vector2i(0,10)},{"size":Vector2i(65,10)},{"path_points":[]},{"path_points":[Vector2.ZERO,Vector2.ZERO]},{"slots":[]},{"slots":[Vector2.ZERO,Vector2.ZERO,Vector2.ONE,Vector2(2,2),Vector2(3,3),Vector2(4,4)]},{"trees":[Vector2(INF,0)]},{"trees":[Vector2(-1,0)]},{"path_length":INF},{"path_length":0},{"decoration":"unknown"}]:
		var data: Dictionary = synthetic();data.merge(change,true);invalid.append(data)
	var near_zero: Dictionary = synthetic();near_zero.path_points = [Vector2.ZERO,Vector2(0.0000001,0)];near_zero.path_length = 0.0;invalid.append(near_zero)
	for data in invalid:
		check(not Maps.validation_error(data).is_empty(),"Définition incomplète ou incohérente refusée")
		var rejected = Model.new(true,data)
		check(rejected.phase == "invalid_map" and not rejected.can_build() and not rejected.start() and not rejected.select_faction(0),"Carte invalide : partie et achats bloqués")
		rejected.reset();check(rejected.phase == "invalid_map","Reset ne débloque pas une carte invalide")
	for change in [{"size":[18.5,10]},{"size":[true,10]},{"path_points":[[0,3],["8",3]]},{"slots":"invalid"},{"path_length":28},{"path_points":[[0,3],[8,3,4]]}]:
		var data: Dictionary = Maps.to_data(synthetic());data.merge(change,true)
		check(Maps.from_data(data).is_empty(),"JSON de carte mal formé rejeté")
	for faction in range(2):
		var scene = Main.new();scene.model = Model.new(true,synthetic());root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		for slot in range(6):
			var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true;click.position = View.project(scene.model.slots[slot]);scene._unhandled_input(click)
			check(scene.selected == slot,"Clic au bon emplacement sur la nouvelle géométrie")
			scene.buy_buttons[0].mouse_entered.emit()
			check(scene.map_view.purchase_ghost().point == click.position,"Silhouette sur le même emplacement que le clic et la portée")
			scene.map_view.queue_redraw();await process_frame
		check(get_root().get_window().title.contains("Carte synthétique"),"Titre de fenêtre lié à la carte sans modifier le nom du profil")
		scene.model.start();scene.model.advance(5)
		var enemy: Dictionary = scene.model.enemies[0]
		var point: Vector2 = View.enemy_bounds(enemy,faction,scene.model.path_points,scene.model.path_length).get_center()
		check(scene.map_view.enemy_at(point) == enemy.id,"Inspection de l'ennemi sur son vrai tracé")
		scene.free()
	print("MAP_DEFINITION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
