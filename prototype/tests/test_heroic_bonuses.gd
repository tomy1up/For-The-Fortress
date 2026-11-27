extends SceneTree
## Bonus héroïques (v0.260, renforcés en v0.261 ; validés par le porteur le 27 novembre 2026) : catalogue, second choix héroïque après le choix ordinaire
## des vagues 4 et 8 en Héroïque seulement, quinze effets aux valeurs renforcées, règle et valeurs de la v0.260 pour le rejeu, interface, rapport et rejeu.
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Reference = preload("res://tests/reference_army.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	verify_catalogue()
	verify_offers()
	verify_offers_v260()
	verify_damage_bonuses()
	verify_events()
	verify_games()
	verify_interface()
	verify_launch()
	print("HEROIC_BONUSES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

func verify_catalogue() -> void:
	var data = Model.Campaign
	check(data.BONUSES.size() == 75 and data.HEROIC_FIRST == 60 and data.HEROIC_COUNT == 15,"75 bonus, dont 15 héroïques (codes 60 à 74)")
	var chapters: Array = []
	for code in range(60,75):
		check(data.bonus_rarity(code) == "heroic" and data.is_heroic_bonus(code) and str(data.BONUSES[code].code) == "H-%02d" % (code-59),"Bonus %d : rareté héroïque, code H-%02d" % [code,code-59])
		chapters.append(int(data.BONUSES[code].chapter))
	check(chapters == [1,1,2,3,4,5,6,7,8,9,10,11,12,13,14],"Deux bonus au chapitre 1, puis un par chapitre jusqu'au 14 : %s" % str(chapters))
	check(not data.is_heroic_bonus(59) and not data.is_heroic_bonus(75) and data.heroic_bonuses_for(0).is_empty() and data.heroic_bonuses_for(1) == [60,61] and data.heroic_bonuses_for(5).size() == 6 and data.heroic_bonuses_for(14).size() == 15 and data.heroic_bonuses_for(20).size() == 15,"Bonus débloqués par chapitre")
	check(Model.H_HUNTER == 60 and Model.H_LAST_SQUARE == 74,"Constantes du combat alignées sur le catalogue")
	check(Reference.BONUS_VALUES[0].size() == 75 and Reference.BONUS_VALUES[1].size() == 75,"Une note par bonus pour le joueur avisé des mesures")
	check(data.BONUSES[60].description.begins_with("+100 %") and Replay.BONUS_TEXTS_V260[60][0].begins_with("+60 %") and Replay.BONUS_TEXTS_V260.size() == 13,"Textes renforcés en v0.261 ; ceux de la v0.260 gardés pour le rejeu")

func army(chapter: int = 0, rules_v261: bool = true) -> Model:
	var m := Model.new(true,Model.Maps.for_id("valley_ford"))
	m.rules_v261 = rules_v261
	if chapter > 0: m.configure_difficulty(1);m.configure_heroic_bonuses(chapter)
	m.select_faction(0)
	m.buy(3,0);m.buy(4,1)
	return m

## Offre ordinaire de la vague `wave`, comme à la fin d'une vague gagnée.
func offer_at(m: Model, wave: int, seed: int) -> void:
	m.rng.seed = seed;m.wave = wave;m.phase = "bonus";m.heroic_choice = false
	m.bonus_offer.assign(m._draw_offers([]))

func verify_offers() -> void:
	var normal := army()
	var heroic := army(20)
	check(not heroic.configure_heroic_bonuses(3),"Chapitre fixé avant la première action")
	check(not Model.new(true,Model.Maps.for_id("valley_ford")).configure_heroic_bonuses(21),"Chapitre borné à 20")
	check(normal.max_bonuses() == 4 and heroic.max_bonuses() == 6,"Quatre bonus en Normal, six en Héroïque")
	var seen: Dictionary = {}
	for seed in range(40):
		for wave in [2,4,6,8]:
			offer_at(normal,wave,seed)
			check(normal.bonus_offer.all(func(code): return code < 60),"Normal : jamais de bonus héroïque")
			normal.bonuses.clear()
			check(normal.choose_bonus(normal.bonus_offer[0]) and normal.phase == "finished","Normal : un seul choix")
			normal.bonuses.clear()
			offer_at(heroic,wave,seed)
			check(heroic.bonus_offer.size() == 3 and heroic.bonus_offer.all(func(code): return code < 60),"Héroïque, vague %d : offre ordinaire de trois cartes" % wave)
			heroic.bonuses.clear()
			check(heroic.choose_bonus(heroic.bonus_offer[0]),"Héroïque : choix ordinaire")
			if wave in [4,8]:
				var second: Array = heroic.bonus_offer.duplicate()
				check(heroic.phase == "bonus" and heroic.heroic_choice and second.size() == 2 and second[0] != second[1] and second.all(func(code): return code >= 60 and code not in [Model.H_DOCTRINE,Model.H_SEAL,Model.H_PLAGUE]),"Héroïque, vague %d : second choix entre deux bonus héroïques utiles (%s)" % [wave,str(second)])
				for code in second: seen[code] = true
				check(heroic.action_history[-1].kind == "bonus_offer" and heroic.action_history[-1].get("heroic",false),"Second choix journalisé")
				check(heroic.choose_bonus(second[1]) and heroic.phase == "finished" and not heroic.heroic_choice and heroic.bonuses.size() == 2,"Second choix : la partie reprend avec deux bonus")
			else: check(heroic.phase == "finished","Héroïque, vague %d : pas de second choix" % wave)
			heroic.bonuses.clear()
	check(seen.size() == 12,"Les douze bonus héroïques utiles à cette armée sont proposés (%d)" % seen.size())
	# Relance pendant le second choix : deux autres cartes héroïques si possible.
	var r := army(20)
	offer_at(r,4,9)
	r.choose_bonus(r.bonus_offer[0])
	var before: Array = r.bonus_offer.duplicate()
	check(r.reroll_bonus() and r.bonus_offer.size() == 2 and r.bonus_offer.all(func(code): return code >= 60 and code not in before),"Relance du second choix : deux autres bonus héroïques")
	# Chapitre 1 : les deux premiers bonus héroïques ; un bonus pris n'est plus proposé.
	var early := army(1)
	offer_at(early,4,3)
	early.choose_bonus(early.bonus_offer[0])
	check(early.bonus_offer.size() == 2 and early.bonus_offer.has(60) and early.bonus_offer.has(61),"Chapitre 1 : Chasseur et Prime des champions")
	early.choose_bonus(60)
	early.phase = "finished"
	offer_at(early,8,4)
	early.choose_bonus(early.bonus_offer[0])
	check(Array(early.bonus_offer) == [61],"Une seule carte quand il ne reste qu'un bonus héroïque")
	# Utilité : Doctrine (une seule famille), Sceau (rappels), Fléau (malédiction).
	var twins := Model.new(true,Model.Maps.for_id("valley_ford"));twins.select_faction(0);twins.buy(3,0);twins.buy(4,0)
	check(twins.bonus_useful(Model.H_DOCTRINE) and not heroic.bonus_useful(Model.H_DOCTRINE),"Doctrine : utile avec une seule famille")
	check(not heroic.bonus_useful(Model.H_SEAL) and not heroic.bonus_useful(Model.H_PLAGUE),"Sceau sans rappel et Fléau sans malédiction : inutiles")

## Règle de la v0.260, gardée pour le rejeu : la troisième carte des vagues 4 et 8 est héroïque, sans second choix.
func verify_offers_v260() -> void:
	var old := army(20,false)
	for seed in range(20):
		for wave in [2,4,6,8]:
			offer_at(old,wave,seed)
			var count: int = old.bonus_offer.filter(func(code): return code >= 60).size()
			check(count == (1 if wave in [4,8] else 0) and (wave not in [4,8] or old.bonus_offer[2] >= 60),"Règle v0.260, vague %d : carte héroïque de remplacement" % wave)
			old.choose_bonus(old.bonus_offer[0])
			check(old.phase == "finished" and not old.heroic_choice,"Règle v0.260 : pas de second choix")
			old.bonuses.clear()
	check(old.max_bonuses() == 4,"Règle v0.260 : quatre bonus au plus")

## Gain de dégâts direct d'un défenseur avec un bonus de plus.
func gain(m: Model, slot: int, code: int, victim: Dictionary = {"type":1}) -> float:
	var before: float = m.damage_for(m.get_stats(slot),"direct",victim)
	m.bonuses.append(code)
	var after: float = m.damage_for(m.get_stats(slot),"direct",victim)
	m.bonuses.erase(code)
	return after/before

## Rapport attendu pour un gain additif `extra` : les gains de dégâts s'additionnent à ceux déjà acquis (synergies, talents).
func expected(m: Model, slot: int, extra: float) -> float:
	var bonus: float = m.get_stats(slot).direct_bonus
	return (1.0+bonus+extra)/(1.0+bonus)

func verify_damage_bonuses() -> void:
	var m := army(20)
	var champion: Dictionary = Model.make_enemy(50,1,0.0,0,100);m._make_champion(champion,["regen"])
	check(is_equal_approx(gain(m,3,Model.H_HUNTER,champion),expected(m,3,1.0)) and is_equal_approx(gain(m,3,Model.H_HUNTER,{"type":7}),expected(m,3,1.0)) and is_equal_approx(gain(m,3,Model.H_HUNTER),1.0),"Chasseur de champions : +100 % contre champions et boss seulement")
	var old := army(20,false)
	check(is_equal_approx(gain(old,3,Model.H_HUNTER,{"type":7}),expected(old,3,0.6)) and is_equal_approx(gain(old,3,Model.H_PACT),expected(old,3,0.6)),"Règle v0.260 : anciennes valeurs (+60 %)")
	check(is_equal_approx(gain(m,3,Model.H_PACT),expected(m,3,1.0)),"Pacte de sang : +100 %")
	check(is_equal_approx(gain(m,3,Model.H_NUMBERS),expected(m,3,0.3)),"Supériorité numérique : +15 % par défenseur (deux)")
	check(is_equal_approx(gain(m,3,Model.H_SEAL),expected(m,3,0.15)),"Sceau des anciens : +15 % à tous les dégâts")
	check(is_equal_approx(gain(m,3,Model.H_DOCTRINE),1.0),"Doctrine unique : rien avec deux familles")
	var twins := Model.new(true,Model.Maps.for_id("valley_ford"));twins.select_faction(0);twins.buy(3,0);twins.buy(4,0)
	check(is_equal_approx(gain(twins,3,Model.H_DOCTRINE),expected(twins,3,0.8)),"Doctrine unique : +80 % avec une seule famille")
	# Héros (inchangé) : le plus haut niveau, puis le plus d'or investi.
	check(m.hero_slot() == 4,"Héros : l'arbalétrier, plus cher à niveau égal")
	m.gold = 1000;m.upgrade(3)
	check(m.hero_slot() == 3,"Héros : l'archer passé au niveau 2")
	var range_before: float = m.get_stats(3).range
	check(is_equal_approx(gain(m,3,Model.H_HERO),expected(m,3,0.6)) and is_equal_approx(gain(m,4,Model.H_HERO),1.0),"Héros du rempart : +60 % au héros seulement")
	m.bonuses.append(Model.H_HERO)
	check(is_equal_approx(m.get_stats(3).range,range_before+1.0),"Héros du rempart : +1 de portée")
	m.bonuses.erase(Model.H_HERO)
	# Cibles : lourds, Blindé, dernier carré.
	check(is_equal_approx(gain(m,3,Model.H_PIERCE,{"type":3}),expected(m,3,0.5)),"Perce-armures : +50 % contre les lourds")
	var armored: Dictionary = Model.make_enemy(51,1,0.0,0,100);m._make_champion(armored,["armored"])
	check(is_equal_approx(gain(m,3,Model.H_PIERCE,armored),1.0/0.7),"Perce-armures : le trait Blindé est ignoré")
	var far: Dictionary = Model.make_enemy(52,1,0.0,0,100);far.distance = m.path_length*0.78
	var middle: Dictionary = Model.make_enemy(53,1,0.0,0,100);middle.distance = m.path_length*0.5
	check(is_equal_approx(gain(m,3,Model.H_LAST_SQUARE,far),expected(m,3,1.5)) and is_equal_approx(gain(m,3,Model.H_LAST_SQUARE,middle),1.0),"Dernier carré : +150 % au-delà de 75 % de la route")
	# Arsenal royal : améliorations −60 %, achats inchangés.
	var cost_before: int = m.upgrade_cost(4)
	var buy_before: int = m.purchase_cost(0)
	m.bonuses.append(Model.H_ARSENAL)
	check(m.upgrade_cost(4) == int(ceil(cost_before*0.4-0.000000001)) and m.purchase_cost(0) == buy_before,"Arsenal royal : améliorations −60 %, achats inchangés")
	m.bonuses.erase(Model.H_ARSENAL)
	# Fléau : malédictions +100 %.
	var horde := Model.new(true,Model.Maps.for_id("valley_ford"));horde.select_faction(1);horde.buy(3,5)
	var curse_before: float = horde.get_stats(3).curse_bonus
	horde.bonuses.append(Model.H_PLAGUE)
	check(is_equal_approx(horde.get_stats(3).curse_bonus,curse_before+1.0),"Fléau : malédictions +100 %")

func verify_events() -> void:
	# Prime des champions.
	var m := army(20)
	var champion: Dictionary = Model.make_enemy(60,1,0.0,0,100);m._make_champion(champion,["regen"]);m.enemies.append(champion)
	m.bonuses.append(Model.H_CHAMPION_GOLD)
	var gold_before: int = m.gold
	m._apply_damage({60:champion.max_hp*2.0})
	check(m.gold-gold_before == int(champion.reward)+50,"Prime des champions : +50 or")
	# Charges en chaîne : 40 % des PV maximum de la victime aux voisins à 1,5 case.
	var c := army(20)
	c.bonuses.append(Model.H_CHAIN)
	var victim: Dictionary = Model.make_enemy(70,3,0.0,0,100);victim.distance = 4.0;c.enemies.append(victim)
	var near: Dictionary = Model.make_enemy(71,3,0.0,0,100);near.distance = 4.5;c.enemies.append(near)
	var away: Dictionary = Model.make_enemy(72,3,0.0,0,100);away.distance = 8.0;c.enemies.append(away)
	c._apply_damage({70:victim.max_hp*2.0})
	check(is_equal_approx(near.hp,near.max_hp-victim.max_hp*0.4) and is_equal_approx(away.hp,away.max_hp),"Charges en chaîne : 40 % des PV max aux voisins")
	# Fléau : la malédiction passe au plus proche.
	var f := Model.new(true,Model.Maps.for_id("valley_ford"));f.select_faction(1)
	f.bonuses.append(Model.H_PLAGUE)
	var cursed: Dictionary = Model.make_enemy(80,1,0.0,1,100);cursed.distance = 4.0;f.enemies.append(cursed)
	var close: Dictionary = Model.make_enemy(81,1,0.0,1,100);close.distance = 4.6;f.enemies.append(close)
	var distant: Dictionary = Model.make_enemy(82,1,0.0,1,100);distant.distance = 9.0;f.enemies.append(distant)
	f._apply_curse(7,80,5.0)
	f._apply_damage({80:cursed.max_hp*2.0})
	check(f.curses.size() == 1 and int(f.curses[0].enemy_id) == 81,"Fléau : la malédiction passe à l'ennemi le plus proche")
	# Sceau des anciens et Hiver éternel à l'apparition.
	var s := army(20)
	s.recalled_attackers = [[4,13,4,2.0]];s.recalled_affix = Catalogue.biome_affix(1)
	check(s.flood_enabled() and s.bonus_useful(Model.H_SEAL),"Avant le Sceau : crue rappelée active")
	s.bonuses.append(Model.H_SEAL)
	check(not s.flood_enabled() and s.affix_of("flood").is_empty() and s.biome_affix_ids().is_empty() and s.active_recalled_affix().is_empty(),"Sceau des anciens : affixe rappelé sans effet")
	var ibex: Dictionary = Model.make_enemy(90,13,0.0,0,100);var wolf: Dictionary = Model.make_enemy(91,0,0.0,0,100)
	var ibex_hp: float = ibex.max_hp;var wolf_hp: float = wolf.max_hp
	s._heroic_spawn(ibex,true);s._heroic_spawn(wolf,true)
	check(is_equal_approx(ibex.max_hp,ibex_hp*0.4) and ibex.hp == ibex.max_hp and is_equal_approx(wolf.max_hp,wolf_hp),"Sceau des anciens : attaquants rappelés à 40 % de PV")
	s.bonuses.append(Model.H_WINTER)
	var slowed: Dictionary = Model.make_enemy(92,0,0.0,0,100);var speed: float = slowed.speed
	s._heroic_spawn(slowed,false)
	check(is_equal_approx(slowed.speed,speed*0.7),"Hiver éternel : vitesse ×0,7")
	# Forge ardente et Pacte de sang en fin de vague.
	var w := army(20)
	w.gold = 1000;w.upgrade(4)
	w.bonuses.append_array([Model.H_FORGE,Model.H_PACT])
	var max_before: int = w.max_hp
	w._wave_cleared_bonuses()
	check(w.defenders[3].level == 2 and w.defenders[4].level == 2 and w.max_hp == max_before-1 and w.fortress_hp <= w.max_hp,"Forge ardente : le moins avancé gagne un niveau ; Pacte de sang : −1 PV max")
	w._wave_cleared_bonuses();w._wave_cleared_bonuses()
	check(w.defenders[3].level == 3 and w.defenders[4].level == 3,"Forge ardente : jusqu'au niveau 3")
	# Perce-armures : boucliers ignorés.
	for pierce in [false,true]:
		var p := Model.new(true,Model.Maps.for_id("valley_ford"))
		p.configure_difficulty(1);p.configure_champions(20);p.configure_heroic_bonuses(20);p.select_faction(0)
		if pierce: p.bonuses.append(Model.H_PIERCE)
		var shielded: Dictionary = Model.make_enemy(95,3,0.0,0,100);p._make_champion(shielded,["shield"]);p.enemies.append(shielded)
		var shield: float = shielded.shield;var hp: float = shielded.hp
		p._apply_damage({95:10.0})
		if pierce: check(is_equal_approx(shielded.hp,hp-10.0) and is_equal_approx(shielded.shield,shield),"Perce-armures : le bouclier n'absorbe rien")
		else: check(is_equal_approx(shielded.hp,hp) and is_equal_approx(shielded.shield,shield-10.0),"Sans Perce-armures : le bouclier absorbe")
	# Muraille vivante : cinq arrivées sans dégâts par vague, après la Herse (trois avec la règle de la v0.260).
	for rules in [[true,false,5],[true,true,6],[false,false,3]]:
		var g := army(20,rules[0])
		g.bonuses.append(Model.H_WALL)
		if rules[1]: g.bonuses.append(Model.B_GATE)
		g.start()
		for index in range(7):
			var runner: Dictionary = Model.make_enemy(200+index,1,-1000.0,0,100);runner.max_hp = 1.0e9;runner.hp = 1.0e9;g.enemies.append(runner)
		var hp_before: int = g.fortress_hp
		g.advance(0.01)
		var hits: int = (7-int(rules[2]))*int(Model.enemy_definition(1).fortress_damage)
		check(hp_before-g.fortress_hp == hits,"Muraille vivante%s%s : %d arrivées sur 7 sans dégâts" % [" et Herse" if rules[1] else ""," (v0.260)" if not rules[0] else "",int(rules[2])])

## Partie héroïque : chaque carte héroïque proposée est prise, sinon le choix avisé de la référence.
func play(m: Model, faction: int, number: int, step: float) -> Dictionary:
	m.rng.seed = 5
	var types: Array = Reference.types(faction,number)
	m.buy(0,types[0]);m.buy(1,types[1])
	for wave in range(1,11):
		if wave >= 2 and m.defenders[2].is_empty(): m.buy(2,types[2])
		if wave >= 5:
			for slot in [0,1,2]:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): break
		while m.active: m.advance(step)
		if m.phase == "defeat": break
		for _choice in range(3):
			if m.phase != "bonus": break
			var heroic: Array = m.bonus_offer.filter(func(code): return code >= 60)
			if heroic.is_empty(): Reference.choose_bonus(m)
			else: m.choose_bonus(heroic[-1])
		if wave < 10: m.prepare_next_wave()
	return JSON.parse_string(JSON.stringify(Report.build(m)))

func heroic_model(number: int, faction: int, rules_v261: bool = true) -> Model:
	var runtime: Dictionary = Catalogue.runtime(Catalogue.id_for(number,1))
	var m := Model.new(true,Model.Maps.for_id(runtime.map_id))
	m.rules_v261 = rules_v261
	var chapter: int = (number-1)/10+1
	m.configure_enemy_hp(100);m.configure_wave_set(runtime.get("wave_set_id","ford"));m.configure_difficulty(1)
	m.configure_champions(chapter);m.configure_heroic_bonuses(chapter);m.configure_combat_affix(runtime.get("combat_affix",{}))
	m.configure_recalled_affix(Catalogue.recalled_affix(number,1));m.configure_recalled_attackers(Catalogue.recalled_attackers(number,1))
	m.select_faction(faction)
	return m

func verify_games() -> void:
	var taken: Dictionary = {}
	var six: int = 0
	for number in [12,24,46,58,72,95,118,137,141,166,183,199]:
		for faction in [0,1]:
			var report: Dictionary = play(heroic_model(number,faction),faction,number,1000.0)
			var replay: Dictionary = Replay.verify(report)
			check(replay.ok,"Mission héroïque %d, faction %d : rapport rejouable : %s" % [number,faction,str(replay.get("error",""))])
			check(int(report.get("heroic_bonus_chapter",0)) == (number-1)/10+1,"Mission héroïque %d : chapitre des bonus héroïques enregistré" % number)
			var heroic: int = 0
			for bonus in report.get("bonuses",[]):
				if int(bonus.index) >= 60: taken[int(bonus.index)] = true;heroic += 1
			check(heroic <= 2,"Mission héroïque %d : deux bonus héroïques au plus" % number)
			if report.get("bonuses",[]).size() == 6: six += 1
	check(taken.size() >= 6 and six >= 4,"Plusieurs bonus héroïques pris, et des parties à six bonus (%s ; %d)" % [str(taken.keys()),six])
	for number in [58,141,183]:
		var coarse: Dictionary = play(heroic_model(number,0),0,number,300.0)
		var fine: Dictionary = play(heroic_model(number,0),0,number,0.05)
		check(Replay._difference(coarse,fine,"rapport").is_empty(),"Mission héroïque %d : même partie à petits et grands pas, bonus héroïques compris" % number)
	var sample: Dictionary = play(heroic_model(72,0),0,72,300.0)
	var without: Dictionary = sample.duplicate(true);without.erase("heroic_bonus_chapter")
	check(not Replay.verify(without).ok,"Retirer le chapitre des bonus héroïques rend le rapport incohérent")
	var older: Dictionary = sample.duplicate(true);older.game_version = "0.259"
	check(Replay.verify(older).get("error","") == "Bonus héroïques invalides.","Un rapport d'avant la v0.260 ne peut pas porter de bonus héroïques")
	# Rapport de la v0.260 : règle de remplacement et anciennes valeurs, anciens textes.
	var legacy: Dictionary = play(heroic_model(72,0,false),0,72,300.0)
	legacy.game_version = "0.260"
	var legacy_heroic: bool = false
	for bonus in legacy.bonuses:
		if Replay.BONUS_TEXTS_V260.has(int(bonus.index)): bonus.description = Replay.BONUS_TEXTS_V260[int(bonus.index)][0]
		if int(bonus.index) >= 60: legacy_heroic = true
	var legacy_replay: Dictionary = Replay.verify(legacy)
	check(legacy_heroic and legacy_replay.ok,"Un rapport de la v0.260 se rejoue avec ses règles et ses textes : %s" % str(legacy_replay.get("error","")))
	var as_new: Dictionary = legacy.duplicate(true);as_new.game_version = "0.261"
	check(not Replay.verify(as_new).ok,"Le même rapport présenté comme v0.261 est incohérent")

func verify_interface() -> void:
	var game = Main.new();root.add_child(game);game.set_process(false)
	game._choose_faction(0)
	var model = game.model
	model.heroic_bonus_chapter = 20 # partie héroïque simulée (la faction est déjà choisie)
	model.bonuses.assign([0,36,53,59,66,71])
	game.overview_open = true
	game._update_interface()
	var visible: int = 0
	for index in range(6):
		if game.bonus_cards[index].visible: visible += 1
	check(visible == 6 and game.bonus_cards[3].position.y > game.bonus_cards[0].position.y and is_equal_approx(game.bonus_cards[3].position.x,game.bonus_cards[0].position.x),"Six bonus acquis : deux rangées de trois cartes")
	check(game.bonus_cards[5].position.y+game.bonus_cards[5].size.y <= game.bonus_body.size.y and game.bonus_close.visible and game.bonus_close.position.y < game.bonus_cards[0].position.y,"Six bonus : cartes dans le panneau, bouton Fermer en haut")
	check(game.bonus_summary_button.text == "Bonus acquis · 6/6","Compteur des bonus : six en Héroïque")
	game.overview_open = false
	model.phase = "bonus";model.heroic_choice = true;model.bonus_offer.assign([60,64])
	game._update_interface()
	check(game.bonus_title.text == "Choisissez un bonus héroïque" and game.bonus_cards[0].visible and game.bonus_cards[1].visible and not game.bonus_cards[2].visible and game.bonus_rarity_labels[0].text == "Héroïque","Second choix : titre héroïque, deux cartes")
	game.free()

func winner(faction: int, normal: int) -> Profile:
	var profile := Profile.new("")
	for number in range(1,normal+1):
		var id: int = profile.begin_mission(faction,Catalogue.id_for(number),1,10,0)
		profile.credit_mission(id,faction,10,true)
	return profile

func verify_launch() -> void:
	var game = Main.new();root.add_child(game);game.set_process(false)
	game.meta_profile = winner(0,100)
	game._open_campaign(0)
	game.campaign_menu._difficulty(1)
	game.campaign_menu._launch()
	check(not game.choosing_faction and game.model.heroic_bonus_chapter == 1 and game.bonus_summary_button.text == "Bonus acquis · 0/6","Mission héroïque 1 : bonus héroïques du chapitre 1, six bonus possibles")
	game.free()
	var normal = Main.new();root.add_child(normal);normal.set_process(false)
	normal.meta_profile = winner(0,100)
	normal._open_campaign(0,1)
	normal.campaign_menu._launch()
	check(not normal.choosing_faction and normal.model.heroic_bonus_chapter == 0 and normal.bonus_summary_button.text == "Bonus acquis · 0/4","Normal : aucun bonus héroïque, quatre bonus possibles")
	normal.free()
