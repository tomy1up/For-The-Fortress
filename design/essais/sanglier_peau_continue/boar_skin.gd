extends "../loup_peau_continue/walk_skin.gd"
## Separate authoring rig. No production script, gameplay data or profile access.
const CYCLE_DISTANCE:=700.0
const FAR_OFFSET:=Vector2(22,-24)
func build() -> void:
	skin.free() # This authoring rig exports constraints; it does not render the raw bone weights.
	build_topology()
	skeleton.name="Skeleton";add_child(skeleton)
	new_bone("Torso","",Vector2.ZERO)
	new_bone("Shoulder","Torso",Vector2(930,550));new_bone("Pelvis","Torso",Vector2(445,550))
	new_bone("Head","Torso",Vector2(1100,470));new_bone("Tail","Torso",Vector2(350,510))
	legs=[
		{"key":"FrontNear","front":true,"offset":Vector2.ZERO,"start":0.0,"duty":0.59375},
		{"key":"HindNear","front":false,"offset":Vector2.ZERO,"start":0.5,"duty":0.59375},
		{"key":"FrontFar","front":true,"offset":FAR_OFFSET,"start":0.5,"duty":0.59375},
		{"key":"HindFar","front":false,"offset":FAR_OFFSET,"start":0.0,"duty":0.59375}]
	for leg in legs:
		var parent: String="Shoulder" if leg.front else "Pelvis"
		var locations: Array=[Vector2(930,550),Vector2(950,750),Vector2(1010,936)] if leg.front else [Vector2(445,550),Vector2(470,700),Vector2(325,815),Vector2(320,936)]
		leg["rest"]=locations
		for index in range(locations.size()):
			var label: String=leg.key+str(index)
			new_bone(label,parent,locations[index]+leg.offset);parent=label
	update_distance(0)
func build_topology() -> void:
	var image:=Image.load_from_file(get_script().resource_path.get_base_dir().path_join("sanglier_proche_source_v001.png"))
	var bitmap:=BitMap.new();bitmap.create_from_image_alpha(image,0.95)
	var outlines:=bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO,image.get_size()),3.0)
	var biggest:=0.0
	for outline in outlines:
		var area:=0.0
		for index in range(outline.size()): area+=outline[index].cross(outline[(index+1)%outline.size()])
		if absf(area)>biggest: biggest=absf(area);points=outline
	assert(not points.is_empty())
	var indices:=Geometry2D.triangulate_polygon(points)
	for index in range(0,indices.size(),3):
		var face:=PackedInt32Array([indices[index],indices[index+1],indices[index+2]])
		if (points[face[1]]-points[face[0]]).cross(points[face[2]]-points[face[0]])<0: face.reverse()
		triangles.append(face)
	var controls: Dictionary={"Torso":Vector2(720,440),"Shoulder":Vector2(930,550),"Pelvis":Vector2(445,550),"Head":Vector2(1100,470),"Tail":Vector2(350,510),"FrontNear1":Vector2(950,750),"FrontNear2":Vector2(1010,936),"HindNear1":Vector2(470,700),"HindNear2":Vector2(325,815),"HindNear3":Vector2(320,936)}
	for label in controls: control_indices[label]=insert_control(controls[label])
	refine_long_edges(65.0)
func surface_weights(point: Vector2) -> Array[float]:
	var shoulder:=smoothstep(480,930,point.x)
	var head:=smoothstep(865,1130,point.x)*(1.0-smoothstep(660,790,point.y))
	var tail: float=(1.0-smoothstep(280,380,point.x))*(1.0-smoothstep(560,650,point.y))
	return [shoulder,1.0-shoulder,head,tail]
func surface_point(point: Vector2) -> Vector2:
	var weights:=surface_weights(point)
	var result: Vector2=(poses.Shoulder*rests.Shoulder.affine_inverse()*point)*weights[0]
	result+=(poses.Pelvis*rests.Pelvis.affine_inverse()*point)*weights[1]
	result=result.lerp(poses.Head*rests.Head.affine_inverse()*point,weights[2])
	return result.lerp(poses.Tail*rests.Tail.affine_inverse()*point,weights[3])
static func root_at(distance: float) -> Vector2: return Vector2(distance,0)
func foot_goal(leg: Dictionary,distance: float) -> Dictionary:
	var center: Vector2=(Vector2(930,936) if leg.front else Vector2(445,936))+leg.offset
	var result:=Ground.sample(distance,CYCLE_DISTANCE,-leg.start,leg.duty,110.0,root_at,center)
	result["local"]=result.world-root_at(distance)
	return result
func update_distance(distance: float) -> void:
	contacts.clear();poses.clear()
	var phase: float=distance/CYCLE_DISTANCE
	var roll: float=sin(TAU*(phase-0.1))
	var rise: float=70.0+5.0*cos(TAU*2.0*phase)
	var shoulder:=Vector2(930,550)+Vector2(3.0*sin(TAU*phase),rise+8.0*roll)
	var pelvis:=Vector2(445,550)+Vector2(-3.0*sin(TAU*phase),rise-8.0*roll)
	var pitch: float=(shoulder-pelvis).angle()
	var torso:=Transform2D(pitch,(shoulder+pelvis)*0.5)
	torso.origin-=torso.basis_xform(Vector2(687.5,550))
	put("Torso",torso);put("Shoulder",Transform2D(pitch,shoulder));put("Pelvis",Transform2D(pitch,pelvis))
	var head_anchor: Vector2=poses.Shoulder*rests.Shoulder.affine_inverse()*rests.Head.origin
	put("Head",Transform2D(pitch+0.012*sin(TAU*(phase-0.12)),head_anchor))
	var tail_anchor: Vector2=poses.Pelvis*rests.Pelvis.affine_inverse()*rests.Tail.origin
	put("Tail",Transform2D(pitch+0.035*sin(TAU*(phase-0.2)),tail_anchor))
	for leg in legs:
		var goal:=foot_goal(leg,distance)
		var attachment: Transform2D=poses.Shoulder if leg.front else poses.Pelvis
		var hip: Vector2=attachment.origin+torso.basis_xform(leg.offset)
		var target: Vector2=goal.local
		if leg.front: solve_pair(leg,hip,target,0,1,2)
		else:
			# Keep the hock above the planted hoof; the thigh and shin solve the remaining reach.
			var length: float=leg.rest[2].distance_to(leg.rest[3])
			var direction:=Vector2(5.0+12.0*sin(TAU*phase),-121.0).normalized()
			var hock: Vector2=target+direction*length
			var reach: float=leg.rest[0].distance_to(leg.rest[1])+leg.rest[1].distance_to(leg.rest[2])-0.01
			if hip.distance_to(hock)>reach:
				var first:=0.0;var last:=1.0
				for iteration in range(24):
					var blend: float=(first+last)*0.5
					var candidate: Vector2=target+direction.lerp((hip-target).normalized(),blend).normalized()*length
					if hip.distance_to(candidate)>reach: first=blend
					else: last=blend
				hock=target+direction.lerp((hip-target).normalized(),last).normalized()*length
			solve_pair(leg,hip,hock,0,1,2)
			var lower: Vector2=poses[leg.key+"2"].origin
			put(leg.key+"2",Transform2D((target-lower).angle()-(leg.rest[3]-leg.rest[2]).angle(),lower))
			put(leg.key+"3",Transform2D(0,target))
		contacts.append({"leg":leg.key,"support":goal.support,"cycle":goal.cycle,"world":poses[leg.key+("2" if leg.front else "3")].origin+root_at(distance),"desired":goal.world})
