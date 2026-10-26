extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
const Survey = preload("res://tests/survey_upgrades.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func signature(m: RefCounted) -> String:
	var values: Array = []
	for field in Survey.COPY_FIELDS: values.append(m.get(field))
	values.append(str(m.rng.state)); values.append(str(m.rng.seed))
	return JSON.stringify(values)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	# Chaque paire d’emplacements, chaque sens des six associations de proximité.
	for rule in Model.Campaign.PROXIMITY:
		for side in range(2):
			for slot in range(6):
				for partner in range(6):
					if partner == slot: continue
					var m = Model.new(); m.select_faction(0 if rule.types[side] < 3 else 1); m.gold = 10000
					m.buy(partner,rule.types[1-side])
					var view = View.new(); view.model = m; view.selected = slot
					var before: String = signature(m)
					var candidate: Dictionary = {"type":rule.types[side],"level":1,"branch":-1}
					var preview: Array = view.synergy_links(candidate)
					check(preview.size() == (1 if Model.SLOTS[slot].distance_squared_to(Model.SLOTS[partner]) <= 25.0 else 0),"Portée des associations indépendante de la portée de tir")
					check(signature(m) == before,"Lecture sans mutation, achat, paiement ou tirage")
					m.buy(slot,rule.types[side])
					check(view.synergy_links() == preview,"Liens prévus identiques aux liens après l’achat réel")
					view.free()
	# Les branches ne créent un lien que si la bonne spécialisation existe chez le partenaire.
	for rule in Model.Campaign.SPECIALISATIONS:
		for side in range(2):
			var m = Model.new(); m.select_faction(0 if rule.types[side] < 3 else 1); m.gold = 10000
			m.buy(0,rule.types[side]); m.buy(5,rule.types[1-side])
			m.upgrade(0); m.upgrade(0); m.upgrade(5); m.upgrade(5); m.upgrade(5,rule.branches[1-side])
			var view = View.new(); view.model = m; view.selected = 0
			var before: String = signature(m)
			var candidate: Dictionary = m.defenders[0].duplicate(true); candidate.level = 4; candidate.branch = rule.branches[side]
			var preview: Array = view.synergy_links(candidate)
			check(preview.size() == 1 and preview[0].partner == 5 and preview[0].specialised,"Lien de spécialisation prévu à longue distance")
			candidate.branch = 1-rule.branches[side]
			check(view.synergy_links(candidate).is_empty(),"Autre branche sans faux lien")
			check(signature(m) == before and view.synergy_links().is_empty(),"Comparer une branche laisse la synergie réelle inactive")
			m.upgrade(0,rule.branches[side])
			check(view.synergy_links() == preview,"Spécialisation confirmée conforme à la prévision")
			view.free()
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		# E2 est à portée de proximité de E1. Budget de contrôle pour deux partenaires identiques.
		scene.model.gold = 10000; scene.model.buy(1,faction*3+1); scene.model.buy(2,faction*3+1)
		scene.selected = 0; scene.map_view.selected = 0; scene._update_interface()
		var before: String = signature(scene.model)
		scene.buy_buttons[0].mouse_entered.emit()
		check(scene.map_view.preview_synergy_unit.type == faction*3 and scene.map_view.synergy_links(scene.map_view.preview_synergy_unit).size() == 2,"Deux partenaires visibles pour la recrue survolée")
		check(scene.hint_label.text.contains("Synergies prévues : 1"),"Un bonus unique malgré deux partenaires")
		scene.inspection_numbers_button.pressed.emit() # Détails de partenaires consultés dans la vue complète.
		check(scene.buy_buttons[0].tooltip_text.contains("E2") and scene.buy_buttons[0].tooltip_text.contains("E3"),"Détail consultable sur le bouton sans quitter le survol")
		check(scene.buy_buttons[0].tooltip_text.contains("+8 % aux dégâts directs" if faction == 0 else "+8 % aux dégâts des rebonds"),"Gain de la recrue propre à sa faction")
		check(not scene.buy_buttons[0].tooltip_text.contains("chaman" if faction == 0 else "mage"),"Aucun texte étranger à la faction")
		check(signature(scene.model) == before,"Survol complet de l’interface sans effet sur la partie")
		scene.buy_buttons[0].mouse_exited.emit()
		check(scene.map_view.preview_synergy_unit.is_empty(),"Sortie du survol retire les liens prévus")
		scene.buy_buttons[0].focus_entered.emit()
		check(not scene.map_view.preview_synergy_unit.is_empty(),"Même aperçu au clavier")
		scene._show_bonuses()
		check(scene.map_view.preview_synergy_unit.is_empty(),"Aucun lien futur à travers le récapitulatif")
		scene._close_bonuses(); scene._start()
		check(scene.map_view.preview_synergy_unit.is_empty(),"Le combat retire les prévisions")
		scene.free()
		scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.model.gold = 10000; scene.model.buy(0,faction*3); scene.model.buy(5,1 if faction == 0 else 5)
		for slot in [0,5]: scene.model.upgrade(slot); scene.model.upgrade(slot)
		scene.model.upgrade(5,1 if faction == 0 else 0)
		scene.selected = 0; scene.map_view.selected = 0; scene._upgrade()
		before = signature(scene.model)
		scene.specialisation_buttons[0].mouse_entered.emit()
		check(scene.map_view.preview_synergy_unit.branch == 0 and scene.map_view.synergy_links(scene.map_view.preview_synergy_unit).size() == 1,"Dialogue : bonne branche et partenaire prévus")
		check(scene.specialisation_buttons[0].tooltip_text.contains("E6") and scene.specialisation_buttons[1].tooltip_text.contains("Aucune synergie"),"Chaque bouton décrit ses associations propres")
		scene.specialisation_buttons[1].mouse_entered.emit(); scene.specialisation_buttons[0].mouse_exited.emit()
		check(scene.map_view.preview_synergy_unit.branch == 1 and scene.map_view.synergy_links(scene.map_view.preview_synergy_unit).is_empty(),"Passage entre branches sans lien périmé")
		check(signature(scene.model) == before,"Comparer ne paie pas et ne spécialise pas")
		scene._cancel_specialisation()
		check(scene.map_view.preview_synergy_unit.is_empty(),"Annuler retire les liens virtuels")
		scene._upgrade(); scene.specialisation_buttons[0].mouse_entered.emit(); scene._choose_branch(0)
		check(scene.map_view.preview_synergy_unit.is_empty() and scene.map_view.synergy_links().size() == 1,"Confirmation remplace le lien prévu par un lien actif")
		scene.free()
	var view = View.new(); var m = Model.new(); view.model = m
	check(view.synergy_links({"type":0,"level":1,"branch":-1}).is_empty(),"Pas de sélection : pas de lien")
	view.selected = 0
	check(view.synergy_links({"type":3,"level":1,"branch":-1}).is_empty(),"Aperçu adverse refusé")
	view.free()
	print("SYNERGY_PREVIEW_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
