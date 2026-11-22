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
	verify_marsh_layers()
	verify_all_active()
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
	for decoration in ["volcanic","citadel","desert","mine","sky","coast","necro"]: # Toutes les cartes décorées depuis la v0.242.
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

## Marais 41 à 50 (v0.242, lots 5ae3c06 et 65638f3 de Codex) : calque de bassins par carte et quatre pièces dessinées ; missions 51 à 60 inchangées.
func verify_marsh_layers() -> void:
	const MarshArt = preload("res://scripts/marsh_art.gd")
	var expected: Array = []
	for number in range(41,51): expected.append(str(Catalogue.definition(number).map_id))
	check(MarshArt.POOL_LAYERS.keys().size() == 10 and expected.all(func(id) -> bool: return MarshArt.POOL_LAYERS.has(id)),"Un calque de bassins pour chacune des cartes des missions 41 à 50")
	var references: Dictionary = {}
	for lot in ["marais_41_45","marais_46_50"]:
		var path: String = ProjectSettings.globalize_path("res://").path_join("../design/essais/%s/Implantation.json" % lot)
		if FileAccess.file_exists(path): references.merge(JSON.parse_string(FileAccess.get_file_as_string(path)).pools)
	check(references.size() == 10,"Implantations de Codex lues pour les dix cartes")
	for id in expected:
		var definition: Dictionary = Model.Maps.for_id(id)
		var layer: Dictionary = MarshArt.pool_layer(id)
		check(not layer.is_empty() and layer.texture.get_size() == layer.area.size*2.0,"Calque de bassins de %s dessiné au double de sa taille d'affichage" % id)
		if layer.is_empty(): continue
		var water: Array = definition.get("water_areas",MarshArt.POOLS)
		if references.has(id):
			var reference: Dictionary = references[id]
			check(layer.area == Rect2(reference.position[0],reference.position[1],reference.size[0],reference.size[1]),"Position et taille du calque de %s conformes à l'implantation" % id)
			check(water.size() == reference.water_areas.size() and range(water.size()).all(func(i: int) -> bool: return Rect2(water[i]).is_equal_approx(Rect2(reference.water_areas[i][0],reference.water_areas[i][1],reference.water_areas[i][2],reference.water_areas[i][3]))),"Les bassins de %s n'ont pas bougé depuis le dessin" % id)
		for pool in water:
			var rect: Rect2 = pool
			for corner in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
				check(layer.area.grow(1.0).has_point(View.project(corner)),"Le calque de %s couvre ses bassins" % id)
		for item in View.scenery_for(definition):
			check(MarshArt.prop_texture(id,item.kind,int(item.order)) != null,"Pièce dessinée pour chaque objet de %s (%s)" % [id,item.kind])
	for kind in ["willow","reeds"]: check(MarshArt.prop_key("marsh_court",kind,4) == kind and MarshArt.prop_key("marsh_nave",kind,3) == kind,"Saule et roseaux gardent leur pièce")
	check(MarshArt.prop_key("marsh_court","ruin",4) == "ruin_fallen" and MarshArt.prop_key("marsh_court","ruin",5) == "ruin","Arche ou mur effondré selon la parité de l'ordre de placement")
	check(MarshArt.prop_key("marsh_cloister","ruin",4) == "ruin" and MarshArt.prop_key("marsh_nave","ruin",5) == "ruin_fallen","Arche au Cloître submergé, mur effondré à la Nef")
	for key in MarshArt.PROP_FILES:
		var texture: Texture2D = Decor.texture(MarshArt.PROP_FILES[key])
		var frame: Rect2 = MarshArt.bounds(Vector2.ZERO,"ruin" if key == "ruin_fallen" else key)
		check(texture != null and absf(texture.get_width()/float(texture.get_height())-frame.size.x/frame.size.y) < 0.02,"Pièce %s au format de son cadre" % key)
	for number in range(51,61):
		var id: String = str(Catalogue.definition(number).map_id)
		check(MarshArt.pool_layer(id).is_empty() and MarshArt.prop_texture(id,"ruin",2) == null,"Mission %d : bassins et objets vectoriels en attendant l'avis du porteur" % number)
	check(MarshArt.prop_texture("valley_ford","willow",1) == null,"Pas de pièce des marais hors des missions 41 à 50")

## Plus aucune carte refondue sans décor (v0.242) : garnison, aire de l'aigle, côtes et nécropole ont leurs pièces.
func verify_all_active() -> void:
	check(Decor.REWORKED_MAPS.is_empty(),"Aucune carte refondue n'est privée de décor")
	for number in [91,100,151,160,161,180,181,200]:
		var definition: Dictionary = Catalogue.definition(number)
		var board: Dictionary = Model.Maps.for_id(str(definition.map_id))
		for faction in [0,1]:
			check(not Decor.props(str(definition.map_id),str(board.decoration),faction).is_empty(),"Mission %d : décor refait affiché (faction %d)" % [number,faction])
