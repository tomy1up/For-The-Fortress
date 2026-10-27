extends SceneTree
## Outil de conversion de confiance pour le développeur ; non exporté dans le jeu.
const Profile = preload("res://scripts/meta_profile.gd")
func _initialize() -> void:
	var input: String = "";var output: String = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--input="): input = argument.trim_prefix("--input=")
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
	if input.is_empty() or output.is_empty() or FileAccess.file_exists(output): print("CONVERSION_REFUSED");quit(2);return
	var file := FileAccess.open(input,FileAccess.READ)
	if file == null or file.get_length() > 1048576: print("CONVERSION_REFUSED");quit(2);return
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not Profile.valid(parser.data): print("CONVERSION_REFUSED");quit(2);return
	var protected: PackedByteArray = Profile.Codec.encode(parser.data)
	if protected.is_empty(): print("CONVERSION_FAILED");quit(1);return
	var target := FileAccess.open(output,FileAccess.WRITE)
	if target == null: print("CONVERSION_FAILED");quit(1);return
	target.store_buffer(protected);target.flush();var error: Error = target.get_error();target.close()
	Profile.Codec.cache.clear()
	var decoded: Variant = Profile.Codec.decode(FileAccess.get_file_as_bytes(output))
	if error != OK or not Profile.valid(decoded) or decoded != parser.data: print("CONVERSION_FAILED");quit(1);return
	print("CONVERSION_OK_ORIGINAL_PRESERVED");quit(0)
