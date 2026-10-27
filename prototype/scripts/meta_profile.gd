extends RefCounted
## Transactions persistées avant publication en mémoire. Deux banques indépendantes.
const Talents = preload("res://scripts/meta_talents.gd")
const DEFAULT_PATH: String = "user://progression_factions_v1.json"
var path: String
var error: String = ""
var blocked: bool = false
var migration_notice: String = ""
var data: Dictionary = fresh()

static func fresh() -> Dictionary:
	return {"schema":2,"serial":0,"banks":[bank(),bank()],"run":{"id":0,"faction":0,"completed":0,"victory":false}}

static func bank() -> Dictionary:
	return {"resource":0,"points":0,"resets":0,"ranks":Talents.empty_ranks()}

func _init(save_path: String = DEFAULT_PATH) -> void:
	path = save_path
	if not path.is_empty(): load_profile()

static func valid(value: Variant) -> bool:
	if not value is Dictionary or not Talents.integer(value.get("schema"),1,2) or not Talents.integer(value.get("serial"),0,1000000000): return false
	if not value.get("banks") is Array or value.banks.size() != 2 or not value.get("run") is Dictionary: return false
	for item in value.banks:
		if not item is Dictionary: return false
		for key in ["resource","points","resets"]:
			if not Talents.integer(item.get(key),0,1000000000): return false
		if not (Talents.Legacy.valid(item.get("ranks")) if value.schema == 1 else Talents.current_valid(item.get("ranks"))): return false
		if Talents.spent(item.ranks) > item.points: return false
	var run: Dictionary = value.run
	return Talents.integer(run.get("id"),0,int(value.serial)) and Talents.integer(run.get("faction"),0,1) and Talents.integer(run.get("completed"),0,10) and run.get("victory") is bool and (not run.victory or run.completed == 10)

func _read(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path): return null
	var file := FileAccess.open(file_path,FileAccess.READ)
	if file == null or file.get_length() > 65536: return null
	var parser := JSON.new()
	return parser.data if parser.parse(file.get_as_text()) == OK else null

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
	error = "Profil illisible : progression protégée. Aucun fichier n’a été remplacé."
	return false

func _accept_loaded(value: Dictionary) -> bool:
	if value.schema == 2: data = value;return true
	if not path.is_empty() and FileAccess.file_exists(path+".v067.bak"):
		var previous_archive: Variant = _read(path+".v067.bak")
		if not valid(previous_archive) or previous_archive.schema != 1:
			blocked = true;error = "Migration annulée : copie du profil précédent à vérifier.";return false
	if not path.is_empty() and not FileAccess.file_exists(path+".v067.bak"):
		var archive := FileAccess.open(path+".v067.bak",FileAccess.WRITE)
		if archive == null:
			blocked = true;error = "Migration annulée : copie du profil précédent impossible.";return false
		archive.store_string(JSON.stringify(value));archive.flush()
		var archive_error: Error = archive.get_error();archive.close()
		if archive_error != OK or not valid(_read(path+".v067.bak")):
			blocked = true;error = "Migration annulée : copie de secours incomplète.";return false
	var upgraded: Dictionary = value.duplicate(true);upgraded.schema = 2
	for item in upgraded.banks: item.ranks = Talents.empty_ranks()
	if not _commit(upgraded):
		blocked = true;return false
	migration_notice = "Arbres mis à jour : vos points investis ont été rendus gratuitement."
	return true

func _commit(candidate: Dictionary) -> bool:
	if blocked or not valid(candidate) or candidate.schema != 2:
		if not blocked: error = "Opération de progression invalide."
		return false
	if path.is_empty(): data = candidate;error = "";return true # Profil éphémère réservé aux tests/captures.
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null: error = "Impossible d’enregistrer la progression."; return false
	file.store_string(JSON.stringify(candidate));file.flush()
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

func begin_run(faction: int) -> int:
	if faction not in [0,1]: return -1
	var next: Dictionary = data.duplicate(true)
	next.serial += 1
	next.run = {"id":next.serial,"faction":faction,"completed":0,"victory":false}
	return int(next.serial) if _commit(next) else -1

func credit(run_id: int, faction: int, completed: int, victory: bool) -> bool:
	if blocked or run_id <= 0 or data.run.id != run_id or data.run.faction != faction or completed < data.run.completed or completed > 10 or (victory and completed != 10): return false
	if completed == data.run.completed and (not victory or data.run.victory): return true
	var next: Dictionary = data.duplicate(true)
	for wave in range(int(next.run.completed)+1,completed+1): next.banks[faction].resource += wave
	if victory and not next.run.victory: next.banks[faction].resource += 5
	next.run.completed = completed;next.run.victory = next.run.victory or victory
	return _commit(next)

func buy_point(faction: int) -> bool:
	if faction not in [0,1] or data.banks[faction].resource < Talents.POINT_PRICE or data.banks[faction].points >= Talents.MAX_POINTS: return false
	var next: Dictionary = data.duplicate(true)
	next.banks[faction].resource -= Talents.POINT_PRICE;next.banks[faction].points += 1
	return _commit(next)

func allocate(faction: int, index: int) -> bool:
	if faction not in [0,1] or not Talents.can_allocate(data.banks[faction].ranks,index,int(data.banks[faction].points)): return false
	var next: Dictionary = data.duplicate(true);next.banks[faction].ranks[index] += 1
	return _commit(next)

func reset_price(faction: int) -> int:
	if faction not in [0,1]: return 0
	return Talents.RESET_PRICES[mini(int(data.banks[faction].resets),Talents.RESET_PRICES.size()-1)]

func respec(faction: int) -> bool:
	if faction not in [0,1] or Talents.spent(data.banks[faction].ranks) == 0 or data.banks[faction].resource < reset_price(faction): return false
	var next: Dictionary = data.duplicate(true)
	next.banks[faction].resource -= reset_price(faction);next.banks[faction].resets += 1
	next.banks[faction].ranks = bank().ranks
	return _commit(next)
