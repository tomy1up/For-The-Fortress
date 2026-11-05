extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
# Les nettoyages de nouvelle partie sont testés après une défaite simulée ; les verrous de parcours sont couverts séparément.
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func snapshot(m: RefCounted) -> Array:
	return [m.gold,m.defenders.duplicate(true),m.next_instance_id,m.rng.state,m.bonuses.duplicate(),m.phase,m.elapsed,m.wave]
func specialise(m: RefCounted, slot: int, branch: int) -> void:
	m.upgrade(slot); m.upgrade(slot); m.upgrade(slot,branch)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	for type in range(6):
		for target in [2,3,4]:
			for branch in [0,1] if target == 4 else [-1]:
				for boosted in [false,true]:
					var m = Model.new(); m.select_faction(0 if type < 3 else 1); m.gold = 10000 # Budget de contrôle.
					m.buy(0,type)
					for level in range(1,target-1): m.upgrade(0)
					if boosted: m.bonuses.assign([0,1,2,3,4,6,7,9])
					if target == 4:
						for rule in Model.Campaign.SPECIALISATIONS:
							var side: int = rule.types.find(type)
							if side >= 0 and rule.branches[side] == branch:
								m.buy(5,rule.types[1-side]); specialise(m,5,rule.branches[1-side])
					m._refresh_windows()
					var before: Array = snapshot(m)
					var preview: Dictionary = m.upgrade_preview_stats(0,branch)
					check(not preview.is_empty(),"Aperçu de chaque niveau et branche")
					check(preview == m.upgrade_preview_stats(0,branch) and snapshot(m) == before,"Comparaisons sans mutation, paiement ni tirage")
					check(m.upgrade(0,branch),"Validation réelle après comparaison")
					check(m.get_stats(0) == preview,"Statistiques réelles identiques à l'aperçu, changements de bonus et synergies compris")
					check(m.defenders[0].windows == Model.coverage_windows(Model.SLOTS[0],preview.range),"Portée bleue conforme aux fenêtres de tir après validation")
	var m = Model.new(); m.gold = 10000; m.buy(0,0); m.bonuses.assign([6]); m.upgrade(0)
	check(is_equal_approx(m.get_stats(0).damage,13.8) and m.upgrade_preview_stats(0).damage == 18,"Recrues aguerries cesse bien dans l'aperçu du niveau 3")
	m.bonuses.assign([7])
	check(m.get_stats(0).damage == 12 and is_equal_approx(m.upgrade_preview_stats(0).damage,20.16),"Vétérans s'active dans l'aperçu du niveau 3")
	check(m.upgrade_preview_stats(-1).is_empty() and m.upgrade_preview_stats(1).is_empty() and m.upgrade_preview_stats(0,0).is_empty(),"Emplacements et choix de branche invalides sans aperçu")
	m.upgrade(0)
	check(m.upgrade_preview_stats(0).is_empty() and m.upgrade_preview_stats(0,2).is_empty(),"Niveau 3 nécessite une des deux branches")
	m.upgrade(0,0)
	check(m.upgrade_preview_stats(0).is_empty(),"Pas d'aperçu au niveau maximum")
	for type in range(6):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0 if type < 3 else 1)
		scene.model.gold = 10000; scene.selected = 0; scene.map_view.selected = 0; scene._buy(type%3)
		var before: Array = snapshot(scene.model)
		scene.upgrade_button.mouse_entered.emit()
		check(scene.title_label.text.contains("APERÇU NIVEAU 2") and scene.details_label.text.contains("→") and not scene.map_view.upgrade_preview.is_empty(),"Survol de l'amélioration compare les valeurs et la portée")
		check(snapshot(scene.model) == before,"Survol sans dépense")
		scene.upgrade_button.mouse_exited.emit()
		check(scene.map_view.upgrade_preview.is_empty() and not scene.title_label.text.contains("APERÇU"),"Sortie du bouton rend la fiche actuelle")
		scene.upgrade_button.focus_entered.emit()
		check(not scene.map_view.upgrade_preview.is_empty(),"Comparaison accessible au clavier")
		scene.model.gold = 0; scene._update_interface()
		check(scene.upgrade_button.disabled and not scene.map_view.upgrade_preview.is_empty() and scene.hint_label.text.contains("Or insuffisant"),"Aperçu possible sans financement, paiement bloqué")
		scene.upgrade_button.pressed.emit()
		check(scene.model.defenders[0].level == 1 and scene.model.gold == 0,"Un clic sans financement ne valide pas l'aperçu")
		scene.model.gold = 10000; scene._upgrade(); scene._upgrade()
		scene.upgrade_button.focus_exited.emit()
		scene.model.phase = "finished"; scene.autoplay_started = true; scene._process(4)
		var remaining: float = scene.countdown_remaining
		var gold: int = scene.model.gold
		scene._upgrade()
		check(scene.pending_slot == 0 and scene.model.defenders[0].level == 3 and scene.model.gold == gold,"Choisir une spécialisation n'améliore pas avant confirmation")
		for branch in [0,1]:
			scene.specialisation_buttons[branch].mouse_entered.emit()
			check(scene.map_view.upgrade_preview.branch_name == Model.stats_for(type,4,branch).branch_name and scene.specialisation_stats[branch].text.contains("→"),"Portée de la branche survolée et comparaison avant/après")
			scene._process(1000)
			check(scene.countdown_remaining == remaining and scene.model.gold == gold and scene.model.defenders[0].level == 3,"Comparer des branches ne consomme ni or ni délai modal")
			scene.specialisation_buttons[branch].mouse_exited.emit()
		check(scene.map_view.upgrade_preview.is_empty(),"Pas de branche présélectionnée à la sortie")
		scene.specialisation_buttons[1].focus_entered.emit()
		check(not scene.map_view.upgrade_preview.is_empty(),"Choix de branche au clavier prévisualisé")
		scene._cancel_specialisation()
		check(scene.model.gold == gold and scene.model.defenders[0].level == 3 and scene.map_view.upgrade_preview.is_empty(),"Annuler retire l'aperçu sans paiement")
		scene._process(1)
		check(scene.countdown_remaining == remaining-1,"Le délai restant reprend après annulation")
		scene._upgrade(); scene.specialisation_buttons[0].mouse_entered.emit()
		var future: Dictionary = scene.map_view.upgrade_preview.duplicate(true)
		scene.specialisation_buttons[0].pressed.emit()
		check(scene.model.defenders[0].level == 4 and scene.model.gold == gold-150 and scene.model.get_stats(0) == future and scene.map_view.upgrade_preview.is_empty(),"Confirmer applique exactement l'aperçu et paie une seule fois")
		scene._choose_branch(0)
		check(scene.model.gold == gold-150,"Seconde confirmation sans effet")
		scene.model.phase = "defeat"; scene._reset()
		check(scene.map_view.upgrade_preview.is_empty() and scene.hovered_branch == -1 and scene.focused_branch == -1,"Réinitialisation sans aperçu résiduel")
		scene.free()
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	scene.selected = 0; scene.map_view.selected = 0; scene._buy(0)
	scene.model.phase = "finished"; scene.autoplay_started = true; scene.upgrade_button.mouse_entered.emit(); scene._process(1)
	check(scene.countdown_remaining == 29 and not scene.map_view.upgrade_preview.is_empty(),"Aperçu d'amélioration ordinaire sans pause du délai")
	scene._show_bonuses()
	check(scene.map_view.upgrade_preview.is_empty(),"Aucun aperçu d'amélioration à travers le récapitulatif")
	scene._close_bonuses(); scene.upgrade_button.mouse_entered.emit(); scene._start()
	check(scene.model.active and scene.map_view.upgrade_preview.is_empty(),"Lancement retire l'aperçu d'amélioration")
	scene.upgrade_button.mouse_entered.emit()
	check(scene.map_view.upgrade_preview.is_empty(),"Pas d'aperçu d'amélioration en combat")
	scene.free()
	var workshop := Main.new()
	workshop.model = Model.new(true,Model.Maps.mountain_workshop())
	root.add_child(workshop)
	workshop.set_process(false)
	workshop._choose_faction(0)
	workshop.model.gold = 1000
	workshop.model.buy(0,0)
	workshop.model.upgrade(0)
	workshop.model.upgrade(0)
	workshop.selected = 0
	workshop._upgrade()
	for branch in range(2):
		check(workshop.specialisation_descriptions[branch].text.contains("Entrée 1") and workshop.specialisation_descriptions[branch].text.contains("Entrée 2"),"Comparer la couverture des deux approches avant la spécialisation")
		check(workshop.specialisation_buttons[branch].tooltip_text.contains("Trajet à portée"),"La comparaison reste accessible dans l’aide")
	workshop.free()
	print("UPGRADE_PREVIEW_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
