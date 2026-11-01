extends SceneTree
const Model=preload("res://scripts/valley_model.gd")
const WolfView=preload("wolf_view.gd")
var model=Model.new()
var view=WolfView.new()
var speed:=1.0
var zoom:=5.0
var stopped:=false
var capture_mode:=false
var status: Label
func _initialize() -> void: call_deferred("start_workshop")
func start_workshop() -> void:
	root.size=Vector2i(1280,800)
	root.title="For the Fortress! — Essai du corps du loup — Sans sauvegarde"
	view.model=model;root.add_child(view);view.set_process(false)
	var layer:=CanvasLayer.new();root.add_child(layer)
	var panel:=PanelContainer.new();panel.position=Vector2(20,15);panel.size=Vector2(1240,125);layer.add_child(panel)
	var box:=VBoxContainer.new();panel.add_child(box)
	var title:=Label.new();title.text="Loup · Liaison du corps aux appuis · Essai à valider";title.add_theme_font_size_override("font_size",26);box.add_child(title)
	status=Label.new();box.add_child(status)
	var row:=HBoxContainer.new();box.add_child(row)
	for value in [0.5,1.0,2.0]:
		var button:=Button.new();button.text="Vitesse ×%s"%value;button.pressed.connect(func()->void:speed=value);row.add_child(button)
	var pause:=Button.new();pause.text="Pause / Reprendre";pause.pressed.connect(func()->void:stopped=not stopped);row.add_child(pause)
	var magnify:=Button.new();magnify.text="Taille du jeu / Agrandir";magnify.pressed.connect(func()->void:zoom=1.0 if zoom>1.0 else 5.0);row.add_child(magnify)
	var contacts:=Button.new();contacts.text="Afficher / Masquer les appuis";contacts.pressed.connect(func()->void:view.show_contacts=not view.show_contacts);row.add_child(contacts)
	var again:=Button.new();again.text="Recommencer";again.pressed.connect(restart);row.add_child(again)
	var body_toggle:=Button.new();body_toggle.text="Corps fixe / animé";body_toggle.pressed.connect(func()->void:view.rig.animate_body=not view.rig.animate_body);row.add_child(body_toggle)
	restart()
	capture_mode=OS.get_cmdline_user_args().has("--capture")
	if OS.get_cmdline_user_args().has("--check-controls"):
		stopped=true
		var before: float=model.enemies[0].distance
		_process(0.1);assert(is_equal_approx(model.enemies[0].distance,before))
		row.get_child(0).pressed.emit();assert(speed==0.5)
		row.get_child(2).pressed.emit();assert(speed==2.0)
		pause.pressed.emit();assert(not stopped)
		_process(0.1);assert(is_equal_approx(model.enemies[0].distance-before,0.23))
		magnify.pressed.emit();assert(zoom==1.0)
		contacts.pressed.emit();assert(view.show_contacts)
		body_toggle.pressed.emit();assert(not view.rig.animate_body)
		again.pressed.emit();assert(model.enemies[0].distance<0.01)
		print("WOLF_WORKSHOP_CONTROLS pause=true speed=true zoom=true contacts=true restart=true profile_access=false")
		capture_mode=true;view.free();quit();return
	if capture_mode: capture()
func restart() -> void:
	model.reset();model.wave=4
	model.spawn_schedule.assign([{"time":0.0,"type":0}]);assert(model.start())
	model.advance(0.001)
func update_view() -> void:
	view.scale=Vector2.ONE*zoom
	view.position=Vector2.ZERO if zoom==1.0 else Vector2(640,470)-view.root_at(model.enemies[0].distance)*zoom
	view.queue_redraw()
	status.text="Vitesse ×%s · Zoom ×%s · Corps %s · %s · Aucun profil joueur chargé"%[speed,zoom,"animé" if view.rig.animate_body else "fixe (comparaison)","Pause" if stopped else "Déplacement"]
func _process(delta: float) -> bool:
	if capture_mode or status==null: return false
	if not stopped: model.advance(delta*speed)
	if model.enemies.is_empty(): restart()
	update_view()
	if Input.is_physical_key_pressed(KEY_ESCAPE): quit()
	return false
func capture() -> void:
	var folder: String=get_script().resource_path.get_base_dir().path_join("captures")
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in range(1200):
		if frame%300==0: restart()
		speed=2.0 if frame>=600 and frame<900 else 1.0;zoom=1.0 if frame>=900 else 5.0
		view.rig.animate_body=frame>=300
		model.advance(speed/60.0);update_view()
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(folder.path_join("%03d.png"%frame))==OK)
	print("WOLF_BODY_CAPTURE frames=1200 fps=60 player_profile_loaded=false max_support_error_pixels=",view.rig.max_support_error_pixels)
	quit()
