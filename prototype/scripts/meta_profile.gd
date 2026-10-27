extends RefCounted
## Transactions persistées avant publication en mémoire. Deux banques indépendantes.
const Talents = preload("res://scripts/meta_talents.gd")
const DEFAULT_PATH: String = "user://progression_factions_v1.json"
var path: String
var error: String = ""
var blocked: bool = false
var data: Dictionary = fresh()

static func fresh() -> Dictionary:
	return {"schema":1,"serial":0,"banks":[bank(),bank()],"run":{"id":0,"faction":0,"completed":0,"victory":false}}

static func bank() -> Dictionary:
	return {"resource":0,"points":0,"resets":0,"ranks":[0,0,0,0,0,0,0,0,0]}

func _init(save_path: String = DEFAULT_PATH) -> void:
	path = save_path
	if not path.is_empty(): load_profile()

static func valid(value: Variant) -> bool:
	if not value is Dictionary or value.get("schema") != 1 or not Talents.integer(value.get("serial"),0,1000000000): return false
	if not value.get("banks") is Array or value.banks.size() != 2 or not value.get("run") is Dictionary: return false
	for item in value.banks:
		if not item is Dictionary: return false
		for key in ["resource","points","resets"]:
			if not Talents.integer(item.get(key),0,1000000000): return false
		if not Talents.valid(item.get("ranks")) or Talents.spent(item.ranks) > item.points: return false
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
	if valid(value): data = value; return true
	value = _read(path+".bak")
	if valid(value):
		data = value
		error = "Profil restauré depuis sa sauvegarde de secours."
		return true
	blocked = true
	error = "Profil illisible : progression protégée. Aucun fichier n’a été remplacé."
	return false

func _commit(candidate: Dictionary) -> bool:
	if blocked or not valid(candidate):
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
	if faction not in [0,1] or data.banks[faction].resource < Talents.POINT_PRICE or data.banks[faction].points >= 12: return false
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
