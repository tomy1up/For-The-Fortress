extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	for case in [[0,21],[1,21],[0,22],[1,22],[0,23],[1,23],[0,24],[1,24],[0,25],[1,25],[0,26],[1,26],[0,27],[1,27],[0,28],[1,28],[0,29],[1,29],[0,30],[1,30]]:
		var faction: int = case[0]
		var mission_number: int = case[1]
		var game := Main.new()
		root.add_child(game)
		game.set_process(false)
		var path := "user://test_slate_campaign_%d_%d.json" % [Time.get_ticks_usec(),faction]
		var profile := Profile.new(path)
		game.meta_profile = profile
		game._open_campaign(faction,3)
		game.campaign_menu._select(mission_number-21)
		game.campaign_menu._launch()
		check(game.choosing_faction,"La mission reste verrouillée avant sa précédente")
		for number in range(1,mission_number):
			var id: int = profile.begin_mission(faction,Main.CampaignCatalogue.id_for(number),60,10,100)
			check(id>0 and profile.credit_mission(id,faction,10,true),"Première victoire préalable créditée par le service")
		var available_points: int = profile.data.banks[faction].points
		for index in [0,0,0,0,0,1,1,1,2,2,2,3,5,5].slice(0,available_points):
			check(profile.allocate(faction,index),"Rangs investis avec les points gagnés auparavant")
		game._open_campaign(faction,3)
		game.campaign_menu._select(mission_number-21)
		game.campaign_menu._launch()
		var model = game.model
		var route_count: int = {24:0,26:3,27:0,29:3}.get(mission_number,2)
		check(not game.choosing_faction and game.mission_definition.id==Main.CampaignCatalogue.id_for(mission_number) and model.routes.size()==route_count,"La mission démarre par le parcours normal")
		check(model.enemy_hp_percent==99+mission_number and model.gold==150 and model.fortress_hp==model.max_hp and model.bonuses.is_empty(),"Paramètres et remise à neuf avec les talents actifs")
		model.rng.seed = 7
		var slots: Array = [3,4,2]
		if faction==1 and mission_number in [22,28]:
			slots = [4,3,2]
		if faction==1 and mission_number==23:
			slots = [2,3,4]
		if faction==0 and mission_number==30:
			slots = [2,3,4]
		var types: Array = [faction*3,faction*3+1,faction*3+2]
		if faction==1 and mission_number==25:
			types = [3,5,4]
		if faction==1 and mission_number==30:
			types = [3,3,5]
		check(model.buy(slots[0],types[0]) and model.buy(slots[1],types[1]),"Recrutement initial dans le budget")
		for wave in range(1,11):
			if wave==2: model.upgrade(slots[0])
			if wave>=2 and model.defenders[slots[2]].is_empty(): model.buy(slots[2],types[2])
			if wave>=5:
				for slot in slots:
					if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level==3 else -1)
			check(model.start(),"Vague lancée normalement")
			model.advance(10000)
			if model.phase=="defeat": break
			if model.phase=="bonus": model.choose_bonus(model.bonus_offer[0])
			if wave<10: model.prepare_next_wave()
		check(model.phase=="victory","Une politique gagnante dans chaque faction sans revenu ajouté")
		check(Replay.verify(JSON.parse_string(JSON.stringify(Main.RunReport.build(model)))).ok,"Le combat de campagne multitrajet est rejouable")
		game._sync_meta_rewards(true)
		check(profile.campaign_status(faction).completed==mission_number and profile.data.banks[faction].resource==60*mission_number and profile.data.banks[faction].xp==100*mission_number,"Première victoire créditée avec 60 PO et 100 XP")
		game._sync_meta_rewards(true)
		check(profile.data.banks[faction].resource==60*mission_number and profile.campaign_status(1-faction).completed==0,"Crédit unique et parcours adverse indépendant")
		Profile.Codec.cache.clear()
		var reopened := Profile.new(path)
		check(reopened.campaign_status(faction).completed==mission_number and reopened.data.banks[faction].xp==100*mission_number,"Gains et réussite relus après fermeture du profil")
		game.free()
		for suffix in ["",".bak",".tmp"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("SLATE_CAMPAIGN_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
