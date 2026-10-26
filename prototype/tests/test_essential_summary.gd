extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders])
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		scene.model.start();scene.model.advance(1000);scene.model.prepare_next_wave();scene.model.start();scene.model.advance(1000)
		var before: String = signature(scene)
		scene._show_run_summary()
		check(scene.summary_tab == 2 and scene.summary_essential_content.visible and not scene.summary_wave_content.visible and not scene.summary_performance_content.visible,"Le premier bilan présente l’essentiel")
		check(scene.summary_subtitle.text.contains("Défaite à la vague 2") and scene.summary_subtitle.text.contains("simulées"),"Résultat et temps simulé explicites")
		check(scene.summary_key_values[0].text == "0 / 20 PV" and scene.summary_key_values[1].text == "20" and scene.summary_key_values[2].text == "0 or","Chiffres issus des compteurs réels, ennemis restants exclus des passés")
		check(scene.summary_loss_note.text.contains("20 PV perdus") and scene.summary_loss_note.text.contains("Première perte : vague 1") and scene.summary_loss_note.text.contains("vagues 1, 2 (10 PV chacune)"),"Pertes et égalités déduites des relevés, sans choisir arbitrairement une seule vague")
		check(scene.summary_boss_note.text == "Vague 10 non atteinte.","Aucun boss prétendument affronté avant sa vague")
		for index in [0,1,2]:
			scene.summary_tabs[index].pressed.emit()
			check(scene.summary_tab == index and [scene.summary_wave_content.visible,scene.summary_performance_content.visible,scene.summary_essential_content.visible].count(true) == 1,"Un seul contenu visible par onglet")
		check(signature(scene) == before,"Lire les trois vues ne réécrit ni rapport, RNG ou défense")
		# Contrôle d’agrégation : un maximum augmenté ne réécrit pas les pertes passées.
		scene.model.max_hp = 24;scene._populate_essential_summary()
		check(scene.summary_key_values[0].text == "0 / 24 PV" and scene.summary_loss_note.text.contains("20 PV perdus"),"Le total historique ne devient pas maximum moins PV restants")
		scene.model.wave_history.clear();scene._populate_essential_summary()
		check(scene.summary_loss_note.text == "Aucun relevé de vague disponible.","Absence de relevé distincte d’une défense sans perte")
		scene._close_run_summary();scene._reset()
		check(scene.summary_tab == 2 and not scene.summary_panel.visible,"Nouvel essai prêt pour un premier bilan essentiel")
		scene.queue_free();await process_frame
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		scene._prepare_campaign_capture("victory");scene._show_run_summary()
		var lost: int = 0
		for record in scene.model.wave_history: lost += record.hp_lost
		check(scene.model.phase == "victory" and scene.summary_subtitle.text.contains("Dix vagues terminées"),"Victoire issue d’une vraie campagne de référence")
		check(scene.summary_loss_note.text.contains(str(lost)+" PV perdus") and scene.summary_boss_note.text == "Boss éliminé.","Pertes et boss conformes à la campagne")
		var font: Font = scene.summary_loss_note.get_theme_font("font")
		for line in scene.summary_loss_note.text.split("\n"):
			check(font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x <= scene.summary_loss_note.size.x,"Les moments clés tiennent sans défilement")
		scene.model.wave_history[0].hp_lost = 0
		# Vue vide de pertes, sans prétendre qu’un relevé manquant vaut zéro.
		for record in scene.model.wave_history: record.hp_lost = 0
		scene._populate_essential_summary()
		check(scene.summary_loss_note.text == "Aucun PV perdu dans les vagues relevées.","Cas sans perte clairement décrit")
		scene.queue_free();await process_frame
	print("ESSENTIAL_SUMMARY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
