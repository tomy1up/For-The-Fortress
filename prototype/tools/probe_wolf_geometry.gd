extends SceneTree
const Walk=preload("res://scripts/enemy_walk_art.gd")
func _initialize() -> void:
	var results: Array=[]
	for direction in [Vector2.RIGHT,Vector2(0.8944272,0.4472136),Vector2(0.8944272,-0.4472136),Vector2.DOWN,Vector2.UP]:
		var inverted:=0;var minimum:=INF
		for frame in range(256):
			var vertices:=Walk.sample_vertices(frame/256.0,direction)
			for index in range(0,Walk.DATA.indices.size(),3):
				var a: Vector2=vertices[Walk.DATA.indices[index]]
				var b: Vector2=vertices[Walk.DATA.indices[index+1]]
				var c: Vector2=vertices[Walk.DATA.indices[index+2]]
				var area: float=(b-a).cross(c-a)
				minimum=minf(minimum,area)
				if area<=0: inverted+=1
		results.append({"direction":[direction.x,direction.y],"flat_profile_fallback":absf(direction.x)<0.05,"inverted":inverted,"min_area":minimum})
	print("WOLF_PROJECTION_GEOMETRY ",JSON.stringify(results))
	var output:=FileAccess.open("res://../design/essais/v0109_wolf_geometry.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"phases":256,"triangles":Walk.DATA.indices.size()/3,"cases":results},"\t"));output.close()
	quit()
