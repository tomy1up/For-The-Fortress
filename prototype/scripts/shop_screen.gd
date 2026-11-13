extends ColorRect
const Shop = preload("res://scripts/shop_catalogue.gd")
const Art = preload("res://scripts/shop_art.gd")
const Model = preload("res://scripts/valley_model.gd")
signal closed
var profile: RefCounted
var faction: int = 0
var cards: Array[Dictionary] = [] # Les deux cartes de la page affichée.
var all_cards: Array[Dictionary] = []
var page: int = 0
var page_label: Label
var previous_button: Button
var next_button: Button
const PAGE_SIZE := 2
var heading: Label
var balance: Label
var choice_note: Label
var notice: Label
var status_labels: Array[Label] = []
var card_panels: Array[Panel] = []
var portraits: Array[TextureRect] = []
var buy_buttons: Array[Button] = []
var select_buttons: Array[Button] = []
var none_button: Button
var back_button: Button
var compare_buttons: Array[Button] = []
var comparison_overlay: ColorRect
var comparison_panel: Panel
var comparison_title: Label
var comparison_headers: Array[Label] = []
var comparison_rows: Array[Array] = []
var comparison_note: Label
var comparison_close: Button
var comparison_index: int = -1
func label_at(parent: Node,text: String,area: Rect2,size: int = 16) -> Label:
	var label := Label.new();label.text = text;label.position = area.position;label.size = area.size
	label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",Color("dedbc4"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;label.mouse_filter = Control.MOUSE_FILTER_IGNORE;parent.add_child(label);return label
func button_at(text: String,area: Rect2,action: Callable,parent: Node = self) -> Button:
	var button := Button.new();button.text = text;button.position = area.position;button.size = area.size;button.pressed.connect(action)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style := StyleBoxFlat.new();style.bg_color = Color("1d3b30") if state != "disabled" else Color("172d25")
		style.border_color = Color("d0bb7d") if state in ["hover","focus"] else Color("426252");style.set_border_width_all(2 if state == "focus" else 1);style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state,style)
	button.add_theme_font_size_override("font_size",16);parent.add_child(button);return button
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);color = Color("08130f")
	heading = label_at(self,"Boutique",Rect2(32,22,840,42),30)
	balance = label_at(self,"",Rect2(930,30,318,36),21)
	label_at(self,"Débloquez des possibilités de jeu avec les PO de cette faction.",Rect2(32,78,1216,30),18)
	choice_note = label_at(self,"",Rect2(32,120,1216,40),16)
	for index in range(2):
		var x: float = 32+index*624
		var panel := Panel.new();panel.position = Vector2(x,180);panel.size = Vector2(592,430)
		var style := StyleBoxFlat.new();style.bg_color = Color("122a21");style.border_color = Color("41604b");style.set_border_width_all(1);style.set_corner_radius_all(9);panel.add_theme_stylebox_override("panel",style);add_child(panel)
		card_panels.append(panel)
		label_at(panel,"",Rect2(24,20,400,38),25).name = "UnitName"
		label_at(panel,"",Rect2(24,70,400,42),19).name = "Role"
		var portrait := TextureRect.new();portrait.position = Vector2(440,12);portrait.size = Vector2(128,108)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE;panel.add_child(portrait);portraits.append(portrait)
		label_at(panel,"",Rect2(24,126,544,66),16).name = "Tradeoff"
		label_at(panel,"",Rect2(24,204,544,84),15).name = "Stats"
		compare_buttons.append(button_at("Comparer les chiffres",Rect2(x+24,474,300,34),_compare.bind(index)))
		label_at(panel,"",Rect2(24,340,544,44),14).name = "Talents"
		status_labels.append(label_at(panel,"",Rect2(24,392,544,28),16))
		buy_buttons.append(button_at("",Rect2(x,628,280,42),_buy.bind(index)))
		select_buttons.append(button_at("",Rect2(x+296,628,296,42),_select.bind(index)))
	notice = label_at(self,"",Rect2(32,686,1216,44),16)
	none_button = button_at("Sans unité supplémentaire",Rect2(32,744,350,38),_none)
	previous_button = button_at("◀ Précédentes",Rect2(400,744,150,38),_turn_page.bind(-1))
	page_label = label_at(self,"",Rect2(560,750,150,30),16);page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_button = button_at("Suivantes ▶",Rect2(720,744,150,38),_turn_page.bind(1))
	back_button = button_at("Retour au parcours · Échap",Rect2(898,744,350,38),close)
	_build_comparison()
	hide()
func _build_comparison() -> void:
	comparison_overlay=ColorRect.new();comparison_overlay.color=Color(0.02,0.04,0.035,0.96)
	comparison_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(comparison_overlay)
	comparison_panel=Panel.new();comparison_panel.position=Vector2(170,100);comparison_panel.size=Vector2(940,590)
	var style:=StyleBoxFlat.new();style.bg_color=Color("122a21");style.border_color=Color("41604b");style.set_border_width_all(1);style.set_corner_radius_all(9)
	comparison_panel.add_theme_stylebox_override("panel",style);comparison_overlay.add_child(comparison_panel)
	comparison_title=label_at(comparison_panel,"",Rect2(24,18,892,40),25)
	label_at(comparison_panel,"Niveau 1 · Sans talents, bonus ou synergies",Rect2(24,65,892,28),16)
	for column in range(3): comparison_headers.append(label_at(comparison_panel,"",Rect2(24+column*300,110,285,30),17))
	for row in range(7):
		var labels: Array=[]
		for column in range(3): labels.append(label_at(comparison_panel,"",Rect2(24+column*300,154+row*42,285,36),16))
		comparison_rows.append(labels)
	comparison_note=label_at(comparison_panel,"",Rect2(24,466,892,54),15)
	comparison_close=button_at("Retour à la boutique · Échap",Rect2(560,536,356,38),_close_comparison,comparison_panel)
	comparison_overlay.hide()
static func _number(value: float) -> String: return str(value).trim_suffix(".0").replace(".",",")
func _compare(index: int) -> void:
	if not visible or comparison_overlay.visible or index<0 or index>=cards.size(): return
	comparison_index=index
	var card: Dictionary=cards[index];var base: Dictionary=Model.ROSTER[card.family]
	var alternative: Dictionary=Model.ROSTER[card.type]
	comparison_title.text="Comparer · "+card.name
	comparison_headers[0].text="Au niveau 1";comparison_headers[1].text=base.name;comparison_headers[2].text=card.name
	var rows: Array=[
		["Recruter pendant la mission","%d or"%base.price,"%d or"%alternative.price],
		["Dégâts du tir principal",_number(base.damage),_number(alternative.damage)],
		["Temps entre deux tirs",_number(base.interval)+" s",_number(alternative.interval)+" s"],
		["Portée sur la carte",_number(base.range),_number(alternative.range)]]
	if alternative.has("secondary_damage"):
		rows.append(["Dégâts du rebond" if card.family==3 else "Dégâts sur chaque voisin",_number(base.secondary_damage),_number(alternative.secondary_damage)])
		rows.append(["Autres ennemis touchés","%d maximum"%base.secondary_cap,"%d maximum"%alternative.secondary_cap])
		rows.append(["Distance du rebond" if card.family==3 else "Rayon de l’explosion",_number(base.radius),_number(alternative.radius)])
	for row in range(comparison_rows.size()):
		for column in range(3):
			comparison_rows[row][column].visible=row<rows.size()
			comparison_rows[row][column].text=rows[row][column] if row<rows.size() else ""
	comparison_note.text="Le déblocage coûte %d PO une seule fois. Chaque recrue coûte ensuite %d or de combat.\nLes talents de cette famille s’appliquent aux deux unités."%[card.po,alternative.price]
	# A short table stays compact; Horde secondary effects use three extra rows.
	var footer: float=154+rows.size()*42+12
	comparison_note.position.y=footer;comparison_close.position.y=footer+70
	comparison_panel.size.y=footer+124;comparison_panel.position.y=(800-comparison_panel.size.y)/2
	for button in buy_buttons+select_buttons+compare_buttons+[none_button,back_button]: button.focus_mode=Control.FOCUS_NONE
	comparison_overlay.show();comparison_close.grab_focus()
func _close_comparison() -> void:
	if comparison_overlay==null or not comparison_overlay.visible: return
	comparison_overlay.hide()
	for button in buy_buttons+select_buttons+compare_buttons+[none_button,back_button]: button.focus_mode=Control.FOCUS_ALL
	if visible and comparison_index>=0: compare_buttons[comparison_index].grab_focus()
func open(for_profile: RefCounted,for_faction: int) -> void:
	if for_profile == null or for_faction not in [0,1] or for_profile.shop_locked: return
	_close_comparison()
	profile = for_profile;faction = for_faction;all_cards = Shop.for_faction(faction);page = 0;show();refresh();back_button.grab_focus()
func refresh() -> void:
	if profile == null: return
	page = clampi(page,0,maxi(0,(all_cards.size()-1)/PAGE_SIZE))
	cards = all_cards.slice(page*PAGE_SIZE,page*PAGE_SIZE+PAGE_SIZE)
	heading.text = "Boutique · "+("Alliance" if faction == 0 else "Horde")
	page_label.text = "Page %d / %d · %d unités" % [page+1,maxi(1,ceili(float(all_cards.size())/PAGE_SIZE)),all_cards.size()]
	previous_button.disabled = page <= 0
	next_button.disabled = (page+1)*PAGE_SIZE >= all_cards.size()
	for index in range(PAGE_SIZE):
		card_panels[index].visible = index < cards.size()
		buy_buttons[index].visible = index < cards.size();select_buttons[index].visible = index < cards.size();compare_buttons[index].visible = index < cards.size()
	var bank: Dictionary = profile.data.banks[faction]
	balance.text = "PO indisponibles" if profile.blocked else "%d PO" % bank.resource
	var chosen: Dictionary = Shop.card(bank.shop_selected)
	choice_note.text = "Trois types habituels + option choisie : "+("indisponible" if profile.blocked else "aucune" if chosen.is_empty() else chosen.name)+". Choix fixé pendant la mission."
	for index in range(cards.size()):
		var card: Dictionary = cards[index];var panel: Panel = card_panels[index]
		portraits[index].texture = Art.TEXTURES[card.type]
		panel.get_node("UnitName").text = card.name
		panel.get_node("Role").text = card.role
		panel.get_node("Tradeoff").text = card.tradeoff
		panel.get_node("Stats").text = "Recrutement : %d or de combat\n%s dégâts par tir · Un tir toutes les %s s" % [card.stats.price,_number(card.stats.damage),_number(card.stats.interval)]
		if card.stats.has("secondary_damage"):
			panel.get_node("Stats").text += "\n%s : %s dégâts · %d autre%s maximum" % ["Rebond" if card.family == 3 else "Explosion",str(card.stats.secondary_damage).replace(".",","),card.stats.secondary_cap," ennemi" if card.stats.secondary_cap == 1 else "s ennemis"]
		panel.get_node("Talents").text = "Talents communs : "+Shop.family_label(card.type)+"."
		var owned: bool = bank.shop_owned.has(card.id)
		var selected: bool = bank.shop_selected == card.id
		status_labels[index].text = "Progression indisponible" if profile.blocked else "Choisie pour la mission" if selected else "Débloquée définitivement" if owned else "Déblocage permanent : %d PO" % card.po
		buy_buttons[index].text = "Déjà acquise" if owned else "Débloquer · %d PO" % card.po
		buy_buttons[index].disabled = not profile.shop_error(faction,card.id).is_empty()
		buy_buttons[index].tooltip_text = profile.shop_error(faction,card.id)
		select_buttons[index].text = "Option choisie" if selected else "Choisir pour la mission"
		select_buttons[index].disabled = profile.blocked or profile.shop_locked or not owned or selected
	none_button.disabled = profile.blocked or profile.shop_locked or bank.shop_selected.is_empty()
	notice.text = profile.error if not profile.error.is_empty() else profile.shop_notice
func _turn_page(direction: int) -> void:
	if not visible or comparison_overlay.visible or profile == null: return
	page = clampi(page+direction,0,maxi(0,(all_cards.size()-1)/PAGE_SIZE));refresh()
func _buy(index: int) -> void:
	if not visible or comparison_overlay.visible or profile == null or index < 0 or index >= cards.size(): return
	profile.buy_shop_unit(faction,cards[index].id);refresh()
func _select(index: int) -> void:
	if not visible or comparison_overlay.visible or profile == null or index < 0 or index >= cards.size(): return
	profile.select_shop_unit(faction,cards[index].id);refresh()
func _none() -> void:
	if visible and not comparison_overlay.visible and profile != null: profile.select_shop_unit(faction,"");refresh()
func close() -> void:
	var was_visible: bool = visible;_close_comparison();hide()
	if was_visible: closed.emit()
func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if comparison_overlay.visible: _close_comparison()
		else: close()
		get_viewport().set_input_as_handled()
