extends SceneTree
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders,scene.model.shots])
func run_checks() -> void:
	check(View.attack_pulse(-0.01) == 0.0 and View.attack_pulse(1.0) == 0.0,"Aucun mouvement pour un tir futur ou ancien")
	check(View.attack_pulse(0.0) == 0.0 and View.attack_pulse(View.ATTACK_POSE_DURATION) == 0.0,"Retour exact à la pose de repos aux deux bornes")
	check(is_equal_approx(View.attack_pulse(View.ATTACK_POSE_DURATION/2),1.0),"Amplitude maximale au milieu du mouvement")
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.model.gold = 10000 # Catalogue des niveaux, pas une campagne d’équilibrage.
		for slot in range(6):
			scene.model.buy(slot,faction*3+slot%3)
			for step in range([1,2,3,4,4,4][slot]-1): scene.model.upgrade(slot,slot%2 if step == 2 else -1)
		var before: String = signature(scene)
		for frame in range(3):
			scene.map_view.queue_redraw(); await process_frame
		check(signature(scene) == before,"Dessiner six silhouettes et badges ne modifie ni or, niveaux, RNG ni rapport")
		for slot in range(6): check(scene.map_view.defender_pose(slot).pulse == 0.0,"Défense immobile avant le premier combat")
		# Vrais événements : le rendu doit retrouver chaque tireur et son impact.
		for type in range(faction*3,faction*3+3):
			scene.model.reset(); scene.model.select_faction(faction); scene.model.gold = 1000
			scene.model.buy(1,type); scene.model.start()
			for step in range(1000):
				scene.model.advance(0.01)
				if not scene.model.shots.is_empty(): break
			check(not scene.model.shots.is_empty(),"Chaque défenseur produit un vrai tir de contrôle")
			if scene.model.shots.is_empty(): continue
			scene.model.advance(View.ATTACK_POSE_DURATION/2)
			var pose: Dictionary = scene.map_view.defender_pose(1)
			check(pose.pulse > 0.9,"Le tireur bouge après son propre tir")
			check(scene.map_view.defender_pose(0).pulse == 0.0,"Le tir d’un emplacement n’anime pas son voisin")
			var shot: Dictionary = scene.model.shots[-1]
			var expected_direction: float = -1.0 if View.project(shot.to).x < View.project(shot.from).x else 1.0
			check(pose.direction == expected_direction,"Le recul suit le côté de l’impact réel")
			before = signature(scene)
			for frame in range(3):
				scene.map_view.defender_pose(1); scene.map_view.queue_redraw(); await process_frame
			check(signature(scene) == before,"Répéter les images ne produit ni temps de combat, tir, dégâts ou aléatoire supplémentaire")
			scene.model.advance(View.ATTACK_POSE_DURATION)
			check(scene.map_view.defender_pose(1).pulse == 0.0,"Le mouvement se termine sans laisser le défenseur déformé")
			scene.model.phase = "finished"
			check(scene.map_view.defender_pose(1).pulse == 0.0,"Une fin de vague ne conserve pas un mouvement figé")
		# Deux événements récents sur des emplacements distincts, puis un tir futur.
		scene.model.phase = "combat"; scene.model.elapsed = 10.0
		scene.model.shots.assign([
			{"time":9.87,"slot":1,"from":Vector2.ZERO,"to":Vector2(-1,0)},
			{"time":9.9,"slot":2,"from":Vector2.ZERO,"to":Vector2(1,0)},
			{"time":10.1,"slot":1,"from":Vector2.ZERO,"to":Vector2(1,0)}])
		check(scene.map_view.defender_pose(1).direction == -1.0,"Ignorer un tir futur sans perdre le vrai tir du même emplacement")
		check(scene.map_view.defender_pose(2).direction == 1.0 and scene.map_view.defender_pose(0).pulse == 0.0,"Distinguer des attaques simultanées sans état visuel partagé")
		scene.queue_free(); await process_frame
	print("DEFENDER_PRESENTATION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
