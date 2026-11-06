extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var definition: Dictionary = Model.Maps.for_id("marsh_threshold")
	check(Model.Maps.validation_error(definition).is_empty() and definition.decoration=="marsh" and definition.path_length==29,"Première carte des marais valide et de longueur mesurée")
	var serialized: Dictionary = Model.Maps.to_data(definition)
	check(Model.Maps.from_data(JSON.parse_string(JSON.stringify(serialized)))==definition,"La nouvelle décoration survit à la sérialisation des cartes et des rapports")
	for pool in View.MarshArt.POOLS:
		check(Rect2(Vector2.ZERO,Vector2(definition.size)).encloses(pool),"Les bassins restent dans les limites du plateau")
		for slot in definition.slots: check(not pool.has_point(slot),"Les emplacements de défense restent sur la terre ferme")
		for index in range(1,definition.path_points.size()): check(not View._segment_in_rect(definition.path_points[index-1],definition.path_points[index],pool),"Le chemin de combat reste distinct des bassins décoratifs")
	var model := Model.new(true,definition)
	model.rng.seed = 7
	var view := View.new();view.model = model;root.add_child(view)
	var before: String = JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders])
	await process_frame;await process_frame
	check(JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders])==before,"Dessiner les marais ne modifie ni combat, économie, historique ni générateur")
	var scenery: Array = view.terrain_details
	var kinds := {}
	for item in scenery:
		kinds[item.kind] = true
		var area: Rect2 = View.scenery_bounds(item)
		for slot in definition.slots: check(not area.intersects(Rect2(View.project(slot)+Vector2(-44,-78),Vector2(88,110))),"Les ruines et la végétation dégagent les silhouettes de défense")
		for index in range(1,definition.path_points.size()): check(not View._segment_in_rect(View.project(definition.path_points[index-1]),View.project(definition.path_points[index]),area.grow(20)),"Le décor ne masque pas les attaquants sur le chemin")
	check(scenery.size()>0 and kinds.has("ruin") and kinds.has("reeds"),"Le terrain affiche des ruines et des roseaux")
	check(scenery==View.scenery_for(definition),"Décor déterministe et indépendant du combat")
	print("MARSH_SCENERY=",JSON.stringify({"count":scenery.size(),"kinds":kinds.keys()}))
	view.model = Model.new()
	check(view.terrain_details.is_empty(),"Revenir au Gué efface le décor des marais")
	view.free()
	for camp in range(2):
		var game := Main.new();root.add_child(game);game.set_process(false)
		var profile := Profile.new("");game.meta_profile = profile
		game._open_campaign(camp,5)
		check(game.campaign_menu.start_button.disabled,"Les marais exigent la réussite du chapitre précédent")
		for number in range(1,41):
			var run: int = profile.begin_mission(camp,Main.CampaignCatalogue.id_for(number),60,10,100)
			check(profile.credit_mission(run,camp,10,true),"Parcours préalable de la faction préparé par le service normal")
		var first: int = 5 if camp==0 else 0
		var tree: int = Talents.coordinates(first).x
		for index in [first,first,first,first,first,Talents.index_for(tree,1)]: check(profile.allocate(camp,index),"Rangs initiaux financés par l'XP acquise")
		while Talents.spent(profile.data.banks[camp].ranks)<20:
			var allocated := false
			for local in range(21):
				if profile.allocate(camp,Talents.index_for(tree,local)): allocated = true;break
			check(allocated,"Les vingt points accessibles sont répartis légalement")
			if not allocated: break
		game._open_campaign(camp,5);game.campaign_menu._launch()
		check(not game.choosing_faction and game.mission_definition.id=="campaign.041" and game.model.map_definition.id=="marsh_threshold","La mission 41 démarre par le parcours normal")
		check(game.model.combat_affix.is_empty() and not game.affix_label.visible and game.model.enemy_hp_percent==140 and game.model.gold==150 and game.model.fortress_hp==game.model.max_hp,"Nouveau biome sans vent, avec ses paramètres et une forteresse intacte")
		var types: Array = [0,1,2] if camp==0 else [3,3,5]
		play(game.model,types)
		check(game.model.phase=="victory","Une composition accessible gagne dans chaque faction")
		var replay: Dictionary = Replay.verify(JSON.parse_string(JSON.stringify(Report.build(game.model))))
		check(replay.ok,"Le rapport avec décoration marais est rejouable")
		game._sync_meta_rewards(true);game._sync_meta_rewards(true)
		check(profile.campaign_status(camp).completed==41 and profile.data.banks[camp].xp==4100 and profile.data.banks[camp].resource==2460 and profile.data.banks[camp].points==20,"Première victoire créditée une seule fois selon la courbe normale")
		check(profile.campaign_status(1-camp).completed==0,"Le parcours adverse est inchangé")
		game._show_run_summary();game._summary_to_campaign()
		check(game.campaign_menu.chapter==5 and game.campaign_menu.nodes[0].state=="completed" and game.campaign_menu.nodes.slice(1).all(func(node):return node.state=="future"),"Retour sur le nouveau chapitre sans mission future présentée comme prête")
		game.free()
	print("MARSH_CAMPAIGN_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func play(model: RefCounted, types: Array) -> void:
	var slots := [3,4,2];model.rng.seed = 7
	check(model.buy(slots[0],types[0]) and model.buy(slots[1],types[1]),"Recrutement initial dans le budget normal")
	for wave in range(1,11):
		if wave==2: model.upgrade(slots[0])
		if wave>=2 and model.defenders[slots[2]].is_empty(): model.buy(slots[2],types[2])
		if wave>=5:
			for slot in slots:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level==3 else -1)
		check(model.start(),"Vague de marais lancée par les règles normales");model.advance(10000)
		if model.phase=="defeat": break
		if model.phase=="bonus": model.choose_bonus(model.bonus_offer[0])
		if wave<10: model.prepare_next_wave()
	var spent := 0
	for action in model.action_history:
		if action.kind in ["buy","upgrade"]: spent += int(action.cost)
	check(model.gold==150+model.total_income-spent and model.gold>=0,"Recrutements et améliorations sont couverts par les revenus normaux")
