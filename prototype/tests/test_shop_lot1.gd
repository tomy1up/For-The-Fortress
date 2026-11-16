extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_catalogue()
	verify_unlock()
	await verify_pages()
	verify_combat()
	verify_target_rules()
	print("SHOP_LOT1_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_catalogue() -> void:
	var total_po := 0
	for faction in range(2):
		var cards: Array[Dictionary] = Shop.for_faction(faction)
		check(cards.size() == 20,"Vingt alternatives par faction (limite du porteur, 15 novembre 2026)")
		var seen: Dictionary = {}
		var previous_po := 0
		for card in cards:
			check(not seen.has(card.id) and card.type < Model.ROSTER.size() and Model.ROSTER[card.type].name == card.name and int(Model.ROSTER[card.type].price) == int(card.stats.price),"Carte %s : identité unique et fiche d'unité cohérente" % card.id)
			seen[card.id] = true
			check(card.family / 3 == faction and card.family >= 0 and card.family < 6,"%s : famille de talents de sa faction" % card.name)
			check(Shop.BRANCHES.has(card.type) and Shop.BRANCHES[card.type].size() == 2 or card.type < 6,"%s : deux spécialisations" % card.name)
			if card.type >= 10:
				check(int(card.po) >= 300 and int(card.po) <= 1350 and int(card.po) >= previous_po and int(card.unlock_missions) >= 10,"%s : prix de 300 à 1350 PO croissants et déblocage après au moins 10 missions" % card.name)
				previous_po = int(card.po)
				for branch in Shop.BRANCHES[card.type]:
					var plain: bool = branch.damage > 0.0 and branch.interval > 0.0 and branch.range >= 1.5 and branch.has("name") and branch.has("description")
					check(plain,"%s : spécialisation %s valide" % [card.name,branch.name])
			total_po += int(card.po)
	check(total_po == 2*(180+240+300+360+420+480+540+600+660+720+780+840+900+960+1020+1080+1140+1200+1250+1300),"Les prix des deux premiers lots suivent le barème proposé (%d PO au total)" % total_po)
	# Les unités du lot 1 n'écrasent aucune unité de départ : chacune a un défaut mesurable.
	for card in Shop.CARDS:
		if card.type < 10: continue
		var base: Dictionary = Model.ROSTER[card.family]
		var alternative: Dictionary = Model.ROSTER[card.type]
		var worse_somewhere: bool = float(alternative.damage) < float(base.damage) or float(alternative.range) < float(base.range) or float(alternative.interval) > float(base.interval) or int(alternative.price) > int(base.price)
		var better_over_time: bool = alternative.has("curse_damage") and float(alternative.curse_damage) > float(base.get("curse_damage",0.0))
		var better_by_rule: bool = alternative.has("wounded_bonus") or alternative.has("heavy_mult") or alternative.has("fast_mult") or alternative.has("slow_seconds") or alternative.has("mark_seconds") or alternative.has("aura_bonus") or alternative.has("loot_seconds") or alternative.has("entrance_mult") or alternative.has("volatile_seconds") or alternative.has("pivot_bonus")
		var better_somewhere: bool = better_over_time or better_by_rule or float(alternative.damage) > float(base.damage) or float(alternative.range) > float(base.range) or float(alternative.interval) < float(base.interval) or int(alternative.price) < int(base.price)
		check(worse_somewhere and better_somewhere,"%s : ni strictement meilleure ni strictement pire que l'unité de départ de sa famille" % card.name)

func verify_unlock() -> void:
	for faction in range(2):
		var cards: Array[Dictionary] = Shop.for_faction(faction)
		var locked: Dictionary = {}
		for card in cards:
			if int(card.get("unlock_missions",0)) > 0: locked = card;break
		check(not locked.is_empty(),"Une carte du lot est verrouillée par les missions réussies")
		var p := Profile.new("")
		# PO suffisantes mais pas assez de missions : on crédite des PO sans passer par 10 victoires.
		var next: Dictionary = p.data.duplicate(true)
		for mission in range(1,6):
			var run: int = p.begin_mission(faction,"campaign.%03d" % mission,60,10,100);p.credit_mission(run,faction,10,true)
		p.data.banks[faction].resource = 5000
		check(p.shop_error(faction,locked.id).contains("missions réussies") and not p.buy_shop_unit(faction,locked.id),"Carte %s refusée avant %d missions réussies, même avec les PO" % [locked.id,int(locked.unlock_missions)])
		for mission in range(6,int(locked.unlock_missions)+1):
			var run: int = p.begin_mission(faction,"campaign.%03d" % mission,60,10,100);p.credit_mission(run,faction,10,true)
		p.data.banks[faction].resource = 5000
		check(p.shop_error(faction,locked.id).is_empty() and p.buy_shop_unit(faction,locked.id),"Carte %s achetable après %d missions réussies" % [locked.id,int(locked.unlock_missions)])

func verify_pages() -> void:
	for faction in range(2):
		var p := Profile.new("")
		for number in range(1,12):
			var run: int = p.begin_mission(faction,"campaign.%03d" % number,60,10,100);p.credit_mission(run,faction,10,true)
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = p;scene._open_campaign(faction)
		scene.campaign_menu.shop_button.pressed.emit()
		var shop = scene.shop_menu
		check(shop.all_cards.size() == 20 and shop.cards.size() == 2 and shop.page == 0 and shop.previous_button.disabled and not shop.next_button.disabled and shop.page_label.text.contains("Page 1 / 10"),"La boutique s'ouvre à la première page de dix")
		var first: String = shop.cards[0].id
		shop.next_button.pressed.emit()
		check(shop.page == 1 and shop.cards[0].id != first and not shop.previous_button.disabled,"Page suivante : deux autres cartes")
		check(shop.card_panels.all(func(panel):return panel.visible) and shop.buy_buttons.all(func(button):return button.visible),"Les deux emplacements de la page sont utilisés")
		for index in range(shop.cards.size()):
			check(Rect2(0,0,1280,800).encloses(shop.buy_buttons[index].get_global_rect()) and Rect2(0,0,1280,800).encloses(shop.next_button.get_global_rect()),"Les commandes de page tiennent dans la fenêtre")
		for _i in range(12): shop.next_button.pressed.emit()
		check(shop.page == 9 and shop.next_button.disabled,"La dernière page bloque « Suivantes »")
		shop.close()
		scene.free()

func verify_combat() -> void:
	for faction in range(2):
		for card in Shop.for_faction(faction):
			if card.type < 10: continue
			var model := Model.new(true,Model.Maps.for_id("valley_ford"))
			check(model.configure_auxiliary(card.type),"%s : alternative acceptée pour la mission" % card.name)
			model.rng.seed = 7;model.select_faction(faction)
			var types: Array = model.available_types()
			check(types.size() == 4 and types[3] == card.type,"%s : quatrième type de la mission" % card.name)
			check(model.buy(3,card.type) and model.defenders[3].type == card.type,"%s : recrutée à l'emplacement 4" % card.name)
			for wave in range(1,11): # jusqu'à la fin de la partie : un rapport ne se construit que sur une partie terminée
				model.start();model.advance(10000)
				if model.phase == "defeat": break
				if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
				if wave < 10: model.prepare_next_wave()
			var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
			var replay: Dictionary = Replay.verify(report)
			check(replay.ok,"%s : rapport de combat rejouable (%s)" % [card.name,str(replay.get("error",""))])

## Règles de cible du second lot : blessé, lourd, petit, rapide (valeurs de prototype).
func verify_target_rules() -> void:
	var intact := {"type":1,"hp":40.0,"max_hp":40.0}
	var wounded := {"type":1,"hp":20.0,"max_hp":40.0}
	var brute := {"type":3,"hp":120.0,"max_hp":120.0}
	var sprinter := {"type":2,"hp":24.0,"max_hp":24.0}
	var plain: Dictionary = Model.stats_for(0)
	check(Model.target_multiplier(plain,wounded) == 1.0 and Model.target_multiplier(plain,brute) == 1.0,"Une unité sans règle n'a aucun multiplicateur de cible")
	var double: Dictionary = Model.stats_for(Shop.card("alliance.doublearcher").type)
	check(Model.target_multiplier(double,intact) == 1.0 and is_equal_approx(Model.target_multiplier(double,wounded),1.9),"L'archer double gagne 90 % sur un ennemi blessé seulement")
	var heavy: Dictionary = Model.stats_for(Shop.card("alliance.heavycrossbow").type)
	check(is_equal_approx(Model.target_multiplier(heavy,brute),1.8) and is_equal_approx(Model.target_multiplier(heavy,sprinter),0.5) and Model.target_multiplier(heavy,{"type":4,"hp":80.0,"max_hp":80.0}) == 0.5,"L'arbalète lourde : ×1,8 contre un lourd, ×0,5 contre un petit")
	var sling: Dictionary = Model.stats_for(Shop.card("horde.blowgun").type)
	check(is_equal_approx(Model.target_multiplier(sling,sprinter),1.8) and is_equal_approx(Model.target_multiplier(sling,brute),0.5) and Model.target_multiplier(sling,intact) == 1.0,"La sarbacane : ×1,8 contre un rapide, ×0,5 contre un lourd")
	# Le tir réel applique la règle : même défenseur, cible intacte puis blessée.
	var model := Model.new(true)
	var archer_type: int = Shop.card("alliance.doublearcher").type
	check(model.configure_auxiliary(archer_type),"L'archer double est accepté comme alternative")
	model.select_faction(0);model.gold = 1000
	model.buy(3,archer_type)
	var stats: Dictionary = model.get_stats(3)
	check(is_equal_approx(model.damage_for(stats,"direct",wounded)/model.damage_for(stats,"direct",intact),1.9),"damage_for applique le bonus de cible blessée")
