extends RefCounted
## Approved wolf gait. Pure visual sampling; no combat or profile mutations.
const WOLF_ID := "enemy.neutral.wolf"
const TEXTURE=preload("res://assets/enemies/animations/loup_corps_v002.png")
static var DATA: Dictionary=_load_motion()
static var BOUNDS: Rect2=DATA.bounds
var meshes: Dictionary={}
var used_ids: Dictionary={}

static func _load_motion() -> Dictionary:
	var file:=FileAccess.open("res://assets/enemies/animations/loup_marche_v002.bin",FileAccess.READ)
	assert(file!=null,"Approved wolf motion data missing")
	var data: Dictionary=file.get_var(false);file.close()
	assert(data.schema==3 and data.frames.size()==129 and data.frames.size()==data.tangents.size())
	assert(data.rest.size()==data.fixed.size() and data.rest.size()==data.uv.size())
	return data

static func supports(id: String) -> bool: return id==WOLF_ID

static func path_motion(distance: float,points: Array[Vector2],axis: Vector2=Vector2(27,13.5)) -> Dictionary:
	var remaining: float=maxf(0.0,distance);var projected:=0.0;var direction:=Vector2.RIGHT
	for index in range(points.size()-1):
		var delta: Vector2=points[index+1]-points[index]
		var length: float=delta.length()
		if length<=0: continue
		var screen:=Vector2((delta.x-delta.y)*axis.x,(delta.x+delta.y)*axis.y)
		direction=screen.normalized()
		if remaining<length-0.000000001:
			projected+=screen.length()*remaining/length
			return {"travel":projected,"direction":direction}
		projected+=screen.length();remaining-=length
	return {"travel":projected,"direction":direction}

static func phase_for(travel: float,enemy_id: int=0,actor_scale: float=1.0) -> float:
	return fposmod(maxf(0.0,travel)/(DATA.stride_pixels*maxf(actor_scale,0.001))+maxi(0,enemy_id)*0.137,1.0)

static func ground_basis(direction: Vector2) -> Vector2:
	# Keep a visible profile for future frontal routes; the current playable
	# routes all use the four isometric diagonal screen directions.
	return Vector2.RIGHT if absf(direction.x)<0.05 else Vector2(absf(direction.x),direction.y).normalized()

static func projected_bounds(direction: Vector2) -> Rect2:
	var ground:=ground_basis(direction)
	return Transform2D(ground,Vector2(-ground.y,ground.x),Vector2.ZERO)*BOUNDS

static func sample_vertices(phase: float,ground_direction: Vector2=Vector2.RIGHT) -> PackedVector2Array:
	var at: float=fposmod(phase,1.0)*128.0
	var first: int=int(floor(at));var t: float=at-first
	var a: PackedVector2Array=DATA.frames[first];var b: PackedVector2Array=DATA.frames[first+1]
	var ma: PackedVector2Array=DATA.tangents[first];var mb: PackedVector2Array=DATA.tangents[first+1]
	var h00: float=2*t*t*t-3*t*t+1;var h01: float=-2*t*t*t+3*t*t
	var h10: float=(t*t*t-2*t*t+t)/128.0;var h11: float=(t*t*t-t*t)/128.0
	var fixed: PackedByteArray=DATA.fixed
	var ground:=ground_basis(ground_direction)
	var result:=PackedVector2Array();result.resize(a.size())
	for index in range(a.size()):
		var point: Vector2=a[index].lerp(b[index],t) if fixed[index]==1 else a[index]*h00+b[index]*h01+ma[index]*h10+mb[index]*h11
		# Rigid orientation preserves the approved silhouette, lengths and angles.
		# A vertical second axis would shear the drawing on diagonal paths.
		result[index]=Vector2(point.x*ground.x-point.y*ground.y,point.x*ground.y+point.y*ground.x)
	return result

func mesh_for(enemy_id: int,phase: float,ground_direction: Vector2=Vector2.RIGHT) -> ArrayMesh:
	used_ids[enemy_id]=true
	var entry: Dictionary=meshes.get(enemy_id,{})
	if not entry.is_empty() and entry.phase==phase and entry.direction==ground_direction: return entry.mesh
	var vertices:=sample_vertices(phase,ground_direction)
	var mesh: ArrayMesh
	if entry.is_empty():
		mesh=ArrayMesh.new()
		var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=DATA.uv
		arrays[Mesh.ARRAY_COLOR]=DATA.colors;arrays[Mesh.ARRAY_INDEX]=DATA.indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_DYNAMIC_UPDATE)
	else:
		mesh=entry.mesh
		mesh.surface_update_vertex_region(0,0,vertices.to_byte_array())
	if entry.is_empty() or entry.direction!=ground_direction:
		var bounds:=projected_bounds(ground_direction)
		mesh.custom_aabb=AABB(Vector3(bounds.position.x,bounds.position.y,-1),Vector3(bounds.size.x,bounds.size.y,2))
	meshes[enemy_id]={"mesh":mesh,"phase":phase,"direction":ground_direction}
	return mesh

func retain_only(ids: Dictionary) -> void:
	for id in meshes.keys():
		if not ids.has(id): meshes.erase(id)

func begin_frame() -> void: used_ids.clear()
func end_frame() -> void: retain_only(used_ids)
