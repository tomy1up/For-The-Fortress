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
	for faction in range(2):
		var game := Main.new()
		root.add_child(game)
		game.set_process(false)
		var path := "user://test_slate_campaign_%d_%d.json" % [Time.get_ticks_usec(),faction]
		var profile := Profile.new(path)
		game.meta_profile = profile
		game._open_campaign(faction,3)
		game.campaign_menu._launch()
		check(game.choosing_faction,"Mission 21 verrouillée avant la mission 20")
		for number in range(1,21):
			var id: int = profile.begin_mission(faction,Main.CampaignCatalogue.id_for(number),60,10,100)
			check(id>0 and profile.credit_mission(id,faction,10,true),"Première victoire préalable créditée par le service")
		for index in [0,0,0,0,0,1]:
			check(profile.allocate(faction,index),"Six rangs achetés avec les points gagnés avant la mission 21")
		game._open_campaign(faction,3)
		game.campaign_menu._launch()
		var model = game.model
		check(not game.choosing_faction and game.mission_definition.id=="campaign.021" and model.routes.size()==2,"La mission 21 démarre par le parcours normal")
		check(model.enemy_hp_percent==120 and model.gold==150 and model.fortress_hp==model.max_hp and model.bonuses.is_empty(),"Paramètres et remise à neuf avec les talents actifs")
		model.rng.seed = 7
		var slots: Array = [1,3,4]
		check(model.buy(slots[0],faction*3) and model.buy(slots[1],faction*3+1),"Recrutement initial dans le budget")
		for wave in range(1,11):
			if wave==1: model.upgrade(slots[0])
			if wave>=2 and model.defenders[slots[2]].is_empty(): model.buy(slots[2],faction*3+2)
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
		check(profile.campaign_status(faction).completed==21 and profile.data.banks[faction].resource==1260 and profile.data.banks[faction].xp==2100,"Première victoire créditée avec 60 PO et 100 XP")
		game._sync_meta_rewards(true)
		check(profile.data.banks[faction].resource==1260 and profile.campaign_status(1-faction).completed==0,"Crédit unique et parcours adverse indépendant")
		Profile.Codec.cache.clear()
		var reopened := Profile.new(path)
		check(reopened.campaign_status(faction).completed==21 and reopened.data.banks[faction].xp==2100,"Gains et réussite relus après fermeture du profil")
		game.free()
		for suffix in ["",".bak",".tmp"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("SLATE_CAMPAIGN_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
