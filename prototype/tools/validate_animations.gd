extends SceneTree
## Contrôle des animations déposées dans assets/animations (format : design/Format_animations.md).
## Usage : Godot --headless --path prototype --script res://tools/validate_animations.gd
const Library = preload("res://scripts/animation_library.gd")

func _initialize() -> void:
	var problems := 0
	var count := 0
	var directory := DirAccess.open(Library.ROOT)
	if directory != null:
		for name in directory.get_directories():
			count += 1
			var path: String = Library.description_path(name)
			if not FileAccess.file_exists(path):
				print("ERREUR %s : animation.json absent." % name);problems += 1;continue
			var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			var error: String = Library.validation_error(data,name)
			if error != "":
				print("ERREUR %s : %s" % [name,error]);problems += 1;continue
			var listed := {}
			for animation_name in data.animations:
				var anim: Dictionary = data.animations[animation_name]
				listed[anim.file] = true
				var texture: Texture2D = Library.texture_for(name,anim)
				if texture == null:
					print("ERREUR %s/%s : planche %s introuvable ou illisible." % [name,animation_name,anim.file]);problems += 1;continue
				var size_error: String = Library.sheet_size_error(anim,Vector2i(texture.get_size()))
				if size_error != "":
					print("ERREUR %s/%s : %s" % [name,animation_name,size_error]);problems += 1
					continue
				print("ok %s/%s : %d images de %dx%d, mode %s" % [name,animation_name,int(anim.frames),int(anim.frame_size[0]),int(anim.frame_size[1]),anim.mode])
			var folder := DirAccess.open(Library.ROOT + name)
			for file in folder.get_files():
				if file.ends_with(".png") and not listed.has(file): print("avertissement %s : %s n'est décrit par aucune animation." % [name,file])
	print("VALIDATION_ANIMATIONS dossiers=%d problemes=%d" % [count,problems])
	quit(1 if problems > 0 else 0)
