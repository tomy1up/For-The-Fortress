extends SceneTree
## Second lot du catalogue (règles v0.233, décision du porteur, 21 novembre 2026) : rareté des offres (commun, rare, épique ; plus de rares en fin de partie),
## une relance gratuite par partie (trois offres remplacées), effets des bonus rares et épiques R-37 à R-60, rétrocompatibilité et rejeu. Valeurs de prototype à confirmer.
const Model = preload("res://scripts/valley_model.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func fresh(faction: int, aux: int = -1) -> Model:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.configure_auxiliary(aux);m.select_faction(faction);m.gold = 50000
	return m

func stats_with(type: int, faction: int, codes: Array, level: int = 1) -> Dictionary:
	var m = fresh(faction,type if type > 5 else -1)
	m.buy(3,type)
	for _i in range(level-1): m.upgrade(3,-1 if level < 4 else 0)
	m.bonuses.assign(codes)
	return m.get_stats(3)

func unit_types(faction: int) -> Array:
	var types: Array = [faction*3,faction*3+1,faction*3+2]
	for card in Shop.for_faction(faction): types.append(card.type)
	return types

## Ennemi fabriqué au milieu du gué, pour les règles de dégâts et d'élimination.
func enemy(m: Model, id: int, type: int) -> Dictionary:
	var e: Dictionary = Model.make_enemy(id,type,0.0,m.faction,100)
	e.distance = 2.0
	return e

func run_checks() -> void:
	var data = Model.Campaign
	# 1. Raretés : les 36 premiers sont communs, R-37 à R-52 rares, R-53 à R-60 épiques.
	var counts: Dictionary = {"common":0,"rare":0,"epic":0}
	for code in range(data.BONUSES.size()):
		var rarity: String = data.bonus_rarity(code)
		counts[rarity] = counts.get(rarity,0)+1
		check(rarity == ("common" if code < 36 else "rare" if code < 52 else "epic" if code < 60 else "heroic"),"Bonus %d : rareté %s" % [code+1,rarity])
	check(counts.common == 36 and counts.rare == 16 and counts.epic == 8 and counts.get("heroic",0) == 15,"36 communs, 16 rares, 8 épiques et 15 héroïques (v0.260)")
	var average: Array = [0.0,0.0,0.0]
	for weights in data.RARITY_WEIGHTS:
		check(int(weights[0])+int(weights[1])+int(weights[2]) == 100,"Pondérations de rareté sur 100")
		for tier in range(3): average[tier] += float(weights[tier])/float(data.RARITY_WEIGHTS.size())
	check(absf(average[0]-70.0) <= 3.0 and absf(average[1]-25.0) <= 2.0 and absf(average[2]-5.0) <= 1.5,"Moyenne proche de 70 / 25 / 5 (%s)" % str(average))
	check(int(data.RARITY_WEIGHTS[3][1]) > int(data.RARITY_WEIGHTS[0][1]) and int(data.RARITY_WEIGHTS[3][2]) > int(data.RARITY_WEIGHTS[0][2]),"Rares et épiques plus fréquents en fin de partie")

	# 2. Tirage par rareté, selon le rang du choix : fréquences proches des pondérations, trois offres distinctes, jamais un bonus déjà pris.
	var m = fresh(0)
	for rank in range(4):
		m.wave = m.bonus_waves()[rank]
		var seen: Array = [0,0,0]
		var distinct: bool = true
		for round in range(1500):
			m.bonuses.assign([36,52] if round%2 == 0 else [])
			m.rng.seed = round*7+rank
			var offer: Array[int] = m._draw_offers([])
			distinct = distinct and offer.size() == 3 and offer[0] != offer[1] and offer[1] != offer[2] and offer[0] != offer[2] and not (36 in offer and round%2 == 0) and not (52 in offer and round%2 == 0)
			for code in offer: seen[data.RARITIES.find(data.bonus_rarity(code))] += 1
		check(distinct,"Rang %d : trois offres distinctes, sans bonus déjà pris" % (rank+1))
		for tier in range(3):
			var share: float = 100.0*float(seen[tier])/4500.0
			check(absf(share-float(data.RARITY_WEIGHTS[rank][tier])) <= 3.0,"Rang %d, rareté %s : %.1f %% pour %d %% attendus" % [rank+1,data.RARITIES[tier],share,int(data.RARITY_WEIGHTS[rank][tier])])
	# Anciennes règles : tirage uniforme parmi 36 (v0.232) ou 12 (avant), jamais de rare ni d'épique.
	for legacy in [[true,false,36],[false,false,12],[false,true,12]]:
		var old = fresh(1)
		old.rules_v232 = legacy[0];old.rules_v233 = legacy[1]
		var highest: int = -1
		for round in range(300):
			old.rng.seed = round;old.bonuses.clear()
			for code in old._draw_offers([]): highest = maxi(highest,code)
		check(highest < int(legacy[2]),"Règles v0.232=%s v0.233=%s : rien au-delà du bonus %d" % [str(legacy[0]),str(legacy[1]),int(legacy[2])])

	# 3. Relance : une seule par partie, gratuite, remplace les trois offres par trois autres ; impossible sous les anciennes règles.
	var r = fresh(0)
	r.gold = 150
	r.wave = 2;r.rng.seed = 11
	r._offer_bonus()
	var previous: Array[int] = r.bonus_offer.duplicate()
	check(r.phase == "bonus" and r.rerolls_available() == 1,"Une relance disponible au premier choix")
	check(r.reroll_bonus(),"Relance acceptée")
	check(r.bonus_offer.size() == 3 and not r.bonus_offer.any(func(code): return code in previous),"Trois nouvelles offres, différentes des précédentes")
	check(r.gold == 150 and r.rerolls_available() == 0 and r.phase == "bonus","Relance gratuite, une seule, le choix reste à faire")
	var last: Dictionary = r.action_history[-1]
	check(last.kind == "bonus_reroll" and last.previous == previous and last.offered == r.bonus_offer,"Relance inscrite au journal avec les offres remplacées et les nouvelles")
	check(not r.reroll_bonus(),"Seconde relance refusée")
	check(not r.choose_bonus(previous[0]) and r.choose_bonus(r.bonus_offer[0]),"Seules les nouvelles offres peuvent être choisies")
	check(not r.reroll_bonus(),"Pas de relance hors du choix")
	var legacy_reroll = fresh(0)
	legacy_reroll.rules_v233 = false
	legacy_reroll._offer_bonus()
	check(legacy_reroll.rerolls_available() == 0 and not legacy_reroll.reroll_bonus(),"Anciennes règles : aucune relance")
	r.reset()
	check(r.rerolls_left == Model.REROLLS_PER_RUN and not r.last_stand_used and r.gate_wave == -1,"Nouvelle partie : relance et effets uniques rétablis")

	# 4. Effets des rares et épiques sur les défenseurs.
	for faction in range(2):
		for type in unit_types(faction):
			var name: String = Model.ROSTER[type].name
			var ref: Dictionary = Model.ROSTER[type]
			var base: Dictionary = stats_with(type,faction,[])
			var group: bool = int(ref.get("secondary_cap",0)) > 0
			var runic: Dictionary = stats_with(type,faction,[Model.B_RUNIC])
			check(is_equal_approx(runic.damage/base.damage,1.12) and is_equal_approx(base.interval/runic.interval,1.06),"R-37 : +12 %% et cadence +6 %% (%s)" % name)
			var echo: Dictionary = stats_with(type,faction,[Model.B_ECHO])
			check(int(echo.secondary_cap) == int(base.secondary_cap)+(2 if int(base.secondary_cap) > 0 else 0),"R-38 : +2 cibles secondaires (%s)" % name)
			if group and float(base.secondary_damage) > 0.0: check(is_equal_approx(echo.secondary_damage/base.secondary_damage,1.25) and is_equal_approx(echo.damage,base.damage),"R-38 : secondaires +25 %%, tir direct inchangé (%s)" % name)
			var cover: Dictionary = stats_with(type,faction,[Model.B_COVER])
			var far: bool = float(ref.range) >= 4.5
			check(is_equal_approx(cover.damage/base.damage,1.15 if far else 1.0) and is_equal_approx(cover.range-base.range,1.0 if far else 0.0),"R-48 : longue portée +15 %% et +1 (%s)" % name)
			var elite: Dictionary = stats_with(type,faction,[Model.B_ELITEARMY])
			check(is_equal_approx(elite.damage/base.damage,1.35) and is_equal_approx(base.interval/elite.interval,1.20),"R-54 : +35 %% et cadence +20 %% (%s)" % name)
			var storm: Dictionary = stats_with(type,faction,[Model.B_FIRESTORM])
			if int(base.secondary_cap) > 0: check(int(storm.secondary_cap) == int(base.secondary_cap)+2 and is_equal_approx(storm.radius-base.radius,0.5),"R-58 : +2 cibles et rayon +0,5 (%s)" % name)
			else: check(int(storm.secondary_cap) == 0 and is_equal_approx(storm.radius,base.radius),"R-58 : sans effet sans zone (%s)" % name)
			if group and float(base.secondary_damage) > 0.0: check(is_equal_approx(storm.secondary_damage/base.secondary_damage,1.40),"R-58 : secondaires +40 %% (%s)" % name)
			var both: Dictionary = stats_with(type,faction,[Model.B_ECHO,Model.B_FIRESTORM,14])
			if int(base.secondary_cap) > 0: check(int(both.secondary_cap) == int(base.secondary_cap)+5,"R-15, R-38 et R-58 se cumulent : +5 cibles (%s)" % name)
			if base.has("slow_seconds"): check(is_equal_approx(float(stats_with(type,faction,[Model.B_STASIS]).slow_seconds),float(base.slow_seconds)*1.5),"R-60 : ralentissements +50 %% (%s)" % name)
	# R-49 et R-56 : gains qui suivent l'état de la partie.
	var despair = fresh(0)
	despair.buy(3,0)
	var plain_bonus: float = despair.get_stats(3).direct_bonus
	despair.bonuses.assign([Model.B_DESPAIR])
	despair.fortress_hp = despair.max_hp-5
	check(is_equal_approx(despair.get_stats(3).direct_bonus-plain_bonus,0.15),"R-49 : +3 % par PV perdu (5 PV : +15 %)")
	despair.fortress_hp = 1
	check(is_equal_approx(despair.get_stats(3).direct_bonus-plain_bonus,0.45),"R-49 : plafonné à +45 %")
	despair.bonuses.assign([Model.B_BLOODLUST]);despair.fortress_hp = despair.max_hp
	despair.total_killed = 30
	check(is_equal_approx(despair.get_stats(3).direct_bonus-plain_bonus,0.30),"R-56 : +1 % par élimination (30 : +30 %)")
	despair.total_killed = 140
	check(is_equal_approx(despair.get_stats(3).direct_bonus-plain_bonus,0.50),"R-56 : plafonné à +50 %")

	# 5. Dégâts selon la cible : Tueur de géants.
	var t = fresh(0)
	t.buy(3,0)
	var s: Dictionary = t.get_stats(3)
	for kind in [0,1,3,5,6,7]:
		var heavy: bool = kind in Model.HEAVY_ENEMY_TYPES
		check(is_equal_approx(t._damage_with_bonuses(s,"direct",{"type":kind},[Model.B_GIANTS])/t._damage_with_bonuses(s,"direct",{"type":kind},[]),1.40 if heavy else 1.0),"R-46 : type %d (lourd : %s)" % [kind,str(heavy)])

	# 6. Effets immédiats au choix : or, forteresse, promotions gratuites.
	for code in [Model.B_TREASURE,Model.B_ROYAL,Model.B_BASTION,Model.B_PROMOTION,Model.B_ASCENSION]:
		var c = fresh(1)
		c.gold = 5000 # mise en place : trois défenseurs de niveaux 1, 2 et 3
		c.buy(0,3);c.buy(1,4);c.upgrade(1,-1);c.buy(2,5);c.upgrade(2,-1);c.upgrade(2,-1)
		var paid: Array = [c.defenders[0].paid,c.defenders[1].paid,c.defenders[2].paid]
		c.fortress_hp = 5
		c.phase = "bonus";c.bonus_offer.assign([code,0,1])
		var gold_before: int = c.gold
		var preview: Dictionary = c.bonus_preview(code)
		check(c.choose_bonus(code),"Choix du bonus %d" % (code+1))
		match code:
			Model.B_TREASURE: check(c.gold == gold_before+100 and preview.gold_after == gold_before+100,"R-42 : +100 or (aperçu compris)")
			Model.B_ROYAL: check(c.gold == gold_before+150 and preview.gold_after == gold_before+150,"R-59 : +150 or (aperçu compris)")
			Model.B_BASTION: check(c.max_hp == 32 and c.fortress_hp == 32 and preview.hp_after == 32 and preview.max_after == 32,"R-57 : +12 PV maximum et soin complet (%d/%d)" % [c.fortress_hp,c.max_hp])
			Model.B_PROMOTION: check([c.defenders[0].level,c.defenders[1].level,c.defenders[2].level] == [2,2,3],"R-44 : seul le niveau 1 passe au niveau 2")
			Model.B_ASCENSION: check([c.defenders[0].level,c.defenders[1].level,c.defenders[2].level] == [3,3,3],"R-55 : niveaux 1 et 2 passent au niveau 3")
		check([c.defenders[0].paid,c.defenders[1].paid,c.defenders[2].paid] == paid,"Bonus %d : or payé (et revente) inchangé" % (code+1))
		if code == Model.B_PROMOTION: check(preview.units[0].level_after == 2 and preview.units[1].level_after == 2,"R-44 : l'aperçu montre le niveau promu")
	# Prix : Levée en masse (−30 %), Fortune royale (−20 %), cumul.
	for codes in [[Model.B_LEVY],[Model.B_ROYAL],[Model.B_LEVY,Model.B_ROYAL],[Model.B_LEVY,10,9]]:
		var p = fresh(0)
		p.buy(3,1)
		var purchase: int = p.purchase_cost(2)
		var upgrade: int = p.upgrade_cost(3)
		p.bonuses.assign(codes)
		var factor: float = (0.7 if Model.B_LEVY in codes else 1.0)*(0.8 if Model.B_ROYAL in codes else 1.0)
		check(p.purchase_cost(2) == int(ceil(float(purchase)*factor*(0.9 if 10 in codes else 1.0)-0.000000001)) and p.upgrade_cost(3) == int(ceil(float(upgrade)*factor*(0.9 if 9 in codes else 1.0)-0.000000001)),"Prix avec %s : achat %d → %d, amélioration %d → %d" % [str(codes),purchase,p.purchase_cost(2),upgrade,p.upgrade_cost(3)])

	# 7. Fin de vague : Réparations et Intérêts.
	var w = fresh(0)
	w.bonuses.assign([Model.B_REPAIRS,Model.B_INTEREST])
	w.fortress_hp = w.max_hp-1;w.gold = 100
	var income: int = w.total_income
	w._wave_cleared_bonuses()
	check(w.fortress_hp == w.max_hp and w.gold == 110 and w.total_income == income+10,"R-41 et R-43 : +2 PV plafonnés au maximum, +10 % d'or compté dans les gains")
	w.gold = 1000
	w._wave_cleared_bonuses()
	check(w.gold == 1025,"R-43 : 25 or au plus par vague")

	# 8. Élimination : Exécution et Prime de guerre.
	var e = fresh(0)
	e.phase = "combat"
	e.enemies.assign([enemy(e,1,3),enemy(e,2,7)])
	var hp_heavy: float = e.enemies[0].max_hp
	var hp_boss: float = e.enemies[1].max_hp
	e.bonuses.assign([Model.B_EXECUTE])
	e._apply_damage({1:hp_heavy*0.92,2:hp_boss*0.95})
	check(e.enemies.size() == 1 and e.enemies[0].id == 2 and e.total_killed == 1,"R-45 : achève sous 10 % des PV, jamais le boss")
	var g = fresh(0)
	g.phase = "combat"
	g.enemies.assign([enemy(g,1,0)])
	var reward: int = int(g.enemies[0].reward)
	g.bonuses.assign([Model.B_BOUNTY])
	var gold_g: int = g.gold
	g._apply_damage({1:10000.0})
	check(g.gold-gold_g == reward+2,"R-52 : +2 or par élimination (%d → %d)" % [reward,g.gold-gold_g])

	# 9. Combat réel : ralentissements d'entrée (avant la v0.254 ; depuis, au premier tir reçu : `test_bonus_values_v254.gd`), malédiction tenace, herse, dernier souffle, marque.
	for code in [Model.B_CALTROPS,Model.B_STASIS]:
		var sl = fresh(0)
		sl.rules_v254 = false
		sl.bonuses.assign([code])
		sl.start();sl.advance(0.01)
		check(not sl.enemies.is_empty() and sl.enemies.all(func(x): return Model.enemy_is_slowed(x) and is_equal_approx(float(x.slow_until)-float(x.slow_start),4.0 if code == Model.B_STASIS else 2.0)),"R-%d, règles d'avant la v0.254 : ennemis ralentis dès l'apparition" % (code+1))
	var curse = fresh(1)
	curse.bonuses.assign([Model.B_TENACIOUS])
	curse._apply_curse(1,1,5.0)
	check(curse.curses[-1].ticks_left == 3,"R-39 : trois échéances")
	curse.bonuses.clear();curse._apply_curse(1,2,5.0)
	check(curse.curses[-1].ticks_left == 2,"Sans R-39 : deux échéances")
	var gated = fresh(0)
	var open = fresh(0)
	gated.bonuses.assign([Model.B_GATE])
	for model in [gated,open]:
		model.rng.seed = 5;model.start();model.advance(10000)
	check(gated.escaped == open.escaped and gated.escaped > 0 and gated.fortress_hp == open.fortress_hp+1,"R-47 : le premier passage de la vague ne coûte rien (%d contre %d PV)" % [gated.fortress_hp,open.fortress_hp])
	var stand = fresh(0)
	var fallen = fresh(0)
	stand.bonuses.assign([Model.B_LASTSTAND])
	for model in [stand,fallen]:
		model.fortress_hp = 2;model.rng.seed = 5;model.start();model.advance(10000)
	check(fallen.phase == "defeat" and stand.phase != "defeat" and stand.last_stand_used and stand.fortress_hp > 0,"R-53 : la forteresse évite une défaite (%s, %d PV)" % [stand.phase,stand.fortress_hp])
	var mark = fresh(0)
	mark.buy(3,0);mark.buy(4,0)
	mark.bonuses.assign([Model.B_HUNTMARK])
	mark.start()
	var marked: bool = false
	for _step in range(80):
		mark.advance(0.25)
		if mark.enemies.any(func(x): return float(x.get("marked_until",-1.0)) > mark.elapsed and is_equal_approx(float(x.get("mark_bonus",0.0)),0.10)): marked = true;break
	check(marked,"R-51 : les tirs directs marquent leur cible à +10 %")

	# 10. Partie complète avec relance : rapport rejouable et journal lisible.
	for faction in range(2):
		var game = Model.new(true,Model.Maps.for_id("valley_ford"))
		game.select_faction(faction);game.rng.seed = 21+faction
		var slots: Array = [3,4,2]
		var types: Array = [faction*3,faction*3+1,faction*3+1]
		game.buy(slots[0],types[0]);game.buy(slots[1],types[1])
		var rerolled: bool = false
		for wave in range(1,11):
			if wave == 2: game.upgrade(slots[0])
			if wave >= 2 and game.defenders[slots[2]].is_empty(): game.buy(slots[2],types[2])
			if wave >= 5:
				for slot in slots:
					if not game.defenders[slot].is_empty(): game.upgrade(slot,0 if game.defenders[slot].level == 3 else -1)
			if not game.start(): break
			game.advance(10000)
			if game.phase == "defeat": break
			if game.phase == "bonus":
				if not rerolled: rerolled = game.reroll_bonus()
				game.choose_bonus(Model.reference_bonus(game.bonus_offer))
			if wave < 10: game.prepare_next_wave()
		check(rerolled and game.phase in ["victory","defeat"],"Faction %d : partie jouée avec une relance (%s)" % [faction,game.phase])
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(game)))
		var verdict: Dictionary = Replay.verify(report)
		check(verdict.ok,"Faction %d : rapport avec relance rejouable %s" % [faction,str(verdict.get("error",""))])
		check(Report.markdown(report).contains("Relance, nouvelles offres"),"Faction %d : la relance apparaît dans le journal du rapport" % faction)
	print("BONUS_RARITY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
