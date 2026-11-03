extends SceneTree
## Isolated real-route rendering: no Main scene, profile, rewards or campaign progress.
const Study=preload("render_study.gd")
const RoutesStudy=preload("render_routes.gd")
const Model=preload("res://scripts/valley_model.gd")
const View=preload("res://scripts/valley_view.gd")
const Walk=preload("res://scripts/enemy_walk_art.gd")

class AnimatedView extends View:
	var layers: Array[Study.Surface]=[]
	var mesh_cache: Dictionary={}
	var sampled: Array=[]
	func _draw_pillager(center: Vector2,enemy: Dictionary,hit_strength: float=0.0,pose: Dictionary={}) -> void:
		if enemy.type!=2:
			super._draw_pillager(center,enemy,hit_strength,pose);return
		var motion: Dictionary=Walk.path_motion(enemy.distance,model.enemy_route_points(enemy),AXIS)
		var phase: float=fposmod(motion.travel/(Study.PROFILE_SCALE*700.0)+enemy.id*0.137,1.0)
		var transform: Transform2D=RoutesStudy.placement(motion.direction,Study.PROFILE_SCALE,center,pose)
		draw_set_transform(center);draw_circle(Vector2(0,3),9,Color(0,0,0,0.25),true,-1,true)
		draw_set_transform_matrix(transform)
		var entry: Dictionary=mesh_cache.get(enemy.id,{})
		if entry.is_empty() or entry.phase!=phase:
			var meshes: Array[ArrayMesh]=[]
			for surface in layers:
				surface.phase=phase
				var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
				arrays[Mesh.ARRAY_VERTEX]=surface.sampled_vertices()
				var uv:=PackedVector2Array();var indices:=PackedInt32Array()
				for point in surface.data.points: uv.append(Vector2(point[0],point[1])/surface.texture.get_size())
				for index in range(surface.data.triangles.size()):
					if surface.far_layer and not surface.visible_faces.has(index): continue
					indices.append_array(PackedInt32Array(surface.data.triangles[index]))
				arrays[Mesh.ARRAY_TEX_UV]=uv;arrays[Mesh.ARRAY_INDEX]=indices
				var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);meshes.append(mesh)
			entry={"phase":phase,"meshes":meshes};mesh_cache[enemy.id]=entry
		for index in range(layers.size()):
			var tint:=Color(0.65,0.65,0.65,1) if layers[index].far_layer else Color.WHITE
			draw_mesh(entry.meshes[index],layers[index].texture,Transform2D.IDENTITY,tint*EnemyArt.tint(hit_strength))
		draw_set_transform(Vector2.ZERO)
		sampled.append({"id":enemy.id,"distance":enemy.distance,"time":model.elapsed,"spawn":enemy.spawn_time,"speed":enemy.speed,"phase":phase,"travel":motion.travel,"direction":[motion.direction.x,motion.direction.y],"anchor":[center.x,center.y],"basis":[[transform.x.x,transform.x.y],[transform.y.x,transform.y.y]],"reaction":pose.strength,"hp":enemy.hp})

class Display extends Node2D:
	var viewport: SubViewport
	var model: RefCounted
	var focus:=Vector2(640,300)
	var speed:=1.0
	var time:=0.0
	func _draw() -> void:
		draw_texture_rect(viewport.get_texture(),Rect2(0,0,1280,800),false)
		var font: Font=ThemeDB.fallback_font
		draw_string(font,Vector2(24,40),"Sanglier · Essai sur le tracé du Gué",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("e0dbbf"))
		draw_string(font,Vector2(24,72),"Animation non approuvée · Traversée contrôlée · Aucun profil joueur",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("abc0b0"))
		var labels: Array[String]=["Alliance" if model.faction==0 else "Horde","Trois sangliers de contrôle","PV : 24 au départ","Vitesse : ×%s"%str(speed).trim_suffix(".0"),"Pause" if speed==0 else "Marche liée au déplacement","Impact imposé au début","Aucun défenseur ne tire"]
		for index in range(labels.size()): draw_string(font,Vector2(24,130+index*28),labels[index],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("abc0b0"))
		draw_string(font,Vector2(24,378),"Agrandissement ×3 du même rendu",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e0dbbf"))
		draw_rect(Rect2(24,390,330,222),Color("0b1915"))
		draw_texture_rect_region(viewport.get_texture(),Rect2(24,390,330,222),Rect2(focus-Vector2(55,52),Vector2(110,74)))
		draw_rect(Rect2(24,390,330,222),Color("58715f"),false,1)
		draw_string(font,Vector2(24,658),"Les virages utilisent le profil orienté sans étirement.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e0dbbf"))
		draw_string(font,Vector2(24,690),"Sens opposés : miroir du profil. Pas de dessin frontal inventé.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("abc0b0"))
		draw_string(font,Vector2(24,754),"Essai hors campagne · %d / 720 images"%int(time*60+1),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("abc0b0"))

func _initialize() -> void: call_deferred("record")
func record() -> void:
	root.size=Vector2i(1280,800);root.content_scale_size=Vector2i(1280,800)
	root.title="For the Fortress! — Sanglier sur le Gué — Essai isolé"
	var folder: String=get_script().resource_path.get_base_dir();var camp:=0
	for argument in OS.get_cmdline_user_args():
		if argument=="--horde": camp=1
	var suffix: String="alliance" if camp==0 else "horde"
	var directory: String=folder.path_join("captures/context_"+suffix)
	DirAccess.make_dir_recursive_absolute(directory)
	var audit: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("controle_interpolation_lissee.json")))
	assert(audit.layers.near.numerically_passed and audit.layers.far.numerically_passed)
	var image:=Image.load_from_file(folder.path_join("sanglier_proche_source_v001.png"));image.generate_mipmaps()
	var texture:=ImageTexture.create_from_image(image)
	var model:=Model.new();model.select_faction(camp)
	model.spawn_schedule.assign([{"type":2,"time":0.0},{"type":2,"time":0.7},{"type":2,"time":1.4}]);assert(model.start())
	var viewport:=SubViewport.new();viewport.size=Vector2i(1280,800);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
	var view:=AnimatedView.new();view.model=model;viewport.add_child(view)
	for layer_suffix in ["_far",""]:
		var layer:=Study.Surface.new();layer.texture=texture;layer.far_layer=layer_suffix=="_far"
		var filename: String="smooth_walk"+layer_suffix+".json"
		assert(FileAccess.get_sha256(folder.path_join(filename))==audit.layers["far" if layer.far_layer else "near"].data_sha256)
		layer.data=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join(filename)));layer.configure_visibility();view.layers.append(layer)
	view.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var display:=Display.new();display.viewport=viewport;display.model=model;root.add_child(display)
	var records: Array=[];var impact:=false
	for frame in range(720):
		var time: float=frame/60.0
		var speed: float=1.0 if time<4.0 else 0.0 if time<4.4 else 2.0
		if frame>0: model.advance((1.0 if (frame-1)/60.0<4.0 else 0.0 if (frame-1)/60.0<4.4 else 2.0)/60.0)
		if not impact and model.elapsed>=2.8 and not model.enemies.is_empty():
			var enemy: Dictionary=model.enemies[0];enemy.hp-=4.0
			model.damage_events.append({"enemy_id":enemy.id,"hp_before":24.0,"hp_after":20.0,"time":model.elapsed});impact=true
		view.sampled.clear();view.queue_redraw()
		if not model.enemies.is_empty(): display.focus=View.project(model.enemy_position(model.enemies[0]))
		display.speed=speed;display.time=time;display.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory.path_join("%04d.png"%frame))==OK)
		records.append({"frame":frame,"wall_time":time,"speed":speed,"elapsed":model.elapsed,"enemies":view.sampled.duplicate(true),"escaped":model.escaped,"hp":model.fortress_hp})
	var out:=FileAccess.open(folder.path_join("captures/context_"+suffix+".json"),FileAccess.WRITE)
	out.store_string(JSON.stringify({"frames":720,"fps":60,"faction":camp,"profile_loaded":false,"controlled_spawn_schedule":true,"imposed_impact":true,"path":model.path_points.map(func(p):return [p.x,p.y]),"records":records}));out.close()
	for layer in view.layers: layer.free()
	print("BOAR_CONTEXT frames=720 profile_loaded=false faction=",camp);quit()
