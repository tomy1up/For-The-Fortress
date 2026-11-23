extends SceneTree
## Cinq attaquants des chapitres pairs (v0.246, décision du porteur du 23 novembre 2026) : bouquetin, golem de magma et Braises, scorpion, taupe, crabe pilleur.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Main = preload("res://scripts/main.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Attackers = preload("res://scripts/biome_attackers.gd")
const Art = preload("res://scripts/enemy_art.gd")
## Chapitre, première mission, profil, première vague du nouvel attaquant, affixe du biome.
const SETS := {
	"slate_ibex":{"chapter":4,"number":31,"type":13,"from":3,"affix":"Vents contraires"},
	"ash_golems":{"chapter":8,"number":71,"type":14,"from":4,"affix":"Éruptions"},
	"dune_scorpions":{"chapter":12,"number":111,"type":16,"from":3,"affix":"Tempête de sable"},
	"mine_moles":{"chapter":14,"number":131,"type":17,"from":3,"affix":"Éboulement"},
	"coast_crabs":{"chapter":18,"number":171,"type":18,"from":4,"affix":"Brume marine"},
}
const OTHER_SETS := {2:"ford_banks",6:"marsh_drowned",10:"citadel_garrison",16:"sky_eagles",20:"necro_revenants"}
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_catalogue()
	verify_ibex()
	verify_golem()
	verify_scorpion()
	verify_mole()
	verify_crab()
	verify_step_independence()
	verify_replay()
	await verify_mission_sheet()
	await verify_rendering()
	print("BIOME_ATTACKERS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

## Combat isolé d'une mission : ennemis du type donné aux instants donnés, aucun défenseur.
func arena(type: int, times: Array, number: int) -> Model:
	var definition: Dictionary = Catalogue.definition(number)
	var model := Model.new(true,Model.Maps.for_id(str(definition.map_id)))
	check(model.configure_wave_set(definition.wave_set_id),"Mission %d : rencontres acceptées" % number)
	check(model.configure_combat_affix(definition.combat_affix),"Mission %d : affixe accepté" % number)
	model.select_faction(0)
	var schedule: Array[Dictionary] = []
	for time in times: schedule.append({"type":type,"time":float(time)})
	model.spawn_schedule = schedule
	check(model.start(),"Combat isolé démarré")
	return model

func go(model: Model, time: float) -> void:
	model.advance(time-model.elapsed)

func near(value: float, expected: float) -> bool:
	return absf(value-expected) < 0.000001

func verify_catalogue() -> void:
	for chapter in range(1,21):
		var expected: String = ""
		for id in SETS:
			if SETS[id].chapter == chapter: expected = id
		if OTHER_SETS.has(chapter): expected = OTHER_SETS[chapter]
		for number in range((chapter-1)*10+1,chapter*10+1):
			var definition: Dictionary = Catalogue.definition(number)
			check(str(definition.get("wave_set_id","")) == expected,"Mission %d : jeu de rencontres %s" % [number,expected])
			check(number == 1 or definition.has("combat_affix"),"Mission %d : le biome garde son affixe" % number)
	var values := {13:[70.0,0.9],14:[150.0,0.6],15:[15.0,1.4],16:[90.0,0.85],17:[60.0,1.0],18:[100.0,0.8]}
	for type in values:
		var definition: Dictionary = Model.enemy_definition(type)
		check(definition.hp == values[type][0] and definition.speed == values[type][1],"Profil %d : PV et vitesse proposés" % type)
		for faction in range(2):
			var identity: Dictionary = Model.Enemies.for_profile(type,faction)
			check(identity.origin == "neutral" and identity.name == definition.name and Model.Enemies.by_id(identity.id,faction) == identity,"Profil %d : attaquant neutre" % type)
			check(Art.TEXTURES.has(identity.id) and Art.FRAMES.has(identity.id) and Art.placeholder_tint(identity.id) != Color.WHITE,"Profil %d : silhouette provisoire teintée" % type)
			var enemy: Dictionary = Model.make_enemy(0,type,0.0,faction,150)
			check(near(float(enemy.hp),float(definition.hp)*1.5) and enemy.name == definition.name,"Profil %d : PV suivant le barème de la mission" % type)
	check(Model.Enemies.for_profile(19,0).is_empty(),"Un profil inconnu reste refusé")
	for id in SETS:
		var data: Dictionary = SETS[id]
		var waves: Array = Model.Campaign.waves_for(id)
		check(Model.Banks.valid_set(id) and waves.size() == 10,"%s : dix vagues" % id)
		for wave in range(10):
			var present: bool = waves[wave].any(func(group): return group[0] == data.type)
			check(present == (wave+1 >= data.from),"%s, vague %d : attaquant présent à partir de la vague %d" % [id,wave+1,data.from])
		check(Model.Enemies.available(0,id).size() == (10 if id == "ash_golems" else 9),"%s : catalogue complété" % id)
		var forecast: Dictionary = Model.wave_forecast(data.from,0,100,id)
		check(forecast.groups.any(func(group): return group.type == data.type and group.name == Model.enemy_definition(data.type).name),"%s : la prévision nomme l'attaquant" % id)
	check(Model.Enemies.available(0).size() == 8,"Les rencontres standard sont inchangées")

func verify_ibex() -> void:
	var model := arena(13,[0.0],31)
	var enemy: Dictionary = model.enemies[0]
	go(model,3.0)
	check(near(float(enemy.distance),2.7),"Marche normale avant la charge")
	model._apply_damage({enemy.id:float(enemy.max_hp)*0.4})
	check(not enemy.get("charged",false),"Pas de charge au-dessus de la moitié des PV")
	go(model,4.0)
	model._apply_damage({enemy.id:float(enemy.max_hp)*0.2})
	check(enemy.get("charged",false) and enemy.has("boost_until"),"Charge sous la moitié des PV")
	go(model,5.0)
	check(near(float(enemy.distance),3.6+0.9*1.7),"Pendant la charge : 70 % plus vite")
	for target in [4.0,5.5,8.0]:
		check(near(model.distance_at(enemy,model.time_at_distance(enemy,target)),target),"Position et instant cohérents pendant la charge")
	go(model,6.5)
	check(near(float(enemy.distance),3.6+0.9*3.4+0.9*0.5) and not enemy.has("boost_until"),"La charge dure 2 s, puis la marche reprend")
	model._apply_damage({enemy.id:1.0})
	check(not enemy.has("boost_until"),"Une seule charge par bouquetin")
	var slowed := arena(13,[0.0],31)
	var runner: Dictionary = slowed.enemies[0]
	go(slowed,2.0)
	slowed._apply_damage({runner.id:float(runner.max_hp)*0.6})
	slowed._slow_enemy(runner,1.0)
	for target in [2.5,3.0,6.0]:
		check(near(slowed.distance_at(runner,slowed.time_at_distance(runner,target)),target),"Charge et ralentissement se combinent")

func verify_golem() -> void:
	var model := arena(14,[0.0],71)
	var golem: Dictionary = model.enemies[0]
	go(model,10.0)
	var gold: int = model.gold
	model._apply_damage({golem.id:999999.0})
	check(model.gold == gold+8,"Le golem rapporte son or")
	check(model.enemies.size() == 2 and model.enemies.all(func(enemy): return enemy.type == 15),"Le golem éclate en deux Braises")
	check(model.planned_enemies() == 3 and model.killed == 1,"Les Braises comptent dans la vague")
	check(model.enemies[0].id != model.enemies[1].id and model.enemies.all(func(enemy): return enemy.id >= Attackers.FIRST_EXTRA_ID),"Identifiants distincts du calendrier")
	check(model.enemies.all(func(enemy): return enemy.get("route_id","") == golem.get("route_id","")),"Les Braises restent sur la route du golem")
	check(near(float(model.enemies[0].distance),6.0) and near(float(model.enemies[1].distance),5.7),"Les Braises repartent de sa position")
	go(model,11.0)
	check(near(float(model.enemies[0].distance),7.4) and near(float(model.enemies[1].distance),7.1),"Les Braises avancent à leur vitesse")
	check(model.affix_events.any(func(event): return event.kind == "burst"),"L'éclatement est signalé à la vue")
	var embers: Array = model.enemies.duplicate()
	model._apply_damage({embers[0].id:999.0,embers[1].id:999.0})
	check(model.enemies.is_empty() and model.killed == 3,"Une Braise tuée n'éclate pas")

func verify_scorpion() -> void:
	var model := arena(16,[0.0,13.0],111)
	var first: Dictionary = model.enemies[0]
	check(model.enemy_route_length(first) > 21.0,"Route assez longue pour le contrôle")
	go(model,11.0)
	check(near(float(first.distance),0.85*11.0),"Marche normale hors tempête")
	go(model,14.0)
	check(first.has("boost_until") and near(float(first.distance),0.85*(14.0+2.0)),"Deux fois plus vite dans la rafale")
	var late: Dictionary = model.enemies[1]
	check(near(float(late.distance),0.85*2.0),"Un scorpion apparu pendant la rafale court aussi")
	go(model,18.0)
	check(not first.has("boost_until") and near(float(first.distance),0.85*(18.0+4.0)),"Vitesse normale après la rafale")
	check(near(float(late.distance),0.85*(5.0+3.0)),"Le retardataire garde l'avance de sa fin de rafale")
	go(model,25.0)
	check(first.has("boost_until") and near(float(first.distance),0.85*(25.0+4.0+1.0)),"Il accélère à chaque rafale")

func verify_mole() -> void:
	for pair in [[0.5,false],[1.9,false],[2.5,true],[3.0,false],[5.9,true],[6.1,false],[29.5,false]]:
		check(Attackers.underground(pair[0],30.0) == pair[1],"Taupe à %.1f sur 30 : sous terre = %s" % [pair[0],str(pair[1])])
	check(not Attackers.underground(35.6,36.5),"Dernière case toujours en surface")
	var clipped: Array = Attackers.surface_windows([{"first":1.0,"last":7.0}],30.0)
	check(clipped.size() == 3 and near(clipped[0].first,1.0) and near(clipped[0].last,2.0) and near(clipped[1].first,3.0) and near(clipped[1].last,5.0) and near(clipped[2].first,6.0) and near(clipped[2].last,7.0),"Fenêtres de tir limitées à la surface")
	check(Attackers.surface_windows([{"first":2.2,"last":2.8}],30.0).is_empty(),"Aucune fenêtre entièrement sous terre")
	var shots := 0
	for slot in range(6):
		var definition: Dictionary = Catalogue.definition(131)
		var model := Model.new(true,Model.Maps.for_id(str(definition.map_id)))
		model.select_faction(0)
		model.buy(slot,0)
		var schedule: Array[Dictionary] = [{"type":17,"time":0.0}]
		model.spawn_schedule = schedule
		model.start()
		var enemy: Dictionary = model.enemies[0]
		enemy.hp = 9999999.0;enemy.max_hp = 9999999.0
		var length: float = model.enemy_route_length(enemy)
		model.advance(10000.0)
		for line in model.event_log:
			var words: PackedStringArray = str(line).split(" ")
			if words.size() < 5 or words[1] != "tir": continue
			shots += 1
			check(not Attackers.underground(float(words[0]),length),"Aucun tir sur la taupe sous terre (%s)" % line)
	check(shots > 0,"La taupe reste visée quand elle est en surface (%d tirs)" % shots)
	check(splash_hits(true) == 0,"Une explosion ne touche pas la taupe sous terre")
	check(splash_hits(false) == 1,"Une explosion touche la taupe en surface")

## Mage visant un fantassin, avec une taupe à la même distance, sous terre ou en surface. Rend le nombre de victimes secondaires.
func splash_hits(buried: bool) -> int:
	var definition: Dictionary = Catalogue.definition(131)
	var probe := Model.new(true,Model.Maps.for_id(str(definition.map_id)))
	var points: Array[Vector2] = []
	points.assign(probe.path_points if probe.routes.is_empty() else probe.routes[0].path_points)
	var length: float = probe.path_length if probe.routes.is_empty() else float(probe.routes[0].path_length)
	for cycle in range(1,int(length/3.0)-1):
		var distance: float = cycle*3.0+(2.5 if buried else 0.5)
		var point: Vector2 = Model.position_at(distance,points,length)
		for slot in range(probe.slots.size()):
			if probe.slots[slot].distance_to(point) > 3.0: continue
			var model := Model.new(true,Model.Maps.for_id(str(definition.map_id)))
			model.select_faction(0)
			model.buy(slot,2)
			var schedule: Array[Dictionary] = [{"type":1,"time":-distance},{"type":17,"time":-distance}]
			if not model.routes.is_empty():
				for entry in schedule: entry.route_id = model.routes[0].id
			model.spawn_schedule = schedule
			model.start()
			if model.shots.is_empty(): continue
			return model.shots[0].secondary.size()
	return -1

func verify_crab() -> void:
	var model := arena(18,[0.0],171)
	var enemy: Dictionary = model.enemies[0]
	enemy.delay = -(model.enemy_route_length(enemy)-0.4)/float(enemy.speed)
	model.gold = 100
	model.advance(1.0)
	check(model.gold == 80 and model.fortress_hp == model.max_hp-1 and model.enemies.is_empty(),"Le crabe vole 20 or en plus de ses dégâts")
	check(model.affix_events.any(func(event): return event.kind == "theft" and event.amount == 20),"Le vol est signalé à la vue")
	var poor := arena(18,[0.0],171)
	var second: Dictionary = poor.enemies[0]
	second.delay = -(poor.enemy_route_length(second)-0.4)/float(second.speed)
	poor.gold = 7
	poor.advance(1.0)
	check(poor.gold == 0,"Le trésor ne devient jamais négatif")
	var gate := arena(18,[0.0],171)
	var third: Dictionary = gate.enemies[0]
	third.delay = -(gate.enemy_route_length(third)-0.4)/float(third.speed)
	gate.bonuses.append(Model.B_GATE)
	gate.gold = 100
	gate.advance(1.0)
	check(gate.gold == 100 and gate.fortress_hp == gate.max_hp,"La Herse bloque aussi le vol")

func played(number: int, faction: int, step: float) -> Model:
	var definition: Dictionary = Catalogue.definition(number)
	var model := Model.new(true,Model.Maps.for_id(str(definition.map_id)))
	model.configure_wave_set(definition.wave_set_id)
	model.configure_combat_affix(definition.combat_affix)
	model.select_faction(faction)
	model.rng.seed = 7
	var types: Array = [0,1,1] if faction == 0 else [3,3,5]
	model.buy(3,types[0]);model.buy(4,types[1])
	for wave in range(1,11):
		if wave == 2: model.upgrade(3)
		if wave >= 2 and model.defenders[2].is_empty(): model.buy(2,types[2])
		model.start()
		var guard := 0
		while model.phase == "combat" and guard < 200000:
			model.advance(step);guard += 1
		if model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 10: model.prepare_next_wave()
	return model

func trace(model: Model) -> String:
	return JSON.stringify([model.event_log,model.fortress_hp,model.gold,model.total_killed,model.total_escaped])

func verify_step_independence() -> void:
	for id in SETS:
		var big: String = trace(played(SETS[id].number,0,10000.0))
		check(big == trace(played(SETS[id].number,0,0.05)) and big == trace(played(SETS[id].number,0,0.731)),"%s : même déroulement quel que soit le pas" % id)

func verify_replay() -> void:
	for id in SETS:
		for faction in range(2):
			var model: Model = played(SETS[id].number,faction,10000.0)
			for record in model.wave_history:
				if record.result == "cleared": check(int(record.killed)+int(record.escaped) == int(record.planned),"%s : tous les ennemis de la vague %d sont comptés" % [id,record.wave])
			var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
			var replay: Dictionary = Replay.verify(report)
			check(replay.ok,"%s, faction %d : rapport rejouable : %s" % [id,faction,str(replay.get("error",""))])

func verify_mission_sheet() -> void:
	var game := Main.new()
	root.add_child(game)
	game.set_process(false)
	game.meta_profile = Profile.new("")
	var font: Font = ThemeDB.fallback_font
	for id in SETS:
		var data: Dictionary = SETS[id]
		game._open_campaign(0,data.chapter)
		for index in range(10):
			game.campaign_menu._select(index)
			var text: String = game.campaign_menu.mission_detail.text
			var lines: PackedStringArray = text.split("\n")
			check(lines.size() == 2 and lines[0].contains("Affixe : "+data.affix) and lines[1] == Attackers.SHEET_LINES[id],"%s : fiche avec l'affixe et le nouvel attaquant (%s)" % [id,text])
			var tooltip: String = game.campaign_menu.mission_detail.tooltip_text
			check(tooltip.contains(Attackers.rule_for_set(id).replace(" Réglage d’essai.","")) and tooltip.contains("Réglage d’essai"),"%s : règles de l'attaquant et de l'affixe en info-bulle" % id)
			for line in lines: check(font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x <= 358.0,"%s : ligne contenue dans la fiche (%s)" % [id,line])
	await process_frame
	game.free()

func verify_rendering() -> void:
	for id in SETS:
		var data: Dictionary = SETS[id]
		var model := arena(data.type,[0.0,1.0,2.0],data.number)
		var view := View.new();view.model = model;root.add_child(view)
		for time in [1.0,2.6,3.5,13.0,14.5]:
			go(model,time)
			if model.enemies.size() > 0 and data.type in [13,14] and time >= 3.5: model._apply_damage({model.enemies[0].id:float(model.enemies[0].max_hp)*(0.6 if data.type == 13 else 9.0)})
			view.queue_redraw()
			await process_frame
		check(true,"%s : dessin sans erreur" % id)
		view.free()
