extends SceneTree
## Système sonore (décision du porteur, 16 novembre 2026) : les sons suivent les événements du modèle aux instants du rendu, sans rien écrire dans le modèle,
## et le jeu reste silencieux sans échec tant que les fichiers ne sont pas installés.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Director = preload("res://scripts/sound_director.gd")
const Bank = preload("res://scripts/sound_bank.gd")
const Player = preload("res://scripts/sound_player.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	check(Bank.shot_event(0,0) == "shot.bow" and Bank.shot_event(1,1) == "shot.crossbow" and Bank.shot_event(13,1) == "shot.cannon" and Bank.shot_event(12,1) == "shot.gun" and Bank.shot_event(14,0) == "shot.melee","Événement de tir selon le type puis la famille")
	for family in range(6):
		check(Bank.EVENTS.has(Bank.shot_event(family,family)) and Bank.EVENTS.has(Bank.impact_event(family)),"Chaque famille a ses événements de tir et d'impact au catalogue")
	for event in Bank.EVENTS: check(Bank.EVENTS[event].has("files") and Bank.gain_db(event) <= 0.0,"%s : liste de fichiers et gain borné" % event)
	# Sons retenus par le porteur (Freesound, CC0) : tous les fichiers listés existent ; les événements sans son restent silencieux.
	var installed: Array[String] = ["shot.bow","shot.crossbow","shot.melee","impact.hit"]
	for event in Bank.EVENTS:
		for name in Bank.EVENTS[event].files: check(not Bank.resolve(name).is_empty(),"%s : fichier %s présent" % [event,name])
		if event in installed:
			check(not Bank.stream_path(event).is_empty(),"%s : un son est installé" % event)
			check(Bank.stream_path(event,0) != Bank.stream_path(event,1) or Bank.EVENTS[event].files.size() == 1,"%s : le numéro varie le fichier" % event)
		else:
			check(Bank.stream_path(event).is_empty(),"%s : silencieux (aucun son retenu)" % event)
	# Fichiers absents : silence et aucune erreur.
	check(Bank.stream_path("shot.bow").is_empty() or Bank.stream_path("shot.bow").begins_with(Bank.DIRECTORY),"Chemin vide ou dans le dossier des sons")
	check(Bank.stream_path("inconnu").is_empty() and is_equal_approx(Bank.gain_db("inconnu"),0.0),"Événement inconnu : silence")
	var player := Player.new();player.dry = true;root.add_child(player)
	await process_frame
	check(not Player.muted and not player.play("shot.gun"),"Son actif par défaut ; un événement sans son reste silencieux")
	check(player.play("shot.bow") and player.played == 1 and not player.play("inconnu"),"Lecture d'un son installé ; événement inconnu silencieux")
	Player.muted = true
	check(not player.play("shot.bow"),"Coupure : rien n'est joué")
	Player.muted = false
	player.release()
	player.free()
	await process_frame
	await process_frame
	# Instants : un tir du Sapeur (lâcher différé de 0,12 s) sonne au lâcher, l'impact à l'arrivée.
	var m = Model.new()
	m.select_faction(1)
	m.buy(3,4)
	var director = Director.new(View.launch_delay,View.PROJECTILE_FLIGHT)
	var before: String = JSON.stringify([m.gold,m.fortress_hp,m.rng.state])
	m.start()
	var events: Array[Dictionary] = []
	var shot_time: float = -1.0
	var guard := 0
	while m.active and guard < 4000 and events.size() < 6:
		m.advance(0.01)
		guard += 1
		for entry in director.update(m): events.append({"event":entry.event,"at":m.elapsed})
		if shot_time < 0.0 and not m.shots.is_empty(): shot_time = float(m.shots[0].time)
	check(shot_time >= 0.0 and events.size() >= 2,"Le combat produit des sons")
	if events.size() >= 2:
		check(events[0].event == "shot.throw" and events[0].at >= shot_time+0.119 and events[0].at < shot_time+0.16,"Le tir sonne au lâcher visuel (0,12 s après le tir)")
		check(events[1].event == "impact.blast" and events[1].at >= shot_time+0.239 and events[1].at < shot_time+0.28,"L'impact sonne à l'arrivée du projectile")
	# Éliminations proches : un seul son.
	var many = Model.new();many.phase = "combat";many.elapsed = 5.0
	for id in range(5): many.elimination_events.append({"time":5.0-0.01*id,"enemy_id":id,"type":1,"point":Vector2(2,2)})
	var crowd: Array[Dictionary] = Director.new().update(many)
	check(crowd.size() == 1 and crowd[0].event == "enemy.down","Éliminations simultanées regroupées en un son")
	# Un son très en retard est abandonné ; un nouveau temps de combat repart de zéro.
	var late = Model.new();late.phase = "combat";late.elapsed = 100.0
	late.elimination_events.append({"time":1.0,"enemy_id":9,"type":1,"point":Vector2(2,2)})
	check(Director.new().update(late).is_empty(),"Un événement très ancien ne sonne pas")
	var again = Director.new()
	var wave = Model.new();wave.phase = "combat";wave.elapsed = 3.0
	wave.elimination_events.append({"time":3.0,"enemy_id":1,"type":1,"point":Vector2(2,2)})
	check(again.update(wave).size() == 1 and again.update(wave).is_empty(),"Un événement ne sonne qu'une fois")
	wave.elapsed = 0.5;wave.elimination_events.clear()
	again.update(wave)
	wave.elapsed = 3.0;wave.elimination_events.append({"time":3.0,"enemy_id":1,"type":1,"point":Vector2(2,2)})
	check(again.update(wave).size() == 1,"Nouvelle vague : mêmes numéros, de nouveau audibles")
	check(Director.new().update(null).is_empty(),"Sans modèle : aucun son")
	print("SOUND_DIRECTOR_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
