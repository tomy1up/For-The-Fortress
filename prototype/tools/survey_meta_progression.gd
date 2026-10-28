extends SceneTree
## Politiques fixes de contrôle ; ni joueur optimal ni mesure humaine.
const Model = preload("res://scripts/valley_model.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const BUILDS: Array = [
	{"id":"zero","ranks":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
	{"id":"base_5","ranks":[5,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
	{"id":"bases_15","ranks":[5,0,0,0,0,5,0,0,0,0,5,0,0,0,0]},
	{"id":"impact_36","ranks":[5,3,3,1,0,5,3,3,1,0,5,3,3,1,0]}
]
const LAYOUTS: Array = [{"id":"reference","slots":[0,1,2]},{"id":"reparti","slots":[1,3,5]}]
func _initialize() -> void:
	var output: String = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
	assert(not output.is_empty(),"Indiquer une destination de rapport hors du profil joueur.")
	output = ProjectSettings.globalize_path(output).replace("\\","/").simplify_path()
	var user_root: String = OS.get_user_data_dir().replace("\\","/").simplify_path().to_lower()+"/"
	if output.to_lower().begins_with(user_root) or FileAccess.file_exists(output):
		push_error("Destination refusée : le rapport doit être nouveau et hors des données du joueur.");quit(2);return
	var rows: Array = [];var checks: int = 0
	for faction in range(2):
		for build in BUILDS:
			assert(Model.MetaTalents.current_valid(build.ranks))
			for layout in LAYOUTS:
				for seed_value in range(1,33):
					var m = Model.new();m.meta_ranks = build.ranks.duplicate();m.select_faction(faction);m.rng.seed = seed_value
					var slots: Array = layout.slots
					m.buy(slots[0],faction*3);m.buy(slots[1],faction*3+1)
					for wave in range(1,11):
						if wave >= 4 and m.defenders[slots[2]].is_empty(): m.buy(slots[2],faction*3+2)
						if wave >= 5:
							for slot in slots:
								if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
						m.start();m.advance(10000)
						if m.phase == "defeat": break
						if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
						if wave < 10: m.prepare_next_wave()
					var paid: int = 0
					for action in m.action_history:
						if action.kind in ["buy","upgrade"]: paid += int(action.cost)
					assert(m.phase in ["victory","defeat"] and m.gold == Model.INITIAL_GOLD+m.total_income-paid)
					checks += 1
					var completed: int = 0
					for record in m.wave_history:
						if record.result == "cleared": completed += 1
					var combat: float = m.completed_time+m.elapsed
					rows.append({"faction":faction,"build":build.id,"points":Model.MetaTalents.spent(build.ranks),"layout":layout.id,"seed":seed_value,"victory":m.phase == "victory","completed":completed,"reached":m.wave,"hp":m.fortress_hp,"resource":Profile.resource_total(completed,m.phase == "victory"),"combat_seconds":combat,"full_preparation_seconds":30*(m.wave-1),"bonuses":m.bonuses.duplicate()})
				print("META_SURVEY_PROGRESS=",rows.size())
	assert(rows.size() == 512 and checks == 512)
	var file := FileAccess.open(output,FileAccess.WRITE);assert(file != null)
	file.store_string(JSON.stringify({"schema":1,"game_version":ProjectSettings.get_setting("application/config/version"),"scenarios":rows.size(),"budget_checks":checks,"seed_count":32,"human_test":false,"profile_loaded":false,"point_price":Model.MetaTalents.POINT_PRICE,"max_points":Model.MetaTalents.MAX_POINTS,"victory_bonus":Profile.WIN_REWARD,"rows":rows},"\t"));file.close()
	print("META_SURVEY_COMPLETE=",rows.size());quit()
