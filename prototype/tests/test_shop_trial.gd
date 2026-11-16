extends SceneTree
## Profil d'essai de la boutique (--essai-boutique) : toutes les unités des deux factions sont possédées dans un profil séparé, sans PO dépensées,
## et chaque unité reste sélectionnable comme renfort.
const Profile = preload("res://scripts/meta_profile.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var path: String = "user://test_shop_trial_%d.json" % Time.get_ticks_usec()
	var p = Profile.new(path)
	check(p.grant_all_shop_units(),"Octroi accepté")
	for faction in range(2):
		var cards: Array = Shop.for_faction(faction)
		check(cards.size() == 20 and p.data.banks[faction].shop_owned.size() == 20,"Faction %d : les 20 unités sont possédées" % faction)
		check(p.data.banks[faction].resource == 0 and p.data.banks[faction].points == 0,"Aucune PO ni point inventé")
		for card in cards:
			check(p.select_shop_unit(faction,card.id) and p.selected_shop_type(faction) == card.type,"%s sélectionnable comme renfort" % card.name)
	check(Profile.valid(p.data) and p.grant_all_shop_units(),"Profil valide, second octroi sans effet")
	Profile.Codec.cache.clear()
	var again = Profile.new(path)
	check(not again.blocked and again.data.banks[0].shop_owned.size() == 20,"Relecture : unités conservées")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("SHOP_TRIAL_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
