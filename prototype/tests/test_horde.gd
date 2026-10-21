extends SceneTree

const Model = preload("res://scripts/valley_model.gd")
var checks: int = 0
var failures: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func fixture(types: Array[int] = []) -> RefCounted:
	var model = Model.new(false)
	model.select_faction(1)
	model.gold = 600
	for index in range(types.size()):
		model.buy(index, types[index])
	model.phase = "combat"
	model.spawned = 10
	return model

func enemy(id: int, progress: float, hp: float = 100.0, type: int = 1) -> Dictionary:
	var result: Dictionary = Model.make_enemy(id, type, 0.0)
	result.spawn_time = -progress / result.speed
	result.distance = progress
	result.hp = hp
	return result

func close(a: float, b: float) -> bool:
	return absf(a - b) < 0.00000001

func _initialize() -> void:
	var model = Model.new(false)
	check(model.select_faction(1) and model.available_types() == [3, 4, 5], "Roster Horde")
	check(not model.buy(0, 0) and model.gold == 150, "Aucun mélange de factions")
	check(model.buy(0, 3) and model.buy(1, 3) and not model.buy(2, 3), "Quota de deux trolls")
	check(not model.select_faction(0), "Choix fixé après recrutement")
	check(model.sell(0) and model.buy(2, 3), "Vente libère le quota Horde")

	model = fixture([3])
	model.enemies.assign([enemy(0, 3), enemy(1, 2.5), enemy(2, 2.2)])
	model._resolve_instant()
	check(model.enemies[0].hp == 84 and model.enemies[1].hp == 92 and model.enemies[2].hp == 100, "Troll : 16 + un seul rebond de 8")
	check(model.shots[0].secondary.size() == 1, "Une victime secondaire distincte")
	model = fixture([3])
	model.enemies.assign([enemy(0, 3), enemy(1, 2)])
	model._resolve_instant()
	check(model.enemies[1].hp == 100, "Rebond : distance strictement inférieure à 1")

	model = fixture([4])
	# E1 est trop loin du point 10 ; utiliser E3 pour cette situation contrôlée.
	model.defenders[2] = model.defenders[0]
	model.defenders[0] = {}
	model.defenders[2].windows = Model.coverage_windows(Model.SLOTS[2], 3.0)
	model.enemies.assign([enemy(0, 10), enemy(1, 9.8), enemy(2, 9.6), enemy(3, 9.4), enemy(4, 9.2)])
	model._resolve_instant()
	check(model.enemies[0].hp == 76, "Sapeur : 24 dégâts principaux")
	for i in range(1, 4):
		check(close(model.enemies[i].hp, 90.4), "Sapeur : secondaire à 9,6")
	check(model.enemies[4].hp == 100 and model.shots[0].secondary.size() == 3, "Sapeur : plafond de trois secondaires")

	# C-06 : effets hors portée, sans prolonger l'effet jusqu'à l'arrivée.
	model = fixture([5])
	model.enemies.assign([enemy(0, 25.5)])
	model._apply_curse(model.defenders[0].instance_id, 0, 4.8)
	model.advance(2)
	check(close(model.enemies[0].hp, 90.4) and model.shots.is_empty(), "C-06 : deux ticks hors portée")
	check(model.curses.is_empty(), "Malédiction épuisée après deux échéances")

	# C-07 : le tick ancien à 2 s précède le nouveau tir et son renouvellement.
	model = fixture([5])
	model.enemies.assign([enemy(0, 3)])
	model._resolve_instant()
	check(model.enemies[0].hp == 88 and model.curses.size() == 1, "Chaman : direct 12 et application")
	model.advance(2)
	check(close(model.enemies[0].hp, 66.4), "C-07 : 12 + 4,8 + 4,8 + 12 à 2 s")
	check(model.curses.size() == 1 and model.curses[0].next_at == 3 and model.curses[0].ticks_left == 2, "C-07 : nouvelles échéances à 3 et 4")
	var tick_index: int = model.event_log.find("2.000000000 tick source 0 cible 0")
	var shot_index: int = model.event_log.find("2.000000000 tir E1 cible 0")
	check(tick_index >= 0 and shot_index > tick_index, "C-07 : ordre du journal tick puis tir")

	model = fixture([5, 5])
	model.enemies.assign([enemy(0, 3)])
	model._resolve_instant()
	check(model.curses.size() == 2 and model.enemies[0].hp == 76, "Deux chamans : effets indépendants")
	for defender in model.defenders:
		if not defender.is_empty(): defender.ready_at = INF
	model.advance(2)
	check(close(model.enemies[0].hp, 56.8) and model.curses.is_empty(), "Quatre ticks indépendants, aucune fusion des sources")

	# Renouvellement contrôlé avant échéance : les anciens ticks futurs sont remplacés.
	model = fixture()
	model.enemies.assign([enemy(0, 20)])
	model._apply_curse(7, 0, 4.8)
	model.advance(0.5)
	model._apply_curse(7, 0, 4.8)
	check(model.curses.size() == 1 and model.curses[0].next_at == 1.5, "Un seul effet par source et cible")
	model.advance(0.5)
	check(model.enemies[0].hp == 100, "Ancien tick à 1 s annulé")
	model.advance(1.5)
	check(close(model.enemies[0].hp, 90.4), "Deux nouveaux ticks uniquement")

	# C-08 : un tick létal au même instant que l'arrivée précède les dégâts de forteresse.
	model = fixture([5])
	model.enemies.assign([enemy(0, 27, 4.8)])
	model._apply_curse(0, 0, 4.8)
	var initial_gold: int = model.gold
	model.advance(1)
	check(model.killed == 1 and model.escaped == 0 and model.fortress_hp == 20 and model.gold == initial_gold + 3, "C-08 : mort par tick avant arrivée")
	check(model.curses.is_empty() and model.phase == "finished", "C-11 : pas d'attente des effets futurs")

	# La phase 2 retire un mort avant le choix des nouveaux tirs de la phase 3.
	model = fixture([5])
	model.enemies.assign([enemy(0, 3, 4.8), enemy(1, 2)])
	model._apply_curse(9, 0, 4.8)
	model.curses[0].next_at = 0.0
	model._resolve_instant()
	check(model.killed == 1 and model.shots.size() == 1 and model.shots[0].target_id == 1, "Mort par tick exclue de l'acquisition suivante")
	check(model.enemies[0].hp == 88, "Le nouveau tir touche le survivant")

	model = fixture()
	model.enemies.assign([enemy(0, 27.5)])
	model._apply_curse(0, 0, 4.8)
	model.advance(2)
	check(model.escaped == 1 and model.curses.is_empty() and model.gold == 600, "Arrivée : ticks futurs annulés, aucun or")

	model = fixture([5])
	model.enemies.assign([enemy(0, 3, 12)])
	model._resolve_instant()
	check(model.phase == "finished" and model.shots.size() == 1 and model.curses.is_empty(), "C-11 : fin sans attendre un trait visuel ni créer d'effet sur un mort")

	# Huit profils exécutés : déplacement, arrivée puis récompense après élimination.
	for type in range(Model.ENEMY_TYPES.size()):
		model = Model.new(false)
		model.spawn_schedule.assign([{"time": 0.0, "type": type}])
		model.start()
		var travel: float = 28.0 / Model.ENEMY_TYPES[type].speed
		model.advance(travel - 0.000001)
		check(model.escaped == 0, "Avant arrivée du type %d" % type)
		model.advance(0.000002)
		check(model.escaped == 1 and model.fortress_hp == maxi(0, 20 - Model.ENEMY_TYPES[type].fortress_damage), "Dégâts d'arrivée du type %d" % type)
		check(model.gold == 150 and close(model.elapsed, travel), "Pas de prime d'arrivée du type %d" % type)
		if type == 7:
			check(model.phase == "defeat", "Boss : arrivée fatale à 20 PV")
		model = Model.new(false)
		model.buy(0, 0)
		model.phase = "combat"
		model.spawned = 10
		model.enemies.assign([enemy(0, 3, 8, type)])
		model._resolve_instant()
		check(model.killed == 1 and model.gold == 100 + Model.ENEMY_TYPES[type].reward, "Récompense unique du type %d" % type)

	# C-01 et C-02 : cibles contrôlées tardives, aucun rattrapage des tirs manqués.
	model = Model.new(false)
	model.buy(0, 0)
	model.spawn_schedule.assign([{"time": 0.3, "type": 1}])
	model.start()
	model.advance(0.3)
	check(close(model.shots[0].time, 0.3) and close(model.defenders[0].ready_at, 1.3), "C-01 : premier tir immédiat à 0,3 s")
	model = Model.new(false)
	model.buy(0, 0)
	model.buy(1, 0)
	model.spawn_schedule.assign([{"time": 0.3, "type": 0}, {"time": 1.8, "type": 0}])
	model.start()
	model.advance(1.3)
	check(model.shots.size() == 2 and model.enemies.is_empty(), "C-02 : aucune cible au retour du délai")
	model.advance(0.5)
	check(model.shots.size() == 4 and close(model.shots[2].time, 1.8) and close(model.defenders[0].ready_at, 2.8), "C-02 : un seul tir par unité à 1,8 s")

	# C-04 : comparateur utilisé par rebonds et explosions en cas d'égalité.
	check(Model._secondary_priority({"squared": 0.25, "enemy": {"distance": 8.0, "id": 9}}, {"squared": 0.25, "enemy": {"distance": 7.0, "id": 1}}), "C-04 : progression avant ordre d'apparition")
	check(Model._secondary_priority({"squared": 0.25, "enemy": {"distance": 8.0, "id": 1}}, {"squared": 0.25, "enemy": {"distance": 8.0, "id": 9}}), "C-04 : ancienneté en dernier départage")
	model = Model.new(false)
	model.buy(0, 0)
	model.buy(1, 0)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 3.5, 8), enemy(1, 3, 40)])
	model._resolve_instant()
	check(model.shots.size() == 2 and model.enemies[0].id == 1 and model.enemies[0].hp == 40, "C-05 : tirs gaspillés sans transfert")

	model = Model.new(false)
	model.fortress_hp = 3
	model.spawn_schedule.assign([{"time": 0.0, "type": 3}, {"time": 0.0, "type": 3}])
	model.start()
	model.advance(40)
	check(model.fortress_hp == 0 and model.phase == "defeat" and model.escaped == 2, "C-09 : quatre dégâts simultanés, PV bornés à zéro")
	check(model.phase != "finished", "C-12 : défaite prioritaire sur fin de vague")
	model = Model.new(false)
	model.buy(0, 0)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 2.5 + sqrt(15.0), 8)])
	model._resolve_instant()
	check(model.killed == 1, "C-10 : portée principale inclusive à la borne exacte")

	# Intégration mêlant vitesses, groupes et malédictions : comparer toute la chronologie.
	var runs: Array = []
	for run_index in range(3):
		var run = Model.new(false)
		run.select_faction(1)
		run.gold = 225
		run.buy(0, 3)
		run.buy(1, 4)
		run.buy(2, 5)
		run.spawn_schedule.clear()
		for i in range(16):
			run.spawn_schedule.append({"time": i * 0.5, "type": i % 8})
		run.start()
		if run_index == 0:
			run.advance(200)
		else:
			while run.active:
				run.advance(float(run_index) / 60.0)
		runs.append(run)
	check(runs[0].event_log == runs[1].event_log and runs[1].event_log == runs[2].event_log, "Horde et huit types : chronologie identique à gros pas, ×1 et ×2")
	check(runs[0].gold == runs[2].gold and runs[0].fortress_hp == runs[2].fortress_hp, "Revenus et PV identiques aux deux vitesses")
	check(runs[0].curses.is_empty(), "Aucun effet persistant après fin de combat")

	model = Model.new(false)
	model.select_faction(1)
	model.buy(0, 3)
	model.buy(1, 4)
	model.start()
	model.advance(100)
	print("HORDE_REFERENCE kills=%d escaped=%d gold=%d hp=%d time=%.9f" % [model.killed, model.escaped, model.gold, model.fortress_hp, model.elapsed])
	print("HORDE_TESTS checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)
