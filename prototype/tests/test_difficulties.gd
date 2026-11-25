extends SceneTree
## Socle des difficultés de campagne (v0.257, lot 1 du cadrage du 25 novembre 2026) : identifiants, PV et récompenses de l'Héroïque, ouverture après
## 100 missions, progression séparée dans le profil, onglets de l'écran de campagne, lancement, rapport et rejeu. Le Mythique n'est pas encore jouable.
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Missions = preload("res://scripts/mission_progress.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
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
	verify_profile()
	verify_screen_and_launch()
	verify_report()
	print("DIFFICULTIES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

func verify_catalogue() -> void:
	check(Catalogue.DIFFICULTY_NAMES == ["Normal","Héroïque","Mythique"],"Trois difficultés nommées")
	for difficulty in [0,1,2]:
		for number in [1,11,100,200]:
			var id: String = Catalogue.id_for(number,difficulty)
			check(Catalogue.number_for(id) == number and Catalogue.difficulty_for(id) == difficulty,"Identifiant %s : numéro et difficulté relus" % id)
	check(Catalogue.id_for(11) == "campaign.011" and Catalogue.id_for(11,1) == "heroic.011" and Catalogue.id_for(11,2) == "mythic.011","Identifiants par difficulté")
	for bad in ["heroic.000","heroic.201","heroic.01","heroic.0011","legend.001","campaign.abc",null,11]:
		check(Catalogue.difficulty_for(bad) == -1 and Catalogue.number_for(bad) == 0,"Identifiant refusé : %s" % str(bad))
	check(Catalogue.runtime("campaign.001") == {"id":"campaign.001","po":60,"xp":100,"waves":10,"map_id":"valley_ford","hp_percent":100},"Le Normal ne change pas")
	var heroic: Dictionary = Catalogue.runtime("heroic.011")
	check(heroic.id == "heroic.011" and heroic.po == int(round(60*1.5)) and heroic.xp == 0 and heroic.difficulty == 1 and heroic.map_id == Catalogue.runtime("campaign.011").map_id,"Héroïque : même carte, PO majorées de moitié, pas d'XP")
	check(Catalogue.runtime("mythic.011").is_empty() and not Catalogue.difficulty_playable(2),"Mythique pas encore jouable")
	for faction in [0,1]:
		for number in range(1,Catalogue.TOTAL_MISSIONS+1):
			var normal: int = Catalogue.faction_hp_percent(number,faction)
			var hard: int = Catalogue.faction_hp_percent(number,faction,1)
			if hard != int(round(normal*1.3)) or not Model.valid_enemy_hp_percent(hard):
				check(false,"Faction %d, mission %d : PV héroïques = PV du Normal × 1,3, dans les limites" % [faction,number])
			if Catalogue.reward_po_for(number,1) != int(round(Catalogue.definition(number).po*1.5)) or Catalogue.reward_xp_for(number,1) != 0:
				check(false,"Mission %d : récompense héroïque" % number)
	check(true,"PV et récompenses héroïques des 200 missions")
	var empty: Dictionary = Missions.campaign_status({})
	var ninety_nine: Dictionary = empty.duplicate(true);ninety_nine.first_hundred = 99
	var hundred: Dictionary = empty.duplicate(true);hundred.first_hundred = 100
	check(Catalogue.difficulty_open(0,[]) and not Catalogue.difficulty_open(1,[ninety_nine,empty,empty]) and Catalogue.difficulty_open(1,[hundred,empty,empty]),"Héroïque ouvert après les 100 premières missions du Normal")
	check(not Catalogue.difficulty_open(2,[hundred,ninety_nine,empty]) and Catalogue.difficulty_open(2,[hundred,hundred,empty]),"Mythique ouvert après les 100 premières missions de l'Héroïque")

## Profil dont les `count` premières missions d'une difficulté sont réussies pour une faction.
func winner(faction: int, normal: int, heroic: int = 0) -> Profile:
	var profile := Profile.new("")
	for item in [[0,normal],[1,heroic]]:
		for number in range(1,int(item[1])+1):
			var id: int = profile.begin_mission(faction,Catalogue.id_for(number,int(item[0])),1,10,0)
			profile.credit_mission(id,faction,10,true)
	return profile

func verify_profile() -> void:
	var profile := winner(0,100)
	var statuses: Array = profile.campaign_statuses(0)
	check(statuses[0].first_hundred == 100 and statuses[1].completed == 0 and profile.campaign_status(1,0).completed == 0,"Réussites du Normal comptées pour la seule faction jouée")
	check(Catalogue.difficulty_open(1,statuses) and not Catalogue.difficulty_open(2,statuses),"Héroïque ouvert, Mythique fermé")
	var resource: int = int(profile.data.banks[0].resource)
	var xp: int = int(profile.data.banks[0].xp)
	var id: int = profile.begin_mission(0,"heroic.001",90,10,0)
	check(id > 0 and profile.credit_mission(id,0,10,true),"Victoire héroïque créditée")
	check(profile.campaign_status(0,1).completed == 1 and profile.campaign_status(0,0).completed == 100,"Réussite héroïque séparée du Normal")
	check(int(profile.data.banks[0].resource) == resource+90 and int(profile.data.banks[0].xp) == xp,"PO versées, XP inchangée")
	var again: int = profile.begin_mission(0,"heroic.001",90,10,0)
	profile.credit_mission(again,0,10,true)
	check(int(profile.data.banks[0].resource) == resource+90,"Rejouer une mission héroïque ne redonne rien")
	check(Profile.valid(profile.data),"Le profil avec des reçus héroïques reste valide")

func verify_screen_and_launch() -> void:
	# Héroïque verrouillé : 99 missions du Normal.
	var locked = Main.new();root.add_child(locked);locked.set_process(false)
	locked.meta_profile = winner(0,99)
	locked._open_campaign(0)
	var menu = locked.campaign_menu
	check(menu.difficulty_buttons.size() == 3 and menu.difficulty == 0,"Trois onglets, Normal par défaut")
	menu._difficulty(1)
	check(menu.difficulty == 1 and menu.start_button.disabled and menu.progress_label.text.contains("verrouillé") and menu.progress_label.text.contains("99 / 100"),"Héroïque verrouillé, condition affichée")
	menu._launch()
	check(locked.choosing_faction,"Aucun lancement d'une difficulté verrouillée")
	locked.free()
	# Héroïque ouvert : 100 missions du Normal.
	var game = Main.new();root.add_child(game);game.set_process(false)
	game.meta_profile = winner(0,100)
	game._open_campaign(0)
	menu = game.campaign_menu
	menu._difficulty(1)
	check(menu.chapter == 1 and menu.selected == 0 and not menu.start_button.disabled,"Héroïque ouvert sur sa première mission")
	check(menu.rewards.text.contains("90 PO") and not menu.rewards.text.contains("XP") and menu.rewards.text.contains("Héroïque"),"Récompense héroïque affichée")
	check(menu.mission_detail.text.contains("PV ennemis : %d %%" % Catalogue.faction_hp_percent(1,0,1)),"PV héroïques affichés")
	menu._select(1)
	check(menu.start_button.disabled,"Deuxième mission héroïque verrouillée tant que la première n'est pas réussie")
	menu._select(0)
	menu._difficulty(2)
	check(menu.start_button.disabled and menu.progress_label.text.contains("verrouillé"),"Mythique verrouillé")
	menu._difficulty(1)
	menu._launch()
	check(not game.choosing_faction and game.mission_definition.id == "heroic.001" and game.model.difficulty == 1,"Mission héroïque lancée")
	check(game.model.enemy_hp_percent == Catalogue.faction_hp_percent(1,0,1) and game.map_caption.text.ends_with("HÉROÏQUE"),"PV héroïques et difficulté affichés en partie")
	game.free()

func verify_report() -> void:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	check(m.configure_enemy_hp(Catalogue.faction_hp_percent(2,0,1)) and m.configure_difficulty(1) and m.select_faction(0),"Partie héroïque préparée")
	check(not m.configure_difficulty(3) and not m.configure_difficulty(1.5) and m.difficulty == 1,"Difficulté invalide refusée")
	m.rng.seed = 7
	m.buy(3,0);m.buy(4,1)
	for wave in range(1,11):
		if wave == 2: m.buy(2,1)
		if not m.start(): break
		m.advance(10000)
		if m.phase == "defeat": break
		if m.phase == "bonus": m.choose_bonus(Model.reference_bonus(m.bonus_offer))
		if wave < 10: m.prepare_next_wave()
	check(not m.configure_difficulty(0),"Difficulté figée après la première action")
	var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
	check(int(report.get("difficulty",-1)) == 1,"Le rapport garde la difficulté")
	check(Replay.verify(report).ok,"Une partie héroïque se rejoue : "+str(Replay.verify(report).get("error","")))
	# Au lot 1, la difficulté ne change que les PV, déjà enregistrés à part : elle n'a pas d'effet propre au combat (les champions du lot 2 en auront un).
	var invalid: Dictionary = report.duplicate(true);invalid.difficulty = 5
	check(not Replay.verify(invalid).ok and Replay.verify(invalid).error == "Difficulté de campagne invalide.","Difficulté invalide refusée au rejeu")
	var old: Dictionary = report.duplicate(true);old.game_version = "0.256"
	check(not Replay.verify(old).ok and Replay.verify(old).error == "Difficulté de campagne invalide.","Un rapport d'avant la v0.257 ne peut pas porter de difficulté")
	var normal = Model.new(true,Model.Maps.for_id("valley_ford"))
	normal.configure_enemy_hp(101);normal.select_faction(0)
	check(not Report.build(normal).has("difficulty"),"Le rapport du Normal garde son format")
