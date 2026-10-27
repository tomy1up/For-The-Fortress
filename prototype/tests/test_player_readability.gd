extends SceneTree
const Main = preload("res://scripts/main.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var formatting = Main.new()
	root.add_child(formatting); formatting.set_process(false)
	formatting._choose_faction(0)
	var tooltip: Label = formatting.start_button._make_custom_tooltip("Ancienne vague")
	root.add_child(tooltip)
	formatting.start_button.tooltip_text = "Nouvelle vague\nPrix actualisé"
	tooltip._process(0.1)
	check(tooltip.text == "Nouvelle vague\nPrix actualisé","Une infobulle déjà ouverte suit le texte actuel du bouton")
	formatting.start_button.tooltip_text = ""
	tooltip._process(0.1)
	check(tooltip.text.is_empty(),"Une aide supprimée ne conserve pas un texte ancien")
	formatting._show_bonuses(); tooltip._process(0.1)
	check(not tooltip.visible,"Une fenêtre modale masque les anciennes infobulles de l'interface derrière elle")
	tooltip.free()
	for item in [[1.0,"1"],[1.5,"1,5"],[0.892857142857,"0,89"],[2.232142857,"2,23"],[75.4,"75,4"],[19.175,"19,18"],[0.004,"0"],[100.0,"100"]]:
		check(formatting._number(item[0]) == item[1],"Nombres lisibles, deux décimales au maximum, sans zéros inutiles")
	formatting.free()
	for faction in range(2):
		for offer in range(3):
			for reduced in [false,true]:
				var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
				scene.inspection_numbers_visible = true # Comptabilité complète, accessible par le nouveau bouton.
				scene.model.gold = 10000 # Budget de contrôle des quatre niveaux.
				if reduced: scene.model.bonuses.assign([9,10])
				scene.selected = 0; scene.map_view.selected = 0; scene._buy(offer)
				for level in range(1,4):
					var price: int = scene.model.upgrade_cost(0)
					var gold_before: int = scene.model.gold
					var invested: int = scene.model.defenders[0].paid
					var refund: int = scene.model.refund(0)
					scene._update_interface()
					check(not scene.upgrade_button.disabled and scene.upgrade_button.tooltip_text.contains("Prix : %d or" % price),"L'aide informative ne bloque pas une amélioration disponible")
					check(scene.upgrade_button.tooltip_text.contains("après amélioration : %d." % (gold_before-price)) and scene.upgrade_button.tooltip_text.contains("%d or." % (invested+price)),"Solde futur et investissement prévus avec le prix réellement payé")
					check(scene.sell_button.tooltip_text.contains("Perte à la vente : %d or" % (invested-refund)) and scene.sell_button.tooltip_text.contains("après vente : %d." % (gold_before+refund)),"Remboursement historique et perte à la vente, réductions incluses")
					scene.upgrade_button.pressed.emit()
					if level == 3:
						check(scene.model.gold == gold_before and scene.upgrade_button.tooltip_text.contains("Aucun paiement avant confirmation"),"Ouvrir les spécialisations n'applique ni dépense ni niveau")
						scene._choose_branch(offer%2)
					check(scene.model.gold == gold_before-price and scene.model.defenders[0].paid == invested+price,"Les montants annoncés correspondent au vrai paiement")
				check(scene.upgrade_button.disabled and scene.upgrade_button.tooltip_text.contains("maximum"),"Niveau maximum correctement verrouillé")
				var gold_before: int = scene.model.gold
				var refund: int = scene.model.refund(0)
				scene.sell_button.pressed.emit()
				check(scene.model.gold == gold_before+refund and scene.model.defenders[0].is_empty(),"Vente réelle conforme au montant annoncé")
				scene.model.phase = "defeat"; scene._reset(); scene._choose_faction(faction); scene.selected = 0; scene._buy(offer)
				scene.model.gold = 0; scene._update_interface()
				check(scene.upgrade_button.disabled and scene.upgrade_button.tooltip_text.contains("Or insuffisant") and not scene.upgrade_button.tooltip_text.contains("Or disponible après amélioration"),"Pas de solde négatif annoncé sur un achat impossible")
				scene.free()
	print("PLAYER_READABILITY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
