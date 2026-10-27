extends SceneTree
const Main = preload("res://scripts/main.gd")
# Les nettoyages de nouvelle partie sont testés après une défaite simulée ; les verrous de parcours sont couverts séparément.
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
	check(not scene.countdown_bar.visible and scene.countdown_bar.mouse_filter == Control.MOUSE_FILTER_IGNORE and scene.countdown_bar.focus_mode == Control.FOCUS_NONE,"Pas de barre avant le premier départ ; elle ne capte ni clic ni focus")
	scene.selected = 0; scene._buy(0)
	scene.selected = 1; scene._buy(1)
	scene._start(); scene._process(1000)
	check(scene.model.phase == "finished" and scene.countdown_remaining == 30 and scene.autoplay_started,"Délai complet après une longue image de combat")
	check(scene.start_button.text == "Vague 2 dans 30 s" and scene.status_label.text.contains("30 s"),"Compte à rebours visible")
	check(scene.countdown_bar.visible and scene.countdown_bar.max_value == 30 and scene.countdown_bar.value == 30,"Barre entière au début de la préparation")
	scene._toggle_speed(); scene._process(29)
	check(scene.speed == 2 and scene.countdown_remaining == 1 and scene.model.wave == 1,"Le x2 ne raccourcit pas les secondes de préparation")
	check(scene.countdown_bar.visible and scene.countdown_bar.value == 1,"Barre suit les secondes réelles restantes malgré le x2")
	scene._process(0.5)
	check(scene.model.wave == 1 and scene.countdown_remaining == 0.5,"Pas de départ avant l'échéance")
	scene._process(0.5)
	check(scene.model.wave == 2 and scene.model.active and scene.model.elapsed == 0 and scene.model.spawned == 1,"Départ automatique à l'échéance, première apparition à t0")
	check(not scene.countdown_bar.visible,"Départ automatique : barre retirée pendant le combat")
	scene._process(1000)
	check(scene.model.phase == "finished" and scene.model.wave == 2 and scene.countdown_remaining == 30,"Nouveau délai sans réutiliser le précédent")
	scene._show_bonuses(); scene._process(1000)
	check(scene.model.wave == 2 and scene.countdown_remaining == 30 and scene.start_button.text.contains("En pause"),"Lecture des bonus pendant la préparation : décompte suspendu")
	check(scene.countdown_bar.visible and scene.countdown_bar.value == 30,"Lecture : barre figée avec le délai suspendu")
	scene._close_bonuses(); scene._process(1)
	check(scene.countdown_remaining == 29,"Fermeture du récapitulatif reprend le temps restant")
	scene._start()
	check(scene.model.wave == 3 and scene.model.active,"Lancement anticipé toujours possible")
	scene._show_bonuses()
	scene._process(1000)
	check(scene.model.phase == "bonus" and scene.countdown_remaining == -1 and not scene.overview_open,"Le choix roguelite remplace le récapitulatif, sans délai actif")
	check(not scene.countdown_bar.visible,"Aucune barre de délai pendant un choix obligatoire")
	scene._process(10000); scene._start()
	check(scene.model.wave == 3 and scene.model.phase == "bonus" and scene.model.bonuses.is_empty(),"Le choix n'expire pas et le lancement forcé reste bloqué")
	scene._choose_bonus(0)
	check(scene.model.phase == "finished" and scene.countdown_remaining == 30,"Après choix, trente secondes entières")
	check(scene.countdown_bar.visible and scene.countdown_bar.value == 30,"Après choix : barre réarmée au délai complet")
	scene._process(12); scene.model.phase = "defeat"; scene._reset(); scene._choose_faction(1); scene._process(1000)
	check(scene.model.wave == 1 and scene.model.phase == "preparation" and not scene.autoplay_started and scene.countdown_remaining == -1,"Nouvel essai désarme l'automatisme et le délai")
	check(not scene.countdown_bar.visible,"Nouvel essai retire la barre de l’ancienne partie")
	scene.free()
	# Budget imposé exclusivement pour couvrir les deux issues du dialogue N4.
	scene = scene_for(); scene.model.gold = 1000; scene.selected = 0
	scene._buy(0); scene._upgrade(); scene._upgrade(); scene._start(); scene._process(1000); scene._process(15)
	var before: int = scene.model.gold
	scene._upgrade(); scene._process(1000)
	check(scene.pending_slot == 0 and scene.model.phase == "finished" and scene.countdown_remaining == 15 and scene.model.gold == before,"N4 suspend le délai sans débit")
	check(scene.countdown_bar.visible and scene.countdown_bar.value == 15,"Spécialisation : la barre conserve le temps restant")
	scene._cancel_specialisation()
	check(scene.countdown_remaining == 15 and scene.model.defenders[0].level == 3,"Annulation conserve niveau et délai restant")
	scene._upgrade(); scene._choose_branch(0)
	check(scene.countdown_remaining == 15 and scene.model.defenders[0].level == 4 and scene.model.gold == before-150,"Confirmation N4 reprend le même délai et paie une seule fois")
	scene._process(15)
	check(scene.model.wave == 2 and scene.model.active,"Le départ reprend après résolution du choix N4")
	scene.free()
	# Une défaite arrête le flux même sans aucune intervention après la vague 1.
	scene = scene_for(); scene._start(); scene._process(1000); scene._process(30); scene._process(1000)
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
			check(scene.countdown_remaining == 30,"Délai complet avant chaque vague")
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
			scene._process(29.9)
			check(scene.model.wave == wave and not scene.model.active,"La préparation ne finit pas en avance")
			scene._process(0.2)
		check(scene.model.phase == "victory" and scene.model.fortress_hp == [14,12][faction] and scene.model.gold == [192,189][faction],"Mêmes références financées avec enchaînement automatique")
		check(scene.countdown_remaining == -1 and not scene.autoplay_started,"Victoire désarme l'automatisme")
		check(not scene.countdown_bar.visible,"Les deux factions terminent sans barre de préparation")
		scene._process(10000)
		check(scene.model.wave == 10 and scene.model.phase == "victory","Jamais de vague 11")
		scene.free()
	print("AUTOPLAY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
