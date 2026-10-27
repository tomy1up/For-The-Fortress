extends ColorRect
const Talents = preload("res://scripts/meta_talents.gd")
var profile: RefCounted
var faction: int = 0
var heading: Label
var balance: Label
var notice: Label
var buy: Button
var reset_button: Button
var names: Array[Label] = []
var nodes: Array[Button] = []
var descriptions: Array[Label] = []
var confirm: ConfirmationDialog

func label_at(parent: Control, text: String, rect: Rect2, font_size: int = 16) -> Label:
	var label := Label.new();label.text = text;label.position = rect.position;label.size = rect.size
	label.add_theme_font_size_override("font_size",font_size);label.add_theme_color_override("font_color",Color("e0dbbf"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;parent.add_child(label);return label

func button_at(parent: Control, text: String, rect: Rect2, action: Callable) -> Button:
	var button := Button.new();button.text = text;button.position = rect.position;button.size = rect.size
	button.add_theme_font_size_override("font_size",15);button.pressed.connect(action)
	var style := StyleBoxFlat.new();style.bg_color = Color("1c3a30");style.border_color = Color("74866b");style.set_border_width_all(1);style.set_corner_radius_all(6)
	button.add_theme_stylebox_override("normal",style);button.add_theme_stylebox_override("hover",style);button.add_theme_stylebox_override("focus",style)
	var disabled_style: StyleBoxFlat = style.duplicate();disabled_style.bg_color = Color("132820");disabled_style.border_color = Color("334e43")
	button.add_theme_stylebox_override("disabled",disabled_style)
	button.add_theme_color_override("font_disabled_color",Color("9eada3"))
	parent.add_child(button);return button

func _ready() -> void:
	color = Color(0.02,0.04,0.035,1.0);set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	heading = label_at(self,"Talents",Rect2(50,28,900,40),28)
	balance = label_at(self,"",Rect2(50,78,800,42),17)
	buy = button_at(self,"",Rect2(880,78,350,42),_buy)
	label_at(self,"BARÈME D’ESSAI · 3 rangs de base ouvrent un choix de spécialité par arbre.",Rect2(50,132,1180,32),15)
	for tree in range(3):
		var x: int = 50+400*tree
		names.append(label_at(self,"",Rect2(x,184,380,36),23))
		for node in range(3):
			var index: int = tree*3+node
			var y: int = 240+134*node
			nodes.append(button_at(self,"",Rect2(x,y,374,44),_allocate.bind(index)))
			descriptions.append(label_at(self,"",Rect2(x+8,y+52,358,66),15))
	reset_button = button_at(self,"",Rect2(50,670,374,44),_request_reset)
	button_at(self,"Retour · Échap",Rect2(880,670,350,44),close)
	notice = label_at(self,"",Rect2(50,730,1180,56),14)
	confirm = ConfirmationDialog.new();confirm.title = "Réinitialiser les talents"
	confirm.ok_button_text = "Payer et réinitialiser";confirm.cancel_button_text = "Annuler"
	confirm.confirmed.connect(_reset);add_child(confirm)
	hide()

func open(for_profile: RefCounted, for_faction: int) -> void:
	if for_profile == null or for_faction not in [0,1]: return
	profile = for_profile;faction = for_faction;refresh();show();buy.grab_focus()

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
	buy.disabled = profile.blocked or bank.resource < Talents.POINT_PRICE or bank.points >= 12
	for tree in range(3):
		var definition: Array = Talents.TREES[faction][tree];names[tree].text = definition[0]
		for node in range(3):
			var index: int = tree*3+node
			nodes[index].text = "%s · %d/%d" % [definition[node+1][0],bank.ranks[index],3 if node == 0 else 1]
			nodes[index].disabled = profile.blocked or not Talents.can_allocate(bank.ranks,index,int(bank.points))
			nodes[index].add_theme_color_override("font_disabled_color",Color("e3c58c") if bank.ranks[index] > 0 else Color("9eada3"))
			descriptions[index].text = definition[node+1][1]+("\nCoût : 1 point par rang." if node == 0 else "\nChoix exclusif · Coût : 1 point.")
	reset_button.text = "Réinitialiser · %d ressources" % profile.reset_price(faction)
	reset_button.disabled = profile.blocked or Talents.spent(bank.ranks) == 0 or bank.resource < profile.reset_price(faction)
	reset_button.tooltip_text = "Prochaine respécialisation : n°%d.\nCoût croissant : 2, 4, 6, 8, puis 10 ressources maximum.\nCompteur propre à %s. Tous les points de cette faction seront rendus." % [int(bank.resets)+1,camp]
	notice.text = profile.error if not profile.error.is_empty() else "Sauvegarde locale · Ressources et points propres à cette faction. Talents appliqués à la prochaine partie."

func _buy() -> void:
	profile.buy_point(faction);refresh()

func _allocate(index: int) -> void:
	profile.allocate(faction,index);refresh()

func _request_reset() -> void:
	confirm.dialog_text = "Payer %d ressources %s pour récupérer %d points ?\nLes trois arbres de cette faction seront réinitialisés.\nL’autre faction reste inchangée." % [profile.reset_price(faction),"Alliance" if faction == 0 else "Horde",Talents.spent(profile.data.banks[faction].ranks)]
	confirm.popup_centered(Vector2i(610,190))

func _reset() -> void:
	profile.respec(faction);refresh()
