extends SceneTree
## Comparaisons appariées depuis une préparation commune après la vague 4.
const Model = preload("res://scripts/valley_model.gd")
const Matrix = preload("res://tests/survey_balance.gd")
const COPY_FIELDS: Array[String] = [
	"wave","max_hp","total_killed","total_escaped","total_income","completed_time",
	"bonuses","bonus_offer","synergies_enabled","faction","next_instance_id","curses",
	"spawn_schedule","gold","fortress_hp","elapsed","phase","spawned","killed",
	"escaped","enemies","defenders","shots","event_log","wave_history","_wave_record"
]
var checks: int = 0
var failures: Array[String] = []

func audit(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message)

func signature(m: RefCounted) -> String:
	var data: Array = []
	for field in COPY_FIELDS: data.append(m.get(field))
	data.append(m.rng.seed)
	data.append(m.rng.state)
	return JSON.stringify(data)

func clone_model(source: RefCounted) -> RefCounted:
	var result = Model.new()
	for field in COPY_FIELDS:
		var value: Variant = source.get(field)
		result.set(field,value.duplicate(true) if value is Array or value is Dictionary else value)
	result.rng.seed = source.rng.seed
	result.rng.state = source.rng.state
	audit(signature(result) == signature(source),"Copie intégrale de l'état et du générateur")
	return result

func choose(m: RefCounted, decisions: Array[Dictionary]) -> void:
	var offer: Array[int] = m.bonus_offer.duplicate()
	for code in Matrix.PRIORITIES.degats:
		if code in offer:
			decisions.append({"wave":m.wave,"offer":offer,"selected":code})
			audit(m.choose_bonus(code),"Choix commun selon priorité dégâts")
			return
	audit(false,"Offre sans choix")

func deployment(m: RefCounted) -> Array[Dictionary]:
	var units: Array[Dictionary] = []
	for slot in range(6):
		if m.defenders[slot].is_empty(): continue
		var u: Dictionary = m.defenders[slot]
		units.append({"slot":slot+1,"type":u.type,"level":u.level,"branch":u.branch,"paid":u.paid,"synergies":m.get_stats(slot).synergies})
	return units

func integrity(m: RefCounted, slots: Array) -> void:
	var paid: int = 0
	var count: int = 0
	for slot in range(6):
		if m.defenders[slot].is_empty(): continue
		count += 1
		paid += m.defenders[slot].paid
		audit(slot in slots and m.defenders[slot].type == m.faction*3+slots.find(slot),"Types et positions conservés")
	audit(count == 3 and m.gold >= 0 and m.gold == 150+m.total_income-paid,"Trois unités et conservation de l'or")

func checkpoint(faction: int, layout: Dictionary, seed_value: int) -> Dictionary:
	var m = Model.new()
	m.select_faction(faction)
	m.rng.seed = seed_value
	m.buy(layout.slots[0],faction*3)
	m.buy(layout.slots[1],faction*3+1)
	var decisions: Array[Dictionary] = []
	for wave in range(1,5):
		if wave == 4: audit(m.buy(layout.slots[2],faction*3+2),"Troisième type payé avant vague 4")
		audit(m.start(),"Lancement du préfixe commun")
		m.advance(300)
		audit(m.phase in ["finished","bonus"],"Survie du préfixe commun")
		if m.phase == "bonus": choose(m,decisions)
		if wave < 4: audit(m.prepare_next_wave(),"Transition du préfixe commun")
	integrity(m,layout.slots)
	for slot in layout.slots:
		audit(m.defenders[slot].level == 1 and m.gold >= m.upgrade_cost(slot),"Trois N1 et chaque premier palier finançable")
	return {"model":m,"decisions":decisions}

func invest(m: RefCounted, slots: Array, policy: String, branch: int) -> void:
	if policy == "reference":
		for slot in slots:
			m.upgrade(slot,branch if m.defenders[slot].level == 3 else -1)
		return
	var order: Array = [0,1,2]
	if policy == "priorite_groupe": order = [2,0,1] if m.faction == 0 else [1,0,2]
	if policy == "equilibre":
		while true:
			var candidates: Array = [0,1,2]
			candidates.sort_custom(func(a: int,b: int) -> bool:
				var la: int = m.defenders[slots[a]].level
				var lb: int = m.defenders[slots[b]].level
				return a < b if la == lb else la < lb)
			var target: int = slots[candidates[0]]
			if not m.upgrade(target,branch if m.defenders[target].level == 3 else -1): break
		return
	for index in order:
		var slot: int = slots[index]
		while m.defenders[slot].level < 4:
			if not m.upgrade(slot,branch if m.defenders[slot].level == 3 else -1): break

func _initialize() -> void:
	var checkpoints: Array[Dictionary] = []
	var immediate: Array[Dictionary] = []
	var campaigns: Array[Dictionary] = []
	for faction in range(2):
		for layout in Matrix.LAYOUTS:
			for seed_value in Matrix.SEEDS:
				var setup: Dictionary = checkpoint(faction,layout,seed_value)
				var base: RefCounted = setup.model
				var original: String = signature(base)
				var id: String = "%d-%s-%d" % [faction,layout.id,seed_value]
				checkpoints.append({"id":id,"faction":faction,"layout":layout.id,"seed":seed_value,"hp":base.fortress_hp,"gold":base.gold,"income":base.total_income,"max_hp":base.max_hp,"bonuses":base.bonuses.duplicate(),"decisions":setup.decisions,"deployed":deployment(base)})
				# Une seule dépense identique sur un N1 ; contrôle sans dépense distinct.
				for target in [-1,0,1,2]:
					var m = clone_model(base)
					audit(m.prepare_next_wave(),"Préparation vague 5 commune")
					var spent: int = m.gold
					if target >= 0: audit(m.upgrade(layout.slots[target]),"Amélioration N2 financée")
					spent -= m.gold
					audit(spent == (base.upgrade_cost(layout.slots[0]) if target >= 0 else 0),"Même coût pour les trois traitements N2")
					var units: Array[Dictionary] = deployment(m)
					integrity(m,layout.slots)
					audit(m.start(),"Lancement vague 5 isolée")
					m.advance(300)
					integrity(m,layout.slots)
					immediate.append({"checkpoint":id,"target":target,"spent":spent,"hp":m.fortress_hp,"gold":m.gold,"kills":m.killed,"escapes":m.escaped,"phase":m.phase,"seconds":m.elapsed,"deployed":units})
					audit(signature(base) == original,"Traitement isolé sans mutation du préfixe")
				# Revenus futurs endogènes : ils sont mesurés, jamais égalisés artificiellement.
				for policy in ["reference","equilibre","priorite_0","priorite_groupe"]:
					for branch in [0,1]:
						var m = clone_model(base)
						var waves: Array[Dictionary] = []
						var decisions: Array[Dictionary] = []
						for wave in range(5,11):
							audit(m.prepare_next_wave(),"Transition de continuation")
							invest(m,layout.slots,policy,branch)
							integrity(m,layout.slots)
							var units: Array[Dictionary] = deployment(m)
							audit(m.start(),"Lancement de continuation")
							m.advance(300)
							integrity(m,layout.slots)
							waves.append({"wave":wave,"hp":m.fortress_hp,"gold":m.gold,"income":m.total_income,"kills":m.killed,"escapes":m.escaped,"phase":m.phase,"seconds":m.elapsed,"deployed":units})
							if m.phase in ["victory","defeat"]: break
							if m.phase == "bonus": choose(m,decisions)
						campaigns.append({"checkpoint":id,"policy":policy,"branch":branch,"phase":m.phase,"last_wave":m.wave,"hp":m.fortress_hp,"gold":m.gold,"income":m.total_income,"kills":m.total_killed,"escapes":m.total_escaped,"combat_seconds":m.completed_time+m.elapsed,"bonuses":m.bonuses.duplicate(),"decisions":decisions,"waves":waves})
						audit(signature(base) == original,"Continuation sans mutation du préfixe")
	var path: String = "user://upgrades_v020.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): path = arg.trim_prefix("--output=")
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		push_error("Écriture impossible : "+path)
		quit(1)
		return
	file.store_string(JSON.stringify({"schema":1,"engine":Engine.get_version_info().string,"checks":checks,"failures":failures,"checkpoints":checkpoints,"immediate":immediate,"campaigns":campaigns}))
	file.close()
	print("UPGRADE_SURVEY checkpoints=%d immediate=%d campaigns=%d checks=%d failures=%d" % [checkpoints.size(),immediate.size(),campaigns.size(),checks,failures.size()])
	quit(0 if failures.is_empty() else 1)
