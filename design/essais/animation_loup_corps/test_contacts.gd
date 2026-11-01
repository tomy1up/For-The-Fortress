extends SceneTree
const Rig=preload("wolf_rig.gd")
const Model=preload("res://scripts/valley_model.gd")
const View=preload("res://scripts/valley_view.gd")
var count:=0
var max_drift:=0.0
var maximum: Dictionary={}
var max_paw_difference:=0.0
static func root_at(progress: float) -> Vector2: return View.project(Model.position_at(progress))
static func direction_at(progress: float) -> float: return View.enemy_facing({"distance":progress})
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var rig:=Rig.new();rig.measure_only=true
	for id in range(16):
		var planted: Dictionary={}
		for step in range(2801):
			var distance: float=step*0.01
			rig.draw(null,distance,id,root_at,direction_at)
			var used: Dictionary={}
			for contact in rig.contacts:
				max_paw_difference=maxf(max_paw_difference,contact.world.distance_to(contact.desired_world))
				assert(not used.has(contact.leg));used[contact.leg]=true
				if not contact.support: continue
				count+=1
				var key: String="%d:%d"%[contact.leg,contact.cycle]
				if planted.has(key):
					var drift: float=planted[key].distance_to(contact.world)
					if drift>max_drift:
						max_drift=drift;maximum={"id":id,"distance":distance,"leg":contact.leg,"cycle":contact.cycle}
				else: planted[key]=contact.world
	var report: Dictionary={"max_difference_from_approved_paws_pixels":max_paw_difference,"max_attachment_shift_pixels":rig.max_attachment_shift_pixels,"support_samples":count,"max_world_drift_pixels":max_drift,"max_ik_error_pixels":rig.max_support_error_pixels,"worst":maximum,"scope":"actual rig paw references across all turns, 16 phase offsets; all paws compared with approved gait including swing; artistic review separate"}
	var file:=FileAccess.open(get_script().resource_path.get_base_dir().path_join("controle_appuis.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("ACTUAL_PAW_CONTACTS=",JSON.stringify(report))
	quit(0 if max_drift<0.002 and rig.max_support_error_pixels<0.002 and max_paw_difference<0.002 else 1)
