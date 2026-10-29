extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void:
	var path: String = ProjectSettings.globalize_path("user://test_profile_relaunch_%d.json" % Time.get_ticks_usec())
	for mode in ["seed","verify","begin","verify"]:
		var output: Array = []
		var code: int = OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/profile_relaunch_fixture.gd","--","--save="+path,"--mode="+mode],output,true,false)
		var log: String = "\n".join(output)
		check(code == 0 and not log.contains("ERROR:"),"Processus de jeu séparé terminé proprement : "+mode)
		check(log.contains("PROFILE_RELAUNCH_"+mode.to_upper()+"=true"),"Progression intacte après ouverture/fermeture : "+mode)
	var saved: Variant = Profile.new(path).data
	check(saved is Dictionary and saved.banks[0].resource == 60 and saved.banks[1].resource == 60,"Deux réserves permanentes conservées sur disque après quatre processus")
	check(saved is Dictionary and not saved.run.settled,"Fermer une nouvelle partie sans résultat ne détruit pas la progression acquise")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("PROFILE_RELAUNCH_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
