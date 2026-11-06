extends SceneTree
const Screen = preload("res://scripts/campaign_screen.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func settled() -> void:
	await process_frame
	await process_frame
func run_checks() -> void:
	for faction in range(2):
		var p = Profile.new("");var menu = Screen.new();root.add_child(menu);menu.open(p,faction)
		await settled()
		check(menu.chapter_in_view(),"Le chapitre de départ est visible")
		var before: String = JSON.stringify(p.data)
		check(menu.nodes[0].state == "available" and menu.nodes[1].state == "locked" and menu.nodes[2].state == "locked","Une mission jouable et deux verrouillées sont distinguées sur un profil neuf")
		for index in range(3,10): check(menu.nodes[index].state == "locked" and menu.nodes[index].locked,"Les sept missions supplémentaires sont verrouillées avant la réussite précédente")
		for chapter in range(1,21):
			menu._chapter(chapter);await settled()
			check(menu.chapter == chapter and menu.chapter_in_view(),"Chaque chapitre sélectionné devient visible dans la liste après mise en page")
			check(menu.get_viewport().gui_get_focus_owner() == menu.nodes[0],"Révéler le chapitre ne vole pas le focus de la mission sélectionnée")
			if chapter == 3:
				check(menu.nodes.all(func(node): return node.state=="locked"),"Les dix missions du chapitre 3 attendent les réussites préalables")
			if chapter == 4:
				check(menu.nodes.all(func(node):return node.state=="locked"),"Les dix missions du chapitre 4 attendent les réussites préalables")
			if chapter == 5:
				check(menu.nodes[0].state=="locked" and menu.nodes.slice(1).all(func(node):return node.state=="future"),"Première mission des marais verrouillée et neuf missions futures")
			if chapter > 5:
				check(menu.chapter_buttons[chapter-1].text.contains("À venir"),"Un chapitre sans contenu jouable ne prétend pas être prêt")
				for node in menu.nodes: check(node.state == "future" and not node.locked,"Les nœuds d’un chapitre futur restent consultables, sans faux cadenas de progression")
				check(menu.terrain_preview.geometry().is_empty() and menu.start_button.disabled,"Une mission future reste sans carte inventée et sans lancement")
		check(JSON.stringify(p.data) == before,"Parcourir les vingt chapitres ne touche aucune ressource ni réussite")
		menu._chapter(20);menu._chapter(1);menu._chapter(19);await settled()
		check(menu.chapter == 19 and menu.chapter_in_view(),"Une navigation rapide révèle le dernier chapitre demandé, pas une ancienne sélection")
		menu._chapter(1);await settled();var scroll: int = menu.chapter_scroll.scroll_vertical
		menu.set_overlay_blocked(true);menu._chapter(20);menu.refresh();await settled()
		check(menu.chapter == 1 and menu.chapter_scroll.scroll_vertical == scroll,"Le parcours ne défile ni ne change derrière une autre fenêtre")
		menu.set_overlay_blocked(false)
		menu._chapter(20);menu.close();await settled()
		check(menu.chapter_scroll.scroll_vertical == scroll,"Une opération différée ne défile pas après fermeture")
		menu.open(p,faction,1);await settled()
		check(menu.chapter == 1 and menu.chapter_in_view(),"Revenir au premier chapitre le remet dans le champ")
		var id: int = p.begin_mission(faction,"campaign.001",60,10,100)
		check(id > 0 and p.credit_mission(id,faction,10,true),"Réussite de contrôle créditée normalement")
		menu.refresh();await settled()
		check(menu.nodes[0].state == "completed" and menu.nodes[0].completed and menu.nodes[1].state == "available" and menu.nodes[2].state == "locked","Une réussite met à jour les états du même camp sans modifier les missions futures")
		check(p.campaign_status(1-faction).completed == 0 and p.data.banks[1-faction].resource == 0,"Aucun succès ni gain n’est transféré à l’autre faction")
		before = JSON.stringify(p.data);p.blocked = true;p.error = "Progression indisponible pour le contrôle."
		menu.refresh();menu._select(0);await settled()
		check(menu.nodes[0].state == "unavailable" and not menu.nodes[0].locked and menu.start_button.text == "Progression indisponible" and menu.start_button.disabled,"Un problème de profil est présenté comme tel, sans faux verrou de mission")
		menu._launch();check(JSON.stringify(p.data) == before,"L’erreur de profil ne lance ni ne crédite de tentative")
		check(menu.nodes[3].state == "unavailable","Les missions existantes ne prétendent pas être à venir quand le profil est indisponible")
		menu.free()
	print("CAMPAIGN_STATES_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
