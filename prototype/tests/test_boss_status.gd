extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false)
		check(not scene.boss_panel.visible,"Aucune jauge avant le choix de faction")
		scene._choose_faction(faction)
		var m = scene.model
		m.phase = "combat"
		for type in range(7):
			m.enemies.assign([Model.make_enemy(type,type,0)])
			scene._update_interface()
			check(not scene.boss_panel.visible,"Aucun ennemi ordinaire annoncé comme boss")
		var boss: Dictionary = Model.make_enemy(17,7,0)
		boss.hp = 123.125; boss.distance = 12
		m.enemies.assign([boss]); scene.inspection_pointer = Vector2(30,60)
		var before: String = JSON.stringify([m.enemies,m.gold,m.fortress_hp,m.action_history,str(m.rng.state),m.elapsed])
		scene._update_interface()
		check(scene.boss_panel.visible and not scene.enemy_inspector.visible,"Jauge visible sans survol de l’ennemi")
		check(scene.boss_name.text == "BOSS · Seigneur de siège" and scene.boss_health.text == "PV : 124 / 600","Nom et PV vivants lus dans le modèle")
		check(scene.boss_bar.value == 123.125 and scene.boss_bar.max_value == 600 and scene.boss_bar.step == 0,"Jauge conservant la précision de la simulation")
		check(scene.boss_threat.text.contains("elle perd 20 PV") and scene.boss_threat.text.ends_with("Défaite"),"Conséquence fatale explicite contre 20 PV")
		check(JSON.stringify([m.enemies,m.gold,m.fortress_hp,m.action_history,str(m.rng.state),m.elapsed]) == before,"Affichage sans mutation, délai, attaque ou tirage")
		m.fortress_hp = 24; scene._update_interface()
		check(not scene.boss_threat.text.contains("Défaite"),"Pas de fausse défaite annoncée contre 24 PV")
		boss.hp = 0.001; scene._update_interface()
		check(scene.boss_health.text == "PV : 1 / 600" and scene.boss_bar.value == 0.001,"Pas d’affichage zéro pour un boss vivant")
		boss.hp = 0; scene._update_interface()
		check(not scene.boss_panel.visible,"Mort : jauge retirée immédiatement")
		boss.hp = 600; m.enemies.assign([boss]); scene._update_interface()
		scene._show_bonuses()
		check(not scene.boss_panel.visible,"Jauge masquée pendant le récapitulatif")
		scene._close_bonuses()
		check(scene.boss_panel.visible,"Jauge restaurée à la fermeture du récapitulatif")
		m.enemies.clear(); scene._update_interface()
		check(not scene.boss_panel.visible,"Arrivée ou disparition : aucune jauge périmée")
		for phase in ["finished","bonus","victory","defeat"]:
			m.phase = phase; m.enemies.assign([boss]); scene._update_interface()
			check(not scene.boss_panel.visible,"Hors combat : jauge masquée même en état de contrôle injecté")
		m.phase = "finished"; scene._reset()
		check(not scene.boss_panel.visible and m.enemies.is_empty(),"Nouvel essai efface le boss affiché")
		check(scene.boss_panel.get_rect().end.x < scene.forecast_panel.position.x and scene.boss_panel.get_rect().end.y <= 154,"Jauge séparée de la fiche ennemie et des ennemis à l’entrée")
		check(scene.boss_bar.mouse_filter == Control.MOUSE_FILTER_IGNORE and scene.boss_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE,"Lecture sans capturer les commandes de la carte")
		scene.free()
	print("BOSS_STATUS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
