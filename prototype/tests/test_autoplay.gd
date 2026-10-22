extends SceneTree
const Main = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func scene_for(faction: int = 0) -> Node:
	var scene = Main.new()
	root.add_child(scene)
	scene.set_process(false)
	scene._choose_faction(faction)
	return scene
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var scene = scene_for()
	scene._process(1000)
	check(scene.model.wave == 1 and scene.model.phase == "preparation" and not scene.autoplay_started,"Premier lancement toujours manuel")
	scene.selected = 0; scene._buy(0)
	scene.selected = 1; scene._buy(1)
	scene._start(); scene._process(1000)
	check(scene.model.phase == "finished" and scene.countdown_remaining == 60 and scene.autoplay_started,"Délai complet après une longue image de combat")
	check(scene.start_button.text == "Vague 2 dans 60 s" and scene.status_label.text.contains("60 s"),"Compte à rebours visible")
	scene._toggle_speed(); scene._process(59)
	check(scene.speed == 2 and scene.countdown_remaining == 1 and scene.model.wave == 1,"Le x2 ne raccourcit pas les secondes de préparation")
	scene._process(0.5)
	check(scene.model.wave == 1 and scene.countdown_remaining == 0.5,"Pas de départ avant l'échéance")
	scene._process(0.5)
	check(scene.model.wave == 2 and scene.model.active and scene.model.elapsed == 0 and scene.model.spawned == 1,"Départ automatique à l'échéance, première apparition à t0")
	scene._process(1000)
	check(scene.model.phase == "finished" and scene.model.wave == 2 and scene.countdown_remaining == 60,"Nouveau délai sans réutiliser le précédent")
	scene._show_bonuses(); scene._process(1000)
	check(scene.model.wave == 2 and scene.countdown_remaining == 60 and scene.start_button.text.contains("En pause"),"Lecture des bonus pendant la préparation : décompte suspendu")
	scene._close_bonuses(); scene._process(1)
	check(scene.countdown_remaining == 59,"Fermeture du récapitulatif reprend le temps restant")
	scene._start()
	check(scene.model.wave == 3 and scene.model.active,"Lancement anticipé toujours possible")
	scene._show_bonuses()
	scene._process(1000)
	check(scene.model.phase == "bonus" and scene.countdown_remaining == -1 and not scene.overview_open,"Le choix roguelite remplace le récapitulatif, sans délai actif")
	scene._process(10000); scene._start()
	check(scene.model.wave == 3 and scene.model.phase == "bonus" and scene.model.bonuses.is_empty(),"Le choix n'expire pas et le lancement forcé reste bloqué")
	scene._choose_bonus(0)
	check(scene.model.phase == "finished" and scene.countdown_remaining == 60,"Après choix, soixante secondes entières")
	scene._process(12); scene._reset(); scene._choose_faction(1); scene._process(1000)
	check(scene.model.wave == 1 and scene.model.phase == "preparation" and not scene.autoplay_started and scene.countdown_remaining == -1,"Nouvel essai désarme l'automatisme et le délai")
	scene.free()
	# Budget imposé exclusivement pour couvrir les deux issues du dialogue N4.
	scene = scene_for(); scene.model.gold = 1000; scene.selected = 0
	scene._buy(0); scene._upgrade(); scene._upgrade(); scene._start(); scene._process(1000); scene._process(15)
	var before: int = scene.model.gold
	scene._upgrade(); scene._process(1000)
	check(scene.pending_slot == 0 and scene.model.phase == "finished" and scene.countdown_remaining == 45 and scene.model.gold == before,"N4 suspend le délai sans débit")
	scene._cancel_specialisation()
	check(scene.countdown_remaining == 45 and scene.model.defenders[0].level == 3,"Annulation conserve niveau et délai restant")
	scene._upgrade(); scene._choose_branch(0)
	check(scene.countdown_remaining == 45 and scene.model.defenders[0].level == 4 and scene.model.gold == before-150,"Confirmation N4 reprend le même délai et paie une seule fois")
	scene._process(45)
	check(scene.model.wave == 2 and scene.model.active,"Le départ reprend après résolution du choix N4")
	scene.free()
	# Une défaite arrête le flux même sans aucune intervention après la vague 1.
	scene = scene_for(); scene._start(); scene._process(1000); scene._process(60); scene._process(1000)
	check(scene.model.phase == "defeat" and not scene.autoplay_started and scene.countdown_remaining == -1,"Défaite sans nouveau délai")
	var fatal_wave: int = scene.model.wave
	scene._process(10000)
	check(scene.model.wave == fatal_wave and scene.model.phase == "defeat","Aucune reprise après défaite")
	scene.free()
	# Deux campagnes financées normalement : un seul premier clic de lancement.
	for faction in range(2):
		scene = scene_for(faction); scene.model.rng.seed = 42
		scene.selected = 0; scene._buy(0)
		scene.selected = 1; scene._buy(1)
		scene._start()
		for wave in range(1,11):
			check(scene.model.wave == wave and scene.model.active,"Vague successive lancée automatiquement")
			scene._process(1000)
			if wave == 10: break
			if wave in [3,6,9]:
				scene._process(1000)
				check(scene.model.phase == "bonus" and scene.countdown_remaining == -1,"Offre après 3/6/9 attend le joueur")
				scene._choose_bonus(0)
			check(scene.countdown_remaining == 60,"Délai complet avant chaque vague")
			if wave+1 >= 4 and scene.model.defenders[2].is_empty():
				scene.selected = 2; scene._buy(2)
			if wave+1 >= 5:
				for slot in [0,1,2]:
					scene.selected = slot; scene._upgrade()
					if scene.pending_slot >= 0: scene._choose_branch(0)
			var paid: int = 0
			for unit in scene.model.defenders:
				if not unit.is_empty(): paid += unit.paid
			check(scene.model.gold == 150+scene.model.total_income-paid,"Conservation de l'économie pendant le délai")
			scene._process(59.9)
			check(scene.model.wave == wave and not scene.model.active,"La préparation ne finit pas en avance")
			scene._process(0.2)
		check(scene.model.phase == "victory" and scene.model.fortress_hp == [14,12][faction] and scene.model.gold == [192,189][faction],"Mêmes références financées avec enchaînement automatique")
		check(scene.countdown_remaining == -1 and not scene.autoplay_started,"Victoire désarme l'automatisme")
		scene._process(10000)
		check(scene.model.wave == 10 and scene.model.phase == "victory","Jamais de vague 11")
		scene.free()
	print("AUTOPLAY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
