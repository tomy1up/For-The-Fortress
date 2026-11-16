extends SceneTree
## Cohérence entre la fiche d'une unité de boutique (rôle, compromis, statistiques) et son comportement réel en combat (demande du porteur, 16 novembre 2026,
## après la découverte que la brûlure du Pyromancien n'était jamais appliquée). Chaque effet annoncé par une statistique doit se produire dans le modèle.
const Model = preload("res://scripts/valley_model.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func arena(card: Dictionary, wave: int = 1):
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.configure_auxiliary(card.type)
	m.select_faction(card.faction)
	m.gold = 5000
	m.rng.seed = 7
	if wave != 1:
		m.wave = wave
		m.spawn_schedule = Model.Campaign.schedule(wave)
	return m

## Première cible touchée par l'unité placée à l'emplacement 3 ; retourne {"model","enemy"} ou {} si aucun tir n'a eu lieu.
func first_shot(card: Dictionary, wave: int = 1) -> Dictionary:
	var m = arena(card,wave)
	m.buy(3,card.type)
	m.start()
	var guard := 0
	while m.active and m.shots.is_empty() and guard < 6000:
		m.advance(0.01);guard += 1
	if m.shots.is_empty(): return {}
	for enemy in m.enemies:
		if enemy.id == m.shots[0].target_id: return {"model":m,"enemy":enemy}
	return {"model":m,"enemy":{}}

func run_checks() -> void:
	var covered: Dictionary = {}
	for faction in range(2):
		var cards: Array = []
		for base_type in range(faction*3,faction*3+3): cards.append({"type":base_type,"faction":faction,"name":Model.ROSTER[base_type].name,"family":base_type}) # unités de base
		cards.append_array(Shop.for_faction(faction))
		for card in cards:
			var base: Dictionary = Model.ROSTER[card.type]
			var name: String = card.name
			var m0 = arena(card)
			m0.buy(3,card.type)
			var stats: Dictionary = m0.get_stats(3)
			# Effets de cible (posés sur l'ennemi touché par le tir direct).
			var needs_shot: bool = float(base.get("slow_seconds",0.0)) > 0.0 or float(base.get("mark_seconds",0.0)) > 0.0 or float(base.get("loot_seconds",0.0)) > 0.0 or float(base.get("volatile_seconds",0.0)) > 0.0 or float(base.get("curse_damage",0.0)) > 0.0
			if needs_shot:
				var shot: Dictionary = first_shot(card)
				check(not shot.is_empty() and not shot.enemy.is_empty(),"%s : tire sur un ennemi" % name)
				if not shot.is_empty() and not shot.enemy.is_empty():
					var enemy: Dictionary = shot.enemy
					var m = shot.model
					if float(base.get("slow_seconds",0.0)) > 0.0:
						check(enemy.has("slow_until") and float(enemy.slow_until) > m.elapsed,"%s : ralentit la cible touchée" % name);covered["slow"] = true
					if float(base.get("mark_seconds",0.0)) > 0.0:
						check(float(enemy.get("marked_until",-1.0)) > m.elapsed and float(enemy.get("mark_bonus",0.0)) > 0.0,"%s : marque la cible touchée" % name);covered["mark"] = true
					if float(base.get("loot_seconds",0.0)) > 0.0:
						check(float(enemy.get("loot_until",-1.0)) >= m.elapsed and float(enemy.get("loot_bonus",0.0)) > 0.0,"%s : désigne la cible au pillage" % name);covered["loot"] = true
					if float(base.get("volatile_seconds",0.0)) > 0.0:
						check(float(enemy.get("volatile_until",-1.0)) >= m.elapsed and float(enemy.get("volatile_damage",0.0)) > 0.0,"%s : rend la cible volatile" % name);covered["volatile"] = true
					if float(base.get("curse_damage",0.0)) > 0.0:
						check(not m.curses.is_empty() and m.curses[0].enemy_id == enemy.id and float(m.curses[0].damage) > 0.0,"%s : applique une brûlure ou malédiction sur la cible" % name)
						var hp_after_hit: float = float(enemy.hp)
						var guard := 0
						var ticked: bool = false
						while m.active and guard < 400 and not ticked:
							m.advance(0.01);guard += 1
							for event in m.damage_events:
								if str(event.get("component","")) == "curse": ticked = true
						check(ticked,"%s : les dégâts sur la durée tombent réellement" % name);covered["curse"] = true
			# Dégâts secondaires (zone, rebonds, chaîne) : des ennemis voisins sont touchés.
			if int(base.get("secondary_cap",0)) > 0:
				var m = arena(card,8)
				m.buy(3,card.type)
				m.start()
				var guard := 0
				var most: int = 0
				while m.active and guard < 6000:
					m.advance(0.01);guard += 1
					for shot in m.shots: most = maxi(most,shot.secondary.size())
					if most > 0: break
				check(most > 0 and most <= int(base.secondary_cap),"%s : touche des ennemis voisins (au plus %d)" % [name,int(base.secondary_cap)]);covered["secondary"] = true
			# Aura des gardiens : un voisin dans le rayon reçoit le bonus annoncé (carte aux emplacements rapprochés : ford_woods).
			if float(base.get("aura_bonus",0.0)) > 0.0:
				var am = Model.new(true,Model.Maps.for_id("ford_woods"))
				am.configure_auxiliary(card.type);am.select_faction(card.faction);am.gold = 5000
				var source: int = -1
				var neighbour: int = -1
				for a in range(am.slots.size()):
					for other in range(am.slots.size()):
						if a != other and source < 0 and am.slots[a].distance_to(am.slots[other]) <= float(base.aura_radius): source = a;neighbour = other
				check(source >= 0,"%s : deux emplacements de la carte sont dans le rayon de l'aura" % name)
				if source >= 0:
					am.buy(source,card.type)
					am.buy(neighbour,card.faction*3)
					check(is_equal_approx(am.guardian_aura(neighbour),float(base.aura_bonus)),"%s : le voisin reçoit +%d %% de dégâts" % [name,int(float(base.aura_bonus)*100.0)])
					check(is_equal_approx(am.guardian_aura(source),0.0),"%s : l'aura ne profite pas à l'unité elle-même" % name)
					var boosted: float = am.get_stats(neighbour).damage
					am.sell(source)
					check(am.get_stats(neighbour).damage < boosted,"%s : le bonus disparaît quand le gardien est vendu" % name)
				covered["aura"] = true
			# Multiplicateurs selon la cible.
			var victim_wounded: Dictionary = {"type":1,"hp":10.0,"max_hp":40.0}
			var victim_intact: Dictionary = {"type":1,"hp":40.0,"max_hp":40.0}
			if float(base.get("wounded_bonus",0.0)) > 0.0:
				check(is_equal_approx(Model.target_multiplier(stats,victim_wounded),1.0+float(base.wounded_bonus)) and is_equal_approx(Model.target_multiplier(stats,victim_intact),1.0),"%s : bonus contre les ennemis blessés" % name);covered["wounded"] = true
			if float(base.get("heavy_mult",0.0)) > 0.0:
				check(is_equal_approx(Model.target_multiplier(stats,{"type":5,"hp":10.0,"max_hp":10.0}),float(base.heavy_mult)),"%s : multiplicateur contre les lourds" % name);covered["heavy"] = true
			if float(base.get("small_mult",0.0)) > 0.0:
				check(is_equal_approx(Model.target_multiplier(stats,{"type":4,"hp":10.0,"max_hp":10.0}),float(base.small_mult)),"%s : multiplicateur contre les petits" % name);covered["small"] = true
			if float(base.get("fast_mult",0.0)) > 0.0:
				check(is_equal_approx(Model.target_multiplier(stats,{"type":2,"hp":10.0,"max_hp":10.0}),float(base.fast_mult)),"%s : multiplicateur contre les rapides" % name);covered["fast"] = true
			# Position sur le trajet : entrée (premier tiers) et forteresse (dernier tiers).
			if base.has("entrance_mult") or base.has("exit_mult"):
				var length: float = m0.path_length
				check(is_equal_approx(m0.progress_multiplier(stats,{"distance":length*0.1}),float(base.get("entrance_mult",1.0))) and is_equal_approx(m0.progress_multiplier(stats,{"distance":length*0.9}),float(base.get("exit_mult",1.0))) and is_equal_approx(m0.progress_multiplier(stats,{"distance":length*0.5}),1.0),"%s : multiplicateurs d'entrée et de forteresse" % name);covered["progress"] = true
			# Unité-pivot : +x % par vague survivée, plafonné à +90 %.
			if float(base.get("pivot_bonus",0.0)) > 0.0:
				m0.wave = 4
				check(is_equal_approx(m0.pivot_bonus(m0.defenders[3]),minf(0.9,float(base.pivot_bonus)*3.0)),"%s : bonus croissant par vague survivée" % name)
				m0.wave = 30
				check(is_equal_approx(m0.pivot_bonus(m0.defenders[3]),0.9),"%s : bonus plafonné à +90 %%" % name);covered["pivot"] = true
	for kind in ["slow","mark","loot","volatile","curse","secondary","aura","wounded","heavy","small","fast","progress","pivot"]:
		check(covered.has(kind),"Effet %s couvert par au moins une unité" % kind)
	# Pillage : un ennemi désigné rapporte +120 % d'or s'il est éliminé pendant la fenêtre.
	var loot_card: Dictionary = Shop.card("alliance.mercenary")
	var lm = arena(loot_card)
	lm.phase = "combat"
	var lootable: Dictionary = Model.make_enemy(0,1,0)
	lootable.distance = 4.0
	lootable.loot_until = 100.0;lootable.loot_bonus = 1.2
	var plain: Dictionary = Model.make_enemy(1,1,0)
	plain.distance = 5.0
	lm.enemies.assign([lootable,plain])
	var gold_before: int = lm.gold
	lm._apply_damage({0:1000000.0})
	var looted: int = lm.gold-gold_before
	gold_before = lm.gold
	lm._apply_damage({1:1000000.0})
	var normal: int = lm.gold-gold_before
	check(looted == roundi(float(normal)*2.2) and normal > 0,"Pillage : +120 %% d'or sur l'ennemi désigné (%d contre %d)" % [looted,normal])
	# Volatile : à sa mort, l'ennemi blesse ses voisins proches.
	var vm = arena(Shop.card("alliance.alchemist"))
	vm.phase = "combat"
	var bomb: Dictionary = Model.make_enemy(0,3,0);bomb.distance = 4.0;bomb.volatile_until = 100.0;bomb.volatile_damage = 80.0;bomb.volatile_radius = 1.4
	var neighbour: Dictionary = Model.make_enemy(1,3,0);neighbour.distance = 4.3
	var far: Dictionary = Model.make_enemy(2,3,0);far.distance = 12.0
	vm.enemies.assign([bomb,neighbour,far])
	var neighbour_hp: float = neighbour.hp
	var far_hp: float = far.hp
	vm._apply_damage({0:1000000.0})
	check(vm.enemies.size() == 2 and float(vm.enemies[0].hp) == neighbour_hp-80.0 and float(vm.enemies[1].hp) == far_hp,"Volatile : 80 dégâts aux voisins à portée, aucun aux ennemis lointains")
	print("UNIT_EFFECTS_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
