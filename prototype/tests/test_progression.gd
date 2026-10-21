extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func close(a: float, b: float) -> bool:
	return absf(a-b) < 0.00000001
func fixture(type: int) -> RefCounted:
	var m = Model.new(false)
	m.select_faction(0 if type < 3 else 1)
	m.gold = 1000
	m.buy(0,type)
	return m
func enemy(id: int, progress: float) -> Dictionary:
	var e: Dictionary = Model.make_enemy(id,1,0)
	e.spawn_time = -progress
	e.distance = progress
	e.hp = 1000.0
	return e
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var expected: Array = [
		[39,1.5,5,0,0,1,0], [19.5,0.6,3.5,0,0,1,0],
		[117,3,5,0,0,1,0], [78,2.5,6.5,0,0,1,0],
		[110,2.5,3.5,22,2,1,0], [70,2.5,3.5,28,4,1.3,0],
		[65,2,3.5,16.25,1,1,0], [46,2,3.5,23,3,1,0],
		[104,2.5,3,26,3,1,0], [65,2.5,3,26,5,1.4,0],
		[58.5,2,4.5,0,0,1,9.75], [26,2,4.5,0,0,1,29.25]]
	var fields: Array[String] = ["damage","interval","range","secondary_damage","secondary_cap","radius","curse_damage"]
	for type in range(6):
		for level in range(1,5):
			var stats: Dictionary = Model.stats_for(type,level)
			var mult: float = [1.0,1.5,2.25,3.25][level-1]
			for field in ["damage","secondary_damage","curse_damage"]:
				check(close(stats[field],Model.ROSTER[type].get(field,0)*mult),"Multiplicateur depuis la base")
			check(stats.interval == Model.ROSTER[type].interval and stats.range == Model.ROSTER[type].range,"Cadence et portée avant branche")
		for branch in range(2):
			var m = fixture(type)
			check(not m.upgrade(0,branch),"Branche refusée avant N4")
			check(m.upgrade(0) and m.upgrade(0),"N2 puis N3")
			var before: int = m.gold
			check(not m.upgrade(0) and not m.upgrade(0,2) and m.gold == before and m.defenders[0].level == 3,"N4 atomique")
			check(m.upgrade(0,branch) and m.defenders[0].branch == branch,"Choix de branche")
			var stats: Dictionary = m.get_stats(0)
			for i in range(fields.size()):
				check(close(stats[fields[i]],expected[type*2+branch][i]),"Statistique finale branche %d champ %s" % [type*2+branch,fields[i]])
			check(m.defenders[0].paid == Model.ROSTER[type].price+300 and m.gold == 1000-m.defenders[0].paid,"Historique des dépenses")
			check(not m.upgrade(0,1-branch),"Branche définitive et plafond N4")
			check(m.defenders[0].windows == Model.coverage_windows(Model.SLOTS[0],stats.range),"Portée recalculée")
			m.phase = "combat"
			m.spawned = 10
			m.enemies.assign([enemy(0,3),enemy(1,2.8),enemy(2,2.6),enemy(3,2.4),enemy(4,2.2),enemy(5,2.0),enemy(6,1.8)])
			m._resolve_instant()
			check(close(m.enemies[0].hp,1000-stats.damage),"Dégâts principaux appliqués")
			check(close(m.defenders[0].ready_at,stats.interval),"Cadence appliquée")
			if type in [2,3,4]:
				check(m.shots[0].secondary.size() == stats.secondary_cap,"Plafond de victimes appliqué")
				for i in range(1,int(stats.secondary_cap)+1):
					check(close(m.enemies[i].hp,1000-stats.secondary_damage),"Secondaire exact sans atténuation")
			if type == 5:
				m.defenders[0].ready_at = INF
				m.advance(2)
				check(close(m.enemies[0].hp,1000-stats.damage-2*stats.curse_damage),"Deux ticks spécialisés")
			m.phase = "finished"
			var gold_before: int = m.gold
			check(m.sell(0) and m.gold-gold_before == [245,262,280][type % 3],"Remboursement global arrondi")
			check(m.buy(0,type) and m.defenders[0].level == 1 and m.defenders[0].instance_id == 1,"Rachat neuf N1")
		var m = fixture(type)
		m.gold = 49
		check(not m.upgrade(0) and m.gold == 49 and m.defenders[0].level == 1,"Fonds insuffisants sans mutation")
		m.gold = 1000
		m.phase = "combat"
		check(not m.upgrade(0) and m.defenders[0].paid == Model.ROSTER[type].price,"Verrou combat")
		m.phase = "preparation"
		m.upgrade(0); m.upgrade(0); m.upgrade(0,0)
		check(m.buy(1,type),"Deuxième copie")
		m.gold = 1000
		m.upgrade(1); m.upgrade(1); m.upgrade(1,1)
		check(m.defenders[0].branch == 0 and m.defenders[1].branch == 1 and not m.buy(2,type),"Branches indépendantes, quota commun")
	var m = fixture(3)
	m.upgrade(0); m.upgrade(0); m.upgrade(0,1)
	m.phase = "combat"; m.spawned = 10
	m.enemies.assign([enemy(0,3),enemy(1,2.2),enemy(2,1.4),enemy(3,0.6)])
	m._resolve_instant()
	check(m.shots[0].secondary.size() == 3 and m.enemies[3].hp == 977,"Chaîne successive de trois rebonds sans revisite")
	m = fixture(3); m.upgrade(0); m.upgrade(0); m.upgrade(0,1)
	m.phase = "combat"; m.spawned = 10
	m.enemies.assign([enemy(0,3),enemy(1,2)])
	m._resolve_instant()
	check(m.shots[0].secondary.is_empty(),"Distance exactement 1 exclue")
	m = Model.new(false); m.buy(0,0); m.upgrade(0)
	check(m.gold == 50 and not m.upgrade(0),"Budget normal inchangé")
	for type in range(6):
		var scene = Main.new()
		root.add_child(scene); scene.set_process(false)
		scene._choose_faction(0 if type < 3 else 1)
		scene.model.gold = 1000; scene.selected = 0
		scene._buy(type % 3); scene._upgrade(); scene._upgrade()
		var before: int = scene.model.gold
		scene._upgrade()
		check(scene.pending_slot == 0 and scene.specialisation_panel.visible and scene.model.gold == before and scene.model.defenders[0].level == 3,"Dialogue sans débit")
		check(scene.specialisation_names[0].text.contains(Model.stats_for(type,4,0).branch_name) and scene.specialisation_names[1].text.contains(Model.stats_for(type,4,1).branch_name),"Deux noms affichés")
		scene._start(); scene._buy(0); scene._sell(); scene._reset()
		check(not scene.model.active and scene.model.gold == before and scene.model.defenders[0].level == 3 and not scene.choosing_faction,"Actions derrière le dialogue bloquées")
		scene.specialisation_cancel.pressed.emit()
		check(scene.pending_slot == -1 and not scene.specialisation_panel.visible and scene.model.gold == before and scene.model.defenders[0].level == 3,"Annuler conserve N3 et l'or")
		scene._upgrade(); scene.specialisation_buttons[1].pressed.emit()
		check(scene.model.gold == before-150 and scene.model.defenders[0].branch == 1 and scene.pending_slot == -1,"Confirmation débite une fois")
		check(scene.title_label.text.contains(Model.stats_for(type,4,1).branch_name) and scene.upgrade_button.disabled,"Branche inspectable et plafond visible")
		scene._choose_branch(0)
		check(scene.model.gold == before-150,"Double confirmation sans effet")
		scene.free()
	var scene = Main.new()
	root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	scene.model.gold = 1000; scene.selected = 0
	scene._buy(0); scene._upgrade(); scene._upgrade(); scene._upgrade()
	scene.model.sell(0); scene.model.buy(0,0)
	var remaining: int = scene.model.gold
	scene._choose_branch(0)
	check(scene.pending_slot == -1 and scene.model.defenders[0].level == 1 and scene.model.gold == remaining,"Confirmation périmée ne modifie pas le remplaçant")
	scene.free()
	print("PROGRESSION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
