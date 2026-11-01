extends RefCounted
const Contact=preload("grounded_foot.gd")
const SCALE=34.0/850.0
const FOOT=Vector2(640,850)
const STRIDE=0.6
var texture: Texture2D
var body: ArrayMesh
var retained: Array[ArrayMesh]=[]
var max_support_error_pixels: float=0.0
var max_attachment_shift_pixels: float=0.0
var contacts: Array[Dictionary]=[]
var measure_only:=false
var shapes: Array[PackedVector2Array]=[]
var source_legs: Array[Dictionary]=[
	{"hip":Vector2(320,750),"knee":Vector2(300,930),"foot":Vector2(355,1185),"area":Rect2(150,620,340,630)},
	{"hip":Vector2(930,760),"knee":Vector2(880,1030),"foot":Vector2(970,1185),"area":Rect2(760,630,380,620)}]
var legs: Array[Dictionary]=[
	{"source":1,"hip":Vector2(435,420),"center":Vector2(480,800),"phase":0.75,"size":1.0},
	{"source":1,"hip":Vector2(490,400),"center":Vector2(480,740),"phase":0.25,"size":0.9},
	{"source":0,"hip":Vector2(815,450),"center":Vector2(800,800),"phase":0.0,"size":1.0},
	{"source":0,"hip":Vector2(870,430),"center":Vector2(800,740),"phase":0.5,"size":0.9}]
func _init() -> void:
	texture=ImageTexture.create_from_image(Image.load_from_file(get_script().resource_path.get_base_dir().path_join("loup_pieces_essai.png")))
	for leg in source_legs: shapes.append(grid(leg.area,16,24))
	var points:=grid(Rect2(0,0,1280,620),1,1)
	body=mesh(points,points)
func grid(area: Rect2,cols: int,rows: int) -> PackedVector2Array:
	var result:=PackedVector2Array()
	for y in range(rows):
		for x in range(cols):
			var a: Vector2=area.position+area.size*Vector2(float(x)/cols,float(y)/rows)
			var b: Vector2=area.position+area.size*Vector2(float(x+1)/cols,float(y)/rows)
			var c: Vector2=area.position+area.size*Vector2(float(x+1)/cols,float(y+1)/rows)
			var d: Vector2=area.position+area.size*Vector2(float(x)/cols,float(y+1)/rows)
			result.append_array(PackedVector2Array([a,b,c,a,c,d]))
	return result
func mesh(points: PackedVector2Array,source: PackedVector2Array) -> ArrayMesh:
	var positions:=PackedVector3Array();var uv:=PackedVector2Array()
	for index in range(points.size()):
		var p: Vector2=(points[index]-FOOT)*SCALE
		positions.append(Vector3(p.x,p.y,0));uv.append(source[index]/Vector2(texture.get_size()))
	var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=positions;arrays[Mesh.ARRAY_TEX_UV]=uv
	var result:=ArrayMesh.new();result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);return result
static func root_at(progress: float) -> Vector2: return Vector2(progress*27,progress*13.5)
func draw(canvas: CanvasItem,distance: float,id: int=0,path: Callable=Callable(),direction: Callable=Callable()) -> void:
	retained.clear()
	contacts.clear()
	if not path.is_valid(): path=root_at
	var facing: float=direction.call(distance) if direction.is_valid() else 1.0
	var root: Vector2=path.call(distance)
	var bob: float=0.20*cos(TAU*2.0*(distance/STRIDE+id*0.137))
	var desired_contacts: Array[Dictionary]=[]
	for index in range(4):
		var leg: Dictionary=legs[index]
		var phase_offset: float=leg.phase+id*0.137
		var cycle: int=int(floor(distance/STRIDE+phase_offset))
		var planted_at: float=(cycle-phase_offset)*STRIDE
		var anchor_facing: float=direction.call(planted_at) if direction.is_valid() else 1.0
		var next_facing: float=direction.call(planted_at+STRIDE) if direction.is_valid() else 1.0
		var offset: Vector2=(leg.center-FOOT)*SCALE*0.7
		var next_offset: Vector2=Vector2(offset.x*next_facing,offset.y)
		offset.x*=anchor_facing
		var contact:=Contact.sample(distance,STRIDE,phase_offset,0.6,1.5,path,offset,next_offset)
		desired_contacts.append(contact)
	var assignment: Array[int]=[0,1,2,3]
	for pair in [[0,2],[1,3]]:
		var straight: float=assignment_cost(pair[0],desired_contacts[pair[0]],root,facing)+assignment_cost(pair[1],desired_contacts[pair[1]],root,facing)
		var swapped: float=assignment_cost(pair[0],desired_contacts[pair[1]],root,facing)+assignment_cost(pair[1],desired_contacts[pair[0]],root,facing)
		if swapped<straight:
			assignment[pair[0]]=pair[1];assignment[pair[1]]=pair[0]
	for index in [1,3,0,2]:
		var leg: Dictionary=legs[index];var rest: Dictionary=source_legs[leg.source]
		var contact_id: int=assignment[index]
		var contact: Dictionary=desired_contacts[contact_id]
		var local: Vector2=(contact.world-root)/(SCALE*0.7);local.x/=facing
		var target: Vector2=FOOT+local
		var hip: Vector2=leg.hip+Vector2(0,bob/SCALE)
		var upper: float=rest.hip.distance_to(rest.knee)*leg.size;var lower: float=rest.knee.distance_to(rest.foot)*leg.size
		var delta: Vector2=target-hip
		var reach: float=upper+lower-0.001
		# Limited movement of the hidden shoulder/hip attachment; never stretch the leg.
		var attachment_shift: Vector2=delta.normalized()*minf(maxf(0.0,delta.length()-reach),3.3/(SCALE*0.7))
		hip+=attachment_shift
		max_attachment_shift_pixels=maxf(max_attachment_shift_pixels,attachment_shift.length()*SCALE*0.7)
		delta=target-hip
		var length: float=clampf(delta.length(),absf(upper-lower)+0.001,upper+lower-0.001)
		var desired: Vector2=target
		target=hip+delta.normalized()*length
		if contact.support: max_support_error_pixels=maxf(max_support_error_pixels,desired.distance_to(target)*SCALE*0.7)
		contacts.append({"leg":contact_id,"role":index,"cycle":contact.cycle,"support":contact.support,"desired_world":contact.world,"world":root+Vector2((target.x-FOOT.x)*facing,target.y-FOOT.y)*SCALE*0.7})
		var bend: float=signf((rest.foot-rest.hip).cross(rest.knee-rest.hip))
		var cosine: float=clampf((upper*upper+length*length-lower*lower)/(2*upper*length),-1,1)
		var knee: Vector2=hip+Vector2.from_angle(delta.angle()+bend*acos(cosine))*upper
		var first: Transform2D=mapping(hip,knee,rest.hip,rest.knee,leg.size)
		var second: Transform2D=mapping(knee,target,rest.knee,rest.foot,leg.size)
		if measure_only: continue
		var points:=PackedVector2Array()
		for source in shapes[leg.source]:
			var blend: float=smoothstep(rest.knee.y-45,rest.knee.y+45,source.y)
			var point: Vector2=(first*source).lerp(second*source,blend)
			var paw: float=smoothstep(rest.foot.y-90,rest.foot.y-30,source.y)
			point=point.lerp((source-rest.foot)*leg.size+target,paw)
			points.append(point)
		var art:=mesh(points,shapes[leg.source]);retained.append(art)
		canvas.draw_mesh(art,texture,Transform2D.IDENTITY,Color(0.65,0.65,0.65,1) if index in [1,3] else Color.WHITE)
	if not measure_only: canvas.draw_mesh(body,texture,Transform2D(0.0,Vector2(0,bob)))
func mapping(first: Vector2,last: Vector2,rest_first: Vector2,rest_last: Vector2,size: float) -> Transform2D:
	var result:=Transform2D((last-first).angle()-(rest_last-rest_first).angle(),Vector2.ONE*size,0,Vector2.ZERO)
	result.origin=first-result*rest_first;return result

func assignment_cost(index: int,contact: Dictionary,root: Vector2,facing: float)->float:
	var leg: Dictionary=legs[index];var rest: Dictionary=source_legs[leg.source]
	var local: Vector2=(contact.world-root)/(SCALE*0.7);local.x/=facing
	var target: Vector2=FOOT+local
	var length: float=leg.hip.distance_to(target)
	var upper: float=rest.hip.distance_to(rest.knee)*leg.size
	var lower: float=rest.knee.distance_to(rest.foot)*leg.size
	var excess: float=absf(length-clampf(length,absf(upper-lower)+0.001,upper+lower-0.001))
	return excess*excess*(10000.0 if contact.support else 1.0)+0.00001*leg.center.distance_squared_to(target)
