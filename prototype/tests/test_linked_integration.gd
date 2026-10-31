extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Linked = Profile.Talents.Linked
const Screen = preload("res://scripts/meta_screen.gd")
const Fixture = preload("res://tests/test_linked_talents.gd")
const OldFixture = preload("res://tests/test_expanded_talents.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func crossing(a: Vector2, b: Vector2, rect: Rect2) -> bool:
	if rect.has_point(a) or rect.has_point(b): return true
	var corners: Array[Vector2] = [rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)]
	for side in range(4):
		if Geometry2D.segment_intersects_segment(a,b,corners[side],corners[(side+1)%4]) != null: return true
	return false
func play(faction: int, ranks: Array) -> Dictionary:
	var scene = Main.new();root.add_child(scene);scene.set_process(false)
	scene.model.meta_ranks = ranks.duplicate();scene._choose_faction(faction);scene._prepare_campaign_capture("victory")
	var result: Dictionary = JSON.parse_string(JSON.stringify(Report.build(scene.model)))
	scene.free();return result
func run_checks() -> void:
	for tree in range(3):
		for local in Linked.PARENTS:
			var child: int = Linked.index_for(tree,local);var parent: int = Linked.parent_index(child)
			var route: PackedVector2Array = Screen.TreeTracks.link_route(child)
			check(route.size() == 2 and is_equal_approx(route[0].x,route[1].x) and route[0].y < route[1].y,"Une seule ligne verticale entre le parent et son enfant, sans coude ni détour")
			var clear: bool = true
			for other in range(21):
				var index: int = Linked.index_for(tree,other)
				if index in [child,parent]: continue
				var rect := Rect2(Screen.TreeTracks.button_position(index),Vector2(42,42)).grow(-1)
				for segment in range(route.size()-1): clear = clear and not crossing(route[segment],route[segment+1],rect)
			check(clear,"Une flèche contourne les icônes sans traverser un talent étranger au lien")
	for faction in range(2):
		var p = Profile.new("");p.data.banks[faction].points = 51;p.data.banks[faction].xp = 10000
		var ui = Screen.new();root.add_child(ui);ui.open(p,faction)
		await process_frame;await process_frame
		for index in range(63): check(ui.boards[Linked.coordinates(index).x].get_global_rect().encloses(ui.nodes[index].get_global_rect()),"Les sept lignes sont toutes visibles dans leur colonne")
		for index in range(63): check(ui.scrollers[Linked.coordinates(index).x].get_global_rect().encloses(ui.nodes[index].get_global_rect()),"Chaque talent tient dans la zone visible sans défilement ni rognage")
		var parent: int = Linked.index_for(0,5);var child: int = Linked.index_for(0,7)
		for index in [parent,parent,0,0,0]: check(p.allocate(faction,index),"Préparation du palier avec un parent partiellement amélioré")
		ui.refresh();ui.nodes[child].grab_focus();await process_frame
		check(ui.nodes[child].state == "prerequisite" and ui.detail_title.text.contains("Parent à terminer") and ui.detail_text.text.contains(Linked.node(faction,parent).name),"Le clavier expose le nom et le rang du parent manquant")
		var before: String = JSON.stringify(p.data);ui._allocate(child)
		check(JSON.stringify(p.data) == before,"Le clic sur l’enfant verrouillé ne contourne pas le prérequis ni ne dépense un point")
		check(p.allocate(faction,parent),"Le parent atteint son maximum")
		ui.refresh();check(ui.nodes[child].state == "available","L’enfant se débloque après le dernier rang du parent")
		ui._allocate(child);check(p.data.banks[faction].ranks[child] == 1 and p.data.banks[faction].resource == 0,"Investissement réel dans l’enfant sans dépenser de PO")
		ui.free()
		for tree in range(3):
			var modern: Array = Fixture.build(tree)
			modern[Linked.index_for((tree+1)%3,6)] -= 1;modern[Linked.index_for(tree,19)] += 1
			check(Linked.valid(modern) and not Linked.Base.valid(modern),"Configuration valide dans les nouveaux choix et distincte de l’ancien arbre")
			var report: Dictionary = play(faction,modern)
			check(report.result in ["victory","defeat"] and Replay.verify(report).ok,"Nouveau build réellement joué et rapport rejoué avec les mêmes effets")
			var legacy: Array = OldFixture.deep_build(tree)
			check(Linked.Base.valid(legacy) and Replay.verify(play(faction,legacy)).ok,"Ancienne configuration et son rapport encore rejouables malgré les nouveaux liens")
	# Migration d’un vrai profil v0.87 : une banque incompatible est remboursée, l’autre conservée.
	var path: String = "user://test_linked_migration_%d.json" % Time.get_ticks_usec()
	var old: Dictionary = Profile.fresh();old.schema = 5;old.serial = 1
	old.run = {"id":1,"faction":0,"completed":10,"victory":true,"settled":true,"previous_maps":0,"mission_id":"campaign.001","mission_reward":60,"mission_waves":10,"mission_earned":60,"mission_xp_reward":100,"mission_xp_earned":100}
	old.banks[0].merge({"resource":81,"xp":10000,"points":51,"resets":7,"ranks":OldFixture.deep_build(0),"mission_rewards":{"campaign.001":{"reward":60,"xp":100,"run_id":1}}},true)
	old.banks[1].points = 5;old.banks[1].xp = Profile.Experience.xp_for_points(5);old.banks[1].ranks[0] = 5;old.banks[1].resource = 17
	check(Profile.valid(old) and not Linked.valid(old.banks[0].ranks),"Profil historique bien formé mais investissements incompatibles avec les nouveaux liens")
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_buffer(Profile.Codec.encode(old));file.close()
	var migrated = Profile.new(path)
	check(not migrated.blocked and migrated.data.schema == 7 and migrated.data.banks[0].ranks == Linked.empty_ranks() and migrated.migration_notice.contains("rendus gratuitement"),"Migration explicite avec restitution gratuite des points de la banque incompatible")
	check(migrated.data.banks[0].resource == 81 and migrated.data.banks[0].xp == 10000 and migrated.data.banks[0].points == 51 and migrated.data.banks[0].resets == 7,"PO, XP, points disponibles et compteur conservés sans nouvelle récompense")
	check(migrated.data.banks[1] == JSON.parse_string(JSON.stringify(old.banks[1])) and migrated.data.run == JSON.parse_string(JSON.stringify(old.run)),"Banque compatible et reçu de résultat strictement conservés")
	check(migrated._read(path+".v087.bak") == JSON.parse_string(JSON.stringify(old)),"Archive chiffrée exacte du profil précédent")
	Profile.Codec.cache.clear();migrated = Profile.new(path)
	check(not migrated.blocked and migrated.migration_notice.is_empty() and migrated.data.banks[0].points == 51,"Réouverture sans deuxième conversion ni perte de point")
	var id: int = migrated.begin_mission(0,"campaign.001",777,10,777)
	check(migrated.credit_mission(id,0,10,true) and migrated.data.banks[0].xp == 10000 and migrated.data.banks[0].resource == 81,"La migration ne rend pas à nouveau payable une mission déjà gagnée")
	var incompatible: Dictionary = migrated.data.duplicate(true);incompatible.banks[0].ranks[Linked.index_for(0,7)] = 1
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	check(not migrated._commit(incompatible) and FileAccess.get_file_as_bytes(path) == bytes,"Configuration sans parent refusée sans écrire dans la sauvegarde")
	for suffix in ["",".bak",".tmp",".v087.bak"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("LINKED_INTEGRATION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
