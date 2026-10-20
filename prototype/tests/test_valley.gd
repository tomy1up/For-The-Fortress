extends SceneTree

const Model = preload("res://scripts/valley_model.gd")
var failures: int = 0
var checks: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func enemy(id: int, progress: float, hp: float = 100.0) -> Dictionary:
	return {"id": id, "spawn_time": -progress, "distance": progress, "hp": hp}

func fixture() -> RefCounted:
	var model = Model.new()
	model.phase = "combat"
	model.spawned = 10
	return model

func _initialize() -> void:
	var model = Model.new()
	var length: float = 0.0
	for i in range(Model.PATH_POINTS.size() - 1):
		length += Model.PATH_POINTS[i].distance_to(Model.PATH_POINTS[i + 1])
	check(length == 28.0 and Model.SLOTS.size() == 6, "Géométrie du Gué")
	var distances: Array[float] = [0, 4, 8, 13, 17, 22, 25, 28]
	for i in range(distances.size()):
		check(Model.position_at(distances[i]) == Model.PATH_POINTS[i], "Virage %d" % i)
	check(Model.position_at(-1) == Model.PATH_POINTS[0] and Model.position_at(40) == Model.PATH_POINTS[-1], "Bornes du chemin")
	# Longueurs de couverture calculées dans le GDD, section 19 (arrondi 0,01).
	var reference: Array = [[4.93, 5.85, 6.37, 7.4, 11.79], [4.06, 8.83, 9.87, 10.9, 12.42], [8.47, 13.35, 14.93, 17.17, 20.18], [4.06, 5.23, 6.34, 8.9, 13.62], [8.33, 12.61, 13.83, 16.1, 19.0], [7.1, 7.66, 8.21, 9.27, 10.82]]
	var radii: Array[float] = [3, 3.5, 4, 5, 6.5]
	for slot in range(Model.SLOTS.size()):
		for radius_index in range(radii.size()):
			var coverage: float = 0.0
			for window in Model.coverage_windows(Model.SLOTS[slot], radii[radius_index]):
				coverage += window.last - window.first
			check(absf(coverage - reference[slot][radius_index]) <= 0.006, "Couverture GDD E%d portée %s" % [slot + 1, radii[radius_index]])
	check(model.gold == 150 and model.fortress_hp == 20 and model.enemies.is_empty(), "État initial")
	check(not model.buy(-1, 0) and not model.buy(6, 0) and not model.buy(0, 3), "Paramètres d'achat invalides")
	check(model.gold == 150, "Échec d'achat sans débit")
	check(model.buy(0, 0) and model.gold == 100, "Archer à 50")
	check(not model.buy(0, 1) and model.gold == 100, "Emplacement occupé")
	check(model.buy(1, 0) and model.gold == 50, "Deuxième archer")
	check(not model.buy(2, 0) and model.gold == 50, "Troisième copie refusée")
	check(not model.buy(2, 1), "Or insuffisant")
	check(model.refund(0) == 35 and model.sell(0) and model.gold == 85, "Vente et libération de place")
	check(model.buy(2, 0) and model.gold == 35 and model.count_type(0) == 2, "Quota libéré immédiatement")
	check(not model.sell(0) and not model.sell(-1), "Ventes invalides sans crédit")
	model.reset()
	check(model.buy(0, 1) and model.buy(1, 1) and model.gold == 0, "Deux arbalétriers à 75")
	check(model.refund(0) == 52 and model.refund(1) == 52, "Vente arrondie par exemplaire")
	check(model.sell(0) and model.sell(1) and model.gold == 104, "Deux ventes rendent 104")
	model.reset()
	check(model.buy(0, 2) and model.gold == 50 and model.refund(0) == 70, "Mage à 100")
	model.reset()
	model.advance(100)
	check(model.phase == "preparation" and model.spawned == 0 and model.elapsed == 0, "Pas de combat avant lancement")
	check(model.start() and model.spawned == 1 and model.elapsed == 0, "Première apparition à t=0")
	check(not model.start() and not model.buy(0, 0) and not model.sell(0), "Transactions et relance bloquées en combat")
	model.advance(22.5)
	check(model.spawned == 10 and model.escaped == 0 and model.active, "Dixième apparition à 22,5 s")
	model.advance(5.5)
	check(model.escaped == 1 and model.fortress_hp == 19 and model.gold == 150, "Premier Pillard arrivé à 28 s sans prime")
	model.advance(100)
	check(model.phase == "finished" and model.elapsed == 50.5 and model.escaped == 10 and model.fortress_hp == 10, "Fin réelle après dernière arrivée")
	check(model.gold == 150 and model.killed == 0, "Aucune prime de fin de vague")
	check(not model.start(), "Pas de répétition gratuite de la vague")
	check(model.buy(0, 0) and model.sell(0), "Transactions possibles après la vague")
	var old_gold: int = model.gold
	model.advance(100)
	check(model.gold == old_gold and model.escaped == 10 and model.fortress_hp == 10, "Vague résolue une seule fois")
	model.reset()
	check(model.gold == 150 and model.fortress_hp == 20 and model.count_type(0) == 0 and model.shots.is_empty(), "Réinitialisation complète")

	# Les deux archers prennent leur décision sur le même état, même en sur-dégâts.
	model.buy(0, 0)
	model.buy(1, 0)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 3.0, 8.0)])
	model._resolve_instant()
	check(model.shots.size() == 2 and model.killed == 1 and model.gold == 53, "Tirs simultanés : une seule récompense")
	check(model.defenders[0].ready_at == 1 and model.defenders[1].ready_at == 1, "Délais indépendants des deux exemplaires")
	check(model.escaped == 0, "Un mort ne peut pas arriver")

	model.reset()
	model.buy(0, 0)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 3.0), enemy(1, 4.0)])
	model._resolve_instant()
	check(model.shots[0].target_id == 1 and model.enemies[1].hp == 92, "Cible la plus avancée")
	model.reset()
	model.buy(0, 0)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(8, 3.0), enemy(2, 3.0)])
	model._resolve_instant()
	check(model.shots[0].target_id == 2, "Égalité : apparition la plus ancienne")

	model.reset()
	model.buy(2, 2)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 10), enemy(1, 9.5), enemy(2, 9.2), enemy(3, 9), enemy(4, 9.1)])
	model._resolve_instant()
	check(model.enemies[0].hp == 73, "Mage : 27 dégâts principaux")
	check(absf(model.enemies[1].hp - 89.2) < 0.000001 and absf(model.enemies[2].hp - 89.2) < 0.000001, "Mage : deux victimes secondaires les plus proches à 10,8")
	check(model.enemies[3].hp == 100 and model.enemies[4].hp == 100, "Mage : rayon strict et plafond de deux")

	model.reset()
	model.buy(2, 2)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 10), enemy(1, 9)])
	model._resolve_instant()
	check(model.enemies[1].hp == 100, "Le rayon secondaire exclut la distance exactement égale à 1")
	model.reset()
	model.buy(2, 2)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 10), enemy(8, 9.5), enemy(2, 9.5, 10.8), enemy(1, 9.5, 10.8)])
	model._resolve_instant()
	check(model.killed == 2 and model.gold == 56, "Explosion : morts secondaires et prime unique")
	check(model.enemies.size() == 2 and model.enemies[1].id == 8 and model.enemies[1].hp == 100, "Secondaires à égalité : ordre d'apparition")

	model.reset()
	model.buy(5, 1)
	model.start()
	model.advance(19)
	var first_entry: float = 17.0 + 15.5 - sqrt(25.0 - 2.25) - 9.0
	check(absf(model.shots[0].time - first_entry) < 0.00000001, "Premier tir dès l'entrée exacte dans la portée")
	model.advance(3)
	check(model.shots.size() >= 2 and absf(model.shots[1].time - model.shots[0].time - 2.5) < 0.00000001, "Cadence de l'arbalétrier après entrée à portée")
	model.reset()
	model.buy(5, 1)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 26, 100)])
	model._resolve_instant()
	check(model.enemies[0].hp == 76, "Arbalétrier : exactement 24 dégâts")
	model.reset()
	model.buy(0, 0)
	model.start()
	model.advance(1.5)
	check(model.shots.size() == 2 and model.shots[0].time == 0 and model.shots[1].time == 1, "Cadence sans délai initial et sans tir supplémentaire")

	model.reset()
	model.buy(5, 1)
	model.phase = "combat"
	model.spawned = 10
	model.enemies.assign([enemy(0, 28, 24)])
	model._resolve_instant()
	check(model.killed == 1 and model.escaped == 0 and model.fortress_hp == 20 and model.gold == 78, "Tir mortel avant l'arrivée simultanée")
	model = fixture()
	model.fortress_hp = 1
	model.enemies.assign([enemy(0, 28, 40), enemy(1, 28, 40)])
	model._resolve_instant()
	check(model.phase == "defeat" and model.fortress_hp == 0 and model.escaped == 2 and model.gold == 150, "Défaite prioritaire et PV bornés à zéro")

	# Comparer les résultats et la chronologie complète entre gros et petits pas.
	var coarse = Model.new()
	var normal = Model.new()
	var fast = Model.new()
	for run in [coarse, normal, fast]:
		run.buy(0, 0)
		run.buy(1, 1)
		run.start()
	coarse.advance(100)
	while normal.active:
		normal.advance(1.0 / 60.0)
	while fast.active:
		fast.advance(2.0 / 60.0)
	check(coarse.event_log == normal.event_log and normal.event_log == fast.event_log, "Chronologie identique à gros pas, ×1 et ×2")
	check(coarse.gold == normal.gold and normal.gold == fast.gold and coarse.fortress_hp == fast.fortress_hp, "Mêmes revenus et PV aux deux vitesses")
	check(coarse.spawned == 10 and coarse.killed + coarse.escaped == 10 and coarse.enemies.is_empty(), "Tous les ennemis résolus")
	check(coarse.gold == 25 + coarse.killed * 3 and coarse.fortress_hp == 20 - coarse.escaped, "Conservation de l'économie et des PV")
	print("REFERENCE E1 archer + E2 arbaletrier: kills=%d escaped=%d gold=%d hp=%d time=%.9f shots=%d" % [coarse.killed, coarse.escaped, coarse.gold, coarse.fortress_hp, coarse.elapsed, coarse.shots.size()])
	print("VALLEY_TESTS checks=%d failures=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)
