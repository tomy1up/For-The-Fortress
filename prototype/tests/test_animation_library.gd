extends SceneTree
const Library = preload("res://scripts/animation_library.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_validation()
	verify_maths()
	verify_defender_state()
	verify_assets_on_disk()
	verify_event_animations()
	verify_walk_variants_and_warning()
	await verify_rendering()
	await verify_event_rendering()
	await verify_headwinds_marker()
	await verify_warning_rendering()
	Library.clear_cache()
	print("ANIMATION_LIBRARY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func sample() -> Dictionary:
	return {"version":1,"id":"enemy.test.walker","display_height":34.0,"foot":[32,60],"facing":"right","muzzle":[50,20],"animations":{
		"walk":{"file":"walk.png","frames":12,"frame_size":[64,64],"mode":"distance","stride":40.0},
		"idle":{"file":"idle.png","frames":4,"frame_size":[64,64],"mode":"time","fps":6.0},
		"attack":{"file":"attack.png","frames":6,"frame_size":[64,64],"mode":"event","duration":0.4},
		"disabled":{"file":"disabled.png","frames":5,"frame_size":[64,64],"mode":"event","duration":1.0}}}

func mutated(path: Array, value: Variant) -> Dictionary:
	var data: Dictionary = sample().duplicate(true)
	var node: Variant = data
	for index in range(path.size()-1): node = node[path[index]]
	if value is String and value == "<erase>": node.erase(path[-1])
	else: node[path[-1]] = value
	return data

func verify_validation() -> void:
	check(Library.validation_error(sample(),"enemy.test.walker") == "","Description complète valide")
	check(Library.validation_error(sample()) == "" and Library.validation_error(sample(),"autre") != "","Identifiant comparé au dossier")
	var bad: Array = [null,"x",[],{},mutated(["version"],2),mutated(["version"],1.5),mutated(["display_height"],0),mutated(["display_height"],500),mutated(["display_height"],INF),
		mutated(["foot"],[1]),mutated(["foot"],["a",1]),mutated(["facing"],"up"),mutated(["muzzle"],[1,2,3]),mutated(["extra"],1),mutated(["animations"],{}),mutated(["animations"],[]),
		mutated(["animations","jump"],{"file":"j.png","frames":1,"frame_size":[8,8],"mode":"time","fps":1}),
		mutated(["animations","walk","file"],"../walk.png"),mutated(["animations","walk","file"],"walk.jpg"),mutated(["animations","walk","file"],"sub/walk.png"),mutated(["animations","walk","file"],".png"),
		mutated(["animations","walk","frames"],0),mutated(["animations","walk","frames"],65),mutated(["animations","walk","frames"],2.5),
		mutated(["animations","walk","frame_size"],[0,64]),mutated(["animations","walk","frame_size"],[64,2000]),mutated(["animations","walk","frame_size"],[64]),
		mutated(["animations","walk","mode"],"magic"),mutated(["animations","walk","stride"],"<erase>"),mutated(["animations","walk","stride"],0),mutated(["animations","walk","stride"],NAN),
		mutated(["animations","idle","fps"],"<erase>"),mutated(["animations","idle","fps"],61),mutated(["animations","attack","duration"],"<erase>"),mutated(["animations","attack","duration"],11),
		mutated(["animations","attack","loop"],true),mutated(["animations","walk","loop"],false),mutated(["animations","walk","loop"],"oui"),mutated(["animations","walk","extra"],1),
		mutated(["animations","idle","frame_size"],[32,64])]
	for index in range(bad.size()): check(Library.validation_error(bad[index]) != "","Description invalide refusée (cas %d)" % index)
	var plain: Dictionary = sample().duplicate(true);plain.erase("facing");plain.erase("muzzle")
	check(Library.validation_error(plain) == "","Côté et projectile facultatifs")
	var anim: Dictionary = sample().animations.walk
	check(Library.sheet_size_error(anim,Vector2i(768,64)) == "" and Library.sheet_size_error(anim,Vector2i(768,63)) != "" and Library.sheet_size_error(anim,Vector2i(64,64)) != "","Taille de planche contrôlée")
	check(Library.defender_id(0) == "defender.alliance.archer" and Library.defender_id(9) == "defender.horde.grenadier" and Library.defender_id(10) == "defender.alliance.sentinel" and Library.defender_id(21) == "defender.horde.cinderburner" and Library.defender_id(50) == "" and Library.defender_id(-1) == "" and Library.DEFENDER_IDS.size() == Model.ROSTER.size(),"Un identifiant par défenseur du modèle")
	check(Library.spec_for("") == {} and Library.spec_for("enemy.test.inexistant") == {},"Unité sans description : aucun résultat")

func verify_maths() -> void:
	var spec: Dictionary = sample()
	var walk: Dictionary = spec.animations.walk
	check(is_equal_approx(Library.phase(walk,20.0,99.0,99.0),0.5) and is_equal_approx(Library.phase(walk,40.0,0.0,0.0),0.0) and is_equal_approx(Library.phase(walk,50.0,0.0,0.0),0.25),"Phase de marche selon la distance parcourue")
	check(is_equal_approx(Library.phase(walk,10.0,0.0,0.0,0.5),0.75) and is_equal_approx(Library.phase(walk,-10.0,0.0,0.0),0.75),"Décalage individuel et distances négatives restent dans la boucle")
	var idle: Dictionary = spec.animations.idle
	check(is_equal_approx(Library.phase(idle,0.0,1.0/3.0,0.0),0.5),"Phase de repos selon le temps et la cadence")
	var attack: Dictionary = spec.animations.attack
	check(is_equal_approx(Library.phase(attack,0.0,0.0,0.2),0.5) and Library.phase(attack,0.0,0.0,9.0) == 1.0 and Library.phase(attack,0.0,0.0,-1.0) == 0.0,"Phase d'un événement bornée à [0, 1]")
	check(Library.frame_index(walk,0.0) == 0 and Library.frame_index(walk,0.5) == 6 and Library.frame_index(walk,0.999) == 11 and Library.frame_index(walk,1.0) == 0 and Library.frame_index(walk,-0.01) == 11,"Image d'une boucle fermée")
	check(Library.frame_index(attack,0.0) == 0 and Library.frame_index(attack,1.0) == 5 and Library.frame_index(attack,0.5) == 3,"Un événement se maintient sur sa dernière image")
	var seen := {}
	for step in range(240): seen[Library.frame_index(walk,Library.phase(walk,step*0.5,0.0,0.0))] = true
	check(seen.size() == 12,"Les douze images sont parcourues sur un cycle")
	check(Library.frame_region(walk,3) == Rect2(192,0,64,64) and Library.frame_region(walk,99) == Rect2(704,0,64,64) and Library.frame_region(walk,-4) == Rect2(0,0,64,64),"Découpe de la planche")
	var destination: Rect2 = Library.destination(spec,walk)
	var scale: float = 34.0/64.0
	check(is_equal_approx(destination.size.y,34.0) and is_equal_approx(destination.size.x,64.0*scale) and is_equal_approx(destination.position.x,-32.0*scale) and is_equal_approx(destination.position.y,-60.0*scale),"Pieds sur l'origine, hauteur d'affichage respectée")
	check(Library.base_facing(spec) == 1.0 and Library.base_facing(mutated(["facing"],"left")) == -1.0,"Côté regardé par défaut")
	check(Library.muzzle(spec).is_equal_approx(Vector2(18.0,-40.0)*scale),"Point de départ des projectiles relatif aux pieds")
	var plain: Dictionary = sample().duplicate(true);plain.erase("muzzle")
	check(Library.muzzle(plain) == Vector2.ZERO,"Sans point de départ : origine")

func verify_defender_state() -> void:
	var spec: Dictionary = sample()
	check(Library.defender_state(spec,{}) == "idle","Repos par défaut")
	check(Library.defender_state(spec,{"attack_age":0.1}) == "attack" and Library.defender_state(spec,{"attack_age":0.5}) == "idle","Tir événementiel jusqu'au bout de sa durée")
	check(Library.defender_state(spec,{"disabled":true,"attack_age":0.1}) == "disabled" and Library.defender_state(spec,{"disabled":false}) == "idle","La désactivation prime sur le tir")
	var only_idle: Dictionary = sample().duplicate(true);only_idle.animations = {"idle":only_idle.animations.idle}
	check(Library.defender_state(only_idle,{"disabled":true,"attack_age":0.1}) == "idle","Repli sur le repos quand l'état manque")
	var no_idle: Dictionary = sample().duplicate(true);no_idle.animations = {"attack":no_idle.animations.attack}
	check(Library.defender_state(no_idle,{}) == "" and Library.defender_state(no_idle,{"attack_age":0.1}) == "attack","Sans repos ni tir : aucun état, le rendu retombe sur l'illustration fixe")
	var timed: Dictionary = sample().duplicate(true);timed.animations.attack = {"file":"a.png","frames":4,"frame_size":[64,64],"mode":"time","fps":8.0}
	check(Library.defender_state(timed,{"attack_age":0.1,"pulse":0.5}) == "attack" and Library.defender_state(timed,{"attack_age":0.1,"pulse":0.0}) == "idle","Attaque en boucle suivant l'impulsion de tir")

func verify_assets_on_disk() -> void:
	var directory := DirAccess.open(Library.ROOT)
	if directory == null: return
	for name in directory.get_directories():
		var spec: Dictionary = Library.spec_for(name)
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(Library.description_path(name)))
		check(not spec.is_empty(),"Animation livrée « %s » : %s" % [name,Library.validation_error(data,name) if Library.validation_error(data,name) != "" else "planche absente ou de mauvaise taille"])

func sheet(frames: int, color: Color) -> Texture2D:
	var image := Image.create(frames*64,64,false,Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func verify_rendering() -> void:
	Library.clear_cache()
	var walker: Dictionary = sample().duplicate(true);walker.id = "enemy.horde.warrior"
	Library.register_for_test("enemy.horde.warrior",walker,{"walk":sheet(12,Color.RED),"idle":sheet(4,Color.GREEN),"attack":sheet(6,Color.BLUE),"disabled":sheet(5,Color.GRAY)})
	var archer: Dictionary = sample().duplicate(true);archer.id = "defender.alliance.archer"
	Library.register_for_test("defender.alliance.archer",archer,{"walk":sheet(12,Color.RED),"idle":sheet(4,Color.GREEN),"attack":sheet(6,Color.BLUE),"disabled":sheet(5,Color.GRAY)})
	check(Library.has_animation("enemy.horde.warrior","walk") and not Library.has_animation("enemy.horde.warrior","death") and not Library.has_animation("enemy.horde.inconnu","walk"),"Animations disponibles par unité")
	var model := Model.new(true)
	model.select_faction(0)
	model.rng.seed = 7
	check(model.buy(3,0),"Défenseur placé pour le rendu")
	model.start()
	model.advance(6.0)
	var before: String = JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.enemies,model.defenders])
	var view := View.new();view.model = model;root.add_child(view)
	await process_frame
	await process_frame
	var warrior: Dictionary = {}
	for enemy in model.enemies:
		if View.enemy_art_id(enemy,model.faction) == "enemy.horde.warrior": warrior = enemy;break
	check(not warrior.is_empty(),"Un guerrier orc est à l'écran pour le rendu animé")
	if not warrior.is_empty():
		var bounds: Rect2 = View.enemy_bounds(warrior,model.faction)
		var destination: Rect2 = Library.destination(Library.spec_for("enemy.horde.warrior"),walker.animations.walk)
		check(bounds.size.y >= destination.size.y*View._enemy_scale(warrior)-0.001,"Le survol englobe l'image animée")
	view.queue_redraw()
	await process_frame
	await process_frame
	check(JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.enemies,model.defenders]) == before,"Dessiner avec des planches ne modifie pas le combat")
	var pose: Dictionary = view.defender_pose(3)
	check(pose.has("attack_age") or not model.shots.any(func(shot):return shot.slot == 3),"La pose de défenseur porte l'âge du dernier tir")
	check(not pose.get("disabled",false),"Défenseur actif hors éruption")
	view.free()
	var eruptions := Model.new(true)
	eruptions.configure_combat_affix({"id":"eruptions","interval":14,"warning":3,"duration":5})
	eruptions.rng.seed = 7
	eruptions.buy(3,0)
	eruptions.start()
	eruptions.advance(14.0)
	var struck: int = eruptions.eruption_slot(1)
	var eruption_view := View.new();eruption_view.model = eruptions;root.add_child(eruption_view)
	await process_frame
	var disabled_pose: Dictionary = eruption_view.defender_pose(struck)
	check(disabled_pose.get("disabled",false) and disabled_pose.disabled_age >= 0.0 and disabled_pose.disabled_age < 0.01,"Un défenseur frappé par l'éruption est désactivé dès son début")
	eruptions.advance(3.0)
	check(is_equal_approx(eruption_view.defender_pose(struck).disabled_age,3.0),"Âge de la désactivation")
	eruptions.advance(2.1)
	check(not eruption_view.defender_pose(struck).get("disabled",false),"Fin de la désactivation")
	eruption_view.free()

func event_sample() -> Dictionary:
	var data: Dictionary = sample().duplicate(true)
	for name in ["death","hurt","spawn","buy","sell","level_up"]:
		data.animations[name] = {"file":name+".png","frames":4,"frame_size":[64,64],"mode":"event","duration":0.5}
	return data

func verify_event_animations() -> void:
	var data: Dictionary = event_sample()
	check(Library.validation_error(data) == "","Toutes les animations d'événements sont acceptées en mode event")
	for name in ["death","hurt","spawn","buy","sell","level_up"]:
		var timed: Dictionary = event_sample();timed.animations[name] = {"file":"x.png","frames":4,"frame_size":[64,64],"mode":"time","fps":8.0}
		check(Library.validation_error(timed) != "","%s : le mode time est refusé" % name)
		var long: Dictionary = event_sample();long.animations[name].duration = 3.5
		check(Library.validation_error(long) != "","%s : durée au-delà de 3 s refusée" % name)
	var info_spec: Dictionary = data
	check(Library.enemy_state(info_spec,{}) == "walk" and Library.enemy_state(info_spec,{"spawn_age":0.2}) == "spawn" and Library.enemy_state(info_spec,{"spawn_age":0.6}) == "walk","Apparition puis marche")
	check(Library.enemy_state(info_spec,{"hurt_age":0.1,"spawn_age":0.2}) == "hurt" and Library.enemy_state(info_spec,{"hurt_age":-1.0}) == "walk" and Library.enemy_state(info_spec,{"hurt_age":0.6}) == "walk","Le coup reçu prime sur l'apparition et reste borné à sa durée")
	var no_walk: Dictionary = sample().duplicate(true);no_walk.animations.erase("walk")
	check(Library.enemy_state(no_walk,{}) == "","Sans marche : aucune animation d'ennemi")
	check(Library.defender_state(data,{"sell_age":0.1,"disabled":true,"attack_age":0.1}) == "sell" and Library.defender_state(data,{"sell_age":0.6}) == "idle","La revente prime sur tout, dans sa durée")
	check(Library.defender_state(data,{"disabled":true,"buy_age":0.1}) == "disabled" and Library.defender_state(data,{"attack_age":0.1,"buy_age":0.1}) == "attack","Désactivation puis tir priment sur l'achat")
	check(Library.defender_state(data,{"buy_age":0.1,"level_up_age":0.1}) == "buy" and Library.defender_state(data,{"level_up_age":0.1}) == "level_up" and Library.defender_state(data,{"level_up_age":0.7}) == "idle","Achat, niveau, puis retour au repos")
	check(Library.defender_state(data,{"buy_age":-0.5}) == "idle","Un âge négatif ne déclenche rien")
	Library.clear_cache()
	check(Library.death_window() == 0.0,"Sans animation chargée : aucune fenêtre de mort")
	Library.register_for_test("enemy.test.walker",data)
	check(is_equal_approx(Library.death_window(),0.5),"Fenêtre de mort égale à la plus longue durée chargée")
	Library.clear_cache()

func verify_event_rendering() -> void:
	Library.clear_cache()
	var sheets := {}
	for name in ["walk","idle","attack","disabled","death","hurt","spawn","buy","sell","level_up"]: sheets[name] = sheet(12,Color.WHITE)
	var warrior: Dictionary = event_sample();warrior.id = "enemy.horde.warrior"
	var archer: Dictionary = event_sample();archer.id = "defender.alliance.archer"
	Library.register_for_test("enemy.horde.warrior",warrior,sheets)
	Library.register_for_test("defender.alliance.archer",archer,sheets)
	# Combat : mort, coup reçu et apparition, sans modifier le déroulement.
	var model := Model.new(true)
	model.select_faction(0);model.rng.seed = 7
	model.buy(3,0);model.buy(4,1)
	model.start()
	var view := View.new();view.model = model;root.add_child(view)
	await process_frame
	var guard := 0
	var saw_hurt := false
	var saw_spawn := false
	while model.active and guard < 400:
		model.advance(0.25);guard += 1 # Pas de pause d'image ici : le lanceur coupe les suites à 120 images.
		for enemy in model.enemies:
			if view.last_hit_age(enemy.id) >= 0.0: saw_hurt = true
			if model.elapsed-float(enemy.spawn_time) < 0.5: saw_spawn = true
	check(saw_hurt and saw_spawn,"Âges de coup reçu et d'apparition disponibles pour le rendu")
	check(model.elimination_events.size() > 0 and model.elimination_events.all(func(event):return event.has("distance") and event.has("route_id")),"Les éliminations portent leur distance et leur trajet")
	check(view.recent_eliminations(5.0).size() > 0,"Fenêtre d'éliminations étendue pour les morts animées")
	check(view.last_hit_age(-5) < 0.0,"Aucun coup pour un ennemi inconnu")
	view.free()
	# Préparation : achat, niveau, revente observés sans état de jeu.
	var shop := Model.new(true)
	shop.select_faction(0);shop.rng.seed = 7
	shop.buy(3,0)
	var shop_view := View.new();shop_view.model = shop;root.add_child(shop_view)
	await process_frame
	await process_frame
	check(shop_view._defender_events.is_empty() and shop_view._sold_ghosts.is_empty(),"Un défenseur déjà posé à l'ouverture n'est pas animé")
	var before: String = JSON.stringify([shop.gold,shop.rng.state,shop.defenders,shop.action_history])
	check(shop.buy(4,1),"Achat en préparation")
	await process_frame
	check(shop_view._defender_events.get(4,{}).get("kind","") == "buy" and shop_view.defender_pose(4).has("buy_age"),"Achat détecté et âge exposé à la pose")
	shop.gold += 300 # Essai du suivi visuel seul : de quoi financer l'amélioration.
	check(shop.upgrade(3),"Amélioration en préparation")
	await process_frame
	check(shop_view._defender_events.get(3,{}).get("kind","") == "level_up" and shop_view.defender_pose(3).has("level_up_age") and Library.defender_state(Library.spec_for("defender.alliance.archer"),shop_view.defender_pose(3)) == "level_up","Passage de niveau détecté et animé")
	check(shop.sell(4),"Revente en préparation")
	await process_frame
	check(shop_view._sold_ghosts.size() == 1 and shop_view._sold_ghosts[0].slot == 4 and not shop_view._defender_events.has(4),"Revente détectée, fantôme conservé pour l'animation")
	var after_actions: String = JSON.stringify([shop.gold,shop.rng.state,shop.defenders,shop.action_history])
	shop_view.queue_redraw()
	await process_frame
	await process_frame
	check(after_actions == JSON.stringify([shop.gold,shop.rng.state,shop.defenders,shop.action_history]) and before != after_actions,"Le suivi visuel ne modifie pas le jeu")
	shop_view.free()
	Library.clear_cache()

func verify_headwinds_marker() -> void:
	var windy := Model.new(true)
	check(windy.configure_combat_affix({"id":"headwinds","cadence_percent":90}),"Vents contraires configurés")
	windy.rng.seed = 7
	windy.buy(3,0)
	var before: String = JSON.stringify([windy.gold,windy.rng.state,windy.defenders,windy.action_history])
	var view := View.new();view.model = windy;root.add_child(view)
	await process_frame
	check(view._sheet_animation_running(),"Le repère des vents contraires demande un redessin continu")
	view.queue_redraw()
	await process_frame
	await process_frame
	check(before == JSON.stringify([windy.gold,windy.rng.state,windy.defenders,windy.action_history]),"Dessiner le vent ne modifie pas le jeu")
	view.free()
	var calm := Model.new(true)
	var calm_view := View.new();calm_view.model = calm;root.add_child(calm_view)
	await process_frame
	check(not calm_view._sheet_animation_running(),"Sans affixe ni planche : aucun redessin continu")
	calm_view.free()

func variant_sample() -> Dictionary:
	var data: Dictionary = sample().duplicate(true)
	data.animations.walk_up = {"file":"walk_up.png","frames":12,"frame_size":[64,64],"mode":"distance","stride":40.0}
	data.animations.walk_down = {"file":"walk_down.png","frames":12,"frame_size":[64,64],"mode":"distance","stride":40.0}
	return data

func verify_walk_variants_and_warning() -> void:
	var data: Dictionary = variant_sample()
	check(Library.validation_error(data) == "","Variantes de marche montante et descendante acceptées")
	var other_frames: Dictionary = variant_sample();other_frames.animations.walk_up.frames = 8
	var other_stride: Dictionary = variant_sample();other_stride.animations.walk_down.stride = 50.0
	var no_base: Dictionary = variant_sample();no_base.animations.erase("walk")
	var timed: Dictionary = variant_sample();timed.animations.walk_up = {"file":"u.png","frames":12,"frame_size":[64,64],"mode":"time","fps":8.0}
	for bad in [other_frames,other_stride,no_base,timed]: check(Library.validation_error(bad) != "","Variante incompatible avec la marche de base refusée")
	var up := Vector2(0.9,-0.4).normalized()
	var down := Vector2(0.9,0.4).normalized()
	check(Library.enemy_state(data,{"direction":up}) == "walk_up" and Library.enemy_state(data,{"direction":down}) == "walk_down","Variante choisie selon la pente du trajet à l'écran")
	check(Library.enemy_state(data,{"direction":Vector2.RIGHT}) == "walk" and Library.enemy_state(data,{}) == "walk","Trajet horizontal ou direction absente : marche de base")
	var only_up: Dictionary = sample().duplicate(true);only_up.animations.walk_up = variant_sample().animations.walk_up
	check(Library.enemy_state(only_up,{"direction":down}) == "walk" and Library.enemy_state(only_up,{"direction":up}) == "walk_up","Variante manquante : marche de base")
	check(Library.enemy_state(data,{"direction":up,"hurt_age":0.1}) == "walk_up","Sans animation de coup reçu, la marche continue")
	# Continuité du pas au virage : la phase ne dépend que de la distance parcourue, identique pour les deux variantes.
	var walk: Dictionary = data.animations.walk
	var before_turn: float = Library.phase(data.animations.walk_up,137.3,0.0,0.0,0.25)
	var after_turn: float = Library.phase(data.animations.walk_down,137.3,0.0,0.0,0.25)
	check(is_equal_approx(before_turn,after_turn) and Library.frame_index(data.animations.walk_up,before_turn) == Library.frame_index(data.animations.walk_down,after_turn) and Library.frame_index(walk,before_turn) == Library.frame_index(data.animations.walk_up,before_turn),"Même image de foulée de part et d'autre du virage")
	var warning: Dictionary = {"version":1,"id":"effect.test","display_height":60,"foot":[40,40],"animations":{"warning":{"file":"w.png","frames":24,"frame_size":[80,60],"mode":"progress"}}}
	check(Library.validation_error(warning) == "","Animation d'avertissement en mode progress acceptée")
	var wrong_mode: Dictionary = warning.duplicate(true);wrong_mode.animations.warning = {"file":"w.png","frames":24,"frame_size":[80,60],"mode":"event","duration":3.0}
	var extra: Dictionary = warning.duplicate(true);extra.animations.warning.duration = 3.0
	var stray: Dictionary = variant_sample();stray.animations.idle = {"file":"i.png","frames":4,"frame_size":[64,64],"mode":"progress"}
	for bad in [wrong_mode,extra,stray]: check(Library.validation_error(bad) != "","Mode progress réservé à warning, sans durée")
	var progress: Dictionary = warning.animations.warning
	check(Library.phase(progress,0.0,0.0,0.5) == 0.5 and Library.phase(progress,0.0,0.0,2.0) == 1.0 and Library.phase(progress,0.0,0.0,-1.0) == 0.0,"Progression bornée à [0, 1]")
	check(Library.frame_index(progress,0.0) == 0 and Library.frame_index(progress,1.0) == 23 and Library.frame_index(progress,0.5) == 12,"Image selon la progression")

func verify_warning_rendering() -> void:
	Library.clear_cache()
	var effect: Dictionary = {"version":1,"id":"effect.eruption","display_height":60,"foot":[40,40],"animations":{"warning":{"file":"warning.png","frames":24,"frame_size":[80,60],"mode":"progress"}}}
	var strip := Image.create(24*80,60,false,Image.FORMAT_RGBA8)
	strip.fill(Color(1.0,0.4,0.1,0.5))
	Library.register_for_test("effect.eruption",effect,{"warning":ImageTexture.create_from_image(strip)})
	var model := Model.new(true)
	model.configure_combat_affix({"id":"eruptions","interval":14,"warning":3,"duration":5})
	model.rng.seed = 7
	model.buy(3,0)
	model.start()
	model.advance(12.0)
	var before: String = JSON.stringify([model.gold,model.rng.state,model.defenders,model.eruption_status()])
	var view := View.new();view.model = model;root.add_child(view)
	await process_frame
	check(view._eruption_warning_sheet() and model.eruption_status().get("state","") == "warning","Avertissement en cours avec une planche disponible")
	view.queue_redraw()
	await process_frame
	await process_frame
	check(before == JSON.stringify([model.gold,model.rng.state,model.defenders,model.eruption_status()]),"Dessiner l'avertissement ne modifie pas le jeu")
	model.advance(2.0)
	view.queue_redraw()
	await process_frame
	check(model.eruption_status().get("state","") == "active","Désactivation après l'avertissement : la planche cède la place")
	view.free()
	Library.clear_cache()
	Library.register_for_test("effect.eruption",{}) # Planche absente (la vraie est livrée dans les ressources).
	var bare := View.new();bare.model = model;root.add_child(bare)
	await process_frame
	check(not bare._eruption_warning_sheet(),"Sans planche : repère provisoire conservé")
	bare.free()
