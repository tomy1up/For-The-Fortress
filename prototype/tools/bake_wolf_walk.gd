extends SceneTree
## Compile the approved authoring curves into compact read-only visual data.
func _initialize() -> void: call_deferred("bake")
func bake() -> void:
	var project: String=ProjectSettings.globalize_path("res://")
	var source: String=project.path_join("../design/essais/loup_transfert_poids").simplify_path()
	var common: String=project.path_join("../design/essais/loup_peau_continue").simplify_path()
	var near: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(source.path_join("smooth_walk.json")))
	var far: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(source.path_join("smooth_walk_far.json")))
	var audit: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(source.path_join("controle_interpolation_lissee.json")))
	assert(audit.passed and audit.native_readback.passed)
	assert(FileAccess.get_sha256(source.path_join("smooth_walk.json"))==audit.layers.near.data_sha256)
	assert(FileAccess.get_sha256(source.path_join("smooth_walk_far.json"))==audit.layers.far.data_sha256)
	var baseline: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(common.path_join("smooth_walk.json")))
	var low:=INF;var high: float=-INF
	for point in baseline.frames[0]: low=minf(low,point[1]);high=maxf(high,point[1])
	var scale: float=34.0/(high-low)
	var pivot:=Vector2(750,929)
	var used_far: Array[int]=[];var far_faces: Array=[]
	for face in far.triangles:
		var center:=Vector2.ZERO
		for index in face: center+=Vector2(far.points[index][0],far.points[index][1])/3.0
		if not ((center.y>575 and center.x>880) or (center.y>560 and center.x>330 and center.x<700 and (center.x>450 or center.y>680))): continue
		far_faces.append(face)
		for index in face:
			if not used_far.has(int(index)): used_far.append(int(index))
	used_far.sort()
	var selected: Array=[used_far,range(near.points.size())]
	var layers: Array=[far,near];var map_indices: Array[Dictionary]=[{},{}]
	var rest:=PackedVector2Array();var uv:=PackedVector2Array();var colors:=PackedColorArray()
	var fixed:=PackedByteArray();var feet:=PackedInt32Array()
	for layer in range(2):
		var data: Dictionary=layers[layer]
		var source_fixed: Dictionary={}
		for original in data.fixed_indices: source_fixed[int(original)]=true
		for original in selected[layer]:
			var index: int=rest.size();map_indices[layer][original]=index
			var point:=Vector2(data.points[original][0],data.points[original][1])
			rest.append((point+(Vector2(20,-35) if layer==0 else Vector2.ZERO)-pivot)*scale)
			uv.append(point/Vector2(1536,1024));colors.append(Color(0.65,0.65,0.65,1) if layer==0 else Color.WHITE)
			fixed.append(1 if source_fixed.has(original) else 0)
			feet.append((0 if point.x>850 else 1)+(2 if layer==0 else 0) if point.y>=900 else -1)
	var indices:=PackedInt32Array()
	for layer in range(2):
		for face in (far_faces if layer==0 else near.triangles):
			for original in face: indices.append(map_indices[layer][int(original)])
	var frames: Array=[];var tangents: Array=[]
	var bounds:=Rect2();var has_bounds:=false
	for frame in range(near.frames.size()):
		var coordinates:=PackedVector2Array();var derivatives:=PackedVector2Array()
		for layer in range(2):
			var data: Dictionary=layers[layer]
			for original in selected[layer]:
				coordinates.append((Vector2(data.frames[frame][original][0],data.frames[frame][original][1])-pivot)*scale)
				derivatives.append(Vector2(data.tangents[frame][original][0],data.tangents[frame][original][1])*scale)
		frames.append(coordinates);tangents.append(derivatives)
	for frame in range(frames.size()-1):
		var dt: float=near.phases[frame+1]-near.phases[frame]
		for index in range(rest.size()):
			var controls: Array[Vector2]=[frames[frame][index],frames[frame][index].lerp(frames[frame+1][index],1.0/3.0),frames[frame][index].lerp(frames[frame+1][index],2.0/3.0),frames[frame+1][index]]
			if fixed[index]==0:
				controls[1]=frames[frame][index]+tangents[frame][index]*dt/3.0
				controls[2]=frames[frame+1][index]-tangents[frame+1][index]*dt/3.0
			for point in controls:
				if not has_bounds: bounds=Rect2(point,Vector2.ZERO);has_bounds=true
				else: bounds=bounds.expand(point)
	var half: float=maxf(absf(bounds.position.x),absf(bounds.end.x))
	bounds=Rect2(Vector2(-half,bounds.position.y),Vector2(half*2,bounds.size.y)).grow(0.1)
	var data: Dictionary={"schema":3,"source_near_sha256":audit.layers.near.data_sha256,"source_far_sha256":audit.layers.far.data_sha256,
		"scale":scale,"stride_pixels":near.stride*940.0*scale,"rest":rest,"uv":uv,"colors":colors,"fixed":fixed,
		"feet":feet,"indices":indices,"frames":frames,"tangents":tangents,"bounds":bounds,
		"approval":"Prototype gait approved by project owner, 2026-11-02"}
	var output:=FileAccess.open("res://assets/enemies/animations/loup_marche_v002.bin",FileAccess.WRITE)
	output.store_var(data);output.close()
	print("WOLF_RUNTIME_BAKED vertices=",rest.size()," triangles=",indices.size()/3," poses=",frames.size()," stride_pixels=",data.stride_pixels," bounds=",bounds)
	quit()
