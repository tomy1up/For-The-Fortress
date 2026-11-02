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
	check(image.detect_alpha() != Image.ALPHA_NONE,"Peau avec transparence réelle")
	check(Walk.DATA.frames.size()==129 and Walk.DATA.tangents.size()==129,"Courbes continues validées pour le prototype")
	check(not Walk.supports("enemy.neutral.boar") and not Walk.supports("enemy.horde.warrior"),"Aucune animation attribuée aux autres identités")
	check(Walk.sample_vertices(0)==Walk.sample_vertices(1),"Fermeture exacte de la boucle")
	check(Walk.phase_for(-2,-5)==0,"Distance et identifiant négatifs bornés")
	check(Walk.phase_for(0,0)!=Walk.phase_for(0,1),"Meute désynchronisée")
	check(is_equal_approx(Walk.phase_for(7,2,0.7),Walk.phase_for(7+Walk.DATA.stride_pixels*0.7,2,0.7)),"Cadence liée à la distance et à la taille affichée")
	for direction in [Vector2(0.8944272,0.4472136),Vector2(-0.8944272,0.4472136),Vector2(0.8944272,-0.4472136),Vector2(-0.8944272,-0.4472136)]:
		var ground:=Walk.ground_basis(direction)
		var facing: float=-1.0 if direction.x<0 else 1.0
		for phase in [0.0,0.17,0.43,0.79]:
			var flat:=Walk.sample_vertices(phase)
			var oriented:=Walk.sample_vertices(phase,direction)
			var length_error:=0.0;var dot_error:=0.0
			for triangle in range(0,Walk.DATA.indices.size(),3):
				var a: int=Walk.DATA.indices[triangle];var b: int=Walk.DATA.indices[triangle+1];var c: int=Walk.DATA.indices[triangle+2]
				var ab: Vector2=flat[b]-flat[a];var ac: Vector2=flat[c]-flat[a]
				var rotated_ab: Vector2=oriented[b]-oriented[a];var rotated_ac: Vector2=oriented[c]-oriented[a]
				length_error=maxf(length_error,absf(ab.length()-rotated_ab.length()))
				dot_error=maxf(dot_error,absf(ab.dot(ac)-rotated_ab.dot(rotated_ac)))
			check(length_error<0.00002,"Orientation sans étirement des arêtes de la silhouette")
			check(dot_error<0.0002,"Orientation sans cisaillement ni changement d’angle")
		for group in range(4):
			var index: int=Walk.DATA.feet.find(group)
			check(index>=0,"Coussinet représentatif de chaque patte")
			var start: float=[62.0,52.0,34.0,20.0][group]/64.0
			var duty: float=[37.0,39.0,34.0,39.0][group]/64.0
			var first: float=start+duty*0.3;var last: float=start+duty*0.7
			var a: Vector2=Walk.sample_vertices(first,ground)[index]*Vector2(facing*0.7,0.7)+direction*Walk.DATA.stride_pixels*0.7*first
			var b: Vector2=Walk.sample_vertices(last,ground)[index]*Vector2(facing*0.7,0.7)+direction*Walk.DATA.stride_pixels*0.7*last
			check(a.distance_to(b)<0.003,"Appui fixe dans le plan isométrique, dans les deux sens")
	var renderer:=Walk.new()
	var first_mesh: ArrayMesh=renderer.mesh_for(1,0.2)
	check(renderer.mesh_for(1,0.2)==first_mesh,"La pause réutilise la pose sans l’animer")
	check(renderer.mesh_for(2,0.4)!=first_mesh,"Maillages indépendants dans la meute")
	renderer.begin_frame();renderer.mesh_for(2,0.5);renderer.end_frame()
	check(renderer.meshes.size()==1 and renderer.meshes.has(2),"Libération des maillages des ennemis disparus")
	for faction in [0,1]:
		for number in range(1,21):
			var mission: Dictionary = Catalogue.runtime(Catalogue.id_for(number))
			var model := Model.new(true,Model.Maps.for_id(mission.map_id));model.select_faction(faction)
			for distance in [1.0,5.0,model.path_length-0.01]:
				var enemy: Dictionary = Model.make_enemy(4,0,0.0,faction);enemy.distance = distance
				var before: Dictionary = enemy.duplicate(true)
				var bounds: Rect2 = View.enemy_bounds(enemy,faction,model.path_points,model.path_length)
				var facing: float = View.enemy_facing(enemy,model.path_points,model.path_length)
				var motion: Dictionary=Walk.path_motion(distance,model.path_points,View.AXIS)
				check(absf(motion.direction.x)>0.05,"Les vingt missions utilisent les vues isométriques disponibles")
				for frame in range(8):
					var vertices:=Walk.sample_vertices((frame+0.37)/8.0,Walk.ground_basis(motion.direction))
					var enclosed:=true
					for point in vertices:
						if not bounds.has_point(View.project(model.point_on_path(distance))+point*Vector2(facing,1)*View._enemy_scale(enemy)): enclosed=false;break
					check(enclosed,"Survol stable couvrant toute la peau dans les deux factions et sur vingt missions")
				check(enemy == before,"Rendu sans changement de PV, position ou identité")
	print("TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
