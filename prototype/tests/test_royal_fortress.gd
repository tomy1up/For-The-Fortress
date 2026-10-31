extends SceneTree
const View = preload("res://scripts/valley_view.gd")
const Art = View.FortressArt
const Model = View.Model
const Main = preload("res://scripts/main.gd")
const Catalogue = Main.CampaignCatalogue
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.defenders,scene.model.damage_events])
func run_checks() -> void:
	check(Art.BUILDINGS[0] != Art.BUILDINGS[1] and Art.KINGS[0] != Art.KINGS[1],"Chaque faction a son bâtiment et son souverain, sans simple recoloration en jeu")
	for texture in Art.BUILDINGS+Art.KINGS:
		var image: Image = texture.get_image()
		check(not image.is_empty() and image.detect_alpha() != Image.ALPHA_NONE,"Illustration transparente réellement chargée")
		check(image.get_pixel(0,0).a < 0.01 and image.get_pixel(image.get_width()-1,image.get_height()-1).a < 0.01,"Aucun fond opaque dans les quatre illustrations")
	for faction in [0,1]:
		var castle: Rect2 = Art.building_rect(faction)
		check(is_equal_approx(castle.size.x/castle.size.y,Art.SOURCES[faction].size.x/Art.SOURCES[faction].size.y),"Bâtiment sans étirement")
		check(Rect2(Vector2.ZERO,Art.BUILDINGS[faction].get_size()).encloses(Art.SOURCES[faction]),"Cadre contenu dans le bâtiment d’origine")
		for pose in range(4):
			var frame: Dictionary = Art.KING_FRAMES[faction][pose]
			check(Rect2(Vector2.ZERO,Art.KINGS[faction].get_size()).encloses(frame.source),"Les quatre poses sont contenues dans l’atlas")
			var target: Rect2 = Art.king_rect(faction,pose)
			check(is_equal_approx(target.end.y,0.0) and target.position.x < 0 and target.end.x > 0,"Les bottes gardent le même ancrage sur le toit")
			check(is_equal_approx(target.size.x/target.size.y,frame.source.size.x/frame.source.size.y),"Souverain sans déformation ni normalisation abusive de la pose recroquevillée")
			for other in range(pose+1,4): check(not frame.source.intersects(Art.KING_FRAMES[faction][other].source),"Les poses voisines ne se mélangent pas dans l’atlas")
			for phase in [0.0,0.1,0.3,1.0,4.0,6.0]:
				var transform: Transform2D = Art.king_transform(pose,phase,0.2)
				check(transform.is_finite() and is_equal_approx(transform.determinant(),1.0),"Animation royale rigide et finie")
				var bound: Rect2 = View.fortress_bounds(Vector2(-68,-26))
				for corner in [target.position,Vector2(target.end.x,target.position.y),target.end,Vector2(target.position.x,target.end.y)]:
					check(bound.has_point(Art.king_anchor(faction)+transform*corner+Art.shake(0.2)),"Roi animé contenu dans la silhouette réservée au bâtiment")
	for number in range(1,21):
		var data: Dictionary = Model.Maps.for_id(Catalogue.definition(number).map_id)
		var bounds: Rect2 = View.fortress_bounds(View.project(data.path_points[-1]))
		for slot in data.slots: check(not bounds.has_point(View.project(slot)),"Centre de placement dégagé : mission %d, position %s, projection %s, bâtiment %s" % [number,str(slot),str(View.project(slot)),str(bounds)])
	check(Art.king_pose(20,2,2) == 0 and Art.king_pose(20,2,0) == 1,"Repos et encouragement dépendent de l’événement de vague")
	check(Art.king_pose(10,0,0) == 2 and Art.king_pose(0,0,0) == 2 and Art.king_pose(0,0.65,0) == 3,"Priorité à l’impact, puis défaite quand la forteresse est détruite")
	check(Art.king_pose(20,-1,-1) == 0 and Art.shake(-1) == Vector2.ZERO and Art.shake(0.35) == Vector2.ZERO,"Pas d’animation future ni de tremblement permanent")
	for faction in [0,1]:
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		var view = scene.map_view
		check(Art.king_pose(scene.model.fortress_hp,view.royal_hurt_age,view.royal_rally_age) == 0,"Nouveau départ sans ancien salut ou choc")
		scene._start()
		check(view.royal_rally_age == 0.0 and Art.king_pose(20,view.royal_hurt_age,view.royal_rally_age) == 1,"Le vrai lancement de vague déclenche l’encouragement")
		view._process(0.2);var rally_before: float = view.royal_rally_age;scene._start()
		check(view.royal_rally_age == rally_before,"Un lancement refusé ne redéclenche pas l’animation")
		scene._process(60.0)
		check(scene.model.fortress_hp == 10 and view.royal_hurt_age == 0.0 and Art.king_pose(10,view.royal_hurt_age,view.royal_rally_age) == 2,"Dix vraies arrivées réduisent les PV et font réagir le roi")
		var before: String = signature(scene)
		for delta in [0.1,0.3,0.4,1000.0]:
			view._process(delta);view.queue_redraw();await process_frame
			check(signature(scene) == before,"Animation royale sans changement de modèle, d’économie, de récompense ou de RNG")
		check(view.royal_hurt_age == 2.0 and view.royal_rally_age == 2.0,"Extinction bornée après une longue image")
		scene.model.fortress_hp = 4;view.reset_royal_animation();scene.model.phase = "bonus";scene.model.bonus_offer.assign([8]);scene.model.choose_bonus(8)
		check(view.royal_hurt_age == 2.0 and Art.king_pose(scene.model.fortress_hp,view.royal_hurt_age,view.royal_rally_age) == 0,"Un soin de forteresse ne simule pas une blessure royale")
		scene.model.reset();scene.model.select_faction(faction);scene.model.wave = 10;scene.model.spawn_schedule = Model.Campaign.schedule(10)
		scene._start();scene._process(300)
		check(scene.model.phase == "defeat" and view.royal_hurt_age == 0.0,"Une vraie défaite commence par la réaction à l’impact fatal")
		view._process(0.8)
		check(Art.king_pose(scene.model.fortress_hp,view.royal_hurt_age,view.royal_rally_age) == 3,"Le souverain adopte ensuite la pose de défaite")
		scene._reset()
		check(view.royal_hurt_age == 2.0 and view.royal_rally_age == 2.0 and scene.model.fortress_hp == 20,"Recommencer efface la réaction de l’ancienne partie")
		scene.queue_free();await process_frame
	print("ROYAL_FORTRESS_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
