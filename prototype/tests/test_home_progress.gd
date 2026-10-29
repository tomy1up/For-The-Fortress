extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var scene = Main.new();root.add_child(scene);scene.set_process(false)
	check(scene.meta_profile == null and scene.home_resources[0].text.contains("indisponibles") and scene.meta_buttons[0].disabled,"Absence de profil distincte d'un solde nul")
	scene.meta_profile = Profile.new("");scene._update_interface()
	for camp in range(2):
		check(not scene.meta_buttons[camp].disabled and scene.home_resources[camp].text.begins_with("0 PO"),"Profil neuf accessible et solde réel affiché")
		check(scene.home_hints[camp].text == "Prochain point : encore 10 PO.","Premier achat expliqué sans donner de point")
	var bank: Dictionary = scene.meta_profile.data.banks[0]
	bank.resource = 25;bank.points = 8;bank.ranks[0] = 5
	scene.meta_profile.data.banks[1].resource = 1
	var before: String = JSON.stringify(scene.meta_profile.data)
	var combat: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state)])
	scene._update_interface();scene._refresh_home_progress()
	check(scene.home_points[0].text == "5 points actifs · 3 à placer" and scene.meta_buttons[0].text.contains("3 points à placer"),"Points déjà achetés mais non affectés mis en avant")
	check(scene.home_hp[0].text == "Forteresse au départ : 25 PV" and scene.home_hp[1].text == "Forteresse au départ : 20 PV","PV initiaux calculés séparément par faction")
	check(scene.home_resources[1].text == "1 PO Horde" and scene.home_hints[1].text.contains("encore 9"),"Solde et coût manquant propres à l'autre camp")
	check(before == JSON.stringify(scene.meta_profile.data) and combat == JSON.stringify([Report.build(scene.model),str(scene.model.rng.state)]),"Accueil en lecture seule sans dépense ni mutation du combat")
	scene._open_meta(0);scene.meta_menu._allocate(5);scene.meta_menu.close();scene._update_interface()
	check(scene.home_points[0].text == "6 points actifs · 2 à placer","Retour des arbres : rappel immédiatement actualisé")
	check(scene.meta_profile.data.banks[1].resource == 1 and scene.meta_profile.data.banks[1].points == 0,"Affectation sans effet sur l'autre faction")
	bank = scene.meta_profile.data.banks[0];bank.ranks = Talents.empty_ranks();bank.points = 0;bank.resource = 25
	scene._update_interface()
	check(scene.home_hints[0].text == "Vous pouvez acheter 2 points de talent." and scene.meta_buttons[0].text == "Préparer les talents","Achat possible annoncé sans confondre points possédés et achetables")
	bank.points = Talents.MAX_POINTS-1;bank.ranks = scene._capture_expanded_ranks(0);bank.ranks[Talents.Expanded.index_for(0,18)] = 0;bank.resource = 100
	scene._update_interface()
	check(scene.home_hints[0].text == "Vous pouvez acheter 1 point de talent.","Achat possible borné au plafond de points")
	bank.points = Talents.MAX_POINTS;bank.ranks = scene._capture_expanded_ranks(0)
	scene._update_interface()
	check(scene.home_hints[0].text == "Tous les points ont été achetés.","Plafond atteint sans encouragement à un achat impossible")
	for camp in range(2):
		for labels in [scene.home_resources,scene.home_points,scene.home_hp,scene.home_hints]:
			var label: Label = labels[camp]
			check(label.get_theme_font("font").get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,label.get_theme_font_size("font_size")).x <= label.size.x,"Libellés de synthèse contenus dans leur colonne")
		check(scene.home_hints[camp].get_global_rect().end.y < scene.meta_buttons[camp].get_global_rect().position.y,"Conseil séparé du bouton de talents")
	scene.meta_profile.blocked = true;scene.meta_profile.error = "Écriture impossible";scene._update_interface()
	check(scene.meta_income.text.contains("Sauvegarde à vérifier") and scene.meta_income.tooltip_text == "Écriture impossible","Erreur de profil visible et consultable à l'accueil")
	check(scene.home_resources[0].text == "PO : à vérifier" and scene.home_hp[0].text.is_empty() and not scene.meta_buttons[0].disabled,"Profil bloqué sans solde fictif, accès au détail conservé")
	scene.meta_profile.blocked = false;scene.meta_profile.error = "";scene._update_interface()
	check(scene.home_resources[0].text == "100 PO Alliance","Retour à un profil valide retire l'alerte")
	scene._choose_faction(1);scene._open_meta(0)
	check(not scene.faction_panel.visible and not scene.meta_menu.visible and not scene.choosing_faction,"Aucun accès aux talents une fois parti")
	scene.model.phase = "defeat";scene._sync_meta_rewards(true);scene._reset();scene._update_interface()
	check(scene.faction_panel.visible and scene.home_resources[1].text == "1 PO Horde","Retour après résultat global : progression conservée")
	scene.free()
	print("HOME_PROGRESS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
