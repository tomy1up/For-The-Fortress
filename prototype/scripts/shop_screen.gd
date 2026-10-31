extends ColorRect
const Shop = preload("res://scripts/shop_catalogue.gd")
const Art = preload("res://scripts/shop_art.gd")
signal closed
var profile: RefCounted
var faction: int = 0
var cards: Array[Dictionary] = []
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
func label_at(parent: Node,text: String,area: Rect2,size: int = 16) -> Label:
	var label := Label.new();label.text = text;label.position = area.position;label.size = area.size
	label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",Color("dedbc4"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;label.mouse_filter = Control.MOUSE_FILTER_IGNORE;parent.add_child(label);return label
func button_at(text: String,area: Rect2,action: Callable) -> Button:
	var button := Button.new();button.text = text;button.position = area.position;button.size = area.size;button.pressed.connect(action)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style := StyleBoxFlat.new();style.bg_color = Color("1d3b30") if state != "disabled" else Color("172d25")
		style.border_color = Color("d0bb7d") if state in ["hover","focus"] else Color("426252");style.set_border_width_all(2 if state == "focus" else 1);style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state,style)
	button.add_theme_font_size_override("font_size",16);add_child(button);return button
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
		label_at(panel,"",Rect2(24,300,544,44),14).name = "Talents"
		status_labels.append(label_at(panel,"",Rect2(24,370,544,28),16))
		buy_buttons.append(button_at("",Rect2(x,628,280,42),_buy.bind(index)))
		select_buttons.append(button_at("",Rect2(x+296,628,296,42),_select.bind(index)))
	notice = label_at(self,"",Rect2(32,686,1216,44),16)
	none_button = button_at("Sans unité supplémentaire",Rect2(32,744,350,38),_none)
	back_button = button_at("Retour au parcours · Échap",Rect2(898,744,350,38),close)
	hide()
func open(for_profile: RefCounted,for_faction: int) -> void:
	if for_profile == null or for_faction not in [0,1] or for_profile.shop_locked: return
	profile = for_profile;faction = for_faction;cards = Shop.for_faction(faction);show();refresh();back_button.grab_focus()
func refresh() -> void:
	if profile == null: return
	heading.text = "Boutique · "+("Alliance" if faction == 0 else "Horde")
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
		panel.get_node("Stats").text = "Recrutement : %d or de combat\nDégâts : %s · Intervalle : %s s · Portée : %s" % [card.stats.price,str(card.stats.damage).replace(".",","),str(card.stats.interval).replace(".",","),str(card.stats.range).replace(".",",")]
		if card.stats.has("secondary_damage"):
			panel.get_node("Stats").text += "\n%s : %s dégâts · %d autre%s maximum" % ["Rebond" if card.family == 3 else "Explosion",str(card.stats.secondary_damage).replace(".",","),card.stats.secondary_cap," ennemi" if card.stats.secondary_cap == 1 else "s ennemis"]
		panel.get_node("Talents").text = "Talents partagés : "+Shop.family_label(card.type)+". Valeurs de prototype."
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
func _buy(index: int) -> void:
	if not visible or profile == null or index < 0 or index >= cards.size(): return
	profile.buy_shop_unit(faction,cards[index].id);refresh()
func _select(index: int) -> void:
	if not visible or profile == null or index < 0 or index >= cards.size(): return
	profile.select_shop_unit(faction,cards[index].id);refresh()
func _none() -> void:
	if visible and profile != null: profile.select_shop_unit(faction,"");refresh()
func close() -> void:
	var was_visible: bool = visible;hide()
	if was_visible: closed.emit()
func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close();get_viewport().set_input_as_handled()
