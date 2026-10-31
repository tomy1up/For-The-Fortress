extends SceneTree
const Replay = preload("res://tests/report_replay.gd")
func _initialize() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if arguments.size() != 1 or not arguments[0].begins_with("--report=") or arguments[0].trim_prefix("--report=").is_empty():
		print("Usage : godot --headless --path prototype --script res://tests/replay_run.gd -- --report=CHEMIN_RAPPORT_JSON")
		quit(2); return
	var result: Dictionary = Replay.load_and_verify(arguments[0].trim_prefix("--report="))
	print("REPLAY_RESULT=" + JSON.stringify(result))
	if result.get("ok",false) and not result.same_version:
		print("Version source différente : vérification par le simulateur actuel avec les paramètres historiques pris en charge ; ce n’est pas une exécution de l’ancien programme.")
	quit(0 if result.get("ok",false) else 1)
