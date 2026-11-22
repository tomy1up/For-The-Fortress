extends SceneTree
const View = preload("res://scripts/valley_view.gd")
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for sample in [[20,20,0],[11,20,0],[10,20,1],[6,20,1],[5,20,2],[1,20,2],[0,20,3],[-1,20,3],[31,31,0],[16,31,0],[15,31,1],[8,31,1],[7,31,2],[100,20,0],[10,0,0]]:
		check(View.fortress_condition(sample[0],sample[1]) == sample[2],"État selon la proportion réelle des PV, bornes et maximum renforcé")
	check(View.fortress_caption(1).contains("ENDOMMAGÉE") and View.fortress_caption(2).contains("EN DANGER") and View.fortress_caption(3).contains("DÉTRUITE"),"État explicite sans dépendre des seules couleurs")
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		for hp in [20,10,4,0]:
			scene.model.fortress_hp = hp
			var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders])
			scene.map_view._process(0.5);scene.map_view.queue_redraw();await process_frame
			check(before == JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders]),"Fissures et fumée ne modifient ni PV, défenses, économie ni aléatoire")
			check(not View.fortress_bounds(View.project(scene.model.PATH_POINTS[-1])).has_point(View.project(scene.model.SLOTS[5])),"Repère E6 dégagé dans chaque état")
		# Une amélioration réelle soigne : l'état visuel doit suivre les PV courants.
		scene.model.fortress_hp = 4;scene.model.phase = "bonus";scene.model.bonus_offer.assign([8])
		check(scene.model.choose_bonus(8) and scene.model.fortress_hp == 8 and scene.model.max_hp == 24 and View.fortress_condition(scene.model.fortress_hp,scene.model.max_hp) == 1,"Soin de R-09 reflété immédiatement sans état critique figé")
		scene.model.reset();check(View.fortress_condition(scene.model.fortress_hp,scene.model.max_hp) == 0,"Nouvelle partie : forteresse saine sans ancien dommage")
		scene.free()
	verify_damage_overlays()
	print("FORTRESS_CONDITION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

## Calques de dégâts (v0.241, lot c81b52a de Codex) : un calque par faction et par état, au cadre de l'illustration, à la place de la fissure générique,
## posé sur le bâtiment avec sa luminosité et dessiné avant la fumée et le roi.
func verify_damage_overlays() -> void:
	const FortressArt = preload("res://scripts/fortress_art.gd")
	for faction in range(2):
		check(FortressArt.damage_overlay(faction,0) == null and FortressArt.damage_overlay(faction,4) == null,"Forteresse intacte : aucun calque de dégâts")
		var source: Rect2 = FortressArt.SOURCES[faction]
		var seen: Array = []
		for condition in range(1,4):
			var overlay: Texture2D = FortressArt.damage_overlay(faction,condition)
			check(overlay != null and overlay not in seen,"Calque propre à l'état %d (faction %d)" % [condition,faction])
			if overlay == null: continue
			seen.append(overlay)
			check(overlay.get_size() == Vector2([368,368][faction],[348,342][faction]),"Calque de %d × %d px (faction %d)" % [368,[348,342][faction],faction])
			check(absf(overlay.get_size().x/overlay.get_size().y-source.size.x/source.size.y) < 0.01,"Calque au cadre de la région affichée de l'illustration (faction %d)" % faction)
	check(FortressArt.damage_overlay(2,1) == FortressArt.damage_overlay(0,1),"Une faction inconnue reprend l'habillage de l'Alliance, comme le bâtiment")
	var source_text: String = FileAccess.get_file_as_string("res://scripts/valley_view.gd")
	var start: int = source_text.find("func _draw_fortress(anchor: Vector2) -> void:")
	var body: String = source_text.substr(start,source_text.find("\nfunc ",start+10)-start)
	var building: int = body.find("draw_texture_rect_region(FortressArt.BUILDINGS[faction]")
	var overlay_call: int = body.find("draw_texture_rect(damage,body,false,Color(brightness,brightness,brightness,1))")
	check(building >= 0 and overlay_call > building and overlay_call < body.find("for index in range(3):") and overlay_call < body.find("FortressArt.KINGS[faction]"),"Calque posé sur le bâtiment, avec sa luminosité, avant la fumée et le roi")
	check(not body.contains("352f25"),"La fissure générique est remplacée")
