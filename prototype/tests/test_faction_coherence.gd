extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const Survey = preload("res://tests/survey_upgrades.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func coherent(text: String, faction: int) -> bool:
	var forbidden := RegEx.new()
	forbidden.compile("(?i)\\b(chaman\\w*|troll\\w*|sapeur\\w*|gobelin\\w*|orc\\w*|rebond\\w*|malédiction\\w*)\\b" if faction == 0 else "(?i)\\b(archer\\w*|arbalétr\\w*|mage\\w*|elfe\\w*|nain\\w*|humain\\w*)\\b")
	return forbidden.search(text) == null
func signature(m: RefCounted) -> String:
	var fields: Array = []
	for key in Survey.COPY_FIELDS: fields.append(m.get(key))
	fields.append(m.rng.state)
	return JSON.stringify(fields)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		for code in range(12):
			check(coherent(Model.Campaign.bonus_description(code,faction),faction),"Description de chaque bonus limitée aux unités et effets de la faction")
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.model.gold = 10000
		for type in scene.model.available_types():
			var slot: int = type%3
			scene.model.buy(slot,type); scene.model.upgrade(slot); scene.model.upgrade(slot)
			scene.selected = slot; scene._upgrade()
			check(scene.pending_slot == slot,"Choix de spécialisation de la recrue du bon camp")
			for branch in range(2):
				check(scene.specialisation_names[branch].text.ends_with(Model.Progression.BRANCHES[type*2+branch].name),"Deux branches correspondant exactement au défenseur sélectionné")
				check(coherent(scene.specialisation_names[branch].text+scene.specialisation_descriptions[branch].text,faction),"Spécialisations sans nom du camp adverse")
			scene._cancel_specialisation()
			check(coherent(scene._synergy_tooltip(slot),faction),"Partenaires de synergie limités au camp joué")
			check(coherent(scene._recruit_tooltip(type,""),faction),"Aide de recrutement du bon camp")
		for code in range(12):
			scene.model.bonuses.clear(); scene.model.phase = "bonus"; scene.model.bonus_offer.assign([code]); scene._update_interface()
			check(scene.bonus_descriptions[0].text == Model.Campaign.bonus_description(code,faction) and coherent(scene.bonus_descriptions[0].text,faction),"Offre affichée avec la description centrale de faction")
			check(coherent(scene.bonus_impacts[0].text,faction),"Projection chiffrée sans unité ou effet de l'autre camp")
			scene.model.bonuses.assign([code]); scene.model.phase = "finished"; scene._show_bonuses()
			check(scene.bonus_descriptions[0].text == Model.Campaign.bonus_description(code,faction),"Même cloisonnement dans le récapitulatif acquis")
			scene._close_bonuses()
		scene.free()
		var m = Model.new(); m.select_faction(faction); m.gold = 10000
		for type in range(6):
			if type in m.available_types(): continue
			var before: String = signature(m)
			check(not m.buy(0,type) and m.purchase_preview_stats(0,type).is_empty() and signature(m) == before,"Achat et aperçu du camp adverse refusés sans dépense")
			# État volontairement incohérent : même une unité injectée ne peut être améliorée.
			var other = Model.new(); other.select_faction(1-faction); other.gold = 10000; other.buy(0,type)
			for level in range(1,4):
				m.defenders[0] = other.defenders[0].duplicate(true)
				before = signature(m)
				for branch in [-1,0,1]:
					check(not m.upgrade(0,branch) and m.upgrade_preview_stats(0,branch).is_empty() and signature(m) == before,"Amélioration et spécialisation adverses refusées, y compris avec état injecté")
				other.upgrade(0)
			m.defenders[0] = {}
		for seed_value in range(64):
			m.rng.seed = seed_value; m._offer_bonus()
			check(m.bonus_offer.size() == 3 and m.bonus_offer[0] != m.bonus_offer[1] and m.bonus_offer[1] != m.bonus_offer[2] and m.bonus_offer[0] != m.bonus_offer[2],"Trois offres communes distinctes conservées")
			for code in m.bonus_offer:
				check(coherent(Model.Campaign.bonus_description(code,faction),faction),"Cohérence de chaque offre aléatoire sur les graines de contrôle")
		# Exercice de tir est commun aux camps ; son exclusion concerne seulement le chaman Horde.
		m.reset(); m.select_faction(faction); m.gold = 10000
		for type in m.available_types(): m.buy(type%3,type)
		var intervals: Array[float] = []
		for slot in range(3): intervals.append(m.get_stats(slot).interval)
		m.phase = "bonus"; m.bonus_offer.assign([1]); m.choose_bonus(1)
		for slot in range(3):
			check(is_equal_approx(m.get_stats(slot).interval,intervals[slot] if m.defenders[slot].type == 5 else intervals[slot]/1.12),"Effet réel de R-02 sur les trois recrues du camp, chaman exclu uniquement en Horde")
	for rule in Model.Campaign.PROXIMITY+Model.Campaign.SPECIALISATIONS:
		check(int(rule.types[0]/3) == int(rule.types[1]/3),"Aucune définition de synergie entre factions")
	check(Model.Campaign.bonus_description(-1,0).is_empty() and Model.Campaign.bonus_description(0,2).is_empty(),"Aucune description arbitraire pour code ou faction invalide")
	print("FACTION_COHERENCE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
