extends SceneTree
## Cohérence entre la description de chaque bonus de partie (R-01 à R-12) et ses effets réels sur les unités (audit demandé par le porteur, 16 novembre 2026).
const Model = preload("res://scripts/valley_model.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func stats_with(type: int, faction: int, bonus_codes: Array, level: int = 1) -> Dictionary:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.configure_auxiliary(type);m.select_faction(faction);m.gold = 50000
	m.buy(3,type)
	for _i in range(level-1): m.upgrade(3,-1 if level < 4 else 0)
	m.bonuses.assign(bonus_codes)
	return m.get_stats(3)

func ratio(after: float, before: float) -> float:
	return after/before if before != 0.0 else 1.0

func run_checks() -> void:
	for faction in range(2):
		var types: Array = [faction*3,faction*3+1,faction*3+2]
		for card in Shop.for_faction(faction):
			if card.family in [faction*3,faction*3+1,faction*3+2]: types.append(card.type)
		for type in types:
			var name: String = Model.ROSTER[type].name
			var base: Dictionary = stats_with(type,faction,[])
			var family: int = Model.family(type)
			# R-01 : +10 % à tous les dégâts, directs, secondaires et périodiques.
			var r1: Dictionary = stats_with(type,faction,[0])
			check(is_equal_approx(ratio(r1.damage,base.damage),1.10) and (base.secondary_damage == 0.0 or is_equal_approx(ratio(r1.secondary_damage,base.secondary_damage),1.10)) and (base.curse_damage == 0.0 or is_equal_approx(ratio(r1.curse_damage,base.curse_damage),1.10)),"R-01 : +10 %% à tous les dégâts (%s)" % name)
			# R-02 : +12 % de fréquence d'attaque, hors chaman et ses alternatives.
			var r2: Dictionary = stats_with(type,faction,[1])
			check(is_equal_approx(ratio(base.interval,r2.interval),1.0 if family == 5 and type < 6 else 1.12),"R-02 : fréquence +12 %% (%s)" % name)
			# R-03 : portée +0,5.
			check(is_equal_approx(stats_with(type,faction,[2]).range-base.range,0.5),"R-03 : portée +0,5 (%s)" % name)
			# R-04 : +20 % aux dégâts des explosions et des rebonds ; R-05 : +0,2 au rayon.
			var r4: Dictionary = stats_with(type,faction,[3])
			check(is_equal_approx(ratio(r4.secondary_damage,base.secondary_damage),1.20 if family in [2,3,4] and float(base.secondary_damage) > 0.0 else 1.0) and is_equal_approx(r4.damage,base.damage),"R-04 : +20 %% aux dégâts secondaires seulement (%s)" % name)
			check(is_equal_approx(stats_with(type,faction,[4]).radius-base.radius,0.2 if family in [2,3,4] else 0.0),"R-05 : rayon +0,2 pour les unités à zone ou rebonds (%s)" % name)
			# R-06 : +15 % aux dégâts directs seulement.
			var r6: Dictionary = stats_with(type,faction,[5])
			check(is_equal_approx(ratio(r6.damage,base.damage),1.15) and is_equal_approx(r6.secondary_damage,base.secondary_damage) and is_equal_approx(r6.curse_damage,base.curse_damage),"R-06 : +15 %% au direct seulement (%s)" % name)
			# R-07 : +15 % niveaux 1 et 2, cesse au niveau 3 ; R-08 : +12 % niveau 3 ou spécialisé.
			var level2: Dictionary = stats_with(type,faction,[],2)
			check(is_equal_approx(ratio(stats_with(type,faction,[6],2).damage,level2.damage),1.15),"R-07 : +15 %% au niveau 2 (%s)" % name)
			var level3: Dictionary = stats_with(type,faction,[],3)
			check(is_equal_approx(ratio(stats_with(type,faction,[6],3).damage,level3.damage),1.0) and is_equal_approx(ratio(stats_with(type,faction,[7],3).damage,level3.damage),1.12) and is_equal_approx(ratio(stats_with(type,faction,[7],2).damage,level2.damage),1.0),"R-07/R-08 : bascule au niveau 3 (%s)" % name)
	# R-09 à R-12 : forteresse, coûts, dégâts contre les gros ennemis.
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.select_faction(0);m.gold = 50000
	m.buy(3,0)
	var hp_before: int = m.fortress_hp
	var max_before: int = m.max_hp
	var upgrade_before: int = m.upgrade_cost(3)
	var purchase_before: int = m.purchase_cost(0)
	m.phase = "bonus";m.bonus_offer.assign([8,9,10])
	check(m.choose_bonus(8) and m.max_hp == max_before+4 and m.fortress_hp == hp_before+4,"R-09 : +4 PV actuels et maximum de forteresse")
	m.bonuses.assign([9])
	check(m.upgrade_cost(3) == int(ceil(upgrade_before*0.9)),"R-10 : améliorations −10 %% (%d → %d)" % [upgrade_before,m.upgrade_cost(3)])
	m.bonuses.assign([10])
	check(m.purchase_cost(0) == int(ceil(purchase_before*0.9)),"R-11 : achats −10 %% (%d → %d)" % [purchase_before,m.purchase_cost(0)])
	m.bonuses.clear()
	var s: Dictionary = m.get_stats(3)
	var heavy_types: Array = [3,5,6,7]
	var light_types: Array = [0,1,2,4]
	var normal: float = m._damage_with_bonuses(s,"direct",{"type":1,"hp":40.0,"max_hp":40.0},[])
	for type in heavy_types:
		check(is_equal_approx(m._damage_with_bonuses(s,"direct",{"type":type,"hp":10.0,"max_hp":10.0},[11])/m._damage_with_bonuses(s,"direct",{"type":type,"hp":10.0,"max_hp":10.0},[]),1.20),"R-12 : +20 %% contre l'ennemi lourd de type %d" % type)
	for type in light_types:
		check(is_equal_approx(m._damage_with_bonuses(s,"direct",{"type":type,"hp":10.0,"max_hp":10.0},[11]),m._damage_with_bonuses(s,"direct",{"type":type,"hp":10.0,"max_hp":10.0},[])),"R-12 : aucun bonus contre l'ennemi léger de type %d" % type)
	print("BONUS_EFFECTS_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
