extends SceneTree
const Study=preload("render_walk.gd")
var surfaces: Array[Node2D]=[]
var moving: Array[Node2D]=[]
var board_scale:=0.0

class Backdrop extends Node2D:
	var distance:=0.0
	func _draw() -> void:
		var font:=ThemeDB.fallback_font
		draw_rect(Rect2(0,0,1280,800),Color("0b1915"))
		draw_string(font,Vector2(30,42),"Loup · Comparaison des mouvements",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e0dbbf"))
		draw_string(font,Vector2(30,82),"Même dessin, mêmes ancrages · Vitesse d’atelier · Étude non validée",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("aec6b6"))
		draw_string(font,Vector2(50,165),"Déformation précédente",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("deb18f"))
		draw_string(font,Vector2(690,165),"Trajectoires de peau lissées",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("c0d59e"))
		draw_line(Vector2(640,130),Vector2(640,610),Color("344e43"),1)
		for center in [320,960]:
			draw_line(Vector2(center-270,510),Vector2(center+270,510),Color("738471"),1)
			for index in range(-6,7):
				var x: float=center+index*50-fposmod(distance*940*0.32,50)
				if x<center-265 or x>center+265: continue
				draw_line(Vector2(x,510),Vector2(x-8,525),Color("526458"),1)
			draw_line(Vector2(center-140,650),Vector2(center+140,650),Color("526458"),1)
		draw_string(font,Vector2(30,595),"En bas : déplacement à la hauteur nominale de 34 pixels",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("aec6b6"))
		draw_string(font,Vector2(30,725),"Les ancrages sont conservés. Le naturel et les raccords de fourrure restent à examiner.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e0dbbf"))
		draw_string(font,Vector2(30,770),"Atelier sans profil joueur · Animation non intégrée au jeu publié",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("789487"))

func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,800)
	root.title="For the Fortress! — Comparaison du mouvement du loup — Atelier"
	var folder: String=get_script().resource_path.get_base_dir()
	var backdrop:=Backdrop.new();root.add_child(backdrop)
	var texture:=ImageTexture.create_from_image(Image.load_from_file(folder.path_join("loup_proche_source_v001.png")))
	for version in range(2):
		var prefix: String="periodic_walk" if version==0 else "smooth_walk"
		var audit: Variant=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("controle_interpolation_periodique.json" if version==0 else "controle_interpolation_lissee.json")))
		assert(audit is Dictionary and audit.get("passed",false))
		if version==1:
			assert(audit.native_readback.passed)
			assert(audit.native_readback.renderer_sha256==FileAccess.get_sha256(folder.path_join("render_walk.gd")))
		var layers: Array=[]
		for suffix in ["_far",""]:
			var path: String=folder.path_join(prefix+suffix+".json")
			assert(FileAccess.get_sha256(path)==audit.layers["far" if suffix=="_far" else "near"].data_sha256)
			layers.append(JSON.parse_string(FileAccess.get_file_as_string(path)))
		var low_y:=INF;var high_y: float=-INF
		for point in layers[1].frames[0]: low_y=minf(low_y,point[1]);high_y=maxf(high_y,point[1])
		var scale_small: float=34.0/(high_y-low_y)
		if version==0: board_scale=scale_small
		for level in range(2):
			for layer in range(2):
				var surface:=Study.Corrected.new()
				surface.texture=texture;surface.data=layers[layer];surface.far_layer=layer==0
				var scale_factor: float=0.32 if level==0 else board_scale
				surface.scale=Vector2.ONE*scale_factor
				surface.position=Vector2(320+version*640,510 if level==0 else 650)-Vector2(750,high_y)*scale_factor
				if layer==0: surface.modulate=Color(0.65,0.65,0.65,1)
				root.add_child(surface);surfaces.append(surface)
				if level==1: moving.append(surface)
	var output: String=folder.path_join("captures/compare_smooth_movie")
	DirAccess.make_dir_recursive_absolute(output)
	for frame in range(192):
		var phase: float=frame/64.0
		backdrop.distance=phase*0.8;backdrop.queue_redraw()
		for surface in surfaces: surface.phase=phase;surface.queue_redraw()
		for index in range(moving.size()):
			moving[index].position.x=280.0+(index/2)*640-750*board_scale+phase*0.8*940*board_scale
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join("pose_%04d.png"%frame))==OK)
	print("SMOOTH_COMPARISON_CAPTURE frames=192 phases_per_cycle=64 old_and_new=true profile_loaded=false artistic_approval=false")
	quit()
