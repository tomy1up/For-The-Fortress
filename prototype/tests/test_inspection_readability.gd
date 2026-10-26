extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders])
func fits(label: Label) -> bool:
	var font: Font = label.get_theme_font("font")
	var size: int = label.get_theme_font_size("font_size")
	for line in label.text.split("\n"):
		if font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x > label.size.x: return false
	return label.text.split("\n").size() <= 2
func run_checks() -> void:
	for faction in range(2):
		for offer in range(3):
			var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
			scene.model.gold = 10000;scene.model.bonuses.assign([0,1,2,3,9,10])
			scene._select_slot(0)
			var type: int = faction*3+offer
			var state: String = signature(scene)
			scene.buy_buttons[offer].mouse_entered.emit()
			check(not scene.inspection_numbers_visible and scene.details_label.text.contains(scene._recruit_role(type)),"Rôle lisible avant les chiffres détaillés")
			check(scene.buy_buttons[offer].tooltip_text.is_empty(),"La fiche d’achat simplifiée reste visible sans bulle redondante")
			check(fits(scene.details_label),"Résumé d’achat contenu sur deux lignes")
			var preview: Dictionary = scene.map_view.purchase_preview.duplicate(true)
			scene.inspection_numbers_button.pressed.emit()
			check(scene.inspection_numbers_visible and scene.details_label.text.contains("Portée :") and scene.buy_buttons[offer].tooltip_text.contains("La cible principale"),"Le même aperçu conserve ses valeurs et règles complètes à la demande")
			check(scene.map_view.purchase_preview == preview and signature(scene) == state,"Changer la lecture ne change ni portée prévue ni modèle")
			scene.inspection_numbers_button.pressed.emit()
			check(not scene.inspection_numbers_visible and fits(scene.details_label),"Retour au résumé sans achat")
			scene.buy_buttons[offer].pressed.emit()
			check(scene.model.defenders[0].type == type and scene.details_label.text.contains(scene._recruit_role(type)),"Le vrai recrutement garde le rôle du bon défenseur")
			for level in range(1,4):
				check(fits(scene.details_label),"Résumé du défenseur contenu à chaque niveau")
				if level == 3: break
				scene.upgrade_button.mouse_entered.emit()
				state = signature(scene)
				check(scene.details_label.text.contains("→") and scene.details_label.text.contains("Prix :") and fits(scene.details_label),"Gain et coût visibles avant amélioration")
				check(scene.upgrade_button.tooltip_text.is_empty(),"Aucune bulle redondante ne recouvre les gains de la vue simplifiée")
				var future: Dictionary = scene.map_view.upgrade_preview.duplicate(true)
				scene.inspection_numbers_button.pressed.emit()
				check(scene.details_label.text.contains("Intervalle :") and scene.details_label.text.contains("Portée :"),"Comparaison exacte dépliée")
				check(scene.map_view.upgrade_preview == future and signature(scene) == state,"Lecture du gain sans paiement ni changement d’état")
				scene.inspection_numbers_button.pressed.emit();scene.upgrade_button.pressed.emit();scene.upgrade_button.mouse_exited.emit()
				check(scene.model.get_stats(0) == future,"Paiement réel conforme à l’aperçu dans les deux vues")
			scene._show_bonuses()
			scene.inspection_numbers_button.pressed.emit()
			check(not scene.inspection_numbers_visible and scene.inspection_numbers_button.disabled and scene.inspection_numbers_button.focus_mode == Control.FOCUS_NONE,"La commande reste verrouillée derrière une fenêtre")
			scene._close_bonuses();scene.inspection_numbers_button.pressed.emit()
			check(scene.inspection_numbers_visible,"La commande redevient utilisable après fermeture")
			scene._reset()
			check(not scene.inspection_numbers_visible and not scene.inspection_numbers_button.visible,"Nouvelle partie sans ancien mode de lecture")
			scene.queue_free();await process_frame
	print("INSPECTION_READABILITY_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
