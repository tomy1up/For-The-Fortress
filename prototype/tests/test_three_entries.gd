extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = Main.Model
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var board: Dictionary = Model.Maps.for_id("slate_crossing")
	check(Model.Maps.validation_error(board).is_empty() and board.routes.size()==3,"Réseau à trois entrées valide")
	check(board.routes.map(func(route): return route.path_length)==[28.0,24.0,28.0],"Le passage central est plus court")
	for faction in range(2):
		var scene := Main.new()
		scene.model = Model.new(true,board)
		root.add_child(scene)
		scene.set_process(false)
		scene._choose_faction(faction)
		check(not scene.summary_wave_arrivals.get_global_rect().intersects(scene.report_status.get_global_rect()),"Arrivées et message d’export disposent de lignes séparées")
		check(not scene.summary_wave_arrivals.get_global_rect().intersects(scene.summary_army[-1].get_global_rect()),"Sixième unité et arrivées séparées : %s / %s" % [scene.summary_army[-1].get_global_rect(),scene.summary_wave_arrivals.get_global_rect()])
		for wave in range(1,11):
			scene.model.wave = wave
			scene.model.spawn_schedule = Model.Campaign.schedule(wave)
			scene._update_interface()
			var counts: Array = scene.forecast_data.entries.map(func(entry): return entry.count)
			check(counts.size()==3 and counts.reduce(func(total,count): return total+count,0)==scene.model.spawn_schedule.size(),"Chaque ennemi annoncé est affecté à une des trois entrées")
			for index in range(scene.forecast_data.groups.size()):
				var label: Label = scene.forecast_routes[index]
				check(label.get_minimum_size().x<=label.size.x,"Les effectifs des trois entrées tiennent sur une ligne")
			var layouts: Array[Dictionary] = scene.map_view.entry_label_layouts()
			check(layouts.size()==3 and layouts[0].color!=layouts[2].color and layouts[1].color!=layouts[2].color,"Trois couleurs distinctes")
			for index in range(3):
				check(Rect2(330,64,926,530).encloses(layouts[index].area),"Les trois repères restent dans la zone de carte")
				scene._update_wave_forecast(scene.map_view.to_global(layouts[index].area.get_center()))
				check(scene.map_view.highlighted_entries==[index],"Chaque repère met son propre trajet en évidence")
		scene.model.reset()
		scene.model.select_faction(faction)
		scene._update_interface()
		scene.selected = 0
		scene.map_view.selected = 0
		scene.hovered_purchase = 0
		scene._update_interface()
		check(scene.hint_label.text.contains("Entrée 3"),"La portée avant achat couvre les trois routes")
		scene.hovered_purchase = -1
		check(scene.model.start(),"Départ de la première vague")
		scene.model.advance(10000)
		check(scene.model.wave_history[0].arrivals_by_route=={"upper":4,"middle":3,"lower":3},"Les apparitions et arrivées respectent la répartition annoncée")
		check(scene._combat_tally_text().contains("3 · 3"),"Le compteur de combat inclut la troisième entrée")
		scene.model.reset()
		scene.model.select_faction(faction)
		scene.model.gold = 1000
		scene.model.buy(0,faction*3)
		scene.model.upgrade(0)
		scene.model.upgrade(0)
		scene._upgrade()
		if faction==0:
			for branch in range(2):
				var label: Label = scene.specialisation_descriptions[branch]
				check(label.text.contains("Entrée 3") and label.get_minimum_size().y<=label.size.y,"Comparaison de portée lisible jusqu’à la troisième entrée")
				check(not label.get_rect().intersects(scene.specialisation_buttons[branch].get_rect()),"Descriptions et boutons séparés : %s / %s" % [label.get_rect(),scene.specialisation_buttons[branch].get_rect()])
		scene.free()
	print("THREE_ENTRIES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
