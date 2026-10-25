extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func make_report(faction: int, victory: bool) -> Dictionary:
	var m = Model.new(); m.select_faction(faction); m.rng.seed = 42
	if victory:
		m.buy(0,faction*3); m.buy(1,faction*3+1)
	else:
		# Vente et nouvel exemplaire dans un relevé normal, sans budget ajouté.
		m.buy(0,faction*3); m.sell(0); m.buy(0,faction*3); m.sell(0)
	for wave in range(1,11):
		if victory and wave >= 4 and m.defenders[2].is_empty(): m.buy(2,faction*3+2)
		if victory and wave >= 5:
			for slot in [0,1,2]: m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		m.start(); m.advance(1000)
		if m.phase in ["victory","defeat"]: break
		if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
		m.prepare_next_wave()
	return JSON.parse_string(JSON.stringify(Report.build(m)))
func rejected(report: Variant, message: String) -> void:
	var result: Dictionary = Replay.verify(report)
	check(not result.ok and not result.error.is_empty(),message)
func run_checks() -> void:
	for faction in range(2):
		for victory in [false,true]:
			var report: Dictionary = make_report(faction,victory)
			var before: String = JSON.stringify(report)
			var result: Dictionary = Replay.verify(report)
			check(result.ok,"Rapport JSON rejoué : faction %d, victoire %s" % [faction,victory])
			if result.ok:
				check(result.faction == faction and result.result == ("victory" if victory else "defeat") and result.gold == int(report.gold) and result.fortress_hp == int(report.fortress_hp),"Rejeu des décisions, ventes, branches, bonus et résultats concordants")
			check(JSON.stringify(report) == before,"Rejeu sans modification du rapport fourni")
	var valid: Dictionary = make_report(0,true)
	for field in ["gold","fortress_hp","total_income","total_killed","combat_seconds"]:
		var changed: Dictionary = valid.duplicate(true); changed[field] += 1
		rejected(changed,"Résultat altéré détecté : "+field)
	var changed: Dictionary = valid.duplicate(true); changed.waves[0].income += 1
	rejected(changed,"Relevé de vague altéré détecté")
	changed = valid.duplicate(true); changed.performance[0].boss_hp += 1
	rejected(changed,"Contributions altérées détectées")
	changed = valid.duplicate(true)
	for action in changed.actions:
		if action.kind == "bonus_offer": action.offered.reverse(); break
	rejected(changed,"Offre automatique altérée détectée, pas seulement le choix final")
	changed = valid.duplicate(true)
	for action in changed.actions:
		if action.kind == "buy": action.type = 3; break
	rejected(changed,"Achat adverse refusé avant toute application")
	changed = valid.duplicate(true); changed.actions[1].slot = "zero"
	rejected(changed,"Champ d’action mal typé rejeté sans erreur moteur")
	changed = valid.duplicate(true); changed.actions[0].kind = "execute"
	rejected(changed,"Aucune commande arbitraire reconnue")
	changed = valid.duplicate(true); changed.erase("waves")
	rejected(changed,"Rapport incomplet refusé")
	for invalid in [null,[],{}, {"schema_version":1}, {"schema_version":2,"result":"combat"}]:
		rejected(invalid,"Entrée non compatible refusée")
	for invalid in ["", "x", "01", "9223372036854775808", 42]:
		changed = valid.duplicate(true); changed.initial_rng_state = invalid
		rejected(changed,"État aléatoire invalide rejeté sans conversion silencieuse")
	changed = valid.duplicate(true); changed.actions = []
	rejected(changed,"Journal vide refusé")
	changed = valid.duplicate(true); changed.actions.resize(Replay.MAX_ACTIONS+1)
	rejected(changed,"Journal excessif refusé")
	changed = valid.duplicate(true); changed.game_version = "ancienne-version"
	var cross_version: Dictionary = Replay.verify(changed)
	check(cross_version.ok and not cross_version.same_version and cross_version.source_version == "ancienne-version","Concordance interversion signalée sans prétendre utiliser l’ancien programme")
	# Entiers aléatoires signés 64 bits conservés comme texte, y compris au-delà de 2^53.
	var m = Model.new(); m.select_faction(1); m.rng.seed = 9223372036854775000
	m.start(); m.advance(1000); m.prepare_next_wave(); m.start(); m.advance(1000)
	check(Replay.verify(JSON.parse_string(JSON.stringify(Report.build(m)))).ok,"Rejeu conserve la graine 64 bits sans passage par un nombre JSON")
	var path: String = "user://test_replay_%d.json" % Time.get_ticks_usec()
	var file := FileAccess.open(path,FileAccess.WRITE); file.store_string(JSON.stringify(valid)); file.close()
	var content: String = FileAccess.get_file_as_string(path)
	check(Replay.load_and_verify(path).ok and FileAccess.get_file_as_string(path) == content,"Lecture du fichier sans réécriture")
	file = FileAccess.open(path,FileAccess.WRITE); file.store_string("{ invalid"); file.close()
	check(not Replay.load_and_verify(path).ok,"JSON invalide remonté sans crash")
	file = FileAccess.open(path,FileAccess.WRITE); file.seek(Replay.MAX_BYTES); file.store_8(0); file.close()
	check(not Replay.load_and_verify(path).ok,"Fichier trop volumineux rejeté avant lecture")
	DirAccess.remove_absolute(path)
	check(not Replay.load_and_verify(path).ok,"Fichier absent signalé sans erreur moteur")
	print("REPORT_REPLAY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
