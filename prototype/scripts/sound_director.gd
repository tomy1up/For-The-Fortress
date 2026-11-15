extends RefCounted
## Déclenche les sons de combat d'après les événements du modèle (tirs, impacts, éliminations), sans jamais écrire dans le modèle.
## Les instants suivent le rendu : le tir sonne au lâcher visuel (`LAUNCH_DELAYS`), l'impact à l'arrivée du projectile. Pause et vitesse suivent `model.elapsed`.
const Model = preload("res://scripts/valley_model.gd")
const Bank = preload("res://scripts/sound_bank.gd")
const MERGE_WINDOW := 0.08 # secondes simulées : des éliminations plus rapprochées ne font qu'un son
const STALE := 0.5 # un son en retard de plus de 0,5 s (pause, saut de temps) est abandonné plutôt que rejoué
var _seen_shots: Dictionary = {}
var _seen_eliminations: Dictionary = {}
var _pending: Array[Dictionary] = []
var _last_down: float = -100.0
var _last_elapsed: float = 0.0
var _model_id: int = 0
var _launch_delay: Callable # secondes entre le tir et le lâcher visuel (valley_view.launch_delay)
var _flight: float = 0.12

func _init(launch_delay: Callable = Callable(), flight: float = 0.12) -> void:
	_launch_delay = launch_delay
	_flight = flight

## Retourne les sons à jouer maintenant : [{"event": nom, "db": gain, "index": numéro pour varier le fichier}].
func update(model) -> Array[Dictionary]:
	var due: Array[Dictionary] = []
	if model == null: return due
	# Nouveau modèle ou temps de combat remis à zéro (nouvelle vague, nouvelle partie) : on repart d'un état vide.
	if model.get_instance_id() != _model_id or model.elapsed < _last_elapsed-0.0001: _reset(model)
	_last_elapsed = model.elapsed
	for shot in model.shots:
		var key: String = "%s:%s:%.6f" % [shot.get("slot",-1),shot.get("type",-1),float(shot.time)]
		if _seen_shots.has(key): continue
		_seen_shots[key] = true
		var type: int = int(shot.get("type",-1))
		var family: int = Model.family(type)
		var delay: float = float(_launch_delay.call(shot)) if _launch_delay.is_valid() else 0.0
		_pending.append({"time":float(shot.time)+delay,"event":Bank.shot_event(type,family),"index":int(shot.get("slot",0))})
		_pending.append({"time":float(shot.time)+delay+_flight,"event":Bank.impact_event(family),"index":int(shot.get("slot",0))})
	for event in model.elimination_events:
		var key: String = "%s:%.6f" % [event.get("enemy_id",-1),float(event.time)]
		if _seen_eliminations.has(key): continue
		_seen_eliminations[key] = true
		if float(event.time)-_last_down >= MERGE_WINDOW:
			_last_down = float(event.time)
			_pending.append({"time":float(event.time),"event":"enemy.down","index":int(event.get("enemy_id",0))})
	var waiting: Array[Dictionary] = []
	for entry in _pending:
		if float(entry.time) > model.elapsed:
			waiting.append(entry)
		elif model.elapsed-float(entry.time) < STALE:
			due.append({"event":entry.event,"db":Bank.gain_db(entry.event),"index":entry.index})
	_pending = waiting
	return due

func _reset(model) -> void:
	_seen_shots.clear();_seen_eliminations.clear();_pending.clear()
	_last_down = -100.0
	_model_id = model.get_instance_id()
