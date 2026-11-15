extends SceneTree
const Art = preload("res://scripts/horde_art.gd")
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
func run_checks() -> void:
	check(Art.TEXTURES.size() == 3 and not Art.TEXTURES.has(0) and not Art.TEXTURES.has(1) and not Art.TEXTURES.has(2),"Assets réservés aux trois classes Horde")
	for type in [3,4,5]:
		var image: Image = Art.TEXTURES[type].get_image()
		check(not image.is_empty() and image.detect_alpha() != Image.ALPHA_NONE,"Un vrai canal alpha est chargé pour chaque silhouette")
		check(image.get_pixel(0,0).a == 0.0 and image.get_pixel(image.get_width()-1,image.get_height()-1).a == 0.0,"Coins transparents, sans fond opaque")
		var frame: Dictionary = Art.FRAMES[type]
		check(Rect2(Vector2.ZERO,image.get_size()).encloses(frame.source),"Cadre de dessin contenu dans le PNG")
		var target: Rect2 = Art.destination(type)
		check(is_equal_approx(target.end.y,0.0) and target.has_area() and target.position.x < 0.0 and target.end.x > 0.0,"Pieds ancrés au sol, silhouette de part et d’autre de l’emplacement")
		check(is_equal_approx(target.size.x/target.size.y,frame.source.size.x/frame.source.size.y),"Proportions de la planche conservées sans étirement")
		# Le chaman orc est animé depuis sa garde de 90 px (v0.211) : son crâne de bâton dépasse du sprite fixe de remplacement.
		check(target.grow(8 if type != 5 else 40).has_point(Art.MUZZLES[type]),"Départ des projectiles près de l’équipement visible")
	check(Art.destination(4).size.y < Art.destination(3).size.y and Art.destination(4).size.y < Art.destination(5).size.y,"Gobelin plus petit que le troll et le chaman")
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(1);scene.model.gold = 10000
	for slot in range(6):
		scene.model.buy(slot,3+slot%3)
		for step in range([1,2,3,4,4,4][slot]-1):scene.model.upgrade(slot,slot%2 if step == 2 else -1)
	var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders])
	for frame in range(3):scene.map_view.queue_redraw();await process_frame
	check(JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders]) == before,"Afficher les six silhouettes et leurs badges ne change ni modèle ni RNG")
	scene.queue_free();await process_frame
	print("HORDE_ART_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
