extends SceneTree
## Brûlure du Pyromancien humain (décision du porteur, 16 novembre 2026) : son tir direct met le feu à la cible, comme le Brûleur de cendres côté Horde.
## Les rapports d'avant la v0.221 se rejouent sans brûlure.
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func first_burn(type: int, faction: int, active: bool = true) -> Dictionary:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.burn_for_all_curse_units = active
	m.configure_auxiliary(type);m.select_faction(faction);m.rng.seed = 3
	m.buy(3,type)
	m.start()
	var guard := 0
	while m.active and m.curses.is_empty() and m.shots.is_empty() and guard < 4000:
		m.advance(0.01);guard += 1
	m.advance(0.05)
	var burning: Array[Dictionary] = []
	burning.assign(m.curses)
	var ticks := 0
	while m.active and guard < 8000 and ticks < 2:
		m.advance(0.05);guard += 1
		for event in m.damage_events:
			if str(event.get("component","")) == "curse": ticks = maxi(ticks,1)
	return {"model":m,"curses":burning}

func run_checks() -> void:
	var fire: Dictionary = first_burn(15,0)
	check(not fire.curses.is_empty() and fire.curses[0].damage > 0.0,"Le tir du Pyromancien met le feu à la cible")
	var dots: int = 0
	for event in fire.model.damage_events:
		if str(event.get("component","")) == "curse" and int(event.get("source_type",-1)) == 15: dots += 1
	check(dots > 0,"Les tics de brûlure sont enregistrés (source : Pyromancien)")
	var old: Dictionary = first_burn(15,0,false)
	check(old.curses.is_empty(),"Règles d'avant la v0.221 : aucune brûlure")
	var horde: Dictionary = first_burn(21,1)
	check(not horde.curses.is_empty(),"Le Brûleur de cendres brûle toujours (Horde)")
	# Rejeu : un rapport d'avant la v0.221 est rejoué sans brûlure, un rapport actuel avec.
	for active in [false,true]:
		var m = Model.new(true,Model.Maps.for_id("valley_ford"))
		m.rules_v232 = false # Le rapport porte une version antérieure à la 0.232 : tirage de douze bonus.
		m.burn_for_all_curse_units = active
		m.configure_auxiliary(15);m.select_faction(0);m.rng.seed = 5
		m.buy(3,15);m.buy(0,0);m.buy(1,1)
		for wave in range(1,11):
			if not m.start(): break
			while m.active: m.advance(1.0)
			if m.phase == "defeat": break
			if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
			if wave < 10 and not m.prepare_next_wave(): break
		check(m.phase in ["victory","defeat"],"La partie de rejeu se termine (%s)" % m.phase)
		if m.phase in ["victory","defeat"]:
			var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
			report.game_version = "0.221" if active else "0.220"
			var verified: Dictionary = Replay.verify(report)
			check(verified.ok,"Rapport %s rejoué exactement (%s)" % ["actuel" if active else "d'avant la v0.221",verified.get("error","")])
	check(Replay.burn_rules_for("0.220") == false and Replay.burn_rules_for("0.221") and Replay.burn_rules_for("0.300") and Replay.burn_rules_for("inconnu"),"Seuil de version de la brûlure")
	print("PYROMANCER_BURN_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
