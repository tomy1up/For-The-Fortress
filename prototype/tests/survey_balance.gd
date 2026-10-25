extends SceneTree
## Essais automatisés de politiques fixes, pas un joueur optimal ni un test humain.
const Model = preload("res://scripts/valley_model.gd")
const SEEDS: Array[int] = [1,2,3,4,5,6,7,8,9,10,11,42]
const LAYOUTS: Array[Dictionary] = [
	{"id":"triangle","slots":[0,1,2]},
	{"id":"milieu","slots":[1,2,3]},
	{"id":"reparti","slots":[0,1,5]},
	{"id":"aval","slots":[4,5,2]}
]
const PRIORITIES: Dictionary = {
	"degats":[0,5,11,7,6,3,1,2,4,8,9,10],
	"economie":[9,10,8,0,5,11,7,6,1,2,3,4],
	"couverture":[2,4,3,1,0,5,11,8,6,7,9,10]
}
var audit_checks: int = 0
var failures: Array[String] = []

func audit(ok: bool, message: String) -> void:
	audit_checks += 1
	if not ok: failures.append(message)

func _initialize() -> void:
	var results: Array[Dictionary] = []
	for faction in range(2):
		for layout in LAYOUTS:
			for policy in ["reference","renforts","specialisation"]:
				for priority in ["degats","economie","couverture"]:
					for branches in ["A","association"]:
						for seed_value in SEEDS:
							results.append(run_case(faction,layout,policy,priority,branches,seed_value))
	var path: String = "user://balance_v019.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): path = argument.trim_prefix("--output=")
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		push_error("Impossible d'écrire le relevé : "+path)
		quit(1)
		return
	file.store_string(JSON.stringify({"schema":1,"engine":Engine.get_version_info().string,"seeds":SEEDS,"audit_checks":audit_checks,"failures":failures,"runs":results}))
	file.close()
	print("BALANCE_SURVEY runs=%d audit_checks=%d failures=%d output=%s" % [results.size(),audit_checks,failures.size(),path])
	quit(0 if failures.is_empty() else 1)

func branch_for(type: int, selection: String) -> int:
	if selection == "A": return 0
	# Associations prévues pour le couple initial, sans troisième N4 gratuit.
	return 1 if type in [1,3,4] else 0

func try_upgrade(m: RefCounted, slot: int, branches: String) -> void:
	if not m.defenders[slot].is_empty():
		m.upgrade(slot,branch_for(m.defenders[slot].type,branches) if m.defenders[slot].level == 3 else -1)

func prepare(m: RefCounted, slots: Array, policy: String, branches: String) -> void:
	if policy == "reference":
		if m.wave >= 4 and m.defenders[slots[2]].is_empty(): m.buy(slots[2],m.faction*3+2)
		if m.wave >= 5:
			for slot in slots: try_upgrade(m,slot,branches)
	elif policy == "renforts":
		# Recruter le troisième type puis les copies avant toute amélioration.
		if m.defenders[slots[2]].is_empty(): m.buy(slots[2],m.faction*3+2)
		if not m.defenders[slots[2]].is_empty():
			for type in m.available_types():
				if m.count_type(type) >= 2: continue
				for slot in range(6):
					if m.defenders[slot].is_empty():
						m.buy(slot,type)
						break
		var count: int = 0
		for unit in m.defenders:
			if not unit.is_empty(): count += 1
		if count == 6:
			for slot in range(6): try_upgrade(m,slot,branches)
	else:
		# Améliorer autant que possible le premier, puis le second avec le solde.
		for slot in [slots[0],slots[1]]:
			while m.defenders[slot].level < 4:
				var previous: int = m.defenders[slot].level
				try_upgrade(m,slot,branches)
				if m.defenders[slot].level == previous: break

func run_case(faction: int, layout: Dictionary, policy: String, priority: String, branches: String, seed_value: int, observer: Callable = Callable()) -> Dictionary:
	var m = Model.new()
	m.select_faction(faction)
	m.rng.seed = seed_value
	m.buy(layout.slots[0],faction*3)
	m.buy(layout.slots[1],faction*3+1)
	var waves: Array[Dictionary] = []
	var decisions: Array[Dictionary] = []
	var id: String = "%d-%s-%s-%s-%s-%d" % [faction,layout.id,policy,priority,branches,seed_value]
	for wave in range(1,11):
		if wave > 1: prepare(m,layout.slots,policy,branches)
		var paid: int = 0
		var deployed: Array[Dictionary] = []
		var specialised_links: Array[String] = []
		for slot in range(6):
			var unit: Dictionary = m.defenders[slot]
			if unit.is_empty(): continue
			paid += unit.paid
			var stats: Dictionary = m.get_stats(slot)
			for code in stats.synergies:
				if code.begins_with("S-") and code not in specialised_links: specialised_links.append(code)
			deployed.append({"slot":slot+1,"type":unit.type,"level":unit.level,"branch":unit.branch,"paid":unit.paid,"synergies":stats.synergies})
			audit(unit.type in m.available_types() and m.count_type(unit.type) <= 2,id+" faction/quota")
		audit(m.gold == 150+m.total_income-paid and m.gold >= 0,id+" conservation avant vague")
		audit(m.start(),id+" lancement")
		m.advance(300)
		audit(not m.active and m.gold == 150+m.total_income-paid,id+" résolution et conservation")
		waves.append({"wave":wave,"phase":m.phase,"kills":m.killed,"escapes":m.escaped,"hp":m.fortress_hp,"max_hp":m.max_hp,"gold":m.gold,"income":m.total_income,"seconds":m.elapsed,"paid":paid,"deployed":deployed,"specialised_links":specialised_links})
		if observer.is_valid(): observer.call(m,waves[-1])
		if m.phase == "defeat" or m.phase == "victory": break
		if m.phase == "bonus":
			var offer: Array[int] = m.bonus_offer.duplicate()
			var selected: int = -1
			for code in PRIORITIES[priority]:
				if code in offer:
					selected = code
					break
			decisions.append({"wave":wave,"offer":offer,"selected":selected})
			audit(m.choose_bonus(selected),id+" sélection")
		audit(m.prepare_next_wave(),id+" préparation suivante")
	return {"id":id,"faction":faction,"layout":layout.id,"policy":policy,"priority":priority,"branches":branches,"seed":seed_value,"phase":m.phase,"last_wave":m.wave,"hp":m.fortress_hp,"gold":m.gold,"income":m.total_income,"kills":m.total_killed,"escapes":m.total_escaped,"combat_seconds":m.completed_time+m.elapsed,"bonuses":m.bonuses,"decisions":decisions,"waves":waves}
