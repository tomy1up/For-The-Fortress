extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
func _initialize() -> void:
	var path: String = "";var mode: String = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--save="): path = argument.trim_prefix("--save=")
		if argument.begins_with("--mode="): mode = argument.trim_prefix("--mode=")
	if not path.get_file().begins_with("test_profile_relaunch_") or path.get_base_dir().simplify_path() != OS.get_user_data_dir().simplify_path(): quit(2);return
	var profile = Profile.new(path)
	var ok: bool = not profile.blocked
	if mode == "seed":
		var first: int = profile.begin_run(0)
		ok = ok and profile.credit(first,0,10,true) and profile.buy_point(0) and profile.allocate(0,0) and profile.respec(0) and profile.allocate(0,0)
		var second: int = profile.begin_run(1)
		ok = ok and profile.credit(second,1,10,true) and profile.buy_point(1) and profile.buy_point(1) and profile.allocate(1,0) and profile.allocate(1,0) and profile.respec(1) and profile.allocate(1,0) and profile.allocate(1,0)
	elif mode == "begin":
		ok = ok and profile.begin_run(0) > 0
	elif mode != "verify": ok = false
	for camp in range(2):
		var bank: Dictionary = profile.data.banks[camp]
		ok = ok and bank.resource == [48,38][camp] and bank.points == camp+1 and bank.resets == 1 and bank.ranks[0] == camp+1
	if not ok: push_error("Échec du scénario de persistance "+mode)
	print("PROFILE_RELAUNCH_",mode.to_upper(),"=",ok)
	quit(0 if ok else 1)
