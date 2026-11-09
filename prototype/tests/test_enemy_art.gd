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
	check(Art.TEXTURES.size() == 15 and Art.TEXTURES.has("enemy.neutral.drowned"),"Quinze identités : cinq neutres, dont le Noyé en attente de visuel, et cinq par camp")
	for id in Art.TEXTURES:
		var image: Image = Art.TEXTURES[id].get_image()
		check(not image.is_empty() and image.detect_alpha() != Image.ALPHA_NONE,"Canal alpha réel pour chaque ennemi illustré")
		check(image.get_pixel(0,0).a < 0.01 and image.get_pixel(image.get_width()-1,image.get_height()-1).a < 0.01,"Absence de fond opaque")
		check(Rect2(Vector2.ZERO,image.get_size()).encloses(Art.FRAMES[id].source),"Cadre de dessin contenu dans le PNG")
		var target: Rect2 = Art.destination(id)
		check(target.end.y == 0.0 and target.position.x < 0.0 and target.end.x > 0.0,"Ancrage des pieds sur la position de l’ennemi")
		check(is_equal_approx(target.size.x/target.size.y,Art.FRAMES[id].source.size.x/Art.FRAMES[id].source.size.y),"Illustration sans étirement")
		for distance in [1.0,5.0]:
			var identity: Dictionary = {}
			var defending: int = 0
			for faction in [0,1]:
				var candidate: Dictionary = Model.Enemies.by_id(id,faction)
				if not candidate.is_empty(): identity = candidate;defending = faction;break
			var enemy: Dictionary = Model.make_enemy(0,identity.profile,0.0,defending);enemy.distance = distance
			var before: Dictionary = enemy.duplicate(true)
			var rect: Rect2 = target
			if View.enemy_facing(enemy) < 0.0: rect.position.x = -rect.end.x
			var scale: float = View._enemy_scale(enemy)
			var rendered := Rect2(View.project(Model.position_at(distance))+rect.position*scale,rect.size*scale)
			check(View.enemy_bounds(enemy,defending).encloses(rendered),"Le survol inclut l’illustration entière dans les deux sens")
			check(enemy == before,"Calcul du survol sans déplacer ou modifier l’ennemi")
	check(Art.destination("enemy.neutral.wolf").size.y*0.7 < Art.destination("enemy.neutral.boar").size.y*0.85 and Art.destination("enemy.neutral.boar").size.y*0.85 < Art.destination("enemy.horde.warrior").size.y,"Tailles relatives Grouillant, Sprinter et Pillard conservées")
	for pair in [[0.0,1.0],[1.0,1.0],[5.0,-1.0],[9.0,1.0],[14.0,1.0],[18.0,1.0],[23.0,-1.0],[27.0,1.0],[28.0,1.0]]:
		check(View.enemy_facing({"distance":pair[0]}) == pair[1],"Orientation selon le vrai chemin, y compris à l’entrée et à la forteresse")
	for pair in [[3.999,1.0],[4.0,-1.0],[4.001,-1.0],[7.999,-1.0],[8.0,1.0]]:
		check(View.enemy_facing({"distance":pair[0]}) == pair[1],"Le sprite se retourne au virage et suit le segment emprunté")
	# Deux silhouettes d’un même atlas ne doivent pas inclure les pixels du voisin.
	for a in Art.TEXTURES:
		for b in Art.TEXTURES:
			if a >= b or Art.TEXTURES[a] != Art.TEXTURES[b] or "enemy.neutral.drowned" in [a,b]: continue # Le Noyé partage provisoirement la silhouette de la tortue.
			check(not Art.FRAMES[a].source.intersects(Art.FRAMES[b].source),"Cadres des personnages disjoints dans chaque atlas")
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
