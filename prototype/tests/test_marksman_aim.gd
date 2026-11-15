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
	print("MARKSMAN_AIM_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
