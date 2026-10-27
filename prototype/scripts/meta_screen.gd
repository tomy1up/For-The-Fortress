extends ColorRect
const Talents = preload("res://scripts/meta_talents.gd")

class TalentButton extends Button:
	var glyph: int = 0
	var accent: Color = Color.WHITE
	var lit: bool = false
	var rank_text: String = ""
	var state: String = "locked"
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
		var badge := Vector2(44,8)
		var color: Color = Color("a9d48a") if state == "available" else Color("e5c779") if state in ["maximum","unfunded"] else Color("9ba89f")
		draw_circle(badge,8,Color("101b16"));draw_arc(badge,8,0,TAU,24,color,1,true)
		if state in ["locked","blocked"]:
			draw_arc(badge+Vector2(0,-1),3,PI,TAU,10,color,1.5,true)
			draw_rect(Rect2(badge+Vector2(-4,-1),Vector2(8,6)),color,false,1.5)
		else:
			var symbol: String = {"available":"+","maximum":"✓","exclusive":"×","unfunded":"!"}.get(state,"?")
			var symbol_width: float = font.get_string_size(symbol,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x
			draw_string(font,badge+Vector2(-symbol_width/2,4),symbol,HORIZONTAL_ALIGNMENT_LEFT,-1,13,color)

class TreeBoard extends Control:
	var accent: Color
	var opened: Array[bool] = [true,false,false]
	var progress: Array[int] = [0,0,0]
	func _draw() -> void:
		var box := StyleBoxFlat.new();box.bg_color = accent.darkened(0.83);box.border_color = accent.darkened(0.5)
		box.set_border_width_all(1);box.set_corner_radius_all(8);draw_style_box(box,Rect2(Vector2.ZERO,size))
		for row in range(3):
			var y: float = 132+117*row
			var ink: Color = Color("d8b96d") if opened[row] else Color("48594f")
			draw_circle(Vector2(18,y),4,ink)
			if row > 0:
				draw_rect(Rect2(40,102+117*row,328,3),Color("283c32"))
				draw_rect(Rect2(40,102+117*row,328*float(progress[row])/Talents.THRESHOLDS[row],3),ink)
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
	label_at(self,"+ Investir un rang · ✓ Maximum · Cadenas : palier fermé · × Autre spécialité choisie · ! Point à acheter",Rect2(32,112,1216,30),14)
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
	var info := Panel.new();info.position = Vector2(32,616);info.size = Vector2(1216,110);add_child(info)
	var box := StyleBoxFlat.new();box.bg_color = Color("132820");box.set_corner_radius_all(6);info.add_theme_stylebox_override("panel",box)
	detail_title = label_at(info,"",Rect2(16,4,1184,26),18)
	detail_text = label_at(info,"",Rect2(16,32,1184,72),14)
	reset_button = button_at(self,"",Rect2(32,730,320,42),_request_reset)
	button_at(self,"Retour · Échap",Rect2(940,730,308,42),close)
	notice = label_at(self,"",Rect2(370,730,550,58),12)
	confirm = ConfirmationDialog.new();confirm.title = "Réinitialiser les talents"
	confirm.ok_button_text = "Payer et réinitialiser";confirm.cancel_button_text = "Annuler"
	confirm.confirmed.connect(_reset);confirm.canceled.connect(_cancel_reset);add_child(confirm);hide()

func open(for_profile: RefCounted, for_faction: int) -> void:
	if for_profile == null or for_faction not in [0,1]: return
	_cancel_reset()
	profile = for_profile;faction = for_faction;inspected = 0;refresh();show();nodes[0].grab_focus()

func close() -> void:
	_cancel_reset();hide()

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
			var invested_below: int = mini(Talents.THRESHOLDS[row],Talents.lower_spent(bank.ranks,tree,row))
			var missing: int = Talents.THRESHOLDS[row]-invested_below
			boards[tree].opened[row] = missing == 0
			boards[tree].progress[row] = invested_below
			tier_labels[tree*3+row].text = "Ligne %d · %s" % [row+1,"Débloquée" if missing == 0 else "%d/%d points requis dans cet arbre" % [invested_below,Talents.THRESHOLDS[row]]]
		boards[tree].queue_redraw()
		for node in range(5):
			var index: int = tree*5+node
			var available: bool = not profile.blocked and Talents.can_allocate(bank.ranks,index,int(bank.points))
			nodes[index].state = _node_state(index)
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
	notice.text = profile.error if not profile.error.is_empty() else profile.migration_notice if not profile.migration_notice.is_empty() else "Barème d’essai · Ressources versées en fin de partie. Talents appliqués au prochain départ."
	_inspect(inspected)

func _node_state(index: int) -> String:
	if profile.blocked: return "blocked"
	var bank: Dictionary = profile.data.banks[faction]
	var tree: int = int(index/5);var node: int = index%5
	if bank.ranks[index] >= Talents.MAX_RANKS[node]: return "maximum"
	if Talents.lower_spent(bank.ranks,tree,Talents.ROWS[node]) < Talents.THRESHOLDS[Talents.ROWS[node]]: return "locked"
	if node >= 3 and bank.ranks[tree*5+3]+bank.ranks[tree*5+4] > 0: return "exclusive"
	return "available" if Talents.can_allocate(bank.ranks,index,int(bank.points)) else "unfunded"

func _inspect(index: int) -> void:
	if profile == null or index < 0 or index >= nodes.size(): return
	inspected = index
	var bank: Dictionary = profile.data.banks[faction];var tree: int = int(index/5);var node: int = index%5
	var definition: Array = Talents.TREES[faction][tree][node+1]
	var state_text: String = {"available":"1 point pour ce rang","maximum":"Rang maximum","locked":"Palier fermé","exclusive":"Autre spécialité choisie","unfunded":"Point à acheter","blocked":"Sauvegarde à vérifier"}[_node_state(index)]
	detail_title.text = "%s · Rang %d/%d · %s" % [definition[0],bank.ranks[index],Talents.MAX_RANKS[node],state_text]
	var reason: String = Talents.allocation_error(bank.ranks,index,int(bank.points))
	detail_text.text = definition[1]+(" Choix exclusif entre les deux spécialités." if node >= 3 else "")
	var gain: String = _rank_gain(index)
	if not gain.is_empty(): detail_text.text += "\nProchain rang · "+gain
	detail_text.text += "\n"+("Profil protégé : enregistrement à vérifier." if profile.blocked else reason if not reason.is_empty() else "Coût : 1 point · Cliquez pour investir un rang.")

func _number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".").replace(".",",")

func _rank_gain(index: int) -> String:
	var preview: Dictionary = Talents.rank_preview(faction,profile.data.banks[faction].ranks,index)
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
	if not profile.blocked and Talents.can_allocate(profile.data.banks[faction].ranks,index,int(profile.data.banks[faction].points)):
		profile.allocate(faction,index)
	refresh()

func _respec_preview() -> Dictionary:
	if profile == null or profile.blocked: return {}
	var bank: Dictionary = profile.data.banks[faction]
	var active: int = Talents.spent(bank.ranks)
	var price: int = profile.reset_price(faction)
	if active == 0 or bank.resource < price: return {}
	return {"faction":faction,"before":bank.duplicate(true),"price":price,"balance_after":int(bank.resource)-price,"active":active,"free_before":int(bank.points)-active,"free_after":int(bank.points),"next_price":Talents.RESET_PRICES[mini(int(bank.resets)+1,Talents.RESET_PRICES.size()-1)]}

func _request_reset() -> void:
	_cancel_reset()
	reset_quote = _respec_preview()
	if reset_quote.is_empty(): return
	var camp: String = "Alliance" if faction == 0 else "Horde"
	confirm.dialog_text = "%s · Réinitialiser les trois arbres\n\nCoût : %d ressources · Solde : %d → %d\nPoints à placer : %d → %d (+%d rendus)\nTous les talents seront retirés ; les points restent achetés.\nProchaine réinitialisation : %d ressources (plafond : %d).\n\nL’autre faction conserve sa progression." % [camp,reset_quote.price,reset_quote.before.resource,reset_quote.balance_after,reset_quote.free_before,reset_quote.free_after,reset_quote.active,reset_quote.next_price,Talents.RESET_PRICES[-1]]
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
