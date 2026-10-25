extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Metrics = preload("res://scripts/combat_metrics.gd")
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func near(a: float, b: float) -> bool: return absf(a-b) < 0.000001
func _initialize() -> void: call_deferred("run_checks")
func fixture(types: Array, enemies: Array) -> RefCounted:
	var m = Model.new(false); m.select_faction(0 if types[0] < 3 else 1)
	for slot in range(types.size()):
		m.buy(slot,types[slot])
		m.defenders[slot].windows = [{"first":0.0,"last":28.0}]
	m.spawn_schedule.clear()
	for type in enemies: m.spawn_schedule.append({"type":type,"time":0.0})
	return m
func run_checks() -> void:
	var m = fixture([0,0],[1]); m.start(); m.advance(100)
	var rows: Array = m.wave_history[0].performance
	check(rows.size() == 2 and rows[0].attacks == 3 and rows[1].attacks == 3,"Deux archers tirent simultanément jusqu’à la mort")
	check(near(rows[0].direct_hp,20) and near(rows[1].direct_hp,20),"Les dégâts excédentaires ne sont pas comptés")
	var saved: Array = m.wave_history.duplicate(true); m.advance(100)
	check(m.wave_history == saved,"Pas de nouvelle contribution après résolution")
	m = fixture([0,1],[2]); m.start()
	rows = m.wave_history[0].performance
	check(near(rows[0].direct_hp,6) and near(rows[1].direct_hp,18),"PV restants partagés à proportion 8/24, sans ordre privilégié")
	check(rows[0].attacks == 1 and rows[1].attacks == 1 and m.killed == 1,"Mesure sans double élimination ni attaque supplémentaire")
	# Vente et rachat au même emplacement : deux recrues distinctes dans le bilan.
	var old_id: int = m.defenders[0].instance_id
	m.sell(0); m.buy(0,0); var new_id: int = m.defenders[0].instance_id
	m.prepare_next_wave(); m.spawn_schedule.assign([{"type":2,"time":0.0}]); m.start(); m.advance(100)
	rows = Report.performance(m)
	check(rows.size() == 3 and rows[0].instance_id == old_id and rows[2].instance_id == new_id,"Les recrues ne sont pas fusionnées par emplacement ou type")
	check(rows[0].waves == [1] and rows[2].waves == [2] and rows[1].waves == [1,2],"Vagues propres à chaque instance")
	check(not rows[0].present_at_end and rows[2].present_at_end,"Unité vendue conservée avec son statut")
	check(near(rows[1].direct_hp,36),"Une recrue conservée cumule ses contributions")
	var report: Dictionary = Report.build(m)
	check(report.schema_version == 2 and report.performance == rows,"Schéma de rapport enrichi")
	var decoded: Dictionary = JSON.parse_string(JSON.stringify(report))
	check(near(decoded.performance[0].direct_hp,6) and Report.markdown(decoded).contains("Activité des défenseurs"),"Mesures conservées après passage JSON et Markdown")
	report.performance[0].direct_hp = -1
	check(near(m.wave_history[0].performance[0].direct_hp,6),"Rapport indépendant de l’historique")
	# Deux malédictions qui tuent avant les tirs de la seconde seconde.
	m = fixture([5],[3]); m.start()
	m.enemies[0].hp = 2.0 # Situation contrôlée à faible vie restante.
	m.advance(1)
	rows = m.wave_history[0].performance
	check(rows[0].attacks == 1 and rows[0].curse_ticks == 1 and near(rows[0].curse_hp,2),"Malédiction létale : seul le déclenchement réel est compté")
	check(near(rows[0].direct_hp,12) and near(rows[0].boss_hp,0),"Dégâts directs distincts de la malédiction")
	for type in [2,3,4]:
		m = fixture([type],[0,0]); m.start(); m.advance(100)
		rows = m.wave_history[0].performance
		var expected: float = [10.8,8.0,9.6][type-2]
		check(rows[0].attacks == 2 and rows[0].secondary_hits == 1,"Explosion ou rebond distinct d’une attaque principale")
		check(near(rows[0].secondary_hp,expected) and near(rows[0].direct_hp,24-expected),"PV réellement retirés par les deux composantes")
		check(near(rows[0].direct_hp+rows[0].secondary_hp,24),"Somme limitée à la vie des deux ennemis")
	# Un boss entièrement éliminé par une seule unité : 600 PV, pas plus.
	m = fixture([1],[7]); m.gold = 1000; m.upgrade(0); m.upgrade(0); m.upgrade(0,0); m.start(); m.advance(1000)
	rows = m.wave_history[0].performance
	check(near(rows[0].boss_hp,600) and near(rows[0].direct_hp,600),"Dégâts du boss inclus, sans excédent létal")
	# Égalité temporelle des ticks : mesure symétrique et indépendante des sources.
	var metrics: Array = Metrics.create([{"instance_id":1},{"instance_id":2}])
	Metrics.credit(metrics,[{"id":7,"hp":6.0,"type":1}],{7:9.6},[{"source_id":1,"enemy_id":7,"component":"curse","amount":4.8},{"source_id":2,"enemy_id":7,"component":"curse","amount":4.8}])
	check(near(metrics[0].curse_hp,3) and near(metrics[1].curse_hp,3) and metrics[0].curse_ticks == 1,"Deux sources simultanées partagent les PV sans priorité")
	check(Metrics.summarize([{"wave":1}]).is_empty(),"Historique ancien sans mesures accepté")
	m = fixture([0],[2]); m.defenders[0].windows = []; m.start(); m.advance(100)
	check(m.wave_history[0].performance[0].attacks == 0 and near(m.wave_history[0].performance[0].direct_hp,0) and m.escaped == 1,"Unité sans cible : zéro activité, sans inventer de dégâts")
	for faction in range(2):
		var simulations: Array = []
		for step in [1000.0,0.07]:
			var simulation = Model.new(); simulation.select_faction(faction); simulation.gold = 10000
			for slot in range(3):
				simulation.buy(slot,faction*3+slot)
				simulation.upgrade(slot); simulation.upgrade(slot); simulation.upgrade(slot,0)
			simulation.wave = 8; simulation.spawn_schedule = Model.Campaign.schedule(8)
			simulation.start()
			while simulation.active: simulation.advance(step)
			simulations.append(simulation)
		check(simulations[0].event_log == simulations[1].event_log and simulations[0].gold == simulations[1].gold,"Les mesures ne changent pas la chronologie à grand ou petit pas")
		check(simulations[0].wave_history[0].performance == simulations[1].wave_history[0].performance,"Mesures identiques indépendamment des images affichées")
	# Deux campagnes normales : aucun changement de résultat ou de budget.
	for faction in range(2):
		m = Model.new(); m.select_faction(faction); m.rng.seed = 42
		m.buy(0,faction*3); m.buy(1,faction*3+1)
		for wave in range(1,11):
			if wave >= 4 and m.defenders[2].is_empty(): m.buy(2,faction*3+2)
			if wave >= 5:
				for slot in [0,1,2]: m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
			m.start(); m.advance(1000)
			var record: Dictionary = m.wave_history[-1]
			check(record.performance.size() == record.army.size(),"Chaque défenseur présent possède son relevé, même sans attaque")
			if wave == 10: break
			if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
			m.prepare_next_wave()
		check(m.phase == "victory" and m.fortress_hp == [14,12][faction] and m.gold == [192,189][faction],"Références financées normalement inchangées")
		rows = Report.performance(m)
		var boss: float = 0
		for row in rows:
			boss += row.boss_hp
			check(row.attacks > 0 and row.direct_hp > 0 and row.curse_hp >= 0 and row.secondary_hp >= 0,"Compteurs effectifs et positifs")
		check(near(boss,600),"Les contributions au boss totalisent ses 600 PV")
		var scene = Main.new(); root.add_child(scene); scene.set_process(false)
		scene.model = m; scene.map_view.model = m; scene.choosing_faction = false
		scene._update_interface(); scene._show_run_summary()
		var before: String = JSON.stringify(Report.build(m))
		check(scene.summary_wave_content.visible and not scene.summary_performance_content.visible,"Bilan ouvre les vagues par défaut")
		scene.summary_tabs[1].pressed.emit()
		check(scene.summary_performance_content.visible and not scene.summary_wave_content.visible and scene.performance_rows.size() == 3,"Onglet défenseurs correctement renseigné")
		check(scene.performance_list.get_child_count() == 3 and scene.summary_subtitle.text.contains("contributions"),"Tableau et aide adaptés au nouvel onglet")
		scene.summary_tabs[0].pressed.emit(); scene.summary_tabs[1].pressed.emit(); scene._set_summary_tab(9)
		check(JSON.stringify(Report.build(m)) == before and scene.summary_tab == 1,"Consultation sans mutation ni tirage, onglet invalide rejeté")
		scene._close_run_summary(); scene._reset()
		check(scene.summary_tab == 0 and scene.performance_rows.is_empty() and m.wave_history.is_empty(),"Nouvelle partie efface les compteurs")
		scene.free()
	# Historique imposé pour contrôler un tableau de 60 recrues, sans simuler une économie.
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	for wave in range(1,11):
		var army: Array = []
		for slot in range(6): army.append({"slot":slot,"type":int(slot/2),"level":1,"branch":-1,"paid":50,"instance_id":wave*10+slot})
		scene.model.wave_history.append({"wave":wave,"performance":Metrics.create(army),"result":"cleared","killed":0,"escaped":0,"hp_lost":0,"income":0,"seconds":1.0,"planned":0,"spawned":0,"remaining":0,"hp_before":20,"hp_after":20,"army":army,"bonuses":[]})
	scene.model.phase = "victory"; scene.model.wave = 10
	scene._show_run_summary(); scene._set_summary_tab(1)
	await process_frame; await process_frame
	var scroll: ScrollContainer = scene.performance_list.get_parent()
	check(scene.performance_rows.size() == 60 and scroll.get_v_scroll_bar().max_value > scroll.get_v_scroll_bar().page,"Recrues nombreuses accessibles par défilement")
	scene._close_run_summary(); scene._show_run_summary()
	check(scene.performance_list.get_child_count() == 60,"Relire le bilan ne duplique pas les lignes")
	scene.free()
	print("COMBAT_METRICS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
