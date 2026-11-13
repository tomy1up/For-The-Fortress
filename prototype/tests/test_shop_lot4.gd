extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_catalogue()
	verify_progress_rules()
	verify_pivot()
	verify_loot()
	verify_chain_reaction()
	verify_step_independence()
	verify_replays()
	print("SHOP_LOT4_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

const IDS := ["alliance.mercenary","alliance.trapper","alliance.ballista","alliance.alchemist","alliance.veteran","horde.pillager","horde.minelayer","horde.warballista","horde.kamikaze","horde.warveteran"]

func verify_catalogue() -> void:
	for id in IDS:
		var card: Dictionary = Shop.card(id)
		check(not card.is_empty() and int(card.po) >= 1080 and int(card.po) <= 1300 and int(card.unlock_missions) >= 140,"Carte %s du lot 4 : 1 080 à 1 300 PO, déblocage après au moins 140 missions" % id)
		check(Shop.BRANCHES[card.type].size() == 2 and Model.ROSTER[card.type].name == card.name,"Carte %s : spécialisations et fiche cohérentes" % id)
	for faction in range(2):
		var total := 0
		for card in Shop.for_faction(faction): total += int(card.po)
		check(Shop.for_faction(faction).size() == 20 and total >= 14750,"Le catalogue de la faction %d compte 20 unités pour %d PO, au moins les 14 750 PO gagnés" % [faction,total])

## Sapeur d'entrée et tourelle de forteresse : multiplicateur selon l'avancée de la cible sur sa route.
func verify_progress_rules() -> void:
	var model := Model.new(true)
	var length: float = model.path_length
	var trapper: int = Shop.card("alliance.trapper").type
	var ballista: int = Shop.card("alliance.ballista").type
	var early := {"type":1,"hp":40.0,"max_hp":40.0,"distance":length*0.2}
	var middle := {"type":1,"hp":40.0,"max_hp":40.0,"distance":length*0.5}
	var late := {"type":1,"hp":40.0,"max_hp":40.0,"distance":length*0.9}
	var trap_stats: Dictionary = Model.stats_for(trapper)
	check(is_equal_approx(model.progress_multiplier(trap_stats,early),1.8) and model.progress_multiplier(trap_stats,middle) == 1.0 and is_equal_approx(model.progress_multiplier(trap_stats,late),0.4),"Le piégeur : ×1,8 à l'entrée, ×1 au milieu, ×0,4 près de la forteresse")
	var ballista_stats: Dictionary = Model.stats_for(ballista)
	check(is_equal_approx(model.progress_multiplier(ballista_stats,late),1.8) and model.progress_multiplier(ballista_stats,middle) == 1.0 and is_equal_approx(model.progress_multiplier(ballista_stats,early),0.4),"La balliste : ×1,8 près de la forteresse, ×0,4 à l'entrée")
	check(model.progress_multiplier(Model.stats_for(0),early) == 1.0 and model.progress_multiplier(trap_stats,{"type":1,"hp":40.0,"max_hp":40.0}) == 1.0,"Sans règle ou sans position, aucun multiplicateur")
	model.configure_auxiliary(trapper)
	model.select_faction(0);model.gold = 1000;model.buy(2,trapper)
	var stats: Dictionary = model.get_stats(2)
	check(is_equal_approx(model.damage_for(stats,"direct",early)/model.damage_for(stats,"direct",middle),1.8),"damage_for applique le multiplicateur d'entrée")

## Unité-pivot : +12 % par vague survivée depuis l'achat, plafonné à +90 %.
func verify_pivot() -> void:
	var veteran: int = Shop.card("alliance.veteran").type
	var model := Model.new(true)
	model.configure_auxiliary(veteran)
	model.select_faction(0);model.gold = 1000;model.buy(3,veteran)
	check(model.bought_waves.get(model.defenders[3].instance_id,-1) == 1 and model.pivot_bonus(model.defenders[3]) == 0.0,"Le vétéran n'a aucun bonus l'instant où il est acheté")
	model.wave = 4
	check(is_equal_approx(model.pivot_bonus(model.defenders[3]),0.36) and model.get_stats(3).direct_bonus >= 0.36-0.000001,"Après trois vagues survivées : +36 %")
	model.wave = 20
	check(is_equal_approx(model.pivot_bonus(model.defenders[3]),0.9),"Le bonus du vétéran est plafonné à +90 %")
	check(Model.new(true).pivot_bonus({"type":0}) == 0.0,"Une unité ordinaire n'a aucun bonus de pivot")

## Pilleur : l'ennemi touché rapporte +60 % d'or s'il meurt dans les 4 s.
func verify_loot() -> void:
	var model := Model.new(true)
	model.select_faction(0)
	var enemy: Dictionary = Model.make_enemy(1,3,0.0,-1,100) # brute : 7 or
	enemy.hp = 0.0
	enemy.loot_until = 3.0;enemy.loot_bonus = 0.6
	model.elapsed = 2.0
	var start_gold: int = model.gold
	var survivors: Array[Dictionary] = [];var blasts: Array[Dictionary] = []
	model._settle_enemy(enemy,survivors,blasts)
	check(model.gold-start_gold == roundi(7.0*1.6) and survivors.is_empty(),"Un ennemi pillé rapporte +60 %% d'or (%d)" % (model.gold-start_gold))
	var other: Dictionary = Model.make_enemy(2,3,0.0,-1,100);other.hp = 0.0
	other.loot_until = 3.0;other.loot_bonus = 0.6
	model.elapsed = 3.5
	start_gold = model.gold
	model._settle_enemy(other,survivors,blasts)
	check(model.gold-start_gold == 7,"Après 4 s, le pillage a expiré et l'or est normal")

## Réaction en chaîne : un ennemi volatil qui meurt explose, ce qui peut tuer ses voisins (qui explosent à leur tour, une seule fois chacun).
func verify_chain_reaction() -> void:
	var model := Model.new(true)
	model.select_faction(0)
	model.elapsed = 5.0
	var first: Dictionary = Model.make_enemy(1,1,0.0,-1,100);first.distance = 10.0;first.hp = 0.0;first.volatile_until = 8.0;first.volatile_damage = 40.0;first.volatile_radius = 1.4
	var second: Dictionary = Model.make_enemy(2,1,0.0,-1,100);second.distance = 10.5;second.hp = 30.0;second.volatile_until = 8.0;second.volatile_damage = 40.0;second.volatile_radius = 1.4
	var third: Dictionary = Model.make_enemy(3,1,0.0,-1,100);third.distance = 11.2;third.hp = 30.0
	var far: Dictionary = Model.make_enemy(4,1,0.0,-1,100);far.distance = 25.0;far.hp = 30.0
	model.enemies = [first,second,third,far]
	var before: int = model.total_killed
	model._apply_damage({})
	var ids: Array = model.enemies.map(func(enemy):return enemy.id)
	check(model.total_killed-before == 3 and ids == [4],"La chaîne tue le premier, son voisin volatil puis le troisième ; l'éloigné survit (%s)" % str(ids))
	var explosions: Array = model.event_log.filter(func(line):return str(line).contains(" explosion "))
	check(explosions.size() == 2,"Chaque ennemi volatil explose une seule fois (%d explosions)" % explosions.size())

func army(card_id: String, step: float, waves: int = 4) -> Dictionary:
	var card: Dictionary = Shop.card(card_id)
	var model := Model.new(true,Model.Maps.for_id("valley_ford"))
	model.configure_auxiliary(card.type)
	model.rng.seed = 7;model.select_faction(card.faction);model.gold = 1500
	model.buy(3,card.type);model.buy(4,card.faction*3);model.buy(2,card.faction*3+1)
	for wave in range(1,waves+1):
		model.start()
		var guard := 0
		while model.phase == "combat" and guard < 100000:
			model.advance(step);guard += 1
		if model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < waves: model.prepare_next_wave()
	return {"log":model.event_log.duplicate(),"gold":model.gold,"hp":model.fortress_hp,"killed":model.total_killed,"phase":model.phase}

func verify_step_independence() -> void:
	for id in ["alliance.mercenary","horde.minelayer","alliance.ballista","horde.kamikaze","alliance.veteran"]:
		var big: Dictionary = army(id,10000.0)
		var small: Dictionary = army(id,0.05)
		var odd: Dictionary = army(id,0.731)
		check(JSON.stringify(big) == JSON.stringify(small) and JSON.stringify(big) == JSON.stringify(odd),"%s : même déroulement avec un grand pas, 50 ms et des pas irréguliers" % id)

func verify_replays() -> void:
	for id in IDS:
		var card: Dictionary = Shop.card(id)
		var model := Model.new(true)
		model.configure_auxiliary(card.type)
		model.rng.seed = 7;model.select_faction(card.faction)
		model.buy(3,card.type);model.buy(4,card.faction*3)
		for wave in range(1,6):
			model.start();model.advance(10000)
			if model.phase == "defeat": break
			if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
			if wave < 5: model.prepare_next_wave()
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
		var replay: Dictionary = Replay.verify(report)
		check(replay.ok,"%s : rapport rejouable (%s)" % [id,str(replay.get("error",""))])
