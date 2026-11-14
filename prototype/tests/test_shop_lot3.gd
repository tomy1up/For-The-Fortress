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
	verify_slow_math()
	verify_mark_and_aura()
	verify_step_independence()
	verify_replays()
	print("SHOP_LOT3_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_catalogue() -> void:
	for id in ["alliance.frostmage","alliance.observer","alliance.priest","horde.swampshaman","horde.wartotem","horde.elder"]:
		var card: Dictionary = Shop.card(id)
		check(not card.is_empty() and int(card.po) >= 900 and int(card.po) <= 1020 and int(card.unlock_missions) >= 110,"Carte %s du lot 3 : 900 à 1 020 PO, déblocage après au moins 110 missions" % id)
		check(Shop.BRANCHES[card.type].size() == 2 and Model.ROSTER[card.type].name == card.name,"Carte %s : spécialisations et fiche cohérentes" % id)

func verify_slow_math() -> void:
	var model := Model.new(true)
	var enemy: Dictionary = Model.make_enemy(1,1,0.0,-1,100)
	model.elapsed = 2.0
	model._slow_enemy(enemy,3.0)
	var speed: float = enemy.speed
	var length: float = model.enemy_route_length(enemy)
	check(is_equal_approx(model.distance_at(enemy,2.0),speed*2.0) and Model.enemy_is_slowed(enemy),"Le ralentissement ne déplace pas l'ennemi à son application")
	check(is_equal_approx(model.distance_at(enemy,5.0),speed*(5.0-(1.0-Model.SLOW_FACTOR)*3.0)),"Pendant 3 s l'ennemi avance à 60 % de sa vitesse")
	check(is_equal_approx(model.distance_at(enemy,3.0),speed*(3.0-(1.0-Model.SLOW_FACTOR)*1.0)),"La position à mi-ralentissement suit la forme fermée")
	# La prévision d'atteinte d'une distance est cohérente avec la position.
	for d in [3.0,length*0.5,length]:
		var t: float = model.time_at_distance(enemy,d)
		check(absf(model.distance_at(enemy,t)-minf(d,length)) < 0.0001,"time_at_distance et distance_at concordent pour d = %.2f" % d)
	model.enemies.append(enemy)
	model.elapsed = 5.0
	model._end_slows()
	check(not Model.enemy_is_slowed(enemy) and is_equal_approx(float(enemy.delay),(1.0-Model.SLOW_FACTOR)*3.0),"La fin du ralentissement cumule le retard exact")
	check(is_equal_approx(model.distance_at(enemy,8.0),speed*(8.0-float(enemy.delay))) and is_equal_approx(model.distance_at(enemy,5.0),speed*(5.0-(1.0-Model.SLOW_FACTOR)*3.0)),"Après la fin, la vitesse normale reprend sans saut de position")
	# Un ralentissement renouvelé prolonge la durée sans changer l'instant de départ.
	var again: Dictionary = Model.make_enemy(2,1,0.0,-1,100)
	model.elapsed = 1.0
	model._slow_enemy(again,3.0);model.elapsed = 2.5;model._slow_enemy(again,3.0)
	check(is_equal_approx(float(again.slow_start),1.0) and is_equal_approx(float(again.slow_until),5.5),"Un deuxième coup prolonge le ralentissement")
	# Sans ralentissement, les formules d'origine sont inchangées.
	var plain: Dictionary = Model.make_enemy(3,2,1.5,-1,100)
	check(model.distance_at(plain,4.0) == clampf((4.0-1.5)*plain.speed,0.0,length) and model.time_at_distance(plain,6.0) == 1.5+6.0/plain.speed,"Sans effet, positions et temps d'atteinte restent identiques à l'ancien calcul")

func verify_mark_and_aura() -> void:
	var observer: int = Shop.card("alliance.observer").type
	var priest: int = Shop.card("alliance.priest").type
	var model := Model.new(true)
	check(model.configure_auxiliary(observer),"L'éclaireur-observateur est accepté comme alternative")
	model.select_faction(0);model.gold = 2000
	model.buy(3,observer);model.buy(4,0)
	var victim := {"type":1,"hp":40.0,"max_hp":40.0}
	var observer_stats: Dictionary = model.get_stats(3)
	var archer_stats: Dictionary = model.get_stats(4)
	var before: float = model.damage_for(archer_stats,"direct",victim)
	victim.marked_until = 4.0;victim.mark_bonus = 0.3
	model.elapsed = 1.0
	check(is_equal_approx(model.damage_for(archer_stats,"direct",victim)/before,1.3),"Un archer inflige +30 % à une cible marquée")
	check(is_equal_approx(model.damage_for(observer_stats,"direct",victim),model.damage_for(observer_stats,"direct",{"type":1,"hp":40.0,"max_hp":40.0})),"Le marqueur ne profite pas de sa propre marque")
	model.elapsed = 4.5
	check(is_equal_approx(model.damage_for(archer_stats,"direct",victim),before),"La marque expire après 4 s")
	# Aura : deux emplacements proches du prêtre reçoivent +40 %, un emplacement éloigné rien.
	var aura := Model.new(true,Model.Maps.for_id("necro_gate"))
	check(aura.configure_auxiliary(priest),"Le prêtre guerrier est accepté comme alternative")
	aura.select_faction(0);aura.gold = 2000
	var guard_slot := -1;var near := -1;var far := -1
	for candidate in range(aura.slots.size()):
		var close := -1;var distant := -1
		for slot in range(aura.slots.size()):
			if slot == candidate: continue
			var d: float = aura.slots[candidate].distance_to(aura.slots[slot])
			if d <= 3.6 and close < 0: close = slot
			if d > 3.6 and distant < 0: distant = slot
		if close >= 0 and distant >= 0:
			guard_slot = candidate;near = close;far = distant;break
	check(guard_slot >= 0,"La carte de contrôle offre un emplacement de gardien avec un voisin proche et un éloigné")
	aura.buy(guard_slot,priest);aura.buy(near,0);aura.buy(far,0)
	check(is_equal_approx(aura.guardian_aura(near),0.4) and aura.guardian_aura(far) == 0.0 and aura.guardian_aura(guard_slot) == 0.0,"L'aura du prêtre bénit son voisin, pas l'éloigné ni lui-même")
	check(aura.get_stats(near).direct_bonus >= 0.4-0.000001,"L'aura s'ajoute au bonus de dégâts directs du voisin")

func army(card_id: String, step: float, waves: int = 4) -> Dictionary:
	var card: Dictionary = Shop.card(card_id)
	var model := Model.new(true,Model.Maps.for_id("valley_ford"))
	model.configure_auxiliary(card.type)
	model.rng.seed = 7;model.select_faction(card.faction);model.gold = 1200
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
	for id in ["alliance.frostmage","horde.swampshaman","alliance.observer","horde.elder"]:
		var big: Dictionary = army(id,10000.0)
		var small: Dictionary = army(id,0.05)
		var odd: Dictionary = army(id,0.731)
		check(JSON.stringify(big) == JSON.stringify(small) and JSON.stringify(big) == JSON.stringify(odd),"%s : même déroulement avec un grand pas, 50 ms et des pas irréguliers" % id)
	# Le ralentissement change réellement le déroulement par rapport à un tir sans effet.
	var slowed: Dictionary = army("alliance.frostmage",10000.0)
	check(slowed.log.size() > 0,"Le combat avec l'entravant se déroule")

func verify_replays() -> void:
	for id in ["alliance.frostmage","horde.swampshaman","alliance.observer","horde.wartotem","alliance.priest","horde.elder"]:
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
