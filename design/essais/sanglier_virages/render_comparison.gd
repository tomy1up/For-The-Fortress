extends SceneTree
## Static direction construction; no Main, model, campaign or player profile.
class Drawing extends Node2D:
	var data: Dictionary
	var profile: Texture2D
	var front: Texture2D
	var quarter: Texture2D
	var rear: Texture2D
	var transforms: Array=[]
	func _draw() -> void:
		draw_rect(Rect2(0,0,1280,800),Color("0b1915"))
		var font: Font=ThemeDB.fallback_font
		draw_string(font,Vector2(24,40),"Sanglier · Construction des vues du virage",HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("e0dbbf"))
		draw_string(font,Vector2(24,76),"Dessin de préparation · Pas une animation de virage · Aucun profil joueur",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("abc0b0"))
		transforms.clear()
		for index in range(4):
			var name: String=["front","quarter","rear","profile"][index]
			var source: Dictionary=data.images[name];var center: float=160+index*320
			var facing: float=1.0
			var label: String=["Face · 4 pattes","Trois quarts avant · 4 pattes","Trois quarts arrière · 4 pattes","Profil · calque proche"][index]
			draw_string(font,Vector2(center-font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,17).x/2,165),label,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e0dbbf"))
			for factor in [5.0,1.0]:
				var floor_y: float=445 if factor>1 else 620
				var scale_value: float=source.uniform_scale*factor
				draw_line(Vector2(center-145,floor_y),Vector2(center+145,floor_y),Color("526458"),1,true)
				var pivot:=Vector2(source.pivot[0],source.pivot[1])
				var transform:=Transform2D(Vector2(facing*scale_value,0),Vector2(0,scale_value),Vector2(center,floor_y)-pivot*Vector2(facing*scale_value,scale_value))
				draw_set_transform_matrix(transform);draw_texture(front if name=="front" else quarter if name=="quarter" else rear if name=="rear" else profile,Vector2.ZERO);draw_set_transform(Vector2.ZERO)
				transforms.append({"view":index,"factor":factor,"basis":[[transform.x.x,transform.x.y],[transform.y.x,transform.y.y]],"pivot":[center,floor_y],"scale":scale_value})
			draw_string(font,Vector2(center-66,485),"Agrandissement ×5",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("abc0b0"))
			draw_string(font,Vector2(center-67,655),"Taille du jeu : 28,9 px",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("abc0b0"))
		draw_string(font,Vector2(24,722),"Hauteur visible commune · Échelles uniformes · Sources conservées sans retouche",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e0dbbf"))
		draw_string(font,Vector2(24,760),"Les appuis et les mouvements entre ces vues restent à construire. Essai non approuvé.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("abc0b0"))
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,800);root.content_scale_size=Vector2i(1280,800);root.title="For the Fortress! — Construction du virage — Essai isolé"
	var folder: String=get_script().resource_path.get_base_dir();var drawing:=Drawing.new()
	drawing.data=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("controle_sources.json")))
	for key in ["profile","front","quarter","rear"]:
		var path: String=folder.path_join({"front":"sanglier_face_source_v001.png","quarter":"sanglier_trois_quarts_source_v001.png","rear":"sanglier_arriere_trois_quarts_source_v001.png","profile":"../sanglier_peau_continue/sanglier_proche_source_v001.png"}[key])
		assert(FileAccess.get_sha256(path)==drawing.data.images[key].sha256)
		var image:=Image.load_from_file(path);image.generate_mipmaps()
		if key=="front": drawing.front=ImageTexture.create_from_image(image)
		elif key=="quarter": drawing.quarter=ImageTexture.create_from_image(image)
		elif key=="rear": drawing.rear=ImageTexture.create_from_image(image)
		else: drawing.profile=ImageTexture.create_from_image(image)
	drawing.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;root.add_child(drawing)
	await process_frame;await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join("Apercu_directions.png"))==OK)
	var out:=FileAccess.open(folder.path_join("placements_natifs.json"),FileAccess.WRITE)
	out.store_string(JSON.stringify({"profile_loaded":false,"static_drawing":true,"transforms":drawing.transforms}));out.close()
	print("BOAR_FRONT_COMPARISON static=true profile_loaded=false");quit()
