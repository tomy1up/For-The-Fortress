extends SceneTree
const Study=preload("render_study.gd")
func _initialize() -> void: call_deferred("inspect_mesh")
func inspect_mesh() -> void:
	root.size=Vector2i(1280,800)
	var folder: String=get_script().resource_path.get_base_dir()
	var image:=Image.load_from_file(folder.path_join("sanglier_proche_source_v001.png"));image.generate_mipmaps()
	var texture:=ImageTexture.create_from_image(image)
	var phases: Array=[0.0,0.0007,0.0078125,0.0137,0.03125,0.0973,0.137,0.249,0.321,0.5003,0.6667,0.7813,0.9321,0.9921875,0.9993,1.0]
	# The common auditor verifies the inherited curve sampler; the study's
	# drawing and visibility code has its own additional fingerprint.
	var results: Dictionary={"renderer_sha256":FileAccess.get_sha256(folder.path_join("../loup_peau_continue/render_walk.gd")),"draw_renderer_sha256":FileAccess.get_sha256(folder.path_join("render_study.gd"))}
	var count:=0
	for suffix in ["","_far"]:
		var surface:=Study.Surface.new()
		surface.data=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("smooth_walk"+suffix+".json")))
		surface.texture=texture;surface.far_layer=suffix=="_far";surface.configure_visibility()
		root.add_child(surface)
		var samples: Array=[]
		for phase in phases:
			surface.phase=phase;surface.queue_redraw()
			await process_frame;await process_frame;await RenderingServer.frame_post_draw
			assert(surface.retained!=null)
			var arrays: Array=surface.retained.surface_get_arrays(0)
			var vertices: Array=[]
			for point in arrays[Mesh.ARRAY_VERTEX]: vertices.append([point.x,point.y])
			count+=vertices.size();samples.append({"phase":phase,"vertices":vertices})
		results["near" if suffix=="" else "far"]={"data_sha256":FileAccess.get_sha256(folder.path_join("smooth_walk"+suffix+".json")),"samples":samples}
		surface.free()
	var output:=FileAccess.open(folder.path_join("captures/native_smooth_mesh.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify(results));output.close()
	print("BOAR_NATIVE_READBACK vertices=",count," layers=2 phases=16 profile_loaded=false");quit()
