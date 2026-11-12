extends SceneTree
const Decor = preload("res://scripts/decor_art.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_data()
	verify_palettes()
	verify_props()
	verify_margins()
	verify_water()
	await verify_rendering()
	print("DECOR_ART_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_data() -> void:
	Decor.clear_cache()
	check(not Decor.data().is_empty() and Decor.data().version == 1,"decor.json chargé")
	check(Decor.set_for("valley").is_empty() and Decor.set_for("inconnu").is_empty() and Decor.palette("marsh",0).is_empty() and Decor.props("marsh_stagnant","marsh",0).is_empty(),"Les marais n'ont que des calques d'eau : ni palette ni pièces")
	check(not Decor.set_for("citadel").is_empty() and not Decor.set_for("volcanic").is_empty(),"Citadelle et volcan décrits")
	for decoration in ["citadel","volcanic"]:
		var assets: Dictionary = Decor.set_for(decoration).assets
		var groups: Array = assets.values() if decoration == "citadel" else [assets]
		for group in groups:
			for name in group:
				var asset: Dictionary = group[name]
				var image: Texture2D = Decor.texture(str(asset.file))
				check(image != null and Vector2i(image.get_size()) == Vector2i(int(asset.size[0]),int(asset.size[1])),"Image de %s présente et de la taille déclarée" % name)
				check(Rect2(Vector2.ZERO,Vector2(float(asset.size[0]),float(asset.size[1]))).has_point(Vector2(float(asset.anchor[0]),float(asset.anchor[1]))) and float(asset.height) > 0.0,"Ancre de %s dans l'image" % name)
	check(Decor.overlay("volcanic").has("texture") and Decor.overlay("citadel").is_empty() and Decor.overlay("valley").is_empty(),"Calque de cendres pour le volcan seulement")
	check(Decor.citadel_faction(0) == "horde" and Decor.citadel_faction(1) == "alliance","La citadelle affichée est celle du camp adverse")

func verify_palettes() -> void:
	var horde_citadel: Dictionary = Decor.palette("citadel",0)
	var alliance_citadel: Dictionary = Decor.palette("citadel",1)
	check(horde_citadel.ground.is_equal_approx(Color8(82,72,71)) and alliance_citadel.ground.is_equal_approx(Color8(79,89,100)),"Sol de la citadelle selon le camp adverse")
	check(horde_citadel.face_right.is_equal_approx(Color8(68,58,57)) and horde_citadel.face_left.is_equal_approx(Color8(50,44,45)),"Faces de la citadelle de la Horde")
	var volcano: Dictionary = Decor.palette("volcanic",0)
	check(volcano.ground.is_equal_approx(Color8(68,60,65)) and Decor.palette("volcanic",1) == volcano,"Palette volcanique commune aux deux camps")
	check(Decor.palette("valley",0).is_empty() and Decor.palette("mountain",1).is_empty(),"Les autres décors gardent leurs couleurs")

func verify_props() -> void:
	for faction in [0,1]:
		var glacis: Array[Dictionary] = Decor.props("citadel_glacis","citadel",faction)
		var gates: Array[Dictionary] = Decor.props("citadel_gates","citadel",faction)
		check(glacis.size() == 6 and gates.size() >= 5,"Pièces de citadelle des missions 81 et 87 (faction %d)" % faction)
		check(Decor.props("citadel_drawbridge","citadel",faction).size() == 6 and Decor.props("citadel_inconnue","citadel",faction).is_empty(),"Pont-levis décoré, carte inconnue sans pièce")
		check(Decor.props("citadel_glacis","valley",faction).is_empty() and Decor.props("inconnue","volcanic",faction).is_empty(),"Pas de pièce hors décor ou carte décrite")
	var positions_a: Array = Decor.props("citadel_gates","citadel",0).map(func(prop):return prop.point)
	var positions_b: Array = Decor.props("citadel_gates","citadel",1).map(func(prop):return prop.point)
	var textures_a: Array = Decor.props("citadel_gates","citadel",0).map(func(prop):return prop.texture)
	var textures_b: Array = Decor.props("citadel_gates","citadel",1).map(func(prop):return prop.texture)
	check(positions_a == positions_b and textures_a != textures_b,"Même placement logique, architecture différente selon le camp")
	var volcanic_maps: Array = []
	for number in range(61,81): volcanic_maps.append(Catalogue.definition(number).map_id)
	for map_id in volcanic_maps:
		var pieces: Array[Dictionary] = Decor.props(str(map_id),"volcanic",0)
		check(pieces.size() == 6 and pieces.all(func(prop):return prop.destination.size.y > 0.0),"Six pièces volcaniques sur %s" % map_id)
	var piece: Dictionary = Decor.props("volcano_threshold","volcanic",0)[0]
	check(is_equal_approx(piece.destination.size.y,float(Decor.set_for("volcanic").assets[piece.object].height)),"Hauteur de jeu respectée")

## Les pièces de toutes les cartes décrites ne chevauchent ni la chaussée ni les emplacements (volcan et citadelle, deux camps).
func verify_margins() -> void:
	var counted := 0
	for decoration in ["volcanic","citadel","desert"]:
		var placements: Dictionary = Decor.set_for(decoration).get("placements",{})
		for id in placements:
			var board: Dictionary = Model.Maps.for_id(str(id))
			check(not board.is_empty() and board.decoration == decoration,"La carte %s existe avec le décor %s" % [id,decoration])
			if board.is_empty(): continue
			for faction in [0,1]:
				for prop in Decor.props(str(id),decoration,faction):
					counted += 1
					var point: Vector2 = prop.point
					check(point.x >= 0.0 and point.x <= float(board.size.x) and point.y >= 0.0 and point.y <= float(board.size.y),"Pièce dans le plateau (%s)" % id)
					for slot in board.slots: check(point.distance_to(slot) >= 1.0,"Pièce loin des emplacements (%s, %s)" % [id,prop.object])
					for route in (board.routes if board.has("routes") else [{"path_points":board.path_points}]):
						var points: Array = route.path_points
						for index in range(points.size()-1):
							var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point,points[index],points[index+1])
							check(point.distance_to(closest) >= 0.9,"Pièce loin de la chaussée (%s, %s)" % [id,prop.object])
	check(counted >= 250,"Toutes les pièces décrites sont contrôlées (%d)" % counted)

func verify_rendering() -> void:
	for faction in [0,1]:
		for id in ["citadel_glacis","citadel_gates","volcano_threshold","ash_crater"]:
			var model := Model.new(true,Model.Maps.for_id(id))
			model.select_faction(faction)
			model.rng.seed = 7
			var before: String = JSON.stringify([model.gold,model.rng.state,model.defenders,model.action_history])
			var view := View.new();view.model = model;root.add_child(view)
			await process_frame
			view.queue_redraw()
			await process_frame
			check(before == JSON.stringify([model.gold,model.rng.state,model.defenders,model.action_history]),"Dessiner le décor de %s ne modifie pas le jeu (faction %d)" % [id,faction])
			view.free()

## Les calques d'eau suivent la géométrie actuelle des cartes : routes et tronçons inondés identiques à ceux du jeu.
func verify_water() -> void:
	var overlays: Dictionary = Decor.set_for("marsh").get("overlays",{})
	check(overlays.has("marsh_stagnant") and overlays.has("marsh_crossroads"),"Calques d'eau des missions 51 et 58")
	for id in overlays:
		var entry: Dictionary = overlays[id]
		var board: Dictionary = Model.Maps.for_id(str(id))
		check(not board.is_empty() and board.has("flooded"),"La carte %s a des tronçons inondés" % id)
		var image: Texture2D = Decor.texture(str(entry.file))
		check(image != null and Vector2i(image.get_size()) == Vector2i(int(entry.size[0]),int(entry.size[1])),"Calque d'eau de %s présent et de la bonne taille" % id)
		check(not Decor.water_overlay(str(id)).is_empty() and Decor.water_overlay("valley_ford").is_empty(),"Calque disponible pour %s seulement" % id)
		check(not Decor.water_overlay_for(board).is_empty(),"Calque utilisé quand la géométrie correspond (%s)" % id)
		var moved: Dictionary = board.duplicate(true)
		var moved_route: Array = (moved.routes if moved.has("routes") else [{"path_points":moved.path_points}])[0].path_points
		moved_route[1] = moved_route[1]+Vector2(0.5,0)
		if not moved.has("routes"): moved.path_points = moved_route
		check(Decor.water_overlay_for(moved).is_empty(),"Tracé différent sous le même identifiant : repère calculé (%s)" % id)
		var shifted: Dictionary = board.duplicate(true)
		shifted.flooded[0].to = float(shifted.flooded[0].to)+1.0
		check(Decor.water_overlay_for(shifted).is_empty(),"Tronçon inondé différent sous le même identifiant : repère calculé (%s)" % id)
		var routes: Array = board.routes if board.has("routes") else [{"id":"main","path_points":board.path_points}]
		check(routes.size() == entry.routes.size(),"Même nombre de routes (%s)" % id)
		for index in range(mini(routes.size(),entry.routes.size())):
			var expected: Array = entry.routes[index].path_points
			var actual: Array = routes[index].path_points
			var same: bool = expected.size() == actual.size()
			for point in range(mini(expected.size(),actual.size())): same = same and is_equal_approx(float(expected[point][0]),actual[point].x) and is_equal_approx(float(expected[point][1]),actual[point].y)
			check(same,"Route %d de %s identique à celle du calque" % [index,id])
		var flooded: Array = board.flooded
		check(flooded.size() == entry.flooded.size(),"Même nombre de tronçons inondés (%s)" % id)
		for index in range(mini(flooded.size(),entry.flooded.size())): check(is_equal_approx(float(flooded[index].from),float(entry.flooded[index].from)) and is_equal_approx(float(flooded[index].to),float(entry.flooded[index].to)),"Tronçon %d de %s identique" % [index,id])
