extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Main = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func fingerprint(m: RefCounted) -> String:
	return JSON.stringify([m.gold,m.fortress_hp,m.enemies,m.defenders,m.event_log,m.action_history,m.wave_history,m._wave_record,str(m.rng.state)])
func single_boss(hp: int) -> RefCounted:
	# Vague isolée de contrôle, jamais substituée à la campagne jouable.
	var m = Model.new(); m.wave = 10; m.fortress_hp = hp; m.max_hp = hp
	m.spawn_schedule.assign([{"time":0.0,"type":7}])
	m.start(); return m
func run_checks() -> void:
	var m = Model.new()
	check(Report.boss_encounter(m).status == "not_reached","Aucun boss inventé avant la vague 10")
	m.start(); m.advance(1000); m.prepare_next_wave(); m.start(); m.advance(1000)
	check(m.phase == "defeat" and Report.boss_description(Report.boss_encounter(m)).contains("n’a pas été atteinte"),"Défaite précoce décrite sans rencontre")
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene._prepare_campaign_capture("summary")
		m = scene.model
		var before: String = fingerprint(m)
		var boss: Dictionary = Report.boss_encounter(m)
		check(boss.status == "killed" and boss.max_hp == 600 and absf(boss.removed_hp-600.0)<0.000001 and boss.remaining_hp<0.000001,"Boss éliminé : 600 PV observés pour chaque faction")
		check(boss.resolved_seconds>0 and boss.resolved_seconds<=m.elapsed and absf(boss.duration_seconds-(boss.resolved_seconds-boss.spawn_seconds))<0.000001,"Temps mesuré depuis l’apparition et le début de vague")
		var report: Dictionary = Report.build(m)
		check(Report.markdown(report).contains("## Boss final") and Report.markdown(report).contains("Boss final éliminé"),"Résultat du boss lisible dans le rapport Markdown")
		scene._update_interface(); scene._show_run_summary()
		check(scene.summary_rows[9].tooltip_text.contains("Boss final éliminé") and not scene.summary_rows[0].tooltip_text.contains("Boss final"),"Détail réservé à la vague du boss dans le bilan")
		check(fingerprint(m) == before,"Consultation sans tirage, or, dégâts ou mutation de la simulation")
		check(Replay.verify(JSON.parse_string(JSON.stringify(report))).ok,"Le rejeu vérifie aussi le nouveau relevé du boss")
		var altered: Dictionary = report.duplicate(true); altered.boss_encounter.resolved_seconds += 1
		check(not Replay.verify(altered).ok,"Un temps de boss altéré est détecté")
		var legacy: Dictionary = JSON.parse_string(JSON.stringify(report)); legacy.erase("boss_encounter")
		check(Replay.verify(legacy).ok,"Les rapports historiques de format 2 sans détail de boss restent lisibles")
		scene.free()
	m = single_boss(20); m.advance(1)
	var present: Dictionary = Report.boss_encounter(m)
	check(present.status == "present" and present.phase == "combat" and present.remaining_hp == 600 and Report.boss_description(present).contains("actuellement"),"Boss vivant en combat : état courant correctement décrit")
	m.advance(1000)
	var escaped: Dictionary = Report.boss_encounter(m)
	check(m.phase == "defeat" and escaped.status == "escaped" and escaped.remaining_hp == 600 and escaped.removed_hp == 0,"Arrivée fatale distincte d’une élimination")
	check(Report.boss_description(escaped).contains("atteint la forteresse") and escaped.resolved_seconds>0,"Arrivée accompagnée de son temps simulé")
	m = single_boss(24); m.advance(1000)
	check(m.phase == "victory" and Report.boss_encounter(m).status == "escaped","Une victoire ne suffit pas à conclure que le boss est éliminé")
	m = Model.new(); m.wave = 10; m.fortress_hp = 1
	m.spawn_schedule.assign([{"time":0.0,"type":0},{"time":1000.0,"type":7}]); m.start(); m.advance(1000)
	check(m.phase == "defeat" and Report.boss_encounter(m).status == "not_spawned","Boss prévu mais pas apparu distingué de la non-rencontre")
	m = Model.new(); m.wave = 10; m.fortress_hp = 1; m.spawn_schedule = Model.Campaign.schedule(10); m.start(); m.advance(1000)
	var alive: Dictionary = Report.boss_encounter(m)
	check(m.phase == "defeat" and alive.status == "present" and alive.remaining_hp>0 and Report.boss_description(alive).contains("fin de la partie"),"Défaite pendant que le boss est encore en chemin")
	# L’identifiant découle du programme d’apparition ; il n’est pas toujours zéro.
	m = Model.new(); m.wave = 10; m.gold = 10000
	m.spawn_schedule.assign([{"time":0.0,"type":0},{"time":1.0,"type":7}])
	for slot in range(6):
		m.buy(slot,slot%3)
		for branch in [-1,-1,0]:m.upgrade(slot,branch)
	m.start(); m.advance(1000)
	var offset: Dictionary = Report.boss_encounter(m)
	check(offset.id == 1 and offset.status == "killed" and offset.spawn_seconds == 1.0 and absf(offset.removed_hp-600)<0.000001,"Boss à l’identifiant non nul correctement suivi")
	m.event_log.clear()
	check(Report.boss_encounter(m).status == "unknown","Journal incomplet : aucune issue ou durée inventée")
	print("BOSS_REPORT_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
