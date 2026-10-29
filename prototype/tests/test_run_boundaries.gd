extends SceneTree
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var path: String = "user://test_boundary_%d_%d.json" % [Time.get_ticks_usec(),faction]
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = Profile.new(path)
		scene.mission_definition = {} # Ancien parcours multi-cartes couvert uniquement pour sa compatibilité.
		scene._choose_faction(faction)
		var disk_before: String = FileAccess.get_file_as_string(path)
		scene.model.start();scene.model.advance(10000);scene._process(0)
		check(scene.model.phase == "finished" and scene.meta_profile.data.banks[faction].resource == 0,"Fin de vague : aucune acquisition de ressource")
		check(scene._meta_reward_summary().pending == 1 and scene.meta_progress_label.text.contains("PO en attente"),"Gain annoncé comme provisoire pendant le parcours")
		check(disk_before == FileAccess.get_file_as_string(path),"Pas de sauvegarde d'un versement entre les vagues")
		var phase_before: String = scene.model.phase
		scene._reset();scene._open_meta(faction)
		check(not scene.choosing_faction and not scene.meta_menu.visible and scene.model.phase == phase_before,"Ni accueil ni arbres entre deux vagues, même par appel forcé")
		check(not scene.reset_button.visible and scene.reset_button.disabled,"Relance retirée pendant une partie en cours")
		# Première carte complète, explicitement non finale ; pas de nouvelle carte créée par ce test.
		scene.model.reset();scene.model.select_faction(faction);scene.run_final_map = false
		scene._prepare_campaign_capture("victory");scene._sync_meta_rewards(true);scene._show_run_summary()
		check(not scene._run_finished() and scene.meta_profile.data.banks[faction].resource == 0,"Victoire d'une carte intermédiaire : pas une fin de partie")
		check(scene.summary_meta_status.text.contains("Provisoires") and not scene.summary_talents_button.visible and scene.summary_title.text.contains("Carte terminée"),"Bilan de carte sans versement ni accès aux arbres")
		scene._summary_to_talents();check(scene.summary_open and not scene.meta_menu.visible,"Raccourci forcé vers les talents interdit entre deux cartes")
		scene._close_run_summary();scene._reset()
		check(not scene.choosing_faction and scene._meta_reward_summary().expected == 55,"Pas de retour à l'accueil ; cinquante-cinq ressources restent provisoires")
		# Simulation de passage de carte : conserver le même identifiant de partie et le cumul provisoire.
		var run_id: int = scene.meta_run_id
		scene.run_map_index = 1;scene.run_final_map = true;scene.model.reset();scene.model.select_faction(faction)
		while scene.model.phase != "defeat":
			if scene.model.phase == "bonus": scene.model.choose_bonus(scene.model.bonus_offer[0])
			if scene.model.phase == "finished": scene.model.prepare_next_wave()
			scene.model.start();scene.model.advance(10000);scene._sync_meta_rewards()
		check(scene._run_finished() and scene.meta_profile.data.banks[faction].resource == 56,"Défaite globale : cumul des deux cartes versé une seule fois")
		check(scene.meta_run_id == run_id and scene.meta_profile.data.run.previous_maps == 55,"Identifiant de parcours conservé et reçu global des cartes précédentes")
		scene._sync_meta_rewards(true);scene._show_run_summary()
		check(scene.summary_meta_value.text == "+56" and scene.summary_talents_button.visible,"Accès aux talents et ressources acquises seulement au résultat global")
		check(scene.meta_profile.data.banks[1-faction].resource == 0,"Le versement global reste propre au camp joué")
		scene._summary_to_talents()
		check(scene.choosing_faction and scene.meta_menu.visible,"Accueil et arbres disponibles après la défaite globale")
		scene.free()
		var reopened = Profile.new(path)
		check(reopened.data.banks[faction].resource == 56 and reopened.data.run.settled,"Versement final conservé après réouverture")
		for suffix in ["",".bak",".tmp"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	# Deux cartes remportées : une seule prime de victoire finale, jamais une prime par carte.
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = Profile.new("");scene.mission_definition = {};scene._choose_faction(0)
	scene.run_final_map = false;scene._prepare_campaign_capture("victory");scene._sync_meta_rewards()
	check(scene.meta_profile.data.banks[0].resource == 0,"Première carte gagnée : aucune prime ni versement")
	scene.run_map_index = 1;scene.run_final_map = true;scene.model.reset();scene.model.select_faction(0)
	scene._prepare_campaign_capture("victory");scene._sync_meta_rewards()
	check(scene.meta_profile.data.banks[0].resource == 115,"Deux cartes : 55 + 55 + une seule prime finale de 5")
	check(not scene.meta_profile.credit(scene.meta_run_id,0,10,true,56) and scene.meta_profile.data.banks[0].resource == 115,"Reçu final immuable : impossible de gonfler après paiement")
	scene.free()
	print("RUN_BOUNDARIES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
