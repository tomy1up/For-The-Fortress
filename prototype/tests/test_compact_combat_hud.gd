extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.next_instance_id,scene.countdown_remaining,scene.speed])
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false)
		scene.combat_numbers_button.pressed.emit()
		check(not scene.combat_numbers_visible and scene.combat_numbers_button.disabled and scene.combat_numbers_button.focus_mode == Control.FOCUS_NONE,"Accueil : commande de fond inactive même via un signal forcé")
		scene._choose_faction(faction)
		check(not scene.combat_numbers_visible and not scene.time_label.visible and scene.tally_label.text == "Ennemis restants : 10\nOnt atteint la forteresse : 0","Lecture simplifiée par défaut, compteur des ennemis non apparus compris")
		check(scene.fortress_bar.value == 20 and scene.fortress_bar.max_value == 20 and not scene.fortress_bar.show_percentage,"Jauge de PV conforme à la forteresse sans chiffre redondant")
		for phase in ["preparation","combat","finished","victory","defeat"]:
			scene.model.phase = phase;scene._update_interface()
			var before: String = signature(scene)
			scene.combat_numbers_button.pressed.emit()
			check(scene.combat_numbers_visible and scene.time_label.visible and scene.tally_label.text.contains("Apparus : 0 / 10") and scene.tally_label.text.contains("Éliminés : 0 · Passés : 0") and scene.tally_label.text.contains("En chemin : 0"),"Détails exacts disponibles dans chaque phase non modale")
			check(signature(scene) == before,"Afficher les chiffres ne modifie ni la partie, la vitesse, le décompte ou l'aléatoire")
			var font: Font = scene.tally_label.get_theme_font("font")
			check(font.get_height(14)*3 <= scene.tally_label.size.y,"Trois lignes de chiffres sans débordement vertical")
			for line in scene.tally_label.text.split("\n"):
				check(font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x <= scene.tally_label.size.x,"Chiffres détaillés sans débordement horizontal")
			scene.combat_numbers_button.pressed.emit()
			check(not scene.combat_numbers_visible and not scene.time_label.visible and scene.tally_label.text.split("\n").size() == 2,"Réduction à deux lignes et retrait du temps technique")
			check(scene.tally_label.text.begins_with("Éliminés :") if phase in ["finished","victory","defeat"] else scene.tally_label.text.begins_with("Ennemis restants :"),"Après une fin de vague ou une défaite : bilan de la vague, sans annoncer un combat à poursuivre")
			for line in scene.tally_label.text.split("\n"):
				check(font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x <= scene.tally_label.size.x,"Résumé sans débordement horizontal")
		for maximum in [20,25]:
			for hp in [maximum,int(maximum/2),int(maximum/4),0]:
				scene.model.max_hp = maximum;scene.model.fortress_hp = hp;scene._update_interface()
				check(scene.fortress_bar.max_value == maximum and scene.fortress_bar.value == hp,"La jauge suit les PV courants, y compris un maximum augmenté")
				var expected: Color = Color("c58272") if hp <= maximum*0.25 else Color("d0b874") if hp <= maximum*0.5 else Color("a1ba75")
				check(scene.fortress_fill.bg_color == expected,"Couleur relative aux mêmes seuils que l'aspect de la forteresse")
		check(scene.tally_label.get_global_rect().end.y <= scene.combat_numbers_button.get_global_rect().position.y and scene.combat_numbers_button.get_global_rect().end.y <= scene.time_label.get_global_rect().position.y,"Compteurs, bouton et temps ne se chevauchent pas")
		scene.model.reset();scene._choose_faction(faction);scene._start();scene.model.advance(29);scene._update_interface()
		check(scene.tally_label.text.contains("Ennemis restants : 9") and scene.tally_label.text.contains("Ont atteint la forteresse : 1"),"Arrivée réelle : compteur restant et menace ayant atteint la forteresse exacts")
		scene.model.advance(1000);scene._update_interface()
		check(scene.countdown_remaining == 30,"Préparation automatique normale après la vague")
		scene._toggle_combat_numbers();scene._process(1)
		check(scene.countdown_remaining == 29 and not scene._countdown_paused(),"Lire les chiffres n'ajoute aucune pause au décompte")
		scene.overview_open = true;scene._update_interface();var before: String = signature(scene)
		scene.combat_numbers_button.pressed.emit()
		check(scene.combat_numbers_visible and scene.combat_numbers_button.disabled and scene.combat_numbers_button.focus_mode == Control.FOCUS_NONE and before == signature(scene),"Lecture des bonus : commande de fond bloquée")
		scene.overview_open = false;scene.model.phase = "bonus";scene._update_interface();scene.combat_numbers_button.pressed.emit()
		check(scene.combat_numbers_visible and scene.combat_numbers_button.disabled,"Choix obligatoire : aucun changement de la vue de fond")
		scene.model.phase = "defeat";scene._update_interface();scene._reset()
		check(not scene.combat_numbers_visible and not scene.time_label.visible and scene.fortress_bar.value == 20,"Nouvelle partie : résumé et jauge restaurés")
		scene.free()
	print("COMPACT_COMBAT_HUD_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
