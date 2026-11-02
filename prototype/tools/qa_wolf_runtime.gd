extends SceneTree
const Walk=preload("res://scripts/enemy_walk_art.gd")
class Bench extends Node2D:
	var count:=1
	var phase:=0.0
	var cache:=Walk.new()
	var cpu_ms:=0.0
	func _draw() -> void:
		cpu_ms=0
		for index in range(count):
			var started:=Time.get_ticks_usec()
			var mesh: ArrayMesh=cache.mesh_for(index,fposmod(phase+index*0.137,1.0),Vector2(0.8944272,0.4472136))
			cpu_ms+=(Time.get_ticks_usec()-started)/1000.0
			draw_set_transform(Vector2(50+(index%16)*75,100+(index/16)*90),0,Vector2.ONE*0.7)
			draw_mesh(mesh,Walk.TEXTURE)
		draw_set_transform(Vector2.ZERO)
func _initialize() -> void: call_deferred("probe")
func probe() -> void:
	root.size=Vector2i(1280,800)
	root.title="For the Fortress! — Contrôle du rendu des loups"
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var bench:=Bench.new();root.add_child(bench)
	var cases: Array=[]
	var readback_error:=0.0
	for count in [1,16,48,96]:
		bench.count=count;bench.cache.meshes.clear()
		var timings: Array[float]=[]
		for frame in range(44):
			bench.phase=frame/64.0;bench.queue_redraw()
			await process_frame;await process_frame;await RenderingServer.frame_post_draw
			if frame>=12: timings.append(bench.cpu_ms)
			if count==1:
				var expected:=Walk.sample_vertices(bench.phase,Vector2(0.8944272,0.4472136))
				var actual: PackedVector2Array=bench.cache.meshes[0].mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
				for index in range(expected.size()): readback_error=maxf(readback_error,expected[index].distance_to(Vector2(actual[index].x,actual[index].y)))
		timings.sort()
		cases.append({"wolves":count,"cpu_update_median_ms":timings[timings.size()/2],"cpu_update_p95_ms":timings[int(timings.size()*0.95)]})
		print("WOLF_RENDER_CPU ",JSON.stringify(cases[-1]))
	var directory:=ProjectSettings.globalize_path("res://../design/essais")
	var output:=FileAccess.open(directory.path_join("v0108_wolf_cpu.json"),FileAccess.WRITE)
	assert(readback_error<0.0001,"Native mesh buffers differ from sampled gait")
	output.store_string(JSON.stringify({"scope":"CPU curve sampling and mesh upload in native renderer; not full game FPS","native_vertex_readback_max_error":readback_error,"cases":cases},"\t"));output.close()
	quit()
