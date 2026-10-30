extends ColorRect
const Talents = preload("res://scripts/meta_talents.gd")
const Expanded = Talents.Linked
const TREE_ROLES: Array = [["Forteresse et portée","Tirs à distance","Magie et explosions"],["Haches et rebonds","Malédictions","Explosifs"]]
signal closed

class TalentButton extends Button:
	var glyph: int = 0
	var accent: Color = Color.WHITE
	var lit: bool = false
	var rank_text: String = ""
	var state: String = "locked"
	var major: bool = false
	var highlighted: bool = false
	func _draw() -> void:
		draw_set_transform(Vector2.ZERO,0,Vector2(42.0/52.0,42.0/52.0))
		var font: Font = get_theme_font("font")
		var width: float = font.get_string_size(rank_text,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x
		draw_string(font,Vector2((52-width)/2,48),rank_text,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("efdfae"))
		var ink: Color = accent if lit else accent.darkened(0.55)
		var c := Vector2(26,19)
		match glyph:
			0:
				draw_colored_polygon(PackedVector2Array([c+Vector2(-10,-10),c+Vector2(10,-10),c+Vector2(8,4),c+Vector2(0,12),c+Vector2(-8,4)]),ink)
				draw_line(c+Vector2(0,-7),c+Vector2(0,7),Color("17251e"),2)
			1,3:
				draw_line(c+Vector2(-9,10),c+Vector2(9,-10),ink,5,true)
				draw_line(c+Vector2(-11,1),c+Vector2(-1,10),ink,2,true)
				if glyph == 3: draw_arc(c+Vector2(5,-5),10,-1.8,0.8,12,ink,5,true)
			2:
				for ray in range(8):
					var v: Vector2 = Vector2.RIGHT.rotated(ray*TAU/8)
					draw_line(c+v*4,c+v*12,ink,2,true)
				draw_circle(c,4,ink)
			4:
				draw_polyline(PackedVector2Array([c+Vector2(0,-12),c+Vector2(9,0),c+Vector2(0,12),c+Vector2(-9,0),c+Vector2(0,-12)]),ink,2,true)
				draw_circle(c,3,ink)
			6:
				draw_arc(c,11,0,PI,16,ink,2,true)
				draw_arc(c,11,PI,TAU,16,ink,2,true)
				draw_circle(c,4,ink)
			5:
				draw_circle(c+Vector2(0,3),9,ink)
				draw_polyline(PackedVector2Array([c+Vector2(0,-6),c+Vector2(2,-11),c+Vector2(8,-10)]),ink,2,true)
		if major:
			var star := Vector2(9,9)
			draw_colored_polygon(PackedVector2Array([star+Vector2(0,-6),star+Vector2(2,-2),star+Vector2(6,0),star+Vector2(2,2),star+Vector2(0,6),star+Vector2(-2,2),star+Vector2(-6,0),star+Vector2(-2,-2)]),Color("f0d38b") if lit else Color("84734e"))
		var badge := Vector2(44,8)
		var color: Color = Color("a9d48a") if state == "available" else Color("e5c779") if state in ["maximum","unfunded","capped"] else Color("9ba89f")
		draw_circle(badge,8,Color("101b16"));draw_arc(badge,8,0,TAU,24,color,1,true)
		if state in ["locked","blocked","prerequisite"]:
			draw_arc(badge+Vector2(0,-1),3,PI,TAU,10,color,1.5,true)
			draw_rect(Rect2(badge+Vector2(-4,-1),Vector2(8,6)),color,false,1.5)
		else:
			var symbol: String = {"available":"+","maximum":"✓","exclusive":"×","unfunded":"!","capped":"!"}.get(state,"?")
			var symbol_width: float = font.get_string_size(symbol,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x
			draw_string(font,badge+Vector2(-symbol_width/2,4),symbol,HORIZONTAL_ALIGNMENT_LEFT,-1,13,color)
		if highlighted:
			for pair in [[Vector2(-3,-3),Vector2(1,1)],[Vector2(55,-3),Vector2(-1,1)],[Vector2(55,55),Vector2(-1,-1)],[Vector2(-3,55),Vector2(1,-1)]]:
				draw_line(pair[0],pair[0]+Vector2(pair[1].x*7,0),Color("f0e6bf"),2,true)
				draw_line(pair[0],pair[0]+Vector2(0,pair[1].y*7),Color("f0e6bf"),2,true)

class TreeBoard extends Control:
	var tree: int = 0
	var ranks: Array = []
	var accent: Color
	var opened: Array[bool] = [true,false,false,false,false,false,false]
	var progress: Array[int] = [0,0,0,0,0,0,0]
	func _draw() -> void:
		var box := StyleBoxFlat.new();box.bg_color = accent.darkened(0.83);box.border_color = accent.darkened(0.5)
		box.set_border_width_all(1);box.set_corner_radius_all(8);draw_style_box(box,Rect2(Vector2.ZERO,size))

class TreeTracks extends Control:
	var board: TreeBoard
	static func button_position(index: int) -> Vector2:
		var cell: Vector2i = Expanded.layout(index)
		return Vector2(47+78*cell.x,6+48*cell.y)
	static func link_route(child: int) -> PackedVector2Array:
		var parent: int = Expanded.parent_index(child)
		if parent < 0: return PackedVector2Array()
		var start: Vector2 = button_position(parent)+Vector2(21,42)
		var end: Vector2 = button_position(child)+Vector2(21,-2)
		return PackedVector2Array([start,end])

	func _draw() -> void:
		if board.ranks.size() != Expanded.NODE_COUNT: return
		# Le palier 20 partage deux rangées, reliées par une accolade de lecture.
		var bracket := PackedVector2Array([Vector2(36,198),Vector2(30,198),Vector2(30,282),Vector2(36,282)])
		draw_polyline(bracket,Color("536159"),1,true)
		for local in Expanded.PARENTS:
			var child: int = Expanded.index_for(board.tree,local)
			var route: PackedVector2Array = link_route(child)
			var end: Vector2 = route[-1]
			var ink: Color = Color("dab868") if Expanded.parent_complete(board.ranks,child) else Color("536159")
			draw_polyline(route,ink,2,true)
			draw_colored_polygon(PackedVector2Array([end+Vector2(0,1),end+Vector2(-4,-4),end+Vector2(4,-4)]),ink)

var profile: RefCounted
var faction: int = 0
var heading: Label
var balance: Label
var notice: Label
var buy: Button
var xp_label: Label
var xp_bar: ProgressBar
var reset_button: Button
var names: Array[Label] = []
var nodes: Array[Button] = []
var descriptions: Array[Label] = [] # Noms courts ; les effets sont dans l'encart de lecture.
var boards: Array[Control] = []
var scrollers: Array[ScrollContainer] = []
var tracks: Array[Control] = []
var point_labels: Array[Label] = []
var tier_labels: Array[Label] = []
var detail_title: Label
var detail_text: Label
var inspected: int = 0
var confirm: ConfirmationDialog
var reset_quote: Dictionary = {}

func label_at(parent: Control, text: String, rect: Rect2, font_size: int = 16) -> Label:
	var label := Label.new();label.text = text;label.position = rect.position;label.size = rect.size
	label.add_theme_font_size_override("font_size",font_size);label.add_theme_color_override("font_color",Color("e0dbbf"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;parent.add_child(label);return label

func style_for(button: Button, background: Color, border: Color) -> void:
	var style := StyleBoxFlat.new();style.bg_color = background;style.border_color = border
	style.set_border_width_all(2);style.set_corner_radius_all(5)
	button.add_theme_stylebox_override("normal",style)
	button.add_theme_stylebox_override("hover",style)
	var focus: StyleBoxFlat = style.duplicate();focus.border_color = Color("f2dc9a")
	button.add_theme_stylebox_override("focus",focus)

func button_at(parent: Control, text: String, rect: Rect2, action: Callable) -> Button:
	var button := Button.new();button.text = text;button.position = rect.position;button.size = rect.size
	button.add_theme_font_size_override("font_size",15);button.pressed.connect(action)
	style_for(button,Color("1c3a30"),Color("74866b"));parent.add_child(button);return button

func _ready() -> void:
	color = Color("080f0c");set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	heading = label_at(self,"Talents",Rect2(32,18,900,40),28)
	balance = label_at(self,"",Rect2(32,66,890,32),16)
	buy = button_at(self,"",Rect2(940,58,308,42),_buy)
	buy.hide();buy.disabled = true
	xp_label = label_at(self,"",Rect2(940,58,308,25),14)
	xp_bar = ProgressBar.new();xp_bar.position = Vector2(940,88);xp_bar.size = Vector2(308,10)
	xp_bar.show_percentage = false;add_child(xp_bar)
	for part in ["background","fill"]:
		var xp_style := StyleBoxFlat.new();xp_style.bg_color = Color("8aa4ba") if part == "fill" else Color("1c302a")
		xp_style.set_corner_radius_all(4);xp_style.set_content_margin_all(0)
		xp_bar.add_theme_stylebox_override(part,xp_style)
	var help := label_at(self,"Survol ou clavier : lire un talent · + Rang disponible · ✓ Rang maximum · ★ Talent majeur",Rect2(32,112,1216,30),14)
	help.tooltip_text = "Cadenas : palier ou parent à terminer. Croix : autre spécialité choisie.\nFlèche grise : parent à terminer ; dorée : prérequis rempli.\nLa description du talent indique la condition exacte."
	help.mouse_filter = Control.MOUSE_FILTER_STOP
	nodes.resize(Expanded.NODE_COUNT);descriptions.resize(Expanded.NODE_COUNT)
	for tree in range(3):
		var board := TreeBoard.new();board.position = Vector2(32+416*tree,144);board.size = Vector2(384,468)
		board.tree = tree;board.mouse_filter = Control.MOUSE_FILTER_IGNORE;board.accent = Color("638c86");add_child(board);boards.append(board)
		names.append(label_at(board,"",Rect2(40,12,328,32),22))
		point_labels.append(label_at(board,"",Rect2(40,48,328,24),14))
		var scroll := ScrollContainer.new();scroll.position = Vector2(0,80);scroll.size = Vector2(384,388)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED;scroll.follow_focus = true
		board.add_child(scroll);scrollers.append(scroll)
		var content := TreeTracks.new();content.board = board;content.custom_minimum_size = Vector2(368,388)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE;scroll.add_child(content);tracks.append(content)
		for row in range(7): tier_labels.append(label_at(content,"",Rect2(2,15+48*Expanded.TIER_VISUAL_ROWS[row]+(24 if row == 4 else 0),34,20),11))
		for local in range(21):
			var index: int = Expanded.index_for(tree,local)
			var pos: Vector2 = TreeTracks.button_position(index)
			var button := TalentButton.new();button.position = pos;button.size = Vector2(42,42)
			button.add_theme_font_size_override("font_size",14)
			button.pressed.connect(_allocate.bind(index));button.mouse_entered.connect(_inspect.bind(index));button.focus_entered.connect(_inspect.bind(index))
			content.add_child(button);nodes[index] = button
			var label: Label = label_at(content,"",Rect2(pos+Vector2(-22,58),Vector2(96,44)),12)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;label.mouse_filter = Control.MOUSE_FILTER_STOP
			label.mouse_entered.connect(_inspect.bind(index));label.hide();descriptions[index] = label
	var info := Panel.new();info.position = Vector2(32,616);info.size = Vector2(1216,110);add_child(info)
	var box := StyleBoxFlat.new();box.bg_color = Color("132820");box.set_corner_radius_all(6);info.add_theme_stylebox_override("panel",box)
	detail_title = label_at(info,"",Rect2(16,4,1184,26),18)
	detail_text = label_at(info,"",Rect2(16,32,1184,72),14)
	reset_button = button_at(self,"",Rect2(32,730,320,42),_request_reset)
	button_at(self,"Retour · Échap",Rect2(940,730,308,42),close)
	notice = label_at(self,"",Rect2(370,730,550,58),12)
	confirm = ConfirmationDialog.new();confirm.title = "Réinitialiser les talents"
	confirm.ok_button_text = "Réinitialiser gratuitement";confirm.cancel_button_text = "Annuler"
	confirm.confirmed.connect(_reset);confirm.canceled.connect(_cancel_reset);add_child(confirm);hide()

func open(for_profile: RefCounted, for_faction: int) -> void:
	if for_profile == null or for_faction not in [0,1]: return
	_cancel_reset()
	profile = for_profile;faction = for_faction;inspected = 0
	for scroll in scrollers: scroll.scroll_vertical = 0
	refresh();show();nodes[0].grab_focus()

func close() -> void:
	var was_visible: bool = visible
	_cancel_reset();hide()
	if was_visible: closed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close();get_viewport().set_input_as_handled()

func _current_ranks() -> Array:
	return Expanded.normalize(profile.data.banks[faction].ranks) if profile != null else []

func refresh() -> void:
	var bank: Dictionary = profile.data.banks[faction]
	var ranks: Array = _current_ranks()
	if ranks.is_empty():
		notice.text = "Configuration de talents à vérifier.";buy.disabled = true;reset_button.disabled = true
		return
	var camp: String = "Alliance" if faction == 0 else "Horde"
	heading.text = "Talents · "+camp
	var free: int = maxi(0,mini(int(bank.points),Expanded.MAX_POINTS)-Expanded.spent(ranks))
	var available_text: String = "Progression à vérifier" if profile.blocked else "Aucun point à placer" if free == 0 else "%d point%s à placer" % [free,"s" if free > 1 else ""]
	balance.text = "%s · %d/51 débloqués · %d XP" % [available_text,bank.points,bank.get("xp",0)]
	if profile.blocked: balance.text = "Progression à vérifier · Points et XP indisponibles"
	balance.add_theme_color_override("font_color",Color("e5c779") if free > 0 and not profile.blocked else Color("e0dbbf"))
	balance.tooltip_text = "51 points maximum à répartir entre les trois arbres de cette faction. Un point augmente un rang de talent.\nPO %s : %d, réservées à la future boutique ; elles ne servent pas à acheter des talents." % [camp,bank.resource]
	if profile.blocked: balance.tooltip_text = "Progression indisponible. Vérifiez la sauvegarde avant de modifier les talents."
	balance.mouse_filter = Control.MOUSE_FILTER_STOP
	var experience: Dictionary = profile.Experience.progress(int(bank.get("xp",0)))
	var at_cap: bool = bank.points >= Expanded.MAX_POINTS
	var lower_xp: int = profile.Experience.xp_for_points(mini(int(bank.points),Expanded.MAX_POINTS))
	var next_xp: int = 0 if at_cap else profile.Experience.xp_for_points(int(bank.points)+1)
	xp_label.text = "51 points de talent débloqués" if at_cap else "Prochain point : encore %d XP" % maxi(0,next_xp-experience.xp)
	xp_label.tooltip_text = "L’XP est conservée dans cette faction. Seule la première victoire d’une mission rapporte de l’XP.\nObjectif de campagne : 51 points sur les 100 premières missions."
	xp_label.mouse_filter = Control.MOUSE_FILTER_STOP
	xp_bar.max_value = 1 if at_cap else next_xp-lower_xp
	xp_bar.value = 1 if at_cap else maxi(0,experience.xp-lower_xp)
	if profile.blocked:
		xp_label.text = "XP indisponible";xp_bar.max_value = 1;xp_bar.value = 0
	buy.disabled = true;buy.hide()
	for tree in range(3):
		names[tree].text = Talents.TREES[faction][tree][0]
		var accent: Color = ([Color("8aa4ba"),Color("8fb675"),Color("b69bda")] if faction == 0 else [Color("d28c70"),Color("b398d4"),Color("d4b078")])[tree]
		boards[tree].accent = accent;boards[tree].ranks = ranks.duplicate()
		var invested: int = Expanded.tree_spent(ranks,tree)
		point_labels[tree].text = "%d point%s · %s" % [invested,"s" if invested > 1 else "",TREE_ROLES[faction][tree]]
		point_labels[tree].tooltip_text = "%d point%s investi%s dans cet arbre. Les 51 points sont partagés entre les trois arbres de %s." % [invested,"s" if invested > 1 else "","s" if invested > 1 else "",camp]
		if profile.blocked:
			point_labels[tree].text = "Points indisponibles · "+TREE_ROLES[faction][tree]
			point_labels[tree].tooltip_text = "Progression indisponible. Le nombre de points investis ne peut pas être confirmé."
		point_labels[tree].mouse_filter = Control.MOUSE_FILTER_STOP
		for row in range(7):
			var invested_below: int = mini(Expanded.THRESHOLDS[row],Expanded.lower_spent(ranks,tree,row))
			var missing: int = Expanded.THRESHOLDS[row]-invested_below
			boards[tree].opened[row] = missing == 0;boards[tree].progress[row] = invested_below
			tier_labels[tree*7+row].text = str(Expanded.THRESHOLDS[row])
			tier_labels[tree*7+row].tooltip_text = ("Palier : %d/%d points dans les lignes précédentes de cet arbre." % [invested_below,Expanded.THRESHOLDS[row]])+(" Les deux rangées accolées appartiennent au même palier de 20 points." if row == 4 else "")
			tier_labels[tree*7+row].mouse_filter = Control.MOUSE_FILTER_STOP
			tier_labels[tree*7+row].add_theme_color_override("font_color",Color("dab868") if missing == 0 else Color("7c8c82"))
		boards[tree].queue_redraw();tracks[tree].queue_redraw()
		for local in range(21):
			var index: int = Expanded.index_for(tree,local)
			var definition: Dictionary = Expanded.node(faction,index)
			var available: bool = not profile.blocked and Expanded.allocation_error(ranks,index,int(bank.points),faction).is_empty()
			nodes[index].state = _node_state(index,ranks)
			var learned: bool = ranks[index] > 0
			nodes[index].rank_text = ("—/%d" % definition.maximum) if profile.blocked else "%d/%d" % [ranks[index],definition.maximum]
			nodes[index].major = definition.major
			nodes[index].highlighted = index == inspected
			nodes[index].glyph = _glyph_for(definition.effect);nodes[index].accent = accent;nodes[index].lit = available or learned
			style_for(nodes[index],accent.darkened(0.77) if available or learned else Color("141c19"),Color("dab868") if learned or (definition.major and available) else accent if available else Color("3c4b43"))
			nodes[index].queue_redraw();descriptions[index].text = definition.name
			var tooltip: String = definition.name+(" · Talent majeur" if definition.major else "")+"\n"+definition.description+"\n"+Expanded.allocation_error(ranks,index,int(bank.points),faction)
			nodes[index].tooltip_text = tooltip;descriptions[index].tooltip_text = tooltip
	reset_button.text = "Réinitialiser · Gratuit"
	reset_button.disabled = profile.blocked or Expanded.spent(ranks) == 0
	reset_button.tooltip_text = "Gratuit entre les missions.\nTous les points de cette faction sont rendus.\nLes PO, l’XP et les points débloqués restent conservés."
	var guidance: String = "Choisissez un talent marqué +. Un point augmente un rang. Réinitialisation gratuite entre les missions." if free > 0 else "51 points répartis entre les trois arbres. Réinitialisez gratuitement pour essayer une autre répartition." if at_cap else "De nouveaux points se débloquent à la première victoire des missions. Rejouer ne rapporte pas d’XP."
	if profile.blocked: guidance = "Progression indisponible : vérifiez la sauvegarde avant de modifier les talents."
	notice.text = profile.error if not profile.error.is_empty() else profile.migration_notice if not profile.migration_notice.is_empty() else guidance
	_inspect(inspected)

static func _glyph_for(effect: Dictionary) -> int:
	if effect.has("hp"): return 0
	if effect.has("range"): return 6
	if effect.has("curse"): return 4
	if effect.has("secondary"): return 3 if effect.get("types",[]) == [3] else 5
	return 1

func _node_state(index: int, supplied: Array = []) -> String:
	if profile.blocked: return "blocked"
	var ranks: Array = _current_ranks() if supplied.is_empty() else supplied
	if ranks.is_empty(): return "blocked"
	var bank: Dictionary = profile.data.banks[faction]
	var position: Vector2i = Expanded.coordinates(index);var tree: int = position.x;var local: int = position.y
	if ranks[index] >= Expanded.MAX_RANKS[local]: return "maximum"
	if not Expanded.parent_complete(ranks,index): return "prerequisite"
	if Expanded.lower_spent(ranks,tree,Expanded.ROWS[local]) < Expanded.THRESHOLDS[Expanded.ROWS[local]]: return "locked"
	for group in Expanded.EXCLUSIONS:
		if local not in group: continue
		for other in group:
			if other != local and ranks[Expanded.index_for(tree,other)] > 0: return "exclusive"
	if Expanded.spent(ranks) >= Expanded.MAX_POINTS: return "capped"
	return "available" if Expanded.allocation_error(ranks,index,int(bank.points),faction).is_empty() else "unfunded"

func _inspect(index: int) -> void:
	if profile == null or index < 0 or index >= nodes.size(): return
	var ranks: Array = _current_ranks()
	if ranks.is_empty(): return
	var previous: int = inspected
	inspected = index
	for selected in [previous,index]:
		nodes[selected].highlighted = selected == index;nodes[selected].queue_redraw()
	var bank: Dictionary = profile.data.banks[faction]
	var definition: Dictionary = Expanded.node(faction,index)
	var state_text: String = {"available":"1 point pour ce rang","maximum":"Rang maximum","locked":"Palier fermé","prerequisite":"Parent à terminer","exclusive":"Autre spécialité choisie","unfunded":"XP à gagner","capped":"Plafond atteint","blocked":"Sauvegarde à vérifier"}[_node_state(index,ranks)]
	detail_title.text = "%s · Rang %d/%d · %s" % [("★ " if definition.major else "")+definition.name,ranks[index],definition.maximum,state_text]
	if profile.blocked: detail_title.text = "%s · Rang inconnu · %s" % [definition.name,state_text]
	var reason: String = Expanded.allocation_error(ranks,index,int(bank.points),faction)
	detail_text.text = definition.description.replace("\n"," ")+(" Choix exclusif entre les spécialités de cette ligne." if definition.local in [3,4] else "")
	if definition.parent >= 0:
		var parent: Dictionary = Expanded.node(faction,definition.parent)
		detail_text.text += " Prérequis : %s au rang %d/%d." % [parent.name,parent.maximum,parent.maximum]
	var gain: String = "" if profile.blocked else _rank_gain(index)
	if not gain.is_empty(): detail_text.text += "\nProchain rang · "+gain
	detail_text.text += "\n"+("Profil protégé : enregistrement à vérifier." if profile.blocked else reason if not reason.is_empty() else "Coût : 1 point · Cliquez pour investir un rang.")
	scrollers[definition.tree].ensure_control_visible(nodes[index])
	if descriptions[index].visible: scrollers[definition.tree].ensure_control_visible(descriptions[index])

func _number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".").replace(".",",")

func _rank_gain(index: int) -> String:
	var preview: Dictionary = Expanded.rank_preview(faction,_current_ranks(),index)
	if preview.is_empty(): return ""
	var parts: Array[String] = []
	if preview.hp_before != preview.hp_after:
		parts.append("PV supplémentaires : +%d → +%d" % [preview.hp_before,preview.hp_after])
	var groups: Dictionary = {}
	for unit in preview.units:
		var changes: Array[String] = []
		for component in ["direct","secondary","curse","range"]:
			if is_equal_approx(unit.before[component],unit.after[component]): continue
			var name: String = {"direct":"tirs","secondary":"rebonds" if unit.type == 3 else "explosions","curse":"malédictions","range":"portée"}[component]
			var scale: float = 1.0 if component == "range" else 100.0
			changes.append("%s +%s → +%s%s" % [name,_number(unit.before[component]*scale),_number(unit.after[component]*scale),"" if component == "range" else " %"])
		var key: String = ", ".join(changes)
		if not groups.has(key): groups[key] = []
		groups[key].append(["Archer","Arbalétrier","Mage","Lanceur de haches","Sapeur","Chaman"][unit.type])
	for key in groups: parts.append("%s : %s" % [" / ".join(groups[key]),key])
	return " · ".join(parts)

func _buy() -> void:
	profile.buy_point(faction);refresh()

func _allocate(index: int) -> void:
	inspected = index
	if not profile.blocked and Expanded.allocation_error(_current_ranks(),index,int(profile.data.banks[faction].points),faction).is_empty():
		profile.allocate(faction,index)
	refresh()

func _respec_preview() -> Dictionary:
	if profile == null or profile.blocked: return {}
	var bank: Dictionary = profile.data.banks[faction]
	var active: int = Talents.spent(bank.ranks)
	var price: int = profile.reset_price(faction)
	if active == 0: return {}
	return {"faction":faction,"before":bank.duplicate(true),"price":price,"balance_after":int(bank.resource)-price,"active":active,"free_before":int(bank.points)-active,"free_after":int(bank.points),"next_price":Talents.RESET_PRICES[mini(int(bank.resets)+1,Talents.RESET_PRICES.size()-1)]}

func _request_reset() -> void:
	if not visible: return
	_cancel_reset()
	reset_quote = _respec_preview()
	if reset_quote.is_empty(): return
	var camp: String = "Alliance" if faction == 0 else "Horde"
	confirm.dialog_text = "%s · Réinitialisation gratuite\n\nPoints à placer : %d → %d (+%d rendus)\nTous les talents seront retirés ; les points débloqués sont conservés.\nAucune PO n’est débitée. Répartissez ensuite vos points autrement.\n\nL’autre faction conserve sa progression." % [camp,reset_quote.free_before,reset_quote.free_after,reset_quote.active]
	confirm.popup_centered(Vector2i(650,300))

func _cancel_reset() -> void:
	reset_quote = {}
	confirm.hide()

func _reset() -> void:
	if profile == null: return
	var current: Dictionary = _respec_preview()
	var matches: bool = not reset_quote.is_empty() and current == reset_quote and visible
	_cancel_reset()
	if matches: profile.respec(faction)
	refresh()
	if not matches: notice.text = "La préparation a changé. Vérifiez le nouvel aperçu avant de réinitialiser."
