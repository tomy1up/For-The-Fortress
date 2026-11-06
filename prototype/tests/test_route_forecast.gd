extends SceneTree
const Main=preload("res://scripts/main.gd")
const Model=Main.Model
const Maps=Model.Maps
var checks:=0
var failures:=0
func check(value: bool, message: String) -> void:
	checks+=1
	if not value: failures+=1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(model: RefCounted) -> String:
	return JSON.stringify([model.wave,model.phase,model.gold,model.fortress_hp,str(model.rng.state),model.spawn_schedule,model.enemies,model.defenders])
func run_checks() -> void:
	var mountain := Model.new(true,Maps.mountain_workshop())
	mountain.select_faction(0)
	var second := mountain.forecast_for_routes(2)
	var third := mountain.forecast_for_routes(3)
	check(second.entries[0].count > second.entries[1].count and third.entries[1].count > third.entries[0].count,"Les vagues du Col alternent leur entrée principale")
	mountain.wave = 2
	mountain.spawn_schedule = Model.Campaign.schedule(2)
	var mountain_arrivals := {"upper":0,"lower":0}
	mountain.start()
	for entry in mountain.spawn_schedule:
		mountain.advance(maxf(0.0,entry.time-mountain.elapsed))
		var spawned: Dictionary = mountain.enemies.back()
		mountain_arrivals[spawned.route_id] += 1
	check(second.entries[0].count == mountain_arrivals.upper and second.entries[1].count == mountain_arrivals.lower,"La pression annoncée correspond aux apparitions")
	for faction in [0,1]:
		for set_id in ["ford","ford_banks"]:
			for number in range(1,11):
				var model:=Model.new(true,Maps.converging_workshop());model.configure_wave_set(set_id);model.select_faction(faction)
				model.wave=number;model.spawn_schedule=Model.Campaign.schedule(number,set_id)
				model.fortress_hp=10000;model.max_hp=10000
				var before:=signature(model)
				var forecast:=model.forecast_for_routes(number)
				check(signature(model)==before,"Prévoir les entrées ne modifie pas le combat ni l'aléatoire")
				check(forecast.entries.size()==2 and forecast.entries[0].count+forecast.entries[1].count==forecast.total,"Total par entrée égal au total de la vague")
				var offset:=0
				for group in forecast.groups:
					var sum:=0
					for entry in group.entries:
						sum+=entry.count
						var indices: Array[int]=[]
						for index in range(offset,offset+group.count):
							if index%2==entry.number-1: indices.append(index)
						check(entry.count==indices.size() and entry.first_at==model.spawn_schedule[indices[0]].time and entry.last_at==model.spawn_schedule[indices[-1]].time,"Provenance et horaires exacts, alternance poursuivie entre groupes")
					check(sum==group.count,"Chaque membre d'un groupe est affecté une seule fois")
					offset+=group.count
				var schedule:=model.spawn_schedule.duplicate(true)
				var observed: Dictionary={"upper":0,"lower":0}
				model.start()
				for id in range(schedule.size()):
					model.advance(maxf(0.0,schedule[id].time-model.elapsed))
					var found:=false
					for target in model.enemies:
						if target.id==id: observed[target.route_id]+=1;found=true;break
					check(found,"Apparition réelle observée avant son arrivée")
				for entry in forecast.entries: check(entry.count==observed[entry.route_id],"Annonce par entrée égale aux apparitions réellement jouées")
		var scene:=Main.new();scene.model=Model.new(true,Maps.converging_workshop());scene.mission_definition={}
		get_root().add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		for number in range(1,11):
			scene.model.wave=number;scene.model.phase="preparation";scene.model.spawn_schedule=Model.Campaign.schedule(number)
			var before:=signature(scene.model)
			scene._update_interface()
			check(scene.forecast_panel.visible and scene.forecast_note.text.contains("Entrée 1") and scene.forecast_note.text.contains("Entrée 2"),"Répartition visible dans le panneau de préparation")
			check(scene.forecast_panel.size.y==112+60*scene.forecast_data.groups.size(),"Le panneau réserve une ligne de répartition par groupe")
			for index in range(scene.forecast_data.groups.size()):
				var group: Dictionary = scene.forecast_data.groups[index]
				var segments: Array[String] = []
				for entry in group.entries:
					segments.append("Entrée %d · %d" % [entry.number,entry.count])
				check(scene.forecast_routes[index].visible and scene.forecast_routes[index].text==" / ".join(segments),"Répartition du groupe visible sans survol")
			var layouts:=scene.map_view.entry_label_layouts()
			check(layouts.size()==2 and layouts[0].color!=layouts[1].color,"Repères d'entrée distincts")
			for index in range(2):
				check(layouts[index].detail.begins_with(str(scene.forecast_data.entries[index].count)),"Quantité du repère liée à l'entrée correspondante")
				check(Rect2(330,64,926,530).encloses(layouts[index].area),"Repère lisible dans la zone de carte sans le panneau gauche")
				scene._update_wave_forecast(scene.map_view.to_global(layouts[index].area.get_center()))
				check(scene.map_view.highlighted_entries==[index],"Survol du repère limité à son trajet")
			scene._update_wave_forecast(Vector2.ZERO)
			check(scene.map_view.highlighted_entries.is_empty(),"Le trajet cesse d’être mis en évidence au départ du pointeur")
			check(signature(scene.model)==before,"Rafraîchir le panneau reste une consultation")
			scene.model.phase="combat";scene._update_interface()
			check(not scene.forecast_panel.visible and scene.map_view.entry_forecast.is_empty() and scene.map_view.entry_label_layouts()[0].detail.is_empty(),"Les anciens effectifs annoncés disparaissent au combat")
		scene.model.phase="preparation";scene.model.wave=1;scene._update_interface()
		scene.model.enemy_hp_percent=119;scene._update_interface()
		check(is_equal_approx(scene.forecast_data.groups[0].hp,47.6),"Cache invalidé si le contexte de statistiques change sans changement de numéro de vague")
		scene.free()
	var single:=Model.new()
	check(single.forecast_for_routes(1)==Model.wave_forecast(1,0),"Campagne à chemin unique : prévision historique inchangée")
	check(single.forecast_for_routes(0).is_empty(),"Vague invalide sans annonce inventée")
	print("ROUTE_FORECAST_TESTS checks=%d failures=%d"%[checks,failures])
	quit(0 if failures==0 else 1)
