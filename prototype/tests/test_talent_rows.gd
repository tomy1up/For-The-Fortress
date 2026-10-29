extends SceneTree
const Talents = preload("res://scripts/meta_talents.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Screen = preload("res://scripts/meta_screen.gd")
const Model = preload("res://scripts/valley_model.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		for tree in range(3):
			var p = Profile.new("");p.data.banks[faction].points = 36;p.data.banks[faction].resource = 30
			var base: int = tree*5
			check(not p.allocate(faction,base+1) and not p.allocate(faction,base+3),"Lignes suivantes verrouillées sans point dépensé")
			for rank in range(4): check(p.allocate(faction,base),"Première ligne disponible immédiatement")
			check(not p.allocate(faction,base+1) and Talents.allocation_error(p.data.banks[faction].ranks,base+1,36).contains("Encore 1"),"Quatre points : encore un point requis")
			check(p.allocate(faction,base) and p.allocate(faction,base+1),"Cinquième point ouvre la deuxième ligne")
			check(not p.allocate(faction,((tree+1)%3)*5+1),"Les points d'un arbre n'ouvrent pas une autre colonne")
			p.allocate(faction,base+1);p.allocate(faction,base+1);p.allocate(faction,base+2)
			check(Talents.tree_spent(p.data.banks[faction].ranks,tree) == 9 and not p.allocate(faction,base+3),"Neuf points : troisième ligne encore fermée")
			check(p.allocate(faction,base+2) and p.allocate(faction,base+3),"Dix points ouvrent la troisième ligne")
			check(not p.allocate(faction,base+4),"Spécialités finales mutuellement exclusives")
			check(p.data.banks[1-faction] == Profile.bank(),"Aucune mutation du camp opposé")
			check(p.respec(faction) and not p.allocate(faction,base+3),"Reset referme toutes les lignes au-delà de la première")
			var invalid: Array = Talents.empty_ranks();invalid[base+1] = 3
			check(not Talents.current_valid(invalid),"Une ligne ne finance pas elle-même son prérequis")
			invalid = Talents.empty_ranks();invalid[base] = 5;invalid[base+3] = 1
			check(not Talents.current_valid(invalid),"Configuration sauvegardée avec spécialité prématurée refusée")
	# Migration réelle sur disque, sans frais, sans redistribution imposée et idempotente.
	var path: String = "user://test_rows_%d.json" % Time.get_ticks_usec()
	var legacy: Dictionary = Profile.fresh();legacy.schema = 1;legacy.serial = 7
	legacy.run = {"id":7,"faction":1,"completed":4,"victory":false}
	for camp in range(2):
		legacy.banks[camp] = {"resource":23+camp,"points":8+camp,"resets":3+camp,"ranks":[3,1,0,3,0,1,0,0,0]}
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_buffer(Profile.Codec.encode(legacy));file.close()
	var migrated = Profile.new(path)
	check(not migrated.blocked and migrated.data.schema == 6 and not migrated.migration_notice.is_empty(),"Ancien profil reconnu et migré")
	for camp in range(2):
		check(migrated.data.banks[camp].resource == legacy.banks[camp].resource and migrated.data.banks[camp].points == legacy.banks[camp].points and migrated.data.banks[camp].resets == legacy.banks[camp].resets,"Ressources, points achetés et compteurs conservés")
		check(Talents.spent(migrated.data.banks[camp].ranks) == 0,"Tous les points investis rendus gratuitement")
	check(migrated.data.run == JSON.parse_string(JSON.stringify(legacy.run)) and migrated.data.serial == 7,"Parcours de gains conservé sans double crédit")
	check(migrated._read(path+".v067.bak") == JSON.parse_string(JSON.stringify(legacy)),"Copie du profil d'origine conservée")
	check(migrated.allocate(0,0),"Points rendus immédiatement réutilisables")
	var reopened = Profile.new(path)
	check(reopened.data.banks[0].ranks[0] == 1 and reopened.migration_notice.is_empty(),"Réouverture : pas de deuxième remboursement des talents")
	# Une copie incomplète laissée par une première tentative ne doit pas être acceptée.
	var bad_path: String = path+"_bad"
	file = FileAccess.open(bad_path,FileAccess.WRITE);file.store_buffer(Profile.Codec.encode(legacy));file.close()
	file = FileAccess.open(bad_path+".v067.bak",FileAccess.WRITE);file.store_string("incomplet");file.close()
	var protected = Profile.new(bad_path)
	check(protected.blocked and protected._read(bad_path) == JSON.parse_string(JSON.stringify(legacy)),"Copie de migration incomplète : ancien profil préservé, pas de migration silencieuse")
	# Conditions et effets du nouveau format ; l'ancien format reste couvert par les tests v0.67.
	var ranks: Array = [5,3,2,1,0,5,3,2,1,0,5,3,2,1,0]
	for faction in range(2):
		var m = Model.new();m.meta_ranks = ranks.duplicate();m.select_faction(faction)
		check(m.max_hp == (31 if faction == 0 else 20),"PV du nouveau format exacts")
		for type in m.available_types():
			var effect: Dictionary = Talents.effects(faction,ranks,type)
			var expected: Array = {0:[0.29,0.0,0.0,0.3],1:[0.29,0.0,0.0,0.3],2:[0.29,0.21,0.0,0.1],3:[0.29,0.06,0.0,0.0],4:[0.29,0.21,0.0,0.0],5:[0.29,0.0,0.21,0.0]}[type]
			check(is_equal_approx(effect.direct,expected[0]) and is_equal_approx(effect.secondary,expected[1]) and is_equal_approx(effect.curse,expected[2]) and is_equal_approx(effect.range,expected[3]),"Effets exacts de tous les nouveaux rangs par classe")
		m.start();m.advance(10000)
		while m.phase not in ["victory","defeat"]:
			if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
			m.prepare_next_wave();m.start();m.advance(10000)
		check(Replay.verify(JSON.parse_string(JSON.stringify(Report.build(m)))).ok,"Rejeu d'une partie au nouveau format, indépendant du profil")
		var p = Profile.new("");p.data.banks[faction].points = 14;p.data.banks[faction].resource = 36
		p.data.banks[faction].ranks = [5,3,2,1,0,1,0,0,0,0,0,0,0,0,0]
		var ui = Screen.new();root.add_child(ui);ui.open(p,faction)
		check(ui.nodes.size() == 63 and ui.tier_labels.size() == 21,"Trois colonnes enrichies et cinquante-quatre icônes avec dix-huit états de ligne")
		check(ui.boards[0].opened == [true,true,true,false,false,false,false] and ui.boards[1].opened == [true,false,false,false,false,false,false],"État visuel des paliers propre à chaque colonne")
		ui.nodes[8].focus_entered.emit()
		check(ui.detail_text.text.contains("Encore 9"),"Clavier : description du verrou et nombre exact de points manquants")
		var before: Dictionary = p.data.duplicate(true);ui._allocate(8)
		check(before == p.data,"Clic sur un talent verrouillé sans dépense ni mutation")
		for index in range(15):
			var board: Control = ui.boards[int(index/5)]
			check(board.get_global_rect().encloses(ui.nodes[index].get_global_rect()),"Icône contenue dans sa colonne")
		ui.queue_redraw();await process_frame;ui.free()
	for suffix in ["",".bak",".tmp",".v067.bak"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
		if FileAccess.file_exists(bad_path+suffix): DirAccess.remove_absolute(bad_path+suffix)
	print("TALENT_ROWS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
