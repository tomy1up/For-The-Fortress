extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Sample = preload("res://tests/test_campaign_sample.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
static func play(model: RefCounted, step: float = 300.0) -> void:
	model.rng.seed = 42
	var types: Array = [0,2,1] if model.faction == 1 and model.enemy_hp_percent not in [104,107,108] else [0,1,2]
	model.buy(0,model.faction*3+types[0]);model.buy(1,model.faction*3+types[1])
	for wave in range(1,11):
		if wave == 2: model.upgrade(0)
		if wave >= 4 and model.defenders[2].is_empty(): model.buy(2,model.faction*3+types[2])
		if wave >= 5:
			for slot in [0,1,2]:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
		model.start()
		while model.active: model.advance(step)
		if model.phase == "defeat": return
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 10: model.prepare_next_wave()
func run_checks() -> void:
	var ids: Dictionary = {}
	for number in range(1,11):
		var entry: Dictionary = Catalogue.definition(number);var terrain: Dictionary = Model.Maps.for_id(entry.map_id)
		check(entry.available and entry.chapter == 1 and not entry.introduces_rule and entry.hp_percent == 99+number and entry.waves == 10,"Dix missions de prototype, sans nouvelle règle dans ce premier chapitre")
		check(not ids.has(terrain.id) and Model.Maps.validation_error(terrain).is_empty() and terrain.slots.size() == 6,"Chaque mission possède un tracé valide et six emplacements")
		ids[terrain.id] = true
		var original: String = JSON.stringify(terrain)
		for slot in terrain.slots:
			check(not Main.MapView.fortress_bounds(Main.MapView.project(terrain.path_points[-1])).has_point(Main.MapView.project(slot)),"Les six positions restent visibles devant la forteresse réellement dessinée")
			var distance: float = INF
			for segment in range(1,terrain.path_points.size()): distance = minf(distance,slot.distance_to(Geometry2D.get_closest_point_to_segment(slot,terrain.path_points[segment-1],terrain.path_points[segment])))
			check(distance >= (0.75 if number >= 4 else 0.5),"Les nouveaux emplacements sont hors de la route, les anciens terrains restent inchangés")
		check(Model.Maps.from_data(JSON.parse_string(JSON.stringify(Model.Maps.to_data(terrain)))) == terrain,"Le rapport peut transporter exactement la géométrie de chaque mission")
		terrain.slots[0] = Vector2.ZERO
		check(JSON.stringify(Model.Maps.for_id(entry.map_id)) == original,"Modifier une copie ne modifie aucune future partie")
		for type in range(8):
			var base: Dictionary = Model.make_enemy(0,type,0,0)
			var scaled: Dictionary = Model.make_enemy(0,type,0,0,entry.hp_percent)
			check(is_equal_approx(scaled.max_hp,base.hp*entry.hp_percent/100.0),"PV exacts sans arrondi prématuré")
			for key in ["speed","reward","fortress_damage","identity_id"]: check(scaled[key] == base[key],"Le changement de mission ne gonfle ni vitesse, ni récompense, ni dégâts à la forteresse")
	check(not Catalogue.definition(31).available and Catalogue.runtime("campaign.031").is_empty(),"La mission 31 reste à venir, sans contenu annoncé comme jouable")
	for faction in range(2):
		for number in range(4,11):
			var entry: Dictionary = Catalogue.definition(number);var reports: Array = []
			for step in [0.05,300.0]:
				var m = Model.new(true,Model.Maps.for_id(entry.map_id));m.configure_enemy_hp(entry.hp_percent);m.select_faction(faction);play(m,step)
				check(m.phase == "victory","Témoin gagnant sans talent sur la mission %d, faction %d, pas %s" % [number,faction,str(step)])
				var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
				check(Replay.verify(report).ok,"Le combat de chaque nouveau terrain se rejoue avec ses vrais PV et emplacements")
				check(report.boss_encounter.max_hp == Model.scaled_enemy_hp(7,entry.hp_percent),"Le boss porte le réglage exact de sa mission")
				reports.append(report)
			check(Replay._difference(reports[0],reports[1],"rapport").is_empty(),"Petits et grands pas donnent le même combat complet")
		var path: String = "user://test_chapter_one_%d_%d.json" % [faction,Time.get_ticks_usec()]
		var p = Profile.new(path)
		# Ancienne progression réelle à trois missions : aucune migration ni remise à zéro.
		for number in range(1,4):
			var run: int = p.begin_mission(faction,Catalogue.id_for(number),60,10,100)
			check(p.credit_mission(run,faction,10,true),"Préparation des trois anciens reçus avec le service réel")
		check(p.allocate(faction,0),"Le premier point est investi normalement")
		Profile.Codec.cache.clear();p = Profile.new(path)
		check(not p.blocked and p.campaign_status(faction).completed == 3 and Catalogue.suggested_mission(p.campaign_status(faction)) == 4,"Le profil existant retrouve ses gains et propose désormais la quatrième mission")
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = p
		var other: String = JSON.stringify(p.data.banks[1-faction])
		for number in range(4,11):
			scene._open_campaign(faction);var menu = scene.campaign_menu
			check(menu.selected == number-1 and not menu.start_button.disabled,"La mission suivante attend un lancement explicite")
			var expected_points: int = (number-1)*51/100
			check(p.data.banks[faction].points == expected_points,"Seule l’XP des victoires antérieures est utilisable au départ")
			menu._launch()
			check(not scene.choosing_faction and scene.model.map_definition.id == Catalogue.definition(number).map_id and scene.model.enemy_hp_percent == 99+number,"La nouvelle mission lance le bon terrain et ses PV")
			check(scene.model.gold == 150 and scene.model.fortress_hp == scene.model.max_hp and scene.model.defenders.all(func(unit): return unit.is_empty()) and scene.model.bonuses.is_empty(),"Forteresse, défense et économie de combat repartent à neuf")
			check(scene.model.meta_ranks[0] == expected_points,"Les points investis avant la mission sont appliqués")
			scene._capture_sample_combat();scene._show_run_summary()
			check(scene.model.phase == "victory" and p.data.banks[faction].xp == number*100 and p.data.banks[faction].resource == number*60,"La première victoire verse immédiatement 100 XP et 60 PO de prototype")
			scene._sync_meta_rewards(true)
			check(p.data.banks[faction].xp == number*100 and p.data.banks[faction].resource == number*60,"Rafraîchir le bilan ne double aucun gain")
			scene._summary_to_campaign()
			while p.data.banks[faction].ranks[0] < p.data.banks[faction].points: check(p.allocate(faction,0),"Les nouveaux points sont investis seulement entre les missions")
			check(JSON.stringify(p.data.banks[1-faction]) == other,"Aucun talent, gain ou succès ne traverse les factions")
			Profile.Codec.cache.clear();p = Profile.new(path);scene.meta_profile = p
			check(not p.blocked and p.campaign_status(faction).completed == number and p.data.banks[faction].xp == number*100,"Fermer puis relire le profil conserve chaque victoire et son XP")
		check(p.campaign_status(faction).chapters[0] == 10 and not p.campaign_status(faction).infinite_eligible and p.data.banks[faction].points == 5,"Premier chapitre réussi : 600 PO, 1 000 XP, cinq points, infini encore fermé")
		for number in [4,10]:
			var entry: Dictionary = Catalogue.definition(number);var before: String = JSON.stringify(p.data.banks[faction])
			var run: int = p.begin_mission(faction,entry.id,entry.po,entry.waves,entry.xp)
			check(p.credit_mission(run,faction,10,true) and JSON.stringify(p.data.banks[faction]) == before,"Rejouer une mission gagnée ne permet pas de farmer")
		var run: int = p.begin_mission(faction,"campaign.011",60,10,100)
		var before: String = JSON.stringify(p.data.banks[faction])
		check(p.credit_mission(run,faction,5,false) and JSON.stringify(p.data.banks[faction]) == before,"Une défaite ne crée ni gain ni succès supplémentaire")
		scene.free()
		for suffix in ["",".bak",".tmp"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("CHAPTER_ONE_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
