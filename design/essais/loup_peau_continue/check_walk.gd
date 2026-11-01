extends SceneTree
const Walker=preload("walk_skin.gd")
func _initialize() -> void: call_deferred("check_walk")
func check_walk() -> void:
	var animal:=Walker.new();root.add_child(animal);animal.build()
	if animal.triangles.is_empty():
		print("WALK_TOPOLOGY_EMPTY points=",animal.points.size()," controls=",animal.control_indices)
		animal.free();quit(1);return
	var source: Image=animal.skin.texture.get_image()
	var opaque: Array[bool]=[]
	for face in animal.triangles:
		var point: Vector2=(animal.points[face[0]]+animal.points[face[1]]+animal.points[face[2]])/3.0
		opaque.append(source.get_pixelv(Vector2i(point)).a>0.5)
	if not opaque.has(true):
		print("WALK_NO_OPAQUE_TRIANGLES points=",animal.points.size()," triangles=",animal.triangles.size())
		animal.free();quit(1);return
	var smallest:=INF;var largest:=-INF;var inverted:=0;var drift:=0.0
	var planted: Dictionary={}
	var worst_skin: Dictionary={}
	for frame in range(128):
		var progress: float=frame/64.0
		animal.update_distance(progress)
		for contact in animal.contacts:
			if not contact.support: continue
			var key: String="%s:%d"%[contact.leg,contact.cycle]
			if planted.has(key): drift=maxf(drift,planted[key].distance_to(contact.world))
			else: planted[key]=contact.world
		var transforms: Array[Transform2D]=[]
		for bone in animal.bones: transforms.append(animal.poses[str(bone.name)]*animal.rests[str(bone.name)].affine_inverse())
		var vertices:=PackedVector2Array()
		for index in range(animal.points.size()):
			var point:=Vector2.ZERO
			for bone in range(animal.bones.size()): point+=transforms[bone]*animal.points[index]*animal.influences[bone][index]
			vertices.append(point)
		for index in range(animal.triangles.size()):
			if not opaque[index]: continue
			var face: PackedInt32Array=animal.triangles[index]
			var ratio: float=(vertices[face[1]]-vertices[face[0]]).cross(vertices[face[2]]-vertices[face[0]])/(animal.points[face[1]]-animal.points[face[0]]).cross(animal.points[face[2]]-animal.points[face[0]])
			if ratio<smallest:
				smallest=ratio;worst_skin={"frame":frame,"source":(animal.points[face[0]]+animal.points[face[1]]+animal.points[face[2]])/3.0}
			largest=maxf(largest,ratio)
			if ratio<=0: inverted+=1
	var report: Dictionary={"frames":128,"reach_error_source_pixels":animal.reach_error,"support_drift_source_pixels":drift,"opaque_inverted_triangles":inverted,"smallest_area_ratio":smallest,"largest_area_ratio":largest,"artistically_approved":false,"worst_reach":animal.worst_reach,"worst_skin":worst_skin}
	var file:=FileAccess.open(get_script().resource_path.get_base_dir().path_join("controle_marche.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("NATIVE_WALK_CHECK=",JSON.stringify(report))
	var passed: bool=animal.reach_error<0.002 and drift<0.002 and inverted==0
	animal.free();quit(0 if passed else 1)
