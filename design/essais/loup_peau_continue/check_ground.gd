extends SceneTree
const Walker=preload("walk_skin.gd")
func _initialize() -> void: call_deferred("run_check")
func run_check() -> void:
	var animal:=Walker.new();root.add_child(animal);animal.build()
	var fixed: Dictionary={};var drift:=0.0;var actual_error:=0.0;var samples:=0
	for frame in range(1025):
		var distance: float=frame*Walker.STRIDE/512.0
		animal.update_distance(distance)
		for contact in animal.contacts:
			var label: String=contact.leg+("2" if str(contact.leg).begins_with("Front") else "3")
			var actual: Vector2=animal.to_local(animal.named[label].global_position)+Walker.source_root(distance)
			actual_error=maxf(actual_error,actual.distance_to(contact.desired))
			if not contact.support: continue
			samples+=1
			var key: String="%s:%d"%[contact.leg,contact.cycle]
			if fixed.has(key): drift=maxf(drift,fixed[key].distance_to(actual))
			else: fixed[key]=actual
	var report: Dictionary={"distance_frames":1025,"support_samples":samples,"actual_bone_support_drift_source_pixels":drift,"actual_bone_target_error_source_pixels":actual_error,"reach_error_source_pixels":animal.reach_error,"scope":"four actual native bone end-points, two cycles, horizontal test floor only","artistic_approval":false}
	var file:=FileAccess.open(get_script().resource_path.get_base_dir().path_join("controle_appuis_cycle.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("CONTINUOUS_GROUND_CHECK=",JSON.stringify(report))
	var passed: bool=drift<0.002 and actual_error<0.002 and animal.reach_error<0.002
	animal.free();quit(0 if passed else 1)
