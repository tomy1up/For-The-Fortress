extends SceneTree
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders,scene.model.next_instance_id])
func run_checks() -> void:
	for faction in range(2):
		for offer in range(3):
			var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
			check(scene.map_view.purchase_ghost().is_empty(),"Sans survol ni focus : aucune silhouette achetée ou prévue")
			for slot in range(6):
				scene._select_slot(slot);scene.buy_buttons[offer].mouse_entered.emit()
				var before: String = signature(scene)
				var ghost: Dictionary = scene.map_view.purchase_ghost()
				check(not ghost.is_empty() and ghost.type == faction*3+offer and ghost.slot == slot and ghost.point == View.project(scene.model.SLOTS[slot]),"Bonne classe et position, dans les six emplacements des deux camps")
				check(ghost.available and scene.model.defenders[slot].is_empty(),"Silhouette disponible sans recrue présente")
				scene.map_view.queue_redraw();await process_frame
				check(before == signature(scene),"Dessiner la silhouette ne paie rien, ne crée aucune instance et ne tire aucun aléa")
				scene.buy_buttons[offer].mouse_exited.emit();check(scene.map_view.purchase_ghost().is_empty(),"Quitter le survol efface l'aperçu")
			scene.buy_buttons[offer].focus_entered.emit();check(not scene.map_view.purchase_ghost().is_empty(),"Silhouette également disponible au clavier")
			scene.model.gold = 0;scene._update_interface();check(not scene.map_view.purchase_ghost().is_empty() and not scene.map_view.purchase_ghost().available,"Sans or : comparaison visible mais indisponibilité explicite")
			scene.model.gold = 150;scene._update_interface();scene._buy(offer)
			check(scene.map_view.purchase_ghost().is_empty() and scene.model.defenders[5].type == faction*3+offer and scene.model.next_instance_id == 1,"Achat : silhouette remplacée par une seule vraie recrue")
			scene.selected = 4;scene.map_view.selected = 4;scene.map_view.purchase_preview = {"type":(1-faction)*3}
			check(scene.map_view.purchase_ghost().is_empty(),"Un type du camp opposé n'est jamais dessiné")
			scene.map_view.purchase_preview = {"type":faction*3+offer};scene.model.start()
			check(scene.map_view.purchase_ghost().is_empty(),"Même un aperçu périmé est refusé pendant le combat")
			scene.model.phase = "defeat";scene._update_interface();scene._reset()
			check(scene.map_view.purchase_ghost().is_empty(),"Nouvelle partie sans silhouette résiduelle")
			scene.free()
	print("PURCHASE_GHOST_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
