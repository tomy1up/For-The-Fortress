extends SceneTree
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func scene_for(faction: int = 0) -> Node:
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
	return scene
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		for speed in [1.0,2.0]:
			var scene = scene_for(faction); scene.speed = speed
			check(scene.map_view.breach_feedback.is_empty(),"Aucune alerte avant la première arrivée")
			scene._start(); scene._process(27.9/speed)
			check(scene.map_view.breach_feedback.is_empty(),"Les apparitions seules ne signalent pas de dégâts")
			scene._process(0.1/speed)
			check(scene.model.total_escaped == 1 and scene.model.fortress_hp == 19 and scene.model.gold == 150,"Arrivée réelle sans récompense ou dépense nouvelle")
			check(scene.map_view.breach_feedback == {"count":1,"damage":1} and scene.breach_remaining == 2.5,"Première fuite : quantité et perte exactes, durée entière")
			check(scene.hp_label.get_theme_color("font_color") == Color("ef9b89"),"Compteur de PV mis en évidence")
			scene._process(1.0)
			check(is_equal_approx(scene.breach_remaining,1.5),"Durée de lecture en secondes réelles, indépendante du ×2")
			scene._process(1.5/speed) # Arrivée du Pillard suivant à 30,5 s simulées.
			check(scene.model.total_escaped == 2 and scene.map_view.breach_feedback.damage == 1,"Une nouvelle arrivée remplace le dernier signal plutôt que cumuler les anciens dégâts")
			scene.free()
	# Plusieurs arrivées simultanées : afficher les PV réellement perdus, plafonnés à zéro.
	var scene = scene_for()
	scene.model.fortress_hp = 3
	scene.model.spawn_schedule.assign([{"time":0.0,"type":3},{"time":0.0,"type":3}])
	scene._start(); scene._process(40.0)
	check(scene.model.phase == "defeat" and scene.model.total_escaped == 2,"Deux Brutes conduisent à une vraie défaite")
	check(scene.map_view.breach_feedback == {"count":2,"damage":3},"Alerte de groupe : perte réelle de 3 PV, pas les 4 dégâts théoriques")
	check(scene.breach_remaining == 2.5 and not scene.autoplay_started,"Dernière alerte lisible après défaite sans relance automatique")
	var before: Array = [scene.model.gold,scene.model.fortress_hp,scene.model.rng.state,scene.model.elapsed,scene.model.wave_history.duplicate(true)]
	scene._process(2.5)
	check(scene.map_view.breach_feedback.is_empty() and scene.breach_remaining == 0.0,"Alerte expirée hors combat")
	check(scene.hp_label.get_theme_color("font_color") == Color("e2d5ad"),"Couleur de PV normale après expiration")
	check(before == [scene.model.gold,scene.model.fortress_hp,scene.model.rng.state,scene.model.elapsed,scene.model.wave_history],"Expiration sans mutation de la partie terminée")
	scene._reset()
	check(scene.choosing_faction and scene.map_view.breach_feedback.is_empty(),"Nouvel essai sans ancien avertissement")
	scene.free()
	scene = scene_for(); scene._start(); scene._process(1000)
	check(scene.model.phase == "finished" and scene.map_view.breach_feedback == {"count":10,"damage":10},"Longue image : signal agrégé, aucune perte inventée")
	check(scene.countdown_remaining == 30,"Le signal ne consomme pas le nouveau délai de préparation")
	scene._start()
	check(scene.model.wave == 2 and scene.map_view.breach_feedback.is_empty() and scene.breach_remaining == 0.0,"Départ suivant efface le signal de l'ancienne vague")
	scene.free()
	scene = scene_for(); scene.model.buy(0,0); scene.model.buy(1,1); scene._start(); scene._process(1000)
	check(scene.model.total_killed == 10 and scene.map_view.breach_feedback.is_empty(),"Une vague sans fuite ne produit pas d'alerte")
	scene.model.fortress_hp += 4; scene._process(0)
	check(scene.map_view.breach_feedback.is_empty(),"Un gain de PV ne produit pas d'alerte")
	scene.free()
	check(View.breach_text(1,1) == "−1 PV · 1 ennemi passé" and View.breach_text(2,3) == "−3 PV · 2 ennemis passés","Libellés singulier et pluriel")
	print("BREACH_FEEDBACK_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
