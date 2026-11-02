extends SceneTree
## Controlled comparison of placement only. Same approved pose on both sides.
const Walk=preload("res://scripts/enemy_walk_art.gd")
class Comparison extends Node2D:
	var cache:=Walk.new()
	var retained: Array[ArrayMesh]=[]
	func _draw() -> void:
		retained.clear()
		draw_rect(Rect2(0,0,1280,850),Color("0b1915"))
		draw_string(ThemeDB.fallback_font,Vector2(28,38),"Loup · Correction de l’orientation sur le chemin",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e0dbbf"))
		draw_string(ThemeDB.fallback_font,Vector2(28,70),"Même pose approuvée · Agrandissement ×4 · Aucun profil joueur",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("abc0b0"))
		draw_string(ThemeDB.fallback_font,Vector2(220,105),"v0.108 · Cisaillement rejeté",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("cc9e91"))
		draw_string(ThemeDB.fallback_font,Vector2(820,105),"v0.109 · Rotation sans étirement",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e0ca86"))
		var directions: Array[Vector2]=[Vector2(2,1).normalized(),Vector2(-2,1).normalized(),Vector2(2,-1).normalized(),Vector2(-2,-1).normalized()]
		for row in range(4):
			var direction: Vector2=directions[row]
			var ground:=Vector2(absf(direction.x),direction.y)
			for column in range(2):
				var center:=Vector2(320+column*620,235+row*175)
				var normal:=Vector2(-direction.y,direction.x)
				draw_colored_polygon(PackedVector2Array([center-direction*170-normal*26,center+direction*170-normal*26,center+direction*170+normal*26,center-direction*170+normal*26]),Color("756c4f"))
				draw_line(center-direction*170,center+direction*170,Color("b6aa80"),1)
				var mesh: ArrayMesh
				if column==1: mesh=cache.mesh_for(row,0.37,ground)
				else:
					var points:=Walk.sample_vertices(0.37)
					for index in range(points.size()): points[index]=Vector2(points[index].x*ground.x,points[index].y+points[index].x*ground.y)
					var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
					arrays[Mesh.ARRAY_VERTEX]=points;arrays[Mesh.ARRAY_TEX_UV]=Walk.DATA.uv;arrays[Mesh.ARRAY_COLOR]=Walk.DATA.colors;arrays[Mesh.ARRAY_INDEX]=Walk.DATA.indices
					mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
					retained.append(mesh)
				draw_set_transform(center,0,Vector2(-2.8 if direction.x<0 else 2.8,2.8))
				draw_mesh(mesh,Walk.TEXTURE)
				draw_set_transform(Vector2.ZERO)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,850)
	var board:=Comparison.new();board.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;root.add_child(board)
	await process_frame;await RenderingServer.frame_post_draw
	var result:=root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../design/essais/v0109_comparaison_orientation.png"))
	assert(result==OK);print("ORIENTATION_COMPARISON saved=",result);quit()
