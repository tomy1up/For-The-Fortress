extends SceneTree
## Repères d'effets de la boutique : pastilles d'état des ennemis, événements d'explosion exposés par le moteur, ressources.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Library = preload("res://scripts/animation_library.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_badges()
	verify_observer_signal()
	verify_wisp_and_totem()
	verify_priest_and_elder()
	verify_mercenary_coin()
	verify_trapper_cartridge()
	verify_alchemist_vial()
	verify_veteran_bolt()
	verify_pillager_token()
	verify_minelayer_disc()
	verify_kamikaze_ember()
	verify_warveteran_axe()
	verify_siege_bolts()
	verify_explosion_events()
	verify_resources()
	print("SHOP_EFFECTS_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)

func verify_badges() -> void:
	var enemy: Dictionary = Model.make_enemy(1,1,0.0,-1,100)
	check(View.enemy_badges(enemy,5.0).is_empty(),"Aucune pastille sur un ennemi sans état")
	enemy.marked_until = 8.0;enemy.loot_until = 8.0;enemy.volatile_until = 8.0
	check(View.enemy_badges(enemy,5.0) == ["mark","loot","volatile"],"Ordre des pastilles : marque, pillage, volatilité")
	check(View.enemy_badges(enemy,9.0).is_empty(),"Les pastilles disparaissent à l'expiration des états")
	enemy.exploded = true;enemy.volatile_until = 20.0
	check(not View.enemy_badges(enemy,5.0).has("volatile"),"Pas de pastille de volatilité après l'explosion")

## Éclaireur-observateur (type 31, lot Codex 88784cf, v0.235) : pas de flèche, losange d'une marque nouvelle au geste pointé (0,32 s), marques déjà visibles conservées.
func verify_observer_signal() -> void:
	var observer: int = Shop.card("alliance.observer").type
	check(observer == View.OBSERVER_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[observer]),0.32),"Éclaireur-observateur : losange et dégâts affichés à 0,32 s")
	var spec: Dictionary = Library.spec_for("defender.alliance.observer")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 28 and is_equal_approx(float(spec.animations.attack.duration),0.896) and int(spec.animations.idle.frames) == 1 and str(spec.animations.attack.mode) == "event","Éclaireur-observateur : garde et signal de 28 poses sur 0,896 s chargés")
	check(is_equal_approx(10.0*float(spec.animations.attack.duration)/float(spec.animations.attack.frames),0.32),"Le premier geste pointé (pose 10) commence à 0,32 s")
	var shot := {"time":5.0,"slot":2,"type":observer,"target_id":7,"from":Vector2(2,2),"to":Vector2(4,3),"secondary":[],"radius":0.0,"mark":"new"}
	check(View.flight_time(shot) == 0.0 and observer in View.SIGNAL_TYPES,"Aucun projectile ni vol pour l'Éclaireur-observateur")
	var enemy: Dictionary = Model.make_enemy(1,1,0.0,-1,100);enemy.id = 7;enemy.marked_until = 9.0
	check(View.enemy_badges(enemy,5.1,[shot]).is_empty() and View.enemy_badges(enemy,5.31,[shot]).is_empty(),"Marque nouvelle : pas de losange avant le geste pointé")
	check(View.enemy_badges(enemy,5.32,[shot]) == ["mark"] and View.enemy_badges(enemy,8.9,[shot]) == ["mark"],"Losange affiché du geste pointé à la fin de la marque")
	check(View.enemy_badges(enemy,5.1) == ["mark"],"Sans tir connu, la marque s'affiche comme avant")
	var renewed: Dictionary = shot.duplicate();renewed.mark = "renewed"
	check(View.enemy_badges(enemy,5.1,[renewed]) == ["mark"],"Renouvellement : le losange déjà visible reste affiché")
	var second: Dictionary = shot.duplicate();second.time = 5.1;second.mark = "renewed"
	check(View.enemy_badges(enemy,5.2,[shot,second]).is_empty() and View.enemy_badges(enemy,5.32,[shot,second]) == ["mark"],"Un second Éclaireur pendant le geste n'avance pas le losange")
	var hunter := {"time":5.1,"slot":3,"type":0,"target_id":7,"from":Vector2(3,2),"to":Vector2(4,3),"secondary":[],"radius":0.0,"mark":"renewed"}
	check(View.enemy_badges(enemy,5.05,[shot,hunter]).is_empty() and View.enemy_badges(enemy,5.15,[shot,hunter]) == ["mark"],"Marque du chasseur posée pendant le geste : affichée aussitôt")
	var other_target: Dictionary = shot.duplicate();other_target.target_id = 8
	check(View.enemy_badges(enemy,5.1,[other_target]) == ["mark"],"Le délai ne concerne que la cible de l'Éclaireur")
	# Moteur : le tir note la marque posée (nouvelle ou renouvelée) sans changer le marquage ni son bonus.
	var model := Model.new(true)
	check(model.configure_auxiliary(observer),"Éclaireur-observateur accepté comme renfort")
	model.select_faction(0);model.gold = 2000
	model.buy(3,observer);model.buy(4,0)
	model.bonuses.append(Model.B_HUNTMARK)
	model.start()
	var first_mark: Dictionary = {}
	for step in range(4000):
		model.advance(0.05)
		for fired in model.shots:
			if int(fired.type) == observer and first_mark.is_empty(): first_mark = fired
		if not first_mark.is_empty() or not model.active: break
	check(not first_mark.is_empty() and str(first_mark.get("mark","")) in ["new","renewed"],"Le tir de l'Éclaireur porte l'état de la marque posée")
	var target: Dictionary = {}
	for alive in model.enemies:
		if int(alive.id) == int(first_mark.get("target_id",-1)): target = alive
	check(target.is_empty() or is_equal_approx(float(target.marked_until),float(first_mark.time)+4.0),"La marque est posée par le moteur dès le tir (4 s)")
	check(model.shots.filter(func(fired): return int(fired.type) == 0).all(func(fired): return fired.has("mark")),"Avec Marque du chasseur, chaque flèche note sa marque")

## Chamane des marais (type 33, lot a89ce33) et Totem de guerre (type 34, lot b36a4eb), v0.236 : départs, repères, vols rectilignes et losange du Totem à l'arrivée de l'impulsion.
func verify_wisp_and_totem() -> void:
	var wisp: int = Shop.card("horde.swampshaman").type
	var totem: int = Shop.card("horde.wartotem").type
	check(wisp == View.WISP_TYPE and totem == View.TOTEM_TYPE,"Types de la Chamane des marais et du Totem de guerre")
	check(is_equal_approx(float(View.LAUNCH_DELAYS[wisp]),0.40) and is_equal_approx(float(View.LAUNCH_DELAYS[totem]),0.30),"Feu follet à 0,40 s, impulsion à 0,30 s")
	check(is_equal_approx(float(View.LAUNCH_DELAYS[totem])+View.PROJECTILE_FLIGHT,0.42) and is_equal_approx(float(View.MARK_DISPLAY_DELAYS[totem]),0.42),"L'impulsion arrive à 0,42 s, avec le premier losange du Totem")
	var wisp_spec: Dictionary = Library.spec_for("defender.horde.swampshaman")
	check(not wisp_spec.is_empty() and int(wisp_spec.animations.attack.frames) == 33 and is_equal_approx(float(wisp_spec.animations.attack.duration),0.88),"Rituel de la Chamane : 33 poses sur 0,88 s chargées")
	check(is_equal_approx(15.0*float(wisp_spec.animations.attack.duration)/float(wisp_spec.animations.attack.frames),0.40),"La volute part sur la pose 15 (0,40 s)")
	var totem_spec: Dictionary = Library.spec_for("defender.horde.wartotem")
	check(not totem_spec.is_empty() and int(totem_spec.animations.attack.frames) == 24 and is_equal_approx(float(totem_spec.animations.attack.duration),0.72),"Impulsion du Totem : 24 poses sur 0,72 s chargées")
	for type in [wisp,totem]:
		var right := {"time":1.0,"slot":2,"type":type,"target_id":3,"from":Vector2(5,5),"to":Vector2(8,5),"secondary":[],"radius":0.0}
		var left: Dictionary = right.duplicate();left.to = Vector2(1,5)
		var tip: Vector2 = View.SINGLE_MUZZLES[type]
		check(View.shot_origin(right).is_equal_approx(View.project(right.from)+tip) and View.shot_facing(right) == 1.0,"Départ au repère de Codex vers la droite (type %d)" % type)
		check(View.shot_origin(left).is_equal_approx(View.project(left.from)+Vector2(-tip.x,tip.y)) and View.shot_facing(left) == -1.0,"Repère retourné avec la pose vers la gauche (type %d)" % type)
		var half: Vector2 = View.shot_origin(right).lerp(View.project(right.to)+Vector2(0,-12),0.5)
		check(View.projectile_position(right,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(half),"Vol rectiligne (type %d)" % type)
	var enemy: Dictionary = Model.make_enemy(1,1,0.0,-1,100);enemy.id = 4;enemy.marked_until = 9.0
	var pulse := {"time":5.0,"slot":2,"type":totem,"target_id":4,"from":Vector2(2,2),"to":Vector2(4,3),"secondary":[],"radius":0.0,"mark":"new"}
	check(View.enemy_badges(enemy,5.41,[pulse]).is_empty() and View.enemy_badges(enemy,5.42,[pulse]) == ["mark"],"Totem : premier losange à l'arrivée de l'impulsion")
	var renewed: Dictionary = pulse.duplicate();renewed.mark = "renewed"
	check(View.enemy_badges(enemy,5.05,[renewed]) == ["mark"],"Totem : une marque déjà visible le reste")
	var hunter := {"time":5.2,"slot":3,"type":3,"target_id":4,"from":Vector2(3,2),"to":Vector2(4,3),"secondary":[],"radius":0.0,"mark":"renewed"}
	check(View.enemy_badges(enemy,5.19,[pulse,hunter]).is_empty() and View.enemy_badges(enemy,5.2,[pulse,hunter]) == ["mark"],"Totem : Marque du chasseur posée pendant l'impulsion, affichée aussitôt")
	var observer := {"time":5.05,"slot":4,"type":View.OBSERVER_TYPE,"target_id":4,"from":Vector2(3,3),"to":Vector2(4,3),"secondary":[],"radius":0.0,"mark":"renewed"}
	check(View.enemy_badges(enemy,5.36,[pulse,observer]).is_empty() and View.enemy_badges(enemy,5.37,[pulse,observer]) == ["mark"],"Totem puis Éclaireur : le losange suit la première arrivée visible")

## Prêtre guerrier (type 32, lot c2d19e8) et Ancien des tribus (type 35, lot b1b0f16), v0.236.
func verify_priest_and_elder() -> void:
	var priest: int = Shop.card("alliance.priest").type
	var elder: int = Shop.card("horde.elder").type
	check(priest == View.GOLD_SHARD_TYPE and elder == View.ELDER_TYPE,"Types du Prêtre guerrier et de l'Ancien des tribus")
	check(is_equal_approx(float(View.LAUNCH_DELAYS[priest]),0.32) and is_equal_approx(float(View.LAUNCH_DELAYS[elder]),0.36),"Éclat doré à 0,32 s, onde à 0,36 s")
	var priest_spec: Dictionary = Library.spec_for("defender.alliance.priest")
	check(not priest_spec.is_empty() and priest_spec.animations.has("attack_up") and priest_spec.animations.has("attack_down") and int(priest_spec.animations.attack.frames) == 20 and is_equal_approx(float(priest_spec.animations.attack.duration),0.8),"Prêtre : trois vues de 20 poses sur 0,8 s chargées")
	check(is_equal_approx(8.0*0.8/20.0,0.32),"L'éclat part sur la pose 8 (0,32 s)")
	var elder_spec: Dictionary = Library.spec_for("defender.horde.elder")
	check(not elder_spec.is_empty() and int(elder_spec.animations.attack.frames) == 22 and is_equal_approx(float(elder_spec.animations.attack.duration),0.88),"Ancien : frappe de 22 poses sur 0,88 s chargée")
	check(is_equal_approx(9.0*0.88/22.0,0.36),"L'onde part sur la pose 9 (0,36 s), au contact du tambour")
	var used := {}
	for target in [Vector2(9,1),Vector2(9,5),Vector2(9,9),Vector2(6,0),Vector2(6,10),Vector2(1,5),Vector2(2,1)]:
		var shot := {"time":1.0,"slot":2,"type":priest,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":0.0}
		var pitch: int = View.aim_pitch(shot)
		used[pitch] = true
		var tip: Vector2 = View.PRIEST_TIPS[pitch]
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
		check(View.shot_origin(shot).is_equal_approx(origin) and View.tilted_variant(shot) == str(View.PRIEST_VARIANTS[pitch]),"Prêtre : paume et vue de l'inclinaison retenue")
		var impact: Vector2 = View.project(shot.to)+Vector2(0,-12)
		var best_error := INF
		for candidate in View.PRIEST_TIPS:
			var line: Vector2 = impact-(View.project(shot.from)+Vector2(View.PRIEST_TIPS[candidate].x*View.shot_facing(shot),View.PRIEST_TIPS[candidate].y))
			best_error = minf(best_error,absf(rad_to_deg(atan2(line.y,maxf(absf(line.x),0.0001)))-float(View.PRIEST_PITCHES[candidate])))
		var chosen: Vector2 = impact-origin
		check(is_equal_approx(absf(rad_to_deg(atan2(chosen.y,maxf(absf(chosen.x),0.0001)))-float(View.PRIEST_PITCHES[pitch])),best_error),"Prêtre : vue la plus proche du trajet depuis sa paume")
		if (impact.x-origin.x)*View.shot_facing(shot) > 0.0:
			check(View.flight_time(shot) == View.PROJECTILE_FLIGHT and View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(impact,0.5)),"Prêtre : éclat en ligne droite")
		else: check(View.flight_time(shot) == 0.0,"Prêtre : impact seul si la cible est derrière la paume")
	check(used.size() == 3,"Les trois vues du Prêtre sont employées (%d)" % used.size())
	var drum := {"time":1.0,"slot":2,"type":elder,"target_id":3,"from":Vector2(5,5),"to":Vector2(1,5),"secondary":[],"radius":0.0}
	var drum_tip: Vector2 = View.SINGLE_MUZZLES[elder]
	check(View.shot_origin(drum).is_equal_approx(View.project(drum.from)+Vector2(-drum_tip.x,drum_tip.y)),"Ancien : départ au tambour, retourné avec le sprite")
	check(View.projectile_position(drum,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(View.shot_origin(drum).lerp(View.project(drum.to)+Vector2(0,-12),0.5)),"Ancien : onde en ligne droite")

## Marchand mercenaire (type 36, lot bcf83a3, validé dans fa8d42c), v0.236 : pièce lancée à 0,40 s depuis le repère de Codex, retourné avec la pose, vol rectiligne.
func verify_mercenary_coin() -> void:
	var merchant: int = Shop.card("alliance.mercenary").type
	check(merchant == View.COIN_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[merchant]),0.40),"Marchand mercenaire : pièce lancée à 0,40 s")
	var spec: Dictionary = Library.spec_for("defender.alliance.mercenary")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 22 and is_equal_approx(float(spec.animations.attack.duration),0.88) and is_equal_approx(10.0*0.88/22.0,0.40),"Lancer de pièce de 22 poses sur 0,88 s chargé, départ sur la pose 10")
	var tip: Vector2 = View.SINGLE_MUZZLES[merchant]
	for target in [Vector2(9,5),Vector2(1,5)]:
		var shot := {"time":1.0,"slot":2,"type":merchant,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":0.0}
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
		check(View.shot_origin(shot).is_equal_approx(origin),"Pièce partie du repère, retourné avec la pose")
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(View.project(shot.to)+Vector2(0,-12),0.5)),"Pièce en vol rectiligne")

## Piégeur nain (type 37, lot 4fb5e10, validé dans 19a06a2), v0.236 : cartouche lancée à 0,36 s de la main ouverte, un tour sur un arc de 16 px.
func verify_trapper_cartridge() -> void:
	var trapper: int = Shop.card("alliance.trapper").type
	check(trapper == View.CARTRIDGE_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[trapper]),0.36),"Piégeur nain : cartouche lancée à 0,36 s")
	var spec: Dictionary = Library.spec_for("defender.alliance.trapper")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 22 and is_equal_approx(float(spec.animations.attack.duration),0.88) and is_equal_approx(9.0*0.88/22.0,0.36),"Lancer de 22 poses sur 0,88 s chargé, départ sur la pose 9")
	var tip: Vector2 = View.SINGLE_MUZZLES[trapper]
	for target in [Vector2(9,5),Vector2(1,5)]:
		var shot := {"time":1.0,"slot":2,"type":trapper,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":0.0}
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
		check(View.shot_origin(shot).is_equal_approx(origin),"Cartouche partie de la main ouverte, repère retourné avec la pose")
		var middle: Vector2 = origin.lerp(View.project(shot.to)+Vector2(0,-12),0.5)-Vector2(0,View.CARTRIDGE_ARC)
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(middle) and View.projectile_position(shot,View.PROJECTILE_FLIGHT).is_equal_approx(View.project(shot.to)+Vector2(0,-12)),"Cartouche : arc de 16 px au milieu du vol, arrivée sur la cible")
	check(is_equal_approx(View.CARTRIDGE_WIDTH,12.0),"Cartouche de 12 px de large à l'écran")

## Alchimiste gnome (type 39, lot 02cb36d, validé dans 68f4dea), v0.236 : fiole ambrée lancée à 0,40 s (image 20) de la main ouverte, arc existant de 10 px.
func verify_alchemist_vial() -> void:
	var alchemist: int = Shop.card("alliance.alchemist").type
	check(alchemist == View.VIAL_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[alchemist]),0.40),"Alchimiste gnome : fiole lancée à 0,40 s")
	var spec: Dictionary = Library.spec_for("defender.alliance.alchemist")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 48 and is_equal_approx(float(spec.animations.attack.duration),0.96) and is_equal_approx(20.0*0.96/48.0,0.40),"Lancer de 48 images sur 0,96 s chargé, départ sur l'image 20")
	var tip: Vector2 = View.SINGLE_MUZZLES[alchemist]
	for target in [Vector2(9,5),Vector2(1,5)]:
		var shot := {"time":1.0,"slot":2,"type":alchemist,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":1.0}
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
		check(View.shot_origin(shot).is_equal_approx(origin),"Fiole partie de la main ouverte, repère retourné avec la pose")
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(View.project(shot.to)+Vector2(0,-12),0.5)-Vector2(0,10)),"Fiole : arc existant de 10 px")

## Vétéran royal (type 40, lot 20550ee, validé dans f34127a), v0.237 : carreau à 0,36 s (image 18) depuis la glissière, en ligne droite ; impact seul si la cible est derrière.
func verify_veteran_bolt() -> void:
	var veteran: int = Shop.card("alliance.veteran").type
	check(veteran == 40 and is_equal_approx(float(View.LAUNCH_DELAYS[veteran]),0.36) and veteran in View.NO_FLIGHT_TYPES,"Vétéran royal : carreau à 0,36 s, impact seul derrière la glissière")
	var spec: Dictionary = Library.spec_for("defender.alliance.veteran")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 48 and is_equal_approx(float(spec.animations.attack.duration),0.96) and is_equal_approx(18.0*0.96/48.0,0.36),"Tir et réarmement de 48 images sur 0,96 s chargés, départ sur l'image 18")
	var tip: Vector2 = View.SINGLE_MUZZLES[veteran]
	for target in [Vector2(9,5),Vector2(1,5),Vector2(5,9)]:
		var shot := {"time":1.0,"slot":2,"type":veteran,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":0.0}
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
		var impact: Vector2 = View.project(shot.to)+Vector2(0,-12)
		check(View.shot_origin(shot).is_equal_approx(origin),"Carreau parti de la glissière, repère retourné avec la pose")
		if (impact.x-origin.x)*View.shot_facing(shot) > 0.0:
			check(View.flight_time(shot) == View.PROJECTILE_FLIGHT and View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(impact,0.5)),"Carreau en ligne droite")
		else: check(View.flight_time(shot) == 0.0,"Cible derrière la glissière : impact seul")

## Pillard gobelin (type 41, lot 0ab5281, validé dans 0d5d807), v0.237 : jeton à 0,36 s, un tour sur l'arc de 8 px, badge de pillage à l'impact.
func verify_pillager_token() -> void:
	var pillager: int = Shop.card("horde.pillager").type
	check(pillager == View.PILLAGER_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[pillager]),0.36) and pillager in View.NO_FLIGHT_TYPES,"Pillard gobelin : jeton lancé à 0,36 s, impact seul à bout portant")
	var spec: Dictionary = Library.spec_for("defender.horde.pillager")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 48 and is_equal_approx(float(spec.animations.attack.duration),0.96) and is_equal_approx(18.0*0.96/48.0,0.36),"Lancer de 48 images sur 0,96 s chargé, départ sur l'image 18")
	var tip: Vector2 = View.SINGLE_MUZZLES[pillager]
	var ahead := {"time":5.0,"slot":2,"type":pillager,"target_id":6,"from":Vector2(5,5),"to":Vector2(9,5),"secondary":[],"radius":0.0,"loot":"new"}
	var origin: Vector2 = View.project(ahead.from)+Vector2(tip.x,tip.y)
	check(View.shot_origin(ahead).is_equal_approx(origin) and View.flight_time(ahead) == View.PROJECTILE_FLIGHT,"Jeton parti de la main ouverte, avec vol vers une cible devant")
	check(View.projectile_position(ahead,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(View.project(ahead.to)+Vector2(0,-12),0.5)-Vector2(0,8)),"Jeton : arc existant de 8 px")
	var enemy: Dictionary = Model.make_enemy(1,1,0.0,-1,100);enemy.id = 6;enemy.loot_until = 9.0
	check(View.enemy_badges(enemy,5.47,[ahead]).is_empty() and View.enemy_badges(enemy,5.48,[ahead]) == ["loot"],"Pillage nouveau : badge à l'impact du jeton (0,48 s)")
	var close: Dictionary = ahead.duplicate();close.to = Vector2(5.2,5.2) # cible juste sous le pillard : derrière sa main à l'écran
	check(View.flight_time(close) == 0.0 and View.enemy_badges(enemy,5.35,[close]).is_empty() and View.enemy_badges(enemy,5.36,[close]) == ["loot"],"Sans vol à bout portant : badge à 0,36 s")
	var renewed: Dictionary = ahead.duplicate();renewed.loot = "renewed"
	check(View.enemy_badges(enemy,5.1,[renewed]) == ["loot"],"Renouvellement : le badge déjà visible reste affiché")
	var merchant := {"time":5.2,"slot":3,"type":View.COIN_TYPE,"target_id":6,"from":Vector2(3,2),"to":Vector2(4,3),"secondary":[],"radius":0.0,"loot":"renewed"}
	check(View.enemy_badges(enemy,5.19,[ahead,merchant]).is_empty() and View.enemy_badges(enemy,5.2,[ahead,merchant]) == ["loot"],"Pillage du Marchand pendant le vol du jeton : affiché aussitôt")
	var coin := {"time":5.0,"slot":3,"type":View.COIN_TYPE,"target_id":6,"from":Vector2(3,2),"to":Vector2(4,3),"secondary":[],"radius":0.0,"loot":"new"}
	check(View.enemy_badges(enemy,5.0,[coin]) == ["loot"],"Marchand mercenaire : badge immédiat, comme avant")
	# Moteur : le tir du Pillard note l'état du pillage posé, sans changer le pillage.
	var model := Model.new(true)
	check(model.configure_auxiliary(pillager),"Pillard gobelin accepté comme renfort")
	model.select_faction(1);model.gold = 2000
	model.buy(3,pillager)
	model.start()
	var fired: Dictionary = {}
	for step in range(4000):
		model.advance(0.05)
		for shot in model.shots:
			if int(shot.type) == pillager and fired.is_empty(): fired = shot
		if not fired.is_empty() or not model.active: break
	check(not fired.is_empty() and str(fired.get("loot","")) == "new","Le premier jeton pose un pillage nouveau")
	for alive in model.enemies:
		if int(alive.id) == int(fired.get("target_id",-1)): check(is_equal_approx(float(alive.loot_until),float(fired.time)+4.0),"Le pillage dure toujours 4 s dès le tir")

## Poseur de mines (type 42, lot 9aae568, validé dans bffb9e6), v0.238 : disque à 0,40 s (index 25), un tour sur l'arc de 15 px, impact seul derrière le repère.
func verify_minelayer_disc() -> void:
	var layer: int = Shop.card("horde.minelayer").type
	check(layer == View.RUNE_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[layer]),0.40) and layer in View.NO_FLIGHT_TYPES,"Poseur de mines : disque lancé à 0,40 s, impact seul derrière le repère")
	var spec: Dictionary = Library.spec_for("defender.horde.minelayer")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 60 and is_equal_approx(float(spec.animations.attack.duration),0.96) and is_equal_approx(25.0*0.96/60.0,0.40),"Lancer de 60 images sur 0,96 s chargé, départ sur l'image 25")
	var tip: Vector2 = View.SINGLE_MUZZLES[layer]
	for target in [Vector2(9,5),Vector2(1,5)]:
		var shot := {"time":1.0,"slot":2,"type":layer,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":1.0}
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
		check(View.shot_origin(shot).is_equal_approx(origin) and View.flight_time(shot) == View.PROJECTILE_FLIGHT,"Disque parti de la main ouverte, repère retourné avec la pose")
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(View.project(shot.to)+Vector2(0,-12),0.5)-Vector2(0,15)),"Disque : arc existant de 15 px")
	var close := {"time":1.0,"slot":2,"type":layer,"target_id":3,"from":Vector2(5,5),"to":Vector2(5.2,5.2),"secondary":[],"radius":1.0}
	check(View.flight_time(close) == 0.0,"Cible derrière le repère : impact seul")
	check(is_equal_approx(View.RUNE_WIDTH,14.0),"Disque de 14 px de large à l'écran")

## Gobelin des braises (type 44, lot d9fea47, validé dans 7610ec7), v0.238 : braise à 0,40 s, vol rectiligne pointe vers la cible, badge de volatilité à l'impact.
func verify_kamikaze_ember() -> void:
	var goblin: int = Shop.card("horde.kamikaze").type
	check(goblin == View.KAMIKAZE_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[goblin]),0.40) and goblin in View.NO_FLIGHT_TYPES,"Gobelin des braises : braise lancée à 0,40 s, impact seul derrière le repère")
	var spec: Dictionary = Library.spec_for("defender.horde.kamikaze")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 60 and is_equal_approx(float(spec.animations.attack.duration),0.96) and is_equal_approx(25.0*0.96/60.0,0.40),"Incantation de 60 images sur 0,96 s chargée, départ sur l'image 25")
	var tip: Vector2 = View.SINGLE_MUZZLES[goblin]
	for target in [Vector2(9,5),Vector2(1,5),Vector2(9,1),Vector2(2,9)]:
		var shot := {"time":5.0,"slot":2,"type":goblin,"target_id":7,"from":Vector2(5,5),"to":target,"secondary":[],"radius":1.4,"volatile":"new"}
		var facing: float = View.shot_facing(shot)
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*facing,tip.y)
		var impact: Vector2 = View.project(shot.to)+Vector2(0,-12)
		check(View.shot_origin(shot).is_equal_approx(origin) and View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(impact,0.5)),"Braise : départ au repère retourné, vol rectiligne")
		var drawn: Transform2D = Transform2D(View.ember_shard_rotation((impact-origin).normalized(),facing),Vector2(facing,1.0),0.0,Vector2.ZERO)
		check(is_equal_approx((drawn*View.EMBER_SHARD_AXIS).normalized().dot((impact-origin).normalized()),1.0),"Braise : pointe du dessin dirigée vers la cible")
	var enemy: Dictionary = Model.make_enemy(1,1,0.0,-1,100);enemy.id = 7;enemy.volatile_until = 9.0
	var ahead := {"time":5.0,"slot":2,"type":goblin,"target_id":7,"from":Vector2(5,5),"to":Vector2(9,5),"secondary":[],"radius":1.4,"volatile":"new"}
	check(View.enemy_badges(enemy,5.51,[ahead]).is_empty() and View.enemy_badges(enemy,5.52,[ahead]) == ["volatile"],"Volatilité nouvelle : badge à l'impact de la braise (0,52 s)")
	var close: Dictionary = ahead.duplicate();close.to = Vector2(5.2,5.2)
	check(View.flight_time(close) == 0.0 and View.enemy_badges(enemy,5.39,[close]).is_empty() and View.enemy_badges(enemy,5.40,[close]) == ["volatile"],"Sans vol à bout portant : badge à 0,40 s")
	var renewed: Dictionary = ahead.duplicate();renewed.volatile = "renewed"
	check(View.enemy_badges(enemy,5.1,[renewed]) == ["volatile"],"Renouvellement : le badge déjà visible reste affiché")
	var vial := {"time":5.0,"slot":3,"type":View.VIAL_TYPE,"target_id":7,"from":Vector2(3,2),"to":Vector2(4,3),"secondary":[],"radius":1.4,"volatile":"new"}
	check(View.enemy_badges(enemy,5.0,[vial]) == ["volatile"],"Alchimiste gnome : badge immédiat, comme avant")

## Chef de guerre vétéran (type 45, lot 2199f08, passation 3d7ec18), v0.239 : hache à 0,40 s (index 24 sur 64), vol rectiligne, impact seul derrière la main.
func verify_warveteran_axe() -> void:
	var chief: int = Shop.card("horde.warveteran").type
	check(chief == View.WARVETERAN_TYPE and is_equal_approx(float(View.LAUNCH_DELAYS[chief]),0.40) and chief in View.NO_FLIGHT_TYPES,"Chef de guerre vétéran : hache lâchée à 0,40 s, impact seul derrière la main")
	var spec: Dictionary = Library.spec_for("defender.horde.warveteran")
	check(not spec.is_empty() and int(spec.animations.attack.frames) == 64 and is_equal_approx(24.0*float(spec.animations.attack.duration)/64.0,0.40),"Lancer de 64 images à 60 ips chargé, lâcher sur l'image 24")
	var tip: Vector2 = View.SINGLE_MUZZLES[chief]
	for target in [Vector2(9,5),Vector2(1,5)]:
		var shot := {"time":1.0,"slot":2,"type":chief,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":1.0}
		var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
		check(View.shot_origin(shot).is_equal_approx(origin) and View.flight_time(shot) == View.PROJECTILE_FLIGHT,"Hache partie de la main, repère retourné avec la pose")
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(View.project(shot.to)+Vector2(0,-12),0.5)),"Hache en vol rectiligne")
	var close := {"time":1.0,"slot":2,"type":chief,"target_id":3,"from":Vector2(5,5),"to":Vector2(5.2,5.2),"secondary":[],"radius":1.0}
	check(View.flight_time(close) == 0.0,"Cible derrière la main : impact seul")
	check(is_equal_approx(View.WARVETERAN_AXE_HEIGHT,16.0) and is_equal_approx(View.WARVETERAN_AXE_ANGLE,48.0),"Hache de 16 px de haut, départ à 48°")

## Balliste royale (type 38, lot 6b93bd1) et Baliste de guerre (type 43, lot 8372ff5), v0.239 : carreau de siège à 0,32 s sur le rail vide, vol rectiligne, impact seul derrière la glissière.
func verify_siege_bolts() -> void:
	for spec_case in [["alliance.ballista","defender.alliance.ballista",36,12],["horde.warballista","defender.horde.warballista",60,20]]:
		var kind: int = Shop.card(str(spec_case[0])).type
		check(kind in View.BOLT_TYPES and is_equal_approx(float(View.LAUNCH_DELAYS[kind]),0.32) and kind in View.NO_FLIGHT_TYPES,"%s : carreau lâché à 0,32 s, impact seul derrière la glissière" % spec_case[0])
		var spec: Dictionary = Library.spec_for(str(spec_case[1]))
		check(not spec.is_empty() and int(spec.animations.attack.frames) == int(spec_case[2]) and is_equal_approx(float(spec_case[3])*float(spec.animations.attack.duration)/float(spec_case[2]),0.32),"%s : planche chargée, rail vide à l'image %d" % [spec_case[0],spec_case[3]])
		var tip: Vector2 = View.SINGLE_MUZZLES[kind]
		for target in [Vector2(9,5),Vector2(1,5)]:
			var shot := {"time":1.0,"slot":2,"type":kind,"target_id":3,"from":Vector2(5,5),"to":target,"secondary":[],"radius":1.0}
			var origin: Vector2 = View.project(shot.from)+Vector2(tip.x*View.shot_facing(shot),tip.y)
			check(View.shot_origin(shot).is_equal_approx(origin) and View.flight_time(shot) == View.PROJECTILE_FLIGHT,"%s : carreau parti du rail, repère retourné avec la pose" % spec_case[0])
			check(View.projectile_position(shot,View.PROJECTILE_FLIGHT*0.5).is_equal_approx(origin.lerp(View.project(shot.to)+Vector2(0,-12),0.5)),"%s : vol rectiligne" % spec_case[0])
		var close := {"time":1.0,"slot":2,"type":kind,"target_id":3,"from":Vector2(5,5),"to":Vector2(5.2,5.2),"secondary":[],"radius":1.0}
		check(View.flight_time(close) == 0.0,"%s : cible derrière la glissière, impact seul" % spec_case[0])

func verify_explosion_events() -> void:
	var model := Model.new(true)
	model.select_faction(0)
	model.elapsed = 5.0
	var first: Dictionary = Model.make_enemy(1,1,0.0,-1,100);first.distance = 10.0;first.hp = 0.0;first.volatile_until = 8.0;first.volatile_damage = 40.0;first.volatile_radius = 1.4
	var second: Dictionary = Model.make_enemy(2,1,0.0,-1,100);second.distance = 10.5;second.hp = 30.0;second.volatile_until = 8.0;second.volatile_damage = 40.0;second.volatile_radius = 1.4
	model.enemies = [first,second]
	model._apply_damage({})
	check(model.explosion_events.size() == 2,"Un événement par explosion, y compris en chaîne (%d)" % model.explosion_events.size())
	check(model.explosion_events.all(func(event): return is_equal_approx(float(event.time),5.0) and event.has("position") and is_equal_approx(float(event.radius),1.4)),"Chaque événement porte l'instant, la position et le rayon")
	var quiet := Model.new(true)
	check(quiet.explosion_events.is_empty(),"Aucun événement d'explosion sans réaction en chaîne")

func verify_resources() -> void:
	for name in ["slow","mark","loot","volatile","aura","volatile_burst"]:
		var path := "res://assets/effects/shop/%s.png" % name
		check(ResourceLoader.exists(path) and load(path) is Texture2D,"Ressource de repère présente : %s" % name)
