extends SceneTree
## Bonus rééquilibrés (v0.254, décision du porteur du 24 novembre 2026 : « Tout valider ») : nouvelles valeurs, anciennes valeurs pour le rejeu,
## ralentissement de Chausse-trappes et Temps suspendu au premier tir direct reçu.
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func fresh(faction: int, v254: bool = true) -> Model:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.select_faction(faction);m.gold = 50000;m.rules_v254 = v254
	return m

func stats(faction: int, type: int, codes: Array, v254: bool, level: int = 1) -> Dictionary:
	var m = fresh(faction,v254)
	m.buy(3,type)
	for _i in range(level-1): m.upgrade(3,-1)
	m.bonuses.assign(codes)
	return m.get_stats(3)

func run_checks() -> void:
	for v254 in [true,false]:
		var label: String = "v0.254" if v254 else "avant la v0.254"
		var base: Dictionary = stats(0,0,[],v254)
		check(is_equal_approx(base.interval/stats(0,0,[1],v254).interval,1.08 if v254 else 1.12),"%s : Exercice de tir" % label)
		check(is_equal_approx(stats(0,0,[Model.B_GAMBLE],v254).damage/base.damage,1.20 if v254 else 1.30),"%s : Pari risqué" % label)
		var frenzy: Dictionary = stats(0,0,[Model.B_FRENZY],v254)
		check(is_equal_approx(base.interval/frenzy.interval,1.15 if v254 else 1.25) and is_equal_approx(base.range-frenzy.range,0.5),"%s : Cadence effrénée" % label)
		check(is_equal_approx(stats(0,0,[Model.B_FORTRESS],v254).damage/base.damage,0.95 if v254 else 0.90),"%s : Forteresse blindée" % label)
		check(is_equal_approx(stats(0,0,[Model.B_ELITE],v254).damage/base.damage,0.95 if v254 else 0.90),"%s : Élite sacrifiée au niveau 1" % label)
		var level3: Dictionary = stats(0,0,[],v254,3)
		check(is_equal_approx(stats(0,0,[Model.B_ELITE],v254,3).damage/level3.damage,1.30),"%s : Élite sacrifiée au niveau 3, inchangée" % label)
		var runic: Dictionary = stats(0,0,[Model.B_RUNIC],v254)
		check(is_equal_approx(runic.damage/base.damage,1.12 if v254 else 1.20) and is_equal_approx(base.interval/runic.interval,1.06 if v254 else 1.10),"%s : Lames runiques" % label)
		var shaman: Dictionary = stats(1,5,[],v254)
		var tenacious: Dictionary = stats(1,5,[Model.B_TENACIOUS],v254)
		check(is_equal_approx(tenacious.curse_damage/shaman.curse_damage,2.0 if v254 else 1.0) and is_equal_approx(tenacious.damage,shaman.damage),"%s : Malédiction tenace, dégâts sur la durée" % label)
		var both: Dictionary = stats(1,5,[Model.B_TENACIOUS,Model.B_CURSE],v254)
		check(is_equal_approx(both.curse_damage/shaman.curse_damage,2.35 if v254 else 1.35),"%s : Malédiction tenace et Sortilèges durables s'additionnent" % label)
		var market = fresh(0,v254)
		market.buy(3,0)
		var purchase: int = market.purchase_cost(1)
		var upgrade: int = market.upgrade_cost(3)
		market.bonuses.assign([Model.B_MARKET])
		check(market.purchase_cost(1) == int(ceil(purchase*0.75-0.000000001)) and market.upgrade_cost(3) == int(ceil(upgrade*(1.05 if v254 else 1.15)-0.000000001)),"%s : Marché noir" % label)
	verify_first_hit()
	check(not Replay.rules_v254_for("0.253") and Replay.rules_v254_for("0.254") and Replay.rules_v254_for("0.300"),"Nouvelles valeurs à partir de la v0.254 seulement")
	print("BONUS_VALUES_V254_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

## Chausse-trappes (3 s) et Temps suspendu (8 s) : aucun ralentissement à l'apparition, ralenti au premier tir direct reçu, une seule fois.
func verify_first_hit() -> void:
	for code in [Model.B_CALTROPS,Model.B_STASIS]:
		var m = fresh(0)
		m.buy(3,0)
		m.bonuses.assign([code])
		m.start();m.advance(0.01)
		check(not m.enemies.is_empty() and m.enemies.all(func(x): return not Model.enemy_is_slowed(x)),"R-%d : plus de ralentissement à l'apparition" % (code+1))
		var hit: Dictionary = {}
		for step in range(600):
			m.advance(0.05)
			for enemy in m.enemies:
				if enemy.has("trap_hit"):
					hit = enemy
					break
			if not hit.is_empty() or m.phase != "combat": break
		var seconds: float = Model.STASIS_HIT_SECONDS if code == Model.B_STASIS else Model.CALTROPS_HIT_SECONDS
		check(not hit.is_empty() and Model.enemy_is_slowed(hit) and is_equal_approx(float(hit.slow_until)-float(hit.slow_start),seconds),"R-%d : ralenti %s s au premier tir reçu" % [code+1,str(seconds)])
		if not hit.is_empty():
			var until: float = float(hit.slow_until)
			m._trap_on_first_hit(hit)
			check(is_equal_approx(float(hit.slow_until),until),"R-%d : une seule fois par ennemi" % (code+1))
	var none = fresh(0)
	var enemy: Dictionary = Model.make_enemy(0,1,0.0,0,100)
	none._trap_on_first_hit(enemy)
	check(not enemy.has("trap_hit") and not Model.enemy_is_slowed(enemy),"Sans ces bonus, aucun ralentissement")
	var legacy = fresh(0,false)
	legacy.bonuses.assign([Model.B_CALTROPS])
	var old_enemy: Dictionary = Model.make_enemy(1,1,0.0,0,100)
	legacy._trap_on_first_hit(old_enemy)
	check(not old_enemy.has("trap_hit"),"Avant la v0.254 : pas de ralentissement au premier tir")
	check(is_equal_approx(Model.CALTROPS_HIT_SECONDS,3.0) and is_equal_approx(Model.STASIS_HIT_SECONDS,8.0),"Durées validées : 3 s et 8 s")
