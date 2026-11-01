extends Node2D
## Native GPU skinning experiment, NOT a walk cycle or a game integration.
var points:=PackedVector2Array()
var triangles: Array[PackedInt32Array]=[]
var influences: Array[PackedFloat32Array]=[]
var skeleton:=Skeleton2D.new()
var skin:=Polygon2D.new()
var bones: Array[Bone2D]=[]
func build() -> void:
	build_topology()
	skeleton.name="Skeleton";add_child(skeleton)
	make_bone("Torso",skeleton,Vector2(750,500))
	make_bone("Front",bones[0],Vector2(250,35))
	make_bone("FrontLower",bones[1],Vector2(20,175))
	make_bone("Hind",bones[0],Vector2(-170,0))
	make_bone("HindLower",bones[3],Vector2(-80,190))
	for index in range(5): influences.append(PackedFloat32Array())
	for point in points:
		var front: float=smoothstep(450,680,point.y)*smoothstep(760,980,point.x)
		var hind: float=smoothstep(450,680,point.y)*(1.0-smoothstep(600,760,point.x))
		front*=1.0-smoothstep(1100,1200,point.x)*(1.0-smoothstep(550,650,point.y))
		hind*=1.0-(1.0-smoothstep(330,450,point.x))*(1.0-smoothstep(640,730,point.y))
		var lower_front: float=smoothstep(680,820,point.y)
		var lower_hind: float=smoothstep(650,820,point.y)
		var weights: Array[float]=[1.0-front-hind,front*(1.0-lower_front),front*lower_front,hind*(1.0-lower_hind),hind*lower_hind]
		for index in range(5): influences[index].append(weights[index])
	bind_skin()
func build_topology() -> void:
	points=PackedVector2Array([Vector2(120,220),Vector2(500,180),Vector2(800,120),Vector2(960,40),Vector2(1430,70),Vector2(1450,650),Vector2(1200,700),Vector2(1230,980),Vector2(900,980),Vector2(880,720),Vector2(720,690),Vector2(620,700),Vector2(620,980),Vector2(300,980),Vector2(300,740),Vector2(80,700)])
	var indices:=Geometry2D.triangulate_polygon(points)
	for index in range(0,indices.size(),3): triangles.append(PackedInt32Array([indices[index],indices[index+1],indices[index+2]]))
	for level in range(3): subdivide()
func bind_skin() -> void:
	skin.name="ContinuousSkin";add_child(skin)
	skin.polygon=points;skin.uv=points
	var faces: Array=[]
	for triangle in triangles: faces.append(triangle)
	skin.polygons=faces
	skin.texture=ImageTexture.create_from_image(Image.load_from_file(get_script().resource_path.get_base_dir().path_join("loup_proche_source_v001.png")))
	skin.skeleton=skin.get_path_to(skeleton)
	for index in range(bones.size()): skin.add_bone(skeleton.get_path_to(bones[index]),influences[index])
func make_bone(label: String,parent: Node,position_value: Vector2) -> void:
	var bone:=Bone2D.new();bone.name=label;bone.position=position_value
	bone.set_autocalculate_length_and_angle(false);bone.set_length(150)
	bone.rest=bone.transform;parent.add_child(bone);bones.append(bone)
func midpoint(a: int,b: int,cache: Dictionary) -> int:
	var key:=Vector2i(mini(a,b),maxi(a,b))
	if cache.has(key): return cache[key]
	var index: int=points.size();points.append((points[a]+points[b])*0.5);cache[key]=index
	return index
func subdivide() -> void:
	var cache: Dictionary={};var refined: Array[PackedInt32Array]=[]
	for triangle in triangles:
		var a: int=triangle[0];var b: int=triangle[1];var c: int=triangle[2]
		var ab: int=midpoint(a,b,cache);var bc: int=midpoint(b,c,cache);var ca: int=midpoint(c,a,cache)
		refined.append_array([PackedInt32Array([a,ab,ca]),PackedInt32Array([ab,b,bc]),PackedInt32Array([ca,bc,c]),PackedInt32Array([ab,bc,ca])])
	triangles=refined
func pose(phase: float) -> void:
	# Small bend only. No ground contacts or complete locomotion are claimed.
	for bone in bones: bone.apply_rest()
	bones[1].rotation=deg_to_rad(7)*sin(TAU*phase)
	bones[2].rotation=-deg_to_rad(4)*sin(TAU*phase)
	bones[3].rotation=-deg_to_rad(4)*sin(TAU*phase)
	bones[4].rotation=deg_to_rad(3)*sin(TAU*phase)
func topology_report() -> Dictionary:
	var graph: Dictionary={}
	for face in triangles:
		for index in range(3):
			var a: int=face[index];var b: int=face[(index+1)%3]
			if not graph.has(a): graph[a]=[]
			if not graph.has(b): graph[b]=[]
			graph[a].append(b);graph[b].append(a)
	var seen: Dictionary={};var pending: Array[int]=[0]
	while not pending.is_empty():
		var index: int=pending.pop_back()
		if seen.has(index): continue
		seen[index]=true
		for neighbor in graph.get(index,[]):
			if not seen.has(neighbor): pending.append(neighbor)
	var maximum_error:=0.0
	for vertex in range(points.size()):
		var total:=0.0
		for weights in influences: total+=weights[vertex]
		maximum_error=maxf(maximum_error,absf(1.0-total))
	return {"vertices":points.size(),"triangles":triangles.size(),"connected_vertices":seen.size(),"bones":skin.get_bone_count(),"weight_sum_error":maximum_error,"single_connected_skin":seen.size()==points.size()}
