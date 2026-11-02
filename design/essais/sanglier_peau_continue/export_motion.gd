extends SceneTree
const Boar=preload("boar_skin.gd")
func _initialize() -> void: call_deferred("export_motion")
func export_motion() -> void:
	var animal:=Boar.new();root.add_child(animal);animal.build()
	var fixed: Dictionary={}
	for label in animal.control_indices:
		var index: int=animal.control_indices[label]
		assert(index>=0,"Handle outside boar silhouette: "+label)
		# Inner joint landmarks refine the topology but are not deformation
		# targets: forcing those painted points caused surface inversions.
		if label in ["FrontNear1","HindNear1","HindNear2"]: continue
		fixed[index]="SurfaceBlend" if label in ["Torso","Shoulder","Pelvis","Head","Tail"] else label
	for index in range(animal.points.size()):
		var point: Vector2=animal.points[index]
		var weights: Array[float]=animal.surface_weights(point)
		if point.y>=882: fixed[index]="FrontNear2" if point.x>700 else "HindNear3"
		elif weights[2]>0.97 or weights[3]>0.97: fixed[index]="SurfaceBlend"
		elif point.x>550 and point.x<810 and point.y>280 and point.y<600: fixed[index]="SurfaceBlend"
	var fixed_indices: Array=fixed.keys();fixed_indices.sort()
	var frames: Array=[];var far_frames: Array=[]
	for frame in range(65):
		animal.update_distance(frame*Boar.CYCLE_DISTANCE/64.0)
		var near: Array=[];var far: Array=[]
		for index in fixed_indices:
			var label: String=fixed[index];var point: Vector2=animal.points[index]
			var result: Vector2=animal.surface_point(point) if label=="SurfaceBlend" else animal.poses[label]*animal.rests[label].affine_inverse()*point
			near.append([result.x,result.y])
			var other: String=label.replace("FrontNear","FrontFar").replace("HindNear","HindFar")
			var offset: Vector2=animal.poses.Torso.basis_xform(Boar.FAR_OFFSET)
			var far_result: Vector2=result+offset if other==label else animal.poses[other]*animal.rests[other].affine_inverse()*(point+Boar.FAR_OFFSET)
			far.append([far_result.x,far_result.y])
		frames.append(near);far_frames.append(far)
	var points: Array=[];var faces: Array=[]
	for point in animal.points: points.append([point.x,point.y])
	for face in animal.triangles: faces.append(Array(face))
	var folder: String=get_script().resource_path.get_base_dir()
	var data: Dictionary={"points":points,"triangles":faces,"fixed_indices":fixed_indices,"fixed_labels":fixed_indices.map(func(index):return fixed[index]),"frames":frames,"far_frames":far_frames,"stride":Boar.CYCLE_DISTANCE,"contact_duty":animal.legs[0].duty,"reference":"Original proposed four-contact gait; not a sampled animal reference or an approved animation","reach_error_source_pixels":animal.reach_error,"source_texture_sha256":FileAccess.get_sha256(folder.path_join("sanglier_proche_source_v001.png"))}
	var output:=FileAccess.open(folder.path_join("captures/correctives_input.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify(data));output.close()
	print("BOAR_MOTION_INPUT vertices=",points.size()," triangles=",faces.size()," fixed=",fixed.size()," reach_error=",animal.reach_error)
	print("BOAR_REACH_DIAGNOSTIC ",JSON.stringify(animal.worst_reach))
	animal.free();quit()
