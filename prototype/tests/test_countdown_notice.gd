extends SceneTree
const Main = preload("res://scripts/main.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		for speed in [1.0,2.0,10.0]:
			var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction);scene.speed = speed
			check(not scene.wave_notice.visible,"Premier départ manuel sans faux avertissement automatique")
			scene.model.buy(0,faction*3);scene.model.buy(1,faction*3+1);scene._start();scene._process(1000)
			check(scene.countdown_remaining == 30 and not scene.wave_notice.visible,"Début de préparation : trente secondes, pas d'alerte précoce")
			scene._process(24);check(scene.countdown_remaining == 6 and not scene.wave_notice.visible,"Six secondes : aucun avertissement central")
			scene._process(1)
			check(scene.wave_notice.visible and scene.wave_notice_title.text == "VAGUE 2 DANS 5 S" and scene.countdown_remaining == 5,"Avertissement au seuil exact aux trois vitesses")
			var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.countdown_remaining])
			scene._update_wave_notice();scene._update_interface()
			check(before == JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.countdown_remaining]),"Lire l'avertissement ne change ni temps restant, modèle ni RNG")
			scene._process(1.2);check(scene.wave_notice_title.text == "VAGUE 2 DANS 4 S","Arrondi supérieur cohérent avec le temps restant")
			var remaining: float = scene.countdown_remaining
			scene._show_bonuses();scene._process(20)
			check(not scene.wave_notice.visible and scene.countdown_remaining == remaining,"Lecture des bonus : avertissement caché et délai suspendu")
			scene._close_bonuses();check(scene.wave_notice.visible and scene.countdown_remaining == remaining,"Reprise du même délai, sans nouvelle préparation")
			scene._process(remaining)
			check(scene.model.wave == 2 and scene.model.active and scene.model.elapsed == 0 and scene.wave_notice_title.text == "VAGUE 2 / 10","À zéro : lancement immédiat et remplacement par l'annonce de départ")
			check(scene.wave_notice.mouse_filter == Control.MOUSE_FILTER_IGNORE and scene.wave_notice.focus_mode == Control.FOCUS_NONE,"Avertissement sans clic ni focus")
			scene.free()
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		scene.model.wave = 9;scene.model.spawn_schedule = scene.model.Campaign.schedule(9);scene.model.phase = "finished";scene.autoplay_started = true;scene.countdown_wave = 9;scene.countdown_remaining = 4.8;scene._update_interface()
		check(scene.wave_notice_title.text == "FINALE DANS 5 S" and scene.wave_notice_detail.text.contains("Chef de guerre orc" if faction == 0 else "Maréchal de l’Alliance"),"Avertissement final propre au camp adverse")
		scene.model.phase = "bonus";scene.model.bonus_offer.assign([0,1,2]);scene._update_interface()
		check(not scene.wave_notice.visible and scene.countdown_remaining < 0,"Choix obligatoire sans départ annoncé ou délai actif")
		scene.model.phase = "defeat";scene._close_bonuses();scene._update_interface();check(not scene.wave_notice.visible,"Défaite sans avertissement résiduel")
		scene.free()
	print("COUNTDOWN_NOTICE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
