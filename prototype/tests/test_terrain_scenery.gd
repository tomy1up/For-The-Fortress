extends SceneTree
const View = preload("res://scripts/valley_view.gd")
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Main = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var layouts: Dictionary = {}
	for number in range(1,11):
		var definition: Dictionary = Model.Maps.for_id(Catalogue.definition(number).map_id)
		var original: String = JSON.stringify(Model.Maps.to_data(definition))
		var m = Model.new(true,definition);m.configure_enemy_hp(99+number);m.select_faction(0);m.rng.seed = 123
		var before: Dictionary = {"rng":m.rng.state,"gold":m.gold,"hp":m.fortress_hp,"actions":m.action_history.duplicate(true)}
		var view = View.new();view.model = m
		var scenery: Array[Dictionary] = view.terrain_details
		check(scenery == View.scenery_for(definition) and scenery == View.scenery_for(definition.duplicate(true)),"Le décor reste identique entre recalculs et copies de la même carte")
		check(scenery.is_empty() if number < 4 else scenery.size() >= 6 and scenery.size() <= 22,"Décor ajouté seulement aux sept nouveaux terrains, en quantité limitée")
		var kinds: Dictionary = {}
		for item in scenery:
			kinds[item.kind] = true
			var area: Rect2 = View.scenery_bounds(item)
			var board := PackedVector2Array([View.project(Vector2.ZERO),View.project(Vector2(18,0)),View.project(Vector2(18,10)),View.project(Vector2(0,10))])
			for point in [area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]: check(Geometry2D.is_point_in_polygon(point,board),"Les silhouettes décoratives restent sur la surface du plateau")
			check(not area.intersects(View.fortress_bounds(View.project(definition.path_points[-1])).grow(12)),"Le décor laisse la forteresse et sa marge libres")
			for segment in range(1,definition.path_points.size()): check(not View._segment_in_rect(View.project(definition.path_points[segment-1]),View.project(definition.path_points[segment]),area.grow(20)),"Les branches, rochers et buissons laissent le chemin libre")
			for slot in definition.slots:
				var center: Vector2 = View.project(slot)
				check(not area.intersects(Rect2(center+Vector2(-26,-13),Vector2(52,40)).grow(4)),"Les cases et leurs libellés ne sont pas recouverts")
				for type in range(6):
					var art = View.AllianceArt if type < 3 else View.HordeArt
					var sprite: Rect2 = art.destination(type);sprite.position += center
					check(not area.intersects(sprite.grow(4)),"Les six silhouettes de défenseurs conservent une zone lisible devant leur emplacement")
		if number >= 4:
			check(kinds.has("shrub") and kinds.has("rock"),"Le terrain comporte plusieurs formes de végétation et relief")
			var key: String = JSON.stringify(scenery)
			check(not layouts.has(key),"Les sept terrains ne répètent pas une même répartition décorative")
			layouts[key] = true
		check(JSON.stringify(Model.Maps.to_data(definition)) == original and m.rng.state == before.rng and m.gold == before.gold and m.fortress_hp == before.hp and m.action_history == before.actions,"Habiller la carte ne change ni géométrie, générateur, économie ou historique du combat")
		var switched = Model.new(true,definition);switched.select_faction(1);view.model = switched
		check(view.terrain_details == scenery,"La faction ne change pas le décor du terrain")
		view.model = Model.new();check(view.terrain_details.is_empty(),"Revenir au Gué ne conserve pas le décor de la mission précédente")
		view.model = null;check(view.terrain_details.is_empty(),"Détacher le modèle efface le cache visuel")
		view.free()
	check(View.scenery_for({}).is_empty() and View.scenery_for({"id":"ford_turns"}).is_empty(),"Définition inconnue ou invalide : aucun décor artificiel")
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false)
		scene.meta_profile = scene.MetaProfile.new("")
		for mission in range(1,4):
			var run: int = scene.meta_profile.begin_mission(faction,Catalogue.id_for(mission),60,10,100);scene.meta_profile.credit_mission(run,faction,10,true)
		scene._open_campaign(faction);scene.campaign_menu._launch()
		check(scene.model.map_definition.id == "ford_turns" and not scene.map_view.terrain_details.is_empty(),"Le lancement réel de la mission 4 remplit son cache décoratif")
		var cached: Array[Dictionary] = scene.map_view.terrain_details
		scene.selected = 0;scene._update_interface();scene.map_view.purchase_preview = {"type":faction*3,"range":4.0}
		check(scene.map_view.terrain_details == cached,"Inspection et préparation d’achat ne replacent pas les décors")
		scene.free()
	print("TERRAIN_SCENERY_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
