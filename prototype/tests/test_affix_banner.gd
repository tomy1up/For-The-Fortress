extends SceneTree
## Bandeau d'affixe (lisibilité, v0.223) : annonce, compte à rebours et effet de chaque affixe de mission.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func combat(affix: Dictionary, map_id: String = "valley_ford"):
	var m = Model.new(true,Model.Maps.for_id(map_id))
	check(m.configure_combat_affix(affix),"Affixe %s accepté" % affix.id)
	m.select_faction(0);m.gold = 5000
	m.buy(0,0);m.buy(1,1)
	m.start()
	return m

func run_checks() -> void:
	check(View.affix_banner(null).is_empty() and View.affix_banner(Model.new()).is_empty(),"Sans affixe : aucun bandeau")
	# Vents contraires : permanent.
	var wind = combat({"id":"headwinds","cadence_percent":90})
	var banner: Dictionary = View.affix_banner(wind)
	check(banner.state == "permanent" and banner.text.contains("−10 %"),"Vents contraires : bandeau permanent « cadence −10 % »")
	# Éruptions : annonce 3 s avant (toutes les 14 s), puis désactivation de 5 s.
	var eruptions = combat({"id":"eruptions","interval":14,"warning":3,"duration":5})
	check(View.affix_banner(eruptions).is_empty(),"Éruptions : aucun bandeau avant l'annonce")
	eruptions.advance(11.5)
	banner = View.affix_banner(eruptions)
	check(banner.state == "warning" and banner.text.begins_with("Éruption dans ") and banner.text.contains("désactivé") and banner.fraction > 0.0 and banner.fraction <= 1.0,"Éruptions : annonce avec compte à rebours et défenseur visé (%s)" % banner.get("text",""))
	eruptions.advance(3.0)
	banner = View.affix_banner(eruptions)
	check(banner.state == "active" and banner.text.contains("encore") and banner.text.contains("désactivé"),"Éruptions : désactivation en cours (%s)" % banner.get("text",""))
	# Tempête de sable.
	var storm = combat({"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":25})
	storm.advance(12.5)
	banner = View.affix_banner(storm)
	check(banner.state == "warning" and banner.text.contains("Tempête de sable") and banner.text.contains("portée −25 %"),"Tempête : annonce et effet (%s)" % banner.get("text",""))
	storm.advance(3.0)
	check(View.affix_banner(storm).state == "active","Tempête : en cours")
	# Brume marine.
	var mist = combat({"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":30},"coast_beacon")
	mist.advance(19.5)
	banner = View.affix_banner(mist)
	check(banner.state == "warning" and banner.text.contains("Brume marine") and banner.text.contains("or −30 %"),"Brume : annonce et effet (%s)" % banner.get("text",""))
	# Éboulement : entrée bloquée (carte à plusieurs entrées).
	var rock = combat({"id":"rockfall","interval":18,"warning":3,"duration":7},"slate_crossing")
	rock.advance(15.5)
	banner = View.affix_banner(rock)
	check(banner.state == "warning" and banner.text.contains("Éboulement") and banner.text.contains("entrée") and banner.text.contains("bloquée"),"Éboulement : annonce et entrée visée (%s)" % banner.get("text",""))
	# Rendu sans erreur à chaque état.
	for sample in [wind,eruptions,storm,mist,rock]:
		var view := View.new();view.model = sample;root.add_child(view)
		view.queue_redraw()
		await process_frame
		check(true,"Dessin du bandeau")
		view.free()
	verify_banner_clearance()
	verify_entry_labels_apart()
	print("AFFIX_BANNER_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)

## Étiquettes d'entrée écartées les unes des autres (v0.240) : avec les effectifs de préparation, les étiquettes d'entrées voisines se chevauchaient
## (46 cas sur 38 missions des chapitres 6 à 20). Contrôle de toutes les missions à plusieurs entrées, pour chaque entrée principale possible et sans entrée principale.
func verify_entry_labels_apart() -> void:
	const Catalogue = preload("res://scripts/campaign_catalogue.gd")
	var view = View.new()
	var moved: Array[int] = []
	for number in range(1,201):
		var m = Model.new(true,Model.Maps.for_id(str(Catalogue.definition(number).map_id)))
		if m.routes.size() < 2: continue
		view.model = m
		for busiest in range(-2,m.routes.size()):
			var forecast: Array[Dictionary] = []
			if busiest > -2:
				for index in range(m.routes.size()): forecast.append({"route_id":m.routes[index].id,"count":12 if index == busiest else 8})
			view.entry_forecast = forecast
			var labels: Array = view.entry_label_layouts()
			var context: String = "Mission %d, %s" % [number,"combat" if busiest == -2 else "préparation sans entrée principale" if busiest == -1 else "préparation, entrée %d principale" % (busiest+1)]
			for i in range(labels.size()):
				var natural := Rect2(view.project(m.routes[i].path_points[0])+Vector2(-labels[i].area.size.x/2.0,-76.0-labels[i].area.size.y),labels[i].area.size)
				var shift: float = Rect2(labels[i].area).position.distance_to(natural.position)
				check(shift <= 40.0,"%s : l'étiquette « Entrée %d » reste près de son point d'entrée" % [context,i+1])
				if busiest == -2: check(shift <= 1.01,"%s : l'étiquette « Entrée %d » garde sa place au combat" % [context,i+1])
				if shift > 1.01 and number not in moved: moved.append(number)
				check(View.ENTRY_LABEL_ZONE.encloses(labels[i].area),"%s : l'étiquette « Entrée %d » reste dans la zone de carte" % [context,i+1])
				for j in range(i+1,labels.size()):
					check(not Rect2(labels[i].area).grow(View.ENTRY_LABEL_GAP-0.5).intersects(labels[j].area),"%s : les étiquettes « Entrée %d » et « Entrée %d » ne se chevauchent pas" % [context,i+1,j+1])
	for number in [60,117,134,170,200]: check(number in moved,"Mission %d : une étiquette d'entrée s'écarte de sa voisine en préparation" % number)
	var apart: Array[Rect2] = View.separate_entry_labels([Rect2(530,81,148,44),Rect2(504,108,92,44)])
	check(apart[0] == Rect2(530,81,148,44) and apart[1] == Rect2(504,129,92,44),"Mission 134 : « Entrée 2 » passe juste sous « Entrée 1 · principale », à 4 px")
	print("ENTRY_LABELS_MOVED=",moved)
	view.free()

## Place commune du bandeau d'affixe (v0.241) : la même place fixe pour tous les affixes, dans la bande du haut, hors du plateau, au-dessus des
## étiquettes d'entrée et hors du bloc d'informations de droite. Signalé sur les missions 36 et 39 (Vents contraires), où le bandeau glissant de la
## v0.239 descendait sur la route et les ennemis, et 173, 177 et 178 (Brume marine). Toutes les missions à affixe, au combat et en préparation.
func verify_banner_clearance() -> void:
	const Catalogue = preload("res://scripts/campaign_catalogue.gd")
	var view = View.new()
	var area: Rect2 = View.affix_banner_area()
	check(area == Rect2(395,24,430,34),"Place commune du bandeau : 395 à 825 px, 24 à 58 px")
	check(Rect2(350,24,520,54).encloses(area),"Le bandeau occupe la place de l'annonce de vague")
	check(not area.intersects(Rect2(898,33,358,253)) and not area.intersects(View.AFFIX_BANNER_HUD),"Le bandeau laisse libres la fiche d'ennemi et les informations en haut à droite")
	check(not area.intersects(Rect2(32,24,300,44)) and not area.intersects(Rect2(34,96,440,20)),"Le bandeau laisse libres le titre et la ligne d'affixe à gauche")
	check(area.end.y+6.0 <= View.ENTRY_LABEL_ZONE.position.y,"Le bandeau reste au-dessus de la zone des étiquettes d'entrée")
	var cases := 0
	for number in range(1,201):
		var entry: Dictionary = Catalogue.definition(number)
		if entry.get("combat_affix",{}).is_empty(): continue
		var m = Model.new(true,Model.Maps.for_id(str(entry.map_id)))
		view.model = m
		var board := Vector2(m.map_definition.size)
		var top: float = INF
		var outline := PackedVector2Array()
		for corner in [Vector2.ZERO,Vector2(board.x,0),board,Vector2(0,board.y)]:
			outline.append(View.project(corner));top = minf(top,View.project(corner).y)
		var banner_outline := PackedVector2Array([area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)])
		check(Geometry2D.intersect_polygons(banner_outline,outline).is_empty() and area.end.y+40.0 <= top,"Mission %d : le bandeau reste hors du plateau, au-dessus des ennemis à l'entrée" % number)
		for busiest in range(-2,m.routes.size()):
			var forecast: Array[Dictionary] = []
			if busiest > -2:
				for index in range(m.routes.size()): forecast.append({"route_id":m.routes[index].id,"count":12 if index == busiest else 8})
			view.entry_forecast = forecast
			cases += 1
			for label in view.entry_label_layouts():
				check(not Rect2(label.area).grow(5.5).intersects(area),"Mission %d (%s) : « %s » reste à 6 px au moins du bandeau" % [number,"combat" if busiest == -2 else "préparation",label.title])
	check(cases >= 100,"Toutes les missions à affixe contrôlées (%d cas)" % cases)
	var wind = combat({"id":"headwinds","cadence_percent":90},"slate_crossing")
	view.model = wind
	check(view.affix_banner_shown(),"Mission 36 : bandeau des Vents contraires affiché")
	view.top_notice_visible = true
	check(not view.affix_banner_shown(),"Le bandeau s'efface pendant l'annonce de vague, qui occupe la même place")
	view.free()
	verify_notice_link()

## Lien avec l'annonce de vague de main.gd : le bandeau s'efface tant que l'annonce (départ de vague ou compte à rebours) est visible.
func verify_notice_link() -> void:
	const Main = preload("res://scripts/main.gd")
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(0)
	scene._update_interface()
	check(not scene.wave_notice.visible and not scene.map_view.top_notice_visible,"Préparation : ni annonce ni effacement du bandeau")
	scene.model.buy(0,0);scene.model.buy(1,1);scene._start()
	check(scene.wave_notice.visible and scene.map_view.top_notice_visible,"Départ de vague : le bandeau laisse la place à l'annonce")
	scene._process(2.5)
	check(not scene.wave_notice.visible and not scene.map_view.top_notice_visible,"Fin de l'annonce : le bandeau revient")
	scene._process(1000)
	check(scene.model.phase == "finished" and scene.countdown_remaining == 30,"Fin de la vague 1 : trente secondes de préparation")
	scene._process(26)
	check(scene.wave_notice.visible and scene.map_view.top_notice_visible,"Compte à rebours de la vague 2 : le bandeau laisse la place à l'annonce")
	scene.free()
