extends SceneTree
## Un affixe par biome (v0.245, décision du porteur du 23 novembre 2026) : Crue, Vapeurs toxiques, Cor d'alarme, Courants ascendants et Drain d'âmes.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Main = preload("res://scripts/main.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Library = preload("res://scripts/animation_library.gd")
const FLOOD := {"id":"flood","interval":20,"warning":3,"duration":5,"speed_percent":10}
const MIASMA := {"id":"miasma","interval":16,"warning":3,"duration":5,"damage_percent":20}
const ALARM := {"id":"alarm","interval":20,"warning":3,"shield_percent":10}
const UPDRAFT := {"id":"updraft","interval":20,"warning":3,"tiles":1}
const SOULDRAIN := {"id":"souldrain","interval":20,"warning":3,"duration":5,"heal_percent":10}
const ALL: Array = [FLOOD,MIASMA,ALARM,UPDRAFT,SOULDRAIN]
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
	verify_catalogue()
	verify_flood()
	verify_miasma()
	verify_alarm()
	verify_updraft()
	verify_souldrain()
	verify_step_independence()
	verify_replay()
	verify_texts()
	await verify_mission_sheet()
	await verify_souldrain_sheets()
	await verify_rendering()
	print("BIOME_AFFIXES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

## Combat isolé : ennemis de type 1 aux instants donnés, aucun défenseur.
func arena(affix: Dictionary, times: Array, speed: float = 0.4) -> Model:
	var model := Model.new(true,Model.Maps.for_id("ford_turns"))
	check(model.configure_combat_affix(affix),"Affixe %s accepté" % affix.id)
	model.select_faction(0)
	var schedule: Array[Dictionary] = []
	for time in times: schedule.append({"type":1,"time":float(time)})
	model.spawn_schedule = schedule
	check(model.start(),"Combat isolé démarré")
	for enemy in model.enemies: enemy.speed = speed
	return model

func go(model: Model, time: float) -> void:
	model.advance(time-model.elapsed)

func verify_validation() -> void:
	for affix in ALL:
		var model := Model.new(true,Model.Maps.for_id("ford_turns"))
		check(model.configure_combat_affix(affix),"%s : réglage valide" % affix.id)
		var key: String = {"flood":"speed_percent","miasma":"damage_percent","alarm":"shield_percent","updraft":"tiles","souldrain":"heal_percent"}[affix.id]
		var bad: Array = []
		for field in affix:
			if field == "id": continue
			var missing: Dictionary = affix.duplicate();missing.erase(field);bad.append(missing)
			var text: Dictionary = affix.duplicate();text[field] = "3";bad.append(text)
			var fraction: Dictionary = affix.duplicate();fraction[field] = 3.5;bad.append(fraction)
			var infinite: Dictionary = affix.duplicate();infinite[field] = INF;bad.append(infinite)
		var extra: Dictionary = affix.duplicate();extra.other = 1;bad.append(extra)
		var early: Dictionary = affix.duplicate();early.interval = 9;bad.append(early)
		var late: Dictionary = affix.duplicate();late.interval = 41;bad.append(late)
		var no_warning: Dictionary = affix.duplicate();no_warning.warning = 0;bad.append(no_warning)
		var zero: Dictionary = affix.duplicate();zero[key] = 0;bad.append(zero)
		var huge: Dictionary = affix.duplicate();huge[key] = 99;bad.append(huge)
		if affix.has("duration"):
			var overlap: Dictionary = affix.duplicate();overlap.interval = 10;overlap.duration = 8;bad.append(overlap)
		for value in bad:
			var other := Model.new(true,Model.Maps.for_id("ford_turns"))
			check(not other.configure_combat_affix(value) and other.combat_affix.is_empty(),"%s : réglage refusé %s" % [affix.id,str(value)])

func verify_catalogue() -> void:
	check(Catalogue.definition(1).get("combat_affix",{}).is_empty(),"La mission 1 reste sans affixe")
	var expected: Dictionary = {1:"flood",2:"headwinds",3:"miasma",4:"eruptions",5:"alarm",6:"sandstorm",7:"rockfall",8:"updraft",9:"seamist",10:"souldrain"}
	var seen: Dictionary = {}
	for number in range(2,201):
		var biome: int = (number-1)/20+1
		var affix: Dictionary = Catalogue.definition(number).get("combat_affix",{})
		check(str(affix.get("id","")) == expected[biome],"Mission %d : affixe de son biome" % number)
		seen[str(affix.get("id",""))] = true
		var model := Model.new(true,Model.Maps.for_id(str(Catalogue.definition(number).map_id)))
		check(model.configure_combat_affix(affix),"Mission %d : affixe accepté par sa carte" % number)
	check(seen.size() == 10,"Dix affixes, un par biome")

func verify_flood() -> void:
	var model := arena(FLOOD,[0.0])
	var enemy: Dictionary = model.enemies[0]
	for sample in [[19.0,19.0],[20.0,20.0],[23.0,23.3],[25.0,25.5],[30.0,30.5],[40.0,40.5],[42.0,42.7]]:
		go(model,sample[0])
		check(is_equal_approx(float(enemy.distance),0.4*float(sample[1])),"Crue : position exacte à %.1f s (%.3f)" % [sample[0],enemy.distance])
	var late := arena(FLOOD,[0.0,22.0])
	go(late,24.0)
	check(late.enemies.size() == 2 and is_equal_approx(float(late.enemies[1].distance),float(late.enemies[1].speed)*2.2),"Un ennemi apparu pendant la crue n'en profite qu'à partir de son apparition")
	var slowed := arena(FLOOD,[0.0])
	go(slowed,19.0)
	slowed._slow_enemy(slowed.enemies[0],3.0)
	go(slowed,21.0)
	var runner: Dictionary = slowed.enemies[0]
	check(is_equal_approx(float(runner.distance),0.4*(19.0+0.6+0.7)),"Ralentissement et crue se combinent (%.3f)" % runner.distance)
	for time in [21.5,21.99,22.5,24.0,24.9]:
		check(absf(slowed.time_at_distance(runner,slowed.distance_at(runner,time))-time) < 0.0001,"Instant et distance restent réciproques pendant la crue (%.2f s)" % time)
	go(slowed,26.0)
	check(is_equal_approx(float(runner.distance),0.4*(26.0-0.4*3.0+0.5)),"Après la crue et le ralentissement (%.3f)" % runner.distance)

func verify_miasma() -> void:
	var model := arena(MIASMA,[0.0])
	var enemy: Dictionary = model.enemies[0]
	var full: float = float(enemy.hp)
	go(model,10.0)
	model._apply_damage({enemy.id:10.0})
	check(is_equal_approx(float(enemy.hp),full-10.0),"Hors vapeurs : dégâts complets")
	go(model,17.0)
	check(is_equal_approx(model.miasma_factor_now(),0.8),"Vapeurs : facteur 0,8")
	var before: float = float(enemy.hp)
	model._apply_damage({enemy.id:10.0})
	check(is_equal_approx(float(enemy.hp),before-8.0),"Vapeurs : 20 % de dégâts en moins")
	go(model,21.0)
	check(model.miasma_factor_now() == 1.0,"Fin des vapeurs à 21 s")

func verify_alarm() -> void:
	var model := arena(ALARM,[0.0,0.0,22.0])
	var first: Dictionary = model.enemies[0]
	var second: Dictionary = model.enemies[1]
	check(not first.has("shield"),"Pas de bouclier avant le cor")
	go(model,20.0)
	var value: float = float(first.max_hp)*0.1
	check(is_equal_approx(float(first.get("shield",0.0)),value) and is_equal_approx(float(second.get("shield",0.0)),value),"Le cor donne 10 % des PV maximum aux ennemis présents")
	go(model,23.0)
	check(model.enemies.size() == 3 and not model.enemies[2].has("shield"),"Un ennemi arrivé après le cor n'a pas de bouclier")
	var hp: float = float(first.hp)
	model._apply_damage({first.id:value*0.5})
	check(is_equal_approx(float(first.hp),hp) and is_equal_approx(float(first.shield),value*0.5),"Le bouclier absorbe avant les PV")
	model._apply_damage({first.id:value})
	check(is_equal_approx(float(first.hp),hp-value*0.5) and not first.has("shield"),"Le surplus touche les PV, le bouclier disparaît")
	go(model,40.0)
	check(is_equal_approx(float(second.get("shield",0.0)),value),"Le bouclier ne se cumule pas")

func verify_updraft() -> void:
	var model := arena(UPDRAFT,[0.0])
	var enemy: Dictionary = model.enemies[0]
	go(model,19.9)
	var before: float = float(enemy.distance)
	go(model,20.0)
	check(is_equal_approx(float(enemy.distance),before+0.04+1.0),"Bond d'une case à 20 s (%.3f)" % enemy.distance)
	go(model,25.0)
	check(is_equal_approx(float(enemy.distance),0.4*25.0+1.0),"La marche reprend après le bond")
	check(model.affix_events.any(func(event): return event.kind == "updraft"),"Le bond est signalé à la vue")
	var edge := arena(UPDRAFT,[0.0])
	var runner: Dictionary = edge.enemies[0]
	var length: float = edge.enemy_route_length(runner)
	runner.speed = (length-0.3)/19.99
	go(edge,20.0)
	check(edge.enemies.size() == 1 and float(runner.distance) < length and float(runner.distance) >= length-Model.UPDRAFT_MARGIN-0.01,"Un bond ne dépose jamais l'ennemi sur la forteresse (%.3f / %.3f)" % [runner.distance,length])
	check(edge.fortress_hp == edge.max_hp,"Aucun PV perdu par le bond")

func verify_souldrain() -> void:
	var model := arena(SOULDRAIN,[0.0,0.0,0.0])
	var victim: Dictionary = model.enemies[0]
	go(model,11.0)
	var near: Dictionary = model.enemies[1]
	var far: Dictionary = model.enemies[2]
	near.hp = float(near.max_hp)*0.5;far.hp = float(far.max_hp)*0.5
	model._apply_damage({victim.id:99999.0})
	check(is_equal_approx(float(near.hp),float(near.max_hp)*0.5),"Hors fenêtre : aucun soin")
	var inside := arena(SOULDRAIN,[0.0,0.0,0.0])
	var distant: Dictionary = inside.enemies[2]
	distant.delay = -5.0/float(distant.speed) # Cinq cases devant les deux autres.
	go(inside,21.0)
	var dying: Dictionary = inside.enemies[0]
	var healed: Dictionary = inside.enemies[1]
	check(inside.enemy_separation_squared(dying,healed) <= Model.SOULDRAIN_RADIUS*Model.SOULDRAIN_RADIUS and inside.enemy_separation_squared(dying,distant) > Model.SOULDRAIN_RADIUS*Model.SOULDRAIN_RADIUS,"Situation de contrôle : un voisin proche, un éloigné")
	healed.hp = float(healed.max_hp)*0.5;distant.hp = float(distant.max_hp)*0.5
	inside._apply_damage({dying.id:99999.0})
	check(is_equal_approx(float(healed.hp),float(healed.max_hp)*0.6),"Pendant le drain : le voisin proche regagne 10 % de ses PV maximum")
	check(is_equal_approx(float(distant.hp),float(distant.max_hp)*0.5),"Un ennemi éloigné n'est pas soigné")
	check(inside.affix_events.any(func(event): return event.kind == "soul"),"Le soin est signalé à la vue")
	var capped := arena(SOULDRAIN,[0.0,0.0])
	go(capped,21.0)
	capped.enemies[1].hp = float(capped.enemies[1].max_hp)*0.95
	capped._apply_damage({capped.enemies[0].id:99999.0})
	check(is_equal_approx(float(capped.enemies[0].hp),float(capped.enemies[0].max_hp)),"Le soin ne dépasse pas les PV maximum")
	var boss := arena(SOULDRAIN,[0.0,0.0])
	go(boss,21.0)
	boss.enemies[1].type = 7
	boss.enemies[1].hp = float(boss.enemies[1].max_hp)*0.5
	boss._apply_damage({boss.enemies[0].id:99999.0})
	check(is_equal_approx(float(boss.enemies[0].hp),float(boss.enemies[0].max_hp)*0.5),"Le boss n'est pas soigné")

func played(affix: Dictionary, step: float) -> String:
	var model := Model.new(true,Model.Maps.for_id("ford_turns"))
	model.configure_combat_affix(affix)
	model.select_faction(0)
	model.rng.seed = 7
	model.buy(3,0);model.buy(4,1)
	for wave in range(1,4):
		model.start()
		var guard := 0
		while model.phase == "combat" and guard < 200000:
			model.advance(step);guard += 1
		if model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 3: model.prepare_next_wave()
	return JSON.stringify([model.event_log,model.fortress_hp,model.gold,model.total_killed,model.total_escaped])

func verify_step_independence() -> void:
	for affix in ALL:
		var big: String = played(affix,10000.0)
		check(big == played(affix,0.05) and big == played(affix,0.731),"%s : même déroulement quel que soit le pas" % affix.id)

func verify_replay() -> void:
	for affix in ALL:
		for faction in range(2):
			var model := Model.new(true,Model.Maps.for_id("ford_turns"))
			check(model.configure_combat_affix(affix),"%s : combat complet" % affix.id)
			model.select_faction(faction)
			model.rng.seed = 7
			var types: Array = [0,1,1] if faction == 0 else [3,3,5]
			model.buy(3,types[0]);model.buy(4,types[1])
			for wave in range(1,11):
				if wave == 2: model.upgrade(3)
				if wave >= 2 and model.defenders[2].is_empty(): model.buy(2,types[2])
				model.start();model.advance(10000)
				if model.phase == "defeat": break
				if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
				if wave < 10: model.prepare_next_wave()
			var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
			var replay: Dictionary = Replay.verify(report)
			check(replay.ok,"%s, faction %d : rapport rejouable : %s" % [affix.id,faction,str(replay.get("error",""))])
			check(Report.markdown(report).contains(Model.Campaign.BIOME_AFFIX_NAMES[affix.id]),"%s : le rapport lisible nomme l'affixe" % affix.id)

func verify_texts() -> void:
	var font: Font = ThemeDB.fallback_font
	for affix in ALL:
		var model := arena(affix,[0.0,1.0,2.0],0.05)
		check(not model.affix_description().is_empty() and model.affix_tooltip().contains("Réglage d’essai"),"%s : description et règle" % affix.id)
		check(View.affix_banner(model).is_empty(),"%s : pas de bandeau au départ" % affix.id)
		go(model,float(affix.interval)-1.5)
		var warning: Dictionary = View.affix_banner(model)
		check(warning.get("state","") == "warning" and str(warning.text).begins_with(Model.Campaign.BIOME_AFFIX_NAMES[affix.id]+" dans"),"%s : annonce (%s)" % [affix.id,warning.get("text","")])
		check(font.get_string_size(str(warning.text),HORIZONTAL_ALIGNMENT_LEFT,-1,15).x <= 382.0,"%s : annonce lisible dans le bandeau" % affix.id)
		go(model,float(affix.interval)+0.5)
		var running: Dictionary = View.affix_banner(model)
		check(running.get("state","") == "active" and float(running.fraction) > 0.0 and float(running.fraction) <= 1.0,"%s : effet en cours (%s)" % [affix.id,running.get("text","")])
		check(font.get_string_size(str(running.text),HORIZONTAL_ALIGNMENT_LEFT,-1,15).x <= 382.0,"%s : effet lisible dans le bandeau" % affix.id)
		check(str(running.text).contains("encore") == affix.has("duration"),"%s : durée affichée seulement pour un effet qui dure" % affix.id)

func verify_mission_sheet() -> void:
	var game := Main.new()
	root.add_child(game)
	game.set_process(false)
	game.meta_profile = Profile.new("")
	var font: Font = ThemeDB.fallback_font
	var names: Dictionary = {1:"Crue",2:"Crue",5:"Vapeurs toxiques",6:"Vapeurs toxiques",9:"Cor d'alarme",10:"Cor d'alarme",15:"Courants ascendants",16:"Courants ascendants",19:"Drain d'âmes",20:"Drain d'âmes"}
	for chapter in names:
		game._open_campaign(0,chapter)
		for index in range(10):
			if chapter == 1 and index == 0:
				game.campaign_menu._select(0)
				check(not game.campaign_menu.mission_detail.text.contains("Crue"),"Mission 1 : aucun affixe annoncé")
				continue
			game.campaign_menu._select(index)
			var text: String = game.campaign_menu.mission_detail.text
			var lines: PackedStringArray = text.split("\n")
			check(lines.size() == 2 and text.contains(names[chapter]) and text.contains("PV ennemis"),"Chapitre %d : fiche avec l'affixe, sur deux lignes (%s)" % [chapter,text])
			check(text.contains("Nouveau : "+names[chapter]) if chapter%2 == 1 else text.contains("Affixe : "+names[chapter]),"Chapitre %d : affixe annoncé comme nouveau au premier chapitre du biome" % chapter)
			check(game.campaign_menu.mission_detail.tooltip_text.contains("Réglage d’essai"),"Chapitre %d : règle en info-bulle" % chapter)
			for line in lines: check(font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x <= 358.0,"Chapitre %d : ligne contenue dans la fiche (%s)" % [chapter,line])
	await process_frame
	game.free()

## Habillage du Drain d'âmes livré par Codex (v0.249) : planches, fondus, trajet de l'âme, suivi de l'ennemi soigné, aucun effet sur le combat.
func verify_souldrain_sheets() -> void:
	Library.clear_cache()
	var spec: Dictionary = Library.spec_for("effect.souldrain")
	check(not spec.is_empty() and ["spawn","idle","death","warning","mist"].all(func(name): return spec.animations.has(name) and Library.texture_for("effect.souldrain",spec.animations[name]) != null),"Les cinq planches du Drain d'âmes sont chargées")
	check(View.souldrain_mist_alpha(0.0,5.0) == 0.0 and is_equal_approx(View.souldrain_mist_alpha(0.13,4.87),0.5) and View.souldrain_mist_alpha(2.0,3.0) == 1.0,"Les volutes montent en 0,26 s")
	check(is_equal_approx(View.souldrain_mist_alpha(4.83,0.17),0.5) and View.souldrain_mist_alpha(5.0,0.0) == 0.0,"Les volutes se dissipent avant la fin de l'effet")
	check(View.soul_arc_height(5.0) == 4.0 and View.soul_arc_height(200.0) == 11.0,"Courbe de l'âme entre 4 et 11 px")
	check(View.soul_size(5.0) == 0.32 and View.soul_size(200.0) == 1.0,"Taille de l'âme entre 0,32 et 1 selon le trajet")
	var from := Vector2(10,40);var to := Vector2(70,20)
	check(View.soul_point(from,to,0.0).is_equal_approx(from) and View.soul_point(from,to,1.0).is_equal_approx(to) and View.soul_point(from,to,0.5).y < from.lerp(to,0.5).y,"L'âme part de la chute, s'élève puis rejoint sa cible")
	Library.spec_for("effect.rockfall")
	check(Library.death_window() == 0.0,"Le dégagement et l'absorption n'allongent pas l'affichage des éliminations")
	var model := arena(SOULDRAIN,[0.0,0.0,0.0])
	go(model,21.0)
	var dying: Dictionary = model.enemies[0]
	var healed: Dictionary = model.enemies[1]
	healed.hp = float(healed.max_hp)*0.5
	var dead_id: int = int(dying.id)
	model._apply_damage({dying.id:99999.0})
	var souls: Array = model.affix_events.filter(func(event): return event.kind == "soul")
	check(souls.size() == 1 and int(souls[0].target_id) == int(healed.id) and int(souls[0].source_id) == dead_id,"Chaque soin désigne l'ennemi éliminé et l'ennemi soigné")
	var view := View.new();view.model = model;root.add_child(view)
	var state := func() -> String: return JSON.stringify([model.gold,model.rng.state,model.fortress_hp,float(healed.hp)])
	var before: String = state.call()
	for step in range(6):
		view.queue_redraw()
		await process_frame
		await process_frame
		model.advance(0.1)
	check(before == state.call(),"Dessiner le transfert ne change pas le combat")
	check(view._soul_target_foot(souls[0]).is_equal_approx(View.project(model.position_at(view.display_distance(healed),model.enemy_route_points(healed),model.enemy_route_length(healed)))) and not view._soul_target_foot(souls[0]).is_equal_approx(View.project(souls[0].to)),"L'absorption suit l'ennemi soigné pendant sa marche")
	model.enemies.erase(healed)
	check(view._soul_target_foot(souls[0]).is_equal_approx(View.project(souls[0].to)),"Ennemi disparu : repli sur sa position au moment du soin")
	view.free()
	Library.clear_cache()

func verify_rendering() -> void:
	for affix in ALL:
		var model := arena(affix,[0.0,1.0,2.0],0.05)
		var view := View.new();view.model = model;root.add_child(view)
		for time in [float(affix.interval)-2.0,float(affix.interval)+0.2,float(affix.interval)+1.0]:
			go(model,time)
			if affix.id == "souldrain" and time > float(affix.interval) and model.enemies.size() > 1: model._apply_damage({model.enemies[0].id:99999.0})
			view.queue_redraw()
			await process_frame
		check(true,"%s : dessin sans erreur" % affix.id)
		view.free()
