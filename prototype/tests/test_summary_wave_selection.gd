extends SceneTree
const Main = preload("res://scripts/main.gd")
const Sample = preload("res://tests/test_campaign_sample.gd")
const Report = preload("res://scripts/run_report.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.meta_profile.data])
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		scene.meta_profile = Profile.new("")
		Sample.play(scene.model,Sample.POSITIONS[0]);scene._show_run_summary()
		check(scene.model.phase == "victory" and scene.summary_selected_wave == 0,"Le bilan reste initialement sur le résumé et la composition finale")
		var before: String = signature(scene)
		scene._set_summary_tab(0)
		for number in range(1,11):
			scene.summary_rows[number-1].pressed.emit()
			var record: Dictionary = scene.model.wave_history[number-1]
			check(scene.summary_selected_wave == number and scene.summary_rows.filter(func(row): return row.button_pressed).size() == 1,"Une seule vague est repérée à chaque clic")
			check(scene.summary_army_heading.text == "Défense au départ · Vague %d" % number and scene.summary_bonus_heading.text.ends_with(str(number)),"Les deux listes identifient le moment historique")
			var army: Array[String] = scene._army_description(record.army)
			for index in range(6): check(scene.summary_army[index].text == (army[index] if index < army.size() else "Aucun défenseur" if index == 0 else ""),"La liste contient les unités et niveaux réellement présents au départ de la vague")
			for index in range(3): check(scene.summary_bonuses[index].text == (scene.Model.Campaign.BONUSES[record.bonuses[index]].name if index < record.bonuses.size() else "Aucun bonus" if index == 0 else ""),"Les bonus sont ceux actifs à la vague, sans réattribuer les choix ultérieurs")
			check(not scene.summary_final_button.disabled,"La composition finale reste accessible après une inspection historique")
			scene._set_summary_tab(2);scene._set_summary_tab(0)
			check(scene.summary_selected_wave == number,"Changer d’onglet préserve la vague consultée")
			check(signature(scene) == before,"Consulter les relevés ne modifie ni rapport, tirages, gains ou profil")
		scene.summary_final_button.pressed.emit()
		check(scene.summary_selected_wave == 0 and scene.summary_final_button.disabled and scene.summary_rows.all(func(row): return not row.button_pressed),"Retour explicite à la défense finale, sans sélection de vague trompeuse")
		check(scene.summary_army_heading.text == "Défense finale" and scene.summary_bonus_heading.text == "Bonus choisis","Les légendes distinguent la composition finale du départ d’une vague")
		var max_loss: int = 0;var first_max: int = 0
		for record in scene.model.wave_history:
			if record.hp_lost > max_loss: max_loss = record.hp_lost;first_max = record.wave
		scene._set_summary_tab(2);scene.summary_loss_button.pressed.emit()
		if max_loss > 0:
			check(scene.summary_tab == 0 and scene.summary_selected_wave == first_max,"L’accès aux pertes ouvre la première vague ayant subi la plus forte perte")
			check(scene.get_viewport().gui_get_focus_owner() == scene.summary_rows[first_max-1],"Le clavier retrouve la vague désignée")
		else:
			check(scene.summary_loss_button.disabled and scene.summary_selected_wave == 0,"Une victoire sans perte ne fabrique pas une vague problématique")
			scene._set_summary_tab(0)
		scene.summary_rows[0].grab_focus()
		check(scene.summary_selected_wave == 1,"La navigation au clavier met à jour le contexte comme le clic")
		scene._select_summary_wave(11);check(scene.summary_selected_wave == 1,"Un numéro absent ne remplace pas les informations courantes")
		check(signature(scene) == before,"Les liens d’analyse restent en lecture seule")
		scene.free()
		# Défaite réelle, égalité de pertes et huit vagues non jouées.
		scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		scene.meta_profile = Profile.new("")
		for wave in range(2):
			scene.model.start();scene.model.advance(1000)
			if wave == 0: scene.model.prepare_next_wave()
		scene._show_run_summary();before = signature(scene)
		check(scene.summary_loss_button.text.ends_with("Vague 1") and scene.summary_loss_note.text.contains("vagues 1, 2"),"Les égalités restent annoncées, l’accès direct choisit la première chronologiquement")
		scene.summary_loss_button.pressed.emit()
		check(scene.summary_selected_wave == 1 and scene.summary_army[0].text == "Aucun défenseur","Une défense absente est explicitement indiquée")
		for index in range(2,10): check(scene.summary_rows[index].disabled,"Les vagues non jouées ne sont pas sélectionnables")
		scene._select_summary_wave(10);check(scene.summary_selected_wave == 1 and signature(scene) == before,"Un relevé manquant ne crée ni contexte fictif ni effet de jeu")
		for record in scene.model.wave_history: record.hp_lost = 0
		scene._populate_essential_summary();check(scene.summary_loss_button.disabled and scene.summary_loss_button.text == "Aucune perte à examiner","Sans perte le raccourci est désactivé")
		scene.model.wave_history.clear();scene._populate_essential_summary()
		check(scene.summary_loss_button.disabled and scene.summary_loss_button.text == "Aucun relevé à examiner","Un relevé absent n’est pas présenté comme une partie sans perte")
		scene.free()
	print("SUMMARY_WAVE_SELECTION_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
