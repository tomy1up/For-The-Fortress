extends SceneTree
## Catalogue étendu à 36 bonus (règles v0.232, décision du porteur, 17 novembre 2026) : effets réels de R-13 à R-36, rétrocompatibilité du tirage et des coûts. Valeurs de prototype à confirmer.
const Model = preload("res://scripts/valley_model.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func fresh(faction: int, aux: int = -1) -> Model:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.rules_v232 = true
	m.configure_auxiliary(aux);m.select_faction(faction);m.gold = 50000
	return m

func stats_with(type: int, faction: int, codes: Array, level: int = 1) -> Dictionary:
	var m = fresh(faction,type if type > 5 else -1)
	m.buy(3,type)
	for _i in range(level-1): m.upgrade(3,-1 if level < 4 else 0)
	m.bonuses.assign(codes)
	return m.get_stats(3)

func ratio(after: float, before: float) -> float:
	return after/before if before != 0.0 else 1.0

func unit_types(faction: int) -> Array:
	var types: Array = [faction*3,faction*3+1,faction*3+2]
	for card in Shop.for_faction(faction):
		if card.family in [faction*3,faction*3+1,faction*3+2]: types.append(card.type)
	return types

func run_checks() -> void:
	var data = Model.Campaign
	check(data.BONUSES.size() == 36 and data.LEGACY_BONUS_COUNT == 12,"Le catalogue compte 36 bonus dont les 12 historiques")
	for index in range(36):
		var entry: Dictionary = data.BONUSES[index]
		check(entry.code == "R-%02d" % (index+1) and not str(entry.name).is_empty() and not str(entry.description).is_empty(),"Bonus %d : code, nom et description" % (index+1))
		if index >= 12: check(str(entry.get("effect","")) != "" and str(entry.get("scope","")) != "" and str(entry.get("note","")) != "" and entry.get("audience","") in ["all","units","immediate","purchases","upgrades"],"Bonus %d : fiche de carte complète" % (index+1))
	# Tirage : douze bonus historiques d'un côté, 36 de l'autre, trois offres distinctes, sans doublon avec les bonus pris.
	var old = fresh(0)
	old.rules_v232 = false
	var seen_old: Dictionary = {}
	var seen_new: Dictionary = {}
	for round in range(60):
		old.bonuses.clear();old.rng.seed = round
		old._offer_bonus()
		for code in old.bonus_offer: seen_old[code] = true
		check(old.bonus_offer.size() == 3 and old.bonus_offer[0] != old.bonus_offer[1] and old.bonus_offer[1] != old.bonus_offer[2] and old.bonus_offer[0] != old.bonus_offer[2],"Anciennes règles : trois offres distinctes")
		var fresh_model = fresh(1)
		fresh_model.rng.seed = round
		fresh_model.bonuses.assign([12,35])
		fresh_model._offer_bonus()
		for code in fresh_model.bonus_offer:
			seen_new[code] = true
			check(code != 12 and code != 35,"Un bonus déjà pris n'est plus proposé")
	var legacy_only: bool = true
	for code in seen_old: if code >= 12: legacy_only = false
	check(legacy_only and seen_old.size() == 12,"Anciennes règles : seuls les 12 bonus historiques sont tirés (%d vus)" % seen_old.size())
	var reached_new: bool = false
	for code in seen_new: if code >= 12: reached_new = true
	check(reached_new and seen_new.size() >= 28,"Nouvelles règles : les bonus R-13 à R-36 sont tirés (%d vus)" % seen_new.size())

	for faction in range(2):
		for type in unit_types(faction):
			var name: String = Model.ROSTER[type].name
			var ref: Dictionary = Model.ROSTER[type]
			var base: Dictionary = stats_with(type,faction,[])
			var interval: float = float(ref.interval)
			var range_base: float = float(ref.range)
			# R-13 / R-14 : tir rapide (≤ 1,3 s), tir lent (≥ 2,4 s).
			check(is_equal_approx(ratio(stats_with(type,faction,[12]).damage,base.damage),1.25 if interval <= 1.3 else 1.0),"R-13 : +25 %% au tir rapide (%s)" % name)
			check(is_equal_approx(ratio(stats_with(type,faction,[13]).damage,base.damage),1.25 if interval >= 2.4 else 1.0),"R-14 : +25 %% au tir lent (%s)" % name)
			# R-15 : +1 cible secondaire seulement pour les unités à zone ou rebonds.
			check(int(stats_with(type,faction,[14]).secondary_cap) == int(base.secondary_cap)+(1 if int(base.secondary_cap) > 0 else 0),"R-15 : +1 cible secondaire (%s)" % name)
			# R-16 : malédictions +35 %.
			var r16: Dictionary = stats_with(type,faction,[15])
			check(is_equal_approx(ratio(r16.curse_damage,base.curse_damage),1.35 if float(base.curse_damage) > 0.0 else 1.0) and is_equal_approx(r16.damage,base.damage),"R-16 : malédiction +35 %% (%s)" % name)
			# R-17 / R-18 : longue portée (≥ 4,5), courte portée (≤ 3,6).
			check(is_equal_approx(ratio(stats_with(type,faction,[16]).damage,base.damage),1.20 if range_base >= 4.5 else 1.0),"R-17 : +20 %% longue portée (%s)" % name)
			check(is_equal_approx(ratio(stats_with(type,faction,[17]).damage,base.damage),1.25 if range_base <= 3.6 else 1.0),"R-18 : +25 %% courte portée (%s)" % name)
			# R-19 : soutiens +30 %.
			var r19: Dictionary = stats_with(type,faction,[18])
			for key in ["mark_bonus","loot_bonus","volatile_damage","slow_seconds"]:
				if base.has(key): check(is_equal_approx(float(r19[key]),float(base[key])*1.3),"R-19 : %s +30 %% (%s)" % [key,name])
			check(is_equal_approx(r19.damage,base.damage),"R-19 : dégâts directs inchangés (%s)" % name)
			# R-20 : +30 % ; R-21 : cadence +25 % et portée −0,5 ; R-22 : portée +1 et dégâts −10 % ; R-24 : dégâts −10 %.
			check(is_equal_approx(ratio(stats_with(type,faction,[19]).damage,base.damage),1.30),"R-20 : +30 %% (%s)" % name)
			var r21: Dictionary = stats_with(type,faction,[20])
			check(is_equal_approx(ratio(base.interval,r21.interval),1.25) and is_equal_approx(base.range-r21.range,0.5),"R-21 : cadence +25 %% et portée −0,5 (%s)" % name)
			var r22: Dictionary = stats_with(type,faction,[21])
			check(is_equal_approx(r22.range-base.range,1.0) and is_equal_approx(ratio(r22.damage,base.damage),0.9),"R-22 : portée +1 et dégâts −10 %% (%s)" % name)
			check(is_equal_approx(ratio(stats_with(type,faction,[23]).damage,base.damage),0.9),"R-24 : dégâts −10 %% (%s)" % name)
			# R-25 : élite sacrifiée (niveau 1-2 : −10 %, niveau 3-4 : +30 %).
			for level in [1,3]:
				var level_base: Dictionary = stats_with(type,faction,[],level)
				check(is_equal_approx(ratio(stats_with(type,faction,[24],level).damage,level_base.damage),1.3 if level >= 3 else 0.9),"R-25 : niveau %d (%s)" % [level,name])
			# R-28 : armée variée (un seul type : +5 %).
			check(is_equal_approx(ratio(stats_with(type,faction,[27]).damage,base.damage),1.05),"R-28 : +5 %% pour un seul type (%s)" % name)
			# R-33 : moral montant, +2 % par vague déjà jouée.
			var morale = fresh(faction,type if type > 5 else -1)
			morale.buy(3,type)
			var without_1: float = morale.get_stats(3).direct_bonus
			morale.bonuses.assign([32])
			check(is_equal_approx(morale.get_stats(3).direct_bonus-without_1,0.0),"R-33 : aucun gain à la première vague (%s)" % name)
			morale.wave = 5
			var with_5: float = morale.get_stats(3).direct_bonus
			morale.bonuses.clear()
			check(is_equal_approx(with_5-morale.get_stats(3).direct_bonus,0.08),"R-33 : +8 %% à la vague 5 (%s)" % name)

	# Position des défenseurs : formation serrée (≤ 3,0), francs-tireurs (> 4,2), armée variée.
	var m = fresh(0)
	m.slots[1] = m.slots[0]+Vector2(2.5,0.0) # Deux emplacements voisins à 2,5 (la carte d'essai n'en a pas à 3,0 ou moins).
	var near_pair: Array = [0,1]
	# Les synergies de proximité s'ajoutent aux gains : on compare donc le gain direct (`direct_bonus`) avec et sans le bonus.
	m.buy(near_pair[0],0)
	m.buy(near_pair[1],1)
	var gain_without: float = m.get_stats(near_pair[0]).direct_bonus
	m.bonuses.assign([25])
	check(is_equal_approx(m.get_stats(near_pair[0]).direct_bonus-gain_without,0.15),"R-26 : +15 %% avec un voisin à 3,0 ou moins")
	m.bonuses.assign([26])
	check(is_equal_approx(m.get_stats(near_pair[0]).direct_bonus-gain_without,0.0),"R-27 : aucun bonus avec un voisin proche")
	m.bonuses.assign([27])
	check(is_equal_approx(m.get_stats(near_pair[0]).direct_bonus-gain_without,0.10),"R-28 : +10 %% avec deux types différents")
	var lonely = fresh(0)
	lonely.buy(0,0)
	var before_lone: Dictionary = lonely.get_stats(0)
	lonely.bonuses.assign([26])
	var after_lone: Dictionary = lonely.get_stats(0)
	check(is_equal_approx(ratio(after_lone.damage,before_lone.damage),1.25) and is_equal_approx(after_lone.range-before_lone.range,0.5),"R-27 : +25 %% et portée +0,5 pour un défenseur isolé")
	lonely.bonuses.assign([25])
	check(is_equal_approx(lonely.get_stats(0).damage,before_lone.damage),"R-26 : aucun bonus sans voisin")

	# Bonus qui dépendent de la cible.
	var t = fresh(0)
	t.buy(3,0)
	var s: Dictionary = t.get_stats(3)
	var length: float = t.path_length
	var middle: Dictionary = {"type":1,"hp":40.0,"max_hp":40.0,"distance":length*0.5}
	var near_exit: Dictionary = {"type":1,"hp":40.0,"max_hp":40.0,"distance":length*0.8}
	var near_entry: Dictionary = {"type":1,"hp":40.0,"max_hp":40.0,"distance":length*0.2}
	var hurt: Dictionary = {"type":3,"hp":10.0,"max_hp":120.0,"distance":length*0.5}
	var plain: float = t._damage_with_bonuses(s,"direct",middle,[])
	check(is_equal_approx(t._damage_with_bonuses(s,"direct",near_exit,[28])/plain,1.25) and is_equal_approx(t._damage_with_bonuses(s,"direct",middle,[28])/plain,1.0) and is_equal_approx(t._damage_with_bonuses(s,"direct",near_entry,[28])/plain,1.0),"R-29 : +25 %% au-delà de 65 %% du trajet seulement")
	check(is_equal_approx(t._damage_with_bonuses(s,"direct",near_entry,[29])/plain,1.25) and is_equal_approx(t._damage_with_bonuses(s,"direct",middle,[29])/plain,1.0) and is_equal_approx(t._damage_with_bonuses(s,"direct",near_exit,[29])/plain,1.0),"R-30 : +25 %% en deçà de 35 %% du trajet seulement")
	check(is_equal_approx(t._damage_with_bonuses(s,"direct",middle,[30])/plain,1.25) and is_equal_approx(t._damage_with_bonuses(s,"secondary",middle,[30]),t._damage_with_bonuses(s,"secondary",middle,[])) and is_equal_approx(t._damage_with_bonuses(s,"direct",{"type":1,"hp":39.0,"max_hp":40.0,"distance":length*0.5},[30]),t._damage_with_bonuses(s,"direct",{"type":1,"hp":39.0,"max_hp":40.0,"distance":length*0.5},[])),"R-31 : +25 %% sur les ennemis intacts, tir direct seulement")
	check(is_equal_approx(t._damage_with_bonuses(s,"direct",hurt,[31])/t._damage_with_bonuses(s,"direct",hurt,[]),1.30) and is_equal_approx(t._damage_with_bonuses(s,"direct",{"type":3,"hp":60.0,"max_hp":120.0,"distance":length*0.5},[31]),t._damage_with_bonuses(s,"direct",{"type":3,"hp":60.0,"max_hp":120.0,"distance":length*0.5},[])),"R-32 : +30 %% sous la moitié des PV (seuil exclu)")
	for kind in range(12):
		var victim: Dictionary = {"type":kind,"hp":40.0,"max_hp":40.0,"distance":length*0.5}
		var fast: bool = kind in Model.FAST_ENEMY_TYPES
		var small: bool = kind in Model.SMALL_ENEMY_TYPES
		var reference: float = t._damage_with_bonuses(s,"direct",victim,[])
		check(is_equal_approx(t._damage_with_bonuses(s,"direct",victim,[33])/reference,1.30 if fast else 1.0),"R-34 : +30 %% contre le type %d (rapide : %s)" % [kind,str(fast)])
		check(is_equal_approx(t._damage_with_bonuses(s,"direct",victim,[34])/reference,1.25 if small else 1.0),"R-35 : +25 %% contre le type %d (petit : %s)" % [kind,str(small)])
	# Cible factice de l'aperçu : aucune position ni PV, aucun gain conditionnel.
	check(is_equal_approx(t._damage_with_bonuses(s,"direct",{"type":7},[28,29,30,31]),t._damage_with_bonuses(s,"direct",{"type":7},[])),"Cible factice de l'aperçu : aucun gain conditionnel")

	# Économie et forteresse : R-20, R-23, R-24, R-36.
	var e = fresh(0)
	e.buy(3,0)
	var purchase: int = e.purchase_cost(1)
	var upgrade: int = e.upgrade_cost(3)
	var hp: int = e.fortress_hp
	var max_before: int = e.max_hp
	e.phase = "bonus";e.bonus_offer.assign([19,22,23])
	check(e.choose_bonus(19) and e.max_hp == max_before-4 and e.fortress_hp == hp-4,"R-20 : −4 PV maximum et actuels")
	e.phase = "bonus";e.bonus_offer.assign([23,22,19])
	check(e.choose_bonus(23) and e.max_hp == max_before+4 and e.fortress_hp == hp+4,"R-24 : +8 PV après −4")
	e.bonuses.assign([22])
	check(e.purchase_cost(1) == int(ceil(purchase*0.75-0.000000001)) and e.upgrade_cost(3) == int(ceil(upgrade*1.15-0.000000001)),"R-23 : achats −25 %% (%d → %d), améliorations +15 %% (%d → %d)" % [purchase,e.purchase_cost(1),upgrade,e.upgrade_cost(3)])
	e.bonuses.assign([22,9,10])
	check(e.purchase_cost(1) == int(ceil(purchase*0.9*0.75-0.000000001)) and e.upgrade_cost(3) == int(ceil(upgrade*0.9*1.15-0.000000001)),"R-23 se cumule avec R-10 et R-11")
	var weak = fresh(0)
	weak.fortress_hp = 3
	weak.phase = "bonus";weak.bonus_offer.assign([19,0,1])
	check(weak.choose_bonus(19) and weak.fortress_hp == 1,"R-20 : les PV actuels ne tombent jamais sous 1")
	var preview: Dictionary = fresh(0).bonus_preview(23)
	check(preview.hp_after == preview.hp_before+8 and preview.max_after == preview.max_before+8,"Aperçu de R-24 : +8 PV")
	for reward in [1,3,6,14]:
		var gold = fresh(0)
		gold.bonuses.assign([35])
		var enemy: Dictionary = {"id":1,"type":1,"hp":0.0,"max_hp":40.0,"reward":reward,"distance":1.0,"speed":1.0}
		var gold_before: int = gold.gold
		var survivors: Array[Dictionary] = []
		var blasts: Array[Dictionary] = []
		gold._settle_enemy(enemy,survivors,blasts)
		check(gold.gold-gold_before == roundi(float(reward)*1.25),"R-36 : %d or → %d or" % [reward,gold.gold-gold_before])
	# Rythme des choix : après les vagues 2, 4, 6 et 8 (règles v0.232), 3, 6 et 9 avant.
	for rules in [true,false]:
		var rhythm: Array = []
		for wave in range(1,11):
			var r = fresh(0)
			r.rules_v232 = rules
			r.wave = wave;r.phase = "combat";r.spawn_schedule.clear();r.spawned = 0;r.enemies.clear()
			r._resolve_instant()
			if r.phase == "bonus": rhythm.append(wave)
		check(rhythm == ([2,4,6,8] if rules else [3,6,9]),"Vagues de choix %s : %s" % [str(rules),str(rhythm)])
	print("BONUS_CATALOGUE_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
