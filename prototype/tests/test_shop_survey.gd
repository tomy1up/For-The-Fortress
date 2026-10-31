extends SceneTree
const Survey = preload("res://tests/survey_shop.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void:
	check(Survey.budget_before(4) == {"po":180,"xp":300,"points":1},"Première alternative à 180 PO finançable après trois premières victoires")
	check(Survey.budget_before(5) == {"po":240,"xp":400,"points":2},"Alternative à 240 PO et deux points à l’entrée de la mission 5")
	for card in Survey.Model.Shop.CARDS:
		var mission: int = 4 if card.po == 180 else 5
		for policy in ["substitution","renfort"]:
			for alternative in [false,true]:
				var slow: Dictionary = Survey.run_case(card,mission,1,policy,1,"famille",42,alternative,0.05,true)
				var fast: Dictionary = Survey.run_case(card,mission,1,policy,1,"famille",42,alternative,300.0,true)
				check(slow.failures.is_empty() and fast.failures.is_empty(),"Pas de dépense forcée ni recrutement invalide dans la politique")
				check(slow.deployed_auxiliary == fast.deployed_auxiliary and (alternative or not fast.deployed_auxiliary),"Le témoin ne recrute aucune unité achetée ; l’état de recrutement ne dépend pas du pas de simulation")
				if policy == "substitution": check(fast.deployed_auxiliary == alternative,"La substitution teste bien l’alternative dès l’ouverture")
				check(Replay._difference(slow.report,fast.report,"rapport").is_empty(),"La politique produit les mêmes rapports à petits et grands pas")
				check(Replay.verify(fast.report).ok,"Le rapport complet de contrôle se rejoue")
				check(Survey.Talents.spent(fast.talent_ranks) <= Survey.budget_before(mission).points,"Aucun talent acquis grâce à une victoire future")
	print("SHOP_SURVEY_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
