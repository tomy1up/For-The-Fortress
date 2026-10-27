extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const MapView = preload("res://scripts/valley_view.gd")
# Les nettoyages de nouvelle partie sont testés après une défaite simulée ; les verrous de parcours sont couverts séparément.
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func hover(scene: Node, point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	scene._input(event)
func snapshot(scene: Node) -> Array:
	var m = scene.model
	return [m.gold,m.fortress_hp,m.enemies.duplicate(true),m.defenders.duplicate(true),m.curses.duplicate(true),m.elapsed,m.rng.state,scene.selected,scene.speed]
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(1)
	check(scene.enemy_health_bar.size.y == 8 and scene.enemy_health_bar.get_rect().end.y < scene.enemy_threat.position.y,"La jauge reste fine et ne recouvre pas le texte de danger")
	check(scene.enemy_inspector.position.x+scene.enemy_inspector.size.x <= 1280,"Fiche contenue dans la fenêtre de référence")
	scene.selected = 0; scene.map_view.selected = 0; scene._buy(0)
	for type in range(8):
		var enemy: Dictionary = Model.make_enemy(100+type,type,0.0)
		enemy.distance = 10.0; enemy.hp = enemy.max_hp*0.51
		scene.model.enemies.assign([enemy]); scene.model.phase = "combat"
		var before: Array = snapshot(scene)
		hover(scene,MapView.enemy_bounds(enemy).get_center())
		check(scene.enemy_inspector.visible and scene.map_view.inspected_enemy_id == enemy.id,"Le survol détecte chaque profil à son échelle réelle")
		check(scene.enemy_name.text.contains(Model.Enemies.for_profile(type,scene.model.faction).name) and scene.enemy_health.text == "PV : %d / %d" % [ceili(enemy.hp),enemy.max_hp],"Nom et PV lus depuis l'ennemi actuel")
		check(scene.enemy_health_bar.value == enemy.hp and scene.enemy_health_bar.max_value == enemy.max_hp,"La jauge conserve la précision réelle des PV")
		check(scene.enemy_reward.text == "Éliminé : vous gagnez %d or." % enemy.reward and scene.enemy_threat.text.contains("elle perd %d PV" % enemy.fortress_damage) and scene.enemy_threat.text.begins_with("S’il atteint la forteresse"),"Récompense et dégâts à la forteresse explicités depuis le modèle")
		check(scene.enemy_threat.get_rect().end.y < scene.enemy_reward.position.y and scene.enemy_reward.get_rect().end.y < scene.enemy_status.position.y,"Les deux lignes de danger restent séparées de la récompense et du statut")
		check(snapshot(scene) == before,"Inspecter ne change ni combat, sélection, or ni générateur")
		enemy.hp = 0.001; scene._update_interface()
		check(scene.enemy_health.text.begins_with("PV : 1 /"),"Un ennemi vivant avec PV fractionnaires n'est pas affiché à zéro")
		enemy.hp = 0; scene._update_interface()
		check(not scene.enemy_inspector.visible and scene.map_view.inspected_enemy_id == -1,"Un ennemi mort n'est plus inspecté")
	var boss: Dictionary = Model.make_enemy(9,7,0); boss.distance = 10
	scene.model.enemies.assign([boss]); scene.model.fortress_hp = 20
	hover(scene,MapView.enemy_bounds(boss).get_center())
	check(scene.enemy_name.text.ends_with("BOSS") and scene.enemy_threat.text.contains("Défaite"),"Le boss est identifié et son arrivée fatale signalée")
	scene.model.fortress_hp = 24; scene._update_interface()
	check(not scene.enemy_threat.text.contains("Défaite"),"Le boss n'est pas annoncé fatal contre 24 PV")
	scene.model.curses.assign([{"enemy_id":9,"source_id":0,"damage":4.8}]); scene._update_interface()
	check(scene.enemy_status.text.contains("Malédiction active"),"La malédiction est signalée sans créer un effet")
	scene.model.curses.clear(); scene._update_interface()
	check(not scene.enemy_status.text.contains("Malédiction"),"Le statut se retire avec l'effet")
	hover(scene,Vector2(30,60))
	check(not scene.enemy_inspector.visible and scene.enemy_prompt.visible,"Hors des ennemis : aide de découverte, sans fiche périmée")
	hover(scene,MapView.enemy_bounds(boss).get_center()); boss.distance = 27; scene._update_interface()
	check(not scene.enemy_inspector.visible,"La fiche suit le survol réel si l'ennemi s'éloigne d'un pointeur immobile")
	# Ennemis superposés : ordre de profondeur puis ordre d'apparition dans le dessin.
	var first: Dictionary = Model.make_enemy(1,1,0); first.distance = 10.0
	var front: Dictionary = Model.make_enemy(2,3,0); front.distance = 10.2
	scene.model.enemies.assign([first,front])
	var overlap: Rect2 = MapView.enemy_bounds(first).intersection(MapView.enemy_bounds(front))
	check(overlap.has_area() and scene.map_view.enemy_at(overlap.get_center()) == 2,"Priorité au personnage dessiné au premier plan")
	front.distance = first.distance
	check(scene.map_view.enemy_at(MapView.enemy_bounds(first).get_center()) == 2,"Égalité de profondeur : dernier personnage dessiné")
	scene.model.enemies.clear(); scene._update_interface()
	check(not scene.enemy_inspector.visible,"Suppression du dernier ennemi retire la fiche")
	for phase in ["preparation","finished","bonus","victory","defeat"]:
		scene.model.enemies.assign([first]); scene.model.phase = phase
		hover(scene,MapView.enemy_bounds(first).get_center())
		check(not scene.enemy_inspector.visible and not scene.enemy_prompt.visible,"Aucune fiche ennemie en dehors du combat")
	scene.model.phase = "combat"; scene._show_bonuses()
	hover(scene,MapView.enemy_bounds(first).get_center())
	check(not scene.enemy_inspector.visible,"Pas d'inspection à travers le récapitulatif modal")
	scene._close_bonuses()
	check(scene.enemy_inspector.visible,"Retour au survol après fermeture du récapitulatif")
	scene.model.phase = "defeat"; scene._reset()
	check(not scene.enemy_inspector.visible and scene.map_view.inspected_enemy_id == -1,"Nouvel essai sans ancienne fiche")
	scene.free()
	# Parcours normal : inspecter un ennemi n'arrête pas l'horloge de combat.
	scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	scene._start()
	var enemy: Dictionary = scene.model.enemies[0]
	hover(scene,MapView.enemy_bounds(enemy).get_center()); scene._process(1)
	check(scene.model.elapsed == 1 and scene.model.enemies[0].distance == 1,"Le combat continue pendant la lecture")
	scene._toggle_speed(); scene._process(1)
	check(scene.model.elapsed == 3 and scene.model.enemies[0].distance == 3,"Le x2 reste effectif pendant l'inspection")
	scene.model.phase = "finished"; scene.model.enemies.clear(); scene._process(1)
	check(scene.countdown_remaining == 29 and not scene.enemy_inspector.visible,"La préparation automatique reprend sans fiche résiduelle")
	scene.free()
	print("ENEMY_INSPECTION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
