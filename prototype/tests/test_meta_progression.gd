extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents.gd")
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var path: String = "user://test_meta_%d.json" % Time.get_ticks_usec()
	var p = Profile.new(path)
	check(not p.blocked and Profile.valid(p.data),"Premier lancement : profil sain et vide")
	var id: int = p.begin_run(0)
	check(id > 0 and FileAccess.file_exists(path),"Début de partie persisté")
	check(p.credit(id,0,4,false) and p.data.banks[0].resource == 10 and p.data.banks[1].resource == 0,"Vagues 1 à 4 : dix ressources Alliance seulement")
	check(p.credit(id,0,4,false) and p.data.banks[0].resource == 10,"Crédit répété sans duplication")
	var saved: String = JSON.stringify(p.data)
	check(not p.credit(id,1,5,false) and not p.credit(id,0,3,false) and not p.credit(id,0,9,true) and saved == JSON.stringify(p.data),"Mauvaise faction, régression et fausse victoire refusées sans mutation")
	check(p.buy_point(0) and p.data.banks[0].points == 1 and p.data.banks[0].resource == 0,"Achat du premier point au prix exact")
	check(not p.buy_point(1) and not p.allocate(1,0) and not p.allocate(0,1),"Pas de partage de points ni spécialité sans prérequis")
	check(p.allocate(0,0) and not p.allocate(0,0),"Un point ne peut être dépensé deux fois")
	check(not p.respec(0) and p.data.banks[0].resets == 0,"Reset sans ressource refusé et non compté")
	var reloaded = Profile.new(path)
	check(reloaded.data == JSON.parse_string(JSON.stringify(p.data)),"Fermeture/réouverture : points et rangs persistés")
	check(not p.credit(id,0,10,true),"Une partie déjà liquidée ne peut pas être augmentée après coup")
	id = p.begin_run(0)
	check(p.credit(id,0,10,true) and p.data.banks[0].resource == 60,"Nouvelle victoire : soixante ressources versées à la fin")
	check(p.credit(id,0,10,true) and p.data.banks[0].resource == 60,"Prime de victoire versée une seule fois")
	var next_id: int = p.begin_run(1)
	check(not p.credit(id,0,10,true) and p.credit(next_id,1,3,false) and p.data.banks[1].resource == 6,"Ancien identifiant refusé ; banque Horde indépendante")
	# Paliers indépendants et plafond permanent après les premiers resets.
	for faction in range(2):
		var q = Profile.new("");q.data.banks[faction].resource = 1000;q.data.banks[faction].points = Talents.MAX_POINTS
		for reset in range(9):
			check(q.reset_price(faction) == [2,4,6,8,10,10,10,10,10][reset],"Prix croissant puis plafonné")
			var built: bool = true
			for index in [0,0,0,0,0,1,1,1,2,2,3]: built = q.allocate(faction,index) and built
			check(built,"Lignes débloquées et spécialité acquise")
			check(not q.allocate(faction,4),"Spécialités exclusives")
			var before: int = q.data.banks[faction].resource
			var price: int = q.reset_price(faction)
			check(q.respec(faction) and q.data.banks[faction].resource == before-price and q.data.banks[faction].points == Talents.MAX_POINTS and Talents.spent(q.data.banks[faction].ranks) == 0,"Reset paie exactement une fois et rend tous les points")
			check(q.data.banks[1-faction].resets == 0 and q.reset_price(1-faction) == 2,"Reset sans incidence sur l'autre faction")
			check(not q.respec(faction) and q.data.banks[faction].resource == before-price,"Arbre vide : pas de nouveau prélèvement")
		q.data.banks[faction].points = Talents.MAX_POINTS
		check(not q.buy_point(faction),"Aucun achat de point inutile au-delà des rangs actifs possibles")
	# Contenu mal formé : pas de création silencieuse d'un profil écrasant les données.
	var broken: Dictionary = Profile.fresh();broken.banks[0].ranks[1] = 1
	check(not Profile.valid(broken),"Sauvegarde incohérente : spécialité sans trois rangs refusée")
	broken = Profile.fresh();broken.banks[0].resource = -1
	check(not Profile.valid(broken),"Monnaie négative refusée")
	var invalid := FileAccess.open(path,FileAccess.WRITE);invalid.store_string("incomplet");invalid.close()
	var recovered = Profile.new(path)
	check(not recovered.blocked and recovered.error.contains("secours"),"Profil principal abîmé : récupération du secours valide")
	var invalid_backup := FileAccess.open(path+".bak",FileAccess.WRITE);invalid_backup.store_string("incomplet");invalid_backup.close()
	var protected = Profile.new(path)
	check(protected.blocked and not protected.buy_point(0) and FileAccess.get_file_as_string(path) == "incomplet","Deux profils illisibles : protection contre l'écrasement")
	var unavailable = Profile.new(path+"/impossible.json")
	var before_failure: String = JSON.stringify(unavailable.data)
	check(unavailable.begin_run(0) == -1 and before_failure == JSON.stringify(unavailable.data),"Échec d'écriture : transaction annulée")
	# Effets, prévisions, bonus et rapports dépendent du cliché de début de partie.
	for faction in range(2):
		var m = Model.new();m.meta_ranks = [3,1,0,3,0,1,3,1,0];m.select_faction(faction)
		check(m.max_hp == (26 if faction == 0 else 20),"PV permanents appliqués une fois au choix de faction")
		for type in m.available_types():
			var effect: Dictionary = Talents.effects(faction,m.meta_ranks,type)
			var expected: Array = {0:[0.09,0.0,0.0,0.3],1:[0.09,0.0,0.0,0.3],2:[0.17,0.09,0.0,0.0],3:[0.17,0.0,0.0,0.0],4:[0.17,0.09,0.0,0.0],5:[0.09,0.0,0.24,0.0]}[type]
			check(is_equal_approx(effect.direct,expected[0]) and is_equal_approx(effect.secondary,expected[1]) and is_equal_approx(effect.curse,expected[2]) and is_equal_approx(effect.range,expected[3]),"Valeurs exactes des talents et composantes propres à chaque défenseur")
			check(Talents.effects(1-faction,m.meta_ranks,type) == {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0},"Aucun effet de talent sur les unités du camp opposé")
			m.gold = 1000
			var preview: Dictionary = m.purchase_preview_stats(type%3,type)
			m.buy(type%3,type)
			check(m.get_stats(type%3) == preview,"Prévision d'achat identique aux vrais effets des talents")
			var stats: Dictionary = m.get_stats(type%3)
			check(is_equal_approx(m.damage_for(stats,"direct",{"type":1}),stats.damage),"Dégâts réels et affichés cohérents")
		m.reset();check(Talents.spent(m.meta_ranks) == 0 and m.max_hp == 20,"Référence sans talent retrouvée après reset du modèle")
		var scene = Main.new();root.add_child(scene);scene.set_process(false)
		check(scene.meta_profile == null,"Tests du jeu isolés du vrai profil utilisateur")
		scene.meta_profile = Profile.new("");scene.meta_profile.data.banks[faction].resource = 100
		scene._open_meta(faction)
		check(scene.meta_menu.visible and scene._selection_blocked(),"Menu talents bloque les commandes de partie")
		var bank_before: Dictionary = scene.meta_profile.data.banks[faction].duplicate(true)
		scene.meta_menu._request_reset();scene.meta_menu.confirm.canceled.emit()
		check(scene.meta_profile.data.banks[faction] == bank_before,"Annuler la confirmation ne dépense rien")
		scene.meta_menu._buy();scene.meta_menu._allocate(0)
		check(scene.meta_profile.data.banks[faction].points == 1 and scene.meta_profile.data.banks[faction].ranks[0] == 1,"Achat et affectation accessibles depuis l'interface")
		scene.meta_menu.close();scene._choose_faction(faction)
		check(Talents.spent(scene.model.meta_ranks) == 1,"Configuration appliquée au début de partie")
		scene.meta_profile.data.banks[faction].ranks[0] = 0
		check(scene.model.meta_ranks[0] == 1,"Configuration du combat indépendante des mutations ultérieures du profil")
		scene._open_meta(faction);check(not scene.meta_menu.visible,"Édition des talents inaccessible en cours de tentative")
		scene.model.wave_history.append({"wave":1,"result":"cleared"});scene._sync_meta_rewards();scene._sync_meta_rewards()
		check(scene.meta_run_earned == 0,"Aucune ressource acquise pendant une partie en cours")
		scene.model.phase = "defeat";scene._sync_meta_rewards();scene._sync_meta_rewards()
		check(scene.meta_run_earned == 1,"Fin de partie : récompense des vagues terminées versée une seule fois")
		scene.free()
	# Rapport à talents réellement rejoué, sans accès au profil.
	var replay_model = Model.new();replay_model.meta_ranks = [3,1,0,0,0,0,0,0,0];replay_model.select_faction(0);replay_model.start();replay_model.advance(10000)
	while replay_model.phase not in ["victory","defeat"]:
		if replay_model.phase == "bonus": replay_model.choose_bonus(replay_model.bonus_offer[0])
		replay_model.prepare_next_wave();replay_model.start();replay_model.advance(10000)
	check(replay_model.phase == "defeat" and Replay.verify(JSON.parse_string(JSON.stringify(Report.build(replay_model)))).ok,"Rapport d'une partie avec talents rejouable indépendamment du profil")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("META_PROGRESSION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
