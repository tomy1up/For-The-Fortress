extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = Model.MetaTalents
const Expanded = Talents.Expanded
const Fixture = preload("res://tests/test_expanded_talents.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func campaign(faction: int, ranks: Array) -> RefCounted:
	var model = Model.new();model.meta_ranks = ranks.duplicate();model.rng.seed = 42;model.select_faction(faction)
	model.buy(0,faction*3);model.buy(1,faction*3+1)
	for wave in range(1,11):
		if wave >= 4 and model.defenders[2].is_empty(): model.buy(2,faction*3+2)
		if wave >= 5:
			for slot in [0,1,2]:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
		model.start();model.advance(10000)
		if model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 10: model.prepare_next_wave()
	return model
func run_checks() -> void:
	check(Profile.fresh().schema == 7 and Profile.bank().ranks.size() == 63,"Nouveaux profils au format enrichi")
	check(Talents.MAX_POINTS == Expanded.MAX_POINTS,"Plafond unique cohérent avec le prototype d’arbres enrichis")
	for faction in range(2):
		var old: Array = [5,3,2,1,0,5,3,2,1,0,5,3,2,1,0]
		var first = campaign(faction,old);var migrated = campaign(faction,Expanded.normalize(old))
		var baseline: Dictionary = Report.build(first);var observed: Dictionary = Report.build(migrated)
		baseline.erase("meta_ranks");observed.erase("meta_ranks")
		check(baseline == observed and first.rng.state == migrated.rng.state and first.event_log == migrated.event_log,"Configuration migrée : rapports, aléas et combats historiques identiques")
		for tree in range(3):
			for ending in [18,19,20]:
				var ranks: Array = Fixture.deep_build(tree,ending)
				var model = campaign(faction,ranks)
				var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
				check(model.phase in ["victory","defeat"] and report.meta_ranks.size() == 63,"Configuration profonde jouée par le modèle réel jusqu’au résultat")
				check(Replay.verify(report).ok,"Rejeu du rapport enrichi, sans profil utilisateur")
				check(Report.markdown(report).contains("arbres enrichis"),"Format des talents explicite dans le rapport Markdown")
				print("EXPANDED_COMBAT=",JSON.stringify({"faction":faction,"tree":tree,"ending":ending,"result":model.phase,"hp":model.fortress_hp,"max_hp":model.max_hp,"gold":model.gold}))
		var path: String = ProjectSettings.globalize_path("user://test_expanded_migration_%d_%d.json" % [Time.get_ticks_usec(),faction])
		assert(not FileAccess.file_exists(path))
		var legacy: Dictionary = {"schema":3,"serial":1,"banks":[],"run":{"id":1,"faction":faction,"completed":10,"victory":true,"settled":true,"previous_maps":0,"mission_id":"test.old","mission_reward":17,"mission_waves":10,"mission_earned":17}}
		for camp in range(2): legacy.banks.append({"resource":200+camp,"points":36,"resets":20+camp,"ranks":old.duplicate(),"mission_rewards":{}})
		legacy.banks[faction].mission_rewards["test.old"] = {"reward":17,"run_id":1}
		var file := FileAccess.open(path,FileAccess.WRITE);file.store_buffer(Profile.Codec.encode(legacy));file.close()
		var p = Profile.new(path)
		check(not p.blocked and p.data.schema == 7 and p.data.run == JSON.parse_string(JSON.stringify(legacy.run)),"Migration schéma 3 : reçu de tentative intact")
		for camp in range(2):
			check(p.data.banks[camp].resource == legacy.banks[camp].resource and p.data.banks[camp].points == 36 and p.data.banks[camp].resets == legacy.banks[camp].resets and p.data.banks[camp].mission_rewards == JSON.parse_string(JSON.stringify(legacy.banks[camp].mission_rewards)),"Soldes, points, compteurs et missions récompensées conservés")
			check(p.data.banks[camp].ranks == Expanded.normalize(JSON.parse_string(JSON.stringify(old))),"Investissements historiques conservés aux bons emplacements")
		check(p._read(path+".v084.bak") == JSON.parse_string(JSON.stringify(legacy)),"Archive chiffrée de la configuration précédente")
		Profile.Codec.cache.clear();p = Profile.new(path)
		check(not p.blocked and p.migration_notice.is_empty() and p.data.banks[faction].ranks.size() == 63,"Relancement sans seconde migration")
		var id: int = p.begin_mission(faction,"test.old",999)
		check(p.credit_mission(id,faction,10,true) and p.data.banks[faction].resource == legacy.banks[faction].resource,"Une ancienne première victoire n’est pas payée à nouveau après migration")
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = p;scene._open_meta(faction)
		var ui = scene.meta_menu
		check(ui.nodes.size() == 63 and ui.scrollers.size() == 3 and ui.tier_labels.size() == 21,"Interface enrichie raccordée aux profils réels")
		await process_frame;await process_frame
		var before: String = JSON.stringify(p.data)
		for tree in range(3):
			var index: int = Expanded.index_for(tree,18)
			ui.nodes[index].grab_focus();await process_frame;await process_frame
			check(ui.scrollers[tree].scroll_vertical == 0 and ui.scrollers[tree].get_global_rect().encloses(ui.nodes[index].get_global_rect()),"Spécialité profonde accessible et visible au clavier par défilement")
			check(ui.detail_title.text.contains(Expanded.node(faction,index).name),"Lecture du talent profond sélectionné")
			var font: Font = ui.detail_title.get_theme_font("font")
			check(font.get_string_size(ui.detail_title.text,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x <= ui.detail_title.size.x,"Titre de spécialité et état lisibles")
		check(before == JSON.stringify(p.data),"Lire les sept lignes n’investit ni ne dépense rien")
		ui._request_reset();ui.confirm.confirmed.emit()
		check(p.data.banks[faction].resource == legacy.banks[faction].resource and p.data.banks[faction].ranks == Expanded.empty_ranks(),"Reset gratuit des 63 talents sans perte de PO")
		check(p.allocate(faction,Expanded.index_for(0,5)),"Nouveau talent achetable depuis le service persistant")
		Profile.Codec.cache.clear();var reopened = Profile.new(path)
		check(reopened.data.banks[faction].ranks[Expanded.index_for(0,5)] == 1,"Nouveau talent retrouvé après réouverture du profil")
		ui.close();scene._choose_faction(faction)
		check(scene.model.meta_ranks.size() == 63 and JSON.parse_string(JSON.stringify(scene.model.meta_ranks)) == reopened.data.banks[faction].ranks,"Configuration enrichie copiée au départ de la partie")
		scene.model.meta_ranks = Fixture.deep_build(0)
		scene._populate_loadout_summary()
		var summary: Dictionary = Expanded.loadout_summary(faction,scene.model.meta_ranks)
		for tree in range(3):
			for index in range(summary.trees[tree].nodes.size()):
				var label: Label = scene.summary_loadout_nodes[tree*4+index] if index < 4 else scene.summary_loadout_extra[tree*17+index-4]
				check(label.visible and label.text.contains(summary.trees[tree].nodes[index].name),"Bilan : tous les talents actifs sont présents, au-delà des quatre premiers")
		check(scene.summary_loadout_lists[0].custom_minimum_size.y > scene.summary_loadout_scrollers[0].size.y,"Bilan des talents profonds consultable par défilement")
		scene.free()
		for suffix in ["",".bak",".tmp",".v084.bak"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("EXPANDED_INTEGRATION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
