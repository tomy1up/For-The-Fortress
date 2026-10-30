extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Fixture = preload("res://tests/test_linked_talents.gd")
var checks: int = 0
var failures: int = 0
class RefusingProfile extends Profile:
	var refuse: bool = true
	func begin_mission(faction: int, id: String, po: int, waves: int = 10, xp: int = 0) -> int:
		if refuse: error = "Échec de sauvegarde simulé.";return -1
		return super.begin_mission(faction,id,po,waves,xp)
class RefusingSettlement extends Profile:
	var refuse: bool = true
	func credit_mission(id: int, faction: int, completed: int, victory: bool) -> bool:
		if refuse: error = "Résultat non enregistré pour le contrôle.";return false
		return super.credit_mission(id,faction,completed,victory)
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func prepared() -> RefCounted:
	var p = Profile.new("")
	for faction in range(2):
		p.data.banks[faction].points = 51;p.data.banks[faction].xp = 10000
		p.data.banks[faction].resource = 17;p.data.banks[faction].ranks = Fixture.build(0)
	return p
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false)
		var p = prepared();scene.meta_profile = p
		var before: String = JSON.stringify(p.data)
		scene.faction_buttons[faction].pressed.emit()
		check(scene.choosing_faction and scene.campaign_menu.visible and scene.campaign_menu.faction == faction,"Le choix de faction ouvre son parcours sans lancer ni payer une tentative")
		check(JSON.stringify(p.data) == before and scene.campaign_menu.status.completed == 0,"Consulter un parcours neuf ne modifie pas le profil")
		var menu = scene.campaign_menu
		for control in [menu.heading,menu.balance,menu.points_label,menu.start_button,menu.talents_button,menu.back_button,menu.footer]+menu.nodes:
			check(Rect2(0,0,1280,800).encloses(control.get_global_rect()),"Les contrôles du parcours tiennent dans la fenêtre de référence")
		for chapter in range(1,21):
			menu._chapter(chapter)
			check(menu.chapter_label.text.contains(str(chapter)) and menu.nodes[9].text == str(chapter*10),"Chaque chapitre présente ses dix positions exactes")
			for index in range(10):
				menu._select(index)
				var number: int = (chapter-1)*10+index+1
				check(menu.start_button.disabled == (number != 1),"Seul le contenu réellement disponible peut démarrer")
				if number > 1:
					menu._launch();scene._launch_campaign_mission("campaign.%03d" % number)
					check(scene.choosing_faction and not scene.model.active and JSON.stringify(p.data) == before,"Une mission future ne peut pas démarrer par clic ni appel direct et ne crée aucun gain")
		menu._chapter(1);menu._talents();await process_frame
		check(scene.meta_menu.visible and menu.overlay_blocked and menu.start_button.focus_mode == Control.FOCUS_NONE,"Les talents recouvrent le parcours et isolent son clavier")
		menu._chapter(2);menu._launch()
		var escape := InputEventKey.new();escape.keycode = KEY_ESCAPE;escape.pressed = true
		menu._unhandled_key_input(escape)
		check(menu.chapter == 1 and scene.choosing_faction and JSON.stringify(p.data) == before,"Le parcours ne reçoit pas les actions à travers les talents")
		check(menu.visible,"Échap ne ferme pas le parcours derrière les talents")
		scene.meta_menu.close();await process_frame
		check(menu.visible and not menu.overlay_blocked and menu.faction == faction,"Fermer les talents retrouve le même parcours")
		menu._launch()
		check(not scene.choosing_faction and not menu.visible and scene.campaign_navigation and scene.model.faction == faction,"Le lancement explicite démarre la bonne mission et la bonne faction")
		check(scene.model.gold == 150 and scene.model.fortress_hp == scene.model.max_hp and scene.model.bonuses.is_empty(),"Départ avec or initial, forteresse intacte et aucun bonus temporaire")
		check(scene.model.defenders.all(func(unit): return unit.is_empty()) and scene.model.meta_ranks == p.data.banks[faction].ranks,"Plateau vide et talents persistants appliqués au début de la mission")
		scene._open_campaign(1-faction)
		check(not menu.visible,"Aucun retour au parcours pendant une mission")
		scene._prepare_campaign_capture("victory")
		check(scene.model.phase == "victory","Mission de référence réellement gagnée avec le build de contrôle")
		scene._sync_meta_rewards(true);scene._update_interface();scene._show_run_summary()
		check(scene.summary_open and scene.summary_campaign_button.visible and not scene.summary_campaign_button.disabled,"Le résultat enregistré propose le retour au parcours")
		check(p.data.banks[faction].resource == 77 and p.data.banks[faction].xp == 10100 and p.campaign_status(faction).completed == 1,"Première victoire créditée et mission marquée réussie immédiatement")
		check(p.data.banks[1-faction].resource == 17 and p.data.banks[1-faction].xp == 10000 and p.campaign_status(1-faction).completed == 0,"Aucun gain ni succès transféré à l’autre faction")
		scene.summary_campaign_button.pressed.emit();await process_frame
		check(menu.visible and scene.choosing_faction and menu.status.completed == 1 and menu.nodes[0].completed and menu.rewards.text.contains("déjà perçues"),"Le retour montre la réussite et annonce clairement le rejeu sans gain")
		menu._launch()
		check(scene.model.gold == 150 and scene.model.fortress_hp == scene.model.max_hp and scene.model.bonuses.is_empty() and scene.model.defenders.all(func(unit): return unit.is_empty()),"Une nouvelle mission efface tous les acquis temporaires de la précédente")
		scene._prepare_campaign_capture("victory");scene._sync_meta_rewards(true)
		check(p.data.banks[faction].resource == 77 and p.data.banks[faction].xp == 10100 and p.campaign_status(faction).completed == 1,"Rejouer la mission ne double ni PO ni XP ni succès")
		scene.free()
	var scene = Main.new();root.add_child(scene);scene.set_process(false)
	var p = RefusingProfile.new("");scene.meta_profile = p;scene._open_campaign(0)
	var before: String = JSON.stringify(p.data);scene.campaign_menu._launch()
	check(scene.choosing_faction and scene.campaign_menu.visible and not scene.model.active and scene.campaign_menu.footer.text.contains("Échec"),"Échec d’enregistrement au lancement : aucun combat et erreur visible")
	check(JSON.stringify(p.data) == before and scene.model.faction == 0,"L’échec ne consomme pas une tentative ni ne modifie le profil")
	p.refuse = false;scene.campaign_menu._launch()
	check(not scene.choosing_faction and scene.meta_run_id > 0,"Réessayer après correction démarre normalement")
	scene.free()
	scene = Main.new();root.add_child(scene);scene.set_process(false)
	var delayed = RefusingSettlement.new("");delayed.data = prepared().data
	scene.meta_profile = delayed;scene._open_campaign(1);scene.campaign_menu._launch()
	scene._prepare_campaign_capture("victory");scene._sync_meta_rewards(true);scene._update_interface();scene._show_run_summary()
	check(scene.summary_campaign_button.disabled and scene._run_finished(),"Un résultat non sauvegardé reste affiché avec le retour désactivé")
	scene._summary_to_campaign()
	check(scene.summary_open and not scene.campaign_menu.visible and not scene.choosing_faction and delayed.data.banks[1].resource == 17,"L’appel direct du retour ne détruit pas un résultat en attente")
	delayed.refuse = false;scene._summary_to_campaign()
	check(scene.campaign_menu.visible and scene.choosing_faction and delayed.data.banks[1].resource == 77 and delayed.campaign_status(1).completed == 1,"Le résultat est crédité une fois puis le parcours s’ouvre après rétablissement")
	scene.free()
	print("CAMPAIGN_NAVIGATION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
