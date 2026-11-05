extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const MapView = preload("res://scripts/valley_view.gd")
# Les nettoyages de nouvelle partie sont testés après une défaite simulée ; les verrous de parcours sont couverts séparément.
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func snapshot(m: RefCounted) -> Array:
	return [m.gold,m.defenders.duplicate(true),m.next_instance_id,m.rng.state,m.bonuses.duplicate(),m.phase,m.elapsed,m.wave]
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	# Budget de contrôle : comparer l'aperçu à un vrai achat dans toutes les positions.
	for faction in range(2):
		for type in range(faction*3,faction*3+3):
			for slot in range(6):
				for boosted in [false,true]:
					var m = Model.new(); m.select_faction(faction); m.gold = 10000
					var partner_slot: int = (slot+1)%6
					for other_type in m.available_types():
						if other_type == type: continue
						m.buy(partner_slot,other_type); partner_slot = (partner_slot+1)%6
					if boosted: m.bonuses.assign([0,1,2,3,4,6,9,10])
					m._refresh_windows()
					var before: Array = snapshot(m)
					var preview: Dictionary = m.purchase_preview_stats(slot,type)
					check(not preview.is_empty(),"Aperçu disponible pour chaque défenseur et emplacement libre")
					check(preview == m.purchase_preview_stats(slot,type) and snapshot(m) == before,"Aperçus répétés sans paiement, instance, mutation ou tirage")
					check(m.buy(slot,type),"Achat réel après aperçu")
					check(m.get_stats(slot) == preview,"Statistiques réelles identiques à l'aperçu, bonus et partenaires compris")
					check(m.defenders[slot].windows == Model.coverage_windows(Model.SLOTS[slot],preview.range),"Route prévue identique aux fenêtres réelles de tir")
	var m = Model.new(); m.gold = 10000; m.buy(1,2); m.bonuses.assign([2])
	check(m.purchase_preview_stats(0,1).range == 5.75,"Arbalétrier : 5 de base + 0,25 de proximité + 0,5 de bonus")
	check(m.defenders[0].is_empty() and m.get_stats(1).synergies.is_empty(),"L'unité virtuelle n'active pas de bonus réel chez son voisin")
	m.synergies_enabled = false
	check(m.purchase_preview_stats(0,1).range == 5.5,"Aperçu respecte la désactivation des synergies de test")
	check(m.purchase_preview_stats(-1,0).is_empty() and m.purchase_preview_stats(6,0).is_empty(),"Emplacement invalide sans effet")
	check(m.purchase_preview_stats(1,0).is_empty(),"Pas d'aperçu d'achat sur une place occupée")
	check(m.purchase_preview_stats(0,3).is_empty() and m.purchase_preview_stats(0,-1).is_empty(),"Autre faction ou défenseur invalide refusé")
	# Géométrie de la portion couverte : plusieurs fenêtres et virages conservés.
	for slot in [0,3,5]:
		var center: Vector2 = Model.SLOTS[slot]
		var sections: Array[PackedVector2Array] = MapView.covered_route(center,4.5)
		var windows: Array[Dictionary] = Model.coverage_windows(center,4.5)
		check(sections.size() == windows.size(),"Les fenêtres séparées ne sont pas reliées artificiellement")
		for index in range(windows.size()):
			check(sections[index][0].is_equal_approx(MapView.project(Model.position_at(windows[index].first))) and sections[index][-1].is_equal_approx(MapView.project(Model.position_at(windows[index].last))),"Extrémités du tracé aux vraies limites de tir")
			var distance: float = 0.0
			for corner in range(1,Model.PATH_POINTS.size()):
				distance += Model.PATH_POINTS[corner-1].distance_to(Model.PATH_POINTS[corner])
				if distance > windows[index].first+Model.EPS and distance < windows[index].last-Model.EPS:
					check(MapView.project(Model.PATH_POINTS[corner]) in sections[index],"Le tracé suit le virage au lieu de couper à travers la carte")
		var ring: PackedVector2Array = MapView.range_outline(center,4.5)
		check(ring.size() == 65 and ring[0].is_equal_approx(ring[-1]) and ring[0].is_equal_approx(MapView.project(center+Vector2(4.5,0))),"Cercle fermé projeté avec la même échelle que la carte")
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.selected = 3; scene.map_view.selected = 3; scene._update_interface()
		var before: Array = snapshot(scene.model)
		check(scene.hint_label.text.contains("Survolez") and scene.map_view.purchase_preview.is_empty(),"Emplacement vide explique comment comparer les portées")
		scene.buy_buttons[0].mouse_entered.emit()
		check(scene.map_view.purchase_preview.range == [4.0,3.5][faction] and scene.title_label.text.contains("APERÇU AVANT ACHAT"),"Survol : portée du bon défenseur de la faction")
		check(snapshot(scene.model) == before,"Survol sans achat ni modification de la partie")
		scene.buy_buttons[1].mouse_entered.emit(); scene.buy_buttons[0].mouse_exited.emit()
		check(scene.map_view.purchase_preview.range == [5.0,3.0][faction],"Passage entre boutons : l'ancien survol ne supprime pas le nouveau")
		scene.buy_buttons[1].mouse_exited.emit()
		check(scene.map_view.purchase_preview.is_empty(),"Sortie du bouton retire l'aperçu")
		scene.buy_buttons[2].focus_entered.emit()
		check(scene.map_view.purchase_preview.range == [3.5,4.5][faction],"Comparaison accessible aussi avec le focus clavier")
		scene.buy_buttons[0].mouse_entered.emit(); scene.buy_buttons[0].mouse_exited.emit()
		check(scene.map_view.purchase_preview.range == [3.5,4.5][faction],"Après survol : retour au choix clavier")
		scene.buy_buttons[2].focus_exited.emit()
		check(scene.map_view.purchase_preview.is_empty(),"Perte de focus sans survol retire l'aperçu")
		scene.model.gold = 0; scene._update_interface(); scene.buy_buttons[1].mouse_entered.emit()
		check(not scene.map_view.purchase_preview.is_empty() and scene.buy_buttons[1].disabled and scene.hint_label.text.contains("Or insuffisant"),"Prévisualisation possible sans or, achat toujours interdit")
		scene.model.gold = 150; scene._update_interface(); scene.buy_buttons[1].mouse_exited.emit(); scene.buy_buttons[0].mouse_entered.emit()
		scene.buy_buttons[0].pressed.emit()
		check(scene.map_view.purchase_preview.is_empty() and scene.model.defenders[3].type == faction*3 and scene.model.gold == 100 and scene.model.next_instance_id == 1,"Un seul achat au clic ; retour à l'inspection réelle")
		scene.selected = 2; scene.map_view.selected = 2; scene._update_interface(); scene.buy_buttons[1].mouse_entered.emit()
		scene._show_bonuses()
		check(scene.map_view.purchase_preview.is_empty(),"Aucun aperçu à travers la fenêtre des bonus")
		scene._close_bonuses(); scene.buy_buttons[1].mouse_entered.emit(); scene._start()
		check(scene.model.active and scene.map_view.purchase_preview.is_empty(),"Départ de vague retire l'aperçu")
		scene.buy_buttons[1].mouse_entered.emit()
		check(scene.map_view.purchase_preview.is_empty(),"Pas d'aperçu de recrutement en combat")
		scene.free()
	# L'aide de recrutement suit les vraies valeurs et n'affecte pas la disponibilité.
	for faction in range(2):
		for boosted in [false,true]:
			var help_scene = Main.new(); root.add_child(help_scene); help_scene.set_process(false); help_scene._choose_faction(faction)
			help_scene.inspection_numbers_visible = true # Contrôle des règles exactes dans la vue chiffrée.
			help_scene.selected = 3; help_scene.map_view.selected = 3
			if boosted: help_scene.model.bonuses.assign([0,1,2,3,4,10])
			help_scene._update_interface()
			for offer in range(3):
				var type: int = faction*3+offer
				var before_help: Array = snapshot(help_scene.model)
				var expected: Dictionary = help_scene.model.purchase_preview_stats(3,type)
				help_scene.buy_buttons[offer].mouse_entered.emit()
				var tooltip: String = help_scene.buy_buttons[offer].tooltip_text
				check(not help_scene.buy_buttons[offer].disabled and tooltip.contains("Cliquez pour acheter"),"L'aide informative ne désactive pas un achat disponible")
				check(help_scene.details_label.text.contains("Dégâts : "+help_scene._number(expected.damage)) and help_scene.details_label.text.contains("les "+help_scene._number(expected.interval)+" s"),"Dégâts et cadence affichés suivent les bonus effectifs")
				check(tooltip.contains("Portée : "+help_scene._number(expected.range)) and help_scene.details_label.text.contains("Prix : %d or" % help_scene.model.purchase_cost(type)),"Portée et prix réduits suivent l'aperçu effectif")
				check(tooltip.contains(Model.ROSTER[type].name) and (faction == 0 or not tooltip.to_lower().contains("mage")),"L'aide nomme le bon défenseur de la bonne faction")
				var text_font: Font = help_scene.details_label.get_theme_font("font")
				var fits: bool = true
				for line in help_scene.details_label.text.split("\n"):
					fits = fits and text_font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x <= help_scene.details_label.size.x
				check(fits,"Les deux lignes de comparaison tiennent dans le panneau")
				check(text_font.get_string_size(help_scene.hint_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x <= help_scene.hint_label.size.x,"Rôle et indication de portée tiennent dans leur ligne")
				if type in [2,3,4]: check(tooltip.contains("jusqu’à") and tooltip.contains(help_scene._number(expected.radius)),"Plafond de victimes et limite de rayon explicités")
				if type == 5: check(tooltip.contains("renouvelle") and tooltip.contains("séparés"),"Renouvellement et sources de malédiction explicités")
				check(snapshot(help_scene.model) == before_help,"Survol et génération de l'aide ne dépensent et ne tirent rien")
				help_scene.buy_buttons[offer].mouse_exited.emit()
			help_scene.model.gold = 0; help_scene._update_interface()
			check(help_scene.buy_buttons[0].disabled and help_scene.buy_buttons[0].tooltip_text.contains("Or insuffisant") and not help_scene.buy_buttons[0].tooltip_text.contains("Cliquez pour acheter"),"Aide d'un achat impossible sans invitation contradictoire")
			help_scene.free()
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	# Un achat remplace les commandes sous le pointeur : ne pas présenter immédiatement la nouvelle action.
	for faction in range(2):
		var bought = Main.new(); root.add_child(bought); bought.set_process(false); bought._choose_faction(faction)
		bought.selected = 0; bought.map_view.selected = 0; bought._buy(1)
		check(bought.model.gold == 75 and bought.model.defenders[0].type == faction*3+1,"Achat réel au prix normal dans chaque faction")
		var rect: Rect2 = bought.buy_buttons[1].get_global_rect()
		bought.purchase_quiet_rect = rect
		bought._refresh_purchase_quiet(rect.get_center())
		bought.hovered_upgrade = true; bought.focused_upgrade = false; bought._refresh_upgrade_preview()
		check(bought.map_view.upgrade_preview.is_empty() and bought.sell_button._get_tooltip(Vector2.ZERO).is_empty() and bought.upgrade_button._get_tooltip(Vector2.ZERO).is_empty(),"Pointeur immobile : ni aperçu d'amélioration ni aide de vente parasite")
		bought._refresh_purchase_quiet(rect.end+Vector2.ONE); bought._refresh_upgrade_preview()
		check(not bought.map_view.upgrade_preview.is_empty() and not bought.sell_button._get_tooltip(Vector2.ZERO).is_empty(),"Sortie puis nouveau survol : les aides et aperçus redeviennent accessibles")
		bought.purchase_quiet_rect = rect; bought._upgrade_focus(true)
		check(bought.purchase_quiet_rect == Rect2() and not bought.map_view.upgrade_preview.is_empty(),"Navigation clavier : l'amélioration reste consultable")
		bought.purchase_quiet_rect = rect; bought.model.phase = "defeat"; bought._reset()
		check(bought.purchase_quiet_rect == Rect2() and not bought.sell_button.tooltip_quiet,"Nouvel essai : aucun état de survol bloqué conservé")
		bought.free()
	scene.selected = 3; scene.map_view.selected = 3; scene.model.phase = "finished"; scene.autoplay_started = true
	scene.buy_buttons[0].mouse_entered.emit(); scene._process(1)
	check(scene.countdown_remaining == 29 and not scene.map_view.purchase_preview.is_empty(),"Comparer les portées ne suspend pas les 30 secondes")
	scene.model.phase = "defeat"; scene._reset()
	check(scene.map_view.purchase_preview.is_empty() and scene.hovered_purchase == -1 and scene.focused_purchase == -1,"Nouvel essai efface tout aperçu")
	scene.free()
	var workshop := Main.new()
	workshop.model = Model.new(true,Model.Maps.mountain_workshop())
	root.add_child(workshop)
	workshop.set_process(false)
	workshop._choose_faction(0)
	workshop.selected = 0
	workshop.hovered_purchase = 0
	workshop._refresh_purchase_preview()
	var coverage := workshop.map_view.entry_coverage_percentages(workshop.model.slots[0],workshop.map_view.purchase_preview.range)
	check(coverage[0] > coverage[1] and coverage[1] >= 0,"E1 couvre davantage la première approche du Col")
	check(workshop.hint_label.text == "Trajet à portée · Entrée 1 : %d %% · Entrée 2 : %d %%" % [coverage[0],coverage[1]],"L’aperçu distingue les deux trajets")
	workshop.free()
	print("PURCHASE_PREVIEW_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
