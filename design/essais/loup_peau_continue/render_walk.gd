extends SceneTree
const Walker=preload("walk_skin.gd")
class Corrected extends Node2D:
	var data: Dictionary
	var texture: Texture2D
	var phase:=0.0
	var far_layer:=false
	var retained: ArrayMesh
	var anchor_mask:=PackedByteArray()
	func sampled_vertices() -> PackedVector3Array:
		if anchor_mask.size()!=data.points.size():
			anchor_mask.resize(data.points.size());anchor_mask.fill(0)
			for index in data.get("fixed_indices",[]): anchor_mask[index]=1
		var normalized: float=fposmod(phase,1.0)
		var first: int
		var t: float
		if data.has("phases"):
			var low:=0;var high: int=data.phases.size()-1
			while high-low>1:
				var middle: int=(low+high)/2
				if data.phases[middle]<=normalized: low=middle
				else: high=middle
			first=low;t=(normalized-data.phases[low])/(data.phases[high]-data.phases[low])
		else:
			var sample: float=normalized*64.0
			first=int(floor(sample));t=sample-first
		var vertices:=PackedVector3Array()
		var t2: float=t*t;var t3: float=t2*t
		var h00: float=2*t3-3*t2+1;var h01: float=-2*t3+3*t2
		var h10: float=t3-2*t2+t;var h11: float=t3-t2
		for index in range(data.points.size()):
			var a: Array=data.frames[first][index];var b: Array=data.frames[first+1][index]
			if data.has("tangents") and anchor_mask[index]==0:
				var dt: float=data.phases[first+1]-data.phases[first]
				var ma: Array=data.tangents[first][index];var mb: Array=data.tangents[first+1][index]
				vertices.append(Vector3(h00*a[0]+h01*b[0]+dt*(h10*ma[0]+h11*mb[0]),h00*a[1]+h01*b[1]+dt*(h10*ma[1]+h11*mb[1]),0))
			else:
				vertices.append(Vector3(lerpf(a[0],b[0],t),lerpf(a[1],b[1],t),0))
		return vertices
	func _draw() -> void:
		var vertices: PackedVector3Array=sampled_vertices()
		var uv:=PackedVector2Array()
		for index in range(data.points.size()):
			uv.append(Vector2(data.points[index][0],data.points[index][1])/Vector2(texture.get_size()))
		var indices:=PackedInt32Array()
		for face in data.triangles:
			if far_layer:
				var center:=Vector2.ZERO
				for index in face: center+=Vector2(data.points[index][0],data.points[index][1])/3.0
				if not ((center.y>575 and center.x>880) or (center.y>560 and center.x>330 and center.x<700 and (center.x>450 or center.y>680))): continue
			indices.append_array(PackedInt32Array(face))
		var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uv;arrays[Mesh.ARRAY_INDEX]=indices
		retained=ArrayMesh.new();retained.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		draw_mesh(retained,texture)
class Floor extends Node2D:
	var distance:=0.0
	var periodic:=false
	func _draw() -> void:
		draw_rect(Rect2(0,0,1280,800),Color("0b1915"))
		draw_string(ThemeDB.fallback_font,Vector2(30,40),"Peau continue · Cycle interne à corriger · Aucun profil joueur",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("e0dbbf"))
		draw_line(Vector2(30,550),Vector2(1250,550),Color("738471"),2)
		for index in range(-15,30):
			var x: float=index*60-fposmod(distance*940*0.4,60)
			draw_line(Vector2(x,550),Vector2(x-10,570),Color("526458"),1)
		if periodic:
			draw_string(ThemeDB.fallback_font,Vector2(30,685),"En bas : hauteur nominale 34 px · Vitesse d’essai · Naturel du mouvement à examiner",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("a9c1b1"))
			draw_line(Vector2(560,740),Vector2(740,740),Color("526458"),1)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,800)
	var floor:=Floor.new();root.add_child(floor)
	var smooth: bool=OS.get_cmdline_user_args().has("--smooth")
	var periodic: bool=OS.get_cmdline_user_args().has("--periodic") or smooth
	var movie: bool=OS.get_cmdline_user_args().has("--movie")
	assert(not movie or periodic,"Movie capture requires the explicitly selected periodic study")
	if periodic:
		var base: String=get_script().resource_path.get_base_dir()
		var audit: Variant=JSON.parse_string(FileAccess.get_file_as_string(base.path_join("controle_interpolation_lissee.json" if smooth else "controle_interpolation_periodique.json")))
		assert(audit is Dictionary and audit.get("passed",false) and audit.get("variant","")==("smooth" if smooth else "periodic"))
		var prefix: String="smooth_walk" if smooth else "periodic_walk"
		assert(FileAccess.get_sha256(base.path_join(prefix+".json"))==audit.layers.near.data_sha256)
		assert(FileAccess.get_sha256(base.path_join(prefix+"_far.json"))==audit.layers.far.data_sha256)
	floor.periodic=periodic
	var animal:=Walker.new();root.add_child(animal);animal.build()
	var corrected: Corrected
	var far_corrected: Corrected
	if OS.get_cmdline_user_args().has("--corrected") or periodic:
		var prefix: String="smooth_walk" if smooth else ("periodic_walk" if periodic else "correctives_walk")
		for child in animal.get_children():
			if child is Polygon2D: child.visible=false
		far_corrected=Corrected.new();far_corrected.texture=animal.skin.texture;far_corrected.far_layer=true;far_corrected.modulate=Color(0.65,0.65,0.65,1)
		far_corrected.data=JSON.parse_string(FileAccess.get_file_as_string(get_script().resource_path.get_base_dir().path_join(prefix+"_far.json")))
		animal.add_child(far_corrected)
		corrected=Corrected.new();corrected.texture=animal.skin.texture
		corrected.data=JSON.parse_string(FileAccess.get_file_as_string(get_script().resource_path.get_base_dir().path_join(prefix+".json")))
		animal.add_child(corrected)
	animal.scale=Vector2.ONE*0.4;animal.position=Vector2(640,550)-Vector2(750,900)*0.4
	var small_near: Corrected
	var small_far: Corrected
	var board_scale:=0.0
	if periodic:
		var minimum_y:=INF;var maximum_y: float=-INF
		for point in corrected.data.frames[0]:
			minimum_y=minf(minimum_y,point[1]);maximum_y=maxf(maximum_y,point[1])
		board_scale=34.0/(maximum_y-minimum_y)
		animal.position=Vector2(640,550)-Vector2(750,maximum_y)*0.4
		for layer in range(2):
			var tiny:=Corrected.new();tiny.texture=corrected.texture;tiny.far_layer=layer==0
			tiny.data=far_corrected.data if layer==0 else corrected.data
			tiny.scale=Vector2.ONE*board_scale;tiny.position=Vector2(640,740)-Vector2(750,maximum_y)*board_scale
			if layer==0: tiny.modulate=Color(0.65,0.65,0.65,1);small_far=tiny
			else: small_near=tiny
			root.add_child(tiny)
	var folder: String=get_script().resource_path.get_base_dir().path_join("captures")
	if movie: folder=folder.path_join("smooth_movie" if smooth else "periodic_movie")
	DirAccess.make_dir_recursive_absolute(folder)
	var count: int=192 if movie else 12
	for frame in range(count):
		var distance: float=frame*Walker.STRIDE/(64.0 if movie else 12.0)
		floor.distance=distance;floor.queue_redraw();animal.update_distance(distance)
		if corrected!=null:
			corrected.phase=distance/Walker.STRIDE;corrected.queue_redraw()
			far_corrected.phase=corrected.phase;far_corrected.queue_redraw()
		if periodic:
			small_near.position.x=590.0-750.0*board_scale+distance*Walker.SOURCE_PER_UNIT*board_scale
			small_far.position.x=small_near.position.x
			small_near.phase=distance/Walker.STRIDE;small_near.queue_redraw()
			small_far.phase=small_near.phase;small_far.queue_redraw()
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		var filename: String="pose_%04d.png"%frame if movie else (("smooth_%02d.png" if smooth else ("periodic_%02d.png" if periodic else ("corrective_%02d.png" if corrected!=null else "marche_%02d.png")))%frame)
		assert(root.get_texture().get_image().save_png(folder.path_join(filename))==OK)
	print("CONTINUOUS_WALK_POSES=",count," periodic=",periodic," smooth=",smooth," artistic_approval=false reach_error=",animal.reach_error)
	quit()
