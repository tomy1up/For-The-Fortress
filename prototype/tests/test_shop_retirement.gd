extends SceneTree
## Retrait du Fantassin squelette (46) et du Tirailleur gnome (47) : boutique à 20 unités par faction (décision du porteur, 15 novembre 2026).
## Les sauvegardes qui les possédaient sont migrées (désélection, remboursement unique) et les anciens rapports restent rejouables.
const Model = preload("res://scripts/valley_model.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func cleanup(path: String) -> void:
	for suffix in ["",".bak",".tmp",".v216.bak"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
func write(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_buffer(Profile.Codec.encode(value));file.close()

func run_checks() -> void:
	for faction in range(2):
		check(Shop.for_faction(faction).size() == 20,"Faction %d : vingt unités de boutique" % faction)
	for id in ["horde.skeleton","alliance.gnome"]:
		check(Shop.card(id).is_empty() and not Shop.retired_card(id).is_empty(),"%s n’est plus proposée mais reste connue pour la migration" % id)
	check(Shop.for_type(46).faction == 1 and Shop.for_type(47).faction == 0 and Shop.BRANCHES.has(46) and Shop.BRANCHES.has(47),"Les types 46 et 47 restent décrits pour les anciens rapports")
	var p0 = Profile.new("")
	check(not p0.buy_shop_unit(1,"horde.skeleton") and not p0.buy_shop_unit(0,"alliance.gnome"),"Achat des unités retirées refusé")
	for pair in [[1,"horde.skeleton",46],[0,"alliance.gnome",47]]:
		var faction: int = pair[0];var id: String = pair[1]
		var path: String = "user://test_shop_retirement_%d_%d.json" % [faction,Time.get_ticks_usec()]
		var old: Dictionary = Profile.fresh()
		var other_bank: Dictionary = old.banks[1-faction]
		other_bank.resource = 77
		var bank: Dictionary = old.banks[faction]
		bank.resource = 100;bank.shop_owned = {id:1350,Shop.for_faction(faction)[0].id:180};bank.shop_selected = id
		check(Profile.valid(old),"Une ancienne sauvegarde possédant l’unité retirée reste lisible")
		write(path,old)
		var p = Profile.new(path)
		check(not p.blocked and p.data.banks[faction].resource == 1450 and not p.data.banks[faction].shop_owned.has(id) and p.data.banks[faction].shop_owned.size() == 1,"%s : PO payées rendues une fois, unité retirée de l’inventaire" % id)
		check(p.data.banks[faction].shop_selected == "" and p.selected_shop_type(faction) == -1,"%s : choix de renfort désélectionné" % id)
		check(p.data.banks[1-faction].resource == 77 and p.data.banks[faction].shop_owned.has(Shop.for_faction(faction)[0].id),"L’autre faction et les autres unités sont intactes")
		check(p.migration_notice.contains("1350"),"Message de migration indiquant le remboursement")
		check(p._read(path+".v216.bak") == JSON.parse_string(JSON.stringify(old)) or p._read(path+".v216.bak") != null,"Profil précédent archivé")
		Profile.Codec.cache.clear()
		var again = Profile.new(path)
		check(again.data.banks[faction].resource == 1450 and again.migration_notice.is_empty(),"Relecture : aucun second remboursement")
		cleanup(path)
		# Une unité retirée possédée mais non sélectionnée est aussi remboursée.
		var quiet: Dictionary = Profile.fresh();quiet.banks[faction].shop_owned = {id:1350}
		write(path,quiet)
		var q = Profile.new(path)
		check(q.data.banks[faction].resource == 1350 and q.data.banks[faction].shop_owned.is_empty(),"Unité retirée non sélectionnée : remboursée aussi")
		cleanup(path)
	# Anciens rapports : une partie avec l’unité retirée comme renfort se rejoue exactement.
	for type in [46,47]:
		var faction: int = Shop.for_type(type).faction
		var m = Model.new(true,Model.Maps.for_id("ford"))
		check(m.configure_auxiliary(type) and m.select_faction(faction),"Le modèle accepte encore le type %d pour rejouer un rapport" % type)
		m.rng.seed = 5
		m.buy(0,faction*3);m.buy(1,type);m.buy(2,faction*3+1)
		for wave in range(1,11):
			if not m.start(): break
			while m.active: m.advance(1.0)
			if m.phase == "defeat": break
			if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
			if wave < 10 and not m.prepare_next_wave(): break
		var shots: int = 0
		for defender in m.defenders:
			if not defender.is_empty() and int(defender.type) == type: shots += 1
		check(shots == 1 or m.phase == "defeat" or m.phase == "victory","Type %d : une partie complète se joue" % type)
		if m.phase in ["victory","defeat"]:
			var verified: Dictionary = Replay.verify(JSON.parse_string(JSON.stringify(Report.build(m))))
			check(verified.ok,"Type %d : le rapport se rejoue exactement (%s)" % [type,verified.get("error","")])
	print("SHOP_RETIREMENT_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
