extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Sample = preload("res://tests/test_campaign_sample.gd")
var checks: int = 0
var failures: int = 0
class PendingProfile extends Profile:
	var fail: bool = false
	func credit_mission(id: int, faction: int, completed: int, victory: bool) -> bool:
		if fail: error = "Écriture indisponible pour le contrôle.";return false
		return super.credit_mission(id,faction,completed,victory)
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	check(Catalogue.suggested_mission({}) == 1,"Progression indisponible : suggestion prudente, sans inventer un succès")
	for faction in range(2):
		var p = Profile.new("")
		for completed in range(21):
			var before: String = JSON.stringify(p.data)
			check(Catalogue.suggested_mission(p.campaign_status(faction)) == mini(completed+1,20),"Suggestion : première mission à réussir, puis dernière mission jouable lorsque l’échantillon est terminé")
			check(Catalogue.suggested_mission(p.campaign_status(1-faction)) == 1 and JSON.stringify(p.data) == before,"La suggestion est sans écriture et ne transfère aucune réussite à l’autre camp")
			if completed < 20:
				var id: int = p.begin_mission(faction,Catalogue.id_for(completed+1),60,10,100)
				check(p.credit_mission(id,faction,10,true),"Préparation d’une réussite réelle par le service de progression")
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = p
		scene._open_campaign(faction)
		check(scene.campaign_menu.chapter == 2 and scene.campaign_menu.selected == 9 and scene.choosing_faction,"Le parcours terminé propose la vingtième mission sans la lancer")
		scene.campaign_menu._chapter(2);scene.campaign_menu._select(5)
		var before: String = JSON.stringify(p.data)
		scene.campaign_menu._talents();scene.meta_menu.close()
		check(scene.campaign_menu.chapter == 2 and scene.campaign_menu.selected == 5 and JSON.stringify(p.data) == before,"Consulter puis fermer les talents préserve une sélection manuelle et le profil")
		scene.free()
		scene = Main.new();root.add_child(scene);scene.set_process(false);p = Profile.new("");scene.meta_profile = p
		for number in [1,2]:
			scene._open_campaign(faction);scene.campaign_menu._launch()
			Sample.play(scene.model,Sample.POSITIONS[number-1]);scene._show_run_summary()
			check(scene.model.phase == "victory" and scene.summary_subtitle.text.contains("Mission %d" % number) and scene.summary_subtitle.text.contains(scene.model.map_definition.title),"Le bilan essentiel identifie la mission réellement terminée")
			for tab in range(4):
				scene._set_summary_tab(tab)
				check(scene.summary_subtitle.text.contains(scene.model.map_definition.title),"Le nom de la carte reste visible dans chaque onglet du bilan")
			scene._set_summary_tab(2)
			if number == 1:
				check(scene.summary_meta_note.text.contains("encore 97 XP") and scene.summary_talents_button.text == "Consulter mes talents","Avant le premier point, le bilan explique l’XP restante sans annoncer un talent attribué")
				scene._summary_to_campaign()
				check(scene.campaign_menu.selected == 1 and scene.choosing_faction,"La prochaine mission est proposée au retour mais attend le clic du joueur")
			else:
				check(scene.summary_meta_note.text.contains("1 point de talent à placer") and scene.summary_talents_button.text == "Placer mon point de talent","Le premier point gagné est clairement disponible, sans être investi automatiquement")
				check(scene.summary_meta_note.mouse_filter == Control.MOUSE_FILTER_STOP and scene.summary_meta_note.tooltip_text.contains("120 PO"),"Le détail du solde reste consultable au survol du texte condensé")
				var balance: int = p.data.banks[faction].resource
				scene.summary_talents_button.pressed.emit()
				check(scene.meta_menu.visible and scene.meta_menu.faction == faction and p.data.banks[faction].ranks[0] == 0,"Le bouton mène à l’arbre de la bonne faction et laisse le choix du talent au joueur")
				scene.meta_menu.nodes[0].pressed.emit();scene.meta_menu.close()
				check(p.data.banks[faction].ranks[0] == 1 and p.data.banks[faction].resource == balance and p.data.banks[faction].xp == 200,"Investir le point n’achète rien en PO et ne consomme pas l’XP")
				check(scene.campaign_menu.visible and scene.campaign_menu.selected == 2 and not scene.campaign_menu.start_button.disabled,"Après le choix du talent, le parcours retrouve la troisième mission disponible")
				scene.campaign_menu._launch();Sample.play(scene.model,Sample.POSITIONS[2]);scene._show_run_summary()
				check(scene.summary_meta_note.text.contains("encore 93 XP") and scene.summary_talents_button.text == "Consulter mes talents","Après investissement, le bilan montre le prochain seuil sans annoncer un second point")
				scene._set_summary_tab(3)
				check(scene.summary_subtitle.text.contains("1 point actif") and scene.summary_subtitle.text.contains("Les Hauts du Gué"),"Le bilan distingue le talent réellement actif et conserve le nom de la mission")
		scene.free()
	var p = PendingProfile.new("")
	var id: int = p.begin_mission(0,"campaign.001",60,10,100);p.credit_mission(id,0,10,true)
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = p;scene._open_campaign(0)
	scene.campaign_menu._select(0);scene.campaign_menu._launch();Sample.play(scene.model,Sample.POSITIONS[0]);p.fail = true;scene._show_run_summary()
	check(not scene._meta_reward_summary().first and scene.summary_meta_note.text.contains("non enregistrés") and scene.summary_talents_button.text == "Réessayer la sauvegarde","Même en rejouant sans gain, un résultat non enregistré garde un avertissement et l’action de reprise")
	p.fail = false;scene._summary_to_talents()
	check(scene.summary_open and p.data.banks[0].xp == 100 and p.data.banks[0].resource == 60,"Réessayer confirme le résultat sans doubler les gains ni quitter le bilan au premier clic")
	scene._summary_to_talents()
	check(scene.meta_menu.visible and scene.campaign_menu.selected == 1,"Après confirmation, le joueur peut consulter ses talents puis reprendre la prochaine mission")
	scene.free()
	print("CAMPAIGN_GUIDANCE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
