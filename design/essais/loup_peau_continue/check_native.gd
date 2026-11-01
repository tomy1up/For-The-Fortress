extends SceneTree
const NativeSkin=preload("continuous_skin.gd")
func _initialize() -> void: call_deferred("run_check")
func run_check() -> void:
	root.size=Vector2i(1280,800)
	root.title="For the Fortress! — Étude de peau continue — Pas un cycle de marche"
	var creature:=NativeSkin.new();root.add_child(creature);creature.build()
	creature.scale=Vector2.ONE*0.65;creature.position=Vector2(110,110)
	var report: Dictionary=creature.topology_report()
	assert(report.single_connected_skin and report.weight_sum_error<0.00001 and report.bones==5)
	for index in range(5): assert(creature.skeleton.get_node(creature.skin.get_bone_path(index))==creature.bones[index])
	if not OS.get_cmdline_user_args().has("--capture"):
		print("NATIVE_CONTINUOUS_SKIN=",JSON.stringify(report));quit();return
	var folder: String=get_script().resource_path.get_base_dir().path_join("captures")
	DirAccess.make_dir_recursive_absolute(folder)
	for index in range(3):
		creature.pose(index/4.0)
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(folder.path_join("flexion_%d.png"%index))==OK)
	var file:=FileAccess.open(folder.path_join("controle_topologie.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("NATIVE_CONTINUOUS_SKIN=",JSON.stringify(report));quit()
