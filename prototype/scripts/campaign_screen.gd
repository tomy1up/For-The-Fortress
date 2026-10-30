extends ColorRect
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
signal mission_requested(id: String)
signal talents_requested(faction: int)
signal closed

class PathDrawing extends Control:
	var points: Array[Vector2] = []
	var completed: Array[bool] = []
	func _draw() -> void:
		for index in range(points.size()-1):
			var color: Color = Color("a9c986") if completed[index] and completed[index+1] else Color("3b5147")
			draw_line(points[index],points[index+1],color,3,true)

class MissionNode extends Button:
	var completed: bool = false
	var locked: bool = false
	func _draw() -> void:
		if completed:
			draw_circle(Vector2(38,4),8,Color("203c29"))
			draw_polyline(PackedVector2Array([Vector2(34,4),Vector2(37,7),Vector2(42,0)]),Color("b1d39b"),2,true)
		elif locked:
			draw_circle(Vector2(38,4),8,Color("182a22"))
			draw_arc(Vector2(38,2),3,PI,TAU,12,Color("9ba89f"),1.5,true)
			draw_rect(Rect2(34,2,8,6),Color("9ba89f"),false,1.5)

var profile: RefCounted
var faction: int = 0
var chapter: int = 1
var selected: int = 0
var status: Dictionary = {}
var overlay_blocked: bool = false
var heading: Label
var progress_label: Label
var balance: Label
var points_label: Label
var chapter_label: Label
var chapter_buttons: Array[Button] = []
var nodes: Array[MissionNode] = []
var path_drawing: PathDrawing
var mission_heading: Label
var mission_title: Label
var mission_detail: Label
var rewards: Label
var infinite_label: Label
var start_button: Button
var talents_button: Button
var back_button: Button
var footer: Label

func label_at(parent: Control, text: String, rect: Rect2, size: int = 16, color: Color = Color("e0dbbf")) -> Label:
	var label := Label.new();label.text = text;label.position = rect.position;label.size = rect.size
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",color)
	parent.add_child(label);return label

func style(button: Button, background: Color, border: Color, radius: int = 6) -> void:
	var box := StyleBoxFlat.new();box.bg_color = background;box.border_color = border
	box.set_border_width_all(2);box.set_corner_radius_all(radius)
	button.add_theme_stylebox_override("normal",box)
	var hover: StyleBoxFlat = box.duplicate();hover.border_color = Color("d8c481")
	button.add_theme_stylebox_override("hover",hover);button.add_theme_stylebox_override("focus",hover)
	var disabled: StyleBoxFlat = box.duplicate();disabled.bg_color = Color("16241e");disabled.border_color = Color("394d40")
	button.add_theme_stylebox_override("disabled",disabled)

func button_at(text: String, rect: Rect2, action: Callable) -> Button:
	var button := Button.new();button.text = text;button.position = rect.position;button.size = rect.size
	button.add_theme_font_size_override("font_size",15);style(button,Color("1b3b30"),Color("536d59"))
	button.pressed.connect(action);add_child(button);return button

func panel(rect: Rect2) -> void:
	var box := Panel.new();box.position = rect.position;box.size = rect.size;box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme_box := StyleBoxFlat.new();theme_box.bg_color = Color("10271f");theme_box.border_color = Color("2f4c3e")
	theme_box.set_border_width_all(1);theme_box.set_corner_radius_all(9);box.add_theme_stylebox_override("panel",theme_box);add_child(box)

func _ready() -> void:
	color = Color("080f0c");set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	heading = label_at(self,"Campagne",Rect2(32,20,830,40),28)
	progress_label = label_at(self,"",Rect2(32,68,830,28),16,Color("aabeb0"))
	balance = label_at(self,"",Rect2(900,28,348,28),16,Color("e5c779"))
	points_label = label_at(self,"",Rect2(900,68,348,28),14,Color("aabeb0"))
	panel(Rect2(32,116,220,572));panel(Rect2(272,116,558,572));panel(Rect2(850,116,398,572))
	label_at(self,"Chapitres",Rect2(48,132,188,30),21)
	var scroll := ScrollContainer.new();scroll.position = Vector2(48,174);scroll.size = Vector2(188,498)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED;scroll.follow_focus = true;add_child(scroll)
	var list := VBoxContainer.new();list.custom_minimum_size.x = 172;list.add_theme_constant_override("separation",6);scroll.add_child(list)
	for number in range(1,Catalogue.CHAPTER_COUNT+1):
		var button := Button.new();button.custom_minimum_size = Vector2(172,34);button.add_theme_font_size_override("font_size",14)
		style(button,Color("142f24"),Color("394e40"));button.pressed.connect(_chapter.bind(number))
		list.add_child(button);chapter_buttons.append(button)
	chapter_label = label_at(self,"",Rect2(292,132,508,32),22)
	path_drawing = PathDrawing.new();path_drawing.position = Vector2(292,178);path_drawing.size = Vector2(508,490)
	path_drawing.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(path_drawing)
	var columns: Array[int] = [200,270,200,130,200,270,200,130,200,270]
	for index in range(10):
		var node := MissionNode.new();node.position = Vector2(columns[index],48*index);node.size = Vector2(42,42)
		node.add_theme_font_size_override("font_size",16)
		node.pressed.connect(_select.bind(index));node.focus_entered.connect(_select.bind(index))
		path_drawing.add_child(node);nodes.append(node)
		path_drawing.points.append(node.position+Vector2(21,21))
	mission_heading = label_at(self,"",Rect2(870,136,358,28),17,Color("e5c779"))
	mission_title = label_at(self,"",Rect2(870,172,358,64),24)
	mission_detail = label_at(self,"",Rect2(870,244,358,64),16,Color("bbcbbf"))
	rewards = label_at(self,"",Rect2(870,316,358,68),16,Color("e5c779"))
	start_button = button_at("Jouer",Rect2(870,400,358,44),_launch)
	talents_button = button_at("Préparer les talents",Rect2(870,456,358,42),_talents)
	label_at(self,"Mode infini",Rect2(870,534,358,28),20)
	infinite_label = label_at(self,"",Rect2(870,574,358,94),15,Color("aabeb0"))
	label_at(self,"Une mission à la fois · XP et PO de première victoire · Parcours propre à la faction",Rect2(32,704,1216,28),14,Color("9eb3a4"))
	back_button = button_at("Changer de faction · Échap",Rect2(32,744,240,38),close)
	footer = label_at(self,"",Rect2(292,748,956,36),13,Color("91a799"))
	hide()

func open(for_profile: RefCounted, for_faction: int, for_chapter: int = 0) -> void:
	if for_faction not in [0,1]: return
	profile = for_profile;faction = for_faction;chapter = clampi(for_chapter,1,Catalogue.CHAPTER_COUNT);selected = 0
	if for_chapter == 0:
		var number: int = Catalogue.suggested_mission(profile.campaign_status(faction) if profile != null else {})
		chapter = (number-1)/Catalogue.CHAPTER_SIZE+1;selected = (number-1)%Catalogue.CHAPTER_SIZE
	set_overlay_blocked(false);show();refresh();initial_focus().grab_focus()

func close() -> void:
	var was_visible: bool = visible;hide()
	if was_visible: closed.emit()

func initial_focus() -> Button:
	return start_button if not start_button.disabled else nodes[selected]

func set_overlay_blocked(value: bool) -> void:
	if overlay_blocked == value: return
	overlay_blocked = value
	for button in chapter_buttons+nodes+[start_button,talents_button,back_button]:
		button.focus_mode = Control.FOCUS_NONE if value else Control.FOCUS_ALL

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and not overlay_blocked and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close();get_viewport().set_input_as_handled()

func _chapter(number: int) -> void:
	if overlay_blocked or number < 1 or number > Catalogue.CHAPTER_COUNT: return
	chapter = number;selected = 0;refresh();nodes[0].grab_focus()

func _select(index: int) -> void:
	if overlay_blocked or index < 0 or index >= 10: return
	selected = index;_refresh_nodes();_refresh_detail()

func refresh() -> void:
	status = profile.campaign_status(faction) if profile != null else {}
	var camp: String = "Alliance" if faction == 0 else "Horde"
	heading.text = "Campagne · "+camp
	if status.is_empty():
		progress_label.text = "Progression à vérifier";balance.text = "PO et XP : indisponibles";points_label.text = ""
		infinite_label.text = "Progression indisponible."
		talents_button.text = "Consulter les talents"
	else:
		var bank: Dictionary = profile.data.banks[faction]
		progress_label.text = "%d / %d missions réussies · %d missions dans l’échantillon" % [status.completed,Catalogue.TOTAL_MISSIONS,Catalogue.available_count()]
		balance.text = "PO %s : %d · XP : %d" % [camp,bank.resource,bank.xp]
		var free: int = maxi(0,mini(int(bank.points),51)-profile.Talents.spent(bank.ranks))
		points_label.text = "%d/51 points débloqués · %d à placer" % [bank.points,free]
		talents_button.text = "Talents · %d point%s à placer" % [free,"s" if free > 1 else ""] if free > 0 else "Préparer les talents"
		infinite_label.text = "Condition remplie pour cette faction.\nMode infini à venir." if status.infinite_eligible else "%d / 100 premières missions réussies\nMode infini à venir." % status.first_hundred
	for index in range(Catalogue.CHAPTER_COUNT):
		chapter_buttons[index].text = "Chapitre %d · %s/10" % [index+1,"—" if status.is_empty() else str(status.chapters[index])]
		style(chapter_buttons[index],Color("254434") if chapter == index+1 else Color("142f24"),Color("d8c481") if chapter == index+1 else Color("394e40"))
	chapter_label.text = "Chapitre %d · Missions %d–%d" % [chapter,(chapter-1)*10+1,chapter*10]
	talents_button.disabled = profile == null
	footer.text = "Prototype · %d missions jouables sur %d prévues. Les autres contenus sont à venir." % [Catalogue.available_count(),Catalogue.TOTAL_MISSIONS]
	if profile != null:
		if not profile.error.is_empty(): footer.text = profile.error
		elif not profile.migration_notice.is_empty(): footer.text = profile.migration_notice
	_refresh_nodes();_refresh_detail()

func _refresh_nodes() -> void:
	path_drawing.completed.clear()
	for index in range(10):
		var number: int = (chapter-1)*10+index+1
		var definition: Dictionary = Catalogue.definition(number)
		var done: bool = not status.is_empty() and status.missions[number-1]
		var border: Color = Color("a7ca8b") if done else Color("d8c481") if Catalogue.unlocked(number,status) else Color("42574a")
		if index == selected: border = Color("e5cd91")
		style(nodes[index],Color("254934") if done else Color("1b3027"),border,21)
		nodes[index].text = str(number);nodes[index].completed = done;nodes[index].locked = definition.available and not Catalogue.unlocked(number,status);nodes[index].queue_redraw()
		nodes[index].tooltip_text = "%s · %s" % [definition.title,"Déjà réussie" if done else "Disponible" if Catalogue.unlocked(number,status) else "Terminez la mission précédente" if definition.available else "À venir"]
		path_drawing.completed.append(done)
	path_drawing.queue_redraw()

func _refresh_detail() -> void:
	var number: int = (chapter-1)*10+selected+1
	var definition: Dictionary = Catalogue.definition(number)
	var done: bool = not status.is_empty() and status.missions[number-1]
	mission_heading.text = "Mission %d" % number
	mission_title.text = definition.title
	if not definition.available:
		mission_detail.text = "Contenu à venir."
		rewards.text = "Vagues et récompenses à définir."
		start_button.text = "Mission à venir"
	elif not Catalogue.unlocked(number,status):
		mission_detail.text = "Terminez la mission %d avec cette faction." % (number-1)
		rewards.text = "+%d PO · +%d XP\nPremière victoire uniquement." % [definition.po,definition.xp]
		start_button.text = "Mission verrouillée"
	elif done:
		mission_detail.text = "%d vagues · Mission déjà réussie" % definition.waves
		rewards.text = "Récompenses déjà perçues.\nRejouer ne donne ni PO ni XP."
		start_button.text = "Rejouer sans nouveau gain"
	else:
		mission_detail.text = "%d vagues · Première victoire" % definition.waves
		rewards.text = "+%d PO · +%d XP\nUne seule fois pour cette faction." % [definition.po,definition.xp]
		start_button.text = "Jouer la mission %d" % number
	start_button.disabled = not Catalogue.unlocked(number,status)
	if definition.available and not status.is_empty(): mission_detail.text += "\nPV ennemis : %d %% · Barème d’essai" % definition.hp_percent
	if status.is_empty():
		mission_detail.text = "La progression n’est pas disponible."
		rewards.text = profile.error if profile != null and not profile.error.is_empty() else "Revenez au choix de faction pour vérifier votre progression."

func _launch() -> void:
	if overlay_blocked or not visible or start_button.disabled or profile == null or profile.blocked: return
	var id: String = Catalogue.id_for((chapter-1)*10+selected+1)
	if Catalogue.runtime(id).is_empty() or not Catalogue.unlocked(Catalogue.number_for(id),profile.campaign_status(faction)): return
	mission_requested.emit(id)

func _talents() -> void:
	if not overlay_blocked and visible and profile != null: talents_requested.emit(faction)
