extends ColorRect
## Read-only mission briefing. Identities and HP come from the combat model.
const Model=preload("res://scripts/valley_model.gd")
const Catalogue=preload("res://scripts/campaign_catalogue.gd")
const Art=preload("res://scripts/enemy_art.gd")
signal closed
var panel: Panel
var heading: Label
var subtitle: Label
var note: Label
var close_button: Button
var wave_filter: OptionButton
var cards: Array[Panel]=[]
var entries: Array[Dictionary]=[]
var mission_number: int=0
var faction: int=-1

static func encounter_data(number: int,camp: int) -> Array[Dictionary]:
	var definition: Dictionary=Catalogue.definition(number)
	var result: Array[Dictionary]=[]
	if camp not in [0,1] or definition.is_empty() or not definition.available: return result
	var found: Dictionary={}
	for wave in range(1,definition.waves+1):
		for spawn in Model.Campaign.schedule(wave,definition.get("wave_set_id","ford")):
			if found.has(spawn.type):
				var existing: Dictionary = found[spawn.type]
				existing.total += 1
				existing.last_wave = wave
				existing.wave_counts[wave] = existing.wave_counts.get(wave, 0)+1
				continue
			var enemy: Dictionary=Model.make_enemy(0,spawn.type,0,camp,definition.hp_percent)
			enemy.first_wave = wave
			enemy.last_wave = wave
			enemy.total = 1
			enemy.wave_counts = {wave: 1}
			found[spawn.type] = enemy
			result.append(enemy)
	return result

func label_at(parent: Control,text: String,area: Rect2,size: int=16) -> Label:
	var label:=Label.new();label.text=text;label.position=area.position;label.size=area.size
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",Color("dedbc4"));parent.add_child(label);return label
func box(parent: Control,area: Rect2) -> Panel:
	var control:=Panel.new();control.position=area.position;control.size=area.size
	var style:=StyleBoxFlat.new();style.bg_color=Color("122a21");style.border_color=Color("41604b");style.set_border_width_all(1);style.set_corner_radius_all(8)
	control.add_theme_stylebox_override("panel",style);parent.add_child(control);return control
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);color=Color(0.02,0.04,0.035,0.96)
	panel=box(self,Rect2(50,40,1180,720))
	heading=label_at(panel,"",Rect2(24,18,1132,36),26)
	subtitle=label_at(panel,"",Rect2(24,60,865,28),16)
	wave_filter = OptionButton.new()
	wave_filter.position = Vector2(922, 51)
	wave_filter.size = Vector2(234, 38)
	wave_filter.item_selected.connect(_show_wave)
	panel.add_child(wave_filter)
	for index in range(9):
		var card:=box(panel,Rect2(24+(index%3)*384,106+(index/3)*152,364,140));cards.append(card)
		var portrait:=TextureRect.new();portrait.name="Portrait";portrait.position=Vector2(10,12);portrait.size=Vector2(90,90)
		portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE;card.add_child(portrait)
		label_at(card,"",Rect2(10,110,90,22),12).name="Origin"
		label_at(card,"",Rect2(110,10,242,40),16).name="Name"
		label_at(card,"",Rect2(110,58,242,72),14).name="Details"
	note=label_at(panel,"",Rect2(24,574,1132,68),16)
	close_button=Button.new();close_button.text="Retour au parcours · Échap";close_button.position=Vector2(800,658);close_button.size=Vector2(356,38)
	for state in ["normal","hover","pressed","focus"]:
		var style:=StyleBoxFlat.new();style.bg_color=Color("1d3b30");style.border_color=Color("d0bb7d") if state in ["hover","focus"] else Color("426252")
		style.set_border_width_all(2 if state=="focus" else 1);style.set_corner_radius_all(6);close_button.add_theme_stylebox_override(state,style)
	close_button.add_theme_font_size_override("font_size",16);close_button.pressed.connect(close);panel.add_child(close_button)
	hide()
func open(number: int,camp: int) -> bool:
	var data: Array[Dictionary]=encounter_data(number,camp)
	if data.is_empty():
		close();return false
	mission_number=number;faction=camp;entries=data
	var definition: Dictionary=Catalogue.definition(number)
	heading.text="Rencontres · Mission %d · %s"%[number,"Alliance" if camp==0 else "Horde"]
	wave_filter.clear()
	wave_filter.add_item("Toute la mission")
	for wave in range(1, definition.waves+1):
		wave_filter.add_item("Vague %d" % wave)
	wave_filter.select(0)
	_show_wave(0)
	note.text="Les unités neutres sont communes aux deux factions. Les autres attaquants viennent du camp adverse."
	if definition.get("wave_set_id","")==Model.Banks.ID:
		note.text="La tortue encaisse %d %% des dégâts de ses voisins proches, dans la limite de ses PV.\nElle ne protège ni les autres tortues ni les boss."%int(Model.Banks.SHARE*100)
	if definition.get("wave_set_id","")==Model.Drowned.ID:
		note.text="Le Noyé régénère %d %% de ses PV maximum par seconde dans les tronçons inondés du chemin."%roundi(Model.Drowned.REGEN_PER_SECOND*100.0)
	show();close_button.grab_focus();return true

func _show_wave(wave: int) -> void:
	var definition: Dictionary = Catalogue.definition(mission_number)
	var visible_entries: Array[Dictionary] = []
	var total := 0
	for enemy in entries:
		var count: int = enemy.total if wave == 0 else enemy.wave_counts.get(wave, 0)
		if count > 0:
			total += count
			visible_entries.append(enemy)
	var scope := "%d vagues" % definition.waves if wave == 0 else "Vague %d sur %d" % [wave, definition.waves]
	subtitle.text="%s · %s · %d ennemis prévus · PV : %d %%"%[definition.title,scope,total,definition.hp_percent]
	for index in range(cards.size()):
		var card: Panel=cards[index];card.visible=index<visible_entries.size()
		if not card.visible: continue
		var enemy: Dictionary=visible_entries[index]
		var atlas:=AtlasTexture.new();atlas.atlas=Art.TEXTURES[enemy.identity_id];atlas.region=Art.FRAMES[enemy.identity_id].source
		card.get_node("Portrait").texture=atlas
		card.get_node("Name").text=enemy.name
		card.get_node("Origin").text=Model.Enemies.origin_label(enemy.origin)
		var wave_details := PackedStringArray()
		for appearance in enemy.wave_counts:
			wave_details.append("Vague %d · %d" % [appearance, enemy.wave_counts[appearance]])
		card.tooltip_text = "\n".join(wave_details)
		var waves := "Vague %d" % enemy.first_wave
		if enemy.last_wave != enemy.first_wave:
			waves = "1re vague %d · Dernière %d" % [enemy.first_wave, enemy.last_wave]
		var count: int = enemy.total if wave == 0 else enemy.wave_counts[wave]
		if wave > 0:
			waves = "Vague %d" % wave
		card.get_node("Details").text="%d prévu%s · %s PV chacun\nForteresse : −%d PV par passage\n%s"%[
			count, "s" if count > 1 else "", str(snappedf(enemy.max_hp,0.01)).trim_suffix(".0").replace(".",","), enemy.fortress_damage, waves]
func close() -> void:
	var was_visible: bool=visible;hide();entries.clear();mission_number=0;faction=-1
	if was_visible: closed.emit()
func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		close();get_viewport().set_input_as_handled()
