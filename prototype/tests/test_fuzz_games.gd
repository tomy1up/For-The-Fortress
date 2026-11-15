extends SceneTree
## Parties complètes aléatoires mais reproductibles (graine fixe) : missions, factions, unités de boutique, achats, améliorations, reventes,
## pas de temps et bonus tirés au hasard. Aucune erreur ni invariant rompu ne doit apparaître, et chaque rapport doit se rejouer exactement.
## Complète les tests de scénarios fixes : elle explore des enchaînements que personne n'a écrits à la main.
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const GAMES := 120
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func invariants(m: Model, label: String) -> void:
	check(m.gold >= 0,"%s : or jamais négatif" % label)
	check(m.fortress_hp <= m.max_hp,"%s : PV de forteresse dans la limite" % label)
	check(m.defenders.size() == m.slots.size(),"%s : un défenseur (ou vide) par emplacement" % label)
	for enemy in m.enemies: check(float(enemy.hp) > 0.0 and is_finite(float(enemy.hp)),"%s : aucun ennemi vivant sans PV" % label)

func play_game(index: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1000+index
	var mission: int = rng.randi_range(1,Catalogue.TOTAL_MISSIONS)
	var faction: int = rng.randi_range(0,1)
	var definition: Dictionary = Catalogue.definition(mission)
	var label := "Partie %d (mission %d, faction %d)" % [index,mission,faction]
	var m = Model.new(true,Model.Maps.for_id(definition.map_id))
	var ok: bool = m.configure_wave_set(definition.get("wave_set_id","ford")) and m.configure_enemy_hp(Catalogue.faction_hp_percent(mission,faction)) and m.configure_combat_affix(definition.get("combat_affix",{}))
	var auxiliary := -1
	var cards: Array = Shop.for_faction(faction).filter(func(card): return int(card.type) >= 10)
	if rng.randf() < 0.6 and not cards.is_empty():
		auxiliary = int(cards[rng.randi_range(0,cards.size()-1)].type)
		ok = ok and m.configure_auxiliary(auxiliary)
	ok = ok and m.select_faction(faction)
	check(ok,"%s : configuration acceptée" % label)
	if not ok: return
	m.rng.seed = rng.randi()
	var types: Array = [faction*3,faction*3+1,faction*3+2]
	if auxiliary >= 0: types.append(auxiliary)
	var slot_count: int = m.slots.size()
	for wave in range(1,11):
		for _action in range(rng.randi_range(0,6)):
			var slot: int = rng.randi_range(0,slot_count-1)
			var roll: float = rng.randf()
			if roll < 0.5: m.buy(slot,types[rng.randi_range(0,types.size()-1)])
			elif roll < 0.85: m.upgrade(slot,rng.randi_range(-1,1))
			else: m.sell(slot)
			invariants(m,label)
		if not m.start(): break
		var step: float = [0.05,0.5,300.0][rng.randi_range(0,2)]
		var guard := 0
		while m.active and guard < 200000:
			m.advance(step)
			guard += 1
		check(guard < 200000,"%s : la vague %d se termine" % [label,wave])
		invariants(m,label)
		if m.phase == "defeat": break
		if m.phase == "bonus": check(m.choose_bonus(m.bonus_offer[rng.randi_range(0,m.bonus_offer.size()-1)]),"%s : bonus accepté" % label)
		if wave < 10: check(m.prepare_next_wave(),"%s : préparation acceptée" % label)
	check(m.phase in ["victory","defeat","preparation","bonus"],"%s : phase finale valide (%s)" % [label,m.phase])
	var paid: int = 0
	for action in m.action_history:
		if action.kind in ["buy","upgrade"]: paid += int(action.cost)
		elif action.kind == "sell": paid -= int(action.received)
	check(m.gold == Model.INITIAL_GOLD+m.total_income-paid,"%s : conservation de l’or (%d contre %d)" % [label,m.gold,Model.INITIAL_GOLD+m.total_income-paid])
	if m.phase in ["victory","defeat"]:
		var verified: Dictionary = Replay.verify(JSON.parse_string(JSON.stringify(Report.build(m))))
		check(verified.ok,"%s : le rapport se rejoue exactement (%s)" % [label,verified.get("error","")])

func run_checks() -> void:
	for index in range(GAMES): play_game(index)
	print("FUZZ_GAMES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
