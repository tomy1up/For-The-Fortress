extends SceneTree
const Art = preload("res://scripts/alliance_art.gd")
const Horde = preload("res://scripts/horde_art.gd")
const View = preload("res://scripts/valley_view.gd")
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
	check(Art.TEXTURES.size() == 3 and not Art.TEXTURES.has(3) and not Art.TEXTURES.has(4) and not Art.TEXTURES.has(5),"Assets réservés aux trois classes Alliance")
	check(not Horde.TEXTURES.has(0) and not Horde.TEXTURES.has(1) and not Horde.TEXTURES.has(2),"Les ressources des deux factions restent disjointes")
	for type in [0,1,2]:
		var image: Image = Art.TEXTURES[type].get_image()
		check(not image.is_empty() and image.detect_alpha() != Image.ALPHA_NONE,"Vrai canal alpha pour chaque classe Alliance")
		check(image.get_pixel(0,0).a < 0.01 and image.get_pixel(image.get_width()-1,image.get_height()-1).a < 0.01,"Coins transparents, sans fond opaque")
		var frame: Dictionary = Art.FRAMES[type]
		check(Rect2(Vector2.ZERO,image.get_size()).encloses(frame.source),"Cadre de dessin contenu dans le PNG")
		var target: Rect2 = Art.destination(type)
		check(is_equal_approx(target.end.y,0.0) and target.has_area() and target.position.x < 0.0 and target.end.x > 0.0,"Pieds ancrés au sol sans décentrer le défenseur")
		check(is_equal_approx(target.size.x/target.size.y,frame.source.size.x/frame.source.size.y),"Image affichée sans étirement")
		check(target.grow(8).has_point(Art.MUZZLES[type]),"Départ des projectiles près de l’arme visible")
		var shot: Dictionary = {"type":type,"from":Vector2(2,6)}
		check(View.shot_origin(shot).is_equal_approx(View.project(shot.from)+Art.MUZZLES[type]),"Le rendu du tir utilise le point d’équipement de la bonne classe")
	check(Art.destination(1).size.y < Art.destination(0).size.y and Art.destination(1).size.y < Art.destination(2).size.y,"Nain plus petit que l’elfe et le mage")
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(0);scene.model.gold = 10000
	for slot in range(6):
		scene.model.buy(slot,slot%3)
		for step in range([1,2,3,4,4,4][slot]-1):scene.model.upgrade(slot,slot%2 if step == 2 else -1)
	var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders])
	for frame in range(3):scene.map_view.queue_redraw();await process_frame
	check(JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders]) == before,"Afficher les six unités et badges ne change ni modèle ni RNG")
	scene.queue_free();await process_frame
	print("ALLIANCE_ART_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
