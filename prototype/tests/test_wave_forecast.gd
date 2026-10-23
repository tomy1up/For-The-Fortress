extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const MapView = preload("res://scripts/valley_view.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func snapshot(m: RefCounted) -> Array:
	return [m.wave,m.phase,m.gold,m.fortress_hp,m.rng.state,m.enemies.duplicate(true),m.defenders.duplicate(true),m.bonuses.duplicate(),m.spawn_schedule.duplicate(true)]
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var quantities: Array[int] = [10,18,16,20,18,20,11,44,14,11]
	var incomes: Array[int] = [30,38,48,44,88,82,96,108,132,104]
	for number in range(1,11):
		var data: Dictionary = Model.wave_forecast(number)
		var schedule: Array[Dictionary] = Model.Campaign.schedule(number)
		check(data.wave == number and data.total == quantities[number-1] and data.income == incomes[number-1],"Quantités et butin maximal conformes aux références")
		var offset: int = 0
		for group in data.groups:
			var enemy: Dictionary = Model.ENEMY_TYPES[group.type]
			check(group.hp == enemy.hp and group.fortress_damage == enemy.fortress_damage and group.reward == enemy.reward and group.name == enemy.name,"Statistiques issues de la définition réellement jouée")
			check(group.first_at == schedule[offset].time and group.last_at == schedule[offset+group.count-1].time,"Horaires issus du calendrier de combat")
			for index in range(group.count):
				check(schedule[offset+index].type == group.type,"Aucune composition inventée dans les groupes")
			if offset > 0: check(is_equal_approx(group.first_at-schedule[offset-1].time,4.0),"Quatre secondes entre groupes conservées")
			offset += group.count
		check(offset == data.total,"Les groupes couvrent toute la vague")
	check(Model.wave_forecast(0).is_empty() and Model.wave_forecast(11).is_empty(),"Aucune vague hors des dix approuvées")
	var data: Dictionary = Model.wave_forecast(9)
	for index in range(4):
		check(data.groups[index].type == [6,5,3,4][index] and is_equal_approx(data.groups[index].first_at,[0.0,9.0,17.0,27.6][index]),"Ordre et départ des quatre groupes de vague 9")
	data = Model.wave_forecast(10)
	check(data.groups[0].type == 7 and data.groups[0].count == 1 and data.groups[0].hp == 600 and data.groups[0].first_at == 0,"Boss unique aux statistiques actuelles, sans candidat à 900 PV")
	data.groups[0].hp = 999
	check(Model.wave_forecast(10).groups[0].hp == 600 and Model.ENEMY_TYPES[7].hp == 600,"Les fiches retournées ne modifient pas les définitions")
	var scene = Main.new(); root.add_child(scene); scene.set_process(false)
	check(not scene.forecast_panel.visible,"Pas de prévision derrière le choix de faction")
	scene._choose_faction(0)
	check(scene.forecast_panel.visible and scene.forecast_title.text.contains("1/10") and scene.forecast_timing.text.contains("Départ manuel"),"Première préparation sans délai imposé")
	for number in range(1,11):
		scene.model.wave = number; scene.model.phase = "preparation"
		var before: Array = snapshot(scene.model)
		scene._update_interface()
		data = Model.wave_forecast(number)
		check(scene.forecast_data == data and scene.forecast_reward.text.contains(str(incomes[number-1])),"Panneau de la vague attendue et gain conditionnel")
		check(scene.forecast_reward.text.begins_with("Si tous éliminés"),"Aucune récompense de vague garantie annoncée")
		for index in range(4):
			check(scene.forecast_rows[index].visible == (index < data.groups.size()),"Aucun groupe périmé visible après changement de vague")
			if index < data.groups.size():
				check(scene.forecast_marks[index].color == MapView.enemy_color(data.groups[index].type) and scene.forecast_names[index].text.contains(data.groups[index].name),"Nom et couleur du profil cohérents avec le combat")
		check(scene.forecast_panel.position.y+scene.forecast_panel.size.y < 393 and scene.forecast_note.position.y+scene.forecast_note.size.y <= scene.forecast_panel.size.y,"Quatre groupes et pied de carte visibles sans recouvrir la route")
		check(snapshot(scene.model) == before,"Consulter la prévision ne change ni ressources ni calendrier ni générateur")
	scene.model.fortress_hp = 20; scene._update_interface()
	check(scene.forecast_names[0].text.contains("BOSS") and scene.forecast_details[0].text.contains("Fatale"),"Boss et danger d'arrivée visibles avant lancement")
	check(scene.forecast_rows[0].tooltip_text.contains("Ennemi unique") and scene.forecast_rows[0].tooltip_text.contains("0 s après le départ"),"L'ennemi unique n'annonce pas un intervalle nul trompeur")
	scene.model.fortress_hp = 24; scene._update_interface()
	check(not scene.forecast_details[0].text.contains("Fatale"),"Le danger est actualisé même si la vague en cache ne change pas")
	scene.model.wave = 8; scene.model.phase = "finished"; scene.autoplay_started = true; scene._process(1)
	check(scene.forecast_wave == 9 and scene.forecast_timing.text.contains("Dans 29 s"),"Après vague 8 : prévision de vague 9 et décompte réel")
	scene._process(1)
	check(scene.countdown_remaining == 28,"La prévision ne suspend pas la préparation")
	scene._show_bonuses()
	check(not scene.forecast_panel.visible,"Pas de panneau à travers le récapitulatif")
	scene._close_bonuses()
	check(scene.forecast_panel.visible,"Retour à la prévision en fermant le récapitulatif")
	scene._start()
	check(scene.model.active and not scene.forecast_panel.visible and scene.enemy_prompt.visible,"Le combat remplace la prévision par l'inspection ennemie")
	var motion := InputEventMouseMotion.new()
	motion.position = MapView.enemy_bounds(scene.model.enemies[0]).get_center()
	scene._input(motion)
	check(scene.enemy_inspector.visible and not scene.forecast_panel.visible,"Prévision et fiche de l'ennemi ne se superposent pas")
	scene.model.enemies.clear(); scene.model.wave = 9; scene.model.phase = "bonus"; scene.model.fortress_hp = 20; scene.model.max_hp = 20; scene.model.bonus_offer.assign([8,0,1]); scene._update_interface()
	check(not scene.forecast_panel.visible,"Le choix roguelite reste prioritaire")
	scene._choose_bonus(0)
	check(scene.forecast_wave == 10 and scene.forecast_panel.visible and scene.countdown_remaining == 30 and not scene.forecast_details[0].text.contains("Fatale"),"Après Maçonnerie : prévision correcte avec délai complet et PV soignés")
	for phase in ["victory","defeat"]:
		scene.model.phase = phase; scene._update_interface()
		check(not scene.forecast_panel.visible,"Aucune prévision ni vague 11 après fin de partie")
	scene._reset()
	check(not scene.forecast_panel.visible,"Nouvel essai : aucun ancien groupe derrière le choix de faction")
	scene._choose_faction(1)
	check(scene.forecast_wave == 1 and scene.forecast_rows[0].visible and not scene.forecast_rows[1].visible,"Nouveau départ Horde : retour à la seule première vague")
	scene.model.gold = 10000; scene.selected = 0; scene._buy(0); scene._upgrade(); scene._upgrade(); scene._upgrade()
	check(scene.pending_slot == 0 and not scene.forecast_panel.visible,"La comparaison de spécialisations reste dégagée")
	scene._cancel_specialisation()
	check(scene.forecast_panel.visible,"La prévision revient après annulation du choix")
	scene.free()
	print("WAVE_FORECAST_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
