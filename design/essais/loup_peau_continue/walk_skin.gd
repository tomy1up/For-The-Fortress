extends "continuous_skin.gd"
const Topology=preload("continuous_skin.gd")
const Ground=preload("../animation_loup_appuis/grounded_foot.gd")
const STRIDE:=0.8
const SOURCE_PER_UNIT:=940.0
var reference: Dictionary
var named: Dictionary={}
var rests: Dictionary={}
var poses: Dictionary={}
var contacts: Array[Dictionary]=[]
var reach_error:=0.0
var body_drop:=65.0
var body_reference:=false
var reference_means: Dictionary={}
var reference_body_scale:=0.0
var worst_reach: Dictionary={}
var control_indices: Dictionary={}
var legs: Array[Dictionary]=[
	{"key":"FrontNear","front":true,"side":"L","offset":Vector2.ZERO,"start":62.0/64.0,"duty":37.0/64.0},
	{"key":"FrontFar","front":true,"side":"R","offset":Vector2(20,-35),"start":34.0/64.0,"duty":34.0/64.0},
	{"key":"HindNear","front":false,"side":"L","offset":Vector2.ZERO,"start":52.0/64.0,"duty":39.0/64.0},
	{"key":"HindFar","front":false,"side":"R","offset":Vector2(20,-35),"start":20.0/64.0,"duty":39.0/64.0}]
func build() -> void:
	build_topology()
	reference=JSON.parse_string(FileAccess.get_file_as_string(get_script().resource_path.get_base_dir().path_join("reference_walk.json")))
	if body_reference:
		for label in ["FrontUpperLeg.L","FrontUpperLeg.R","BackLeg.L","BackLeg.R"]:
			var mean:=Vector3.ZERO
			for frame in range(64):
				var value: Array=reference.samples[frame][label]
				mean+=Vector3(value[0],value[1],value[2])/64.0
			reference_means[label]=mean
		reference_body_scale=500.0/(reference_means["FrontUpperLeg.L"].z-reference_means["BackLeg.L"].z)
	skeleton.name="Skeleton";add_child(skeleton)
	new_bone("Torso","",Vector2.ZERO)
	new_bone("Shoulder","Torso",Vector2(1000,500));new_bone("Pelvis","Torso",Vector2(500,470))
	new_bone("Head","Torso",Vector2(1130,420));new_bone("Tail","Torso",Vector2(500,470))
	for leg in legs:
		var parent: String="Shoulder" if leg.front else "Pelvis"
		var locations: Array=[Vector2(1000,500),Vector2(930,690),Vector2(1060,900)] if leg.front else [Vector2(500,470),Vector2(585,660),Vector2(415,810),Vector2(460,900)]
		leg["rest"]=locations
		for index in range(locations.size()):
			var label: String=leg.key+str(index)
			new_bone(label,parent,locations[index]+leg.offset);parent=label
	for index in range(bones.size()): influences.append(PackedFloat32Array())
	for point in points:
		var weights: Dictionary=weights_at(point,false)
		for index in range(bones.size()): influences[index].append(weights.get(str(bones[index].name),0.0))
	bind_skin()
	add_far_leg(true);add_far_leg(false)
	update_distance(0.0)
func build_topology() -> void:
	var image:=Image.load_from_file(get_script().resource_path.get_base_dir().path_join("loup_proche_source_v001.png"))
	var bitmap:=BitMap.new();bitmap.create_from_image_alpha(image,0.95)
	var outlines: Array[PackedVector2Array]=bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO,image.get_size()),4.0)
	var biggest:=0.0
	for outline in outlines:
		var area:=0.0
		for index in range(outline.size()): area+=outline[index].cross(outline[(index+1)%outline.size()])
		if absf(area)>biggest: biggest=absf(area);points=outline
	assert(not points.is_empty())
	var indices:=Geometry2D.triangulate_polygon(points)
	for index in range(0,indices.size(),3): triangles.append(PackedInt32Array([indices[index],indices[index+1],indices[index+2]]))
	var controls: Dictionary={"Torso":Vector2(750,450),"Shoulder":Vector2(1000,500),"Pelvis":Vector2(500,470),"Head":Vector2(1130,420),"Tail":Vector2(500,470),"FrontNear1":Vector2(930,690),"FrontNear2":Vector2(1060,900),"HindNear1":Vector2(585,660),"HindNear2":Vector2(415,810),"HindNear3":Vector2(460,900)}
	for label in controls:
		control_indices[label]=insert_control(controls[label])
	refine_long_edges(65.0)
func refine_long_edges(maximum: float) -> void:
	for iteration in range(4000):
		var largest: float=maximum*maximum;var a: int=-1;var b: int=-1
		for face in triangles:
			for edge in range(3):
				var length: float=points[face[edge]].distance_squared_to(points[face[(edge+1)%3]])
				if length>largest: largest=length;a=face[edge];b=face[(edge+1)%3]
		if a<0: return
		var index: int=points.size();points.append((points[a]+points[b])*0.5)
		var refined: Array[PackedInt32Array]=[]
		for face in triangles:
			if a not in face or b not in face: refined.append(face);continue
			for edge in range(3):
				if face[edge] not in [a,b] or face[(edge+1)%3] not in [a,b]: continue
				refined.append(PackedInt32Array([face[edge],index,face[(edge+2)%3]]))
				refined.append(PackedInt32Array([index,face[(edge+1)%3],face[(edge+2)%3]]));break
		triangles=refined
	assert(false,"Adaptive topology refinement exceeded its limit")
func insert_control(point: Vector2) -> int:
	for index in range(points.size()):
		if points[index].distance_to(point)<20.0: return index
	for face in triangles:
		for side in range(3):
			var a: int=face[side];var b: int=face[(side+1)%3]
			var projected: Vector2=Geometry2D.get_closest_point_to_segment(point,points[a],points[b])
			if projected.distance_to(point)>2.0: continue
			point=projected
			var result: int=points.size();points.append(point)
			var refined: Array[PackedInt32Array]=[]
			for candidate in triangles:
				if a not in candidate or b not in candidate: refined.append(candidate);continue
				for edge in range(3):
					if candidate[edge] not in [a,b] or candidate[(edge+1)%3] not in [a,b]: continue
					refined.append(PackedInt32Array([candidate[edge],result,candidate[(edge+2)%3]]))
					refined.append(PackedInt32Array([result,candidate[(edge+1)%3],candidate[(edge+2)%3]]));break
			triangles=refined;return result
	for face_index in range(triangles.size()):
		var face: PackedInt32Array=triangles[face_index]
		if not Geometry2D.is_point_in_polygon(point,PackedVector2Array([points[face[0]],points[face[1]],points[face[2]]])): continue
		var result: int=points.size();points.append(point);triangles.remove_at(face_index)
		for edge in range(3): triangles.append(PackedInt32Array([face[edge],face[(edge+1)%3],result]))
		return result
	return -1
func new_bone(label: String,parent_label: String,position_value: Vector2) -> void:
	var parent: Node=skeleton if parent_label.is_empty() else named[parent_label]
	var local: Vector2=position_value if parent_label.is_empty() else position_value-rests[parent_label].origin
	make_bone(label,parent,local)
	named[label]=bones[-1];rests[label]=Transform2D(0,position_value)
func head_blend_at(point: Vector2) -> float:
	var neck_edge: float=900.0+(point.y-250.0)*0.55
	var chin_edge: float=440.0+clampf((point.x-1000.0)/200.0,0.0,1.0)*120.0
	return smoothstep(neck_edge-50.0,neck_edge+50.0,point.x)*(1.0-smoothstep(chin_edge-60.0,chin_edge+60.0,point.y))
func tail_blend_at(point: Vector2) -> float:
	return (1.0-smoothstep(380,520,point.x))*(1.0-smoothstep(530,650,point.y))
func weights_at(point: Vector2,far: bool) -> Dictionary:
	var front_edge: float=965.0-0.33*(point.y-450.0)
	var hind_edge: float=lerpf(700,680,clampf((point.y-480.0)/120.0,0,1)) if point.y<=600 else lerpf(680,500,clampf((point.y-600.0)/120.0,0,1))
	var f: float=smoothstep(450,680,point.y)*smoothstep(front_edge-45,front_edge+5,point.x)
	var h: float=smoothstep(450,680,point.y)*(1.0-smoothstep(hind_edge-25,hind_edge+25,point.x))
	f*=1.0-smoothstep(1060,1200,point.x)*(1.0-smoothstep(540,650,point.y))
	h*=1.0-(1.0-smoothstep(330,450,point.x))*(1.0-smoothstep(640,730,point.y))
	var head: float=head_blend_at(point)
	var tail: float=tail_blend_at(point)
	f*=1.0-head;h*=1.0-tail
	var body: float=1.0-f-h
	var shoulder: float=smoothstep(600,1000,point.x)
	var pelvis: float=1.0-smoothstep(450,750,point.x)
	var torso: float=body*(1.0-head-tail)
	var result: Dictionary={"Torso":torso*(1.0-shoulder-pelvis),"Shoulder":torso*shoulder,"Pelvis":torso*pelvis,"Head":body*head,"Tail":body*tail}
	var front: String="FrontFar" if far else "FrontNear"
	var hind: String="HindFar" if far else "HindNear"
	var lower: float=smoothstep(660,800,point.y);var paw: float=smoothstep(855,905,point.y)
	result[front+"0"]=f*(1.0-lower);result[front+"1"]=f*lower*(1.0-paw);result[front+"2"]=f*lower*paw
	var mid: float=smoothstep(600,720,point.y);lower=smoothstep(760,850,point.y)
	result[hind+"0"]=h*(1.0-mid);result[hind+"1"]=h*mid*(1.0-lower);result[hind+"2"]=h*mid*lower*(1.0-paw);result[hind+"3"]=h*mid*lower*paw
	return result
func add_far_leg(front: bool) -> void:
	var outline:=PackedVector2Array([Vector2(920,565),Vector2(1040,565),Vector2(1090,700),Vector2(1080,820),Vector2(1220,900),Vector2(1220,980),Vector2(910,980),Vector2(900,800),Vector2(880,650)]) if front else PackedVector2Array([Vector2(485,520),Vector2(700,520),Vector2(650,660),Vector2(530,770),Vector2(510,850),Vector2(620,900),Vector2(620,980),Vector2(300,980),Vector2(300,820),Vector2(360,700),Vector2(420,620)])
	var helper:=Topology.new();helper.points=outline
	var indices:=Geometry2D.triangulate_polygon(outline)
	for index in range(0,indices.size(),3): helper.triangles.append(PackedInt32Array([indices[index],indices[index+1],indices[index+2]]))
	for level in range(3): helper.subdivide()
	var polygon:=Polygon2D.new();add_child(polygon);move_child(polygon,skin.get_index())
	polygon.texture=skin.texture;polygon.modulate=Color(0.65,0.65,0.65,1)
	var vertices:=PackedVector2Array()
	for point in helper.points: vertices.append(point+Vector2(20,-35))
	polygon.polygon=vertices;polygon.uv=helper.points
	var faces: Array=[]
	for triangle in helper.triangles: faces.append(triangle)
	polygon.polygons=faces;polygon.skeleton=polygon.get_path_to(skeleton)
	for bone in bones:
		var values:=PackedFloat32Array()
		for point in helper.points: values.append(weights_at(point,true).get(str(bone.name),0.0))
		polygon.add_bone(skeleton.get_path_to(bone),values)
	helper.skin.free();helper.skeleton.free();helper.free()
func ref_point(label: String,phase: float) -> Vector3:
	var at: float=fposmod(phase,1.0)*64.0
	var index: int=int(floor(at));var t: float=at-index
	var values: Array[Vector3]=[]
	for delta in [-1,0,1,2]:
		var p: Array=reference.samples[(index+delta+64)%64][label]
		values.append(Vector3(p[0],p[1],p[2]))
	return 0.5*((2.0*values[1])+(-values[0]+values[2])*t+(2.0*values[0]-5.0*values[1]+4.0*values[2]-values[3])*t*t+(-values[0]+3.0*values[1]-3.0*values[2]+values[3])*t*t*t)
static func source_root(distance: float) -> Vector2: return Vector2(distance*SOURCE_PER_UNIT,0)
func foot_goal(leg: Dictionary,distance: float) -> Dictionary:
	var center:=Vector2(1040,900) if leg.front else Vector2(550,900)
	var sample: Dictionary=Ground.sample(distance,STRIDE,-leg.start,leg.duty,0,source_root,center+leg.offset)
	if not sample.support:
		var bone: String=("FF." if leg.front else "FFB.")+leg.side
		var foot: Vector3=ref_point(bone,distance/STRIDE)
		var floor_y: float=0.0716 if leg.front and leg.side=="L" else 0.069
		var swing: float=(sample.phase-leg.duty)/(1.0-leg.duty)
		var envelope: float=smoothstep(0,0.15,swing)*(1.0-smoothstep(0.85,1.0,swing))
		sample.world.y-=maxf(0.0,foot.y-floor_y-0.012)*340.0*envelope
	sample["local"]=sample.world-source_root(distance)
	return sample
func put(label: String,value: Transform2D) -> void:
	poses[label]=value
	var bone: Bone2D=named[label]
	var parent_label: String=str(bone.get_parent().name)
	bone.transform=poses[parent_label].affine_inverse()*value if poses.has(parent_label) else value
func reference_attachment(front: bool,side: String,phase: float) -> Vector2:
	var label: String=("FrontUpperLeg." if front else "BackLeg.")+side
	var delta: Vector3=ref_point(label,phase)-reference_means[label]
	var base:=Vector2(1000,500) if front else Vector2(500,470)
	return base+Vector2(0,body_drop)+Vector2(delta.z,-delta.y)*reference_body_scale
func update_distance(distance: float) -> void:
	contacts.clear();poses.clear()
	var phase: float=distance/STRIDE
	var back: Vector3=ref_point("Back",phase);var chest: Vector3=ref_point("Torso3",phase)
	var pitch: float=clampf((chest.y-back.y+0.18)*0.25,-0.03,0.03)
	var pivot:=Vector2(750,500)
	var torso:=Transform2D(pitch,Vector2.ZERO)
	torso.origin=pivot-torso*pivot+Vector2(0,body_drop-(back.y-1.86)*120.0)
	var shoulder_origin: Vector2=torso*Vector2(1000,500)
	var pelvis_origin: Vector2=torso*Vector2(500,470)
	if body_reference:
		shoulder_origin=reference_attachment(true,"L",phase)
		pelvis_origin=reference_attachment(false,"L",phase)
		pitch=(shoulder_origin-pelvis_origin).angle()-Vector2(500,30).angle()
		torso=Transform2D(pitch,Vector2.ZERO)
		torso.origin=(shoulder_origin+pelvis_origin)*0.5-torso*Vector2(750,485)
	put("Torso",torso)
	put("Shoulder",Transform2D(pitch,shoulder_origin))
	put("Pelvis",Transform2D(pitch,pelvis_origin))
	var head: Vector3=ref_point("Head",phase)-ref_point("Neck3",phase)
	put("Head",Transform2D(clampf(atan2(-head.y,head.z)+0.31,-0.07,0.07),torso*Vector2(1130,420)))
	var tail: Vector3=ref_point("Tail8",phase)-ref_point("Tail1",phase)
	put("Tail",Transform2D(pitch+clampf(atan2(tail.y,-tail.z)+0.31,-0.09,0.09),torso*Vector2(500,470)))
	for leg in legs:
		var goal: Dictionary=foot_goal(leg,distance)
		var hip: Vector2=torso*(leg.rest[0]+leg.offset)
		if body_reference:
			hip=reference_attachment(leg.front,leg.side,phase)+torso.basis_xform(leg.offset)
		var target: Vector2=goal.local
		if leg.front:
			solve_pair(leg,hip,target,0,1,2)
		else:
			var vector: Vector3=ref_point("FFB."+leg.side,phase)-ref_point("BackLowerLeg."+leg.side,phase)
			var angle: float=atan2(-vector.y,vector.z)
			var length: float=leg.rest[2].distance_to(leg.rest[3])
			var hock: Vector2=target-Vector2.from_angle(angle)*length
			var reach: float=leg.rest[0].distance_to(leg.rest[1])+leg.rest[1].distance_to(leg.rest[2])-0.01
			if hip.distance_to(hock)>reach:
				var lo:=0.0;var hi:=1.0
				for iteration in range(20):
					var t: float=(lo+hi)*0.5
					var next: Vector2=target-Vector2.from_angle(lerp_angle(angle,(target-hip).angle(),t))*length
					if hip.distance_to(next)<=reach: hi=t
					else: lo=t
				hock=target-Vector2.from_angle(lerp_angle(angle,(target-hip).angle(),hi))*length
			solve_pair(leg,hip,hock,0,1,2)
			var lower: Vector2=poses[leg.key+"2"].origin
			put(leg.key+"2",Transform2D((target-lower).angle()-(leg.rest[3]-leg.rest[2]).angle(),lower))
			put(leg.key+"3",Transform2D(0,target))
		var last: String=leg.key+("2" if leg.front else "3")
		var actual: Vector2=poses[last].origin+source_root(distance)
		contacts.append({"leg":leg.key,"support":goal.support,"cycle":goal.cycle,"world":actual,"desired":goal.world})
	var shoulder_pose: Transform2D=poses.Shoulder
	var pelvis_pose: Transform2D=poses.Pelvis
	if not body_reference:
		shoulder_pose=Transform2D(lerp_angle(pitch,poses.FrontNear0.get_rotation(),0.25),shoulder_pose.origin)
		pelvis_pose=Transform2D(lerp_angle(pitch,poses.HindNear0.get_rotation(),0.2),pelvis_pose.origin)
	put("Shoulder",shoulder_pose);put("Pelvis",pelvis_pose)
	for leg in legs:
		for index in range(leg.rest.size()): put(leg.key+str(index),poses[leg.key+str(index)])
	var head_pose: Transform2D=poses.Head
	head_pose.origin=shoulder_pose*rests.Shoulder.affine_inverse()*Vector2(1130,420)
	put("Head",head_pose)
	var tail_pose: Transform2D=poses.Tail
	tail_pose.origin=pelvis_pose*rests.Pelvis.affine_inverse()*Vector2(500,470)
	put("Tail",tail_pose)
func solve_pair(leg: Dictionary,hip: Vector2,target: Vector2,a: int,b: int,c: int) -> void:
	var upper: float=leg.rest[a].distance_to(leg.rest[b]);var lower: float=leg.rest[b].distance_to(leg.rest[c])
	var delta: Vector2=target-hip
	var length: float=clampf(delta.length(),absf(upper-lower)+0.01,upper+lower-0.01)
	var resolved: Vector2=hip+delta.normalized()*length
	if resolved.distance_to(target)>reach_error:
		reach_error=resolved.distance_to(target)
		worst_reach={"leg":leg.key,"hip":hip,"target":target,"length":delta.length(),"reach":upper+lower}
	var bend: float=signf((leg.rest[c]-leg.rest[a]).cross(leg.rest[b]-leg.rest[a]))
	var angle: float=delta.angle()+bend*acos(clampf((upper*upper+length*length-lower*lower)/(2.0*upper*length),-1.0,1.0))
	var knee: Vector2=hip+Vector2.from_angle(angle)*upper
	put(leg.key+str(a),Transform2D((knee-hip).angle()-(leg.rest[b]-leg.rest[a]).angle(),hip))
	put(leg.key+str(b),Transform2D((resolved-knee).angle()-(leg.rest[c]-leg.rest[b]).angle(),knee))
	put(leg.key+str(c),Transform2D(0,resolved))
