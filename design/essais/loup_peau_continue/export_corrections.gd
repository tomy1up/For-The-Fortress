extends SceneTree
const Walker=preload("walk_skin.gd")
func _initialize() -> void: call_deferred("export_data")
func export_data() -> void:
	var animal:=Walker.new();root.add_child(animal);animal.build()
	var fixed: Dictionary={}
	for label in animal.control_indices:
		var index: int=animal.control_indices[label]
		assert(index>=0,"Control outside silhouette: "+label)
		if not fixed.has(index): fixed[index]="SurfaceBlend" if label in ["Torso","Shoulder","Pelvis","Head","Tail"] else label
	for index in range(animal.points.size()):
		var point: Vector2=animal.points[index]
		var weights: Dictionary=animal.weights_at(point,false)
		if point.y>=880: fixed[index]="FrontNear2" if point.x>850 else "HindNear3"
		elif weights.get("Head",0.0)>0.0 or weights.get("Tail",0.0)>0.0: fixed[index]="SurfaceBlend"
		elif point.x>=1060 and point.y>=510 and point.y<=700: fixed[index]="SurfaceBlend"
		elif point.x>=650 and point.x<=900 and point.y>=300 and point.y<=550: fixed[index]="SurfaceBlend"
	var fixed_indices: Array=fixed.keys();fixed_indices.sort()
	var frames: Array=[]
	var far_frames: Array=[]
	var matrices: Array=[]
	var specs: Array=[]
	for index in fixed_indices:
		var point: Vector2=animal.points[index]
		specs.append({"label":fixed[index],"surface_weights":[smoothstep(600,1000,point.x),1.0-smoothstep(450,750,point.x),animal.head_blend_at(point),animal.tail_blend_at(point)]})
	for frame in range(65):
		animal.update_distance(frame*Walker.STRIDE/64.0)
		var targets: Array=[]
		var far_targets: Array=[]
		var frame_matrices: Dictionary={}
		for label in animal.poses: frame_matrices[label]=encode_transform(animal.poses[label])
		matrices.append(frame_matrices)
		for index in fixed_indices:
			var label: String=fixed[index]
			var source_point: Vector2=animal.points[index]
			var point: Vector2
			if label=="SurfaceBlend":
				var shoulder: float=smoothstep(600,1000,source_point.x)
				var pelvis: float=1.0-smoothstep(450,750,source_point.x)
				point=animal.poses.Torso*source_point*(1.0-shoulder-pelvis)
				point+=animal.poses.Shoulder*animal.rests.Shoulder.affine_inverse()*source_point*shoulder
				point+=animal.poses.Pelvis*animal.rests.Pelvis.affine_inverse()*source_point*pelvis
				point=point.lerp(animal.poses.Head*animal.rests.Head.affine_inverse()*source_point,animal.head_blend_at(source_point))
				point=point.lerp(animal.poses.Tail*animal.rests.Tail.affine_inverse()*source_point,animal.tail_blend_at(source_point))
			else:
				point=animal.poses[label]*animal.rests[label].affine_inverse()*source_point
			targets.append([point.x,point.y])
			var far_label: String=label.replace("FrontNear","FrontFar").replace("HindNear","HindFar")
			var far_point: Vector2
			if far_label!=label:
				far_point=animal.poses[far_label]*animal.rests[far_label].affine_inverse()*(animal.points[index]+Vector2(20,-35))
			else:
				far_point=point+animal.poses.Torso.basis_xform(Vector2(20,-35))
			far_targets.append([far_point.x,far_point.y])
		frames.append(targets)
		far_frames.append(far_targets)
	var source: Array=[];var faces: Array=[]
	var rest_matrices: Dictionary={}
	for label in animal.rests: rest_matrices[label]=encode_transform(animal.rests[label])
	for point in animal.points: source.append([point.x,point.y])
	for face in animal.triangles: faces.append(Array(face))
	var folder: String=get_script().resource_path.get_base_dir().path_join("captures")
	DirAccess.make_dir_recursive_absolute(folder)
	var result: Dictionary={"points":source,"triangles":faces,"fixed_indices":fixed_indices,"fixed_specs":specs,"pose_matrices":matrices,"rest_matrices":rest_matrices,"frames":frames,"far_frames":far_frames,"stride":Walker.STRIDE,"reference":"Quaternius Walk CC0; adapted 2D geometry"}
	var file:=FileAccess.open(folder.path_join("correctives_input.json"),FileAccess.WRITE);file.store_string(JSON.stringify(result));file.close()
	print("CORRECTIVES_INPUT vertices=",source.size()," triangles=",faces.size()," constraints=",fixed.size()," frames=65")
	animal.free();quit()
func encode_transform(value: Transform2D) -> Array:
	return [value.x.x,value.x.y,value.y.x,value.y.y,value.origin.x,value.origin.y]
