extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void:
	var path: String = "user://test_integrity_%d.json" % Time.get_ticks_usec()
	var p = Profile.new(path);var id: int = p.begin_run(0)
	check(id > 0 and p.credit(id,0,10,true) and p.buy_point(0) and p.allocate(0,0),"Profil protégé créé et progression enregistrée")
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var good_backup: PackedByteArray = FileAccess.get_file_as_bytes(path+".bak")
	check(bytes.slice(0,Profile.Codec.MAGIC.length()) == Profile.Codec.MAGIC.to_utf8_buffer(),"Format de sauvegarde protégé explicite")
	check(not bytes.hex_encode().contains(JSON.stringify(p.data).to_utf8_buffer().hex_encode()),"Progression absente en clair du fichier")
	Profile.Codec.cache.clear();var reopened = Profile.new(path)
	check(not reopened.blocked and reopened.data.banks[0].resource == 50 and reopened.data.banks[0].ranks[0] == 1,"Déchiffrement Windows et reprise du profil après suppression du cache")
	bytes[bytes.size()-8] = bytes[bytes.size()-8] ^ 1
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_buffer(bytes);file.close()
	Profile.Codec.cache.clear();var recovered = Profile.new(path)
	check(not recovered.blocked and recovered.error.contains("secours") and recovered.data.banks[0].resource == 50,"Octet modifié : principal rejeté, secours valide utilisé")
	file = FileAccess.open(path+".bak",FileAccess.WRITE);file.store_buffer(bytes);file.close()
	Profile.Codec.cache.clear();var both_bad = Profile.new(path)
	check(both_bad.blocked and FileAccess.get_file_as_bytes(path) == bytes,"Deux fichiers binaires altérés : refus sans écrasement ni décodage texte")
	file = FileAccess.open(path+".bak",FileAccess.WRITE);file.store_buffer(good_backup);file.close()
	var forged: Dictionary = Profile.fresh();forged.banks[0].resource = 999999
	file = FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify(forged));file.close()
	Profile.Codec.cache.clear();recovered = Profile.new(path)
	check(not recovered.blocked and recovered.data.banks[0].resource != 999999,"Faux JSON lisible ignoré en présence d'un secours protégé")
	file = FileAccess.open(path+".bak",FileAccess.WRITE);file.store_string(JSON.stringify(forged));file.close()
	var before: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var blocked = Profile.new(path)
	check(blocked.blocked and blocked.error.contains("non protégé"),"Aucune conversion automatique d'un fichier éditable forgé")
	check(blocked.begin_run(0) == -1 and FileAccess.get_file_as_bytes(path) == before,"Refus fermé : aucune progression neuve n'écrase le fichier suspect")
	# Conversion de confiance distincte du jeu : entrée préservée et jamais importée automatiquement.
	var legacy_path: String = ProjectSettings.globalize_path(path+"_legacy")
	var output_path: String = legacy_path+".protected"
	var legacy: Dictionary = Profile.fresh();legacy.banks[0].resource = 123
	file = FileAccess.open(legacy_path,FileAccess.WRITE);file.store_string(JSON.stringify(legacy));file.close()
	var original: PackedByteArray = FileAccess.get_file_as_bytes(legacy_path)
	var logs: Array = []
	var args: PackedStringArray = ["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/protect_legacy_profile.gd","--","--input="+legacy_path,"--output="+output_path]
	var code: int = OS.execute(OS.get_executable_path(),args,logs,true,false)
	check(code == 0 and "\n".join(logs).contains("CONVERSION_OK_ORIGINAL_PRESERVED"),"Outil de conversion contrôlée exécuté dans un autre processus")
	check(FileAccess.get_file_as_bytes(legacy_path) == original,"Conversion sans modification du fichier d'origine")
	var converted = Profile.new(output_path)
	check(not converted.blocked and converted.data.banks[0].resource == 123,"Ancienne progression retrouvée dans la version protégée")
	var converted_bytes: PackedByteArray = FileAccess.get_file_as_bytes(output_path)
	code = OS.execute(OS.get_executable_path(),args,logs,true,false)
	check(code == 2 and FileAccess.get_file_as_bytes(output_path) == converted_bytes,"Outil incapable d'écraser une conversion existante")
	DirAccess.remove_absolute(legacy_path);DirAccess.remove_absolute(output_path)
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("PROFILE_INTEGRITY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
