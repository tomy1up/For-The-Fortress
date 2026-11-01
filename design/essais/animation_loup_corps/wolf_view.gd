extends "res://scripts/valley_view.gd"
const Rig=preload("wolf_rig.gd")
var rig=Rig.new()
var show_contacts:=false
func root_at(progress: float) -> Vector2: return project(model.point_on_path(progress))
func direction_at(progress: float) -> float: return enemy_facing({"distance":progress},model.path_points,model.path_length)
func _draw_pillager(center: Vector2,enemy: Dictionary,hit_strength: float=0.0,pose: Dictionary={}) -> void:
	if enemy_art_id(enemy,model.faction) != "enemy.neutral.wolf":
		super._draw_pillager(center,enemy,hit_strength,pose)
		return
	var facing: float=direction_at(enemy.distance)
	draw_set_transform(center,0,Vector2(facing,1)*_enemy_scale(enemy))
	rig.draw(self,enemy.distance,enemy.id,root_at,direction_at)
	draw_set_transform(Vector2.ZERO)
	if show_contacts:
		for contact in rig.contacts:
			draw_circle(contact.world,1.3,Color("8bcc88") if contact.support else Color("80bada"))
