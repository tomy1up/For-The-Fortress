extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func scene_for(faction: int) -> Node:
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction);return scene
func run_checks() -> void:
	for faction in range(2):
		for speed in [1.0,2.0,10.0]:
			var scene = scene_for(faction);scene.speed = speed
			check(not scene.wave_notice.visible,"Pas d'annonce avant le départ manuel")
			scene._start()
			check(scene.wave_notice.visible and scene.wave_notice_title.text == "VAGUE 1 / 10" and scene.wave_notice_remaining == 2.0,"Départ réussi : annonce de la bonne vague")
			check(scene.wave_notice.mouse_filter == Control.MOUSE_FILTER_IGNORE and scene.wave_notice.focus_mode == Control.FOCUS_NONE and not scene._selection_blocked(),"Annonce sans clic, focus ni verrou de commandes")
			scene._process(0.2)
			check(is_equal_approx(scene.wave_notice_remaining,1.8) and is_equal_approx(scene.model.elapsed,0.2*speed),"Durée réelle identique aux trois vitesses ; combat non retardé")
			check(scene.wave_notice.modulate.a == 1.0,"Annonce lisible après son apparition")
			var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state)])
			scene._update_wave_notice();scene._update_interface()
			check(before == JSON.stringify([Report.build(scene.model),str(scene.model.rng.state)]),"Relire l'annonce ne change ni combat, RNG ni rapport")
			scene._start();check(is_equal_approx(scene.wave_notice_remaining,1.8),"Un départ refusé ne relance pas l'animation")
			scene._process(1.5);check(scene.wave_notice.visible and scene.wave_notice.modulate.a > 0 and scene.wave_notice.modulate.a < 1,"Extinction progressive en fin de durée")
			scene._process(0.4);check(not scene.wave_notice.visible,"Annonce retirée sans attendre la fin de vague")
			scene.model.phase = "defeat";scene._update_interface();scene._reset()
			check(scene.wave_notice_remaining == 0 and not scene.wave_notice.visible,"Retour accueil sans annonce précédente")
			scene.free()
		var scene = scene_for(faction)
		scene.model.buy(0,faction*3);scene.model.buy(1,faction*3+1);scene._start();scene._process(1000)
		check(scene.model.phase == "finished" and scene.countdown_remaining == 30,"Préparation conserve ses trente secondes")
		scene._process(30)
		check(scene.model.wave == 2 and scene.model.elapsed == 0 and scene.wave_notice_title.text == "VAGUE 2 / 10" and scene.wave_notice_remaining == 2,"Départ automatique : annonce neuve et combat immédiat")
		scene._process(0.2);scene.overview_open = true;scene._update_interface()
		check(not scene.wave_notice.visible,"Lecture des bonus sans annonce superposée")
		scene.overview_open = false;scene._update_interface();check(scene.wave_notice.visible,"Retour au combat : annonce restante consultable")
		scene.free()
		scene = scene_for(faction);scene.model.wave = 10;scene.model.spawn_schedule = scene.model.Campaign.schedule(10);scene._start();scene._process(0.2)
		check(scene.wave_notice_title.text == "VAGUE FINALE" and scene.wave_notice_detail.text.contains("Chef de guerre orc" if faction == 0 else "Maréchal de l’Alliance"),"Annonce finale nomme le boss adverse")
		check(scene.boss_panel.visible and not scene.wave_notice.get_global_rect().intersects(scene.boss_panel.get_global_rect()),"Annonce finale et jauge du boss simultanées sans recouvrement")
		check(not scene.wave_notice.get_global_rect().intersects(scene.loadout_label.get_global_rect()),"Annonce séparée des talents actifs")
		check(scene.wave_notice_detail.get_theme_font("font").get_string_size(scene.wave_notice_detail.text,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x <= scene.wave_notice_detail.size.x,"Nom du boss et effectif lisibles sur une ligne")
		scene.model.phase = "defeat";scene._update_interface();check(not scene.wave_notice.visible,"Défaite retire immédiatement l'annonce")
		scene.free()
	print("WAVE_NOTICE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
