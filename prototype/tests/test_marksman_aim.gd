extends SceneTree
## Visée inclinée du Tireur d'élite elfe (type 11, décision du porteur, 15 novembre 2026) : un seul angle choisi d'après la cible à l'écran sert à la planche,
## à l'origine de la flèche et à sa direction de départ ; le lâcher reste à 0,27 s.
const View = preload("res://scripts/valley_view.gd")
const Library = preload("res://scripts/animation_library.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func shot_to(from: Vector2, to: Vector2) -> Dictionary:
	return {"type":11,"from":from,"to":to,"slot":0}

func run_checks() -> void:
	check(is_equal_approx(View.launch_delay({"type":11}),0.27),"Le lâcher de la flèche reste à 0,27 s")
	var from := Vector2(6,6)
	# Cibles à gauche et à droite, plus haut et plus bas à l'écran : angle borné à ±24°, par pas de 8°.
	var seen: Dictionary = {}
	for dx in [-8.0,-3.0,0.0,3.0,8.0]:
		for dy in [-8.0,-3.0,-1.0,0.0,1.0,3.0,8.0]:
			var shot := shot_to(from,from+Vector2(dx,dy))
			var pitch: int = View.aim_pitch(shot)
			seen[pitch] = true
			check(pitch % 8 == 0 and absi(pitch) <= 24,"Angle %d : multiple de 8°, borné à ±24°" % pitch)
			var origin: Vector2 = View.shot_origin(shot)
			var pivot: Vector2 = View.project(from)+View.AIM_PIVOT
			var direction: Vector2 = View.aim_direction(shot)
			check(origin.distance_to(pivot+direction*View.AIM_LENGTH) < 0.001 and is_equal_approx(direction.length(),1.0),"L'origine tourne autour du pivot selon l'angle de la pose")
			var start: Dictionary = View.aimed_curve(shot,0.0)
			check(start.point.distance_to(origin) < 0.001 and start.direction.distance_to(direction) < 0.001,"La flèche part dans la direction de la pose")
			var end: Dictionary = View.aimed_curve(shot,1.0)
			check(end.point.distance_to(View.project(shot.to)+Vector2(0,-12)) < 0.001,"La trajectoire rejoint le point d'impact")
			check(View.projectile_position(shot,0.0).distance_to(origin) < 0.001,"Le projectile quitte l'origine inclinée")
			check(sign(direction.x) == View.shot_facing(shot) or absf(direction.x) < 0.0001,"La visée regarde du côté du tir")
	check(seen.size() >= 5,"Plusieurs inclinaisons sont réellement choisies selon la cible (%d)" % seen.size())
	check(View.aim_variant(0) == "attack" and View.aim_variant(-16) == "attack_up16" and View.aim_variant(24) == "attack_down24","Noms des planches inclinées (négatif : vers le haut)")
	# Bibliothèque : les sept planches sont chargées et la variante suit la pose.
	var spec: Dictionary = Library.spec_for("defender.alliance.marksman")
	check(not spec.is_empty(),"Planches du Tireur d'élite chargées et valides")
	for pitch in [-24,-16,-8,0,8,16,24]:
		var name: String = View.aim_variant(pitch)
		check(spec.animations.has(name),"Planche %s présente" % name)
		check(Library.defender_state(spec,{"attack_age":0.1,"pulse":1.0,"attack_variant":name}) == name,"%s jouée pendant le geste" % name)
		check(Library.defender_state(spec,{"attack_age":0.7,"pulse":0.0,"attack_variant":name}) == "idle","%s : retour à la garde après 0,66 s" % name)
	check(Library.defender_state(spec,{"attack_age":0.1,"pulse":1.0}) == "attack","Sans variante : tir droit")
	# Javelinier troll (type 17) : trois inclinaisons, origine de la pointe tirée de lachers.json, lâcher à 0,288 s ; Bombardier nain (type 13) : départ à 26°, lâcher à 0,16 s.
	check(is_equal_approx(View.launch_delay({"type":17}),0.288) and is_equal_approx(View.launch_delay({"type":13}),0.16),"Lâchers différés du javelinier et du bombardier")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var jav: Dictionary = {"type":17,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var jp: int = View.aim_pitch(jav)
			var tip: Vector2 = View.JAVELIN_TIPS[jp]
			check(jp in [-12,0,12] and View.shot_origin(jav).distance_to(View.project(from)+Vector2(tip.x*View.shot_facing(jav),tip.y)) < 0.001,"Javelinier : origine de la pointe selon l'angle %d" % jp)
			check(View.aimed_curve(jav,0.0).direction.distance_to(View.aim_direction(jav)) < 0.001,"Javelinier : la javeline part dans l'axe de la pose")
			var cannon: Dictionary = {"type":13,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var start: Vector2 = View.aimed_curve(cannon,0.0).direction
			check(absf(rad_to_deg(asin(-start.y))-View.CANNON_ANGLE) < 0.01 and sign(start.x) == View.shot_facing(cannon),"Bombardier : le boulet part à 26° vers le haut, du côté du tir")
			check(View.aimed_curve(cannon,1.0).point.distance_to(View.project(cannon.to)+Vector2(0,-12)) < 0.001,"Bombardier : la cloche rejoint l'impact")
	for name in ["defender.horde.javelin","defender.alliance.bombard"]:
		check(not Library.spec_for(name).is_empty(),"%s : planches chargées et valides" % name)
	var jspec: Dictionary = Library.spec_for("defender.horde.javelin")
	check(Library.defender_state(jspec,{"attack_age":0.1,"pulse":1.0,"attack_variant":"attack_up12"}) == "attack_up12" and Library.defender_state(jspec,{"attack_age":0.1,"pulse":1.0,"attack_variant":"attack_down12"}) == "attack_down12","Javelinier : variantes inclinées jouées")
	# Piquier humain (type 14) : trois inclinaisons, pointe tirée de contact.json, éclat de contact à 0,256 s ; la pique est dans les planches.
	check(is_equal_approx(View.launch_delay({"type":14}),0.256),"Contact du piquier à 0,256 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var pike: Dictionary = {"type":14,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var pp: int = View.aim_pitch(pike)
			var ptip: Vector2 = View.PIKE_TIPS[pp]
			check(pp in [-12,0,12] and View.shot_origin(pike).distance_to(View.project(from)+Vector2(ptip.x*View.shot_facing(pike),ptip.y)) < 0.001,"Piquier : pointe selon l'angle %d" % pp)
			check(View.aim_variant(pp) in ["attack","attack_up12","attack_down12"],"Piquier : planche choisie par l'angle")
	var pspec: Dictionary = Library.spec_for("defender.alliance.pikeman")
	check(not pspec.is_empty() and pspec.animations.has("attack_up12") and pspec.animations.has("attack_down12"),"Piquier : planches chargées et valides")
	# Pyromancien humain (type 15) : trois inclinaisons, départ de la boule de feu tiré de lachers.json, lâcher à 0,288 s.
	check(is_equal_approx(View.launch_delay({"type":15}),0.288),"Lâcher du pyromancien à 0,288 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var fire: Dictionary = {"type":15,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var fp: int = View.aim_pitch(fire)
			var ftip: Vector2 = View.PYRO_TIPS[fp]
			check(fp in [-12,0,12] and View.shot_origin(fire).distance_to(View.project(from)+Vector2(ftip.x*View.shot_facing(fire),ftip.y)) < 0.001,"Pyromancien : départ selon l'angle %d" % fp)
	var fspec: Dictionary = Library.spec_for("defender.alliance.pyromancer")
	check(not fspec.is_empty() and fspec.animations.has("attack_up12") and fspec.animations.has("attack_down12"),"Pyromancien : planches chargées et valides")
	# Lance-éclats gobelin (type 18) : cinq planches, choisie pour minimiser l'écart entre son angle et la droite pointe -> impact ; lâcher à 0,1125 s.
	check(is_equal_approx(View.launch_delay({"type":18}),0.1125),"Lâcher du lance-éclats à 0,1125 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var shard: Dictionary = {"type":18,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var sp: int = View.aim_pitch(shard)
			check(sp in [-36,-12,0,12,36],"Lance-éclats : angle de planche valide (%d)" % sp)
			var stip: Vector2 = View.SHARD_TIPS[sp]
			check(View.shot_origin(shard).distance_to(View.project(from)+Vector2(stip.x*View.shot_facing(shard),stip.y)) < 0.001,"Lance-éclats : départ depuis la pointe de la planche %d" % sp)
			# La planche choisie est celle qui s'écarte le moins de la droite pointe -> impact.
			var impact: Vector2 = View.project(shard.to)+Vector2(0,-12)
			var errors: Dictionary = {}
			for candidate in View.SHARD_TIPS:
				var origin: Vector2 = View.project(from)+Vector2(View.SHARD_TIPS[candidate].x*View.shot_facing(shard),View.SHARD_TIPS[candidate].y)
				var line: Vector2 = impact-origin
				errors[candidate] = absf(rad_to_deg(atan2(line.y,maxf(absf(line.x),0.0001)))-float(candidate))
			var least: float = INF
			for candidate in errors: least = minf(least,errors[candidate])
			check(is_equal_approx(errors[sp],least),"Lance-éclats : écart minimal pour la planche choisie")
	var sspec: Dictionary = Library.spec_for("defender.horde.shardthrower")
	check(not sspec.is_empty() and sspec.animations.has("attack_up36") and sspec.animations.has("attack_down36"),"Lance-éclats : cinq planches chargées et valides")
	# Sentinelle elfe (type 10) : trois planches, choisie par l'écart minimal entre son angle et la droite pointe -> impact ; flèche à 0,52 s.
	check(is_equal_approx(View.launch_delay({"type":10}),0.52),"Lâcher de la sentinelle à 0,52 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var sentinel: Dictionary = {"type":10,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var np: int = View.aim_pitch(sentinel)
			var ntip: Vector2 = View.SENTINEL_TIPS[np]
			check(np in [-12,0,12] and View.shot_origin(sentinel).distance_to(View.project(from)+Vector2(ntip.x*View.shot_facing(sentinel),ntip.y)) < 0.001,"Sentinelle : départ depuis la pointe de la planche %d" % np)
	var nspec: Dictionary = Library.spec_for("defender.alliance.sentinel")
	check(not nspec.is_empty() and nspec.animations.has("attack_up12") and nspec.animations.has("attack_down12"),"Sentinelle : planches chargées et valides")
	print("MARKSMAN_AIM_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
