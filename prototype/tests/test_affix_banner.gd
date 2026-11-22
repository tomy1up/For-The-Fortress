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
	print("AFFIX_BANNER_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)

## Le bandeau d'affixe ne chevauche aucune étiquette d'entrée (v0.239, signalé sur les missions 116, 117 et 120 de la Tempête de sable), pour toutes les missions à affixe, avec ou sans le décompte d'ennemis.
func verify_banner_clearance() -> void:
	const Catalogue = preload("res://scripts/campaign_catalogue.gd")
	var view = View.new()
	var moved: Array[int] = []
	for number in range(1,201):
		var entry: Dictionary = Catalogue.definition(number)
		if entry.get("combat_affix",{}).is_empty(): continue
		var m = Model.new(true,Model.Maps.for_id(str(entry.map_id)))
		view.model = m
		for with_counts in [false,true]:
			var forecast: Array[Dictionary] = []
			if with_counts:
				for route in m.routes: forecast.append({"route_id":route.id,"count":12})
			view.entry_forecast = forecast
			var labels: Array = view.entry_label_layouts()
			var area: Rect2 = View.affix_banner_area(labels)
			check(labels.all(func(label) -> bool: return not Rect2(label.area).grow(View.AFFIX_BANNER_MARGIN-0.5).intersects(area)),"Mission %d : le bandeau d'affixe laisse de la place aux étiquettes d'entrée" % number)
			check(area.position.x >= 320.0 and area.end.x <= 1260.0 and area.position.y >= 56.0,"Mission %d : le bandeau reste au-dessus du plateau, hors des panneaux" % number)
			if not with_counts and not area.position.is_equal_approx(Vector2(425,112)): moved.append(number)
	for number in [116,117,120]: check(number in moved,"Mission %d : le bandeau s'écarte de l'étiquette « Entrée 1 »" % number)
	check(View.affix_banner_area([]) == Rect2(Vector2(425,112),View.AFFIX_BANNER_SIZE),"Sans étiquette : place habituelle")
	print("BANNER_MOVED=",moved)
	view.free()
