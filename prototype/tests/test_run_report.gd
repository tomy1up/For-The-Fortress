extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Report = preload("res://scripts/run_report.gd")
const Main = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func replay(data: Dictionary) -> RefCounted:
	var copy = Model.new()
	copy.rng.seed = int(data.initial_rng_seed)
	copy.rng.state = int(data.initial_rng_state)
	for action in data.actions:
		match action.kind:
			"faction": check(copy.select_faction(int(action.faction)),"Rejeu : faction")
			"buy": check(copy.buy(int(action.slot),int(action.type)),"Rejeu : achat")
			"upgrade": check(copy.upgrade(int(action.slot),int(action.branch)),"Rejeu : amélioration")
			"sell": check(copy.sell(int(action.slot)),"Rejeu : vente")
			"wave_prepare": check(copy.prepare_next_wave(),"Rejeu : préparation")
			"wave_start":
				check(copy.start(),"Rejeu : lancement")
				copy.advance(1000)
			"bonus_choice":
				var offered: Array[int] = []
				for code in action.offered: offered.append(int(code))
				check(copy.bonus_offer == offered,"Rejeu : les trois offres restent identiques")
				check(copy.choose_bonus(int(action.chosen)),"Rejeu : choix")
	return copy
func run_checks() -> void:
	for faction in range(2):
		var m = Model.new(); m.select_faction(faction); m.rng.seed = 9223372036854775000
		var seed_value: String = str(m.rng.seed)
		var state_value: String = str(m.rng.state)
		m.buy(0,faction*3); m.buy(1,faction*3+1)
		var count: int = m.action_history.size()
		check(not m.buy(0,faction*3) and not m.buy(2,(1-faction)*3) and not m.upgrade(5),"Actions invalides rejetées")
		check(count == m.action_history.size(),"Pas de fausses décisions dans le journal")
		for wave in range(1,11):
			if wave >= 4 and m.defenders[2].is_empty(): m.buy(2,faction*3+2)
			if wave >= 5:
				for slot in [0,1,2]: m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
			check(m.start(),"Départ normal")
			m.advance(1000)
			if m.phase in ["victory","defeat"]: break
			if m.phase == "bonus":
				var offer: Array = m.bonus_offer.duplicate()
				m.choose_bonus(offer[0])
				check(m.action_history[-1].offered == offer,"Les offres restent présentes après le choix")
			m.prepare_next_wave()
		check(m.initial_rng_seed == seed_value and m.initial_rng_state == state_value,"État initial 64 bits sans tirage supplémentaire")
		var before: Array = [m.action_history.duplicate(true),m.rng.state,m.wave_history.duplicate(true),m.gold,m.phase]
		var report: Dictionary = Report.build(m)
		var decoded: Dictionary = JSON.parse_string(JSON.stringify(report))
		check(decoded.initial_rng_state == state_value and decoded.initial_rng_seed == seed_value,"JSON conserve exactement les entiers 64 bits sous forme de texte")
		var copy = replay(decoded)
		check(copy.phase == m.phase and copy.gold == m.gold and copy.fortress_hp == m.fortress_hp and copy.total_killed == m.total_killed and copy.total_escaped == m.total_escaped,"Rejeu JSON : résultat et économie identiques")
		check(copy.bonuses == m.bonuses and copy.rng.state == m.rng.state and copy.action_history == m.action_history,"Rejeu JSON : décisions et tirages identiques")
		check(Report.markdown(report).contains("Bonus proposés") and Report.markdown(report).contains("Choix parmi"),"Rapport lisible : offres et choix")
		for bonus in report.bonuses: check(bonus.description == Model.Campaign.bonus_description(int(bonus.index),faction),"Descriptions cloisonnées par faction")
		var exported: Dictionary = Report.export_local(m,"user://test_reports")
		check(exported.ok,"Export local réussi")
		if exported.ok:
			for name in ["rapport.json","rapport.md"]:
				check(FileAccess.file_exists(exported.folder.path_join(name)),"Les deux fichiers existent")
			var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(exported.folder.path_join("rapport.json")))
			check(saved.actions.size() == m.action_history.size(),"Journal complet sur disque")
			var second: Dictionary = Report.export_local(m,"user://test_reports")
			check(second.ok and second.folder != exported.folder,"Deux exports ne s’écrasent pas")
			for folder in [exported.folder,second.folder]:
				for name in ["rapport.json","rapport.md"]: DirAccess.remove_absolute(folder.path_join(name))
				DirAccess.remove_absolute(folder)
		var blocker: String = "user://report_blocker.txt"
		var file := FileAccess.open(blocker,FileAccess.WRITE); file.store_string("test"); file.close()
		check(not Report.export_local(m,blocker).ok,"Erreur de dossier remontée sans faux succès")
		DirAccess.remove_absolute(blocker)
		check([m.action_history,m.rng.state,m.wave_history,m.gold,m.phase] == before,"Construction et export sans mutation ni tirage")
		report.actions[0]["gold"] = -999
		check(m.action_history[0].gold != -999,"Instantané indépendant du modèle")
		m.reset()
		check(m.action_history.is_empty() and m.initial_rng_seed.is_empty() and m.initial_rng_state.is_empty(),"Nouvel essai efface le journal")
		check(not Report.export_local(m).ok,"Pas d’export avant fin de partie")
	# Identité conservée après vente et rachat ; refus sans effet sur le journal.
	var m = Model.new(); m.buy(0,0); var id: int = m.defenders[0].instance_id
	m.sell(0); m.buy(0,0)
	check(m.action_history[1].instance_id == id and m.action_history[1].received == 35 and m.action_history[2].instance_id != id,"Vente à 70 % et nouvelle recrue distincte")
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	scene.model.start(); scene.model.advance(1000); scene.model.prepare_next_wave(); scene.model.start(); scene.model.advance(1000)
	scene._update_interface(); scene._show_run_summary()
	check(scene.report_button.visible and scene.report_button.text == "Exporter le rapport" and scene.report_status.mouse_filter == Control.MOUSE_FILTER_STOP,"Accès à l’export et aux détails au survol depuis le bilan de défaite")
	scene.report_folder = "test"; scene.report_status.text = "test"
	scene._close_run_summary(); scene._reset()
	check(scene.report_folder.is_empty() and scene.report_status.text.is_empty() and scene.report_button.text == "Exporter le rapport","Nouvel essai ne réutilise pas le précédent rapport")
	scene.free()
	print("RUN_REPORT_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
