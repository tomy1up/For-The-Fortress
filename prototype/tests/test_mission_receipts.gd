extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for total in [0,1,99,100,360,1000,1000000000]:
		var rewards: Array[int] = Profile.Missions.distribute_budget(total)
		var sum: int = 0
		for value in rewards: sum += value
		check(rewards.size() == 100 and sum == total,"Budget paramétrable réparti sans perte ni création de PO")
		check(rewards.max()-rewards.min() <= 1,"Répartition régulière de test sans montant de campagne fixé")
	check(Profile.Missions.distribute_budget(-1).is_empty() and Profile.Missions.distribute_budget(10,0).is_empty(),"Budget invalide refusé")
	for id in ["campaign.valley_ford","mission-001","a"]: check(Profile.Missions.valid_id(id),"Identifiant stable accepté")
	for id in ["","Mission","a/b","a b","é",12]: check(not Profile.Missions.valid_id(id),"Identifiant ambigu ou non textuel refusé")
	var p = Profile.new("")
	for faction in range(2):
		var id: int = p.begin_mission(faction,"test.mission_1",17)
		check(id > 0 and p.data.banks[faction].resource == 0 and p.data.banks[faction].mission_rewards.is_empty(),"Commencer ne crédite pas de PO")
		check(not p.credit_mission(id,1-faction,10,true) and not p.credit_mission(id,faction,9,true) and not p.credit(id,faction,10,true),"Mauvais camp, victoire incomplète et ancienne voie de versement refusés")
		check(p.credit_mission(id,faction,10,true) and p.data.banks[faction].resource == 17 and p.data.run.mission_earned == 17,"Première victoire créditée du montant lié à la tentative")
		check(p.credit_mission(id,faction,10,true) and p.data.banks[faction].resource == 17,"Même résultat répété sans double versement")
		check(not p.credit_mission(id,faction,9,false),"Résultat enregistré immuable")
		id = p.begin_mission(faction,"test.mission_1",99)
		check(p.credit_mission(id,faction,10,true) and p.data.banks[faction].resource == 17 and p.data.run.mission_earned == 0,"Rejouer une mission récompensée, même avec un barème modifié, ne redonne rien")
		id = p.begin_mission(faction,"test.mission_2",99,12)
		check(p.credit_mission(id,faction,6,false) and p.data.banks[faction].resource == 17 and not p.data.banks[faction].mission_rewards.has("test.mission_2"),"Défaite sans PO ni marquage de première victoire")
		id = p.begin_mission(faction,"test.mission_2",23,12)
		check(not p.credit_mission(id,faction,10,true) and p.credit_mission(id,faction,12,true) and p.data.banks[faction].resource == 40,"Victoire à la limite de vagues configurée, sans imposer dix à toutes les futures missions")
	check(p.data.banks[0].mission_rewards.size() == 2 and p.data.banks[1].mission_rewards.size() == 2,"Registres et monnaies indépendants entre factions")
	var path: String = ProjectSettings.globalize_path("user://test_mission_receipts_%d.json" % Time.get_ticks_usec())
	assert(not FileAccess.file_exists(path))
	var legacy: Dictionary = Profile.fresh();legacy.schema = 2;legacy.serial = 12
	for item in legacy.banks: item.erase("mission_rewards")
	legacy.banks[0].resource = 1234;legacy.banks[0].points = 5;legacy.banks[0].resets = 3;legacy.banks[0].ranks[0] = 5
	legacy.banks[1].resource = 999
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_buffer(Profile.Codec.encode(legacy));file.close()
	p = Profile.new(path)
	check(not p.blocked and p.data.schema == 3 and p.data.banks[0].resource == 1234 and p.data.banks[0].points == 5 and p.data.banks[0].resets == 3 and p.data.banks[0].ranks[0] == 5 and p.data.banks[1].resource == 999,"Migration du profil précédent sans perte de ressource, point, talent ou compteur")
	check(p._read(path+".v082.bak") == JSON.parse_string(JSON.stringify(legacy)),"Archive chiffrée du profil précédent conservée")
	var id: int = p.begin_mission(0,"test.mission_1",17)
	check(p.credit_mission(id,0,10,true),"Crédit de mission sur disque")
	Profile.Codec.cache.clear();p = Profile.new(path)
	check(not p.blocked and p.data.banks[0].resource == 1251 and p.data.banks[0].mission_rewards.has("test.mission_1"),"Après déchiffrement sans cache : PO et reçu retrouvés ensemble")
	var output: Array = []
	var code: int = OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/mission_receipt_relaunch.gd","--","--save="+path],output,true,false)
	check(code == 0 and "\n".join(output).contains("MISSION_RELAUNCH=true"),"Processus séparé : lecture puis victoire rejouée sans duplication")
	p = Profile.new(path);id = p.begin_mission(0,"test.mission_3",5)
	var before: Dictionary = p.data.duplicate(true);p.path = path+"_missing/profile.json"
	check(not p.credit_mission(id,0,10,true) and p.data == before,"Échec d’écriture : ni reçu ni PO publiés en mémoire")
	p.path = path;check(p.credit_mission(id,0,10,true),"Nouvelle tentative d’enregistrement unique après l’erreur")
	p.begin_mission(0,"test.mission_4",9)
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path);bytes[-1] = bytes[-1]^1
	file = FileAccess.open(path,FileAccess.WRITE);file.store_buffer(bytes);file.close();Profile.Codec.cache.clear()
	p = Profile.new(path)
	check(not p.blocked and p.data.banks[0].mission_rewards.has("test.mission_3") and p.data.banks[0].resource == 1256,"Secours protégé : anciens reçus et ressources restent cohérents")
	var invalid: Dictionary = p.data.duplicate(true);invalid.banks[0].mission_rewards["bad/id"] = {"reward":1,"run_id":1}
	check(not Profile.valid(invalid),"Reçu avec identifiant invalide refusé")
	invalid = p.data.duplicate(true);invalid.banks[0].mission_rewards["test.bad"] = {"reward":-1,"run_id":1}
	check(not Profile.valid(invalid),"Reçu négatif refusé")
	p = Profile.new("");p.data.banks[0].resource = 1000000000;id = p.begin_mission(0,"test.overflow",1)
	before = p.data.duplicate(true)
	check(not p.credit_mission(id,0,10,true) and p.data == before,"Dépassement de capacité : transaction complète annulée")
	var bad_path: String = path+"_bad_archive"
	var original: PackedByteArray = Profile.Codec.encode(legacy)
	file = FileAccess.open(bad_path,FileAccess.WRITE);file.store_buffer(original);file.close()
	file = FileAccess.open(bad_path+".v082.bak",FileAccess.WRITE);file.store_string("incomplet");file.close()
	var rejected = Profile.new(bad_path)
	check(rejected.blocked and rejected.error.contains("Migration annulée"),"Archive antérieure invalide : migration bloquée")
	check(FileAccess.get_file_as_bytes(bad_path) == original,"Migration bloquée : profil d’origine intact")
	DirAccess.remove_absolute(bad_path);DirAccess.remove_absolute(bad_path+".v082.bak")
	p = Profile.new("");id = p.begin_mission(0,"test.zero",0)
	check(p.credit_mission(id,0,10,true) and p.data.banks[0].mission_rewards.has("test.zero"),"Montant nul de test : victoire tout de même enregistrée")
	id = p.begin_mission(0,"test.zero",25)
	check(p.credit_mission(id,0,10,true) and p.data.banks[0].resource == 0,"Révision du montant après une victoire à zéro : aucun second versement")
	for suffix in ["",".bak",".tmp",".v082.bak"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("MISSION_RECEIPTS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
