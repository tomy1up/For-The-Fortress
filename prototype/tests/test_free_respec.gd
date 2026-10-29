extends SceneTree
const Profile = preload("res://scripts/meta_profile.gd")
const Main = preload("res://scripts/main.gd")
const Talents = Profile.Talents
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var p = Profile.new("");var id: int = p.begin_mission(faction,"test.respec",13)
		p.credit_mission(id,faction,10,true);p.data.banks[faction].resource = 0;p.data.banks[faction].points = 5
		var receipts: Dictionary = p.data.banks[faction].mission_rewards.duplicate(true)
		var other: Dictionary = p.data.banks[1-faction].duplicate(true)
		for previous_count in [0,20,1000000000]:
			p.data.banks[faction].resets = previous_count
			for repeat in range(3):
				for rank in range(5): check(p.allocate(faction,0),"Points rendus réinvestissables sans rachat")
				check(p.reset_price(faction) == 0 and p.respec(faction),"Reset toujours gratuit même sans PO et après de nombreux essais")
				check(p.data.banks[faction].resource == 0 and p.data.banks[faction].points == 5 and Talents.spent(p.data.banks[faction].ranks) == 0,"PO et points achetés inchangés, rangs rendus")
				check(p.data.banks[faction].mission_rewards == receipts and p.data.banks[1-faction] == other,"Reçus de première victoire et autre faction intacts")
		var before: Dictionary = p.data.duplicate(true)
		check(not p.respec(faction) and p.data == before,"Arbres vides : aucun enregistrement ou compteur inutile")
		p.allocate(faction,0);p.blocked = true;before = p.data.duplicate(true)
		check(not p.respec(faction) and p.data == before,"Profil bloqué : gratuité sans contournement de la sauvegarde")
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.meta_profile = Profile.new("")
		scene.meta_profile.data.banks[faction].points = 5;scene.meta_profile.data.banks[faction].ranks[0] = 5
		scene._open_meta(faction)
		check(not scene.meta_menu.reset_button.disabled and scene.meta_menu.reset_button.text.contains("Gratuit"),"Commande disponible à zéro PO avant une mission")
		scene.meta_menu.close();scene._choose_faction(faction);scene._start()
		var model_before: String = JSON.stringify(Report.build(scene.model))
		for phase in ["combat","finished","bonus","victory"]:
			scene.model.phase = phase;scene.run_final_map = false;scene._update_interface();before = scene.meta_profile.data.duplicate(true)
			scene._open_meta(faction);scene.meta_menu._request_reset();scene.meta_menu.confirm.confirmed.emit()
			check(not scene.meta_menu.visible and not scene.meta_menu.confirm.visible and scene.meta_profile.data == before,"Aucun reset pendant la mission ou à un résultat intermédiaire")
		scene.model.phase = "defeat";scene._update_interface();scene._reset();scene._open_meta(faction)
		model_before = JSON.stringify(Report.build(scene.model))
		scene.meta_menu._request_reset()
		check(scene.meta_menu.confirm.visible and scene.meta_menu.confirm.dialog_text.contains("Aucune PO") and not scene.meta_menu.confirm.dialog_text.contains("Prochaine réinitialisation"),"Après la mission : confirmation explique la gratuité sans ancien tarif")
		scene.meta_menu.confirm.confirmed.emit()
		check(scene.meta_profile.data.banks[faction].resource == 0 and scene.meta_profile.data.banks[faction].points == 5 and Talents.spent(scene.meta_profile.data.banks[faction].ranks) == 0,"Après défaite, tous les points sont rendus gratuitement")
		check(model_before == JSON.stringify(Report.build(scene.model)),"Le changement des arbres ne réécrit pas les talents de la partie terminée")
		scene.free()
	print("FREE_RESPEC_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
