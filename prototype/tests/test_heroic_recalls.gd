extends SceneTree
## Cumul des nouveautés de l'Héroïque (v0.259, validé par le porteur le 26 novembre 2026) : rotation des rappels, affixe rappelé décalé de 6 s,
## attaquants rappelés aux vagues 4, 7 et 10, écran de campagne, lancement, rapport et rejeu, absence en Normal.
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Recalls = preload("res://scripts/heroic_recalls.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Scout = preload("res://scripts/mission_scout.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Reference = preload("res://tests/reference_army.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	verify_rotation()
	verify_catalogue()
	verify_model()
	verify_timing()
	verify_banner()
	verify_games()
	verify_screen_and_launch()
	print("HEROIC_RECALLS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

func verify_rotation() -> void:
	var previous: Dictionary = {}
	for number in range(1,201):
		var recall: Dictionary = Recalls.plan(number)
		var chapter: int = (number-1)/10+1
		var biome: int = (chapter+1)/2
		var count: int = (1 if int(recall.attacker) > 0 else 0)+(1 if int(recall.affix) > 0 else 0)
		if chapter < 3: check(count == 0,"Mission %d : aucun rappel aux chapitres 1 et 2" % number)
		elif chapter < 11: check(count == 1 and (int(recall.attacker) > 0) == (number%2 == 1),"Mission %d : un rappel, attaquant aux missions impaires, affixe aux paires" % number)
		else: check(count == 2 and int(recall.attacker) != int(recall.affix),"Mission %d : un attaquant et un affixe de deux biomes différents" % number)
		check(int(recall.attacker) < biome and int(recall.affix) < biome,"Mission %d : rappels d'un biome déjà traversé" % number)
		check(int(recall.attacker) not in [3,6,10],"Mission %d : ni Gueule-de-Vase, ni Scorpion, ni Nécropole" % number)
		if not previous.is_empty():
			check(int(recall.attacker) == 0 or int(recall.attacker) != int(previous.attacker),"Mission %d : pas deux fois de suite le même attaquant" % number)
			check(int(recall.affix) == 0 or int(recall.affix) != int(previous.affix),"Mission %d : pas deux fois de suite le même affixe" % number)
		check(recall == Recalls.plan(number),"Mission %d : rappel fixe" % number)
		previous = recall
	check(Recalls.plan(41) == {"attacker":1,"affix":0} and Recalls.plan(42) == {"attacker":0,"affix":2} and Recalls.plan(101) == {"attacker":2,"affix":4},"Exemples : 41 Tortue, 42 Vents contraires, 101 Bouquetin et Éruptions")
	check(Recalls.attacker_groups(5) == [[7,10,1,0.0],[10,10,1,0.0]] and Recalls.attacker_groups(8).size() == 3 and Recalls.attacker_groups(3).is_empty(),"Garnison aux vagues 7 et 10, aigles aux vagues 4, 7 et 10")

func verify_catalogue() -> void:
	var ids: Array = []
	for biome in range(1,10): ids.append(str(Catalogue.biome_affix(biome).get("id","")))
	check(ids == ["flood","headwinds","miasma","eruptions","alarm","sandstorm","rockfall","updraft","seamist"],"Affixe de chaque biome")
	for number in range(1,201):
		check(Catalogue.recalled_affix(number,0).is_empty() and Catalogue.recalled_attackers(number,0).is_empty() and Catalogue.recall_text(number,0).is_empty(),"Mission %d : rien en Normal" % number)
		var affix: Dictionary = Catalogue.recalled_affix(number,1)
		var main: Dictionary = Catalogue.definition(number).get("combat_affix",{})
		check(affix.is_empty() or (Model.valid_affix(affix) and str(affix.id) != str(main.get("id",""))),"Mission %d : affixe rappelé valide, différent de celui du biome" % number)
		check(Recalls.valid_attackers(Catalogue.recalled_attackers(number,1)),"Mission %d : attaquants rappelés valides" % number)
	check(Catalogue.recall_text(101,1) == "Rappel : Bouquetin des crêtes (Ardoises) · Éruptions (Terres volcaniques)","Texte du rappel")

func heroic_model(number: int, faction: int, hp_percent: int = -1) -> Model:
	var runtime: Dictionary = Catalogue.runtime(Catalogue.id_for(number,1))
	var m := Model.new(true,Model.Maps.for_id(runtime.map_id))
	var ok: bool = m.configure_enemy_hp(Catalogue.faction_hp_percent(number,faction,1) if hp_percent < 0 else hp_percent) and m.configure_wave_set(runtime.get("wave_set_id","ford")) and m.configure_difficulty(1)
	ok = ok and m.configure_champions((number-1)/10+1) and m.configure_combat_affix(runtime.get("combat_affix",{})) and m.configure_wave_reinforcements(Catalogue.wave_reinforcements(number,faction))
	ok = ok and m.configure_recalled_affix(Catalogue.recalled_affix(number,1)) and m.configure_recalled_attackers(Catalogue.recalled_attackers(number,1))
	check(ok,"Mission héroïque %d préparée" % number)
	m.select_faction(faction)
	return m

func verify_model() -> void:
	var m := Model.new(true,Model.Maps.for_id("valley_ford"))
	check(m.configure_combat_affix(Catalogue.biome_affix(6)) and not m.configure_recalled_affix(Catalogue.biome_affix(6)) and m.configure_recalled_affix(Catalogue.biome_affix(1)),"L'affixe rappelé ne peut pas être celui du biome")
	check(not m.configure_combat_affix(Catalogue.biome_affix(1)),"L'affixe du biome ne peut pas reprendre l'affixe rappelé")
	check(not m.configure_recalled_affix({"id":"flood"}) and not m.configure_recalled_affix("flood") and m.configure_recalled_affix({}),"Affixe rappelé invalide refusé, vide accepté")
	check(not m.configure_recalled_attackers([[4,1,2,1.0]]) and not m.configure_recalled_attackers([[11,14,2,4.0]]) and not m.configure_recalled_attackers([[4,14,11,4.0]]),"Attaquants rappelés invalides refusés (type ordinaire, vague 11, groupe de 11)")
	var plain: int = m.spawn_schedule.size()
	check(m.configure_recalled_attackers(Recalls.attacker_groups(4)),"Golems rappelés")
	check(m.spawn_schedule.size() == plain,"Vague 1 : pas de golem")
	var counts: Array = []
	for wave in range(1,11):
		counts.append(Model.Campaign.schedule(wave,m.wave_set_id,m.extra_groups()).filter(func(entry): return int(entry.type) == 14).size())
	check(counts == [0,0,0,2,0,0,2,0,0,2],"Deux golems aux vagues 4, 7 et 10 : %s" % str(counts))
	var forecast: Dictionary = Model.wave_forecast(4,0,100,"ford",[],m.recalled_attackers)
	check(forecast.groups.any(func(group): return int(group.type) == 14 and int(group.count) == 2),"La prévision de vague annonce les golems")
	check(Scout.encounter_data(101,0,1).any(func(enemy): return int(enemy.type) == 13) and not Scout.encounter_data(101,0,0).any(func(enemy): return int(enemy.type) == 13),"Voir les ennemis : bouquetins rappelés en Héroïque seulement")

## Affixe rappelé décalé de 6 s : Crue rappelée à 6, 18, 30 s pendant la Tempête de sable du biome à 12, 24, 36 s.
func verify_timing() -> void:
	var m := Model.new(true,Model.Maps.for_id("valley_ford"))
	m.configure_combat_affix(Catalogue.biome_affix(6));m.configure_recalled_affix(Catalogue.biome_affix(1));m.select_faction(0)
	m.buy(3,0)
	m.start()
	var seen: Array = []
	var last: String = ""
	for step in range(0,400):
		m.advance(0.1)
		if not m.active: break
		var state: String = ("C" if m.biome_affix_status("flood").get("state","") == "active" else "-")+("T" if m.storm_active_now() else "-")
		if state != last: seen.append([snappedf(m.elapsed,0.1),state]);last = state
	var flood_starts: Array = seen.filter(func(item): return item[1].begins_with("C")).map(func(item): return item[0])
	check(flood_starts.size() >= 2 and absf(flood_starts[0]-6.0) < 0.15 and absf(flood_starts[1]-18.0) < 0.15,"Crue rappelée à 6 puis 18 s : %s" % str(seen.slice(0,6)))
	check(seen.any(func(item): return absf(item[0]-12.0) < 0.15 and item[1] == "-T"),"Tempête du biome à 12 s, sans crue en même temps")
	check(m.event_log.any(func(line): return " crue 1 début" in line) and m.event_log.any(func(line): return " tempête 1 début" in line),"Les deux affixes sont journalisés")
	# Éruption rappelée : première à 6 s.
	var e := Model.new(true,Model.Maps.for_id("valley_ford"))
	e.configure_combat_affix(Catalogue.biome_affix(6));e.configure_recalled_affix(Catalogue.biome_affix(4))
	check(is_equal_approx(e.eruption_time(1),6.0) and is_equal_approx(e.storm_start_time(1),12.0),"Éruption rappelée à 6 s, tempête du biome à 12 s")
	var r := Model.new(true,Model.Maps.for_id("valley_ford"))
	r.configure_recalled_affix(Catalogue.biome_affix(7))
	check(is_equal_approx(r.rockfall_time(2),18.0) and Array(Model.rockfall_held_times([7.0,12.0],12.0,5.0,0.6,-6.0)) == [11.0,12.0],"Éboulement rappelé : blocage de 6 à 11 s")

func verify_banner() -> void:
	var m := Model.new(true,Model.Maps.for_id("valley_ford"))
	m.configure_combat_affix(Catalogue.biome_affix(6));m.configure_recalled_affix(Catalogue.biome_affix(1));m.select_faction(0)
	m.buy(3,0);m.start()
	m.advance(4.0)
	var banner: Dictionary = View.affix_banner(m)
	check(banner.get("text","").begins_with("Rappel · Crue dans") and banner.state == "warning","Bandeau : annonce de la crue rappelée")
	m.advance(3.0)
	banner = View.affix_banner(m)
	check(banner.get("text","").begins_with("Rappel · Crue · encore") and banner.state == "active","Bandeau : crue rappelée en cours")
	m.advance(6.0)
	banner = View.affix_banner(m)
	check(banner.get("text","").begins_with("Tempête de sable · encore"),"Bandeau : tempête du biome en cours")
	var w := Model.new(true,Model.Maps.for_id("valley_ford"))
	w.configure_combat_affix(Catalogue.biome_affix(6));w.configure_recalled_affix(Catalogue.biome_affix(2))
	check(View.affix_banner(w).get("text","") == "Rappel · Vents contraires · cadence −10 %","Vents contraires rappelés : bandeau permanent hors des rafales")

func play(m: Model, faction: int, number: int, step: float) -> Dictionary:
	m.rng.seed = 11
	var types: Array = Reference.types(faction,number)
	var slots: Array = [0,1,2]
	m.buy(slots[0],types[0]);m.buy(slots[1],types[1])
	for wave in range(1,11):
		if wave >= 2 and m.defenders[slots[2]].is_empty(): m.buy(slots[2],types[2])
		if wave >= 5:
			for slot in slots:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): break
		while m.active: m.advance(step)
		if m.phase == "defeat": break
		if m.phase == "bonus": Reference.choose_bonus(m)
		if wave < 10: m.prepare_next_wave()
	return JSON.parse_string(JSON.stringify(Report.build(m)))

func verify_games() -> void:
	# Toutes les missions héroïques à partir du chapitre 3 : partie jouée, rapport rejoué.
	var families: Dictionary = {}
	for number in range(21,201):
		var faction: int = number%2
		var report: Dictionary = play(heroic_model(number,faction),faction,number,1000.0)
		var replay: Dictionary = Replay.verify(report)
		check(replay.ok,"Mission héroïque %d : rapport rejouable : %s" % [number,str(replay.get("error",""))])
		check(report.get("recalled_affix",{}) == JSON.parse_string(JSON.stringify(Catalogue.recalled_affix(number,1))) and report.has("recalled_attackers") == (not Catalogue.recalled_attackers(number,1).is_empty()),"Mission héroïque %d : le rapport garde les rappels" % number)
		families[str(report.get("recalled_affix",{}).get("id",""))] = true
	check(families.size() == 10,"Les neuf affixes rappelables ont été joués (%s)" % str(families.keys()))
	# Petits et grands pas : même partie pour un rappel de chaque famille d'affixe.
	for number in [102,104,110,128,146,168,190]:
		var faction: int = number%2
		var coarse: Dictionary = play(heroic_model(number,faction),faction,number,300.0)
		var fine: Dictionary = play(heroic_model(number,faction),faction,number,0.05)
		check(Replay._difference(coarse,fine,"rapport").is_empty(),"Mission héroïque %d : même partie à petits et grands pas (%s)" % [number,str(coarse.get("recalled_affix",{}).get("id",""))])
	var sample: Dictionary = play(heroic_model(101,1),1,101,300.0)
	var without: Dictionary = sample.duplicate(true);without.erase("recalled_affix")
	check(not Replay.verify(without).ok,"Retirer l'affixe rappelé rend le rapport incohérent")
	var early: Dictionary = play(heroic_model(21,0,100),0,21,300.0) # Tortues rappelées : partie qui dépasse la vague 4.
	check(early.has("recalled_attackers") and int(early.get("wave",0)) >= 4,"Mission héroïque 21 : la partie atteint les tortues rappelées (vague %d)" % int(early.get("wave",0)))
	var no_attackers: Dictionary = early.duplicate(true);no_attackers.erase("recalled_attackers")
	check(not Replay.verify(no_attackers).ok,"Retirer les attaquants rappelés rend le rapport incohérent")
	var old: Dictionary = sample.duplicate(true);old.game_version = "0.258"
	check(Replay.verify(old).get("error","") == "Rappels invalides.","Un rapport d'avant la v0.259 ne peut pas porter de rappel")

func winner(faction: int, normal: int, heroic: int) -> Profile:
	var profile := Profile.new("")
	for item in [[0,normal],[1,heroic]]:
		for number in range(1,int(item[1])+1):
			var id: int = profile.begin_mission(faction,Catalogue.id_for(number,int(item[0])),1,10,0)
			profile.credit_mission(id,faction,10,true)
	return profile

func verify_screen_and_launch() -> void:
	var game = Main.new();root.add_child(game);game.set_process(false)
	game.meta_profile = winner(0,100,100)
	game._open_campaign(0)
	var menu = game.campaign_menu
	menu._difficulty(1)
	check(menu.chapter == 11 and menu.selected == 0,"Héroïque ouvert sur la mission 101")
	check(menu.infinite_title.text == "Rappels de l'Héroïque" and menu.infinite_label.text == "Bouquetin des crêtes (Ardoises) · vagues 4, 7, 10\nÉruptions (Terres volcaniques) · décalé de 6 s","Écran de campagne : rappels de la mission 101")
	menu._difficulty(0)
	check(menu.infinite_title.text == "Mode infini" and menu.infinite_label.text.contains("Mode infini"),"Normal : bloc du mode infini")
	menu._difficulty(1)
	menu._launch()
	var model = game.model
	check(not game.choosing_faction and model.difficulty == 1 and model.combat_affix.get("id","") == "sandstorm" and model.recalled_affix.get("id","") == "eruptions" and model.recalled_attackers == Recalls.attacker_groups(2),"Mission héroïque 101 lancée avec ses rappels")
	check(game.affix_label.visible and game.affix_label.text == "Tempête de sable · rappel : Éruptions" and game.affix_label.tooltip_text.contains("décalé de 6 s"),"Ligne d'affixe : affixe du biome et rappel")
	game.free()
	# Normal : aucune trace du cumul.
	var normal = Main.new();root.add_child(normal);normal.set_process(false)
	normal.meta_profile = winner(0,100,0)
	normal._open_campaign(0,11)
	normal.campaign_menu._launch()
	check(not normal.choosing_faction and normal.model.recalled_affix.is_empty() and normal.model.recalled_attackers.is_empty() and normal.affix_label.text == normal.model.affix_description(),"Normal : pas de rappel")
	normal.free()
