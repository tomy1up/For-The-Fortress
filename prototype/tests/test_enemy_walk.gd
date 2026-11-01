extends SceneTree
const Walk = preload("res://scripts/enemy_walk_art.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var image: Image = Walk.TEXTURE.get_image()
	check(image.detect_alpha() != Image.ALPHA_NONE,"Atlas avec transparence réelle")
	check(Walk.FRAMES.size() == 8,"Huit poses dessinées")
	check(not Walk.supports("enemy.neutral.boar") and not Walk.supports("enemy.horde.warrior"),"Aucune animation attribuée aux autres identités")
	var hashes: Array = []
	for frame in range(8):
		var rect: Rect2 = Walk.FRAMES[frame]
		check(Rect2(Vector2.ZERO,image.get_size()).encloses(rect),"Cadre contenu dans le PNG")
		var target: Rect2 = Walk.destination(frame)
		check(Walk.BOUNDS.encloses(target),"Enveloppe fixe contenant chaque pose")
		check(is_equal_approx(target.size.x/rect.size.x,Walk.SCALE) and is_equal_approx(target.size.y/rect.size.y,Walk.SCALE),"Échelle commune sans étirement ni pompage")
		hashes.append(hash(image.get_region(Rect2i(rect)).get_data()))
	check(hashes.size() == 8 and hashes.all(func(value): return hashes.count(value) == 1),"Huit images distinctes")
	for id in range(5):
		for frame in range(8):
			var distance: float = (frame+0.25)/8.0*Walk.STRIDE
			check(Walk.frame_index(distance,id) == Walk.frame_index(distance+Walk.STRIDE,id),"Boucle continue à distance équivalente")
			check(Walk.frame_index(distance,id) >= 0 and Walk.frame_index(distance,id) < 8,"Indice sûr")
	check(Walk.frame_index(-2,-5) == 0,"Distance et identifiant négatifs bornés")
	check(Walk.frame_index(0.0,0) != Walk.frame_index(0.0,1),"Meute désynchronisée")
	for faction in [0,1]:
		for number in range(1,21):
			var mission: Dictionary = Catalogue.runtime(Catalogue.id_for(number))
			var model := Model.new(true,Model.Maps.for_id(mission.map_id));model.select_faction(faction)
			for distance in [1.0,5.0,model.path_length-0.01]:
				var enemy: Dictionary = Model.make_enemy(4,0,0.0,faction);enemy.distance = distance
				var before: Dictionary = enemy.duplicate(true)
				var bounds: Rect2 = View.enemy_bounds(enemy,faction,model.path_points,model.path_length)
				var facing: float = View.enemy_facing(enemy,model.path_points,model.path_length)
				for frame in range(8):
					var target: Rect2 = Walk.destination(frame)
					if facing < 0: target.position.x = -target.end.x
					var scale: float = View._enemy_scale(enemy)
					check(bounds.encloses(Rect2(View.project(model.point_on_path(distance))+target.position*scale,target.size*scale)),"Survol stable couvrant chaque pose dans les deux factions et sur vingt missions")
				check(enemy == before,"Rendu sans changement de PV, position ou identité")
	print("TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
