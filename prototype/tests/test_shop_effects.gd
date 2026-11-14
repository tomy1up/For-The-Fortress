extends SceneTree
## Repères d'effets de la boutique : pastilles d'état des ennemis, événements d'explosion exposés par le moteur, ressources.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_badges()
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
