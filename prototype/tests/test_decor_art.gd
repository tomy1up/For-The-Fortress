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
	await verify_rendering()
	print("DECOR_ART_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_data() -> void:
	Decor.clear_cache()
	check(not Decor.data().is_empty() and Decor.data().version == 1,"decor.json chargé")
	check(Decor.set_for("valley").is_empty() and Decor.set_for("marsh").is_empty() and Decor.set_for("inconnu").is_empty(),"Seuls la citadelle et le volcan ont un décor par données")
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
		check(Decor.props("citadel_drawbridge","citadel",faction).is_empty(),"Cartes de citadelle sans placement vérifié : aucune pièce")
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

## Les pièces ne chevauchent ni la chaussée ni les emplacements ni la forteresse.
func verify_margins() -> void:
	for number in range(61,81):
		var id: String = Catalogue.definition(number).map_id
		var board: Dictionary = Model.Maps.for_id(id)
		for prop in Decor.props(id,"volcanic",0):
			var point: Vector2 = prop.point
			check(point.x >= 0.0 and point.x <= float(board.size.x) and point.y >= 0.0 and point.y <= float(board.size.y),"Pièce dans le plateau (%s)" % id)
			for slot in board.slots: check(point.distance_to(slot) >= 1.0,"Pièce loin des emplacements (%s)" % id)
			for route in (board.routes if board.has("routes") else [{"path_points":board.path_points}]):
				var points: Array = route.path_points
				for index in range(points.size()-1):
					var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point,points[index],points[index+1])
					check(point.distance_to(closest) >= 0.9,"Pièce loin de la chaussée (%s)" % id)

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
