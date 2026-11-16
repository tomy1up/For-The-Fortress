extends RefCounted
## Transactions persistées avant publication en mémoire. Deux banques indépendantes.
const Talents = preload("res://scripts/meta_talents.gd")
const Codec = preload("res://scripts/profile_codec.gd")
const Missions = preload("res://scripts/mission_progress.gd")
const Experience = preload("res://scripts/talent_experience.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const SCHEMA_VERSION: int = 7
var shop_locked: bool = false # État de la session, sans changement d’une mission déjà lancée.
var shop_notice: String = ""
const DEFAULT_PATH: String = "user://progression_factions_v1.json"
const WIN_REWARD: int = 5
var path: String
var error: String = ""
var blocked: bool = false
var migration_notice: String = ""
var data: Dictionary = fresh()

static func fresh() -> Dictionary:
	return {"schema":SCHEMA_VERSION,"serial":0,"banks":[bank(),bank()],"run":{"id":0,"faction":0,"completed":0,"victory":false}}

static func bank() -> Dictionary:
	return {"resource":0,"xp":0,"points":0,"resets":0,"ranks":Talents.Linked.empty_ranks(),"mission_rewards":{},"shop_owned":{},"shop_selected":""}

static func resource_total(completed: int, victory: bool = false) -> int:
	if completed < 0 or completed > 10: return 0
	return int(completed*(completed+1)/2)+(WIN_REWARD if victory and completed == 10 else 0)

func _init(save_path: String = DEFAULT_PATH) -> void:
	path = save_path
	if not path.is_empty(): load_profile()

static func valid(value: Variant) -> bool:
	if not value is Dictionary or not Talents.integer(value.get("schema"),1,SCHEMA_VERSION) or not Talents.integer(value.get("serial"),0,1000000000): return false
	if not value.get("banks") is Array or value.banks.size() != 2 or not value.get("run") is Dictionary: return false
	for faction_index in range(2):
		var item: Variant = value.banks[faction_index]
		if not item is Dictionary: return false
		if value.schema >= 7 and not Shop.valid_inventory(faction_index,item.get("shop_owned"),item.get("shop_selected")): return false
		for key in ["resource","points","resets"]:
			if not Talents.integer(item.get(key),0,1000000000): return false
		if not (Talents.Legacy.valid(item.get("ranks")) if value.schema == 1 else Talents.Linked.valid(item.get("ranks")) if value.schema >= 6 else Talents.Expanded.valid(item.get("ranks")) if value.schema >= 4 else Talents.current_valid(item.get("ranks"))): return false
		if value.schema >= 5:
			if not Talents.integer(item.get("xp"),0,1000000000) or item.points < Experience.points_for_xp(int(item.xp)): return false
		if Talents.spent(item.ranks) > item.points: return false
		if value.schema >= 3:
			if not item.get("mission_rewards") is Dictionary or item.mission_rewards.size() > 10000: return false
			for id in item.mission_rewards:
				var receipt: Variant = item.mission_rewards[id]
				if not Missions.valid_id(id) or not receipt is Dictionary: return false
				if not Talents.integer(receipt.get("reward"),0,1000000000) or not Talents.integer(receipt.get("run_id"),1,int(value.serial)): return false
				if receipt.has("xp") and (value.schema < 5 or not Talents.integer(receipt.xp,0,1000000000)): return false

	var run: Dictionary = value.run
	var mission: bool = run.has("mission_id") or run.has("mission_reward") or run.has("mission_waves") or run.has("mission_earned")
	var wave_limit: int = 10
	var with_xp: bool = run.has("mission_xp_reward") or run.has("mission_xp_earned")
	if with_xp:
		if value.schema < 5 or not mission or not Talents.integer(run.get("mission_xp_reward"),0,1000000000) or not Talents.integer(run.get("mission_xp_earned"),0,int(run.mission_xp_reward)): return false
		if (not run.get("settled",false) or not run.get("victory",false)) and run.mission_xp_earned != 0: return false
	if mission:
		if value.schema < 3 or not Missions.valid_id(run.get("mission_id")) or not Talents.integer(run.get("mission_reward"),0,1000000000) or not Talents.integer(run.get("mission_waves"),1,10000): return false
		wave_limit = int(run.mission_waves)
		if not Talents.integer(run.get("mission_earned"),0,int(run.mission_reward)) or not run.get("settled") is bool or run.get("previous_maps") != 0: return false
	if not (Talents.integer(run.get("id"),0,int(value.serial)) and Talents.integer(run.get("faction"),0,1) and Talents.integer(run.get("completed"),0,wave_limit) and run.get("victory") is bool and (not run.victory or run.completed == wave_limit)): return false
	if run.has("settled") or run.has("previous_maps"):
		if not run.get("settled") is bool or not Talents.integer(run.get("previous_maps"),0,1000000000): return false
		if not run.settled and (run.completed != 0 or run.victory or run.previous_maps != 0): return false
	if mission:
		if (not run.settled or not run.victory) and run.mission_earned != 0: return false
		if run.mission_earned > 0:
			var receipt: Variant = value.banks[int(run.faction)].mission_rewards.get(run.mission_id)
			if not receipt is Dictionary or receipt.run_id != run.id or receipt.reward != run.mission_earned: return false
		if with_xp and run.mission_xp_earned > 0:
			var receipt: Variant = value.banks[int(run.faction)].mission_rewards.get(run.mission_id)
			if not receipt is Dictionary or receipt.run_id != run.id or receipt.get("xp") != run.mission_xp_earned: return false
	return true

func _read(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path): return null
	var file := FileAccess.open(file_path,FileAccess.READ)
	if file == null or file.get_length() > 1048576: return null
	return Codec.decode(file.get_buffer(file.get_length()))

func load_profile() -> bool:
	if not FileAccess.file_exists(path) and not FileAccess.file_exists(path+".bak"): return true
	var value: Variant = _read(path)
	if valid(value): return _accept_loaded(value)
	value = _read(path+".bak")
	if valid(value):
		if not _accept_loaded(value): return false
		error = "Profil restauré depuis sa sauvegarde de secours."
		return true
	blocked = true
	error = "Profil illisible ou modifié : progression protégée. Aucun fichier n’a été remplacé."
	if _legacy_json(path) or _legacy_json(path+".bak"):
		error = "Ancien profil non protégé : conversion contrôlée nécessaire. Fichiers conservés."
	return false

func _legacy_json(file_path: String) -> bool:
	var file := FileAccess.open(file_path,FileAccess.READ)
	if file == null: return false
	for byte in file.get_buffer(mini(64,file.get_length())):
		if byte in [9,10,13,32]: continue
		return byte == 123
	return false

func _accept_loaded(value: Dictionary) -> bool:
	if value.schema == SCHEMA_VERSION:
		if not _has_retired_units(value): data = value;return true
		# Unités retirées de la boutique (v0.217) : on archive le profil, on les désélectionne et on rembourse une seule fois les PO enregistrées.
		if not _archive_previous(value,".v216.bak",SCHEMA_VERSION): return false
		var upgraded: Dictionary = value.duplicate(true)
		var refunded: int = _refund_retired_units(upgraded)
		if not _commit(upgraded): blocked = true;return false
		migration_notice = "Boutique limitée à 20 unités : Fantassin squelette et Tirailleur gnome retirés, %d PO remboursées." % refunded
		return true
	if value.schema == 6:
		if not _archive_previous(value,".v098.bak",6): return false
		var upgraded: Dictionary = value.duplicate(true)
		if not _commit(upgraded): blocked = true;return false
		migration_notice = "Boutique préparée : PO, XP, talents et missions conservés."
		return true
	if value.schema == 5:
		if not _archive_previous(value,".v087.bak",5): return false
		var upgraded: Dictionary = value.duplicate(true);upgraded.schema = 6
		var refunded: bool = _convert_linked_ranks(upgraded)
		if not _commit(upgraded): blocked = true;return false
		migration_notice = "Arbres liés : points rendus gratuitement pour adapter vos talents. PO et XP conservées." if refunded else "Arbres liés : points, investissements, PO et XP conservés."
		return true
	if value.schema == 4:
		if not _archive_previous(value,".v086.bak",4): return false
		var upgraded: Dictionary = value.duplicate(true);upgraded.schema = 6
		for item in upgraded.banks: item.xp = Experience.xp_for_points(mini(int(item.points),Experience.MAX_POINTS))
		var refunded: bool = _convert_linked_ranks(upgraded)
		if not _commit(upgraded): blocked = true;return false
		migration_notice = "Arbres liés : points rendus gratuitement pour adapter vos talents. PO et XP conservées." if refunded else "Progression XP et arbres liés : points, talents et PO conservés."
		return true
	if value.schema == 3:
		if not _archive_previous(value,".v084.bak",3): return false
		var upgraded: Dictionary = value.duplicate(true);upgraded.schema = 6
		for item in upgraded.banks:
			item.ranks = Talents.Expanded.normalize(item.ranks);item.xp = Experience.xp_for_points(mini(int(item.points),Experience.MAX_POINTS))
		_convert_linked_ranks(upgraded)
		if not _commit(upgraded): blocked = true;return false
		migration_notice = "Arbres enrichis : points, talents investis et acquis conservés."
		return true
	if value.schema == 2:
		if not _archive_previous(value,".v082.bak",2): return false
		var upgraded: Dictionary = value.duplicate(true);upgraded.schema = 6
		for item in upgraded.banks:
			item.mission_rewards = {};item.ranks = Talents.Expanded.normalize(item.ranks);item.xp = Experience.xp_for_points(mini(int(item.points),Experience.MAX_POINTS))
		_convert_linked_ranks(upgraded)
		if not _commit(upgraded): blocked = true;return false
		migration_notice = "Sauvegarde préparée pour les premières victoires : acquis conservés."
		return true
	if not path.is_empty() and FileAccess.file_exists(path+".v067.bak"):
		var previous_archive: Variant = _read(path+".v067.bak")
		if not valid(previous_archive) or previous_archive.schema != 1:
			blocked = true;error = "Migration annulée : copie du profil précédent à vérifier.";return false
	if not path.is_empty() and not FileAccess.file_exists(path+".v067.bak"):
		var archive := FileAccess.open(path+".v067.bak",FileAccess.WRITE)
		if archive == null:
			blocked = true;error = "Migration annulée : copie du profil précédent impossible.";return false
		var sealed: PackedByteArray = Codec.encode(value)
		if sealed.is_empty(): archive.close();blocked = true;error = "Protection Windows indisponible : migration annulée.";return false
		archive.store_buffer(sealed);archive.flush()
		var archive_error: Error = archive.get_error();archive.close()
		if archive_error != OK or not valid(_read(path+".v067.bak")):
			blocked = true;error = "Migration annulée : copie de secours incomplète.";return false
	var upgraded: Dictionary = value.duplicate(true);upgraded.schema = 6
	for item in upgraded.banks:
		item.ranks = Talents.Expanded.empty_ranks();item.mission_rewards = {};item.xp = Experience.xp_for_points(mini(int(item.points),Experience.MAX_POINTS))
	_convert_linked_ranks(upgraded)
	if not _commit(upgraded):
		blocked = true;return false
	migration_notice = "Arbres mis à jour : vos points investis ont été rendus gratuitement."
	return true

static func _has_retired_units(value: Dictionary) -> bool:
	for item in value.banks:
		if item is Dictionary and item.get("shop_owned") is Dictionary:
			for id in item.shop_owned:
				if not Shop.retired_card(id).is_empty(): return true
	return false

## Retire des banques les unités de boutique retirées : désélection si besoin, remboursement unique des PO réellement payées. Retourne le total remboursé.
static func _refund_retired_units(value: Dictionary) -> int:
	var total: int = 0
	for item in value.banks:
		for id in item.shop_owned.keys():
			if Shop.retired_card(id).is_empty(): continue
			var paid: int = int(item.shop_owned[id])
			item.shop_owned.erase(id)
			item.resource = mini(int(item.resource)+paid,1000000000)
			total += paid
			if item.shop_selected == id: item.shop_selected = ""
	return total

static func _convert_linked_ranks(value: Dictionary) -> bool:
	var refunded: bool = false
	for item in value.banks:
		var converted: Array = Talents.Linked.normalize(item.ranks)
		if converted.is_empty():
			item.ranks = Talents.Linked.empty_ranks();refunded = true
		else: item.ranks = converted
	return refunded

func _archive_previous(value: Dictionary, suffix: String, schema: int) -> bool:
	if path.is_empty(): return true
	var archive_path: String = path+suffix
	if FileAccess.file_exists(archive_path):
		var previous: Variant = _read(archive_path)
		if valid(previous) and previous.schema == schema: return true
		blocked = true;error = "Migration annulée : copie du profil précédent à vérifier.";return false
	var sealed: PackedByteArray = Codec.encode(value)
	if sealed.is_empty(): blocked = true;error = "Protection Windows indisponible : migration annulée.";return false
	var archive := FileAccess.open(archive_path,FileAccess.WRITE)
	if archive == null: blocked = true;error = "Migration annulée : copie du profil précédent impossible.";return false
	archive.store_buffer(sealed);archive.flush();var failure: Error = archive.get_error();archive.close()
	if failure != OK or _read(archive_path) != value:
		blocked = true;error = "Migration annulée : copie du profil précédent incomplète.";return false
	return true

func _commit(candidate: Dictionary) -> bool:
	# Les versions antérieures sont conservées en archive avant cette conversion.
	if candidate.get("schema") == 6 and candidate.get("banks") is Array:
		candidate = candidate.duplicate(true);candidate.schema = SCHEMA_VERSION
		for item in candidate.banks:
			if item is Dictionary: item.shop_owned = {};item.shop_selected = ""
	# Les transactions sur un ancien cliché à quinze rangs sont canonisées avant validation.
	if candidate.get("schema") in [6,SCHEMA_VERSION] and candidate.get("banks") is Array:
		for item in candidate.banks:
			if item is Dictionary and Talents.current_valid(item.get("ranks")):
				item.ranks = Talents.Linked.normalize(item.ranks)
	if blocked or not valid(candidate) or candidate.schema != SCHEMA_VERSION:
		if not blocked: error = "Opération de progression invalide."
		return false
	if path.is_empty(): data = candidate;error = "";return true # Profil éphémère réservé aux tests/captures.
	var sealed: PackedByteArray = Codec.encode(candidate)
	if sealed.is_empty(): error = "Protection Windows indisponible : enregistrement annulé.";return false
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null: error = "Impossible d’enregistrer la progression."; return false
	file.store_buffer(sealed);file.flush()
	var failure: Error = file.get_error();file.close()
	if failure != OK or not valid(_read(path+".tmp")):
		error = "Enregistrement incomplet : opération annulée."; return false
	# Garder un profil valide en secours avant de remplacer le fichier principal.
	if valid(_read(path)):
		if DirAccess.copy_absolute(path,path+".bak") != OK:
			error = "Copie de secours impossible : opération annulée."; return false
	# Renommage de remplacement du fichier temporaire, sur le même volume.
	if DirAccess.rename_absolute(path+".tmp",path) != OK:
		error = "Remplacement du profil impossible : opération annulée."; return false
	data = candidate;error = ""
	return true

func begin_run(faction: int, mission_id: String = "", reward: int = 0, wave_count: int = 10, xp_reward: int = 0) -> int:
	if faction not in [0,1] or xp_reward < 0 or xp_reward > 1000000000 or (mission_id.is_empty() and xp_reward != 0) or (not mission_id.is_empty() and (not Missions.valid_id(mission_id) or reward < 0 or reward > 1000000000 or wave_count < 1 or wave_count > 10000)): return -1
	var next: Dictionary = data.duplicate(true)
	next.serial += 1
	next.run = {"id":next.serial,"faction":faction,"completed":0,"victory":false,"settled":false,"previous_maps":0}
	if not mission_id.is_empty(): next.run.merge({"mission_id":mission_id,"mission_reward":reward,"mission_waves":wave_count,"mission_earned":0})
	if xp_reward > 0: next.run.merge({"mission_xp_reward":xp_reward,"mission_xp_earned":0})
	return int(next.serial) if _commit(next) else -1

func credit(run_id: int, faction: int, completed: int, victory: bool, previous_maps: int = 0) -> bool:
	# Chemin historique du prototype ; les tentatives de mission passent par credit_mission.
	if data.run.has("mission_id"): return false
	if blocked or run_id <= 0 or data.run.id != run_id or data.run.faction != faction or completed < 0 or completed > 10 or previous_maps < 0 or (victory and completed != 10): return false
	if not data.run.has("settled"): return false # Ancien parcours déjà crédité : ne pas le rémunérer à nouveau.
	if data.run.settled: return completed == data.run.completed and victory == data.run.victory and previous_maps == data.run.previous_maps
	var next: Dictionary = data.duplicate(true)
	next.banks[faction].resource += resource_total(completed,victory)+previous_maps
	next.run.completed = completed;next.run.victory = victory
	next.run.settled = true;next.run.previous_maps = previous_maps
	return _commit(next)

func begin_mission(faction: int, mission_id: String, reward: int, wave_count: int = 10, xp_reward: int = 0) -> int:
	if not Missions.valid_id(mission_id): return -1
	return begin_run(faction,mission_id,reward,wave_count,xp_reward)

func campaign_status(faction: int) -> Dictionary:
	if blocked or faction not in [0,1]: return {}
	return Missions.campaign_status(data.banks[faction].mission_rewards)

func credit_mission(run_id: int, faction: int, completed: int, victory: bool) -> bool:
	if blocked or not data.run.has("mission_id") or run_id <= 0 or data.run.id != run_id or data.run.faction != faction: return false
	if completed < 0 or completed > data.run.mission_waves or (victory and completed != data.run.mission_waves): return false
	if data.run.settled: return completed == data.run.completed and victory == data.run.victory
	var next: Dictionary = data.duplicate(true)
	var mission_id: String = next.run.mission_id
	var earned: int = 0
	var xp_earned: int = 0
	if victory and not next.banks[faction].mission_rewards.has(mission_id):
		earned = next.run.mission_reward
		next.banks[faction].mission_rewards[mission_id] = {"reward":earned,"run_id":run_id}
		next.banks[faction].resource += earned
		if next.run.has("mission_xp_reward"):
			xp_earned = next.run.mission_xp_reward
			next.banks[faction].mission_rewards[mission_id].xp = xp_earned
			next.banks[faction].xp += xp_earned
			next.banks[faction].points = maxi(int(next.banks[faction].points),Experience.points_for_xp(int(next.banks[faction].xp)))
	next.run.completed = completed;next.run.victory = victory
	next.run.settled = true;next.run.mission_earned = earned
	if next.run.has("mission_xp_reward"): next.run.mission_xp_earned = xp_earned
	return _commit(next)

func buy_point(_faction: int) -> bool:
	# Ancien point d’entrée conservé pour refuser explicitement tout achat en PO.
	error = "Les points de talent se débloquent avec l’XP des missions."
	return false

func allocate(faction: int, index: int) -> bool:
	if faction not in [0,1]: return false
	var ranks: Array = Talents.Linked.normalize(data.banks[faction].ranks)
	if not Talents.Linked.allocation_error(ranks,index,int(data.banks[faction].points),faction).is_empty(): return false
	var next: Dictionary = data.duplicate(true);next.banks[faction].ranks = ranks
	next.banks[faction].ranks[index] += 1
	return _commit(next)

func reset_price(_faction: int) -> int:
	return 0

func respec(faction: int) -> bool:
	if faction not in [0,1] or Talents.spent(data.banks[faction].ranks) == 0: return false
	var next: Dictionary = data.duplicate(true)
	next.banks[faction].resets = mini(int(next.banks[faction].resets)+1,1000000000)
	next.banks[faction].ranks = bank().ranks
	return _commit(next)

func shop_error(faction: int, id: String) -> String:
	if blocked: return error if not error.is_empty() else "Progression indisponible."
	if shop_locked: return "La boutique est accessible entre les missions."
	if faction not in [0,1]: return "Faction inconnue."
	var entry: Dictionary = Shop.card(id)
	if entry.is_empty() or entry.faction != faction: return "Cette unité n’appartient pas à cette faction."
	if data.banks[faction].shop_owned.has(id): return "Unité déjà acquise."
	if int(entry.get("unlock_missions",0)) > int(campaign_status(faction).completed): return "Disponible après %d missions réussies avec cette faction." % int(entry.unlock_missions)
	if data.banks[faction].resource < entry.po: return "PO insuffisantes : %d requises." % entry.po
	return ""

func buy_shop_unit(faction: int, id: String) -> bool:
	var problem: String = shop_error(faction,id)
	if not problem.is_empty(): shop_notice = problem;return false
	var entry: Dictionary = Shop.card(id);var next: Dictionary = data.duplicate(true)
	next.banks[faction].resource -= entry.po
	next.banks[faction].shop_owned[id] = int(entry.po)
	var saved: bool = _commit(next)
	shop_notice = "" if saved else error
	return saved

## Profil d'essai (`--essai-boutique`) : toutes les unités de boutique des deux factions sont possédées, sans PO dépensées ; aucun effet sur le profil de jeu normal (autre fichier).
func grant_all_shop_units() -> bool:
	if blocked: return false
	var next: Dictionary = data.duplicate(true)
	var changed: bool = false
	for faction in range(2):
		for card in Shop.for_faction(faction):
			if not next.banks[faction].shop_owned.has(card.id):
				next.banks[faction].shop_owned[card.id] = 0
				changed = true
	return _commit(next) if changed else true

func select_shop_unit(faction: int, id: String) -> bool:
	if blocked or shop_locked or faction not in [0,1]: return false
	if not id.is_empty() and not data.banks[faction].shop_owned.has(id): return false
	if data.banks[faction].shop_selected == id: return true
	var next: Dictionary = data.duplicate(true);next.banks[faction].shop_selected = id
	return _commit(next)

func selected_shop_type(faction: int) -> int:
	if blocked or faction not in [0,1]: return -1
	var entry: Dictionary = Shop.card(data.banks[faction].shop_selected)
	return int(entry.type) if not entry.is_empty() and entry.faction == faction and data.banks[faction].shop_owned.has(entry.id) else -1
