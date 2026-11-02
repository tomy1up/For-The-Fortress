extends SceneTree
## Controlled placement study. No mission or player profile is created.
const Study=preload("render_study.gd")
const Walk=preload("res://scripts/enemy_walk_art.gd")
const View=preload("res://scripts/valley_view.gd")
const PIVOT:=Vector2(750,936)
const DIRECTIONS: Array[Vector2]=[Vector2(2,1),Vector2(-2,1),Vector2(2,-1),Vector2(-2,-1)]
const LABELS: Array[String]=["Droite et bas","Gauche et bas","Droite et haut","Gauche et haut"]

class Ground extends Node2D:
	var clock:=0.0
	func _draw() -> void:
		draw_rect(Rect2(0,0,1280,840),Color("0b1915"))
		draw_string(ThemeDB.fallback_font,Vector2(24,35),"Sanglier · Essai de déplacement sur quatre diagonales",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("e0dbbf"))
		draw_string(ThemeDB.fallback_font,Vector2(24,66),"Animation non approuvée · Sol fixe · Aucun profil joueur",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("abc0b0"))
		for index in range(4):
			var origin:=Vector2(20+(index%2)*630,95+(index/2)*345)
			var direction: Vector2=DIRECTIONS[index].normalized()
			draw_rect(Rect2(origin,Vector2(610,330)),Color("142b23"))
			draw_string(ThemeDB.fallback_font,origin+Vector2(14,26),LABELS[index]+" · grand ×2 et taille du jeu",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e0dbbf"))
			for factor in [2.0,1.0]:
				var center:=origin+Vector2(305,175 if factor==2 else 220)
				var start: Vector2=center-direction*(220 if factor==2 else 140)
				var finish: Vector2=center+direction*(230 if factor==2 else 150)
				var side:=Vector2(-direction.y,direction.x)*10
				draw_colored_polygon(PackedVector2Array([start-side,finish-side,finish+side,start+side]),Color("9d906a"))
				for n in range(16 if factor==2 else 10):
					var p: Vector2=start+direction*n*30
					draw_line(p-side,p+side,Color("c6b990"),1,true)
		var caption: String="Vitesse normale"
		if clock>=1.5 and clock<2.1: caption="Vitesse ×2 : la cadence suit le déplacement"
		elif clock>=2.1 and clock<2.5: caption="Pause : déplacement et pas arrêtés"
		elif clock>=2.85 and clock<3.13: caption="Impact imposé : réaction visuelle du prototype"
		draw_string(ThemeDB.fallback_font,Vector2(24,805),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e0dbbf"))

func _initialize() -> void: call_deferred("record")

static func travel_at(time: float) -> float:
	return minf(time,1.5)+2.0*clampf(time-1.5,0,0.6)+maxf(0,time-2.5)

static func placement(direction: Vector2,scale_value: float,anchor: Vector2,pose: Dictionary) -> Transform2D:
	var ground:=Walk.ground_basis(direction)
	var facing: float=-1.0 if direction.x<0 else 1.0
	var mirror:=Transform2D(Vector2(facing,0),Vector2(0,1),Vector2.ZERO)
	var orient:=Transform2D(ground,Vector2(-ground.y,ground.x),Vector2.ZERO)
	var reaction:=Transform2D(float(pose.rotation),Vector2(pose.offset)/(34.0/880.0))
	var result: Transform2D=mirror*orient*reaction
	result.x*=scale_value;result.y*=scale_value
	result.origin=anchor+result.origin*scale_value-result.basis_xform(PIVOT)
	return result

func record() -> void:
	root.size=Vector2i(1280,840)
	root.content_scale_size=Vector2i(1280,840)
	root.title="For the Fortress! — Sanglier sur routes — Essai isolé"
	var folder: String=get_script().resource_path.get_base_dir()
	var directory: String=folder.path_join("captures/routes_frames")
	DirAccess.make_dir_recursive_absolute(directory)
	var image:=Image.load_from_file(folder.path_join("sanglier_proche_source_v001.png"));image.generate_mipmaps()
	var texture:=ImageTexture.create_from_image(image)
	var data: Dictionary={}
	for suffix in ["_far",""]:
		data[suffix]=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("smooth_walk"+suffix+".json")))
	var floor:=Ground.new();root.add_child(floor)
	var actors: Array[Dictionary]=[]
	for index in range(4):
		for factor in [2.0,1.0]:
			var layers: Array[Study.Surface]=[]
			for suffix in ["_far",""]:
				var surface:=Study.Surface.new();surface.data=data[suffix];surface.texture=texture
				surface.far_layer=suffix=="_far";surface.configure_visibility()
				if surface.far_layer: surface.modulate=Color(0.65,0.65,0.65,1)
				surface.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
				root.add_child(surface);layers.append(surface)
			actors.append({"index":index,"factor":factor,"layers":layers})
	var trace: Array=[]
	var enemy: Dictionary={"id":1,"type":2,"max_hp":24.0}
	var events: Array[Dictionary]=[{"enemy_id":1,"hp_before":24.0,"hp_after":12.0,"time":2.85}]
	var screen_speed: float=1.65*Vector2(27,13.5).length()
	for frame in range(240):
		var time: float=frame/60.0
		var distance: float=travel_at(time)*screen_speed
		var phase: float=fposmod(distance/(Study.PROFILE_SCALE*700.0),1.0)
		var pose: Dictionary=View.enemy_reaction_pose(enemy,events,time)
		floor.clock=time;floor.queue_redraw()
		for actor in actors:
			var index: int=actor.index
			var direction: Vector2=DIRECTIONS[index].normalized()
			var center:=Vector2(20+(index%2)*630+305,95+(index/2)*345+(175 if actor.factor==2 else 220))
			var anchor: Vector2=center-direction*(220 if actor.factor==2 else 140)+direction*distance*actor.factor
			var transform:=placement(direction,Study.PROFILE_SCALE*actor.factor,anchor,pose)
			for surface in actor.layers:
				surface.transform=transform;surface.phase=phase;surface.queue_redraw()
			if frame in [0,27,90,125,126,149,171,174,188,239]:
				trace.append({"frame":frame,"time":time,"direction":[direction.x,direction.y],"factor":actor.factor,"distance":distance,"phase":phase,"reaction":pose.strength,"basis":[[transform.x.x,transform.x.y],[transform.y.x,transform.y.y]],"anchor":[anchor.x,anchor.y]})
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory.path_join("%04d.png"%frame))==OK)
	var output:=FileAccess.open(folder.path_join("captures/routes_trace.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify({"frames":240,"fps":60,"profile_loaded":false,"trace":trace}));output.close()
	print("BOAR_ROUTES frames=240 profile_loaded=false");quit()
