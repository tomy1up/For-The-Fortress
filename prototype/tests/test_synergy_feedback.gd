extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
# Les nettoyages de nouvelle partie sont testés après une défaite simulée ; les verrous de parcours sont couverts séparément.
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func fixture(faction: int) -> RefCounted:
	var m = Model.new()
	m.select_faction(faction)
	m.gold = 10000 # Budget de contrôle uniquement pour inspecter toutes les associations.
	return m
func specialise(m: RefCounted, slot: int, branch: int) -> void:
	m.upgrade(slot); m.upgrade(slot); m.upgrade(slot, branch)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	for rule in Model.Campaign.PROXIMITY:
		var m = fixture(0 if rule.types[0] < 3 else 1)
		m.buy(0,rule.types[0]); m.buy(1,rule.types[1]); m.buy(2,rule.types[1])
		check(m.synergy_partners(0,rule) == [1,2],"Deux partenaires affichables, dans l'ordre des emplacements")
		check(m.synergy_effects(0).codes.count(rule.code) == 1,"Plusieurs liens ne doublent pas un même bonus")
		for i in range(4):
			check(is_equal_approx(m.synergy_effects(0)[["direct","secondary","curse","range"][i]],rule.effects[0][i]),"Valeur unique malgré deux partenaires")
		m.sell(1)
		check(m.synergy_partners(0,rule) == [2],"Une vente supprime uniquement le lien concerné")
		m.sell(2)
		check(m.synergy_partners(0,rule).is_empty() and m.synergy_effects(0).codes.is_empty(),"Dernière vente retire le lien et le gain")
		m = fixture(0 if rule.types[0] < 3 else 1)
		m.buy(2,rule.types[0]); m.buy(4,rule.types[1]); m.bonuses.assign([2])
		check(m.synergy_partners(2,rule).is_empty(),"E3/E5 : pas de lien à 5,025, même avec bonus de portée")
		m.sell(4); m.buy(3,rule.types[1])
		check(m.synergy_partners(2,rule) == [3],"E3/E4 : lien de proximité admissible")
		m.synergies_enabled = false
		check(m.synergy_partners(2,rule).is_empty(),"Pas de liens si les synergies sont désactivées")
	for rule in Model.Campaign.SPECIALISATIONS:
		var m = fixture(0 if rule.types[0] < 3 else 1)
		m.buy(0,rule.types[0]); m.buy(5,rule.types[1])
		check(m.synergy_partners(0,rule).is_empty(),"Deux recrues ne créent pas de lien de spécialisation")
		specialise(m,5,rule.branches[1])
		m.upgrade(0); m.upgrade(0)
		check(m.synergy_partners(0,rule).is_empty(),"Aucun lien réel pendant le simple choix de spécialisation")
		check(m.synergy_partners(0,rule,rule.branches[0]) == [5],"Aperçu de branche conserve les gains prévus")
		check(m.defenders[0].level == 3,"Aperçu sans modification de la recrue")
		m.upgrade(0,rule.branches[0])
		check(m.synergy_partners(0,rule) == [5] and rule.code in m.get_stats(0).synergies,"Lien actif à longue distance après confirmation")
		check(m.synergy_partners(5,rule) == [0],"Lien réciproque des spécialisations")
		m.sell(5); m.buy(5,rule.types[1]); specialise(m,5,1-rule.branches[1])
		check(m.synergy_partners(0,rule).is_empty(),"Mauvaise spécialisation : aucun lien trompeur")
	for faction in range(2):
		var scene = Main.new()
		root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.selected = 0; scene._buy(0)
		check(scene.hint_label.text.contains("Aucune synergie active"),"Aide disponible avant toute association")
		check(scene.hint_label.tooltip_text.contains("Inactive") and scene.hint_label.tooltip_text.contains("E2, E3"),"Partenaires et emplacements compatibles expliqués")
		scene.selected = 1; scene._buy(1); scene.selected = 0; scene._update_interface()
		check(scene.hint_label.text.contains("Synergies actives : 1") and not scene.hint_label.text.contains("P-"),"Nombre lisible à la place du code")
		check(scene.hint_label.tooltip_text.contains("Active avec") and scene.hint_label.tooltip_text.contains("(E2)"),"Nom et emplacement du partenaire actif")
		check(scene.hint_label.tooltip_text.contains("+8 % aux dégâts directs" if faction == 0 else "+8 % aux dégâts des rebonds"),"Gain propre au défenseur sélectionné")
		if faction == 1:
			check(not scene.hint_label.tooltip_text.contains("Mage") and not scene.hint_label.tooltip_text.contains("Archer"),"Aucune association de l'autre faction")
		scene.model.sell(1); scene._update_interface()
		check(scene.hint_label.text.contains("Aucune synergie active") and not scene.hint_label.tooltip_text.contains("Active avec"),"Interface actualisée après vente du partenaire")
		scene.model.phase = "defeat"; scene._reset()
		check(scene.hint_label.tooltip_text.is_empty(),"Aucune ancienne association après réinitialisation")
		scene.free()
	print("SYNERGY_FEEDBACK_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
