extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const Survey = preload("res://tests/survey_upgrades.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func snapshot(m: RefCounted) -> Array:
	return [m.gold,m.fortress_hp,m.defenders.duplicate(true),m.bonuses.duplicate(),m.rng.state,m.phase,m.elapsed,m.total_income,m.wave_history.duplicate(true)]
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		var m = scene.model
		m.rng.seed = 42; m.rules_v232 = false # Références historiques : tirage de douze bonus
		check(not scene.summary_button.visible and m.wave_history.is_empty(),"Aucun bilan ni relevé avant le premier combat")
		scene._show_run_summary()
		check(not scene.summary_open,"Bilan indisponible avant fin de partie")
		m.buy(0,faction*3); m.buy(1,faction*3+1)
		var income: int = 0
		var duration: float = 0.0
		var lost: int = 0
		for wave in range(1,11):
			if wave >= 4 and m.defenders[2].is_empty(): m.buy(2,faction*3+2)
			if wave >= 5:
				for slot in [0,1,2]: m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
			var hp_before: int = m.fortress_hp
			var bonus_before: Array = m.bonuses.duplicate()
			check(m.start() and not m.start(),"Un seul départ valide par vague")
			m.advance(1000)
			check(m.wave_history.size() == wave,"Une ligne exactement à chaque résolution de vague")
			var row: Dictionary = m.wave_history[-1]
			check(row.wave == wave and row.killed == m.killed and row.escaped == m.escaped and row.spawned == m.spawned and row.remaining == 0,"Comptages du relevé conformes à la simulation")
			check(row.hp_before == hp_before and row.hp_after == m.fortress_hp and row.hp_lost == hp_before-m.fortress_hp,"PV avant/après et pertes exacts")
			income += row.income; duration += row.seconds; lost += row.hp_lost
			check(income == m.total_income and is_equal_approx(duration,m.completed_time+m.elapsed),"Conservation des revenus et temps par vague")
			check(row.bonuses == bonus_before and row.result == "cleared","Contexte au départ, avant le prochain choix de bonus")
			var saved: Array = m.wave_history.duplicate(true)
			m.advance(1000)
			check(m.wave_history == saved,"Pas de duplication en attente après la vague")
			if wave == 10: break
			if m.phase == "bonus": m.choose_bonus(Model.reference_bonus(m.bonus_offer))
			check(m.wave_history == saved,"Choisir un nouveau bonus ne réécrit pas la vague précédente")
			m.prepare_next_wave()
		check(m.phase == "victory" and m.fortress_hp == [14,12][faction] and m.gold == [192,189][faction],"Résultats financés normalement inchangés")
		check(lost == 20-m.fortress_hp and income == [752,749][faction],"Sommes du bilan identiques aux résultats de référence")
		check(m.wave_history[0].army.size() == 2 and m.wave_history[0].army[0].level == 1 and m.wave_history[-1].army[0].level == 4,"Composition historique indépendante des améliorations ultérieures")
		scene._update_interface()
		check(scene.summary_button.visible and scene.reset_button.text == "Rejouer" and scene.reset_button.size.x == 112,"Accès au bilan et nouveau départ en fin de partie")
		var before: Array = snapshot(m)
		scene.summary_button.pressed.emit()
		check(scene.summary_open and scene.summary_panel.visible and scene.summary_title.text.contains("Victoire"),"Ouverture du bilan de victoire")
		check(scene.summary_cells[9][1].text == str(m.wave_history[9].killed) and scene.summary_cells[9][6].text == "Terminée","Dernière vague réellement relevée")
		check(scene.summary_rows[3].tooltip_text.contains("Défense au départ") and scene.summary_rows[3].tooltip_text.contains("Bonus actifs"),"Contexte de chaque vague consultable")
		check(scene.summary_subtitle.text.contains("simulées") and scene.summary_totals.text.contains(str(m.total_income)),"Temps simulé explicite et revenu exact")
		scene._reset(); scene._show_bonuses(); scene._start(); scene._process(1000)
		check(scene.summary_open and not scene.overview_open and snapshot(m) == before,"Lecture sans mutation ni commande derrière le panneau")
		scene.summary_close.pressed.emit(); scene.summary_button.pressed.emit()
		check(snapshot(m) == before and scene.summary_open,"Relire ne réenregistre pas les vagues")
		scene._close_run_summary(); scene._reset()
		check(m.wave_history.is_empty() and m._wave_record.is_empty() and not scene.summary_button.visible and not scene.summary_panel.visible,"Nouvel essai efface les relevés et ferme le bilan")
		check(scene.reset_button.size.x == 234 and scene.reset_button.text == "Nouvel essai","Bouton de relance normal restauré")
		scene.free()
	# Défaite sans défense : la vague perdue contient encore des ennemis en chemin.
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	var m = scene.model
	m.start(); m.advance(1000); m.prepare_next_wave(); m.start(); m.advance(1000)
	check(m.phase == "defeat" and m.wave_history.size() == 2 and m.wave_history[1].result == "defeat","Défaite enregistrée dans la vague réellement perdue")
	check(m.wave_history[1].remaining == 8 and m.wave_history[1].escaped == 10 and m.wave_history[1].planned == 18,"Le bilan ne transforme pas les ennemis restants en éliminations")
	check(m.wave_history[0].seconds == 50.5 and m.wave_history[1].seconds == 46.0 and m.total_income == 0,"Temps et absence de récompense des ennemis passés")
	scene._update_interface(); scene._show_run_summary()
	check(scene.summary_title.text.contains("Défaite") and scene.summary_cells[1][6].text == "Défaite" and scene.summary_cells[2][6].text == "Non jouée","Vagues non jouées distinctes de la défaite")
	check(scene.summary_rows[1].tooltip_text.contains("8 encore en chemin") and scene.summary_army[0].text == "Aucun défenseur" and scene.summary_bonuses[0].text == "Aucun bonus","Contexte incomplet et composition vide décrits sans invention")
	scene._close_run_summary(); m.advance(1000)
	check(m.wave_history.size() == 2,"Aucun relevé supplémentaire après défaite")
	scene.free()
	# Contrôle technique du soin entre vagues, sans l'attribuer au combat passé.
	m = Model.new(); m.gold = 10000
	m.buy(0,0); m.buy(1,1)
	for wave in range(1,4):
		m.start(); m.advance(1000)
		if wave < 3: m.prepare_next_wave()
	var old: Array = m.wave_history.duplicate(true)
	var hp: int = m.fortress_hp
	m.bonus_offer.assign([8,0,1]); m.choose_bonus(8)
	check(m.fortress_hp == hp+4 and m.wave_history == old,"Maçonnerie ne réécrit pas les PV de la vague passée")
	m.prepare_next_wave(); m.start()
	check(m._wave_record.hp_before == hp+4 and m._wave_record.max_hp == 24 and m._wave_record.bonuses == [8],"Le soin et le bonus figurent au départ de la vague suivante")
	var survey = Survey.new()
	var clone = survey.clone_model(m)
	check(survey.failures.is_empty() and clone.wave_history == m.wave_history and clone._wave_record == m._wave_record,"Les comparaisons automatisées copient aussi le bilan et la vague en cours")
	clone.wave_history[0].hp_after = 999; clone._wave_record.army[0].level = 4
	check(m.wave_history[0].hp_after != 999 and m._wave_record.army[0].level != 4,"Les copies d'essai ne réécrivent pas les relevés de leur source")
	survey.free()
	print("RUN_SUMMARY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
