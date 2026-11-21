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
