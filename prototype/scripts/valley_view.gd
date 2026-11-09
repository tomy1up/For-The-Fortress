extends Node2D
var entry_forecast: Array[Dictionary] = []
var highlighted_entries: Array[int] = []

const Model = preload("res://scripts/valley_model.gd")
const MarshArt = preload("res://scripts/marsh_art.gd")
const HordeArt = preload("res://scripts/horde_art.gd")
const AllianceArt = preload("res://scripts/alliance_art.gd")
const EnemyArt = preload("res://scripts/enemy_art.gd")
const EnemyWalkArt = preload("res://scripts/enemy_walk_art.gd")
var walking_meshes:=EnemyWalkArt.new()
var wolf_turn_preview := Callable()
const ShopArt = preload("res://scripts/shop_art.gd")
const FortressArt = preload("res://scripts/fortress_art.gd")
const ORIGIN := Vector2(658, 174)
const AXIS := Vector2(27, 13.5)
const INK := Color("d9e4d7")
const SLOT_FILL := Color("213e3b")
const IMPACT_DURATION := 0.32 # Secondes de simulation, comme les autres effets du combat.
const DAMAGE_TRAIL_DURATION := 0.40
const HIT_FLASH_DURATION := 0.16
const HIT_REACTION_DURATION := 0.28
const ELIMINATION_DURATION := 0.45
const MAX_ELIMINATION_EFFECTS := 24
var elimination_tail: float = 0.0
var flag_phase: float = 0.0
var model: RefCounted:
	set(value):
		model = value
		reset_royal_animation()
		terrain_details.assign(scenery_for(model.map_definition) if model != null else [])
var terrain_details: Array[Dictionary] = []
var selected: int = -1
var purchase_preview: Dictionary = {}
var upgrade_preview: Dictionary = {}
var preview_synergy_unit: Dictionary = {}
var inspected_enemy_id: int = -1
var royal_hurt_age: float = 2.0
var royal_rally_age: float = 2.0
var breach_feedback: Dictionary = {}:
	set(value):
		breach_feedback = value
		if int(value.get("damage",0)) > 0 and int(value.get("count",0)) > 0: royal_hurt_age = 0.0

func reset_royal_animation() -> void:
	royal_hurt_age = 2.0;royal_rally_age = 2.0

func signal_wave_started() -> void:
	royal_rally_age = 0.0

var font: Font = ThemeDB.fallback_font

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func _process(delta: float) -> void:
	royal_hurt_age = minf(2.0,royal_hurt_age+maxf(0.0,delta))
	royal_rally_age = minf(2.0,royal_rally_age+maxf(0.0,delta))
	flag_phase = fmod(flag_phase+maxf(0.0,delta),TAU)
	if model == null or model.active or model.phase not in ["finished","bonus","victory","defeat"]:
		elimination_tail = 0.0
	elif elimination_tail < ELIMINATION_DURATION:
		elimination_tail = minf(ELIMINATION_DURATION,elimination_tail+maxf(0.0,delta))
		queue_redraw()

func recent_eliminations() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if model == null or model.phase not in ["combat","finished","bonus","victory","defeat"]: return result
	for index in range(model.elimination_events.size()-1,-1,-1):
		var event: Dictionary = model.elimination_events[index]
		var age: float = model.elapsed-event.time+(0.0 if model.active else elimination_tail)
		if age >= ELIMINATION_DURATION: break
		if age >= 0.0:
			result.append({"event":event,"age":age})
			if result.size() >= MAX_ELIMINATION_EFFECTS: break
	return result

static func elimination_particles(event: Dictionary, age: float) -> Array[Dictionary]:
	var particles: Array[Dictionary] = []
	if age < 0.0 or age >= ELIMINATION_DURATION: return particles
	var t: float = age/ELIMINATION_DURATION
	var scale: float = 1.5 if event.type == 7 else 1.0
	var center: Vector2 = project(event.point)+Vector2(0,-10*scale)
	for index in range(5):
		var angle: float = index*TAU/5+fmod(float(event.enemy_id)*0.61,TAU)
		var offset := Vector2(cos(angle)*(4+14*t),sin(angle)*(2+5*t)-12*t)*scale
		particles.append({"point":center+offset,"radius":(4.0+1.4*(index%2))*(1.0-0.55*t)*scale,"alpha":0.65*(1.0-t)})
	return particles

static func project(point: Vector2) -> Vector2:
	return ORIGIN + Vector2((point.x - point.y) * AXIS.x, (point.x + point.y) * AXIS.y)

func purchase_ghost() -> Dictionary:
	if model == null or not model.can_build() or selected < 0 or selected >= model.defenders.size(): return {}
	if not model.defenders[selected].is_empty() or not purchase_preview.has("type"): return {}
	var type: int = int(purchase_preview.type)
	if type not in model.available_types(): return {}
	return {"slot":selected,"type":type,"point":project(_map_slots()[selected]),"available":model.purchase_error(selected,type).is_empty()}

static func range_outline(center: Vector2, radius: float) -> PackedVector2Array:
	var ring := PackedVector2Array()
	for step in range(65):
		var angle: float = TAU * step / 64.0
		ring.append(project(center + Vector2(cos(angle), sin(angle)) * radius))
	return ring

static func impact_opacity(age: float) -> float:
	return clampf(1.0 - age / IMPACT_DURATION, 0.0, 1.0) if age >= 0.0 else 0.0

static func damage_opacity(age: float, duration: float = DAMAGE_TRAIL_DURATION) -> float:
	return clampf(1.0-age/duration,0.0,1.0) if age >= 0.0 and duration > 0.0 else 0.0

static func damage_span(event: Dictionary, maximum: float) -> Vector2:
	if maximum <= 0.0: return Vector2.ZERO
	return Vector2(clampf(event.hp_after/maximum,0.0,1.0),clampf(event.hp_before/maximum,0.0,1.0))

func recent_enemy_damage(enemy_id: int) -> Array[Dictionary]:
	var recent: Array[Dictionary] = []
	if model == null or not model.active: return recent
	for index in range(model.damage_events.size()-1,-1,-1):
		var event: Dictionary = model.damage_events[index]
		var age: float = model.elapsed-event.time
		if age >= DAMAGE_TRAIL_DURATION: break
		if event.enemy_id == enemy_id and age >= 0.0: recent.append(event)
	return recent

func enemy_hit_strength(events: Array[Dictionary]) -> float:
	var strength: float = 0.0
	for event in events: strength = maxf(strength,damage_opacity(model.elapsed-event.time,HIT_FLASH_DURATION))
	return strength

static func hit_reaction_pulse(age: float) -> float:
	if not is_finite(age) or age < 0.0 or age >= HIT_REACTION_DURATION: return 0.0
	# Une brève prise d’impact suivie d’un retour progressif au repos.
	if age < 0.045: return sin(age/0.045*PI/2.0)
	return pow(cos((age-0.045)/(HIT_REACTION_DURATION-0.045)*PI/2.0),2)

static func enemy_reaction_weight(type: int) -> float:
	return {3:0.7,5:0.55,6:0.7,7:0.45,8:0.35}.get(type,1.0)

func inspected_protection_links() -> Array[Dictionary]:
	var links: Array[Dictionary] = []
	if model == null or not model.active or inspected_enemy_id < 0: return links
	var positions: Dictionary = {}
	for enemy in model.enemies: positions[enemy.id] = model.enemy_position(enemy)
	for enemy in model.enemies:
		var guardian: int = Model.Banks.guardian_for(enemy,model.enemies,positions)
		if guardian >= 0 and (enemy.id == inspected_enemy_id or guardian == inspected_enemy_id):
			links.append({"enemy_id":enemy.id,"guardian_id":guardian,"from":positions[enemy.id],"to":positions[guardian]})
	return links

static func enemy_reaction_pose(enemy: Dictionary, events: Array[Dictionary], now: float) -> Dictionary:
	var strength: float = 0.0
	for event in events:
		if event.get("enemy_id",-1) != enemy.id: continue
		var lost: float = maxf(0.0,float(event.hp_before)-float(event.hp_after))
		if lost <= 0.0 or enemy.get("max_hp",0.0) <= 0.0: continue
		var fraction: float = clampf(lost/float(enemy.max_hp),0.0,1.0)
		var pulse: float = hit_reaction_pulse(now-event.time)*(0.35+0.65*sqrt(fraction))
		strength = maxf(strength,pulse) # Les coups simultanés ne cumulent pas leur recul.
	strength *= enemy_reaction_weight(int(enemy.get("type",1)))
	return {"strength":strength,"offset":Vector2(-3.5*strength,0.7*strength),"rotation":-0.105*strength}

static func enemy_body_transform(enemy: Dictionary, facing: float, pose: Dictionary, elapsed: float, moving: bool, route_direction := Vector2.ZERO) -> Transform2D:
	var scale: float = _enemy_scale(enemy)
	var stride: float = sin(elapsed*10.0*enemy.get("speed",1.0)+enemy.id)*2.0 if moving else 0.0
	# Les pieds restent proches de leur ancrage. Ni recul logique, ni ralentissement.
	var offset: Vector2 = pose.get("offset",Vector2.ZERO)
	var mirror := Transform2D(Vector2(facing*scale,0),Vector2(0,scale),Vector2.ZERO)
	var reaction := Transform2D(float(pose.get("rotation",0.0)),Vector2.ONE,0.0,offset)
	var result: Transform2D = mirror*reaction
	if route_direction != Vector2.ZERO:
		result.origin += (route_direction-Vector2(facing, 0.0))*offset.x*scale
	result.origin.y -= absf(stride)*0.3*scale
	return result

static func secondary_segments(shot: Dictionary) -> Array[PackedVector2Array]:
	var segments: Array[PackedVector2Array] = []
	var origin: Vector2 = shot.to
	for target in shot.get("secondary", []):
		segments.append(PackedVector2Array([project(origin), project(target)]))
		if Model.family(shot.type) == 3: origin = target
	return segments

const PROJECTILE_FLIGHT := 0.12 # Habillage du tir déjà résolu ; aucune attente de dégâts.

static func shot_origin(shot: Dictionary, pose_age: float = 0.0) -> Vector2:
	# Points d'équipement des silhouettes, distincts du centre logique de portée.
	var art = defender_art(int(shot.type))
	var muzzle: Vector2 = art.MUZZLES[int(shot.type)]
	var pose := {"pulse": attack_pulse(pose_age), "direction": shot_facing(shot)}
	return project(shot.from)+attack_transform(int(shot.type), pose)*muzzle

static func defender_art(type: int) -> GDScript:
	return ShopArt if ShopArt.TEXTURES.has(type) else AllianceArt if AllianceArt.TEXTURES.has(type) else HordeArt

static func shot_facing(shot: Dictionary) -> float:
	return -1.0 if project(shot.to).x < project(shot.from).x else 1.0

static func projectile_position(shot: Dictionary, age: float) -> Vector2:
	var progress: float = clampf(age / PROJECTILE_FLIGHT,0.0,1.0)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var point: Vector2 = origin.lerp(target,progress)
	if Model.family(shot.type) in [3,4]: point.y -= sin(PI*progress)*(15.0 if Model.family(shot.type) == 4 else 8.0)
	return point

func _draw_projectile(shot: Dictionary, age: float, color: Color) -> void:
	if age < 0.0 or age >= PROJECTILE_FLIGHT: return
	var point: Vector2 = projectile_position(shot,age)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var direction: Vector2 = (target-origin).normalized()
	if direction.is_zero_approx(): direction = Vector2.RIGHT
	var side: Vector2 = direction.orthogonal()
	match Model.family(int(shot.type)):
		0,1:
			var length: float = 13.0 if Model.family(shot.type) == 0 else 9.0
			draw_line(point-direction*length,point,Color("ead9a8"),1.8 if Model.family(shot.type) == 0 else 3.0,true)
			draw_colored_polygon(PackedVector2Array([point+direction*3,point-direction*3+side*3,point-direction*3-side*3]),Color("e4f0e7"))
			for sign in [-1,1]: draw_line(point-direction*(length-3),point-direction*length+side*sign*3,color,1.5,true)
		2:
			draw_circle(point,7,Color(color,0.12),true,-1,true)
			draw_circle(point,3.5,color,true,-1,true)
			draw_circle(point+Vector2(-1,-1),1.5,Color("ecffff"),true,-1,true)
		3:
			_draw_spinning_axe(point, age)
		4:
			var roll := sin(age/PROJECTILE_FLIGHT*PI)*0.75*shot_facing(shot)
			var fuse := point+Vector2(4,-8).rotated(roll)
			draw_circle(point,5,Color("253a3e"),true,-1,true)
			draw_arc(point,4,3.7+roll,5.0+roll,8,Color("a6b7a9"),1.5,true)
			draw_line(point+Vector2(2,-4).rotated(roll),fuse,Color("d8b16b"),1.5,true)
			draw_circle(fuse,4.0,Color(1.0,0.57,0.22,0.26),true,-1,true)
			draw_circle(fuse,1.7,Color("fff0b4"),true,-1,true)
			for spark in range(3):
				var phase := fposmod(age*17.0+float(spark)/3.0,1.0)
				var offset := Vector2.UP.rotated(roll+(spark-1)*0.65)*lerpf(2.0,7.0,phase)
				draw_circle(fuse+offset,1.1,Color(1.0,0.72,0.34,1.0-phase),true,-1,true)
		5:
			var cross := PackedVector2Array([point+Vector2(0,-6),point+Vector2(4,0),point+Vector2(0,6),point+Vector2(-4,0)])
			draw_colored_polygon(cross,color)
			draw_line(point+Vector2(0,-3),point+Vector2(0,3),Color("f5def5"),1.5,true)

func _draw_spinning_axe(point: Vector2, age: float) -> void:
	var rotation: float = age/PROJECTILE_FLIGHT*TAU
	var shaft := Vector2(cos(rotation),sin(rotation))
	var edge: Vector2 = shaft.orthogonal()
	draw_line(point-shaft*6,point+shaft*5,Color("1a2524"),4.0,true)
	draw_line(point-shaft*6,point+shaft*5,Color("d0ac75"),2.5,true)
	var blade := PackedVector2Array([point+shaft*4,point+shaft*7+edge*6,point-shaft*2+edge*7,point-shaft*3+edge*3])
	draw_colored_polygon(blade,Color("c9e5da"))
	blade.append(blade[0])
	draw_polyline(blade,Color("1a2524"),1.4,true)

func _draw_hit_marker(point: Vector2, alpha: float, primary: bool, type: int, age: float) -> void:
	type = Model.family(type)
	var color: Color = [Color("f0d796"),Color("e1e9dc"),Color("90dceb"),Color("a8ddbd"),Color("f2b269"),Color("d1a3ed")][type]
	color.a = alpha
	var spread: float = (5.0 if primary else 3.0)+minf(maxf(age,0.0)/IMPACT_DURATION,1.0)*4.0
	if type == 5:
		var diamond := PackedVector2Array([point+Vector2(0,-spread),point+Vector2(spread*0.65,0),point+Vector2(0,spread),point+Vector2(-spread*0.65,0),point+Vector2(0,-spread)])
		draw_polyline(diamond,color,1.8,true)
	else:
		draw_circle(point,spread,color,false,1.7 if primary else 1.2,true)
		if primary:
			for index in range(4):
				var direction := Vector2.RIGHT.rotated(index*PI/2+PI/4)
				draw_line(point+direction*(spread+2),point+direction*(spread+5),color,1.5,true)
	if age < 0.08: draw_circle(point,2.5 if primary else 1.5,Color(color,alpha*0.8),true,-1,true)

func _draw_impact(shot: Dictionary, age: float) -> void:
	var alpha: float = impact_opacity(age)
	if alpha <= 0.0: return
	var type: int = Model.family(shot.type)
	var color: Color = [Color("f0d796"),Color("e1e9dc"),Color("90dceb"),Color("a8ddbd"),Color("f2b269"),Color("d1a3ed")][type]
	color.a = alpha
	var height := Vector2(0,-12)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+height
	# L'impact est visible dès le tir : le déplacement bref ne retarde aucun dégât.
	_draw_hit_marker(target,alpha,true,type,age)
	if type == 5:
		origin = shot_origin(shot, age)
		var direction: Vector2 = target-origin
		var side: Vector2 = direction.normalized().orthogonal()
		var bolt := PackedVector2Array([origin,origin+direction*0.3+side*4,origin+direction*0.55-side*4,origin+direction*0.78+side*3,target])
		draw_polyline(bolt,Color(color,alpha*0.65),1.5,true)
	elif type in [0,1,2]:
		draw_line(origin,target,Color(color,alpha*0.22),1 if type != 1 else 1.5,true)
	else:
		var trail := PackedVector2Array()
		for index in range(9): trail.append(projectile_position(shot,PROJECTILE_FLIGHT*index/8.0))
		draw_polyline(trail,Color(color,alpha*0.18),1,true)
	_draw_projectile(shot,age,color)
	if type in [2,4]:
		var radius: float = shot.get("radius",1.0)
		var ring := range_outline(shot.to,radius)
		# Rayon exact, remplissage discret ; seules les victimes réelles sont marquées.
		draw_colored_polygon(ring,Color(color,alpha*0.045))
		draw_polyline(ring,Color(color,alpha*0.6),1.5,true)
		var inner := range_outline(shot.to,radius*(0.25+0.75*minf(age/0.18,1.0)))
		draw_polyline(inner,Color(color,alpha*0.4),1,true)
	var segments := secondary_segments(shot)
	var bounce_duration := (IMPACT_DURATION-PROJECTILE_FLIGHT)/maxi(1,segments.size())
	var axe_position := Vector2.INF
	for index in range(segments.size()):
		var segment := segments[index]
		var secondary: Vector2 = segment[1]+height
		if type == 3:
			var start: Vector2 = segment[0]+height
			var progress := (age-PROJECTILE_FLIGHT)/bounce_duration-index
			draw_line(start,secondary,Color(color,alpha*0.65),1.8,true)
			if progress >= 0.0 and progress < 1.0:
				axe_position = start.lerp(secondary,progress)-Vector2(0.0,sin(PI*progress)*4.0)
		_draw_hit_marker(secondary,alpha,false,type,age)
	if axe_position.is_finite():
		_draw_spinning_axe(axe_position,age)


static func enemy_art_id(enemy: Dictionary, defending_faction: int = -1) -> String:
	if defending_faction in [0,1]: return Model.Enemies.for_profile(int(enemy.get("type",1)),defending_faction).id
	if EnemyArt.TEXTURES.has(enemy.get("identity_id","")): return enemy.identity_id
	return Model.Enemies.for_profile(int(enemy.get("type",1)),0).id

static func enemy_bounds(enemy: Dictionary, defending_faction: int = -1, route_points: Array[Vector2] = Model.PATH_POINTS, route_length: float = Model.PATH_LENGTH) -> Rect2:
	var center: Vector2 = project(Model.position_at(enemy.distance,route_points,route_length))
	var scale: float = _enemy_scale(enemy)
	var width: float = maxf(28.0,32.0*scale)
	var bounds := Rect2(center+Vector2(-width/2.0,-39.0*scale),Vector2(width,47.0*scale))
	if EnemyArt.TEXTURES.has(enemy_art_id(enemy,defending_faction)):
		var image: Rect2 = EnemyArt.destination(enemy_art_id(enemy,defending_faction))
		var facing: float
		if EnemyWalkArt.supports(enemy_art_id(enemy,defending_faction)):
			var motion: Dictionary=EnemyWalkArt.path_motion(enemy.distance,route_points,AXIS)
			image=image.merge(EnemyWalkArt.projected_bounds(motion.direction))
			facing = route_facing(motion.direction)
		else:
			facing = enemy_facing(enemy,route_points,route_length)
		if facing < 0.0: image.position.x = -image.end.x
		bounds = bounds.merge(Rect2(center+image.position*scale,image.size*scale).grow(1.0))
	return bounds.grow(8.0) # Marge fixe couvrant les poses, sans survol qui tremble avec le corps.

static func route_facing(direction: Vector2) -> float:
	return -1.0 if direction.x < 0.0 else 1.0

static func enemy_facing(enemy: Dictionary, route_points: Array[Vector2] = Model.PATH_POINTS, route_length: float = Model.PATH_LENGTH) -> float:
	var distance: float = clampf(enemy.distance,0.0,route_length)
	return route_facing(EnemyWalkArt.path_motion(distance,route_points,AXIS).direction)


func enemy_at(point: Vector2) -> int:
	if model == null: return -1
	var found: int = -1
	var front_y: float = -INF
	for enemy in model.enemies:
		if enemy.hp <= 0.0 or not enemy_bounds(enemy,model.faction,model.enemy_route_points(enemy),model.enemy_route_length(enemy)).has_point(point): continue
		var y: float = project(model.enemy_position(enemy)).y
		if y >= front_y: # Même priorité visuelle que le dessin, dernier acteur en cas d'égalité.
			front_y = y
			found = enemy.id
	return found

static func covered_route(center: Vector2, radius: float, route_points: Array[Vector2] = Model.PATH_POINTS, route_length: float = Model.PATH_LENGTH) -> Array[PackedVector2Array]:
	var sections: Array[PackedVector2Array] = []
	for window in Model.coverage_windows(center, radius, route_points):
		var points := PackedVector2Array([project(Model.position_at(window.first,route_points,route_length))])
		var distance: float = 0.0
		for index in range(1, route_points.size()):
			distance += route_points[index-1].distance_to(route_points[index])
			if distance > window.first + Model.EPS and distance < window.last - Model.EPS:
				points.append(project(route_points[index]))
		points.append(project(Model.position_at(window.last,route_points,route_length)))
		sections.append(points)
	return sections


func synergy_links(candidate: Dictionary = {}) -> Array[Dictionary]:
	var links: Array[Dictionary] = []
	if model == null or selected < 0 or selected >= model.defenders.size(): return links
	var unit: Dictionary = model.defenders[selected] if candidate.is_empty() else candidate
	if unit.is_empty() or int(unit.get("type",-1)) not in model.available_types(): return links
	for rule in Model.Campaign.PROXIMITY + Model.Campaign.SPECIALISATIONS:
		for partner in model.synergy_partners(selected,rule,-1,candidate):
			links.append({"code":rule.code,"partner":partner,"specialised":rule.has("branches")})
	return links

func _draw_synergy_links(candidate: Dictionary = {}) -> void:
	var planned: bool = not candidate.is_empty()
	for link in synergy_links(candidate):
		var offset := Vector2(0,4 if link.specialised else 0)
		var start: Vector2 = project(_map_slots()[selected]) + offset
		var finish: Vector2 = project(_map_slots()[link.partner]) + offset
		var color := Color("8bd5e6") if planned else Color("8cbde0") if link.specialised else Color("e1bb70")
		if planned:
			var length: float = start.distance_to(finish)
			var direction: Vector2 = (finish-start).normalized()
			for step in range(0,int(ceil(length)),12):
				draw_line(start+direction*step,start+direction*minf(step+7,length),color,2,true)
		else:
			draw_line(start,finish,Color(color,0.65),2,true)
		draw_circle(finish,7 if planned else 5,color,false,2,true)

func polygon(points: Array[Vector2], color: Color) -> void:
	var projected := PackedVector2Array()
	for point in points:
		projected.append(project(point))
	draw_colored_polygon(projected, color)

func _map_slots() -> Array[Vector2]:
	return model.slots if model != null else Model.SLOTS

func _map_path() -> Array[Vector2]:
	return model.path_points if model != null else Model.PATH_POINTS

static func routes_for(definition: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if definition.has("routes"): result.assign(definition.routes)
	else: result.append({"id":"main","path_points":definition.path_points,"path_length":definition.path_length})
	return result

func map_covered_routes(center: Vector2, radius: float) -> Array[PackedVector2Array]:
	var sections: Array[PackedVector2Array] = []
	for route in routes_for(model.map_definition):
		var points: Array[Vector2] = [];points.assign(route.path_points)
		sections.append_array(covered_route(center,radius,points,route.path_length))
	return sections

func entry_coverage_percentages(center: Vector2, radius: float) -> Array[int]:
	var percentages: Array[int] = []
	for route in model.routes:
		var points: Array[Vector2] = []
		points.assign(route.path_points)
		var length := 0.0
		for window in Model.coverage_windows(center,radius,points):
			length += window.last-window.first
		percentages.append(clampi(roundi(100.0*length/route.path_length),0,100))
	return percentages

static func _segment_in_rect(first: Vector2, last: Vector2, area: Rect2) -> bool:
	if area.has_point(first) or area.has_point(last): return true
	var corners: Array[Vector2] = [area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(first,last,corners[index],corners[(index+1)%4]) != null: return true
	return false

static func scenery_bounds(item: Dictionary) -> Rect2:
	var center: Vector2 = project(item.point)
	if item.kind in ["willow","ruin","reeds"]: return MarshArt.bounds(center,item.kind)
	return Rect2(center+Vector2(-16,-46),Vector2(32,60)) if item.kind == "pine" else Rect2(center+Vector2(-13,-14),Vector2(26,23))

static func scenery_for(definition: Dictionary) -> Array[Dictionary]:
	# Habillage des nouveaux terrains uniquement. Aucun tirage du générateur de combat.
	var result: Array[Dictionary] = []
	var mountain: bool = definition.get("decoration","") == "mountain"
	var marsh: bool = definition.get("decoration","") == "marsh"
	if not mountain and not marsh and definition.get("id","") not in Model.Maps.CHAPTER_ONE_MAPS: return result
	if not Model.Maps.validation_error(definition).is_empty(): return result
	var board := PackedVector2Array([project(Vector2.ZERO),project(Vector2(definition.size.x,0)),project(Vector2(definition.size)),project(Vector2(0,definition.size.y))])
	var reserved: Array[Rect2] = [fortress_bounds(project(definition.path_points[-1])).grow(12)]
	for route in routes_for(definition): reserved.append(Rect2(project(route.path_points[0])+Vector2(-60,-43),Vector2(116,65)))
	for slot in definition.slots: reserved.append(Rect2(project(slot)+Vector2(-44,-78),Vector2(88,110)))
	var candidates: Array[Dictionary] = []
	var seed_value: int = absi(String(definition.id).hash())
	for x in range(12):
		for y in range(7):
			var order: int = (x*29+y*47+seed_value)%101
			var kind: String = ["pine","shrub","rock"][order%3]
			if marsh: kind = ["reeds","ruin","willow"][order%3]
			if mountain and kind == "shrub": kind = "rock"
			candidates.append({"point":Vector2(0.8+x*1.45,0.8+y*1.35),"kind":kind,"order":order})
	candidates.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.order < b.order)
	for candidate in candidates:
		var area: Rect2 = scenery_bounds(candidate)
		var clear: bool = true
		for corner in [area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]:
			if not Geometry2D.is_point_in_polygon(corner,board): clear = false;break
		if not clear: continue
		for exclusion in reserved:
			if area.intersects(exclusion): clear = false;break
		if not clear: continue
		for route in routes_for(definition):
			for segment in range(1,route.path_points.size()):
				if _segment_in_rect(project(route.path_points[segment-1]),project(route.path_points[segment]),area.grow(20)): clear = false;break
			if not clear: break
		if not clear: continue
		for placed in result:
			if area.grow(7).intersects(scenery_bounds(placed)): clear = false;break
		if clear: result.append(candidate)
		if result.size() >= 22: break
	# Sur un terrain encombré, une ruine plus compacte remplace un saule déjà dégagé.
	# Ses limites sont incluses dans celles de l'arbre : les marges restent préservées.
	if marsh and not result.any(func(item):return item.kind=="ruin"):
		for item in result:
			if item.kind=="willow": item.kind = "ruin";break
	result.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return project(a.point).y < project(b.point).y)
	return result

func _draw_terrain_detail(item: Dictionary) -> void:
	var center: Vector2 = project(item.point)
	if item.kind in ["willow","ruin","reeds"]:
		MarshArt.draw_detail(self,center,item.kind)
		return
	if item.kind == "pine": _draw_tree(center);return
	if item.kind == "rock":
		draw_colored_polygon(PackedVector2Array([center+Vector2(-12,2),center+Vector2(-7,-9),center+Vector2(3,-13),center+Vector2(12,-3),center+Vector2(10,4),center+Vector2(-2,7)]),Color("697765"))
		draw_colored_polygon(PackedVector2Array([center+Vector2(-7,-9),center+Vector2(3,-13),center+Vector2(12,-3),center]),Color("95a08a"))
		draw_line(center+Vector2(3,-13),center,Color("52634f"),2,true)
	else:
		draw_circle(center+Vector2(-6,-2),6,Color("2b5140"))
		draw_circle(center+Vector2(5,-4),7,Color("496e50"))
		draw_circle(center+Vector2(0,-8),5,Color("5f8154"))
		if item.order%2 == 0:
			draw_circle(center+Vector2(-4,-6),1.5,Color("d6be78"))
			draw_circle(center+Vector2(6,-8),1.5,Color("d6be78"))

func _draw() -> void:
	walking_meshes.begin_frame()
	var definition: Dictionary = model.map_definition if model != null else Model.Maps.valley()
	var mountain: bool = definition.decoration == "mountain"
	var marsh: bool = definition.decoration == "marsh"
	var board: Vector2i = definition.size
	var ghost: Dictionary = purchase_ghost()
	var corners: Array[Vector2] = [Vector2.ZERO, Vector2(board.x, 0), Vector2(board.x, board.y), Vector2(0, board.y)]
	var base := PackedVector2Array()
	for corner in corners:
		base.append(project(corner) + Vector2(0, 16))
	draw_colored_polygon(base, Color("172c2b"))
	# Deux faces donnent de l'épaisseur au plateau, sans déplacer sa surface logique.
	for edge in [[corners[1],corners[2],Color("315247") if marsh else Color("34444c") if mountain else Color("263e34")],[corners[2],corners[3],Color("233e37") if marsh else Color("27363f") if mountain else Color("1c322c")]]:
		var first: Vector2 = project(edge[0])
		var last: Vector2 = project(edge[1])
		draw_colored_polygon(PackedVector2Array([first,last,last+Vector2(0,16),first+Vector2(0,16)]),edge[2])
	polygon(corners, MarshArt.GROUND if marsh else Color("4a5b65") if mountain else Color("3a513e"))
	if marsh: MarshArt.draw_ground(self,project,false,definition.get("water_areas",MarshArt.POOLS))
	for x in range(board.x+1):
		draw_line(project(Vector2(x, 0)), project(Vector2(x, board.y)), Color(0.75, 0.86, 0.7, 0.055), 1)
	for y in range(board.y+1):
		draw_line(project(Vector2(0, y)), project(Vector2(board.x, y)), Color(0.75, 0.86, 0.7, 0.055), 1)
	if definition.decoration == "valley": _draw_valley_water()
	var screen_routes: Array[PackedVector2Array] = []
	for entry in routes_for(definition):
		var route := PackedVector2Array()
		for point in entry.path_points: route.append(project(point))
		screen_routes.append(route)
	for route in screen_routes: draw_polyline(route,Color("2d3a42") if mountain else Color("26372e"),28,true)
	for route in screen_routes:
		draw_polyline(route,MarshArt.ROAD if marsh else Color("b3a17b"),20,true)
		for point in route: draw_circle(point,10,MarshArt.ROAD if marsh else Color("b3a17b"))
	for route in screen_routes: draw_polyline(route,Color("c7b58d"),2,true)
	if marsh:
		var paths: Array = routes_for(definition).map(func(route):return route.path_points)
		MarshArt.draw_joints(self,project,paths)
	var highlighted_segments := {}
	for index in highlighted_entries:
		if index < 0 or index >= screen_routes.size():
			continue
		var route := screen_routes[index]
		for step in range(1, route.size()):
			var start := route[step-1]
			var finish := route[step]
			var segment := Vector4(start.x, start.y, finish.x, finish.y)
			var tint := Color("f2dfb2") if highlighted_segments.has(segment) else entry_color(index)
			highlighted_segments[segment] = tint
	for segment: Vector4 in highlighted_segments:
		draw_line(Vector2(segment.x, segment.y), Vector2(segment.z, segment.w), highlighted_segments[segment], 5.0, true)
	if definition.decoration == "valley": _draw_valley_bridge()
	for tree in definition.trees:
		_draw_tree(project(tree))
	for item in terrain_details: _draw_terrain_detail(item)
	var preview: Dictionary = purchase_preview if not purchase_preview.is_empty() else upgrade_preview
	if model != null and selected >= 0 and not preview.is_empty():
		var preview_ring := range_outline(_map_slots()[selected], preview.range)
		draw_colored_polygon(preview_ring, Color(0.35, 0.8, 0.95, 0.12))
		draw_polyline(preview_ring, Color("8bd5e6"), 2.5, true)
		for section in map_covered_routes(_map_slots()[selected],preview.range):
			draw_polyline(section, Color("8bd5e6"), 6, true)
		if not preview_synergy_unit.is_empty(): _draw_synergy_links(preview_synergy_unit)
	if model != null and selected >= 0 and not model.defenders[selected].is_empty():
		var stats: Dictionary = model.get_stats(selected)
		var ring := range_outline(_map_slots()[selected], stats.range)
		draw_colored_polygon(ring, Color(0.8, 0.85, 0.5, 0.05))
		draw_polyline(ring, Color(0.8, 0.85, 0.5, 0.35), 1.5, true)
		if preview.is_empty():
			for section in map_covered_routes(_map_slots()[selected],stats.range):
				draw_polyline(section,Color(0.9,0.77,0.48,0.65),4,true)
		if preview.is_empty(): _draw_synergy_links()
	for index in range(_map_slots().size()):
		var center: Vector2 = project(_map_slots()[index])
		var diamond := PackedVector2Array([center + Vector2(-26, 0), center + Vector2(0, -13), center + Vector2(26, 0), center + Vector2(0, 13)])
		draw_colored_polygon(diamond, SLOT_FILL)
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color("ddbd78") if selected == index else Color("779b89"), 2, true)
		var occupied: bool = model != null and not model.defenders[index].is_empty()
		occupied = occupied or (not ghost.is_empty() and ghost.slot == index)
		draw_string(font, center + Vector2(-9, 22 if occupied else 5), "E%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)
	_draw_fortress(project(_map_path()[-1]))
	for index in range(screen_routes.size()):
		var entrance: Vector2 = screen_routes[index][0]
		if index in highlighted_entries:
			draw_arc(entrance, 9.0, 0.0, TAU, 24, entry_color(index), 2.0, true)
		draw_circle(entrance,5,Color("debd7f") if screen_routes.size()==1 else entry_color(index))
		if screen_routes.size()==1: draw_string(font,entrance+Vector2(-48,-20),"ENTRÉE",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("a7b8aa"))
	if model != null:
		var protection_positions: Dictionary = {}
		for enemy in model.enemies:
			if model.active and not model.protection_events.is_empty():
				protection_positions[enemy.id] = model.enemy_position(enemy)
			if enemy.type != Model.Banks.GUARD_TYPE: continue
			var ring := PackedVector2Array()
			var center: Vector2 = model.enemy_position(enemy)
			for step in range(49): ring.append(project(center+Vector2.from_angle(TAU*step/48)*Model.Banks.RADIUS))
			draw_polyline(ring,Color(0.62,0.79,0.43,0.42),1.4,true)
		for link in inspected_protection_links():
			draw_line(project(link.from)+Vector2(0,-12),project(link.to)+Vector2(0,-12),Color(0.72,0.89,0.56,0.65),1.5,true)
			draw_arc(project(link.from)+Vector2(0,3),12,0,TAU,32,Color("b8d889"),1.5,true)
		var actors: Array[Dictionary] = []
		for slot in range(model.defenders.size()):
			if not model.defenders[slot].is_empty():
				actors.append({"point": project(_map_slots()[slot]), "defender": model.defenders[slot],"slot":slot,"order":actors.size()})
		for enemy in model.enemies:
			actors.append({"point": project(model.enemy_position(enemy)), "enemy": enemy,"order":actors.size()})
		if not ghost.is_empty(): actors.append({"point":ghost.point,"ghost":ghost,"order":actors.size()})
		actors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order if a.point.y == b.point.y else a.point.y < b.point.y)
		for actor in actors:
			if actor.has("ghost"):
				_draw_purchase_ghost(actor.ghost)
			elif actor.has("defender"):
				_draw_defender(actor.point, actor.defender.type, actor.defender.get("level", 1), actor.defender.get("branch", -1), defender_pose(actor.slot))
			else:
				var feedback: Array[Dictionary] = recent_enemy_damage(actor.enemy.id)
				_draw_pillager(actor.point, actor.enemy,enemy_hit_strength(feedback),enemy_reaction_pose(actor.enemy,feedback,model.elapsed))
				var ratio: float = clampf(actor.enemy.hp / actor.enemy.get("max_hp", 40.0), 0.0, 1.0)
				var bar_position: Vector2 = actor.point + Vector2(-12, -39 * _enemy_scale(actor.enemy))
				draw_rect(Rect2(bar_position, Vector2(24, 4)), Color("472f2a"))
				draw_rect(Rect2(bar_position, Vector2(24 * ratio, 4)), Color("edcc80") if actor.enemy.id == inspected_enemy_id else Color("a1ba75"))
				for event in feedback:
					var span: Vector2 = damage_span(event,actor.enemy.get("max_hp",40.0))
					if span.y > span.x:
						draw_rect(Rect2(bar_position+Vector2(24*span.x,0),Vector2(24*(span.y-span.x),4)),Color(Color("f3dfba"),damage_opacity(model.elapsed-event.time)))
		if model.active:
			for event in model.protection_events:
				var age: float = model.elapsed-event.time
				if age < 0.0 or age >= 0.4: continue
				var from: Vector2 = protection_positions.get(event.get("protected_id", -1),event.from)
				var to: Vector2 = protection_positions.get(event.get("guardian_id", -1),event.to)
				draw_line(project(from)+Vector2(0,-12),project(to)+Vector2(0,-12),Color(0.83,0.96,0.52,(1.0-age/0.4)*0.85),2,true)
			for shot in model.shots:
				_draw_impact(shot, model.elapsed - shot.time)
		for effect in recent_eliminations():
			for particle in elimination_particles(effect.event,effect.age):
				draw_circle(particle.point,particle.radius,Color(Color("d6c7a6"),particle.alpha))
	for entry in entry_label_layouts():
		var box:=StyleBoxFlat.new();box.bg_color=Color("10271f");box.border_color=entry.color
		box.set_border_width_all(1);box.set_corner_radius_all(5)
		draw_style_box(box,entry.area)
		draw_string(font,entry.area.position+Vector2(8,17),entry.title,HORIZONTAL_ALIGNMENT_LEFT,-1,12,entry.color)
		if not entry.detail.is_empty(): draw_string(font,entry.area.position+Vector2(8,35),entry.detail,HORIZONTAL_ALIGNMENT_LEFT,-1,12,INK)
	if not breach_feedback.is_empty(): _draw_breach_feedback()
	walking_meshes.end_frame()

func entry_label_layouts() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if model==null or model.routes.size()<2: return result
	var font: Font=ThemeDB.fallback_font
	var busiest_route := ""
	var highest_count := 0
	for entry in entry_forecast:
		if entry.count > highest_count:
			highest_count = entry.count
			busiest_route = entry.route_id
		elif entry.count == highest_count:
			busiest_route = ""
	for index in range(model.routes.size()):
		var title: String="ENTRÉE %d"%(index+1)
		var route_id: String = model.routes[index].id
		if route_id == busiest_route:
			title += " · PRINCIPALE"
		var detail: String=""
		for entry in entry_forecast:
			if entry.route_id==route_id: detail="%d ennemi%s"%[entry.count,"" if entry.count==1 else "s"]
		var width: float=maxf(92.0,maxf(font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x,font.get_string_size(detail,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x)+16.0)
		var height: float=24.0 if detail.is_empty() else 44.0
		var origin: Vector2=project(model.routes[index].path_points[0])+Vector2(-width/2.0,-76.0-height)
		result.append({"area":Rect2(origin,Vector2(width,height)),"title":title,"detail":detail,"color":entry_color(index)})
	return result

static func entry_color(index: int) -> Color:
	return [Color("e5c779"),Color("83c4c6"),Color("c8a6e3")][index%3]

static func breach_text(count: int, damage: int) -> String:
	return "−%d PV · %d ennemi%s passé%s" % [damage,count,"" if count == 1 else "s","" if count == 1 else "s"]

func _draw_breach_feedback() -> void:
	var area: Rect2 = fortress_bounds(project(_map_path()[-1]))
	var center: Vector2 = fortress_center(project(_map_path()[-1]))
	var warning := Color("ef9b89")
	draw_rect(area.grow(3),Color(warning,0.75),false,2)
	var text: String = breach_text(breach_feedback.count,breach_feedback.damage)
	var width: float = font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x+24
	var box := Rect2(Vector2(center.x-width/2.0,area.position.y-36),Vector2(width,30))
	draw_rect(box,Color("35241f"))
	draw_rect(box,warning,false,1)
	draw_string(font,box.position+Vector2(12,21),text,HORIZONTAL_ALIGNMENT_LEFT,-1,15,warning)

const UNIT_INK := Color("192a2b")
const ATTACK_POSE_DURATION := 0.26
# Recul horizontal, inclinaison en radians, élévation : habillage des tirs résolus.
const ATTACK_MOTIONS: Array[Vector3] = [
	Vector3(2.8,-0.035,0.0), # Archer : traction et petit recul.
	Vector3(4.0,-0.025,0.0), # Arbalétrier : recul plus sec.
	Vector3(0.8,0.015,2.5), # Mage : légère élévation de l'incantation.
	Vector3(2.0,0.070,1.0), # Troll : engagement du corps dans le lancer.
	Vector3(1.6,0.055,2.0), # Sapeur : lancer avec petit bond.
	Vector3(0.8,-0.025,2.5), # Chaman : élévation et bascule du totem.
]

# Animation issue des tirs réels, dans le temps simulé. Aucune horloge ni RNG de jeu modifiée.
static func attack_pulse(age: float) -> float:
	if age < 0.0 or age >= ATTACK_POSE_DURATION: return 0.0
	return sin(PI * age / ATTACK_POSE_DURATION)

func defender_pose(slot: int) -> Dictionary:
	var pose: Dictionary = {"pulse":0.0,"direction":1.0}
	if model == null or slot < 0 or slot >= model.defenders.size(): return pose
	var defender: Dictionary = model.defenders[slot]
	if defender.has("last_target_position"):
		pose.direction = shot_facing({"from": model.slots[slot], "to": defender.last_target_position})
	if not model.active: return pose
	# Garder le côté du dernier tir de cet emplacement après la fin du mouvement.
	for index in range(model.shots.size()-1,-1,-1):
		var shot: Dictionary = model.shots[index]
		var age: float = model.elapsed-shot.time
		if shot.slot != slot or age < 0.0: continue
		pose.pulse = attack_pulse(age)
		pose.direction = shot_facing(shot)
		if shot.get("type", -1) == 0:
			pose.archer_stage = AllianceArt.archer_shot_stage(age, defender.ready_at-shot.time)
		elif shot.get("type", -1) == 1:
			pose.crossbow_reload = age >= ATTACK_POSE_DURATION and age < minf(0.72, (defender.ready_at-shot.time)*0.8)
		elif shot.get("type", -1) == 2 and age < ATTACK_POSE_DURATION:
			pose.staff_flash = 1.0-smoothstep(0.0, ATTACK_POSE_DURATION, age)
		break
	return pose

static func attack_transform(type: int, pose: Dictionary) -> Transform2D:
	type = Model.family(type)
	var pulse: float = clampf(pose.get("pulse",0.0),0.0,1.0)
	var direction: float = pose.get("direction",1.0)
	var motion: Vector3 = ATTACK_MOTIONS[type]
	return Transform2D(motion.y*pulse*direction,Vector2(direction,1.0),0.0,Vector2(-direction*motion.x*pulse,-motion.z*pulse))

func _unit_shape(points: Array[Vector2], color: Color, width: float = 1.5) -> void:
	var contour := PackedVector2Array(points)
	draw_colored_polygon(contour,color)
	contour.append(contour[0])
	draw_polyline(contour,UNIT_INK,width,true)

func _unit_disk(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center,radius,UNIT_INK,true,-1,true)
	draw_circle(center,radius-1.2,color,true,-1,true)

func _unit_stroke(from: Vector2, to: Vector2, color: Color, width: float = 3.0) -> void:
	draw_line(from,to,UNIT_INK,width+2.0,true)
	draw_line(from,to,color,width,true)

func _unit_face(skin: Color, wide: float, y: float, tusks: bool = false) -> void:
	_unit_disk(Vector2(0,y),wide,skin)
	draw_line(Vector2(-3,y-1),Vector2(-1,y-1),UNIT_INK,1.5,true)
	draw_line(Vector2(2,y-1),Vector2(4,y-1),UNIT_INK,1.5,true)
	if tusks:
		for side in [-1,1]:
			_unit_shape([Vector2(side*4,y+5),Vector2(side*5,y),Vector2(side*2,y+4)],Color("fff0c9"),0.8)

func _draw_purchase_ghost(ghost: Dictionary) -> void:
	var art = defender_art(ghost.type)
	if not art.TEXTURES.has(ghost.type): return
	var alpha: float = 0.52 if ghost.available else 0.34
	draw_set_transform(ghost.point+Vector2(0,2),0,Vector2(1,0.45))
	draw_arc(Vector2.ZERO,13,0,TAU,32,Color(Color("8bd5e6"),alpha),1.5,true)
	draw_set_transform(ghost.point)
	draw_texture_rect_region(art.TEXTURES[ghost.type],art.destination(ghost.type),art.FRAMES[ghost.type].source,Color(0.76,0.97,1.0,alpha))
	draw_set_transform(Vector2.ZERO)

func _draw_defender(center: Vector2, type: int, level: int = 1, branch: int = -1, pose: Dictionary = {}) -> void:
	var art = defender_art(type)
	if not art.TEXTURES.has(type): return
	_draw_illustrated_defender(center,type,pose,art)
	_draw_level_badge(center,level,branch)

func _draw_illustrated_defender(center: Vector2, type: int, pose: Dictionary, art: GDScript) -> void:
	draw_set_transform(center+Vector2(0,2),0,Vector2(1,0.45))
	draw_circle(Vector2.ZERO,12,Color(0,0,0,0.25),true,-1,true)
	var transform: Transform2D = attack_transform(type,pose)
	transform.origin += center
	draw_set_transform_matrix(transform)
	var texture: Texture2D = AllianceArt.ARCHER_SHOT_TEXTURES[pose.get("archer_stage", 0)] if type == 0 else art.TEXTURES[type]
	if type == 1 and pose.get("crossbow_reload", false):
		texture = AllianceArt.CROSSBOW_RELOAD_TEXTURE
	draw_texture_rect_region(texture,art.destination(type),art.FRAMES[type].source)
	var flash: float = pose.get("staff_flash", 0.0)
	if flash > 0.0:
		var crystal: Vector2 = art.MUZZLES[type]
		draw_circle(crystal, 7.0+3.0*(1.0-flash), Color(0.40,0.87,1.0,0.24*flash), true, -1.0, true)
		draw_circle(crystal, 3.0, Color(0.86,0.98,1.0,0.8*flash), true, -1.0, true)
	draw_set_transform(Vector2.ZERO)

func _draw_level_badge(center: Vector2, level: int, branch: int) -> void:
	if level > 1:
		var badge: Vector2 = center + Vector2(16,6)
		_unit_disk(badge,11 if level == 4 else 9,Color("7b6c41") if level == 4 else Color("304d42"))
		var badge_text: String = str(level) + ("A" if branch == 0 else "B") if level == 4 else str(level)
		draw_string(font,badge+Vector2(-7 if level == 4 else -3,4),badge_text,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("efe0b8"))


func _draw_tree(center: Vector2) -> void:
	draw_circle(center + Vector2(0, 3), 10, Color(0, 0, 0, 0.1))
	draw_line(center, center + Vector2(0, -22), Color("80755a"), 3)
	for crown in [[14.0,-8.0,-31.0],[11.0,-18.0,-39.0],[7.5,-28.0,-45.0]]:
		var left: Vector2 = center+Vector2(-crown[0],crown[1])
		var right: Vector2 = center+Vector2(crown[0],crown[1])
		var tip: Vector2 = center+Vector2(0,crown[2])
		draw_colored_polygon(PackedVector2Array([left,tip,right]),Color("2b5140"))
		draw_colored_polygon(PackedVector2Array([tip,right,center+Vector2(0,crown[1])]),Color("496e50"))

static func fortress_style(faction: int) -> Dictionary:
	if faction == 1:
		return {"faction":1,"wall":Color("956746"),"shade":Color("624c3c"),"roof":Color("a63f31"),"flag":Color("bd4936"),"trim":Color("c5bda7")}
	return {"faction":0,"wall":Color("c2c8b6"),"shade":Color("84958a"),"roof":Color("356582"),"flag":Color("376b99"),"trim":Color("d9b968")}

static func fortress_center(anchor: Vector2) -> Vector2:
	return anchor+Vector2(68,26) # Cour allongée pour dégager les placements des nouvelles silhouettes.

static func fortress_bounds(anchor: Vector2) -> Rect2:
	return Rect2(fortress_center(anchor)+Vector2(-50,-101),Vector2(106,124))

static func fortress_condition(hp: int, maximum: int) -> int:
	if hp <= 0: return 3
	if maximum <= 0: return 0
	var ratio: float = float(hp)/maximum
	return 2 if ratio <= 0.25 else 1 if ratio <= 0.5 else 0

static func fortress_caption(condition: int) -> String:
	return ["FORTERESSE","FORTERESSE · ENDOMMAGÉE","FORTERESSE · EN DANGER","FORTERESSE DÉTRUITE"][clampi(condition,0,3)]

func _draw_fortress(anchor: Vector2) -> void:
	var center: Vector2 = fortress_center(anchor)
	var faction: int = FortressArt.side(model.faction if model != null else 0)
	var style: Dictionary = fortress_style(faction)
	var condition: int = fortress_condition(model.fortress_hp,model.max_hp) if model != null else 0
	var offset: Vector2 = FortressArt.shake(royal_hurt_age)
	var body: Rect2 = FortressArt.building_rect(faction)
	body.position += center+offset
	draw_colored_polygon(PackedVector2Array([anchor+Vector2(-12,0),anchor+Vector2(36,-5),center+Vector2(43,3),center+Vector2(0,23)]),Color("576650"))
	var brightness: float = 1.0-condition*0.13
	if royal_hurt_age < 0.15: brightness += 0.22*(1.0-royal_hurt_age/0.15)
	draw_texture_rect_region(FortressArt.BUILDINGS[faction],body,FortressArt.SOURCES[faction],Color(brightness,brightness,brightness,1))
	if condition > 0:
		var crack := PackedVector2Array([center+offset+Vector2(-12,-39),center+offset+Vector2(-8,-31),center+offset+Vector2(-11,-23),center+offset+Vector2(-6,-13)])
		draw_polyline(crack,Color("352f25"),1.6,true)
	if condition >= 2:
		for index in range(3):
			var t: float = fmod(flag_phase/TAU+float(index)/3.0,1.0)
			draw_circle(center+Vector2(-12+index*11+sin(t*TAU)*2,-45-t*22),3+3*t,Color(Color("6d7167"),0.28*(1-t)))
	var hp: int = model.fortress_hp if model != null else 20
	var pose: int = FortressArt.king_pose(hp,royal_hurt_age,royal_rally_age)
	var king_center: Vector2 = center+offset+FortressArt.king_anchor(faction)
	var royal: Transform2D = FortressArt.king_transform(pose,flag_phase,royal_hurt_age)
	royal.origin += king_center
	draw_set_transform_matrix(royal)
	draw_texture_rect_region(FortressArt.KINGS[faction],FortressArt.king_rect(faction,pose),FortressArt.KING_FRAMES[faction][pose].source)
	draw_set_transform(Vector2.ZERO)
	# Bannière décalée : elle ne traverse ni le visage ni la couronne du souverain.
	var pole: Vector2 = center+Vector2(34,-25 if condition == 3 else -94)
	draw_line(center+Vector2(34,-10 if condition == 3 else -45),pole,style.trim,1.8,true)
	var flutter: float = sin(flag_phase)*1.5
	draw_colored_polygon(PackedVector2Array([pole+Vector2(1,0),pole+Vector2(19,3+flutter),pole+Vector2(17,13+flutter),pole+Vector2(1,11)]),style.flag)
	var caption: String = fortress_caption(condition)
	var width: float = font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x
	draw_string(font,center+Vector2(-width/2,34),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ed9989") if condition >= 2 else Color("d7bd83") if condition == 1 else INK)

static func _enemy_scale(enemy: Dictionary) -> float:
	return [0.7, 1.0, 0.85, 1.2, 1.0, 1.5, 1.3, 1.7, 1.4][enemy.get("type", 1)]

static func enemy_color(type: int) -> Color:
	return [Color("789263"), Color("b45f4c"), Color("c6a16a"), Color("9e6659"), Color("967556"), Color("838e85"), Color("9777a6"), Color("aca384"),Color("91ab72")][type]

func _draw_pillager(center: Vector2, enemy: Dictionary, hit_strength: float = 0.0, pose: Dictionary = {}) -> void:
	var id: String = enemy_art_id(enemy,model.faction)
	var scale: float = _enemy_scale(enemy)
	var walking: bool = EnemyWalkArt.supports(id)
	var route_points: Array[Vector2] = model.enemy_route_points(enemy)
	var motion := EnemyWalkArt.path_motion(enemy.distance, route_points, AXIS)
	var facing := route_facing(motion.direction)
	var preview: Dictionary = {}
	if walking and wolf_turn_preview.is_valid():
		preview = wolf_turn_preview.call(enemy.distance, route_points, enemy.id, scale)
	center = preview.get("center", center)
	draw_set_transform(center,0.0,Vector2.ONE*scale)
	if enemy.id == inspected_enemy_id:
		draw_arc(Vector2(0,3),14,0,TAU,32,Color("edcc80"),2,true)
	for curse in model.curses:
		if curse.enemy_id != enemy.id: continue
		draw_arc(Vector2(0,-13),19,0,TAU,24,Color("be83d3"),1.5,true)
		var mark := Vector2(0,-45)
		draw_colored_polygon(PackedVector2Array([mark+Vector2(0,-5),mark+Vector2(4,0),mark+Vector2(0,5),mark+Vector2(-4,0)]),Color("d6a1ef"))
		break
	draw_circle(Vector2(0,3),10,Color(0,0,0,0.25),true,-1,true)
	var body: Transform2D = enemy_body_transform(enemy,facing,pose,model.elapsed,model.active and not walking, motion.get("direction", Vector2.ZERO))
	body.origin += center
	draw_set_transform_matrix(body)
	if preview.has("texture"):
		draw_set_transform(body.origin, 0.0, Vector2(preview.get("facing", 1.0), 1.0)*scale)
		draw_mesh(preview.mesh, preview.texture, Transform2D.IDENTITY, EnemyArt.tint(hit_strength))
	elif walking:
		var phase: float=EnemyWalkArt.phase_for(preview.get("travel", motion.travel),enemy.id,scale)
		var orientation: Vector2 = preview.get("direction", motion.direction)
		var ground := Vector2(absf(orientation.x), orientation.y)
		draw_mesh(walking_meshes.mesh_for(enemy.id,phase,ground),EnemyWalkArt.TEXTURE,Transform2D.IDENTITY,EnemyArt.tint(hit_strength))
	else:
		draw_texture_rect_region(EnemyArt.TEXTURES[id],EnemyArt.destination(id),EnemyArt.FRAMES[id].source,EnemyArt.tint(hit_strength))
	if enemy.type == Model.Banks.GUARD_TYPE and model.active:
		for index in range(model.protection_events.size()-1,-1,-1):
			var event: Dictionary = model.protection_events[index]
			var age: float = model.elapsed-event.time
			if age >= 0.4: break
			if age < 0.0 or event.get("guardian_id", -1) != enemy.id: continue
			var strength := 1.0-age/0.4
			var shell := Vector2(-4,-18)
			draw_circle(shell,11.0+5.0*(1.0-strength),Color(0.78,0.96,0.49,0.18*strength),true,-1,true)
			draw_arc(shell,10.0+4.0*(1.0-strength),PI,TAU,20,Color(0.86,1.0,0.62,0.90*strength),2.0,true)
			break
	draw_set_transform(Vector2.ZERO)

func _draw_valley_water() -> void:
	# La rivière et le pont sont des éléments visuels, sans collision.
	polygon([Vector2(5.86,0),Vector2(7.14,0),Vector2(7.14,10),Vector2(5.86,10)],Color("68755a"))
	polygon([Vector2(6, 0), Vector2(7, 0), Vector2(7, 10), Vector2(6, 10)], Color("407b7d"))
	polygon([Vector2(6.76,0),Vector2(7,0),Vector2(7,10),Vector2(6.76,10)],Color("315e67"))
	for y in range(10):
		draw_line(project(Vector2(6.16,y+0.24)),project(Vector2(6.52,y+0.28)),Color("83b7ab"),1.2,true)
		draw_line(project(Vector2(6.45,y+0.65)),project(Vector2(6.82,y+0.68)),Color("659c9c"),1.2,true)

func _draw_valley_bridge() -> void:
	polygon([Vector2(5.8, 6.55), Vector2(7.2, 6.55), Vector2(7.2, 7.45), Vector2(5.8, 7.45)], Color("77654c"))
	for plank in range(8):
		var x: float = 5.85 + plank * 0.18
		draw_line(project(Vector2(x, 6.6)), project(Vector2(x, 7.4)), Color("b29a6b"), 2)
	for bank in [6.55,7.45]:
		var first: Vector2 = project(Vector2(5.8,bank))
		var last: Vector2 = project(Vector2(7.2,bank))
		draw_line(first+Vector2(0,-5),last+Vector2(0,-5),Color("c3aa78"),2,true)
		for post in [first,last]: draw_line(post,post+Vector2(0,-8),Color("725c42"),3,true)
