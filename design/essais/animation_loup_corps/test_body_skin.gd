extends SceneTree
const Rig=preload("wolf_rig.gd")
var failures:=0
var checks:=0
func check(value: bool,label: String) -> void:
	checks+=1
	if not value: failures+=1;push_error(label)
func _initialize() -> void:
	var rig:=Rig.new()
	var smallest_area_ratio:=INF
	var largest_area_ratio:=0.0
	var spine_motion:=0.0
	for frame in range(48):
		var distance: float=frame*Rig.STRIDE/48.0
		var motion: Dictionary=rig.body_motion(distance)
		var loop: Dictionary=rig.body_motion(distance+Rig.STRIDE)
		var pelvis: Vector2=rig.body_point(Vector2(435,420),motion)
		var shoulder: Vector2=rig.body_point(Vector2(815,450),motion)
		spine_motion=maxf(spine_motion,absf((pelvis.y-420)-(shoulder.y-450)))
		var eye:=Vector2(1040,330);var nose:=Vector2(1170,430)
		check(is_equal_approx(rig.body_point(eye,motion).distance_to(rig.body_point(nose,motion)),eye.distance_to(nose)),"Visage rigide sans étirement")
		for source in [Vector2(100,340),Vector2(435,420),Vector2(815,450),eye,nose]:
			check(rig.body_point(source,motion).distance_to(rig.body_point(source,loop))<0.001,"Raccord périodique du corps")
		for index in range(0,rig.body_source.size(),3):
			var a: Vector2=rig.body_source[index];var b: Vector2=rig.body_source[index+1];var c: Vector2=rig.body_source[index+2]
			var pa: Vector2=rig.body_point(a,motion);var pb: Vector2=rig.body_point(b,motion);var pc: Vector2=rig.body_point(c,motion)
			var ratio: float=(pb-pa).cross(pc-pa)/(b-a).cross(c-a)
			smallest_area_ratio=minf(smallest_area_ratio,ratio);largest_area_ratio=maxf(largest_area_ratio,ratio)
			check(ratio>0.65 and ratio<1.35,"Maillage continu sans pli inversé ni forte dilatation")
	check(spine_motion>20.0,"Le dos se déforme au cours du cycle, au-delà d'une translation uniforme")
	var report: Dictionary={"checks":checks,"failures":failures,"smallest_triangle_area_ratio":smallest_area_ratio,"largest_triangle_area_ratio":largest_area_ratio,"relative_shoulder_pelvis_motion_source_pixels":spine_motion,"artistic_approval":false}
	var file:=FileAccess.open(get_script().resource_path.get_base_dir().path_join("controle_corps.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"));file.close()
	print("WOLF_BODY_SKIN ",JSON.stringify(report))
	quit(0 if failures==0 else 1)
