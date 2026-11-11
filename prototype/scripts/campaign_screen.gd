extends ColorRect
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Scout = preload("res://scripts/mission_scout.gd")
const Maps = preload("res://scripts/map_definition.gd")
const MarshArt = preload("res://scripts/marsh_art.gd")
const Drowned = preload("res://scripts/drowned_encounters.gd")
signal mission_requested(id: String)
signal talents_requested(faction: int)
signal shop_requested(faction: int)
signal closed

class TerrainPreview extends Control:
	var definition: Dictionary = {}
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func show_map(id: String) -> void:
		definition = Maps.for_id(id) if not id.is_empty() else {}
		queue_redraw()
	static func project(point: Vector2) -> Vector2:
		return Vector2((point.x-point.y)*2,point.x+point.y)
	func geometry() -> Dictionary:
		if definition.is_empty() or size.x < 32 or size.y < 48: return {}
		var dimensions: Vector2 = Vector2(definition.size)
		var logical_board: Array[Vector2] = [Vector2.ZERO,Vector2(dimensions.x,0),dimensions,Vector2(0,dimensions.y)]
		var minimum: Vector2 = project(logical_board[0]);var maximum: Vector2 = minimum
		for point in logical_board:
			minimum = minimum.min(project(point));maximum = maximum.max(project(point))
		var extent: Vector2 = maximum-minimum
		var available: Vector2 = size-Vector2(24,38)
		var factor: float = minf(available.x/extent.x,available.y/extent.y)
		var origin: Vector2 = Vector2(12,6)+(available-extent*factor)/2-minimum*factor
		var board := PackedVector2Array();var paths: Array[PackedVector2Array] = [];var slots := PackedVector2Array()
		for point in logical_board: board.append(origin+project(point)*factor)
		for route in definition.get("routes",[definition]):
			var path := PackedVector2Array()
			for point in route.path_points: path.append(origin+project(point)*factor)
			paths.append(path)
		for point in definition.slots: slots.append(origin+project(point)*factor)
		return {"id":definition.id,"board":board,"paths":paths,"slots":slots}
	func _draw() -> void:
		var font: Font = ThemeDB.fallback_font
		draw_style_box(_background(),Rect2(Vector2.ZERO,size))
		var layout: Dictionary = geometry()
		if layout.is_empty():
			var message: String = "Carte à venir"
			draw_string(font,Vector2((size.x-font.get_string_size(message,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x)/2,size.y/2+5),message,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("91a799"))
			return
		var marsh: bool = definition.decoration=="marsh"
		draw_colored_polygon(layout.board,MarshArt.GROUND if marsh else Color("3d3837") if definition.decoration == "volcanic" else Color("55555d") if definition.decoration == "citadel" else Color("405256") if definition.decoration == "mountain" else Color("294536"))
		if marsh:
			var factor: float = (layout.board[1].x-layout.board[0].x)/(definition.size.x*2.0)
			MarshArt.draw_ground(self,func(point: Vector2):return layout.board[0]+project(point)*factor,true,definition.get("water_areas",MarshArt.POOLS))
		var outline: PackedVector2Array = layout.board.duplicate();outline.append(outline[0])
		draw_polyline(outline,Color("48634e"),1,true)
		for path in layout.paths: draw_polyline(path,Color("645b3b"),9,true)
		for path in layout.paths: draw_polyline(path,MarshArt.ROAD if marsh else Color("d6c18a"),5,true)
		for point in layout.slots:
			var diamond := PackedVector2Array([point+Vector2(0,-4),point+Vector2(7,0),point+Vector2(0,4),point+Vector2(-7,0)])
			draw_colored_polygon(diamond,Color("142d28"));diamond.append(diamond[0]);draw_polyline(diamond,Color("bdd0c3"),1.5,true)
		var fortress: Vector2 = layout.paths[0][-1]
		for index in range(layout.paths.size()):
			draw_circle(layout.paths[index][0],4,[Color("e9c46a"),Color("83c4c6"),Color("c8a6e3")][index%3])
		draw_rect(Rect2(fortress-Vector2(5,7),Vector2(10,10)),Color("a5c8c1"))
		draw_line(fortress+Vector2(0,-7),fortress+Vector2(0,-16),Color("d9e4d7"),1.5,true)
		draw_colored_polygon(PackedVector2Array([fortress+Vector2(0,-16),fortress+Vector2(8,-13),fortress+Vector2(0,-10)]),Color("e9c46a"))
		var entrances := "Entrée" if layout.paths.size() == 1 else "%d entrées" % layout.paths.size()
		var legend: String = "%s → Forteresse · %d emplacements" % [entrances,layout.slots.size()]
		draw_string(font,Vector2((size.x-font.get_string_size(legend,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x)/2,size.y-8),legend,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("bbcbbf"))
	func _background() -> StyleBoxFlat:
		var box := StyleBoxFlat.new();box.bg_color = Color("0c1d17");box.set_corner_radius_all(6);return box

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
	var state: String = "future"
	func _draw() -> void:
		if state == "future":
			for segment in range(12):
				draw_arc(Vector2(21,21),20,TAU*segment/12,TAU*(segment+0.55)/12,5,Color("8fa397"),1.5,true)
			draw_circle(Vector2(38,4),8,Color("24352b"))
			for x in [35,38,41]: draw_circle(Vector2(x,4),1,Color("bcc9bf"))
		elif state == "unavailable":
			draw_circle(Vector2(38,4),8,Color("3c3421"))
			draw_string(ThemeDB.fallback_font,Vector2(35,8),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e5cd91"))
		elif completed:
			draw_circle(Vector2(38,4),8,Color("203c29"))
			draw_polyline(PackedVector2Array([Vector2(34,4),Vector2(37,7),Vector2(42,0)]),Color("b1d39b"),2,true)
		elif locked:
			draw_circle(Vector2(38,4),8,Color("182a22"))
			draw_arc(Vector2(38,2),3,PI,TAU,12,Color("9ba89f"),1.5,true)
			draw_rect(Rect2(34,2,8,6),Color("9ba89f"),false,1.5)

var scout: ColorRect
var scout_button: Button
var shop_button: Button
var shop_note: Label
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
var chapter_scroll: ScrollContainer
var chapter_reveal_pending: bool = false
var nodes: Array[MissionNode] = []
var path_drawing: PathDrawing
var mission_heading: Label
var mission_title: Label
var terrain_preview: TerrainPreview
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
	chapter_scroll = ScrollContainer.new();chapter_scroll.position = Vector2(48,174);chapter_scroll.size = Vector2(188,498)
	chapter_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED;chapter_scroll.follow_focus = true;add_child(chapter_scroll)
	var list := VBoxContainer.new();list.custom_minimum_size.x = 172;list.add_theme_constant_override("separation",6);chapter_scroll.add_child(list)
	for number in range(1,Catalogue.CHAPTER_COUNT+1):
		var button := Button.new();button.custom_minimum_size = Vector2(172,34);button.add_theme_font_size_override("font_size",14)
		style(button,Color("142f24"),Color("394e40"));button.pressed.connect(_chapter.bind(number))
		list.add_child(button);chapter_buttons.append(button)
	chapter_label = label_at(self,"",Rect2(292,132,508,32),22)
	label_at(self,"✓ Réussie · Cadenas : verrouillée · Pointillés : à venir",Rect2(292,170,508,22),12,Color("aabeb0"))
	path_drawing = PathDrawing.new();path_drawing.position = Vector2(292,200);path_drawing.size = Vector2(508,478)
	path_drawing.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(path_drawing)
	var columns: Array[int] = [200,270,200,130,200,270,200,130,200,270]
	for index in range(10):
		var node := MissionNode.new();node.position = Vector2(columns[index],48*index);node.size = Vector2(42,42)
		node.add_theme_font_size_override("font_size",16)
		node.pressed.connect(_select.bind(index));node.focus_entered.connect(_select.bind(index))
		path_drawing.add_child(node);nodes.append(node)
		path_drawing.points.append(node.position+Vector2(21,21))
	mission_heading = label_at(self,"",Rect2(870,136,206,28),17,Color("e5c779"))
	mission_title = label_at(self,"",Rect2(870,172,358,48),24)
	terrain_preview = TerrainPreview.new();terrain_preview.position = Vector2(870,232);terrain_preview.size = Vector2(358,144);add_child(terrain_preview)
	mission_detail = label_at(self,"",Rect2(870,384,358,44),14,Color("bbcbbf"))
	rewards = label_at(self,"",Rect2(870,436,358,50),16,Color("e5c779"))
	start_button = button_at("Jouer",Rect2(870,500,358,44),_launch)
	talents_button = button_at("Préparer les talents",Rect2(870,556,358,42),_talents)
	label_at(self,"Mode infini",Rect2(870,608,358,24),16)
	infinite_label = label_at(self,"",Rect2(870,636,358,40),13,Color("aabeb0"))
	shop_note = label_at(self,"",Rect2(32,704,1216,28),14,Color("9eb3a4"))
	shop_button = button_at("Boutique · Option supplémentaire",Rect2(292,744,330,38),_shop)
	back_button = button_at("Changer de faction · Échap",Rect2(32,744,240,38),close)
	footer = label_at(self,"",Rect2(646,744,602,42),13,Color("91a799"))
	scout_button = button_at("Voir les ennemis",Rect2(1080,134,148,30),_scout)
	scout = Scout.new();add_child(scout);scout.closed.connect(_scout_closed)
	hide()

func open(for_profile: RefCounted, for_faction: int, for_chapter: int = 0) -> void:
	if for_faction not in [0,1]: return
	if scout.visible: scout.close()
	profile = for_profile;faction = for_faction;chapter = clampi(for_chapter,1,Catalogue.CHAPTER_COUNT);selected = 0
	if for_chapter == 0:
		var number: int = Catalogue.suggested_mission(profile.campaign_status(faction) if profile != null else {})
		chapter = (number-1)/Catalogue.CHAPTER_SIZE+1;selected = (number-1)%Catalogue.CHAPTER_SIZE
	set_overlay_blocked(false);show();refresh();initial_focus().grab_focus()

func close() -> void:
	if scout.visible: scout.close()
	var was_visible: bool = visible;hide()
	if was_visible: closed.emit()

func initial_focus() -> Button:
	if scout.visible: return scout.wave_filter if scout.wave_filter.has_focus() else scout.close_button
	return start_button if not start_button.disabled else nodes[selected]

func set_overlay_blocked(value: bool) -> void:
	value = value or scout.visible
	if overlay_blocked == value: return
	overlay_blocked = value
	for button in chapter_buttons+nodes+[start_button,talents_button,shop_button,scout_button,back_button]:
		button.focus_mode = Control.FOCUS_NONE if value else Control.FOCUS_ALL

func _unhandled_key_input(event: InputEvent) -> void:
	if scout.visible:
		scout._unhandled_key_input(event);return
	if visible and not overlay_blocked and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close();get_viewport().set_input_as_handled()

func _chapter(number: int) -> void:
	if overlay_blocked or number < 1 or number > Catalogue.CHAPTER_COUNT: return
	chapter = number;selected = 0;refresh();nodes[0].grab_focus()

func _select(index: int) -> void:
	if overlay_blocked or index < 0 or index >= 10: return
	selected = index;_refresh_nodes();_refresh_detail()

func chapter_in_view() -> bool:
	return chapter_scroll.get_global_rect().encloses(chapter_buttons[chapter-1].get_global_rect())

func _reveal_chapter() -> void:
	chapter_reveal_pending = false
	if visible and not overlay_blocked: chapter_scroll.ensure_control_visible(chapter_buttons[chapter-1])

func _chapter_has_content(number: int) -> bool:
	for mission in range((number-1)*Catalogue.CHAPTER_SIZE+1,number*Catalogue.CHAPTER_SIZE+1):
		if Catalogue.definition(mission).available: return true
	return false

func _mission_state(number: int) -> String:
	if not Catalogue.definition(number).available: return "future"
	if status.is_empty(): return "unavailable"
	if status.missions[number-1]: return "completed"
	return "available" if Catalogue.unlocked(number,status) else "locked"

func refresh() -> void:
	if profile != null:
		var extra: Dictionary = profile.Shop.card(profile.data.banks[faction].shop_selected)
		shop_note.text = "Trois types habituels + option boutique : "+("indisponible" if profile.blocked else "aucune" if extra.is_empty() else extra.name)+" · Choix fixé pendant la mission."
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
		var detail: String = ("—" if status.is_empty() else str(status.chapters[index]))+"/10" if _chapter_has_content(index+1) else "À venir"
		chapter_buttons[index].text = "Chapitre %d · %s" % [index+1,detail]
		style(chapter_buttons[index],Color("254434") if chapter == index+1 else Color("142f24"),Color("d8c481") if chapter == index+1 else Color("394e40"))
	chapter_label.text = "Chapitre %d · Missions %d–%d" % [chapter,(chapter-1)*10+1,chapter*10]
	talents_button.disabled = profile == null
	footer.text = "Prototype · %d missions jouables sur %d prévues. Les autres contenus sont à venir." % [Catalogue.available_count(),Catalogue.TOTAL_MISSIONS]
	if profile != null:
		if not profile.error.is_empty(): footer.text = profile.error
		elif not profile.migration_notice.is_empty(): footer.text = profile.migration_notice
	_refresh_nodes();_refresh_detail()
	if not chapter_reveal_pending:
		chapter_reveal_pending = true;_reveal_chapter.call_deferred()

func _refresh_nodes() -> void:
	path_drawing.completed.clear()
	for index in range(10):
		var number: int = (chapter-1)*10+index+1
		var definition: Dictionary = Catalogue.definition(number)
		var done: bool = not status.is_empty() and status.missions[number-1]
		var state: String = _mission_state(number)
		var border: Color = Color("a7ca8b") if done else Color("d8c481") if Catalogue.unlocked(number,status) else Color("42574a")
		if state == "future": border = Color.TRANSPARENT
		if index == selected: border = Color("e5cd91")
		style(nodes[index],Color("14241c") if state == "future" else Color("254934") if done else Color("1b3027"),border,21)
		nodes[index].add_theme_color_override("font_color",Color("aabeb0") if state == "future" else Color("e0dbbf"))
		nodes[index].text = str(number);nodes[index].completed = done;nodes[index].locked = state == "locked";nodes[index].state = state;nodes[index].queue_redraw()
		var description: String = {"future":"À venir","unavailable":"Progression indisponible","completed":"Déjà réussie","available":"Disponible","locked":"Terminez la mission précédente"}[state]
		nodes[index].tooltip_text = "%s · %s" % [definition.title,description]
		path_drawing.completed.append(done)
	path_drawing.queue_redraw()

func _refresh_detail() -> void:
	var number: int = (chapter-1)*10+selected+1
	var definition: Dictionary = Catalogue.definition(number)
	var done: bool = not status.is_empty() and status.missions[number-1]
	mission_heading.text = "Mission %d" % number
	var title_width: float = mission_title.get_theme_font("font").get_string_size(definition.title,HORIZONTAL_ALIGNMENT_LEFT,-1,24).x
	var title_size := clampi(floori(24.0*358.0/maxf(title_width,1.0)),18,24)
	mission_title.add_theme_font_size_override("font_size",title_size)
	mission_title.size = Vector2(358,48)
	mission_title.text = definition.title
	terrain_preview.show_map(definition.get("map_id","") if definition.available else "")
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
	scout_button.disabled = not definition.available
	start_button.disabled = not Catalogue.unlocked(number,status)
	if definition.available and not status.is_empty(): mission_detail.text += "\nPV ennemis : %d %% · Barème d’essai" % definition.hp_percent
	mission_detail.tooltip_text = ""
	if definition.get("combat_affix",{}).get("id","") == "eruptions":
		mission_detail.text = "%d vagues · PV ennemis : %d %%\nNouveau : Éruptions · défenseur désactivé" % [definition.waves,definition.hp_percent]
		mission_detail.tooltip_text = "Toutes les %d s de combat, un défenseur choisi au hasard est désactivé pendant %d s : il ne tire plus. Son emplacement est signalé %d s avant. Réglage d’essai." % [int(definition.combat_affix.interval),int(definition.combat_affix.duration),int(definition.combat_affix.warning)]
	elif definition.has("combat_affix"):
		mission_detail.text = "%d vagues · PV ennemis : %d %%\nVents contraires · Cadence −10 %%" % [definition.waves,definition.hp_percent]
		mission_detail.tooltip_text = "Tous les défenseurs attaquent 10 % moins souvent. Les dégâts périodiques déjà appliqués gardent leur rythme. Réglage d’essai."
	if definition.get("wave_set_id","") == "ford_banks":
		mission_detail.text = "%d vagues · PV ennemis : %d %%\nNouveau : tortue gardienne" % [definition.waves,definition.hp_percent]
		mission_detail.tooltip_text = "Essai : la tortue encaisse 25 % des dégâts des voisins proches, dans la limite de ses PV. Ne protège ni les autres tortues ni les boss. Mêmes tracés que le chapitre 1 ; nouvelles rencontres. Valeurs provisoires."
	if definition.get("wave_set_id","") == "citadel_garrison":
		mission_detail.text = "%d vagues · PV ennemis : %d %%\nNouveau : Garnison · capitaine d'élite" % [definition.waves,definition.hp_percent]
		mission_detail.tooltip_text = "Essai : la Garnison est l'unité d'élite de la citadelle (520 PV, vitesse 0,6, −4 PV de forteresse) ; elle accompagne les vagues 5, 7, 9 et 10. Valeurs provisoires."
	if definition.get("wave_set_id","") == "marsh_drowned":
		mission_detail.text = "%d vagues · PV ennemis : %d %%
Nouveau : Noyé · eau régénérante" % [definition.waves,definition.hp_percent]
		mission_detail.tooltip_text = "Essai : le Noyé régénère %d %% de ses PV maximum par seconde dans les tronçons inondés de la carte, repérés en bleu sur le chemin. Valeurs provisoires." % roundi(Drowned.REGEN_PER_SECOND*100.0)
	if status.is_empty():
		mission_detail.text = "La progression n’est pas disponible."
		rewards.text = profile.error if profile != null and not profile.error.is_empty() else "Revenez au choix de faction pour vérifier votre progression."
		start_button.text = "Progression indisponible"

func _launch() -> void:
	if overlay_blocked or not visible or start_button.disabled or profile == null or profile.blocked: return
	var id: String = Catalogue.id_for((chapter-1)*10+selected+1)
	if Catalogue.runtime(id).is_empty() or not Catalogue.unlocked(Catalogue.number_for(id),profile.campaign_status(faction)): return
	mission_requested.emit(id)

func _talents() -> void:
	if not overlay_blocked and visible and profile != null: talents_requested.emit(faction)

func _shop() -> void:
	if not overlay_blocked and visible and profile != null: shop_requested.emit(faction)

func _scout() -> void:
	if overlay_blocked or not visible or scout_button.disabled: return
	if scout.open((chapter-1)*10+selected+1,faction): set_overlay_blocked(true)
func _scout_closed() -> void:
	set_overlay_blocked(false)
	if visible: scout_button.grab_focus()
