extends SceneTree
const Art = preload("res://scripts/enemy_art.gd")
const Model = preload("res://scripts/valley_model.gd")
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
	check(Art.TEXTURES.keys() == [0,1,2],"Seuls les trois profils du lot utilisent les nouveaux PNG")
	for type in [0,1,2]:
		var image: Image = Art.TEXTURES[type].get_image()
		check(not image.is_empty() and image.detect_alpha() != Image.ALPHA_NONE,"Canal alpha réel pour chaque ennemi illustré")
		check(image.get_pixel(0,0).a < 0.01 and image.get_pixel(image.get_width()-1,image.get_height()-1).a < 0.01,"Absence de fond opaque")
		check(Rect2(Vector2.ZERO,image.get_size()).encloses(Art.FRAMES[type].source),"Cadre de dessin contenu dans le PNG")
		var target: Rect2 = Art.destination(type)
		check(target.end.y == 0.0 and target.position.x < 0.0 and target.end.x > 0.0,"Ancrage des pieds sur la position de l’ennemi")
		check(is_equal_approx(target.size.x/target.size.y,Art.FRAMES[type].source.size.x/Art.FRAMES[type].source.size.y),"Illustration sans étirement")
		for distance in [1.0,5.0]:
			var enemy: Dictionary = Model.make_enemy(type,type,0.0);enemy.distance = distance
			var before: Dictionary = enemy.duplicate(true)
			var rect: Rect2 = target
			if View.enemy_facing(enemy) < 0.0: rect.position.x = -rect.end.x
			var scale: float = View._enemy_scale(enemy)
			var rendered := Rect2(View.project(Model.position_at(distance))+rect.position*scale,rect.size*scale)
			check(View.enemy_bounds(enemy).encloses(rendered),"Le survol inclut l’illustration entière dans les deux sens")
			check(enemy == before,"Calcul du survol sans déplacer ou modifier l’ennemi")
	check(Art.destination(0).size.y*0.7 < Art.destination(2).size.y*0.85 and Art.destination(2).size.y*0.85 < Art.destination(1).size.y,"Tailles relatives Grouillant, Sprinter et Pillard conservées")
	for pair in [[0.0,1.0],[1.0,1.0],[5.0,-1.0],[9.0,1.0],[14.0,1.0],[18.0,1.0],[23.0,-1.0],[27.0,1.0],[28.0,1.0]]:
		check(View.enemy_facing({"distance":pair[0]}) == pair[1],"Orientation selon le vrai chemin, y compris à l’entrée et à la forteresse")
	for type in range(3,8):
		var enemy: Dictionary = Model.make_enemy(type,type,0.0);enemy.distance = 10.0
		var scale: float = View._enemy_scale(enemy);var width: float = maxf(28,32*scale)
		check(View.enemy_bounds(enemy) == Rect2(View.project(Model.position_at(10.0))+Vector2(-width/2,-39*scale),Vector2(width,47*scale)),"Les cinq profils procéduraux conservent leur zone de survol")
	check(Art.tint(0.0) == Color.WHITE and Art.tint(1.0).a == 1.0 and Art.tint(1.0).r > 1.0,"Réaction aux dégâts : gain de luminosité sans opacifier le fond")
	check(Art.tint(-1.0) == Art.tint(0.0) and Art.tint(2.0) == Art.tint(1.0),"Intensité de réaction bornée")
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(0)
	scene.model.phase = "combat";scene.model.elapsed = 1.0
	for type in range(8):
		var enemy: Dictionary = Model.make_enemy(type,type,0.0);enemy.distance = 1.0+type*3.0
		scene.model.enemies.append(enemy)
		scene.model.damage_events.append({"time":1.0,"enemy_id":type,"hp_before":enemy.hp,"hp_after":enemy.hp*0.8})
	scene.map_view.inspected_enemy_id = 1
	scene.model.curses.append({"enemy_id":2})
	var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.damage_events,scene.model.curses])
	for frame in range(3):scene.map_view.queue_redraw();await process_frame
	check(JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.damage_events,scene.model.curses]) == before,"Dessiner les huit profils, dégâts et malédictions ne change ni modèle ni RNG")
	scene.queue_free();await process_frame
	print("ENEMY_ART_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
