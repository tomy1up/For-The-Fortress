extends SceneTree
const XPFixture = preload("res://tests/xp_fixture.gd")
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents.gd")
const Report = preload("res://scripts/run_report.gd")
class FlakyProfile extends "res://scripts/meta_profile.gd":
	var failing: bool = false
	var attempts: int = 0
	func credit(run_id: int, faction: int, completed: int, victory: bool, previous_maps: int = 0) -> bool:
		attempts += 1
		if failing: error = "Écriture momentanément indisponible.";return false
		return super.credit(run_id,faction,completed,victory,previous_maps)
	func credit_mission(run_id: int, faction: int, completed: int, victory: bool) -> bool:
		attempts += 1
		if failing: error = "Écriture momentanément indisponible.";return false
		return super.credit_mission(run_id,faction,completed,victory)
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		for config in [Talents.empty_ranks(),[5,0,0,0,0,5,0,0,0,0,5,0,0,0,0],[5,3,2,0,0,5,3,2,0,0,5,3,2,0,0]]:
			for index in range(15):
				var ranks: Array = config.duplicate()
				var before: String = JSON.stringify(ranks)
				var preview: Dictionary = Talents.rank_preview(faction,ranks,index)
				check(before == JSON.stringify(ranks),"Aperçu d'un rang sans modifier l'affectation")
				var candidate: Array = ranks.duplicate();candidate[index] += 1
				if not Talents.current_valid(candidate):
					check(preview.is_empty(),"Pas d'aperçu d'un rang impossible ou d'une ligne verrouillée")
					continue
				var p = Profile.new("");p.data.banks[faction].points = 36;p.data.banks[faction].ranks = ranks.duplicate()
				check(p.allocate(faction,index) and preview.hp_after == Talents.extra_hp(faction,p.data.banks[faction].ranks),"Aperçu des PV identique à une vraie affectation")
				for unit in preview.units:
					check(unit.after == Talents.effects(faction,p.data.banks[faction].ranks,unit.type),"Aperçu des composantes identique aux effets réellement achetés")
		check(Talents.rank_preview(faction,[5,3,2,1,0,0,0,0,0,0,0,0,0,0,0],4).is_empty(),"Aperçu respecte l'exclusion des spécialités finales")
		var path: String = "user://test_feedback_%d_%d.json" % [Time.get_ticks_usec(),faction]
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = Profile.new(path)
		scene._open_meta(faction)
		var before_ui: String = JSON.stringify(scene.meta_profile.data)
		scene.meta_menu._inspect(0)
		check(scene.meta_menu.detail_text.text.contains("Prochain rang") and scene.meta_menu.detail_text.text.contains("Aucun point disponible"),"Gain du prochain rang consultable même sans point disponible")
		check(before_ui == JSON.stringify(scene.meta_profile.data),"Lire le prochain rang ne crée ni point ni dépense")
		scene.meta_menu.close();scene._choose_faction(faction)
		scene._prepare_campaign_capture("victory");scene._show_run_summary()
		var info: Dictionary = scene._meta_reward_summary()
		check(info.saved == 60 and info.waves == 0 and info.bonus == 0 and info.balance == 60 and info.affordable == 0,"Bilan victoire : vagues et prime enregistrées au montant exact")
		check(scene.summary_meta_value.text == "+60" and scene.summary_meta_status.text.begins_with("Sauvegardées") and scene.summary_meta_note.text.contains("XP : +100"),"Bilan annonce les ressources sauvées et les points achetables")
		var before_read: String = JSON.stringify([scene.meta_profile.data,Report.build(scene.model)])
		scene._show_run_summary();scene._update_meta_summary();scene._show_run_summary()
		check(before_read == JSON.stringify([scene.meta_profile.data,Report.build(scene.model)]),"Relire le bilan ne crédite pas à nouveau les gains et ne modifie pas le combat")
		scene.summary_talents_button.pressed.emit()
		check(scene.choosing_faction and scene.meta_menu.visible and scene.meta_menu.faction == faction and not scene.summary_open,"Accès aux talents de la faction jouée pour la partie suivante")
		XPFixture.unlock(scene.meta_profile,faction,1);scene.meta_menu.refresh();scene.meta_menu._allocate(0)
		check(scene.meta_profile.data.banks[faction].resource == 60 and scene.meta_profile.data.banks[faction].points == 1,"Un gain de victoire finance un vrai point")
		scene.meta_menu.close();scene.meta_profile = Profile.new(path)
		check(scene.meta_profile.data.banks[faction].resource == 60 and scene.meta_profile.data.banks[faction].ranks[0] == 1,"Réouverture du fichier : solde et affectation conservés")
		scene._choose_faction(faction)
		check(scene.model.meta_ranks[0] == 1 and scene.meta_profile.data.banks[1-faction].resource == 0,"Point actif à la tentative suivante, sans bénéfice pour l'autre camp")
		scene.free()
		for suffix in ["",".bak",".tmp"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
		# Une défaite conserve seulement les vagues réellement terminées.
		scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = Profile.new("");scene._choose_faction(faction)
		while scene.model.phase != "defeat":
			if scene.model.phase == "bonus": scene.model.choose_bonus(scene.model.bonus_offer[0])
			if scene.model.phase == "finished": scene.model.prepare_next_wave()
			scene.model.start();scene.model.advance(10000)
		scene._show_run_summary();info = scene._meta_reward_summary()
		check(info.saved == 0 and info.bonus == 0 and info.affordable == 0 and scene.summary_meta_note.text.contains("XP : +0"),"Défaite sans défense : première vague seule rémunérée, neuf ressources avant un point")
		scene.meta_profile.data.banks[faction].points = Talents.MAX_POINTS;scene._update_meta_summary()
		check(scene._meta_reward_summary().affordable == 0 and scene.summary_meta_note.text.contains("51/51 points"),"Plafond de contenu : aucun achat supplémentaire annoncé")
		scene.free()
	# Échec d'écriture : pas de faux message de sauvegarde, reprise sans double gain.
	var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = FlakyProfile.new("");scene._choose_faction(0)
	scene._prepare_campaign_capture("victory");scene.meta_profile.failing = true;scene._show_run_summary()
	check(scene.summary_meta_value.text == "0 / 60" and scene.summary_talents_button.text == "Réessayer la sauvegarde" and scene.meta_profile.data.banks[0].resource == 0,"Échec de sauvegarde : gains en attente, aucune fausse attribution")
	var attempts: int = scene.meta_profile.attempts
	for frame in range(10): scene._process(0.1)
	check(scene.meta_profile.attempts == attempts,"Échec d'écriture : pas de nouvelle tentative à chaque image")
	scene._summary_to_talents()
	check(scene.summary_open and not scene.meta_menu.visible,"Échec persistant : le raccourci ne détruit pas le bilan")
	scene._close_run_summary();scene._reset()
	check(not scene.choosing_faction and scene.model.phase == "victory","Rejouer ne détruit pas non plus un résultat dont le versement a échoué")
	scene._show_run_summary()
	scene.meta_profile.failing = false;scene._summary_to_talents()
	check(scene.summary_open and scene.summary_meta_value.text == "+60" and scene.meta_profile.data.banks[0].resource == 60,"Premier clic de reprise : enregistrement confirmé avant de quitter")
	scene._summary_to_talents()
	check(scene.meta_menu.visible and scene.meta_profile.data.banks[0].resource == 60,"Deuxième clic : talents ouverts sans double crédit")
	scene.free()
	print("PROGRESSION_FEEDBACK_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
