extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const POSITIONS: Array = [[1,2,4],[1,3,4],[1,2,4]]
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
static func play(model: RefCounted, positions: Array, step: float = 300.0) -> void:
	model.rng.seed = 42
	var types: Array = [0,2,1] if model.faction == 1 and model.enemy_hp_percent > 100 else [0,1,2]
	model.buy(positions[0],model.faction*3+types[0]);model.buy(positions[1],model.faction*3+types[1])
	for wave in range(1,11):
		if wave == 2 and model.faction == 1: model.upgrade(positions[0])
		if wave >= 4 and model.defenders[positions[2]].is_empty(): model.buy(positions[2],model.faction*3+types[2])
		if wave >= 5:
			for slot in positions:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
		model.start()
		while model.active: model.advance(step)
		if model.phase == "defeat": return
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 10: model.prepare_next_wave()
func run_checks() -> void:
	for percent in [100,101,102]:
		for type in range(8):
			for faction in range(2):
				var base: Dictionary = Model.make_enemy(0,type,0,faction)
				var scaled: Dictionary = Model.make_enemy(0,type,0,faction,percent)
				check(is_equal_approx(scaled.hp,base.hp*percent/100.0) and scaled.hp == scaled.max_hp,"Les PV initiaux et maximum appliquent exactement le pourcentage demandé")
				for key in ["speed","reward","fortress_damage","identity_id","origin"]: check(scaled[key] == base[key],"Vitesse, gains, dégâts à la forteresse et identité de faction inchangés")
	var m = Model.new()
	for invalid in [0,99,150,100.5,true,"101",null,INF]: check(not m.configure_enemy_hp(invalid) and m.enemy_hp_percent == 100,"Réglage absent, non entier ou hors de l’échantillon refusé sans effet")
	check(m.configure_enemy_hp(101) and m.select_faction(0) and not m.configure_enemy_hp(102),"Le pourcentage est configuré avant le départ puis figé")
	m.start();m.advance(0)
	check(not m.enemies.is_empty() and m.enemies[0].max_hp == Model.scaled_enemy_hp(m.enemies[0].type,101),"Le moteur applique les PV réglés aux apparitions réelles")
	m.reset();check(m.enemy_hp_percent == 101,"Réessayer sur le même modèle conserve ses règles de mission")
	var inspected = Main.new();inspected.model = Model.new(true,Model.Maps.for_id("ford_woods"));inspected.model.configure_enemy_hp(101)
	root.add_child(inspected);inspected.set_process(false);inspected._choose_faction(1);inspected._update_interface()
	check(inspected.forecast_details[0].text.contains("40,4 PV"),"L’aperçu de vague indique les PV augmentés avec leurs décimales")
	inspected.model.start();inspected.model.advance(0)
	check(inspected._enemy_health_text(inspected.model.enemies[0]) == "PV : 40,4 / 40,4","L’inspection utilise les mêmes PV que l’aperçu et le combat")
	inspected.free()
	for faction in range(2):
		for number in range(1,4):
			var entry: Dictionary = Catalogue.definition(number)
			var definition: Dictionary = Model.Maps.for_id(entry.map_id)
			check(entry.available and entry.hp_percent == 99+number and entry.waves == 10 and Model.Maps.validation_error(definition).is_empty(),"Trois missions de dix vagues avec cartes valides et PV à 100/101/102 pour cent")
			for slot in definition.slots: check(not Main.MapView.fortress_bounds(Main.MapView.project(definition.path_points[-1])).has_point(Main.MapView.project(slot)),"Aucun emplacement n’est caché sous la forteresse")
			var reports: Array = []
			for step in [0.05,300.0]:
				m = Model.new(true,definition);m.configure_enemy_hp(entry.hp_percent);m.select_faction(faction)
				play(m,POSITIONS[number-1],step)
				check(m.phase == "victory","Stratégie de contrôle sans talent : faction %d, mission %d, pas %s, résultat %s, vague %d" % [faction,number,str(step),m.phase,m.wave])
				var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
				var replay: Dictionary = Replay.verify(report)
				check(replay.ok,"Le rapport de chaque nouvelle mission se rejoue avec sa géométrie et son pourcentage de PV : "+replay.get("error",""))
				check(report.boss_encounter.get("max_hp",-1) == Model.scaled_enemy_hp(7,entry.hp_percent),"Le bilan du boss utilise ses vrais PV de mission")
				check(report.has("enemy_hp_percent") == (number != 1) and report.has("map_definition") == (number != 1),"Le format historique du Gué est conservé et les autres rapports portent leurs règles")
				reports.append(report)
			check(Replay._difference(reports[0],reports[1],"rapport").is_empty(),"La simulation produit le même rapport à petits et grands pas")
			if number > 1:
				var bad: Dictionary = reports[0].duplicate(true);bad.enemy_hp_percent = 100
				check(not Replay.verify(bad).ok,"Un rapport dont le pourcentage a été falsifié est rejeté")
				bad.enemy_hp_percent = 150;check(not Replay.verify(bad).ok,"Un rapport ne peut pas imposer une difficulté non prise en charge")
				bad.erase("enemy_hp_percent");check(not Replay.verify(bad).ok,"Supprimer les règles de PV du rapport ne permet pas un rejeu incohérent")
		var scene = Main.new();root.add_child(scene);scene.set_process(false)
		var p = Profile.new("");scene.meta_profile = p;scene._open_campaign(faction)
		var other: String = JSON.stringify(p.data.banks[1-faction])
		for number in range(1,4):
			var menu = scene.campaign_menu
			menu._select(number-1)
			check(not menu.start_button.disabled and menu.rewards.text.contains("100 XP"),"La prochaine mission affiche ses gains de prototype et se débloque dans le bon camp")
			if number < 3:
				var before: String = JSON.stringify(p.data)
				scene._launch_campaign_mission(Catalogue.id_for(number+1))
				check(scene.choosing_faction and JSON.stringify(p.data) == before,"Lancer directement la mission suivante avant le succès requis reste impossible")
			if number == 2:
				menu._launch()
				while scene.model.phase not in ["victory","defeat"]:
					scene.model.start();scene.model.advance(300)
					if scene.model.phase == "bonus": scene.model.choose_bonus(scene.model.bonus_offer[0])
					if scene.model.phase == "finished": scene.model.prepare_next_wave()
				scene._sync_meta_rewards(true);scene._update_interface();scene._show_run_summary()
				check(scene.model.phase == "defeat" and p.data.banks[faction].xp == 100 and p.data.banks[faction].resource == 60 and p.campaign_status(faction).completed == 1,"Perdre la deuxième mission ne retire pas la première récompense et ne donne aucun nouveau gain")
				check(not Catalogue.unlocked(3,p.campaign_status(faction)),"Une défaite ne débloque pas la mission suivante")
				check(Replay.verify(JSON.parse_string(JSON.stringify(Report.build(scene.model)))).ok,"Le rapport de défaite conserve la géométrie et les PV réglés et se rejoue correctement")
				scene._summary_to_campaign();menu._select(number-1)
				check(menu.visible and not menu.start_button.disabled,"Après la défaite, la mission reste accessible pour une nouvelle tentative")
			menu._launch()
			check(not scene.choosing_faction and scene.model.map_definition.id == Catalogue.definition(number).map_id and scene.model.enemy_hp_percent == 99+number,"Le parcours lance la bonne géométrie et le bon réglage")
			check(scene.map_view.model == scene.model and scene.map_caption.text == scene.model.map_definition.title.to_upper() and root.title.contains(scene.model.map_definition.title),"Carte dessinée, titre de fenêtre et en-tête suivent la mission sélectionnée")
			check(scene.model.gold == 150 and scene.model.fortress_hp == scene.model.max_hp and scene.model.bonuses.is_empty() and scene.model.defenders.all(func(unit): return unit.is_empty()),"Chaque mission de la série repart à neuf")
			if number == 3: check(scene.model.meta_ranks[0] == 1,"Le talent acquis après la seconde victoire est actif au départ de la troisième mission")
			play(scene.model,POSITIONS[number-1]);scene._sync_meta_rewards(true);scene._update_interface();scene._show_run_summary()
			check(scene.model.phase == "victory" and p.data.banks[faction].xp == 100*number and p.data.banks[faction].resource == 60*number,"Les premières victoires successives versent PO et XP une seule fois")
			scene._summary_to_campaign()
			check(scene.campaign_menu.visible and scene.campaign_menu.status.completed == number and JSON.stringify(p.data.banks[1-faction]) == other,"Retour au parcours et réussites indépendantes pour l’autre faction")
			if number == 2:
				check(p.data.banks[faction].points == 1 and p.allocate(faction,0),"La seconde première victoire débloque réellement le premier point de talent à placer")

		scene.campaign_menu._select(0);scene.campaign_menu._launch();play(scene.model,POSITIONS[0]);scene._sync_meta_rewards(true)
		check(scene.model.enemy_hp_percent == 100 and scene.model.map_definition.id == "valley_ford","Revenir au Gué restaure exactement ses PV de référence après les missions plus difficiles")
		check(p.data.banks[faction].xp == 300 and p.data.banks[faction].resource == 180 and p.data.banks[faction].points == 1,"Le rejeu après la série ne permet pas de farmer PO, XP ou points")
		scene.free()
	print("CAMPAIGN_SAMPLE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
