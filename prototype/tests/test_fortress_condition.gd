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
	print("FORTRESS_CONDITION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
