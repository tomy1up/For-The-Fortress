extends SceneTree
const View = preload("res://scripts/valley_view.gd")
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var alliance: Dictionary = View.fortress_style(0);var horde: Dictionary = View.fortress_style(1)
	check(alliance.flag.b > alliance.flag.r and horde.flag.r > horde.flag.b,"Bannières bleue et rouge propres aux deux camps")
	check(alliance.wall != horde.wall and alliance.roof != horde.roof,"Matériaux et toitures visuellement distincts")
	check(View.fortress_style(-1) == alliance,"Vue sans camp choisi : référence Alliance déterminée")
	alliance.flag = Color.BLACK;check(View.fortress_style(0).flag != Color.BLACK,"Une palette lue n'altère pas la suivante")
	var anchor: Vector2 = View.project(Model.PATH_POINTS[-1])
	check(View.fortress_center(anchor) == anchor+Vector2(52,26),"Centre de dessin conservé dans la cour")
	check(not View.fortress_bounds(anchor).has_point(View.project(Model.SLOTS[5])),"Silhouette du bâtiment séparée du centre E6")
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),Model.PATH_POINTS,Model.SLOTS])
		for delta in [0.0,0.4,2.0,1000.0]:
			scene.map_view._process(delta);scene.map_view.queue_redraw();await process_frame
			check(is_finite(scene.map_view.flag_phase) and scene.map_view.flag_phase >= 0 and scene.map_view.flag_phase < TAU,"Mouvement décoratif borné sans accumulation de temps")
			check(before == JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),Model.PATH_POINTS,Model.SLOTS]),"Animation sans mutation du modèle, de l'or, du RNG ou des positions")
		var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true;click.position = View.project(Model.SLOTS[5]);scene._unhandled_input(click)
		check(scene.selected == 5 and scene.model.buy(5,faction*3),"E6 reste sélectionnable et constructible dans les deux camps")
		check(scene.model.fortress_hp == 20 and scene.model.max_hp == 20 and Model.position_at(Model.PATH_LENGTH) == Vector2(17,6),"PV et point d'arrivée inchangés")
		scene.free()
	print("FORTRESS_IDENTITY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
