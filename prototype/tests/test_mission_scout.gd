extends SceneTree
const Main=preload("res://scripts/main.gd")
const Profile=preload("res://scripts/meta_profile.gd")
const Scout=preload("res://scripts/mission_scout.gd")
const Model=preload("res://scripts/valley_model.gd")
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func escape() -> void:
	var event:=InputEventKey.new();event.keycode=KEY_ESCAPE;event.pressed=true;Input.parse_input_event(event)
	await process_frame
	event=InputEventKey.new();event.keycode=KEY_ESCAPE;Input.parse_input_event(event)
func run_checks() -> void:
	for camp in range(2):
		var profile=Profile.new("");var scene=Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile=profile
		scene._open_campaign(camp)
		var menu=scene.campaign_menu;var scout=menu.scout
		await process_frame
		var before: String=JSON.stringify(profile.data)
		for number in range(1,21):
			menu._chapter((number-1)/10+1);menu._select((number-1)%10);menu.scout_button.pressed.emit()
			check(scout.visible and menu.overlay_blocked and scout.mission_number==number and scout.faction==camp,"La préparation affiche la mission et faction sélectionnées, même verrouillée")
			var expected: Array[Dictionary]=[];var seen: Array[int]=[]
			var definition: Dictionary=menu.Catalogue.definition(number)
			for wave in range(1,11):
				for group in Model.Campaign.waves_for(definition.get("wave_set_id","ford"))[wave-1]:
					if group[0] in seen:
						var existing: Dictionary = expected[seen.find(group[0])]
						existing.total += group[1]
						existing.last = wave
						existing.wave_counts[wave] = existing.wave_counts.get(wave, 0)+group[1]
						continue
					seen.append(group[0]);expected.append({"type":group[0],"first":wave,"last":wave,"total":group[1],"wave_counts":{wave:group[1]}})
			check(scout.entries.size()==expected.size() and scout.cards.filter(func(card):return card.visible).size()==expected.size(),"Seulement les ennemis réellement présents sont montrés, une fois chacun")
			for index in range(expected.size()):
				var entry: Dictionary=scout.entries[index];var source: Dictionary=Model.enemy_definition(expected[index].type)
				check(entry.type==expected[index].type and entry.first_wave==expected[index].first,"L’ordre et la première vague suivent la vraie séquence")
				check(entry.total==expected[index].total and entry.last_wave==expected[index].last and entry.wave_counts==expected[index].wave_counts,"Les effectifs et la derniere vague suivent les groupes de combat")
				check(is_equal_approx(entry.max_hp,source.hp*(99+number)/100.0) and entry.fortress_damage==source.fortress_damage,"PV de mission et danger de passage exacts")
				check(entry.origin in ["neutral","horde" if camp==0 else "alliance"],"Les attaquants humains sont du camp adverse et la faune reste neutre")
				var card: Panel=scout.cards[index]
				var wave_lines := PackedStringArray()
				for wave in expected[index].wave_counts:
					wave_lines.append("Vague %d · %d" % [wave, expected[index].wave_counts[wave]])
				check(card.tooltip_text=="\n".join(wave_lines),"Le survol liste les effectifs exacts des vagues concernees")
				check(card.get_node("Name").text==entry.name and card.get_node("Portrait").texture.atlas==scout.Art.TEXTURES[entry.identity_id],"Nom et portrait partagent la même identité")
				for label in [card.get_node("Name"),card.get_node("Details"),card.get_node("Origin")]:
					check(label.get_minimum_size().y<=label.size.y,"Les textes des rencontres tiennent dans leurs fiches")
			for wave in range(1, definition.waves+1):
				scout.wave_filter.select(wave)
				scout.wave_filter.item_selected.emit(wave)
				var visible_cards: Array = scout.cards.filter(func(card):return card.visible)
				var groups: Array = expected.filter(func(entry):return entry.wave_counts.has(wave))
				check(visible_cards.size()==groups.size(),"Le filtre affiche les seuls types presents dans la vague")
				for index in range(groups.size()):
					check(visible_cards[index].get_node("Details").text.begins_with("%d " % groups[index].wave_counts[wave]),"La fiche affiche le nombre de cette vague")
			scout.wave_filter.select(0)
			scout.wave_filter.item_selected.emit(0)
			scout.wave_filter.grab_focus()
			scene._sync_keyboard_focus()
			check(root.gui_get_focus_owner()==scout.wave_filter,"Le filtre conserve le focus pendant le rafraichissement")
			scout.close_button.grab_focus()

			check(scout.note.text.contains("25 %")== (number>10),"La protection n’est expliquée que dans les missions où elle apparaît")
			check(Rect2(0,0,1280,800).encloses(scout.panel.get_global_rect()),"La fenêtre reste entièrement lisible")
			for button in menu.chapter_buttons+menu.nodes+[menu.start_button,menu.talents_button,menu.shop_button,menu.scout_button,menu.back_button]:
				check(button.focus_mode==Control.FOCUS_NONE,"Le parcours derrière ne capte pas la navigation")
			menu.start_button.pressed.emit();menu._shop();menu._talents();menu._chapter(20);menu._select(9)
			scene._update_interface();scene._sync_keyboard_focus()
			check(menu.chapter==(number-1)/10+1 and menu.selected==(number-1)%10 and not scene.shop_menu.visible and not scene.meta_menu.visible and scene.choosing_faction,"Aucune action sous la fenêtre ne lance de mission ni ne change de sélection")
			check(root.gui_get_focus_owner()==scout.close_button,"Les rafraîchissements conservent le focus dans la fenêtre")
			check(JSON.stringify(profile.data)==before,"Lire les rencontres ne modifie aucune progression")
			await escape()
			check(menu.visible and not scout.visible and not menu.overlay_blocked and root.gui_get_focus_owner()==menu.scout_button,"Échap revient au bouton d’origine sans quitter le parcours")
		menu._chapter(15);menu._select(0);check(menu.scout_button.disabled,"Les missions futures n’inventent pas de rencontres")
		menu._scout();check(not scout.visible,"Le contenu futur ne s’ouvre pas")
		menu._chapter(1);menu._scout();menu.close();check(not scout.visible and scout.entries.is_empty(),"Quitter le parcours efface la consultation")
		menu.open(profile,1-camp);check(not scout.visible and not menu.overlay_blocked,"Aucune ancienne faction ne reste affichée après changement")
		menu._scout();check(not scout.open(201,camp) and not scout.visible and scout.entries.is_empty(),"Une mission inconnue efface les données précédentes")
		for invalid in [-1,2]: check(Scout.encounter_data(1,invalid).is_empty(),"Une faction invalide ne reçoit pas de catalogue")
		scene.free()
	print("MISSION_SCOUT_TESTS checks=%d failures=%d"%[checks,failures]);quit(0 if failures==0 else 1)
