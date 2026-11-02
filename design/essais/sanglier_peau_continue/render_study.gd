extends SceneTree
const Shared=preload("../loup_peau_continue/render_walk.gd")
const PROFILE_SCALE:=34.0/880.0*0.85
var screen_speed: float=1.65*Vector2(27,13.5).length()
class Surface extends Shared.Corrected:
	var visible_faces: PackedInt32Array=PackedInt32Array()
	func configure_visibility() -> void:
		visible_faces.clear()
		if not far_layer: return
		for index in range(data.triangles.size()):
			var center:=Vector2.ZERO
			for vertex in data.triangles[index]: center+=Vector2(data.points[vertex][0],data.points[vertex][1])/3.0
			if (center.y>690 and center.x>780 and center.x<1120) or (center.y>625 and center.x>180 and center.x<600): visible_faces.append(index)
	func _draw() -> void:
		var vertices:=sampled_vertices()
		var uv:=PackedVector2Array()
		for point in data.points: uv.append(Vector2(point[0],point[1])/Vector2(texture.get_size()))
		var indices:=PackedInt32Array()
		for index in range(data.triangles.size()):
			if far_layer and not visible_faces.has(index): continue
			indices.append_array(PackedInt32Array(data.triangles[index]))
		var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uv;arrays[Mesh.ARRAY_INDEX]=indices
		retained=ArrayMesh.new();retained.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		draw_mesh(retained,texture)
class Board extends Node2D:
	var distance:=0.0
	func _draw() -> void:
		draw_rect(Rect2(0,0,1280,800),Color("0b1915"))
		draw_string(ThemeDB.fallback_font,Vector2(28,40),"Sanglier neutre · Allure rapide expérimentale",HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("e0dbbf"))
		draw_string(ThemeDB.fallback_font,Vector2(28,74),"Atelier isolé · Aucun profil joueur chargé · Animation non approuvée",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("abc0b0"))
		draw_string(ThemeDB.fallback_font,Vector2(180,170),"Vers la droite · agrandi ×5",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("80bbd8"))
		draw_string(ThemeDB.fallback_font,Vector2(810,170),"Vers la gauche · agrandi ×5",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("d79782"))
		for column in range(2):
			var center: float=325+column*630
			for scale_factor in [1.0,5.0]:
				var y: float=520 if scale_factor>1 else 650
				var width: float=240 if scale_factor>1 else 70
				var sign_value: float=1 if column==0 else -1
				draw_line(Vector2(center-width,y),Vector2(center+width,y),Color("536657"),1)
				var step: float=32*scale_factor
				for index in range(-12,13):
					var x: float=center+index*step-sign_value*fposmod(distance*PROFILE_SCALE*scale_factor,step)
					if absf(x-center)>width: continue
					draw_line(Vector2(x,y),Vector2(x,y+8),Color("869878"),1)
		draw_string(ThemeDB.fallback_font,Vector2(28,710),"En bas : taille du plateau. Vitesse de déplacement du sanglier du prototype.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("abc0b0"))
		draw_string(ThemeDB.fallback_font,Vector2(28,746),"Les repères défilent avec la distance parcourue ; ce n’est pas une partie jouée.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("abc0b0"))
func _initialize() -> void: call_deferred("record")
func record() -> void:
	root.size=Vector2i(1280,800)
	root.title="For the Fortress! — Atelier du sanglier — Non approuvé"
	var folder: String=get_script().resource_path.get_base_dir()
	var audit: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("controle_interpolation_lissee.json")))
	assert(audit.passed)
	var image:=Image.load_from_file(folder.path_join("sanglier_proche_source_v001.png"));image.generate_mipmaps()
	var texture:=ImageTexture.create_from_image(image)
	var board:=Board.new();root.add_child(board)
	var surfaces: Array[Surface]=[]
	for column in range(2):
		for scale_factor in [5.0,1.0]:
			for suffix in ["_far",""]:
				var surface:=Surface.new()
				var layer: String="far" if suffix=="_far" else "near"
				assert(FileAccess.get_sha256(folder.path_join("smooth_walk"+suffix+".json"))==audit.layers[layer].data_sha256)
				surface.data=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("smooth_walk"+suffix+".json")))
				surface.texture=texture;surface.far_layer=suffix=="_far"
				if surface.far_layer:
					surface.modulate=Color(0.65,0.65,0.65,1)
				surface.configure_visibility()
				var actor_scale: Vector2=Vector2(-PROFILE_SCALE if column==1 else PROFILE_SCALE,PROFILE_SCALE)*scale_factor
				surface.scale=actor_scale
				surface.position=Vector2(325+column*630,520 if scale_factor>1 else 650)-Vector2(750,936)*actor_scale
				surface.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
				root.add_child(surface);surfaces.append(surface)
	var movie: bool="--movie" in OS.get_cmdline_user_args()
	var directory: String=folder.path_join("captures/rapide_frames")
	DirAccess.make_dir_recursive_absolute(directory)
	var trace: Array=[]
	for frame in range(144 if movie else 12):
		var distance: float=frame/60.0*screen_speed/PROFILE_SCALE if movie else frame/12.0*700.0
		var phase: float=fposmod(distance/700.0,1.0)
		board.distance=distance;board.queue_redraw()
		trace.append({"frame":frame,"time":frame/60.0,"distance_source":distance,"phase":phase})
		for surface in surfaces: surface.phase=phase;surface.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory.path_join("%04d.png"%frame))==OK)
	var output:=FileAccess.open(folder.path_join("captures/motion_trace.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify({"movie":movie,"screen_speed":screen_speed,"profile_scale":PROFILE_SCALE,"stride_source":700.0,"frames":trace}));output.close()
	print("BOAR_STUDY frames=",144 if movie else 12," cycle_seconds=",700.0*PROFILE_SCALE/screen_speed," profile_loaded=false")
	quit()
