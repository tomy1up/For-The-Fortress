extends SceneTree
const Walker=preload("../loup_peau_continue/walk_skin.gd")
func _initialize() -> void: call_deferred("inspect_body")
func inspect_body() -> void:
	var previous:=Walker.new();root.add_child(previous);previous.build()
	var candidate:=Walker.new();candidate.body_reference=true;root.add_child(candidate);candidate.build()
	var root_error:=0.0;var foot_difference:=0.0;var head_error:=0.0;var tail_error:=0.0
	var shoulder_min:=Vector2(INF,INF);var shoulder_max:=-shoulder_min
	var pelvis_min:=Vector2(INF,INF);var pelvis_max:=-pelvis_min
	var fixed: Dictionary={};var support_drift:=0.0;var support_samples:=0
	for frame in range(1025):
		var distance: float=frame*Walker.STRIDE/512.0
		previous.update_distance(distance);candidate.update_distance(distance)
		var shoulder: Vector2=candidate.named.Shoulder.global_position
		var pelvis: Vector2=candidate.named.Pelvis.global_position
		shoulder_min=shoulder_min.min(shoulder);shoulder_max=shoulder_max.max(shoulder)
		pelvis_min=pelvis_min.min(pelvis);pelvis_max=pelvis_max.max(pelvis)
		root_error=maxf(root_error,shoulder.distance_to(candidate.named.FrontNear0.global_position))
		root_error=maxf(root_error,pelvis.distance_to(candidate.named.HindNear0.global_position))
		var expected_head: Vector2=candidate.named.Shoulder.global_transform*candidate.rests.Shoulder.affine_inverse()*Vector2(1130,420)
		head_error=maxf(head_error,expected_head.distance_to(candidate.named.Head.global_position))
		tail_error=maxf(tail_error,pelvis.distance_to(candidate.named.Tail.global_position))
		for index in range(candidate.contacts.size()):
			var contact: Dictionary=candidate.contacts[index]
			var last: String=contact.leg+("2" if str(contact.leg).begins_with("Front") else "3")
			var actual: Vector2=candidate.named[last].global_position+Walker.source_root(distance)
			var old: Vector2=previous.named[last].global_position+Walker.source_root(distance)
			foot_difference=maxf(foot_difference,actual.distance_to(old))
			if contact.support:
				support_samples+=1
				var key: String="%s:%d"%[contact.leg,contact.cycle]
				if fixed.has(key): support_drift=maxf(support_drift,fixed[key].distance_to(actual))
				else: fixed[key]=actual
	var result: Dictionary={"frames":1025,"cycles":2,"reference_pixels_per_unit":candidate.reference_body_scale,
		"actual_near_root_attachment_error_source_pixels":root_error,"actual_foot_difference_from_previous_source_pixels":foot_difference,
		"actual_support_drift_source_pixels":support_drift,"support_samples":support_samples,
		"actual_head_attachment_error_source_pixels":head_error,"actual_tail_attachment_error_source_pixels":tail_error,
		"shoulder_peak_to_peak_source_pixels":[shoulder_max.x-shoulder_min.x,shoulder_max.y-shoulder_min.y],
		"pelvis_peak_to_peak_source_pixels":[pelvis_max.x-pelvis_min.x,pelvis_max.y-pelvis_min.y],
		"reach_error_source_pixels":candidate.reach_error,"artistically_approved":false,
		"scope":"actual Skeleton2D endpoints; isolated horizontal gait, not rendered skin or game validation"}
	var passed: bool=root_error<0.002 and foot_difference<0.002 and support_drift<0.002 and head_error<0.002 and tail_error<0.002 and candidate.reach_error<0.002
	result["passed"]=passed
	var output:=FileAccess.open(get_script().resource_path.get_base_dir().path_join("controle_attaches.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify(result,"\t"));output.close()
	print("REFERENCE_BODY_CHECK=",JSON.stringify(result))
	previous.free();candidate.free();quit(0 if passed else 1)
