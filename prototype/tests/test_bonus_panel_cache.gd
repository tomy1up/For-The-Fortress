extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
class CountingMain extends "res://scripts/main.gd":
	var impact_calls: int = 0
	func _bonus_impact_text(code: int) -> String:
		impact_calls += 1
		return super._bonus_impact_text(code)
# Les nettoyages de nouvelle partie sont testés après une défaite simulée ; les verrous de parcours sont couverts séparément.
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func verify_texts(scene: Node) -> bool:
	for index in range(3):
		if scene.bonus_impacts[index].text != scene._bonus_impact_text(scene.model.bonus_offer[index]): return false
	return true
func run_checks() -> void:
	for faction in range(2):
		var scene = CountingMain.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.model.gold = 10000 # Fixture d’interface, aucun résultat d’équilibrage.
		for slot in range(6): scene.model.buy(slot,faction*3+slot%3)
		scene.model.wave = 3; scene.model.phase = "bonus"; scene.model.bonus_offer.assign([0,1,2])
		scene._update_interface()
		var count: int = scene.impact_calls
		check(count == 3,"Premier affichage : trois comparaisons calculées")
		var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders])
		for step in range(30): scene._update_interface()
		check(scene.impact_calls == count,"Lecture immobile : aucun nouveau calcul de comparaison")
		check(JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders]) == before,"Cache sans tirage, paiement ou mutation du modèle")
		check(verify_texts(scene),"Textes conservés identiques aux calculs frais")
		# Toutes les entrées des aperçus restent prises en compte, y compris les fixtures mutables.
		for field in ["gold","fortress_hp","max_hp","bonuses","level","branch","type","synergies_enabled","offer","wave"]:
			match field:
				"gold": scene.model.gold -= 1
				"fortress_hp": scene.model.fortress_hp -= 1
				"max_hp": scene.model.max_hp += 1
				"bonuses": scene.model.bonuses.assign([7])
				"level": scene.model.defenders[0].level = 4
				"branch": scene.model.defenders[0].branch = 1
				"type": scene.model.defenders[0].type = faction*3+1
				"synergies_enabled": scene.model.synergies_enabled = false
				"offer": scene.model.bonus_offer.assign([8,9,10])
				"wave": scene.model.wave = 6
			count = scene.impact_calls; scene._update_interface()
			check(scene.impact_calls == count+3,"Donnée changée : recalcul des offres ("+field+")")
			check(verify_texts(scene),"Aucun texte périmé après changement de "+field)
			count = scene.impact_calls; scene._update_interface()
			check(scene.impact_calls == count,"Nouvel état réutilisé sans recalcul ("+field+")")
		scene.model.phase = "defeat"; scene._update_interface(); scene._reset()
		check(scene.bonus_impact_keys == ["","",""] and scene.bonus_contexts == ["","",""],"Nouvel essai vide le cache et le contexte de défilement")
		scene.free()
	print("BONUS_PANEL_CACHE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
