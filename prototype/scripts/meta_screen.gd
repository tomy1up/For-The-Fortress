extends ColorRect
const Talents = preload("res://scripts/meta_talents.gd")

class TalentButton extends Button:
	var glyph: int = 0
	var accent: Color = Color.WHITE
	var lit: bool = false
	var rank_text: String = ""
	func _draw() -> void:
		var font: Font = get_theme_font("font")
		var width: float = font.get_string_size(rank_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x
		draw_string(font,Vector2((52-width)/2,48),rank_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("efdfae"))
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
			5:
				draw_circle(c+Vector2(0,3),9,ink)
				draw_polyline(PackedVector2Array([c+Vector2(0,-6),c+Vector2(2,-11),c+Vector2(8,-10)]),ink,2,true)

class TreeBoard extends Control:
	var accent: Color
	var opened: Array[bool] = [true,false,false]
	func _draw() -> void:
		var box := StyleBoxFlat.new();box.bg_color = accent.darkened(0.83);box.border_color = accent.darkened(0.5)
		box.set_border_width_all(1);box.set_corner_radius_all(8);draw_style_box(box,Rect2(Vector2.ZERO,size))
		for row in range(3):
			var y: float = 132+117*row
			var ink: Color = Color("d8b96d") if opened[row] else Color("48594f")
			draw_circle(Vector2(18,y),4,ink)
			if row > 0:
				draw_line(Vector2(18,y-111),Vector2(18,y-8),ink,2,true)
				draw_polyline(PackedVector2Array([Vector2(13,y-18),Vector2(18,y-12),Vector2(23,y-18)]),ink,2,true)

var profile: RefCounted
var faction: int = 0
var heading: Label
var balance: Label
var notice: Label
var buy: Button
var reset_button: Button
var names: Array[Label] = []
var nodes: Array[Button] = []
var descriptions: Array[Label] = [] # Noms courts ; les effets sont dans l'encart de lecture.
var boards: Array[Control] = []
var point_labels: Array[Label] = []
var tier_labels: Array[Label] = []
var detail_title: Label
var detail_text: Label
var inspected: int = 0
var confirm: ConfirmationDialog

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
	label_at(self,"BARÈME D’ESSAI · De haut en bas : 0, 5 puis 10 points dépensés dans le même arbre.",Rect2(32,112,1216,30),15)
	for tree in range(3):
		var board := TreeBoard.new();board.position = Vector2(32+416*tree,158);board.size = Vector2(384,454)
		board.mouse_filter = Control.MOUSE_FILTER_IGNORE;board.accent = Color("638c86");add_child(board);boards.append(board)
		names.append(label_at(board,"",Rect2(40,12,328,32),22))
		point_labels.append(label_at(board,"",Rect2(40,48,328,24),14))
		for row in range(3): tier_labels.append(label_at(board,"",Rect2(40,80+117*row,330,22),12))
		for node in range(5):
			var index: int = tree*5+node
			var pos: Vector2 = [Vector2(166,106),Vector2(86,223),Vector2(246,223),Vector2(86,340),Vector2(246,340)][node]
			var button := TalentButton.new();button.position = pos;button.size = Vector2(52,52)
			button.add_theme_font_size_override("font_size",14)
			button.pressed.connect(_allocate.bind(index));button.mouse_entered.connect(_inspect.bind(index));button.focus_entered.connect(_inspect.bind(index))
			board.add_child(button);nodes.append(button)
			var label: Label = label_at(board,"",Rect2(pos+Vector2(-55,58),Vector2(162,38)),13)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;label.mouse_filter = Control.MOUSE_FILTER_STOP
			label.mouse_entered.connect(_inspect.bind(index));descriptions.append(label)
	var info := Panel.new();info.position = Vector2(32,628);info.size = Vector2(1216,84);add_child(info)
	var box := StyleBoxFlat.new();box.bg_color = Color("132820");box.set_corner_radius_all(6);info.add_theme_stylebox_override("panel",box)
	detail_title = label_at(info,"",Rect2(16,6,1184,28),18)
	detail_text = label_at(info,"",Rect2(16,36,1184,44),14)
	reset_button = button_at(self,"",Rect2(32,730,320,42),_request_reset)
	button_at(self,"Retour · Échap",Rect2(940,730,308,42),close)
	notice = label_at(self,"",Rect2(370,730,550,58),12)
	confirm = ConfirmationDialog.new();confirm.title = "Réinitialiser les talents"
	confirm.ok_button_text = "Payer et réinitialiser";confirm.cancel_button_text = "Annuler"
	confirm.confirmed.connect(_reset);add_child(confirm);hide()

func open(for_profile: RefCounted, for_faction: int) -> void:
	if for_profile == null or for_faction not in [0,1]: return
	profile = for_profile;faction = for_faction;inspected = 0;refresh();show();nodes[0].grab_focus()

func close() -> void:
	confirm.hide();hide()

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close();get_viewport().set_input_as_handled()

func refresh() -> void:
	var bank: Dictionary = profile.data.banks[faction]
	var camp: String = "Alliance" if faction == 0 else "Horde"
	heading.text = "Talents · "+camp
	balance.text = "Ressource %s : %d · Points disponibles : %d / %d achetés" % [camp,bank.resource,int(bank.points)-Talents.spent(bank.ranks),bank.points]
	buy.text = "Acheter 1 point · %d ressources" % Talents.POINT_PRICE
	buy.disabled = profile.blocked or bank.resource < Talents.POINT_PRICE or bank.points >= Talents.MAX_POINTS
	for tree in range(3):
		var definition: Array = Talents.TREES[faction][tree];names[tree].text = definition[0]
		var accent: Color = ([Color("8aa4ba"),Color("8fb675"),Color("b69bda")] if faction == 0 else [Color("d28c70"),Color("b398d4"),Color("d4b078")])[tree]
		boards[tree].accent = accent
		var invested: int = Talents.tree_spent(bank.ranks,tree)
		point_labels[tree].text = "%d point%s investi%s dans cet arbre" % [invested,"s" if invested > 1 else "","s" if invested > 1 else ""]
		for row in range(3):
			var missing: int = maxi(0,Talents.THRESHOLDS[row]-Talents.lower_spent(bank.ranks,tree,row))
			boards[tree].opened[row] = missing == 0
			tier_labels[tree*3+row].text = "Ligne %d · %s" % [row+1,"Accessible" if missing == 0 else "Encore %d points dans cet arbre" % missing]
		boards[tree].queue_redraw()
		for node in range(5):
			var index: int = tree*5+node
			var available: bool = not profile.blocked and Talents.can_allocate(bank.ranks,index,int(bank.points))
			var learned: bool = bank.ranks[index] > 0
			nodes[index].rank_text = "%d/%d" % [bank.ranks[index],Talents.MAX_RANKS[node]]
			nodes[index].glyph = faction*3+tree;nodes[index].accent = accent;nodes[index].lit = available or learned
			style_for(nodes[index],accent.darkened(0.77) if available or learned else Color("141c19"),Color("dab868") if learned else accent if available else Color("3c4b43"))
			nodes[index].add_theme_color_override("font_color",Color("f1d286") if learned else Color("c1cbc3"))
			nodes[index].queue_redraw()
			descriptions[index].text = definition[node+1][0]
			var tooltip: String = definition[node+1][0]+"\n"+definition[node+1][1]+"\n"+Talents.allocation_error(bank.ranks,index,int(bank.points))
			nodes[index].tooltip_text = tooltip;descriptions[index].tooltip_text = tooltip
	reset_button.text = "Réinitialiser · %d ressources" % profile.reset_price(faction)
	reset_button.disabled = profile.blocked or Talents.spent(bank.ranks) == 0 or bank.resource < profile.reset_price(faction)
	reset_button.tooltip_text = "Respécialisation n°%d de %s.\n2, 4, 6, 8, puis 10 ressources maximum.\nTous les points de cette faction seront rendus." % [int(bank.resets)+1,camp]
	notice.text = profile.error if not profile.error.is_empty() else profile.migration_notice if not profile.migration_notice.is_empty() else "Terminez des vagues pour gagner la ressource de cette faction. Talents appliqués à la prochaine partie."
	_inspect(inspected)

func _inspect(index: int) -> void:
	if profile == null or index < 0 or index >= nodes.size(): return
	inspected = index
	var bank: Dictionary = profile.data.banks[faction];var tree: int = int(index/5);var node: int = index%5
	var definition: Array = Talents.TREES[faction][tree][node+1]
	detail_title.text = "%s · Rang %d/%d" % [definition[0],bank.ranks[index],Talents.MAX_RANKS[node]]
	var reason: String = Talents.allocation_error(bank.ranks,index,int(bank.points))
	detail_text.text = definition[1]+(" Choix exclusif entre les deux spécialités." if node >= 3 else "")+"\n"+("Profil protégé : enregistrement à vérifier." if profile.blocked else reason if not reason.is_empty() else "Coût : 1 point · Cliquez pour investir un rang.")

func _buy() -> void:
	profile.buy_point(faction);refresh()

func _allocate(index: int) -> void:
	inspected = index
	if not profile.blocked and Talents.can_allocate(profile.data.banks[faction].ranks,index,int(profile.data.banks[faction].points)):
		profile.allocate(faction,index)
	refresh()

func _request_reset() -> void:
	confirm.dialog_text = "Payer %d ressources %s pour récupérer %d points ?\nLes trois arbres de cette faction seront réinitialisés.\nL’autre faction reste inchangée." % [profile.reset_price(faction),"Alliance" if faction == 0 else "Horde",Talents.spent(profile.data.banks[faction].ranks)]
	confirm.popup_centered(Vector2i(610,190))

func _reset() -> void:
	profile.respec(faction);refresh()
