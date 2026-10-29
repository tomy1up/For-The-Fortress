extends SceneTree
const Main = preload("res://scripts/main.gd")
const Talents = preload("res://scripts/meta_talents.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var configurations: Array = [Talents.empty_ranks(),[5,3,2,1,0,5,3,2,1,0,5,3,2,1,0],[3,1,0,3,0,1,3,1,0]]
	for faction in range(2):
		for ranks in configurations:
			var before: String = JSON.stringify(ranks)
			var data: Dictionary = Talents.loadout_summary(faction,ranks)
			check(data.points == Talents.spent(ranks) and data.hp == Talents.extra_hp(faction,ranks),"Résumé fidèle au total de points et aux PV permanents")
			var counted: int = 0
			for tree in data.trees:
				for node in tree.nodes: counted += node.rank
			check(counted == data.points and data.trees.size() == 3,"Tous les rangs actifs comptés une fois dans trois arbres")
			for unit in data.units:
				check(unit.type in ([0,1,2] if faction == 0 else [3,4,5]) and unit.bonuses == Talents.effects(faction,ranks,unit.type),"Bénéficiaires et bonus propres à la faction")
			check(before == JSON.stringify(ranks),"Calcul du résumé sans mutation des rangs")
			var scene = Main.new();root.add_child(scene);scene.set_process(false)
			scene.model.meta_ranks = ranks.duplicate();scene._choose_faction(faction)
			var signature: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state)])
			check(scene.loadout_label.visible and scene.loadout_label.text == ("Aucun talent permanent actif" if data.points == 0 else "Talents actifs · %d points (survol)" % data.points),"Rappel du départ visible avant la première vague")
			check(scene.loadout_label.get_global_rect().position.x >= scene.boss_panel.get_global_rect().end.x and scene.loadout_label.get_global_rect().end.y <= scene.enemy_inspector.position.y,"Rappel séparé de la jauge de boss et de la fiche ennemie")
			check(not scene.meta_menu.visible and not scene.choosing_faction,"Rappel consultable sans ouvrir les arbres pendant le parcours")
			scene._refresh_loadout_label();scene._populate_loadout_summary()
			check(signature == JSON.stringify([Report.build(scene.model),str(scene.model.rng.state)]),"Lecture du rappel et du bilan sans mutation du combat ou du RNG")
			scene._prepare_campaign_capture("victory");scene._show_run_summary();scene._set_summary_tab(3)
			check(scene.summary_tab == 3 and scene.summary_loadout_content.visible and not scene.summary_essential_content.visible and not scene.summary_wave_content.visible and not scene.summary_performance_content.visible,"Onglet Talents distinct des trois bilans existants")
			var text: String = scene.loadout_label.tooltip_text
			for line in scene.summary_loadout_units: text += "\n"+line.text
			check(not text.to_lower().contains("chaman") if faction == 0 else not text.to_lower().contains("mage"),"Résumé sans unité du camp opposé")
			for line in scene.summary_loadout_units:
				check(line.get_theme_font("font").get_string_size(line.text,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x <= line.size.x,"Bonus permanents lisibles sur une ligne")
			var report: Dictionary = Report.build(scene.model)
			var markdown: String = Report.markdown(report)
			check(Replay.verify(JSON.parse_string(JSON.stringify(report))).ok,"Rapport JSON encore rejouable avec les mêmes rangs")
			if data.points > 0:
				check(markdown.contains("## Talents permanents de la partie") and markdown.contains(data.trees[0].name),"Rapport Markdown avec noms et rangs compréhensibles")
			scene._set_summary_tab(2);check(not scene.summary_loadout_content.visible,"Retour à Essentiel retire le contenu Talents")
			scene._close_run_summary();scene._reset()
			check(not scene.loadout_label.visible and scene.summary_tab == 2,"Retour accueil sans ancien rappel actif")
			scene.free()
	# Le bilan décrit le cliché de la partie, jamais les changements ultérieurs du profil.
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = Profile.new("")
	scene.mission_definition = {} # Consultation du format historique multi-cartes, hors campagne actuelle.
	scene.meta_profile.data.banks[0].points = 33;scene.meta_profile.data.banks[0].ranks = configurations[1].duplicate()
	scene._choose_faction(0);var tooltip: String = scene.loadout_label.tooltip_text
	scene.meta_profile.data.banks[0].ranks = Talents.empty_ranks();scene._update_interface()
	check(scene.loadout_label.tooltip_text == tooltip and Talents.spent(scene.model.meta_ranks) == 33,"Cliché du départ indépendant de l'affectation du profil")
	scene.run_final_map = false;scene._prepare_campaign_capture("victory");scene._show_run_summary();scene._set_summary_tab(3)
	check(scene.summary_tab != 3 and not scene.summary_tabs[3].visible and not scene.summary_loadout_content.visible,"Aucun onglet Talents entre les cartes d'un parcours non terminé")
	scene.free()
	check(Talents.loadout_summary(2,Talents.empty_ranks()).is_empty() and Talents.loadout_summary(0,[99]).is_empty(),"Entrées invalides refusées sans approximation")
	print("LOADOUT_SUMMARY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
