extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const HordeArt = preload("res://scripts/horde_art.gd")
const AllianceArt = preload("res://scripts/alliance_art.gd")
const EnemyArt = preload("res://scripts/enemy_art.gd")
const ORIGIN := Vector2(658, 174)
const AXIS := Vector2(27, 13.5)
const INK := Color("d9e4d7")
const SLOT_FILL := Color("213e3b")
const IMPACT_DURATION := 0.32 # Secondes de simulation, comme les autres effets du combat.
const DAMAGE_TRAIL_DURATION := 0.40
const HIT_FLASH_DURATION := 0.16
var model: RefCounted
var selected: int = -1
var purchase_preview: Dictionary = {}
var upgrade_preview: Dictionary = {}
var preview_synergy_unit: Dictionary = {}
var inspected_enemy_id: int = -1
var breach_feedback: Dictionary = {}
var font: Font = ThemeDB.fallback_font

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

static func project(point: Vector2) -> Vector2:
	return ORIGIN + Vector2((point.x - point.y) * AXIS.x, (point.x + point.y) * AXIS.y)

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

static func secondary_segments(shot: Dictionary) -> Array[PackedVector2Array]:
	var segments: Array[PackedVector2Array] = []
	var origin: Vector2 = shot.to
	for target in shot.get("secondary", []):
		segments.append(PackedVector2Array([project(origin), project(target)]))
		if shot.type == 3: origin = target
	return segments

const PROJECTILE_FLIGHT := 0.12 # Habillage du tir déjà résolu ; aucune attente de dégâts.

static func shot_origin(shot: Dictionary) -> Vector2:
	# Points d'équipement des silhouettes, distincts du centre logique de portée.
	var art = AllianceArt if AllianceArt.MUZZLES.has(int(shot.type)) else HordeArt
	var muzzle: Vector2 = art.MUZZLES[int(shot.type)]
	return project(shot.from)+Vector2(muzzle.x*shot_facing(shot),muzzle.y)

static func shot_facing(shot: Dictionary) -> float:
	return -1.0 if project(shot.to).x < project(shot.from).x else 1.0

static func projectile_position(shot: Dictionary, age: float) -> Vector2:
	var progress: float = clampf(age / PROJECTILE_FLIGHT,0.0,1.0)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var point: Vector2 = origin.lerp(target,progress)
	if shot.type in [3,4]: point.y -= sin(PI*progress)*(15.0 if shot.type == 4 else 8.0)
	return point

func _draw_projectile(shot: Dictionary, age: float, color: Color) -> void:
	if age < 0.0 or age >= PROJECTILE_FLIGHT: return
	var point: Vector2 = projectile_position(shot,age)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var direction: Vector2 = (target-origin).normalized()
	if direction.is_zero_approx(): direction = Vector2.RIGHT
	var side: Vector2 = direction.orthogonal()
	match int(shot.type):
		0,1:
			var length: float = 13.0 if shot.type == 0 else 9.0
			draw_line(point-direction*length,point,Color("ead9a8"),1.8 if shot.type == 0 else 3.0,true)
			draw_colored_polygon(PackedVector2Array([point+direction*3,point-direction*3+side*3,point-direction*3-side*3]),Color("e4f0e7"))
			for sign in [-1,1]: draw_line(point-direction*(length-3),point-direction*length+side*sign*3,color,1.5,true)
		2:
			draw_circle(point,7,Color(color,0.12),true,-1,true)
			draw_circle(point,3.5,color,true,-1,true)
			draw_circle(point+Vector2(-1,-1),1.5,Color("ecffff"),true,-1,true)
		3:
			var rotation: float = age/PROJECTILE_FLIGHT*TAU
			var shaft := Vector2(cos(rotation),sin(rotation))
			var edge: Vector2 = shaft.orthogonal()
			draw_line(point-shaft*6,point+shaft*5,Color("d0ac75"),2.5,true)
			draw_colored_polygon(PackedVector2Array([point+shaft*4,point+shaft*7+edge*6,point-shaft*2+edge*7,point-shaft*3+edge*3]),Color("c9e5da"))
		4:
			draw_circle(point,5,Color("253a3e"),true,-1,true)
			draw_arc(point,4,3.7,5.0,8,Color("a6b7a9"),1.5,true)
			draw_line(point+Vector2(2,-4),point+Vector2(4,-8),Color("d8b16b"),1.5,true)
			draw_circle(point+Vector2(4,-8),2,color,true,-1,true)
		5:
			var cross := PackedVector2Array([point+Vector2(0,-6),point+Vector2(4,0),point+Vector2(0,6),point+Vector2(-4,0)])
			draw_colored_polygon(cross,color)
			draw_line(point+Vector2(0,-3),point+Vector2(0,3),Color("f5def5"),1.5,true)

func _draw_hit_marker(point: Vector2, alpha: float, primary: bool, type: int, age: float) -> void:
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
	var type: int = shot.type
	var color: Color = [Color("f0d796"),Color("e1e9dc"),Color("90dceb"),Color("a8ddbd"),Color("f2b269"),Color("d1a3ed")][type]
	color.a = alpha
	var height := Vector2(0,-12)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+height
	# L'impact est visible dès le tir : le déplacement bref ne retarde aucun dégât.
	_draw_hit_marker(target,alpha,true,type,age)
	if type == 5:
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
	for segment in secondary_segments(shot):
		var secondary: Vector2 = segment[1]+height
		if type == 3:
			var start: Vector2 = segment[0]+height
			draw_line(start,secondary,Color(color,alpha*0.65),1.8,true)
			if start.distance_to(secondary) > 8:
				var direction: Vector2 = (secondary-start).normalized()
				var tip: Vector2 = start.lerp(secondary,0.65)
				draw_polyline(PackedVector2Array([tip-direction.rotated(0.55)*5,tip,tip-direction.rotated(-0.55)*5]),color,1.5,true)
		_draw_hit_marker(secondary,alpha,false,type,age)


static func enemy_bounds(enemy: Dictionary) -> Rect2:
	var center: Vector2 = project(Model.position_at(enemy.distance))
	var scale: float = _enemy_scale(enemy)
	var width: float = maxf(28.0,32.0*scale)
	var bounds := Rect2(center+Vector2(-width/2.0,-39.0*scale),Vector2(width,47.0*scale))
	if EnemyArt.TEXTURES.has(int(enemy.get("type",1))):
		var image: Rect2 = EnemyArt.destination(int(enemy.get("type",1)))
		if enemy_facing(enemy) < 0.0: image.position.x = -image.end.x
		bounds = bounds.merge(Rect2(center+image.position*scale,image.size*scale).grow(1.0))
	return bounds

static func enemy_facing(enemy: Dictionary) -> float:
	var distance: float = clampf(enemy.distance,0.0,Model.PATH_LENGTH)
	var from: Vector2 = project(Model.position_at(distance))
	var to: Vector2 = project(Model.position_at(minf(distance+0.01,Model.PATH_LENGTH)))
	if distance == Model.PATH_LENGTH:
		from = project(Model.position_at(maxf(0.0,distance-0.01)))
	return -1.0 if to.x < from.x else 1.0

func enemy_at(point: Vector2) -> int:
	if model == null: return -1
	var found: int = -1
	var front_y: float = -INF
	for enemy in model.enemies:
		if enemy.hp <= 0.0 or not enemy_bounds(enemy).has_point(point): continue
		var y: float = project(Model.position_at(enemy.distance)).y
		if y >= front_y: # Même priorité visuelle que le dessin, dernier acteur en cas d'égalité.
			front_y = y
			found = enemy.id
	return found

static func covered_route(center: Vector2, radius: float) -> Array[PackedVector2Array]:
	var sections: Array[PackedVector2Array] = []
	for window in Model.coverage_windows(center, radius):
		var points := PackedVector2Array([project(Model.position_at(window.first))])
		var distance: float = 0.0
		for index in range(1, Model.PATH_POINTS.size()):
			distance += Model.PATH_POINTS[index-1].distance_to(Model.PATH_POINTS[index])
			if distance > window.first + Model.EPS and distance < window.last - Model.EPS:
				points.append(project(Model.PATH_POINTS[index]))
		points.append(project(Model.position_at(window.last)))
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
		var start: Vector2 = project(Model.SLOTS[selected]) + offset
		var finish: Vector2 = project(Model.SLOTS[link.partner]) + offset
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

func _draw() -> void:
	var corners: Array[Vector2] = [Vector2.ZERO, Vector2(18, 0), Vector2(18, 10), Vector2(0, 10)]
	var base := PackedVector2Array()
	for corner in corners:
		base.append(project(corner) + Vector2(0, 16))
	draw_colored_polygon(base, Color("172c2b"))
	# Deux faces donnent de l'épaisseur au plateau, sans déplacer sa surface logique.
	for edge in [[corners[1],corners[2],Color("263e34")],[corners[2],corners[3],Color("1c322c")]]:
		var first: Vector2 = project(edge[0])
		var last: Vector2 = project(edge[1])
		draw_colored_polygon(PackedVector2Array([first,last,last+Vector2(0,16),first+Vector2(0,16)]),edge[2])
	polygon(corners, Color("3a513e"))
	for x in range(19):
		draw_line(project(Vector2(x, 0)), project(Vector2(x, 10)), Color(0.75, 0.86, 0.7, 0.055), 1)
	for y in range(11):
		draw_line(project(Vector2(0, y)), project(Vector2(18, y)), Color(0.75, 0.86, 0.7, 0.055), 1)
	# La rivière et le pont sont des éléments visuels, sans collision.
	polygon([Vector2(5.86,0),Vector2(7.14,0),Vector2(7.14,10),Vector2(5.86,10)],Color("68755a"))
	polygon([Vector2(6, 0), Vector2(7, 0), Vector2(7, 10), Vector2(6, 10)], Color("407b7d"))
	polygon([Vector2(6.76,0),Vector2(7,0),Vector2(7,10),Vector2(6.76,10)],Color("315e67"))
	for y in range(10):
		draw_line(project(Vector2(6.16,y+0.24)),project(Vector2(6.52,y+0.28)),Color("83b7ab"),1.2,true)
		draw_line(project(Vector2(6.45,y+0.65)),project(Vector2(6.82,y+0.68)),Color("659c9c"),1.2,true)
	var route := PackedVector2Array()
	for point in Model.PATH_POINTS:
		route.append(project(point))
	draw_polyline(route, Color("26372e"), 28, true)
	draw_polyline(route, Color("b3a17b"), 20, true)
	for point in route:
		draw_circle(point, 10, Color("b3a17b"))
	draw_polyline(route, Color("c7b58d"), 2, true)
	polygon([Vector2(5.8, 6.55), Vector2(7.2, 6.55), Vector2(7.2, 7.45), Vector2(5.8, 7.45)], Color("77654c"))
	for plank in range(8):
		var x: float = 5.85 + plank * 0.18
		draw_line(project(Vector2(x, 6.6)), project(Vector2(x, 7.4)), Color("b29a6b"), 2)
	for bank in [6.55,7.45]:
		var first: Vector2 = project(Vector2(5.8,bank))
		var last: Vector2 = project(Vector2(7.2,bank))
		draw_line(first+Vector2(0,-5),last+Vector2(0,-5),Color("c3aa78"),2,true)
		for post in [first,last]: draw_line(post,post+Vector2(0,-8),Color("725c42"),3,true)
	for tree in [Vector2(1, 1), Vector2(1.4, 8.5), Vector2(4.6, 9), Vector2(10, 1), Vector2(12, 8.7), Vector2(16.8, 2), Vector2(17, 8.7)]:
		_draw_tree(project(tree))
	var preview: Dictionary = purchase_preview if not purchase_preview.is_empty() else upgrade_preview
	if model != null and selected >= 0 and not preview.is_empty():
		var preview_ring := range_outline(Model.SLOTS[selected], preview.range)
		draw_colored_polygon(preview_ring, Color(0.35, 0.8, 0.95, 0.12))
		draw_polyline(preview_ring, Color("8bd5e6"), 2.5, true)
		for section in covered_route(Model.SLOTS[selected], preview.range):
			draw_polyline(section, Color("8bd5e6"), 6, true)
		if not preview_synergy_unit.is_empty(): _draw_synergy_links(preview_synergy_unit)
	if model != null and selected >= 0 and not model.defenders[selected].is_empty():
		var stats: Dictionary = model.get_stats(selected)
		var ring := range_outline(Model.SLOTS[selected], stats.range)
		draw_colored_polygon(ring, Color(0.8, 0.85, 0.5, 0.05))
		draw_polyline(ring, Color(0.8, 0.85, 0.5, 0.35), 1.5, true)
		if preview.is_empty():
			for section in covered_route(Model.SLOTS[selected],stats.range):
				draw_polyline(section,Color(0.9,0.77,0.48,0.65),4,true)
		if preview.is_empty(): _draw_synergy_links()
	for index in range(Model.SLOTS.size()):
		var center: Vector2 = project(Model.SLOTS[index])
		var diamond := PackedVector2Array([center + Vector2(-26, 0), center + Vector2(0, -13), center + Vector2(26, 0), center + Vector2(0, 13)])
		draw_colored_polygon(diamond, SLOT_FILL)
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color("ddbd78") if selected == index else Color("779b89"), 2, true)
		var occupied: bool = model != null and not model.defenders[index].is_empty()
		draw_string(font, center + Vector2(-9, 22 if occupied else 5), "E%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)
	_draw_fortress(project(Vector2(17, 6)))
	var entrance: Vector2 = project(Model.PATH_POINTS[0])
	draw_circle(entrance, 5, Color("debd7f"))
	draw_string(font, entrance + Vector2(-48, -20), "ENTRÉE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a7b8aa"))
	if model != null:
		var actors: Array[Dictionary] = []
		for slot in range(model.defenders.size()):
			if not model.defenders[slot].is_empty():
				actors.append({"point": project(Model.SLOTS[slot]), "defender": model.defenders[slot],"slot":slot,"order":actors.size()})
		for enemy in model.enemies:
			actors.append({"point": project(Model.position_at(enemy.distance)), "enemy": enemy,"order":actors.size()})
		actors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order if a.point.y == b.point.y else a.point.y < b.point.y)
		for actor in actors:
			if actor.has("defender"):
				_draw_defender(actor.point, actor.defender.type, actor.defender.get("level", 1), actor.defender.get("branch", -1), defender_pose(actor.slot))
			else:
				var feedback: Array[Dictionary] = recent_enemy_damage(actor.enemy.id)
				_draw_pillager(actor.point, actor.enemy,enemy_hit_strength(feedback))
				var ratio: float = clampf(actor.enemy.hp / actor.enemy.get("max_hp", 40.0), 0.0, 1.0)
				var bar_position: Vector2 = actor.point + Vector2(-12, -39 * _enemy_scale(actor.enemy))
				draw_rect(Rect2(bar_position, Vector2(24, 4)), Color("472f2a"))
				draw_rect(Rect2(bar_position, Vector2(24 * ratio, 4)), Color("edcc80") if actor.enemy.id == inspected_enemy_id else Color("a1ba75"))
				for event in feedback:
					var span: Vector2 = damage_span(event,actor.enemy.get("max_hp",40.0))
					if span.y > span.x:
						draw_rect(Rect2(bar_position+Vector2(24*span.x,0),Vector2(24*(span.y-span.x),4)),Color(Color("f3dfba"),damage_opacity(model.elapsed-event.time)))
		if model.active:
			for shot in model.shots:
				_draw_impact(shot, model.elapsed - shot.time)
	if not breach_feedback.is_empty(): _draw_breach_feedback()

static func breach_text(count: int, damage: int) -> String:
	return "−%d PV · %d ennemi%s passé%s" % [damage,count,"" if count == 1 else "s","" if count == 1 else "s"]

func _draw_breach_feedback() -> void:
	var center: Vector2 = project(Vector2(17,6)) + Vector2(52,26)
	var warning := Color("ef9b89")
	draw_rect(Rect2(center+Vector2(-42,-72),Vector2(84,92)),Color(warning,0.75),false,2)
	var text: String = breach_text(breach_feedback.count,breach_feedback.damage)
	var width: float = font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x+24
	var box := Rect2(center+Vector2(-width/2.0,-110),Vector2(width,30))
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
	if model == null or not model.active: return pose
	# Garder le côté du dernier tir de cet emplacement après la fin du mouvement.
	for index in range(model.shots.size()-1,-1,-1):
		var shot: Dictionary = model.shots[index]
		var age: float = model.elapsed-shot.time
		if shot.slot != slot or age < 0.0: continue
		pose.pulse = attack_pulse(age)
		pose.direction = shot_facing(shot)
		break
	return pose

static func attack_transform(type: int, pose: Dictionary) -> Transform2D:
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

func _draw_defender(center: Vector2, type: int, level: int = 1, branch: int = -1, pose: Dictionary = {}) -> void:
	var art = AllianceArt if AllianceArt.TEXTURES.has(type) else HordeArt
	if not art.TEXTURES.has(type): return
	_draw_illustrated_defender(center,type,pose,art)
	_draw_level_badge(center,level,branch)

func _draw_illustrated_defender(center: Vector2, type: int, pose: Dictionary, art: GDScript) -> void:
	draw_set_transform(center+Vector2(0,2),0,Vector2(1,0.45))
	draw_circle(Vector2.ZERO,12,Color(0,0,0,0.25),true,-1,true)
	var transform: Transform2D = attack_transform(type,pose)
	transform.origin += center
	draw_set_transform_matrix(transform)
	draw_texture_rect_region(art.TEXTURES[type],art.destination(type),art.FRAMES[type].source)
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

func _draw_fortress(anchor: Vector2) -> void:
	# Décaler le bâtiment dans sa cour pour laisser le repère E6 visible.
	# Le point d'arrivée logique demeure H (17 ; 6).
	var center: Vector2 = anchor + Vector2(52, 26)
	draw_colored_polygon(PackedVector2Array([anchor + Vector2(-12, 0), anchor + Vector2(36, -5), center + Vector2(37, 0), center + Vector2(0, 21)]), Color("576650"))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-31, -8), center + Vector2(0, -23), center + Vector2(31, -8), center + Vector2(0, 9)]), Color("64766a"))
	for offset in [-23, 23]:
		var tower: Vector2 = center + Vector2(offset, -8)
		draw_rect(Rect2(tower + Vector2(-9, -39), Vector2(18, 39)), Color("a9b5a4"))
		draw_rect(Rect2(tower + Vector2(1, -39), Vector2(8, 39)), Color("7e9285"))
		draw_colored_polygon(PackedVector2Array([tower + Vector2(-13, -39), tower + Vector2(0, -57), tower + Vector2(13, -39)]), Color("315b68"))
	draw_rect(Rect2(center + Vector2(-17, -34), Vector2(34, 29)), Color("8b9e8e"))
	for height in [-28,-19,-10]:
		draw_line(center+Vector2(-16,height),center+Vector2(16,height),Color("7a9082"),1)
	draw_circle(center+Vector2(0,-24),6,Color("233c36"))
	draw_rect(Rect2(center + Vector2(-6, -24), Vector2(12, 19)), Color("233c36"))
	for offset in [-3,3]:draw_line(center+Vector2(offset,-26),center+Vector2(offset,-5),Color("4f6858"),1)
	draw_line(center + Vector2(0, -36), center + Vector2(0, -68), Color("d0bc8c"), 2)
	draw_colored_polygon(PackedVector2Array([center + Vector2(1, -68), center + Vector2(20, -62), center + Vector2(1, -55)]), Color("d3b676"))
	draw_string(font, center + Vector2(-42, 32), "FORTERESSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, INK)

static func _enemy_scale(enemy: Dictionary) -> float:
	return [0.7, 1.0, 0.85, 1.2, 1.0, 1.5, 1.3, 1.7][enemy.get("type", 1)]

static func enemy_color(type: int) -> Color:
	return [Color("789263"), Color("b45f4c"), Color("c6a16a"), Color("9e6659"), Color("967556"), Color("838e85"), Color("9777a6"), Color("aca384")][type]

func _draw_pillager(center: Vector2, enemy: Dictionary, hit_strength: float = 0.0) -> void:
	var anchor: Vector2 = center
	var type: int = enemy.get("type", 1)
	var flash: float = clampf(hit_strength,0.0,1.0)*0.55
	var armor: Color = enemy_color(type).lightened(flash)
	draw_set_transform(center, 0.0, Vector2.ONE * _enemy_scale(enemy))
	center = Vector2.ZERO
	if enemy.id == inspected_enemy_id:
		draw_arc(center+Vector2(0,3),14,0,TAU,32,Color("edcc80"),2,true)
	for curse in model.curses:
		if curse.enemy_id == enemy.id:
			draw_arc(center + Vector2(0, -13), 19, 0, TAU, 24, Color("be83d3"), 1.5, true)
			var mark: Vector2 = center + Vector2(0, -45)
			draw_colored_polygon(PackedVector2Array([mark+Vector2(0,-5),mark+Vector2(4,0),mark+Vector2(0,5),mark+Vector2(-4,0)]), Color("d6a1ef"))
			break
	draw_circle(Vector2(0,3),10,Color(0,0,0,0.25),true,-1,true)
	var stride: float = sin(model.elapsed*10.0*enemy.get("speed",1.0)+enemy.id)*2.0 if model.active else 0.0
	if EnemyArt.TEXTURES.has(type):
		var scale: float = _enemy_scale(enemy)
		draw_set_transform(anchor+Vector2(0,-absf(stride)*0.3*scale),0.0,Vector2(enemy_facing(enemy)*scale,scale))
		draw_texture_rect_region(EnemyArt.TEXTURES[type],EnemyArt.destination(type),EnemyArt.FRAMES[type].source,EnemyArt.tint(hit_strength))
		draw_set_transform(Vector2.ZERO)
		return
	var skin: Color = Color("dbb991").lightened(flash)
	var metal: Color = Color("b5bfb8").lightened(flash)
	_unit_stroke(Vector2(-4,-4),Vector2(-6+stride,4),Color("655043"),4)
	_unit_stroke(Vector2(4,-4),Vector2(6-stride,4),Color("655043"),4)
	match type:
		3: # Torse massif, bras nus et massue à gros nœuds.
			_unit_shape([Vector2(-11,-21),Vector2(10,-21),Vector2(11,-5),Vector2(-11,-5)],armor)
			_unit_stroke(Vector2(-11,-19),Vector2(-13,-8),skin,5)
			_unit_stroke(Vector2(10,-19),Vector2(14,-13),skin,5)
			_unit_face(skin,7.5,-26)
			_unit_stroke(Vector2(-6,-30),Vector2(5,-30),Color("76513d"),3)
			_unit_stroke(Vector2(-10,-6),Vector2(10,-6),Color("564439"),3)
			_unit_stroke(Vector2(13,-3),Vector2(13,-25),Color("a57a4f"),3)
			_unit_shape([Vector2(9,-29),Vector2(17,-30),Vector2(18,-19),Vector2(10,-17)],Color("806044"))
			for y in [-26,-21]: draw_line(Vector2(12,y),Vector2(16,y-1),Color("bd9561"),1.5,true)
		4: # Harnais et deux haches, posture d’assaillant.
			_unit_shape([Vector2(-8,-20),Vector2(8,-20),Vector2(10,-4),Vector2(-9,-4)],armor)
			_unit_stroke(Vector2(-6,-20),Vector2(5,-5),Color("624535"),3)
			_unit_stroke(Vector2(6,-20),Vector2(-5,-5),Color("624535"),3)
			_unit_face(skin,7,-25)
			_unit_shape([Vector2(-7,-28),Vector2(-5,-32),Vector2(5,-32),Vector2(8,-27),Vector2(1,-29)],Color("5c4940"))
			for side in [-1,1]:
				_unit_stroke(Vector2(side*7,-18),Vector2(side*12,-12),skin,3)
				_unit_stroke(Vector2(side*12,-3),Vector2(side*12,-26),Color("ad8754"),2)
				_unit_shape([Vector2(side*11,-26),Vector2(side*17,-23),Vector2(side*17,-17),Vector2(side*11,-18)],metal)
		5: # Armure carrée et marteau lourd, silhouette la plus large hors boss.
			_unit_shape([Vector2(-12,-21),Vector2(12,-21),Vector2(12,-4),Vector2(-12,-4)],armor)
			_unit_shape([Vector2(-8,-20),Vector2(8,-20),Vector2(7,-10),Vector2(-7,-10)],armor.lightened(0.18))
			_unit_stroke(Vector2(-11,-6),Vector2(11,-6),Color("455754"),3)
			for side in [-1,1]: _unit_shape([Vector2(side*6,-25),Vector2(side*13,-25),Vector2(side*15,-17),Vector2(side*7,-17)],metal.darkened(0.12))
			_unit_shape([Vector2(-7,-31),Vector2(7,-31),Vector2(8,-22),Vector2(-8,-22)],armor.lightened(0.1))
			_unit_stroke(Vector2(-5,-26),Vector2(5,-26),UNIT_INK,1.5)
			_unit_stroke(Vector2(13,-1),Vector2(13,-24),Color("ae8d5f"),3)
			_unit_shape([Vector2(6,-30),Vector2(19,-30),Vector2(19,-22),Vector2(6,-22)],metal)
			draw_line(Vector2(9,-28),Vector2(17,-28),Color("e0e4d3"),1.5,true)
		6: # Casque à crête, bouclier pointu et lance.
			_unit_shape([Vector2(-8,-20),Vector2(8,-20),Vector2(10,-3),Vector2(-10,-3)],armor)
			_unit_face(skin,6.5,-25)
			_unit_shape([Vector2(-7,-29),Vector2(6,-29),Vector2(8,-24),Vector2(-7,-24)],metal.darkened(0.1))
			_unit_shape([Vector2(-3,-30),Vector2(-3,-34),Vector2(4,-34),Vector2(6,-30)],Color("c7a4ce"))
			_unit_shape([Vector2(-15,-21),Vector2(-4,-21),Vector2(-4,-10),Vector2(-9,-3),Vector2(-15,-10)],armor.darkened(0.2))
			_unit_shape([Vector2(-9,-18),Vector2(-6,-13),Vector2(-9,-8),Vector2(-12,-13)],Color("e7ce82"),0.8)
			_unit_stroke(Vector2(12,1),Vector2(12,-29),Color("d2b77f"),2)
			_unit_shape([Vector2(12,-34),Vector2(15,-27),Vector2(9,-27)],metal)
		7: # Cape écarlate, grandes épaulières, couronne et épée de siège.
			_unit_shape([Vector2(-8,-23),Vector2(8,-23),Vector2(14,4),Vector2(0,1),Vector2(-14,4)],Color("813e49"))
			_unit_shape([Vector2(-9,-20),Vector2(9,-20),Vector2(10,-3),Vector2(-10,-3)],armor.darkened(0.25))
			_unit_shape([Vector2(-5,-18),Vector2(5,-18),Vector2(7,-8),Vector2(0,-4),Vector2(-7,-8)],armor)
			for side in [-1,1]: _unit_shape([Vector2(side*6,-24),Vector2(side*13,-24),Vector2(side*15,-18),Vector2(side*7,-17)],Color("c6a66a"))
			_unit_face(skin,7,-25)
			_unit_shape([Vector2(-7,-28),Vector2(-7,-33),Vector2(-3,-30),Vector2(0,-34),Vector2(3,-30),Vector2(7,-33),Vector2(7,-28)],Color("edce80"))
			_unit_stroke(Vector2(-6,-4),Vector2(6,-4),Color("c6a66a"),2)
			_unit_stroke(Vector2(13,1),Vector2(13,-27),Color("d7dacf"),3)
			_unit_stroke(Vector2(8,-8),Vector2(17,-8),Color("edce80"),2)

	draw_set_transform(Vector2.ZERO)
