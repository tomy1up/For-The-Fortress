extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
func _initialize() -> void:
	var path: String = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--save="): path = argument.trim_prefix("--save=")
	assert(path.get_file().begins_with("test_mission_receipts_") and FileAccess.file_exists(path))
	var p = Profile.new(path)
	var ok: bool = not p.blocked and p.data.schema == 6 and p.data.banks[0].resource == 1251 and p.data.banks[0].ranks[0] == 5 and p.data.banks[1].resource == 999
	var id: int = p.begin_mission(0,"test.mission_1",999)
	ok = ok and id > 0 and p.credit_mission(id,0,10,true) and p.data.banks[0].resource == 1251 and p.data.run.mission_earned == 0
	print("MISSION_RELAUNCH=",ok);quit(0 if ok else 1)
