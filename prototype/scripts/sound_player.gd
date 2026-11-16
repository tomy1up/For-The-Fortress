extends Node
## Lecteur d'effets sonores : un petit ensemble de voix réutilisées, volume général et coupure. Silencieux si le fichier d'un événement n'est pas installé.
const Bank = preload("res://scripts/sound_bank.gd")
const VOICES := 12
const DEFAULT_VOLUME := 0.8 # réglage de prototype à confirmer à l'écoute
static var volume: float = DEFAULT_VOLUME # 0 à 1
static var muted: bool = false
var _voices: Array[AudioStreamPlayer] = []
var _next: int = 0
var _cache: Dictionary = {}
var dry: bool = false # tests : compte les sons sans lancer la lecture
var played: int = 0 # nombre de sons réellement lancés (contrôle des tests)

func _ready() -> void:
	if DisplayServer.get_name() == "headless": dry = true # tests sans écran : pas de lecture réelle
	for _index in range(VOICES):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_voices.append(voice)

## Lance un événement sonore ; retourne vrai si un fichier a été joué.
func play(event: String, db: float = 0.0, index: int = 0) -> bool:
	if muted or volume <= 0.0 or _voices.is_empty(): return false
	var path: String = Bank.stream_path(event,index)
	if path.is_empty(): return false
	if not _cache.has(path): _cache[path] = load(path)
	var stream: AudioStream = _cache[path]
	if stream == null: return false
	var voice: AudioStreamPlayer = _voices[_next]
	_next = (_next+1)%_voices.size()
	voice.stream = stream
	voice.volume_db = db+linear_to_db(clampf(volume,0.0,1.0))
	if not dry: voice.play()
	played += 1
	return true

## Libère les sons chargés (fin de partie, tests).
func release() -> void:
	for voice in _voices:
		voice.stop()
		voice.stream = null
	_cache.clear()

func play_all(entries: Array[Dictionary]) -> void:
	for entry in entries: play(str(entry.event),float(entry.db),int(entry.index))
