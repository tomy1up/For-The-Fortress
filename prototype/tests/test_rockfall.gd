extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const View = preload("res://scripts/valley_view.gd")
const Library = preload("res://scripts/animation_library.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const AFFIX := {"id":"rockfall","interval":18,"warning":3,"duration":7}
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_validation()
	verify_texts()
	verify_blocking()
	verify_forecast_and_spawns()
	verify_step_independence()
	verify_status()
	verify_replay()
	await verify_rendering()
	verify_rockfall_transitions()
	await verify_sheets()
	await verify_single_entry()
	verify_biome_affixes()
	print("ROCKFALL_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func rocky(map_id: String = "mine_crystals") -> Model:
	var model := Model.new(true,Model.Maps.for_id(map_id))
	check(model.configure_combat_affix(AFFIX),"Affixe Éboulement accepté sur %s" % map_id)
	model.rng.seed = 7
	return model

func verify_validation() -> void:
	for map_id in ["mine_gallery","mine_crystals"]:
		for valid in [AFFIX,{"id":"rockfall","interval":10,"warning":1,"duration":2},{"id":"rockfall","interval":40,"warning":4,"duration":12}]:
			var model := Model.new(true,Model.Maps.for_id(map_id))
			check(model.configure_combat_affix(valid),"Affixe valide accepté : %s" % JSON.stringify(valid))
	var invalid: Array = [{"id":"rockfall"},{"id":"rockfall","interval":18,"warning":3},{"id":"rockfall","interval":18,"warning":3,"duration":7,"extra":1},
		{"id":"rockfall","interval":9,"warning":3,"duration":7},{"id":"rockfall","interval":41,"warning":3,"duration":7},{"id":"rockfall","interval":18,"warning":0,"duration":7},
		{"id":"rockfall","interval":18,"warning":5,"duration":7},{"id":"rockfall","interval":18,"warning":3,"duration":1},{"id":"rockfall","interval":18,"warning":3,"duration":13},
		{"id":"rockfall","interval":10,"warning":4,"duration":6},{"id":"rockfall","interval":18.5,"warning":3,"duration":7},{"id":"rockfall","interval":18,"warning":"3","duration":7},
		{"id":"rockfall","interval":18,"warning":NAN,"duration":7},{"id":"rockfall","interval":18,"warning":3,"duration":INF}]
	for bad in invalid:
		var model := Model.new(true,Model.Maps.for_id("mine_crystals"))
		check(not model.configure_combat_affix(bad) and model.combat_affix.is_empty(),"Affixe mal formé refusé sans effet : %s" % str(bad))
	var single := Model.new(true,Model.Maps.for_id("mine_entrance"))
	check(single.configure_combat_affix(AFFIX) and single.combat_affix == AFFIX,"Une carte à une seule entrée accepte l'éboulement depuis la décision du 23 novembre 2026")
	var started := Model.new(true,Model.Maps.for_id("mine_crystals"));started.buy(3,0)
	check(not started.configure_combat_affix(AFFIX),"Affixe refusé après une action")

func verify_texts() -> void:
	var model := rocky()
	check(model.affix_description() == "Éboulement · une entrée bloquée 7 s toutes les 18 s","Description courte de l'affixe")
	check(model.affix_tooltip().contains("18 s") and model.affix_tooltip().contains("7 s") and model.affix_tooltip().contains("3 s") and model.affix_tooltip().contains("entrée suivante") and model.affix_tooltip().contains("Réglage d’essai"),"Info-bulle d'essai complète")
	var plain := Model.new(true,Model.Maps.for_id("mine_crystals"))
	check(plain.affix_description() == "" and not plain.rockfall_enabled() and plain.rockfall_status().is_empty() and plain.rockfall_blocked_route(20.0,1) == "","Sans affixe, rien n'est annoncé ni bloqué")

func verify_blocking() -> void:
	var model := rocky()
	var size: int = model.routes.size()
	check(size == 3,"La Grotte aux Cristaux a trois entrées")
	check(model.rockfall_blocked_route(0.0,1) == "" and model.rockfall_blocked_route(17.9,1) == "" and model.rockfall_blocked_route(25.0,1) == "" and model.rockfall_blocked_route(35.9,1) == "","Aucune entrée bloquée hors des fenêtres")
	check(model.rockfall_blocked_route(18.0,1) == model.routes[(1+1)%size].id and model.rockfall_blocked_route(24.9,1) == model.routes[(1+1)%size].id,"Le premier éboulement tombe sur l'entrée (1 + vague) modulo trois")
	check(model.rockfall_blocked_route(36.0,1) == model.routes[(2+1)%size].id and model.rockfall_blocked_route(36.0,2) == model.routes[(2+2)%size].id,"L'entrée touchée change avec le numéro d'éboulement et la vague")
	for wave in range(1,11):
		for number in range(1,6):
			var route_id: String = model.rockfall_blocked_route(18.0*number+1.0,wave)
			check(route_id != "" and model.routes.any(func(route): return route.id == route_id),"Vague %d, éboulement %d : une entrée existante est touchée" % [wave,number])

func verify_forecast_and_spawns() -> void:
	for map_id in ["mine_gallery","mine_crystals"]:
		var plain := Model.new(true,Model.Maps.for_id(map_id))
		var model := rocky(map_id)
		for wave in range(1,11):
			var schedule: Array[Dictionary] = Model.Campaign.schedule(wave,"ford")
			var moved := 0
			for index in range(schedule.size()):
				var base: String = plain.spawn_route_id(index,schedule[index],wave)
				var actual: String = model.spawn_route_id(index,schedule[index],wave)
				var blocked: String = model.rockfall_blocked_route(float(schedule[index].time),wave)
				if blocked != "" and base == blocked:
					moved += 1
					check(actual != blocked and actual == model.routes[(model.routes.find(model.routes.filter(func(route): return route.id == base)[0])+1)%model.routes.size()].id,"%s vague %d apparition %d : passe par l'entrée suivante" % [map_id,wave,index])
				else:
					check(actual == base,"%s vague %d apparition %d : trajet inchangé hors de l'entrée bloquée" % [map_id,wave,index])
			var forecast: Dictionary = model.forecast_for_routes(wave)
			var total := 0
			for entry in forecast.entries: total += int(entry.count)
			check(total == schedule.size(),"%s vague %d : la prévision garde tous les ennemis (%d déplacés)" % [map_id,wave,moved])
	# Au moins une vague change réellement de répartition : l'affixe a un effet observable.
	var plain_model := Model.new(true,Model.Maps.for_id("mine_crystals"))
	var model := rocky()
	var differs := false
	for wave in range(1,11):
		var a: Dictionary = plain_model.forecast_for_routes(wave);var b: Dictionary = model.forecast_for_routes(wave)
		if JSON.stringify(a.entries) != JSON.stringify(b.entries): differs = true
	check(differs,"L'éboulement modifie la répartition des entrées sur au moins une vague")

func play_wave(step: float, map_id: String = "mine_crystals") -> Dictionary:
	var model := rocky(map_id)
	model.gold = 600
	model.select_faction(0)
	model.buy(3,0);model.buy(4,1)
	model.start()
	var guard := 0
	while model.phase == "combat" and guard < 100000:
		model.advance(step);guard += 1
	var routes_used: Array = []
	for enemy in model.enemies: routes_used.append(enemy.get("route_id",""))
	return {"log":model.event_log.duplicate(),"routes":routes_used,"hp":model.fortress_hp,"gold":model.gold,"killed":model.wave_killed if "wave_killed" in model else 0,"phase":model.phase}

func verify_step_independence() -> void:
	var big: Dictionary = play_wave(10000.0)
	var small: Dictionary = play_wave(0.05)
	var odd: Dictionary = play_wave(0.731)
	check(JSON.stringify(big) == JSON.stringify(small) and JSON.stringify(big) == JSON.stringify(odd),"Même déroulement avec un grand pas, des pas de 50 ms et des pas irréguliers")

func verify_status() -> void:
	var model := rocky()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	check(model.rockfall_status().is_empty(),"Hors combat, aucun état")
	model.start()
	check(model.rockfall_status().is_empty(),"Au début du combat, aucun éboulement annoncé")
	model.advance(15.0)
	var warning: Dictionary = model.rockfall_status()
	check(warning.get("state","") == "warning" and warning.number == 1 and warning.route_id == model.routes[(1+model.wave)%model.routes.size()].id and absf(float(warning.remaining)-3.0) < 0.001,"À 15 s : avertissement de l'éboulement 1 sur l'entrée touchée")
	model.advance(3.5)
	var active: Dictionary = model.rockfall_status()
	check(active.get("state","") == "active" and active.route_id == warning.route_id and absf(float(active.remaining)-6.5) < 0.001,"À 18,5 s : entrée bloquée, même entrée que l'avertissement")
	model.advance(7.0)
	check(model.rockfall_status().is_empty() or model.rockfall_status().get("state","") == "warning" and model.rockfall_status().number == 2,"Après 25,5 s : plus de blocage")

func verify_replay() -> void:
	for faction in range(2):
		var model := rocky()
		model.select_faction(faction)
		var types: Array = [0,1,1] if faction == 0 else [3,3,5]
		model.buy(3,types[0]);model.buy(4,types[1])
		for wave in range(1,11):
			if wave == 2: model.upgrade(3)
			if wave >= 2 and model.defenders[2].is_empty(): model.buy(2,types[2])
			if wave >= 5:
				for slot in [3,4,2]:
					if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
			model.start();model.advance(10000)
			if model.phase == "defeat": break
			if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
			if wave < 10: model.prepare_next_wave()
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
		check(report.has("combat_affix") and report.combat_affix.id == "rockfall" and int(report.combat_affix.interval) == 18 and int(report.combat_affix.warning) == 3 and int(report.combat_affix.duration) == 7,"Le rapport conserve l'affixe")
		var replay: Dictionary = Replay.verify(report)
		check(replay.ok,"Le rapport de la faction %d est rejouable : %s" % [faction,str(replay.get("error",""))])
		check(Report.markdown(report).contains("Éboulement · toutes les 18 s de combat"),"Le rapport lisible décrit l'éboulement")
		var tampered: Dictionary = report.duplicate(true)
		tampered.combat_affix.duration = 8;tampered.combat_affix.interval = 10;tampered.combat_affix.warning = 1
		check(not Replay.verify(tampered).ok,"Un rapport dont l'affixe est modifié n'est plus rejouable")

func verify_rendering() -> void:
	var model := rocky()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	var view := View.new();view.model = model;root.add_child(view)
	model.start()
	var before: String = JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders])
	for time in [5.0,10.0,3.0,4.0,5.0]:
		model.advance(time)
		await process_frame
	check(not model.rockfall_status().is_empty() or model.elapsed > 0.0,"Le combat avance pendant le dessin")
	view.free()
	check(before != "","Dessin de l'avertissement et du blocage sans erreur")

## Chute, tas et dégagement livrés par Codex (v0.249) : enchaînement sur l'âge du blocage, raccord sur l'image 0, réouverture inchangée.
func verify_rockfall_transitions() -> void:
	Library.clear_cache()
	var spec: Dictionary = Library.spec_for("effect.rockfall")
	check(not spec.is_empty() and int(spec.animations.spawn.frames) == 41 and is_equal_approx(float(spec.animations.spawn.duration),0.68) and int(spec.animations.death.frames) == 32 and is_equal_approx(float(spec.animations.death.duration),0.54),"Planches de chute et de dégagement chargées")
	var at := func(age: float) -> Dictionary: return View.rockfall_sheet(spec,{"state":"active","remaining":5.0-age},5.0,3.0,12.0+age)
	var index := func(sheet: Dictionary) -> int: return Library.frame_index(spec.animations[sheet.state],float(sheet.phase))
	check(at.call(0.0).state == "spawn" and index.call(at.call(0.0)) == 0,"La chute commence dès l'activation")
	check(at.call(0.679).state == "spawn" and index.call(at.call(0.679)) == 40,"La chute va jusqu'à sa dernière image")
	check(at.call(0.681).state == "blocked" and index.call(at.call(0.681)) == 0,"Le tas reprend sur son image 0")
	check(at.call(4.459).state == "blocked" and index.call(at.call(4.459)) == 23,"Le tas finit son dernier cycle sur sa dernière image")
	check(at.call(4.461).state == "death" and index.call(at.call(4.461)) == 0,"Le dégagement part de l'image 0")
	check(at.call(4.999).state == "death" and index.call(at.call(4.999)) == 31,"Le dégagement va jusqu'à sa dernière image")
	check(View.rockfall_sheet(spec,{"state":"warning","remaining":1.5},5.0,3.0,10.5).state == "warning" and is_equal_approx(float(View.rockfall_sheet(spec,{"state":"warning","remaining":1.5},5.0,3.0,10.5).phase),0.5),"L'annonce suit sa progression")
	var short: Dictionary = View.rockfall_sheet(spec,{"state":"active","remaining":0.5},1.0,1.0,12.5)
	check(short.state == "blocked","Blocage trop court pour les transitions : le tas reste affiché")
	var old: Dictionary = spec.duplicate(true);old.animations.erase("spawn");old.animations.erase("death")
	check(View.rockfall_sheet(old,{"state":"active","remaining":4.9},5.0,3.0,12.1).state == "blocked","Sans transition : le tas reste affiché")
	check(View.rockfall_sheet({},{"state":"active","remaining":4.0},5.0,3.0,13.0).is_empty(),"Sans planche : repli sur le repère provisoire")
	Library.clear_cache()

## Habillage par planches (`effect.rockfall`) : accepté, dessiné sans modifier le jeu, repli sur le repère provisoire sans planche.
func verify_sheets() -> void:
	Library.clear_cache()
	var spec := {"version":1,"id":"effect.rockfall","display_height":48,"foot":[32,40],"animations":{
		"warning":{"file":"warning.png","frames":6,"frame_size":[64,48],"mode":"progress"},
		"blocked":{"file":"blocked.png","frames":8,"frame_size":[64,48],"mode":"time","fps":8}}}
	check(Library.validation_error(spec) == "","Description de l'effet d'éboulement valide")
	var wrong: Dictionary = spec.duplicate(true);wrong.animations.blocked = {"file":"b.png","frames":4,"frame_size":[64,48],"mode":"event","duration":1.0}
	check(Library.validation_error(wrong) != "","Le blocage boucle : mode time obligatoire")
	var warning_strip := Image.create(6*64,48,false,Image.FORMAT_RGBA8);warning_strip.fill(Color(0.9,0.5,0.2,0.4))
	var blocked_strip := Image.create(8*64,48,false,Image.FORMAT_RGBA8);blocked_strip.fill(Color(0.4,0.4,0.45,0.9))
	Library.register_for_test("effect.rockfall",spec,{"warning":ImageTexture.create_from_image(warning_strip),"blocked":ImageTexture.create_from_image(blocked_strip)})
	var model := rocky()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	model.start()
	var view := View.new();view.model = model;root.add_child(view)
	for time in [18.5,20.0]:
		model.advance(time-model.elapsed)
		var before: String = JSON.stringify([model.gold,model.rng.state,model.defenders,model.rockfall_status()])
		view.queue_redraw()
		await process_frame
		await process_frame
		check(before == JSON.stringify([model.gold,model.rng.state,model.defenders,model.rockfall_status()]) and not model.rockfall_status().is_empty(),"Dessiner l'éboulement à %.1f s (planches) ne modifie pas le jeu" % time)
	view.free()
	Library.clear_cache()
	var bare := View.new();bare.model = model;root.add_child(bare)
	await process_frame
	bare.queue_redraw()
	await process_frame
	check(not model.rockfall_status().is_empty(),"Sans planche : repère provisoire dessiné sans erreur")
	bare.free()

## Éboulement sur une carte à une seule entrée (décision du porteur, 23 novembre 2026) : les ennemis attendent la fin du blocage, puis sortent groupés dans le même ordre.
func verify_single_entry() -> void:
	var expected: Array[float] = [0.0,1.0,17.0,25.0,25.3,25.6,25.9,26.2,30.0]
	var held: Array[float] = Model.rockfall_held_times([0.0,1.0,17.0,18.0,19.0,24.9,25.0,26.0,30.0],18.0,7.0)
	check(held.size() == expected.size() and range(held.size()).all(func(i: int) -> bool: return is_equal_approx(held[i],expected[i])),"Sorties retardées à la fin du blocage, espacées de 0,3 s, sans toucher aux apparitions hors blocage : %s" % str(held))
	var chained: Array[float] = Model.rockfall_held_times([24.9,25.0,35.9,36.0,36.1],18.0,7.0)
	check(is_equal_approx(chained[0],25.0) and is_equal_approx(chained[1],25.3) and is_equal_approx(chained[2],35.9) and is_equal_approx(chained[3],43.0) and is_equal_approx(chained[4],43.3),"Chaque blocage retient ses propres apparitions")
	for number in [121,122,125,128]:
		var definition: Dictionary = Catalogue.definition(number)
		var map_id: String = str(definition.map_id)
		for faction in range(2):
			var model := rocky(map_id)
			check(model.routes.size() < 2,"Mission %d : une seule entrée" % number)
			model.select_faction(faction)
			model.configure_enemy_hp(100)
			model.gold = 2000
			model.buy(3,faction*3);model.buy(4,faction*3+1);model.buy(2,faction*3)
			for wave in range(1,5):
				var base: Array = Model.Campaign.schedule(wave,model.wave_set_id)
				var forecast: Dictionary = model.forecast_for_routes(wave)
				check(model.start(),"Mission %d, vague %d démarrée" % [number,wave])
				check(model.spawn_schedule.size() == base.size() and range(base.size()).all(func(i: int) -> bool: return int(model.spawn_schedule[i].type) == int(base[i].type) and float(model.spawn_schedule[i].time) >= float(base[i].time)-0.000001),"Mission %d, vague %d : mêmes ennemis, dans le même ordre, jamais en avance" % [number,wave])
				for index in range(model.spawn_schedule.size()):
					var time: float = float(model.spawn_schedule[index].time)
					var block: int = int(floor((time+0.000001)/18.0))
					check(block < 1 or time >= 18.0*block+7.0-0.000001,"Mission %d, vague %d : aucune sortie pendant un blocage (%.2f s)" % [number,wave,time])
					if index > 0: check(time > float(model.spawn_schedule[index-1].time),"Mission %d, vague %d : sorties ordonnées et distinctes" % [number,wave])
				var offset: int = 0
				for group in forecast.groups:
					check(is_equal_approx(float(group.first_at),float(model.spawn_schedule[offset].time)) and is_equal_approx(float(group.last_at),float(model.spawn_schedule[offset+int(group.count)-1].time)),"Mission %d, vague %d : la prévision annonce les sorties retardées" % [number,wave])
					offset += int(group.count)
				model.advance(15.5)
				var warning: Dictionary = model.rockfall_status()
				if model.active:
					check(warning.get("state","") == "warning" and str(warning.route_id) == "","Mission %d : avertissement sur l'unique entrée" % number)
					check(View.affix_banner(model).text.contains("l'entrée sera bloquée"),"Mission %d : le bandeau annonce le blocage de l'entrée" % number)
					model.advance(3.0)
					if model.active: check(View.affix_banner(model).text.contains("entrée bloquée"),"Mission %d : le bandeau indique l'entrée bloquée" % number)
				model.advance(10000)
				if model.phase != "finished" and model.phase != "bonus": break
				if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
				model.prepare_next_wave()
	check(rocky("mine_entrance").affix_tooltip().contains("sortent groupés") and rocky("mine_crystals").affix_tooltip().contains("entrée suivante"),"Explication adaptée au nombre d'entrées")
	var big: Dictionary = play_wave(10000.0,"mine_entrance")
	var small: Dictionary = play_wave(0.05,"mine_entrance")
	var odd: Dictionary = play_wave(0.731,"mine_entrance")
	check(JSON.stringify(big) == JSON.stringify(small) and JSON.stringify(big) == JSON.stringify(odd),"Une seule entrée : même déroulement quelle que soit la taille des pas")
	for faction in range(2):
		var model := rocky("mine_entrance")
		model.select_faction(faction)
		model.buy(3,faction*3);model.buy(4,faction*3+1)
		for wave in range(1,11):
			model.start();model.advance(10000)
			if model.phase == "defeat": break
			if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
			if wave < 10: model.prepare_next_wave()
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
		var replay: Dictionary = Replay.verify(report)
		check(replay.ok,"Une seule entrée : rapport rejouable (faction %d) : %s" % [faction,str(replay.get("error",""))])
		check(Report.markdown(report).contains("attendent, puis sortent groupés"),"Le rapport lisible décrit l'éboulement sur une seule entrée")
	var view := View.new()
	var drawn := rocky("mine_entrance");drawn.select_faction(0);drawn.buy(3,0);view.model = drawn;root.add_child(view)
	drawn.start()
	for time in [15.5,3.0,5.0]:
		drawn.advance(time);view.queue_redraw()
		await process_frame
	check(true,"Dessin de l'éboulement sur l'unique entrée sans erreur")
	view.free()

## Un affixe par biome : le premier chapitre reprend exactement l'affixe du second.
func verify_biome_affixes() -> void:
	for pair in [[3,4],[7,8],[11,12],[13,14],[17,18]]:
		var reference: Dictionary = Catalogue.definition(pair[1]*10).combat_affix
		for number in range((pair[0]-1)*10+1,pair[1]*10+1):
			check(Catalogue.definition(number).get("combat_affix",{}) == reference,"Mission %d : même affixe sur les deux chapitres du biome" % number)
	check(Catalogue.definition(1).get("combat_affix",{}).is_empty(),"Mission 1 : sans affixe, pour apprendre le jeu")
	for number in range(1,201):
		var definition: Dictionary = Catalogue.definition(number)
		if definition.has("combat_affix"):
			var model := Model.new(true,Model.Maps.for_id(str(definition.map_id)))
			check(model.configure_combat_affix(definition.combat_affix),"Mission %d : affixe accepté par sa carte" % number)
