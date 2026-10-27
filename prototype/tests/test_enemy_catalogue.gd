extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/enemy_catalogue.gd")
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
const Art = preload("res://scripts/enemy_art.gd")
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
func campaign(faction: int, seed: int = 42, prefer_robust: bool = false) -> RefCounted:
	var m = Model.new();m.select_faction(faction);m.rng.seed = seed
	m.buy(0,faction*3);m.buy(1,faction*3+1)
	for wave in range(1,11):
		if wave >= 4 and m.defenders[2].is_empty(): m.buy(2,faction*3+2)
		if wave >= 5:
			for slot in [0,1,2]: m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		m.start();m.advance(1000)
		if m.phase in ["victory","defeat"]: break
		if m.phase == "bonus": m.choose_bonus(11 if prefer_robust and 11 in m.bonus_offer else m.bonus_offer[0])
		m.prepare_next_wave()
	return m
func run_checks() -> void:
	var all_ids: Dictionary = {}
	for faction in [0,1]:
		var catalogue: Array[Dictionary] = Catalogue.available(faction)
		check(catalogue.size() == 8,"Huit profils accessibles dans chaque campagne")
		var neutrals: int = 0
		for identity in catalogue:
			all_ids[identity.id] = true
			check(identity.origin == "neutral" or identity.origin == ("horde" if faction == 0 else "alliance"),"Aucun attaquant de sa propre faction")
			check(Catalogue.by_id(identity.id,faction) == identity and Art.TEXTURES.has(identity.id),"Identité autorisée avec son propre visuel")
			if identity.origin == "neutral":
				neutrals += 1
				check(Catalogue.by_id(identity.id,1-faction) == identity,"Neutres identiques dans les deux campagnes")
			else: check(Catalogue.by_id(identity.id,1-faction).is_empty(),"Rejet d’un attaquant spécifique dans le mauvais catalogue")
			for defender in Model.ROSTER: check(identity.name != defender.name,"Attaquants distincts des défenseurs construits")
			var enemy: Dictionary = Model.make_enemy(0,identity.profile,0.0,faction)
			check(enemy.identity_id == identity.id and enemy.name == identity.name and enemy.origin == identity.origin,"L’apparition lie identifiant, nom et origine")
			var stats: Dictionary = Model.ENEMY_TYPES[identity.profile]
			check(enemy.hp == stats.hp and enemy.speed == stats.speed and enemy.fortress_damage == stats.fortress_damage and enemy.reward == stats.reward,"Identité sans modification des caractéristiques")
		check(neutrals == 3,"Trois neutres et cinq attaquants adverses")
		for number in range(1,11):
			var m = Model.new();m.select_faction(faction);m.wave = number;m.spawn_schedule = Model.Campaign.schedule(number);m.fortress_hp = 10000;m.start()
			var forecast: Dictionary = Model.wave_forecast(number,faction)
			for entry in m.spawn_schedule:
				m.elapsed = entry.time;m._resolve_instant()
				var enemy: Dictionary = m.enemies[-1]
				var identity: Dictionary = Catalogue.for_profile(entry.type,faction)
				check(enemy.identity_id == identity.id and enemy.origin == identity.origin,"Vraies apparitions des dix vagues limitées au bon camp")
			for group in forecast.groups:
				var identity: Dictionary = Catalogue.for_profile(group.type,faction)
				check(group.name == identity.name and group.identity_id == identity.id and group.origin == identity.origin,"Prévisions cohérentes avec les apparitions")
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		check(scene.forecast_names[0].text.contains(Catalogue.for_profile(1,faction).name),"La première vague affiche l’infanterie adverse")
		for type in range(8):
			var enemy: Dictionary = Model.make_enemy(type,type,0.0,faction);enemy.distance = 10.0
			scene.model.phase = "combat";scene.model.enemies.assign([enemy])
			scene.inspection_pointer = View.enemy_bounds(enemy,faction).get_center();scene._update_interface()
			check(scene.enemy_name.text.contains(Catalogue.for_profile(type,faction).name),"Inspection avec l’identité effective, y compris la faune")
			check(scene.enemy_status.text.begins_with(Catalogue.origin_label(Catalogue.for_profile(type,faction).origin)+" · "),"Origine visible dans la ligne d’état existante")
			check(View.enemy_art_id(enemy,faction) == enemy.identity_id,"Nom et texture désignent le même attaquant")
		var text: String = scene._bonus_impact_text(11)
		# Ouvrir un aperçu réel plutôt qu’une offre déjà acquise.
		scene.model.bonuses.clear();scene.model.gold = 1000;scene.model.enemies.clear();scene.model.phase = "preparation";scene.model.buy(0,faction*3)
		text = scene._bonus_impact_text(11)
		for profile in [3,5,6,7]:check(text.contains(Catalogue.for_profile(profile,faction).name),"R-12 détaille les quatre cibles de la campagne")
		scene.queue_free();await process_frame
		var m = campaign(faction)
		check(m.phase == "victory","Campagne de référence gagnable au budget normal, sans nouveau réglage")
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
		check(report.enemy_catalog == JSON.parse_string(JSON.stringify(Catalogue.available(faction))) and report.boss_encounter.name == Catalogue.for_profile(7,faction).name,"Rapport et boss reflètent le bon camp")
		check(Report.markdown(report).contains("Catalogue des attaquants") and Replay.verify(report).ok,"Catalogue exporté et vérifié au rejeu")
		var altered: Dictionary = report.duplicate(true);altered.enemy_catalog[1].origin = "alliance" if faction == 0 else "horde"
		check(not Replay.verify(altered).ok,"Rejeu : détecter une origine falsifiée")
		var legacy: Dictionary = report.duplicate(true);legacy.erase("enemy_catalog");legacy.game_version = "0.64";legacy.boss_encounter.name = Model.ENEMY_TYPES[7].name
		for bonus in legacy.bonuses:bonus.description = bonus.description.replace("ours, unités lourdes, gardes d’élite et boss","Brutes, Colosses, Élites et boss")
		check(Replay.verify(legacy).ok,"Rapport historique avec anciens noms de profils toujours vérifiable")
		var robust = campaign(faction,0,true)
		for seed in range(1,32):
			if 11 in robust.bonuses: break
			robust = campaign(faction,seed,true)
		check(11 in robust.bonuses,"Contrôle de migration avec un R-12 réellement proposé et acquis")
		var old_bonus_report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(robust)))
		old_bonus_report.erase("enemy_catalog");old_bonus_report.game_version = "0.64";old_bonus_report.boss_encounter.name = Model.ENEMY_TYPES[7].name
		for bonus in old_bonus_report.bonuses:bonus.description = bonus.description.replace("ours, unités lourdes, gardes d’élite et boss","Brutes, Colosses, Élites et boss")
		check(Replay.verify(old_bonus_report).ok,"R-12 historique : ancien libellé reconnu sans accepter un bonus non joué")
	check(all_ids.size() == 13,"Treize identités totales, sans doublons entre les camps")
	check(Catalogue.available(-1).is_empty() and Catalogue.available(2).is_empty() and Catalogue.for_profile(8,0).is_empty() and Catalogue.by_id("defender.archer",0).is_empty(),"Catalogue fermé aux factions, profils et identifiants invalides")
	print("ENEMY_CATALOGUE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
