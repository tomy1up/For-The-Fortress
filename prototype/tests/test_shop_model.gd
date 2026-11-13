extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Fixture = preload("res://tests/test_expanded_talents.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void:
	for card in Shop.CARDS:
		var m = Model.new();check(m.configure_auxiliary(card.type),"Option configurée avant le départ")
		check(not m.select_faction(1-card.faction) and m.action_history.is_empty(),"Une alternative étrangère refuse le départ sans action partielle")
		check(m.select_faction(card.faction),"Départ avec l’alternative de la faction")
		check(m.available_types().size() == 4 and m.available_types().slice(0,3) == ([0,1,2] if card.faction == 0 else [3,4,5]) and m.available_types()[3] == card.type,"Trois types de base conservés plus le seul quatrième type choisi")
		check(not m.configure_auxiliary(-1),"Le choix ne peut pas être retiré après le départ")
		for other in Shop.CARDS:
			if other.type != card.type: check(not m.buy(5,other.type),"Les autres alternatives ne sont pas recrutables")
		check(m.buy(0,card.type) and m.gold == 150-int(card.stats.price),"Recrutement avec l’or de combat au prix de l’unité, sans PO")
		for level in range(1,4):
			var stats: Dictionary = Model.stats_for(card.type,level)
			check(is_equal_approx(stats.damage,card.stats.damage*Model.Progression.DAMAGE_MULTIPLIERS[level-1]) and stats.name == card.name,"Niveaux et identité propres à l’alternative")
		for branch in range(2):
			var stats: Dictionary = Model.stats_for(card.type,4,branch)
			check(not stats.branch_name.is_empty() and stats.branch_name == Shop.BRANCHES[card.type][branch].name,"Deux spécialisations distinctes pour chaque alternative")
		for tree in range(3):
			var ranks: Array = Fixture.deep_build(tree)
			check(Model.MetaTalents.effects(card.faction,ranks,card.type) == Model.MetaTalents.effects(card.faction,ranks,card.family),"Les talents de famille appliquent les mêmes bonus à l’unité de base et à son alternative")
		check(Model.MetaTalents.effects(1-card.faction,Fixture.deep_build(0),card.type) == {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0},"Aucun bonus de talent ne traverse la frontière de faction")
		var rounds: Array = []
		for step in [0.05,300.0]:
			m = Model.new();m.configure_auxiliary(card.type);m.select_faction(card.faction);m.rng.seed = 42
			m.buy(0,card.type);m.buy(1,card.faction*3)
			for wave in range(1,11):
				if wave >= 4 and m.defenders[2].is_empty(): m.buy(2,card.faction*3+2)
				if wave >= 5:
					for slot in range(3):
						if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
				m.start()
				while m.active: m.advance(step)
				if m.phase == "defeat": break
				if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
				if wave < 10: m.prepare_next_wave()
			var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
			check(report.auxiliary_type == card.type and m.phase in ["victory","defeat"] and m.gold >= 0,"Une partie normale avec l’alternative produit un rapport de résultat")
			var replay: Dictionary = Replay.verify(report)
			check(replay.ok,"Le rapport avec quatrième type se rejoue : "+replay.get("error",""))
			var bad: Dictionary = report.duplicate(true);bad.erase("auxiliary_type")
			check(not Replay.verify(bad).ok,"Supprimer le choix de l’alternative empêche de rejouer ses recrutements")
			bad = report.duplicate(true);bad.auxiliary_type = Shop.for_faction(1-card.faction)[0].type
			check(not Replay.verify(bad).ok,"Une alternative de la mauvaise faction est rejetée au rejeu")
			rounds.append(report)
		check(Replay._difference(rounds[0],rounds[1],"rapport").is_empty(),"Chronologie des alternatives identique à petits et grands pas")
	var plain = Model.new();plain.select_faction(0)
	check(plain.available_types() == [0,1,2] and not Report.build(plain).has("auxiliary_type"),"Le format et le recrutement historiques restent inchangés sans alternative")
	for bad in [true,"6",6.5,0,5,30,-2,INF,null]:
		var m = Model.new();check(not m.configure_auxiliary(bad) and m.auxiliary_type == -1,"Identifiants d’alternative invalides refusés sans effet")
	print("SHOP_MODEL_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
