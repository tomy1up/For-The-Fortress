extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
const Experience = Profile.Experience
const Main = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var p = Profile.new("")
	for faction in range(2):
		for mission in range(1,201):
			var other: String = JSON.stringify(p.data.banks[1-faction])
			var id: int = p.begin_mission(faction,"test.xp.%03d" % mission,5,10,100)
			check(id > 0 and p.credit_mission(id,faction,10,true),"Victoire avec versement atomique PO et XP")
			check(p.data.banks[faction].xp == mission*100 and p.data.banks[faction].points == Experience.points_for_xp(mission*100),"Points débloqués automatiquement par l’XP sans dépenser les PO")
			check(p.data.banks[faction].resource == mission*5 and JSON.stringify(p.data.banks[1-faction]) == other,"Récompenses des 200 missions conservées, faction opposée intacte")
			var before: String = JSON.stringify(p.data)
			check(p.credit_mission(id,faction,10,true) and JSON.stringify(p.data) == before,"Nouvelle lecture du résultat sans double XP, PO ou point")
			if mission == 99: check(p.data.banks[faction].points == 50,"Avant la mission 100 : le 51e point reste à obtenir")
			if mission == 100: check(p.data.banks[faction].points == 51,"Mission 100 : exactement 51 points")
		var total: String = JSON.stringify(p.data.banks[faction])
		var repeated: int = p.begin_mission(faction,"test.xp.001",999,10,999)
		check(p.credit_mission(repeated,faction,10,true) and JSON.stringify(p.data.banks[faction]) == total,"Hypothèse première victoire : rejouer ne redonne ni PO ni XP")
		var lost: int = p.begin_mission(faction,"test.xp.lost",5,10,100)
		check(p.credit_mission(lost,faction,9,false) and JSON.stringify(p.data.banks[faction]) == total,"Défaite : aucun gain de première victoire")
		check(p.allocate(faction,0) and p.respec(faction) and p.data.banks[faction].xp == 20000 and p.data.banks[faction].points == 51 and p.data.banks[faction].resource == 1000,"Respécialisation gratuite : XP, points débloqués et PO conservés")
	# Une victoire à zéro PO peut tout de même donner l’XP configurée.
	var zero = Profile.new("");var id: int = zero.begin_mission(0,"test.zero_po",0,10,200)
	check(zero.credit_mission(id,0,10,true) and zero.data.banks[0].resource == 0 and zero.data.banks[0].points == 1 and zero.data.banks[0].xp == 200,"XP indépendante d’un montant de PO nul")
	var before: String = JSON.stringify(zero.data)
	check(zero.begin_mission(0,"test.bad",1,10,-1) == -1 and JSON.stringify(zero.data) == before,"Récompense XP négative refusée sans mutation")
	var invalid: Dictionary = zero.data.duplicate(true);invalid.banks[0].xp = 10000
	check(not Profile.valid(invalid),"Profil incohérent : XP sans les points correspondants refusée")
	invalid = zero.data.duplicate(true);invalid.banks[0].mission_rewards["test.zero_po"].xp = 199
	check(not Profile.valid(invalid),"Reçu XP du résultat incohérent refusé")
	# Migration réelle du dernier profil publié, puis attribution et relancement.
	var path: String = "user://test_xp_migration_%d.json" % Time.get_ticks_usec()
	var old: Dictionary = Profile.fresh();old.schema = 4
	for bank in old.banks: bank.erase("xp")
	old.banks[0].points = 5;old.banks[0].ranks[0] = 5;old.banks[0].resource = 37
	old.banks[1].points = 51;old.banks[1].resource = 19
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_buffer(Profile.Codec.encode(old));file.close()
	var migrated = Profile.new(path)
	check(not migrated.blocked and migrated.data.schema == 5 and migrated.data.banks[0].resource == 37 and migrated.data.banks[0].points == 5 and migrated.data.banks[0].ranks == JSON.parse_string(JSON.stringify(old.banks[0].ranks)),"Migration : points, talents et PO acquis intacts")
	check(migrated.data.banks[0].xp == Experience.xp_for_points(5) and migrated.data.banks[1].xp == Experience.TARGET_XP,"Crédit XP de compatibilité correspondant aux anciens points")
	check(migrated._read(path+".v086.bak") == JSON.parse_string(JSON.stringify(old)),"Ancien profil protégé archivé avant migration")
	id = migrated.begin_mission(0,"test.persisted_xp",7,10,200)
	check(migrated.credit_mission(id,0,10,true),"XP attribuée par la transaction persistante")
	var expected: Dictionary = JSON.parse_string(JSON.stringify(migrated.data))
	Profile.Codec.cache.clear();migrated = Profile.new(path)
	check(not migrated.blocked and migrated.data == expected and migrated.migration_notice.is_empty(),"Relancement : XP, points et reçu protégés retrouvés sans seconde conversion")
	var bank_before: String = JSON.stringify(migrated.data.banks)
	id = migrated.begin_mission(0,"test.persisted_xp",700,10,2000)
	check(migrated.credit_mission(id,0,10,true) and JSON.stringify(migrated.data.banks) == bank_before,"Mission déjà payée : pas de nouveau gain après relancement")
	for suffix in ["",".bak",".tmp",".v086.bak"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	# Raccordement réel de la seule mission jouable, sans profil utilisateur.
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = Profile.new("")
	for faction in range(2):
		scene._choose_faction(faction);scene._prepare_campaign_capture("victory");scene._show_run_summary()
		check(scene.meta_profile.data.banks[faction].xp == 100 and scene.meta_profile.data.banks[faction].resource == 60 and scene.meta_profile.data.banks[faction].points == 0,"Gué : première victoire enregistrée avec 100 XP et 60 PO, sans point anticipé")
		check(scene._meta_reward_summary().xp_earned == 100 and scene.summary_meta_note.text.contains("XP : +100"),"Bilan indique le gain d’XP réellement enregistré")
		scene._summary_to_talents()
		check(scene.choosing_faction and scene.meta_menu.visible and scene.meta_menu.buy.disabled and not scene.meta_menu.buy.visible and scene.meta_menu.xp_label.text.contains("encore 97 XP") and scene.meta_menu.xp_bar.value == 100 and scene.meta_menu.xp_bar.max_value == 197,"Après la mission : progression vers le premier point affichée, aucun achat en PO")
		scene.meta_menu.close();scene._choose_faction(faction);scene._prepare_campaign_capture("victory");scene._show_run_summary()
		check(scene._meta_reward_summary().saved == 0 and scene._meta_reward_summary().xp_earned == 0 and scene.meta_profile.data.banks[faction].xp == 100 and scene.meta_profile.data.banks[faction].resource == 60,"Gué rejoué : victoire sans deuxième gain, quelle que soit la faction")
		check(scene.summary_meta_note.text.contains("Mission déjà réussie"),"Absence de nouvelle récompense expliquée au joueur")
		scene._summary_to_talents();scene.meta_menu.close()
	check(scene.meta_profile.data.banks[0].xp == 100 and scene.meta_profile.data.banks[1].xp == 100,"Deux réussites indépendantes sans transfert d’XP entre factions")
	scene.free()
	print("MISSION_EXPERIENCE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
