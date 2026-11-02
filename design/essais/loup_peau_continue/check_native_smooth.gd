extends SceneTree
const Study=preload("render_walk.gd")
func _initialize() -> void: call_deferred("inspect_mesh")
func inspect_mesh() -> void:
	root.size=Vector2i(1280,800)
	root.title="For the Fortress! — Contrôle des courbes du loup — Atelier"
	var folder: String=get_script().resource_path.get_base_dir()
	var assets: String=folder
	var arguments: PackedStringArray=OS.get_cmdline_user_args()
	var folder_index: int=arguments.find("--data-folder")
	if folder_index>=0:
		assert(folder_index+1<arguments.size())
		folder=arguments[folder_index+1]
	var phases: Array=[0.0,0.0007,0.0078125,0.0137,0.03125,0.0973,0.137,0.249,0.321,0.5003,0.6667,0.7813,0.9321,0.9921875,0.9993,1.0]
	var results: Dictionary={"renderer_sha256":FileAccess.get_sha256(assets.path_join("render_walk.gd"))}
	for suffix in ["","_far"]:
		var surface:=Study.Corrected.new()
		surface.data=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("smooth_walk"+suffix+".json")))
		surface.texture=ImageTexture.create_from_image(Image.load_from_file(assets.path_join("loup_proche_source_v001.png")))
		surface.far_layer=suffix=="_far"
		root.add_child(surface)
		var samples: Array=[]
		for phase in phases:
			surface.phase=phase;surface.queue_redraw()
			await process_frame;await process_frame;await RenderingServer.frame_post_draw
			assert(surface.retained!=null)
			var arrays: Array=surface.retained.surface_get_arrays(0)
			var coordinates: Array=[]
			for point in arrays[Mesh.ARRAY_VERTEX]: coordinates.append([point.x,point.y])
			assert(coordinates.size()==surface.data.points.size())
			samples.append({"phase":phase,"vertices":coordinates})
		results["near" if suffix=="" else "far"]={"data_sha256":FileAccess.get_sha256(folder.path_join("smooth_walk"+suffix+".json")),"samples":samples}
		surface.free()
	var output:=FileAccess.open(folder.path_join("captures/native_smooth_mesh.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify(results));output.close()
	print("NATIVE_SMOOTH_READBACK layers=2 phases_per_layer=16 mesh_vertices_per_sample=771 profile_loaded=false")
	quit()
