extends SceneTree
const Screen = preload("res://scripts/campaign_screen.gd")
const Maps = preload("res://scripts/map_definition.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var p = Profile.new("")
		var screen = Screen.new();root.add_child(screen);screen.open(p,faction)
		var before: String = JSON.stringify(p.data)
		for number in range(1,11):
			screen._select(number-1)
			var preview = screen.terrain_preview
			var source: Dictionary = Maps.for_id(screen.Catalogue.definition(number).map_id)
			var original: String = JSON.stringify(source)
			var layout: Dictionary = preview.geometry()
			check(layout.id == source.id and preview.definition.path_points == source.path_points and preview.definition.slots == source.slots,"L’aperçu lit le tracé et les positions exacts de la mission sélectionnée")
			check(layout.path.size() == source.path_points.size() and layout.slots.size() == 6 and layout.board.size() == 4,"Tous les segments et les six emplacements sont présents")
			var content := Rect2(Vector2(4,4),preview.size-Vector2(8,28))
			for point in layout.path+layout.slots+layout.board: check(content.has_point(point),"Le terrain et les marqueurs restent dans la zone d’aperçu, hors de la légende")
			check(preview.mouse_filter == Control.MOUSE_FILTER_IGNORE and preview.focus_mode == Control.FOCUS_NONE,"L’aperçu n’intercepte ni clic ni navigation au clavier")
			check(JSON.stringify(Maps.for_id(source.id)) == original and JSON.stringify(p.data) == before,"Consulter un terrain ne modifie ni sa géométrie ni la progression")
			check(screen.start_button.disabled == (number != 1),"Voir un terrain verrouillé ne permet pas de lancer sa mission")
			for control in [preview,screen.mission_heading,screen.mission_title,screen.mission_detail,screen.rewards,screen.start_button,screen.talents_button,screen.infinite_label]:
				check(Rect2(850,116,398,572).encloses(control.get_global_rect()),"L’aperçu et les informations de mission tiennent dans leur panneau")
			for pair in [[screen.mission_title,preview],[preview,screen.mission_detail],[screen.mission_detail,screen.rewards],[screen.rewards,screen.start_button],[screen.start_button,screen.talents_button],[screen.talents_button,screen.infinite_label]]:
				check(not pair[0].get_global_rect().intersects(pair[1].get_global_rect()),"Les zones de lecture et les actions ne se recouvrent pas")
			for label in [screen.mission_title,screen.mission_detail,screen.rewards,screen.infinite_label]:
				check(label.get_minimum_size().y <= label.size.y,"Le texte de mission tient dans sa zone sans être coupé")
		var first: int = p.begin_mission(faction,"campaign.001",60,10,100)
		check(first > 0 and p.credit_mission(first,faction,10,true),"Réussite de contrôle enregistrée avec les règles normales")
		screen.refresh();screen._select(1)
		check(screen.terrain_preview.definition.id == "ford_woods" and not screen.start_button.disabled,"La même carte devient jouable après le succès requis")
		before = JSON.stringify(p.data)
		screen._chapter(2);screen._select(0)
		check(screen.terrain_preview.definition.is_empty() and screen.terrain_preview.geometry().is_empty() and screen.start_button.disabled,"Un contenu à venir n’emprunte pas le terrain du Gué ni celui précédemment consulté")
		screen._chapter(20);screen._select(9)
		check(screen.terrain_preview.geometry().is_empty() and JSON.stringify(p.data) == before,"Les chapitres futurs restent sans terrain inventé et sans effet sur les acquis")
		screen.terrain_preview.show_map("id_inconnu")
		check(screen.terrain_preview.geometry().is_empty(),"Une carte inconnue reste vide")
		screen.free()
	print("CAMPAIGN_PREVIEW_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
