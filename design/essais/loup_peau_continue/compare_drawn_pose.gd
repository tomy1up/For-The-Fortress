extends SceneTree
## Isolated art comparison. Never loads game scenes or a player profile.
const RenderStudy=preload("render_walk.gd")
const PHASE:=8.0/12.0
var retained: Array[Node]=[]

class Backdrop extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(0,0,1280,800),Color("0b1915"))
		var font:=ThemeDB.fallback_font
		draw_string(font,Vector2(32,42),"Loup · Étude d’une correction dessinée",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e0dbbf"))
		draw_string(font,Vector2(32,82),"Image fixe : ne valide ni la marche, ni les appuis, ni les transitions.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("b0c5b8"))
		draw_string(font,Vector2(32,155),"Déformation actuelle · Pose 8 sur 12",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("e8a17c"))
		draw_string(font,Vector2(672,155),"Correction dessinée · À recaler",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("b9d699"))
		draw_line(Vector2(640,180),Vector2(640,630),Color("344e43"),1)
		draw_string(font,Vector2(32,690),"À examiner : continuité épaule / patte et hanche / cuisse ; stabilité des proportions.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e0dbbf"))
		draw_string(font,Vector2(32,728),"La nouvelle image n’est pas interchangeable avec une frame du cycle : son cadrage diffère.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("b0c5b8"))
		draw_string(font,Vector2(32,768),"Atelier sans profil joueur · Aucun changement dans la version publiée",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("789487"))

func _initialize() -> void: call_deferred("compare")
func compare() -> void:
	root.size=Vector2i(1280,800)
	root.title="For the Fortress! — Correction dessinée du loup — Étude"
	var folder: String=get_script().resource_path.get_base_dir()
	root.add_child(Backdrop.new())
	var data_near: Variant=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("correctives_walk.json")))
	var data_far: Variant=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("correctives_walk_far.json")))
	assert(data_near is Dictionary and data_far is Dictionary)
	var old_texture:=ImageTexture.create_from_image(Image.load_from_file(folder.path_join("loup_proche_source_v001.png")))
	for layer in range(2):
		var surface:=RenderStudy.Corrected.new()
		surface.texture=old_texture;surface.phase=PHASE;surface.far_layer=layer==0
		surface.data=data_far if layer==0 else data_near
		surface.scale=Vector2.ONE*0.36
		surface.position=Vector2(325,574)-Vector2(750,923)*0.36
		if layer==0: surface.modulate=Color(0.65,0.65,0.65,1)
		root.add_child(surface);retained.append(surface)
	var candidate:=Sprite2D.new()
	var candidate_image:=Image.load_from_file(folder.path_join("pose_passage_dessinee_v001.png"))
	assert(candidate_image.get_size()==Vector2i(1586,992))
	candidate.texture=ImageTexture.create_from_image(candidate_image)
	candidate.centered=false
	# Manual presentation fit only. This is not registration for animation use.
	candidate.scale=Vector2.ONE*0.44
	candidate.position=Vector2(965,574)-Vector2(798,835)*0.44
	root.add_child(candidate)
	await process_frame;await process_frame;await RenderingServer.frame_post_draw
	var output: String=folder.path_join("captures/comparaison_pose_dessinee.png")
	assert(root.get_texture().get_image().save_png(output)==OK)
	print("DRAWN_POSE_COMPARISON frames=1 registered_for_animation=false artistically_approved=false profile_loaded=false")
	quit()
