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
	# Catapulte gobeline (type 19) : trois vues selon la hauteur de la cible au sol, départ de la pierre tiré de lacher.json, lâcher à 0,50 s, courbe quadratique.
	check(is_equal_approx(View.launch_delay({"type":19}),0.5),"Lâcher de la catapulte à 0,50 s")
	var views: Dictionary = {}
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var stone: Dictionary = {"type":19,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var view: String = View.catapult_view(stone.from,stone.to)
			views[view] = true
			check(view in ["","_up","_down"],"Catapulte : vue valide")
			var gap: Vector2 = View.project(stone.to)-View.project(from)
			var limit: float = maxf(5.0,0.16*absf(gap.x))
			check((view == "_up") == (gap.y < -limit) and (view == "_down") == (gap.y > limit),"Catapulte : vue selon l'écart vertical à l'écran")
			var center: Vector2 = View.CATAPULT_CENTERS[view]
			check(View.shot_origin(stone).distance_to(View.project(from)+Vector2(center.x*View.shot_facing(stone),center.y)) < 0.001,"Catapulte : pierre partie du centre de la planche %s" % view)
			var start: Dictionary = View.catapult_curve(stone,0.0)
			var arrival: Dictionary = View.catapult_curve(stone,1.0)
			check(start.point.distance_to(View.shot_origin(stone)) < 0.001 and arrival.point.distance_to(View.project(stone.to)+Vector2(0,-12)) < 0.001,"Catapulte : la courbe va du centre à l'impact")
			if View.catapult_stone_flies(stone):
				var slope: float = -float(start.direction.y)/maxf(absf(start.direction.x),0.0001)
				check(absf(slope-float(View.CATAPULT_SLOPES[view])) < 0.01,"Catapulte : tangente initiale à la pente de la planche %s" % view)
			else:
				check((View.project(stone.to).x-View.shot_origin(stone).x)*View.shot_facing(stone) <= 0.0,"Catapulte : cible derrière la cuillère, pierre omise")
	check(views.size() == 3,"Catapulte : les trois vues sont atteintes")
	var cspec: Dictionary = Library.spec_for("defender.horde.catapult")
	check(not cspec.is_empty() and cspec.animations.has("attack_up") and cspec.animations.has("attack_down") and cspec.animations.has("idle_up") and cspec.animations.has("idle_down"),"Catapulte : six planches chargées et valides")
	check(Library.defender_state(cspec,{"idle_variant":"idle_up"}) == "idle_up" and Library.defender_state(cspec,{"attack_age":0.2,"attack_variant":"attack_down","idle_variant":"idle_down"}) == "attack_down" and Library.defender_state(cspec,{"idle_variant":"idle_inconnu"}) == "idle","Catapulte : état de garde et d'attaque avec repli")
	# Lance-épieu orc (type 20) : sept planches, choisie par la pointe la plus proche de l'impact projeté ; un éclat de contact à 0,28 s.
	check(is_equal_approx(View.launch_delay({"type":20}),0.28),"Contact du lance-épieu à 0,28 s")
	var spear_seen: Dictionary = {}
	for dx in [-9.0,-6.0,-3.0,-1.0,1.0,3.0,6.0,9.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var spear: Dictionary = {"type":20,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var variant: String = View.spear_variant(spear)
			spear_seen[variant] = true
			var impact_point: Vector2 = View.project(spear.to)+Vector2(0,-12)
			var nearest: float = INF
			for candidate in View.SPEAR_POINTS: nearest = minf(nearest,View.spear_tip(spear,candidate).distance_to(impact_point))
			check(is_equal_approx(View.spear_tip(spear,variant).distance_to(impact_point),nearest),"Lance-épieu : pointe la plus proche de l'impact (%s)" % variant)
			check(View.shot_origin(spear).distance_to(View.spear_tip(spear,variant)) < 0.001,"Lance-épieu : éclat à la pointe de la planche")
	check(spear_seen.size() >= 3,"Lance-épieu : plusieurs planches atteintes (%d)" % spear_seen.size())
	var lspec: Dictionary = Library.spec_for("defender.horde.spearman")
	check(not lspec.is_empty() and lspec.animations.has("attack_close") and lspec.animations.has("attack_far") and lspec.animations.has("attack_close_up") and lspec.animations.has("attack_close_down"),"Lance-épieu : sept planches chargées et valides")
	# Brûleur de cendres (type 21) : trois planches, braise partie de la grille de la planche à 0,336 s, sans trait de malédiction.
	check(is_equal_approx(View.launch_delay({"type":21}),0.336),"Braise du brûleur à 0,336 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var ember: Dictionary = {"type":21,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var ep: int = View.aim_pitch(ember)
			var grate: Vector2 = View.EMBER_GRATE[ep]
			check(ep in [-12,0,12] and View.shot_origin(ember).distance_to(View.project(from)+Vector2(grate.x*View.shot_facing(ember),grate.y)) < 0.001,"Brûleur : braise partie de la grille de la planche %d" % ep)
	var espec: Dictionary = Library.spec_for("defender.horde.cinderburner")
	check(not espec.is_empty() and espec.animations.has("attack_up12") and espec.animations.has("attack_down12"),"Brûleur : trois planches chargées et valides")
	# Mage de la foudre (type 22) : trois planches, éclair parti de la main de la planche à 0,32 s.
	check(is_equal_approx(View.launch_delay({"type":22}),0.32),"Éclair du mage de la foudre à 0,32 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var bolt: Dictionary = {"type":22,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var lp: int = View.aim_pitch(bolt)
			var hand: Vector2 = View.LIGHTNING_HANDS[lp]
			check(lp in [-12,0,12] and View.shot_origin(bolt).distance_to(View.project(from)+Vector2(hand.x*View.shot_facing(bolt),hand.y)) < 0.001,"Mage de la foudre : éclair parti de la main de la planche %d" % lp)
	var gspec: Dictionary = Library.spec_for("defender.alliance.lightning")
	check(not gspec.is_empty() and gspec.animations.has("attack_up12") and gspec.animations.has("attack_down12"),"Mage de la foudre : trois planches chargées et valides")
	# Archer double (type 23) : cinq planches choisies par l'écart minimal, flèche à 0,60 s depuis la pointe encochée, trajet rectiligne.
	check(is_equal_approx(View.launch_delay({"type":23}),0.6),"Flèche de l'archer double à 0,60 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var twin: Dictionary = {"type":23,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var tp: int = View.aim_pitch(twin)
			var ttip: Vector2 = View.DOUBLE_ARCHER_TIPS[tp]
			check(tp in [-36,-12,0,12,36] and View.shot_origin(twin).distance_to(View.project(from)+Vector2(ttip.x*View.shot_facing(twin),ttip.y)) < 0.001,"Archer double : départ depuis la pointe de la planche %d" % tp)
			check(not (23 in View.CURVED_TYPES),"Archer double : trajet rectiligne")
	var dspec: Dictionary = Library.spec_for("defender.alliance.doublearcher")
	check(not dspec.is_empty() and dspec.animations.has("attack_up36") and dspec.animations.has("attack_down36"),"Archer double : cinq planches chargées et valides")
	# Arbalète lourde (type 24) : six planches choisies par l'écart minimal, carreau à 0,44 s depuis la pointe, trajet rectiligne.
	check(is_equal_approx(View.launch_delay({"type":24}),0.44),"Carreau de l'arbalète lourde à 0,44 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var heavy: Dictionary = {"type":24,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var hp: int = View.aim_pitch(heavy)
			var htip: Vector2 = View.HEAVY_CROSSBOW_TIPS[hp]
			check(hp in [-24,-12,0,12,24,36] and View.shot_origin(heavy).distance_to(View.project(from)+Vector2(htip.x*View.shot_facing(heavy),htip.y)) < 0.001,"Arbalète lourde : départ depuis la pointe de la planche %d" % hp)
	var hspec: Dictionary = Library.spec_for("defender.alliance.heavycrossbow")
	check(not hspec.is_empty() and hspec.animations.has("attack_up24") and hspec.animations.has("attack_down36"),"Arbalète lourde : six planches chargées et valides")
	# Fronde elfe (type 25) : cinq planches choisies par l'écart minimal, galet à 0,40 s depuis le repère de la planche, trajet rectiligne.
	check(is_equal_approx(View.launch_delay({"type":25}),0.4),"Galet de la fronde à 0,40 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var sling: Dictionary = {"type":25,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var gp: int = View.aim_pitch(sling)
			var gtip: Vector2 = View.SLING_TIPS[gp]
			check(gp in [-12,0,12,24,36] and View.shot_origin(sling).distance_to(View.project(from)+Vector2(gtip.x*View.shot_facing(sling),gtip.y)) < 0.001,"Fronde : départ du repère de la planche %d" % gp)
	var gspec2: Dictionary = Library.spec_for("defender.alliance.sling")
	check(not gspec2.is_empty() and gspec2.animations.has("attack_up12") and gspec2.animations.has("attack_down36"),"Fronde : cinq planches chargées et valides")
	# Hache en chaîne (type 26) : cinq planches choisies par l'écart minimal, hache lâchée à 0,52 s depuis le repère de la planche, ricochets de 0,068 s.
	check(is_equal_approx(View.launch_delay({"type":26}),0.52) and is_equal_approx(View.CHAIN_AXE_BOUNCE,0.068),"Hache en chaîne : lâcher à 0,52 s, ricochets de 0,068 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var chain: Dictionary = {"type":26,"from":from,"to":from+Vector2(dx,dy),"slot":0,"secondary":[from+Vector2(dx+1.0,dy),from+Vector2(dx+2.0,dy+1.0)]}
			var cp: int = View.aim_pitch(chain)
			var ctip: Vector2 = View.CHAIN_AXE_TIPS[cp]
			check(cp in [-12,0,12,24,36] and View.shot_origin(chain).distance_to(View.project(from)+Vector2(ctip.x*View.shot_facing(chain),ctip.y)) < 0.001,"Hache en chaîne : départ du repère de la planche %d" % cp)
			check(View.secondary_segments(chain).size() == 2 and View.secondary_segments(chain)[1][0].is_equal_approx(View.project(chain.secondary[0])),"Hache en chaîne : ricochets dans l'ordre de shot.secondary")
	var xspec: Dictionary = Library.spec_for("defender.horde.chainaxe")
	check(not xspec.is_empty() and xspec.animations.has("attack_up12") and xspec.animations.has("attack_down36"),"Hache en chaîne : cinq planches chargées et valides")
	# Lanceur double troll (type 27) : bras alternés, planche du bras actif choisie par l'écart minimal, hache à 0,48 s depuis le centre de la planche.
	check(is_equal_approx(View.launch_delay({"type":27}),0.48),"Hache du lanceur double à 0,48 s")
	for arm in [0,1]:
		for dx in [-8.0,-3.0,3.0,8.0]:
			for dy in [-6.0,-2.0,0.0,2.0,6.0]:
				var twin_axe: Dictionary = {"type":27,"from":from,"to":from+Vector2(dx,dy),"slot":0,"arm":arm}
				var variant27: String = View.double_variant(twin_axe)
				var pose27: Dictionary = View.DOUBLE_THROWER_POSES[variant27]
				check(int(pose27.arm) == arm and (arm == 1) == variant27.begins_with("attack_close"),"Lanceur double : planche du bras %d (%s)" % [arm,variant27])
				check(View.shot_origin(twin_axe).distance_to(View.project(from)+Vector2(pose27.center.x*View.shot_facing(twin_axe),pose27.center.y)) < 0.001,"Lanceur double : hache partie du centre de la planche %s" % variant27)
	var tspec: Dictionary = Library.spec_for("defender.horde.doublethrower")
	check(not tspec.is_empty() and tspec.animations.has("attack_close_up") and tspec.animations.has("attack_down"),"Lanceur double : six planches chargées et valides")
	# Alternance suivie côté rendu : un seul état par défenseur, poursuivi entre les vagues, jamais écrit dans le modèle.
	var tracker := View.new()
	var tracked = View.Model.new(true,View.Model.Maps.for_id("valley_ford"))
	tracked.configure_auxiliary(27);tracked.select_faction(1)
	check(tracked.buy(3,27),"Lanceur double : recruté")
	tracker.model = tracked
	var arms: Array = []
	var seen_keys: Dictionary = {}
	var continued: bool = true
	var inside: bool = true
	for wave in range(1,3):
		tracked.start();seen_keys.clear()
		var wave_arms: Array = []
		var start_count: int = int(tracker._arm_counts.get(int(tracked.defenders[3].instance_id),0))
		for step in range(900):
			tracked.advance(0.5)
			tracker._track_double_arms()
			for shot in tracked.shots:
				if int(shot.type) != 27: continue
				var key: String = "%d:%.5f" % [int(shot.slot),float(shot.time)]
				check(not shot.has("arm"),"Lanceur double : le modèle n'est pas modifié")
				if not seen_keys.has(key):
					seen_keys[key] = true
					wave_arms.append(tracker.with_arm(shot).arm)
			if tracked.phase != "combat": break
		for index in range(1,wave_arms.size()): inside = inside and wave_arms[index] == 1-wave_arms[index-1]
		continued = continued and int(tracker._arm_counts.get(int(tracked.defenders[3].instance_id),0)) > start_count
		arms.append_array(wave_arms)
		tracked.advance(10000)
		if tracked.phase == "bonus": tracked.choose_bonus(tracked.bonus_offer[0])
		if wave < 2: tracked.prepare_next_wave()
	check(arms.size() >= 4 and inside and continued,"Lanceur double : alternance basse, haute, basse… à chaque tir, compteur conservé entre les vagues")
	check(arms.size() >= 2 and arms[0] == 0,"Lanceur double : commence par la hache basse")
	tracker.free()
	# Veilleur des cendres (type 16) : trois planches choisies par l'écart minimal, hachette à 0,36 s depuis le point de la planche.
	check(is_equal_approx(View.launch_delay({"type":16}),0.36),"Hachette du veilleur à 0,36 s")
	for dx in [-8.0,-3.0,3.0,8.0]:
		for dy in [-6.0,-2.0,0.0,2.0,6.0]:
			var hatchet: Dictionary = {"type":16,"from":from,"to":from+Vector2(dx,dy),"slot":0}
			var wp: int = View.aim_pitch(hatchet)
			var wtip: Vector2 = View.WATCHER_TIPS[wp]
			check(wp in [-12,0,12] and View.shot_origin(hatchet).distance_to(View.project(from)+Vector2(wtip.x*View.shot_facing(hatchet),wtip.y)) < 0.001,"Veilleur : départ du point de la planche %d" % wp)
	var wspec: Dictionary = Library.spec_for("defender.horde.watcher")
	check(not wspec.is_empty() and wspec.animations.has("attack_up12") and wspec.animations.has("attack_down12"),"Veilleur : trois planches chargées et valides")
	print("MARKSMAN_AIM_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
