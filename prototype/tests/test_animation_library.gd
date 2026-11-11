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
	await verify_rendering()
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
	check(Library.defender_id(0) == "defender.alliance.archer" and Library.defender_id(9) == "defender.horde.grenadier" and Library.defender_id(10) == "" and Library.defender_id(-1) == "" and Library.DEFENDER_IDS.size() == Model.ROSTER.size(),"Un identifiant par défenseur du modèle")
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
	check(Library.has_animation("enemy.horde.warrior","walk") and not Library.has_animation("enemy.horde.warrior","death") and not Library.has_animation("enemy.horde.scout","walk"),"Animations disponibles par unité")
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
