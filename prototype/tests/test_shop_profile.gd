extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
class RefusingProfile extends Profile:
	func _commit(_candidate: Dictionary) -> bool:
		error = "Écriture refusée pour le contrôle.";return false
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func cleanup(path: String) -> void:
	for suffix in ["",".bak",".tmp",".v098.bak"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
func run_checks() -> void:
	check(Profile.fresh().schema == 7 and Profile.valid(Profile.fresh()),"Nouveau format de profil valide avec inventaire vide")
	var types: Dictionary = {};var ids: Dictionary = {}
	for card in Shop.CARDS:
		check(not types.has(card.type) and not ids.has(card.id) and card.family/3 == card.faction,"Identités de catalogue uniques et familles propres à leur faction")
		types[card.type] = true;ids[card.id] = true
		var copy: Dictionary = Shop.card(card.id);copy.stats.damage = -100
		check(Shop.card(card.id).stats.damage > 0,"Modifier une fiche reçue ne change pas le catalogue")
	for faction in range(2):
		var cards: Array[Dictionary] = Shop.for_faction(faction);var other_cards: Array[Dictionary] = Shop.for_faction(1-faction)
		var path: String = "user://test_shop_profile_%d_%d.json" % [faction,Time.get_ticks_usec()]
		var p = Profile.new(path)
		check(cards.size() == 15 and p.selected_shop_type(faction) == -1,"Quinze propositions d’alternative, aucune choisie sans achat")
		check(not p.buy_shop_unit(faction,cards[0].id) and p.error.is_empty() and p.data.banks[faction].shop_owned.is_empty(),"Solde insuffisant sans faux message de sauvegarde corrompue")
		for mission in range(1,8):
			var run: int = p.begin_mission(faction,"campaign.%03d" % mission,60,10,100)
			check(p.credit_mission(run,faction,10,true),"PO et XP obtenues par de vraies premières victoires")
		var other: String = JSON.stringify(p.data.banks[1-faction]);var xp: int = p.data.banks[faction].xp;var points: int = p.data.banks[faction].points
		check(p.buy_shop_unit(faction,cards[0].id) and p.data.banks[faction].resource == 240 and p.selected_shop_type(faction) == -1,"L’achat permanent à 180 PO ne sélectionne pas automatiquement la quatrième option")
		var before: String = JSON.stringify(p.data)
		check(not p.buy_shop_unit(faction,cards[0].id) and not p.buy_shop_unit(faction,other_cards[0].id) and not p.buy_shop_unit(2,cards[0].id) and JSON.stringify(p.data) == before,"Double achat, autre faction et faction inconnue refusés sans débit")
		check(p.select_shop_unit(faction,cards[0].id) and p.selected_shop_type(faction) == cards[0].type,"Choix explicite parmi les unités possédées")
		check(not p.select_shop_unit(faction,cards[1].id) and not p.select_shop_unit(faction,other_cards[0].id),"Une unité non possédée ou du camp opposé n’est pas sélectionnable")
		p.shop_locked = true;before = JSON.stringify(p.data)
		check(not p.buy_shop_unit(faction,cards[1].id) and not p.select_shop_unit(faction,"") and JSON.stringify(p.data) == before,"Session verrouillée : ni achat ni changement d’alternative")
		p.shop_locked = false
		check(p.buy_shop_unit(faction,cards[1].id) and p.data.banks[faction].resource == 0 and p.select_shop_unit(faction,cards[1].id),"Le second achat débite son prix exact et permet de changer le choix hors mission")
		check(p.data.banks[faction].xp == xp and p.data.banks[faction].points == points and JSON.stringify(p.data.banks[1-faction]) == other,"Les achats ne consomment ni XP ni points et n’affectent pas l’autre banque")
		Profile.Codec.cache.clear();p = Profile.new(path)
		check(not p.blocked and p.data.schema == 7 and p.data.banks[faction].shop_owned.size() == 2 and p.selected_shop_type(faction) == cards[1].type and p.data.banks[faction].resource == 0,"Achats, solde et choix retrouvés après fermeture et relecture protégée")
		check(p.select_shop_unit(faction,"") and p.selected_shop_type(faction) == -1 and p.data.banks[faction].shop_owned.size() == 2,"Retirer l’alternative ne détruit ni ne rembourse l’unité possédée")
		for malformed in [{cards[0].id:-1},{cards[0].id:1.5},{cards[0].id:true},{other_cards[0].id:180},{"unknown.unit":180}]:
			var bad: Dictionary = Profile.fresh();bad.banks[faction].shop_owned = malformed
			check(not Profile.valid(bad),"Inventaire malformé, prix invalide et unité étrangère refusés")
		var legacy: Dictionary = Profile.fresh();legacy.schema = 6;legacy.banks[faction].resource = 420
		for bank in legacy.banks: bank.erase("shop_owned");bank.erase("shop_selected")
		var old_path: String = path+"_legacy";var f := FileAccess.open(old_path,FileAccess.WRITE);f.store_buffer(Profile.Codec.encode(legacy));f.close()
		p = Profile.new(old_path)
		check(not p.blocked and p.data.schema == 7 and p.data.banks[faction].resource == 420 and p.data.banks[faction].shop_owned.is_empty() and p._read(old_path+".v098.bak") == JSON.parse_string(JSON.stringify(legacy)),"Migration du schéma 6 : archive exacte et acquis conservés, aucune unité inventée")
		cleanup(path);cleanup(old_path)
	var refusing = RefusingProfile.new("");refusing.data.banks[0].resource = 420
	var before: String = JSON.stringify(refusing.data)
	check(not refusing.buy_shop_unit(0,Shop.CARDS[0].id) and JSON.stringify(refusing.data) == before,"Un refus d’écriture ne publie ni débit ni propriété en mémoire")
	check(not Shop.valid_inventory(0,{},Shop.CARDS[0].id),"Un choix sans possession correspondante est invalide")
	print("SHOP_PROFILE_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
