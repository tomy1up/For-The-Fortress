extends SceneTree
const Walker=preload("walk_skin.gd")
class Corrected extends Node2D:
	var data: Dictionary
	var texture: Texture2D
	var phase:=0.0
	var far_layer:=false
	var retained: ArrayMesh
	func _draw() -> void:
		var sample: float=fposmod(phase,1.0)*64.0
		var first: int=int(floor(sample));var t: float=sample-first
		var vertices:=PackedVector3Array();var uv:=PackedVector2Array()
		for index in range(data.points.size()):
			var a: Array=data.frames[first][index];var b: Array=data.frames[first+1][index]
			vertices.append(Vector3(lerpf(a[0],b[0],t),lerpf(a[1],b[1],t),0))
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
	func _draw() -> void:
		draw_rect(Rect2(0,0,1280,800),Color("0b1915"))
		draw_string(ThemeDB.fallback_font,Vector2(30,40),"Peau continue · Cycle interne à corriger · Aucun profil joueur",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("e0dbbf"))
		draw_line(Vector2(30,550),Vector2(1250,550),Color("738471"),2)
		for index in range(-15,30):
			var x: float=index*60-fposmod(distance*940*0.4,60)
			draw_line(Vector2(x,550),Vector2(x-10,570),Color("526458"),1)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,800)
	var floor:=Floor.new();root.add_child(floor)
	var animal:=Walker.new();root.add_child(animal);animal.build()
	var corrected: Corrected
	var far_corrected: Corrected
	if OS.get_cmdline_user_args().has("--corrected"):
		for child in animal.get_children():
			if child is Polygon2D: child.visible=false
		far_corrected=Corrected.new();far_corrected.texture=animal.skin.texture;far_corrected.far_layer=true;far_corrected.modulate=Color(0.65,0.65,0.65,1)
		far_corrected.data=JSON.parse_string(FileAccess.get_file_as_string(get_script().resource_path.get_base_dir().path_join("correctives_walk_far.json")))
		animal.add_child(far_corrected)
		corrected=Corrected.new();corrected.texture=animal.skin.texture
		corrected.data=JSON.parse_string(FileAccess.get_file_as_string(get_script().resource_path.get_base_dir().path_join("correctives_walk.json")))
		animal.add_child(corrected)
	animal.scale=Vector2.ONE*0.4;animal.position=Vector2(640,550)-Vector2(750,900)*0.4
	var folder: String=get_script().resource_path.get_base_dir().path_join("captures")
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in range(12):
		var distance: float=frame*Walker.STRIDE/12.0
		floor.distance=distance;floor.queue_redraw();animal.update_distance(distance)
		if corrected!=null:
			corrected.phase=distance/Walker.STRIDE;corrected.queue_redraw()
			far_corrected.phase=corrected.phase;far_corrected.queue_redraw()
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(folder.path_join(("corrective_%02d.png" if corrected!=null else "marche_%02d.png")%frame))==OK)
	print("CONTINUOUS_WALK_POSES=12 artistic_approval=false reach_error=",animal.reach_error)
	quit()
