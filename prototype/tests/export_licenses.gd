extends SceneTree
## Notices extraites du moteur utilisé, sans dépendance à un service externe.
func _initialize() -> void:
	var path: String = "res://distribution/LICENCES_GODOT.txt"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): path = argument.trim_prefix("--output=")
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		push_error("Écriture des licences impossible : "+path)
		quit(1)
		return
	file.store_string("FOR THE FORTRESS! — GODOT ENGINE ET COMPOSANTS TIERS\n\n")
	file.store_string("Moteur : "+Engine.get_version_info().string+"\n")
	file.store_string("Notices extraites du moteur officiel de cette version.\n")
	file.store_string("Le moteur d'édition peut inclure des composants supplémentaires.\n\n")
	file.store_string("LICENCE GODOT ENGINE\n\n"+Engine.get_license_text()+"\n\n")
	file.store_string("ATTRIBUTIONS DES COMPOSANTS TIERS\n\n")
	file.store_string(JSON.stringify(Engine.get_copyright_info(),"  ")+"\n\n")
	var licenses: Dictionary = Engine.get_license_info()
	var names: Array = licenses.keys()
	names.sort()
	for name in names:
		file.store_string("============================================================\n"+str(name)+"\n\n"+str(licenses[name])+"\n\n")
	file.close()
	print("LICENSES_GENERATED=",path)
	quit()
