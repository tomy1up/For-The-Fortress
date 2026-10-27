extends SceneTree
const Main = preload("res://scripts/main.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func new_scene(faction: int) -> Node:
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
	return scene
func run_checks() -> void:
	var scene = new_scene(0)
	for expected in [2.0,10.0,1.0]:
		scene.speed_button.pressed.emit()
		check(scene.speed == expected,"Cycle de vitesse : 1, 2, 10 puis 1")
		check(scene.speed_button.text.contains("debug") == (expected == 10.0),"Le mode dix fois est explicitement temporaire de débogage")
	scene.free()
	for faction in range(2):
		var runs: Array[Dictionary] = []
		for multiplier in [1.0,2.0,10.0]:
			scene = new_scene(faction); scene.speed = multiplier
			scene.selected = 0; scene._buy(0); scene.selected = 1; scene._buy(1)
			scene._start()
			var frames := 0
			while scene.model.active and frames < 2000:
				scene._process(0.1); frames += 1
			check(scene.model.phase == "finished" and frames < 2000,"La même première vague se termine aux trois vitesses")
			runs.append({"events":scene.model.event_log.duplicate(),"gold":scene.model.gold,"hp":scene.model.fortress_hp,"killed":scene.model.killed,"escaped":scene.model.escaped,"seconds":scene.model.elapsed})
			check(scene.countdown_remaining == 30.0,"Le combat rapide conserve 30 secondes réelles de préparation")
			scene._process(29)
			check(scene.countdown_remaining == 1.0 and scene.model.wave == 1,"Aucun départ anticipé par le multiplicateur de vitesse")
			scene._show_bonuses(); scene._process(100)
			check(scene.countdown_remaining == 1.0,"Lecture du récapitulatif : délai suspendu aussi en ×10")
			scene._close_bonuses(); scene._process(1)
			check(scene.model.wave == 2 and scene.model.active,"Le départ automatique fonctionne après les 30 secondes réelles")
			scene.model.phase = "bonus"; scene.model.bonus_offer.assign([0,1,2]); scene._update_interface(); scene._process(1000)
			check(scene.model.phase == "bonus" and scene.model.bonuses.is_empty() and scene.countdown_remaining < 0,"Le choix obligatoire n'est jamais accéléré ou validé automatiquement")
			scene._reset()
			check(scene.model.phase == "bonus" and not scene.choosing_faction,"Le choix obligatoire protège aussi le redémarrage forcé")
			scene._choose_bonus(0); scene.model.phase = "defeat"; scene._reset()
			check(scene.speed == 1.0 and scene.choosing_faction,"Nouvel essai revient en ×1")
			scene.free()
		check(runs[0] == runs[1] and runs[1] == runs[2],"Même journal, économie, pertes et durée simulée en ×1, ×2 et ×10")
	scene = new_scene(0); scene.speed = 10.0
	scene.model.spawn_schedule.assign([{"time":0.0,"type":1}]) # Une seule percée pour contrôler sa durée de lecture.
	scene._start(); scene._process(2.8)
	check(scene.map_view.breach_feedback == {"count":1,"damage":1} and scene.breach_remaining == 2.5,"La percée reste visible pendant sa durée entière à ×10")
	scene._process(1.0)
	check(scene.breach_remaining == 1.5,"L'alerte de percée utilise des secondes réelles aussi en mode debug")
	scene._process(1.5)
	check(scene.map_view.breach_feedback.is_empty() and scene.countdown_remaining == 27.5,"Expiration du signal indépendante de la préparation, sans accélérer celle-ci")
	scene.free()
	print("DEBUG_SPEED_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
