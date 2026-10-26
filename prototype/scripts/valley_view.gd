extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const ORIGIN := Vector2(658, 174)
const AXIS := Vector2(27, 13.5)
const INK := Color("d9e4d7")
const SLOT_FILL := Color("213e3b")
const IMPACT_DURATION := 0.32 # Secondes de simulation, comme les autres effets du combat.
var model: RefCounted
var selected: int = -1
var purchase_preview: Dictionary = {}
var upgrade_preview: Dictionary = {}
var preview_synergy_unit: Dictionary = {}
var inspected_enemy_id: int = -1
var breach_feedback: Dictionary = {}
var font: Font = ThemeDB.fallback_font

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
	var offset: Vector2 = [Vector2(12,-21),Vector2(3,-22),Vector2(15,-41),Vector2(12,-34),Vector2(15,-12),Vector2(17,-40)][int(shot.type)]
	return project(shot.from)+offset

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
	return Rect2(center+Vector2(-width/2.0,-39.0*scale),Vector2(width,47.0*scale))

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
				_draw_pillager(actor.point, actor.enemy)
				var ratio: float = clampf(actor.enemy.hp / actor.enemy.get("max_hp", 40.0), 0.0, 1.0)
				var bar_position: Vector2 = actor.point + Vector2(-12, -36 * _enemy_scale(actor.enemy))
				draw_rect(Rect2(bar_position, Vector2(24, 4)), Color("472f2a"))
				draw_rect(Rect2(bar_position, Vector2(24 * ratio, 4)), Color("edcc80") if actor.enemy.id == inspected_enemy_id else Color("a1ba75"))
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

# Animation issue des tirs réels, dans le temps simulé. Aucune horloge ni RNG de jeu modifiée.
static func attack_pulse(age: float) -> float:
	if age < 0.0 or age >= ATTACK_POSE_DURATION: return 0.0
	return sin(PI * age / ATTACK_POSE_DURATION)

func defender_pose(slot: int) -> Dictionary:
	var pose: Dictionary = {"pulse":0.0,"direction":1.0}
	if model == null or not model.active: return pose
	# Les tirs sont chronologiques ; arrêter dès que l'historique est trop ancien.
	for index in range(model.shots.size()-1,-1,-1):
		var shot: Dictionary = model.shots[index]
		var age: float = model.elapsed-shot.time
		if age >= ATTACK_POSE_DURATION: break
		if shot.slot != slot or age < 0.0: continue
		pose.pulse = attack_pulse(age)
		pose.direction = -1.0 if project(shot.to).x < project(shot.from).x else 1.0
		break
	return pose

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
	var pulse: float = pose.get("pulse",0.0)
	var direction: float = pose.get("direction",1.0)
	var trim := Color("f1ce79") if level == 4 else Color("b7c7b7")
	draw_set_transform(center,0,Vector2(1,0.45))
	draw_circle(Vector2(0,5),14,Color(0,0,0,0.25),true,-1,true)
	draw_set_transform(center+Vector2(-direction*pulse*1.8,-pulse*1.5))
	# Grosses mains, tête et équipement : silhouettes lisibles à la taille réelle du plateau.
	match type:
		0: # Elfe : cape en feuille, oreilles longues, arc et carquois.
			_unit_shape([Vector2(-8,-29),Vector2(6,-28),Vector2(10,0),Vector2(-12,-1)],Color("275b4b"))
			_unit_stroke(Vector2(-5,-5),Vector2(-6,1),Color("6a513b"),4)
			_unit_stroke(Vector2(4,-5),Vector2(5,1),Color("6a513b"),4)
			_unit_shape([Vector2(-6,-25),Vector2(6,-24),Vector2(7,-7),Vector2(-7,-7)],Color("689d65"))
			_unit_stroke(Vector2(-9,-24),Vector2(-12,-37),Color("ae8052"),3)
			for x in [-13,-10]: _unit_stroke(Vector2(x,-35),Vector2(x-2,-40),Color("d6e4bf"),1)
			_unit_shape([Vector2(-6,-34),Vector2(-15,-34),Vector2(-6,-27)],Color("ebcda1"))
			_unit_shape([Vector2(6,-34),Vector2(13,-37),Vector2(6,-27)],Color("ebcda1"))
			_unit_face(Color("ebcda1"),7,-31)
			_unit_shape([Vector2(-7,-34),Vector2(-4,-40),Vector2(4,-39),Vector2(8,-33),Vector2(0,-35)],Color("dfc473"))
			_unit_stroke(Vector2(-5,-23),Vector2(7+pulse*2,-21),Color("ebcda1"),3)
			draw_arc(Vector2(7+pulse*3,-22),13,-PI/2,PI/2,20,UNIT_INK,4,true)
			draw_arc(Vector2(7+pulse*3,-22),13,-PI/2,PI/2,20,Color("d5ae70"),2,true)
			draw_line(Vector2(7+pulse*3,-35),Vector2(4-pulse*2,-22),Color("e9e6cf"),1,true)
			draw_line(Vector2(4-pulse*2,-22),Vector2(7+pulse*3,-9),Color("e9e6cf"),1,true)
			_unit_stroke(Vector2(-2,-21),Vector2(18,-21),Color("d8e4ca"),1)
		1: # Nain : trapu, barbe cuivrée, casque et arbalète horizontale.
			_unit_stroke(Vector2(-7,-4),Vector2(-8,1),Color("72523e"),6)
			_unit_stroke(Vector2(7,-4),Vector2(8,1),Color("72523e"),6)
			_unit_shape([Vector2(-12,-24),Vector2(11,-24),Vector2(13,-6),Vector2(-13,-6)],Color("5e83a2"))
			for side in [-1,1]: _unit_disk(Vector2(side*11,-23),5,trim)
			_unit_face(Color("e6b68a"),8,-30)
			_unit_shape([Vector2(-8,-29),Vector2(-6,-17),Vector2(0,-11),Vector2(6,-17),Vector2(8,-29),Vector2(0,-25)],Color("b46f3f"))
			_unit_stroke(Vector2(0,-24),Vector2(0,-16),Color("e1a45f"),2)
			_unit_shape([Vector2(-9,-32),Vector2(-7,-39),Vector2(4,-41),Vector2(9,-34),Vector2(9,-31)],Color("899da8"))
			_unit_stroke(Vector2(-9,-32),Vector2(9,-32),trim,2)
			_unit_stroke(Vector2(0,-40),Vector2(0,-34),Color("e2c77e"),2)
			_unit_stroke(Vector2(-6,-19),Vector2(5,-18+pulse*2),Color("e6b68a"),4)
			_unit_stroke(Vector2(2,-27+pulse*2),Vector2(3,-10+pulse*2),Color("916c4b"),4)
			_unit_stroke(Vector2(-14,-22+pulse*2),Vector2(15,-22+pulse*2),Color("d3bd82"),3)
			draw_polyline(PackedVector2Array([Vector2(-14,-22+pulse*2),Vector2(2,-16+pulse*2),Vector2(15,-22+pulse*2)]),Color("f3e8c6"),1,true)
		2: # Humain : robe bleue, haut chapeau et bâton à cristal.
			_unit_shape([Vector2(-7,-26),Vector2(7,-26),Vector2(12,0),Vector2(-12,0)],Color("426fba"))
			_unit_shape([Vector2(0,-24),Vector2(4,-24),Vector2(7,0),Vector2(1,0)],Color("7ba7d4"),0.8)
			_unit_stroke(Vector2(-9,-1),Vector2(10,-1),trim,2)
			_unit_stroke(Vector2(-7,-21),Vector2(-10,-13),Color("5d88c2"),5)
			_unit_face(Color("ebc9a3"),7,-31)
			_unit_shape([Vector2(-4,-28),Vector2(5,-28),Vector2(2,-21)],Color("dadbcf"),0.8)
			_unit_shape([Vector2(-12,-34),Vector2(-4,-36),Vector2(0,-51),Vector2(7,-38),Vector2(12,-34)],Color("4c78ba"))
			_unit_stroke(Vector2(-7,-35),Vector2(8,-35),trim,2)
			_unit_stroke(Vector2(8,-22),Vector2(15,-21),Color("ebc9a3"),3)
			_unit_stroke(Vector2(15,-1),Vector2(15+pulse*3,-39),Color("b7935d"),3)
			_unit_shape([Vector2(15+pulse*3,-48),Vector2(21+pulse*3,-41),Vector2(15+pulse*3,-34),Vector2(10+pulse*3,-41)],Color("84d9e8"))
			draw_line(Vector2(15+pulse*3,-46),Vector2(15+pulse*3,-38),Color("e4ffff"),1.5,true)
		3: # Troll : grand et voûté, peau turquoise, crête et hache à large lame.
			_unit_stroke(Vector2(-4,-7),Vector2(-7,1),Color("755743"),4)
			_unit_stroke(Vector2(5,-7),Vector2(8,1),Color("755743"),4)
			_unit_shape([Vector2(-7,-28),Vector2(6,-29),Vector2(8,-8),Vector2(-8,-8)],Color("458d96"))
			_unit_shape([Vector2(-8,-12),Vector2(8,-12),Vector2(10,-5),Vector2(-9,-5)],Color("a46d46"))
			_unit_shape([Vector2(-5,-35),Vector2(-15,-39),Vector2(-6,-28)],Color("60b2ae"))
			_unit_shape([Vector2(6,-35),Vector2(13,-40),Vector2(7,-29)],Color("60b2ae"))
			_unit_face(Color("60b2ae"),7,-33,true)
			_unit_shape([Vector2(-4,-39),Vector2(-3,-46),Vector2(1,-43),Vector2(4,-48),Vector2(6,-38)],Color("c47559"))
			_unit_stroke(Vector2(-7,-25),Vector2(-12,-15),Color("60b2ae"),4)
			_unit_stroke(Vector2(6,-25),Vector2(13,-23+pulse*3),Color("60b2ae"),4)
			_unit_stroke(Vector2(12,-5),Vector2(12+pulse*4,-39),Color("ad8c5d"),3)
			_unit_shape([Vector2(12+pulse*4,-40),Vector2(24+pulse*4,-36),Vector2(26+pulse*4,-29),Vector2(13+pulse*4,-26)],Color("b4d1c4"))
			_unit_stroke(Vector2(18+pulse*4,-36),Vector2(23+pulse*4,-31),Color("e6f1dc"),1)
		4: # Gobelin : petit, oreilles larges, lunettes, sac et bombe.
			_unit_stroke(Vector2(-5,-4),Vector2(-6,1),Color("64513e"),4)
			_unit_stroke(Vector2(5,-4),Vector2(6,1),Color("64513e"),4)
			_unit_disk(Vector2(-9,-14),8,Color("926d44"))
			_unit_shape([Vector2(-7,-22),Vector2(7,-22),Vector2(8,-5),Vector2(-8,-5)],Color("bc7942"))
			_unit_shape([Vector2(-5,-30),Vector2(-17,-34),Vector2(-11,-24),Vector2(-4,-24)],Color("a4c762"))
			_unit_shape([Vector2(5,-30),Vector2(17,-34),Vector2(11,-24),Vector2(4,-24)],Color("a4c762"))
			_unit_face(Color("a4c762"),8,-28)
			_unit_stroke(Vector2(-7,-33),Vector2(7,-33),Color("6d5137"),3)
			for side in [-1,1]: _unit_disk(Vector2(side*4,-32),4,Color("a6d6ce"))
			_unit_stroke(Vector2(-5,-23),Vector2(6,-8),Color("604a36"),3)
			_unit_stroke(Vector2(7,-18),Vector2(13+pulse*3,-13),Color("a4c762"),3)
			_unit_disk(Vector2(15+pulse*3,-12),8,Color("455253"))
			draw_arc(Vector2(15+pulse*3,-12),5,3.6,4.6,8,Color("96a39a"),1.5,true)
			_unit_stroke(Vector2(15+pulse*3,-20),Vector2(18+pulse*3,-25),Color("d8b16b"),2)
			draw_circle(Vector2(18+pulse*3,-25),2.2,Color("f5cf73"),true,-1,true)
		5: # Orc : épaules massives, défenses, fourrure et totem de chaman.
			_unit_stroke(Vector2(-6,-5),Vector2(-7,1),Color("6e4b3e"),5)
			_unit_stroke(Vector2(6,-5),Vector2(7,1),Color("6e4b3e"),5)
			_unit_shape([Vector2(-10,-25),Vector2(10,-25),Vector2(12,-2),Vector2(-11,-2)],Color("7f577f"))
			_unit_shape([Vector2(-13,-27),Vector2(-8,-31),Vector2(0,-25),Vector2(8,-31),Vector2(13,-27),Vector2(12,-19),Vector2(6,-21),Vector2(0,-18),Vector2(-6,-21),Vector2(-12,-19)],Color("b8b8a5"))
			_unit_face(Color("789c62"),9,-34,true)
			_unit_shape([Vector2(-8,-37),Vector2(-6,-43),Vector2(4,-44),Vector2(9,-37),Vector2(2,-39)],Color("3e4740"))
			_unit_stroke(Vector2(-9,-20),Vector2(-13,-11),Color("789c62"),5)
			_unit_stroke(Vector2(9,-21),Vector2(17,-19),Color("789c62"),4)
			_unit_stroke(Vector2(17,0),Vector2(17+pulse*3,-39),Color("a18258"),3)
			_unit_shape([Vector2(10+pulse*3,-44),Vector2(24+pulse*3,-44),Vector2(22+pulse*3,-34),Vector2(12+pulse*3,-34)],Color("d7c9a6"))
			for x in [14,20]: draw_circle(Vector2(x+pulse*3,-40),1.7,UNIT_INK,true,-1,true)
			_unit_shape([Vector2(10+pulse*3,-44),Vector2(7+pulse*3,-50),Vector2(15+pulse*3,-45)],Color("d7c9a6"),0.8)
			_unit_shape([Vector2(24+pulse*3,-44),Vector2(27+pulse*3,-50),Vector2(19+pulse*3,-45)],Color("d7c9a6"),0.8)
			draw_circle(Vector2(17+pulse*3,-35),2,Color("c194df"),true,-1,true)
	if level == 4:
		# Emblème de spécialisation, sans suggérer une nouvelle mécanique.
		_unit_shape([Vector2(-2,-14),Vector2(1,-17),Vector2(4,-14),Vector2(1,-11)],trim,0.8)
	draw_set_transform(Vector2.ZERO)
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

func _draw_pillager(center: Vector2, enemy: Dictionary) -> void:
	var type: int = enemy.get("type", 1)
	var armor: Color = enemy_color(type)
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
	draw_circle(center + Vector2(0, 3), 8, Color(0, 0, 0, 0.3))
	var stride: float = sin(model.elapsed*10.0*enemy.get("speed",1.0)+enemy.id)*2.0 if model.active else 0.0
	draw_line(center + Vector2(-3, -2), center + Vector2(-5+stride, 5), Color("b5a68a"), 3)
	draw_line(center + Vector2(3, -2), center + Vector2(5-stride, 5), Color("b5a68a"), 3)
	if type == 7:
		draw_colored_polygon(PackedVector2Array([Vector2(-8,-20),Vector2(8,-20),Vector2(13,3),Vector2(-13,3)]),Color("713b42"))
	var half_width: float = 9.0 if type in [3,5] else 6.0
	draw_rect(Rect2(center + Vector2(-half_width, -15), Vector2(half_width*2, 16)), armor)
	draw_circle(center + Vector2(0, -20), 6, Color("dbc3a1"))
	draw_line(center + Vector2(-6, -23), center + Vector2(6, -23), Color("77695a"), 3)
	match type:
		0: # Petit couteau, silhouette légère.
			draw_line(Vector2(8,-5),Vector2(11,-14),Color("c6c6a4"),2)
		1: # Épée droite du pillard.
			draw_line(Vector2(10,-21),Vector2(10,0),Color("dac494"),2)
			draw_line(Vector2(7,-7),Vector2(13,-7),Color("746043"),2)
		2: # Foulard et lame courte du sprinter.
			draw_colored_polygon(PackedVector2Array([Vector2(-5,-18),Vector2(-14,-14),Vector2(-13,-20)]),Color("af5351"))
			draw_line(Vector2(8,-7),Vector2(13,-16),Color("e1d0a4"),2)
		3: # Massue de la brute.
			draw_line(Vector2(10,-1),Vector2(10,-25),Color("a1865d"),3)
			draw_circle(Vector2(10,-25),4,Color("6d5544"))
		4: # Deux haches courtes du maraudeur.
			for side in [-1,1]:
				draw_line(Vector2(side*10,-3),Vector2(side*10,-23),Color("b69b70"),2)
				draw_colored_polygon(PackedVector2Array([Vector2(side*9,-23),Vector2(side*15,-18),Vector2(side*9,-14)]),Color("c1b49a"))
		5: # Large ceinture et marteau du colosse.
			draw_line(Vector2(-9,-4),Vector2(9,-4),Color("4d5c59"),4)
			draw_line(Vector2(10,0),Vector2(10,-25),Color("aa9470"),3)
			draw_rect(Rect2(Vector2(5,-30),Vector2(10,8)),Color("b2bbb0"))
		6: # Bouclier pointu et crête de l'élite.
			draw_colored_polygon(PackedVector2Array([Vector2(-14,-17),Vector2(-5,-17),Vector2(-5,-8),Vector2(-10,-3),Vector2(-14,-8)]),Color("645d81"))
			draw_line(Vector2(-10,-15),Vector2(-10,-7),Color("d5c495"),2)
			draw_line(Vector2(0,-26),Vector2(0,-32),Color("c0a8cc"),4)
			draw_line(Vector2(10,-24),Vector2(10,-2),Color("d4c8a1"),2)
		7: # Cape et couronne du chef de siège.
			draw_colored_polygon(PackedVector2Array([Vector2(-7,-24),Vector2(-7,-31),Vector2(-3,-27),Vector2(0,-33),Vector2(3,-27),Vector2(7,-31),Vector2(7,-24)]),Color("e4c980"))
			draw_line(Vector2(11,-28),Vector2(11,0),Color("e4c980"),3)
			draw_line(Vector2(7,-8),Vector2(14,-8),Color("c1a565"),2)
	draw_set_transform(Vector2.ZERO)
