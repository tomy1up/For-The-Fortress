extends "res://scripts/valley_view.gd"
var candidate: Texture2D
const ROW_START := [0,245,470,690]
const ROW_END := [245,470,690,887]
const ROW_REGISTER := [0,226,444,657]
func _ready() -> void:
	candidate = ImageTexture.create_from_image(Image.load_from_file(get_script().resource_path.get_base_dir().path_join("loup_24_poses_candidat.png")))
func _draw_pillager(center: Vector2, enemy: Dictionary, hit_strength: float = 0.0, pose: Dictionary = {}) -> void:
	if enemy_art_id(enemy,model.faction) != "enemy.neutral.wolf":
		super._draw_pillager(center,enemy,hit_strength,pose)
		return
	draw_set_transform(center,0.0,Vector2.ONE*_enemy_scale(enemy))
	if enemy.id == inspected_enemy_id:
		draw_arc(Vector2(0,3),14,0,TAU,32,Color("edcc80"),2,true)
	for curse in model.curses:
		if curse.enemy_id != enemy.id: continue
		draw_arc(Vector2(0,-13),19,0,TAU,24,Color("be83d3"),1.5,true)
		var mark := Vector2(0,-45)
		draw_colored_polygon(PackedVector2Array([mark+Vector2(0,-5),mark+Vector2(4,0),mark+Vector2(0,5),mark+Vector2(-4,0)]),Color("d6a1ef"))
		break
	draw_circle(Vector2(0,3),10,Color(0,0,0,0.25),true,-1,true)
	var index := int(floor(fposmod(enemy.distance/1.15+enemy.id*0.137,1.0)*24.0))
	var row := index/6
	var width := 1774.0/6.0
	var source := Rect2((index%6)*width,ROW_START[row],width,ROW_END[row]-ROW_START[row])
	var ratio := 34.0/176.0
	var destination := Rect2(Vector2(-148,-219+ROW_START[row]-ROW_REGISTER[row])*ratio,source.size*ratio)
	var body: Transform2D = enemy_body_transform(enemy,enemy_facing(enemy,model.path_points,model.path_length),pose,model.elapsed,false)
	body.origin += center
	draw_set_transform_matrix(body)
	draw_texture_rect_region(candidate,destination,source,EnemyArt.tint(hit_strength))
	draw_set_transform(Vector2.ZERO)
