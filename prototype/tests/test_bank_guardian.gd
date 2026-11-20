extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Banks = Model.Banks
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Sample = preload("res://tests/test_chapter_one.gd")
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func close(a: float,b: float) -> bool: return absf(a-b) < 0.000001
func _initialize() -> void: call_deferred("run_checks")
func enemy(id: int,type: int,hp: float) -> Dictionary:
	var result: Dictionary = Model.make_enemy(id,type,0,0);result.hp = hp;return result
func verify_transfer(guards_hp: float, direct: float, victim_damage: float) -> Dictionary:
	var enemies: Array = [enemy(0,8,guards_hp),enemy(1,1,40),enemy(2,2,24)]
	var damage: Dictionary = {0:direct,1:victim_damage,2:victim_damage}
	var hits: Array = []
	for id in damage: hits.append({"enemy_id":id,"source_id":7,"component":"direct","amount":damage[id]})
	var source: String = str([enemies,damage,hits])
	var result: Dictionary = Banks.redirect(enemies,damage,hits,{0:Vector2.ZERO,1:Vector2.RIGHT,2:Vector2.LEFT})
	check(str([enemies,damage,hits]) == source,"Le calcul de protection ne modifie aucun état d’entrée")
	var total: float = 0.0;var attributed: float = 0.0
	for id in result.damage: total += result.damage[id]
	for hit in result.hits:
		attributed += hit.amount
		check(hit.source_id == 7 and hit.component == "direct","Source et composante conservées pour les dégâts absorbés")
	check(close(total,direct+2*victim_damage) and close(attributed,total),"Conservation des dégâts : aucun dégât créé ni perdu dans le bilan")
	check(result.damage[0] <= maxf(guards_hp,direct)+0.000001,"Absorption plafonnée aux PV disponibles après dégâts directs")
	return result
func run_checks() -> void:
	var result: Dictionary = verify_transfer(180,0,40)
	check(close(result.damage[0],20) and close(result.damage[1],30) and close(result.damage[2],30),"25 % des dégâts des deux voisins vont à la tortue")
	result = verify_transfer(10,0,40)
	check(close(result.damage[0],10) and close(result.damage[1],35) and close(result.damage[2],35),"Derniers PV partagés proportionnellement entre voisins frappés simultanément")
	result = verify_transfer(10,8,40)
	check(close(result.damage[0],10) and close(result.damage[1],39),"Les dégâts directement reçus par la tortue passent avant son absorption")
	result = verify_transfer(10,12,40)
	check(result.transfers.is_empty() and close(result.damage[1],40),"Tortue déjà tuée par l’impact simultané : aucune protection")
	for hp in [0.1,1.0,10.0,180.0]:
		for direct in [0.0,0.1,20.0,200.0]:
			for amount in [0.0,1.0,40.0,1000.0]: verify_transfer(hp,direct,amount)
	var group: Array = [enemy(0,8,180),enemy(1,8,180),enemy(2,1,40),enemy(3,7,600)]
	result = Banks.redirect(group,{0:40.0,1:40.0,2:40.0,3:40.0},[],{0:Vector2.LEFT,1:Vector2.RIGHT,2:Vector2.ZERO,3:Vector2.ZERO})
	check(result.transfers.size() == 1 and result.transfers[0].guardian_id == 0 and close(result.damage[3],40),"Ni chaîne entre tortues ni protection du boss ; égalité départagée par ID")
	result = Banks.redirect(group,{2:40.0},[],{0:Vector2(2.0001,0),1:Vector2(-3,0),2:Vector2.ZERO,3:Vector2.ZERO})
	check(result.transfers.is_empty(),"Aucun transfert hors du rayon logique de deux")
	result = Banks.redirect(group,{2:40.0},[],{0:Vector2(2,0),1:Vector2(-3,0),2:Vector2.ZERO,3:Vector2.ZERO})
	check(result.transfers.size() == 1,"Borne exacte du rayon incluse")
	var m = Model.new();m.enemies.assign([enemy(0,8,2),enemy(1,1,40)])
	var initial_gold: int = m.gold
	m._apply_damage({1:40.0},[{"enemy_id":1,"source_id":7,"component":"periodic","amount":40.0}])
	check(m.enemies.size() == 1 and m.enemies[0].id == 1 and close(m.enemies[0].hp,2) and m.gold == initial_gold+8 and m.total_killed == 1,"Mort réelle de la gardienne, gain unique et dégâts limités correctement transférés")
	m._apply_damage({1:2.0})
	check(m.enemies.is_empty() and m.total_killed == 2 and m.gold == initial_gold+11,"Après mort de la tortue, le voisin n’est plus protégé")
	check(m.protection_events.size() == 1 and m.protection_events[0].amount == 2.0,"Le rendu observe uniquement un transfert réel")
	m.reset();check(m.protection_events.is_empty(),"Un nouvel essai efface les anciens signaux de protection")
	for invalid in [null,1,true,"","inconnu"]: check(not m.configure_wave_set(invalid),"Identifiant de rencontres inconnu refusé")
	check(m.configure_wave_set(Banks.ID) and m.select_faction(0) and not m.configure_wave_set("ford"),"Rencontres figées avant le premier choix de faction")
	for number in range(11,21):
		var data: Dictionary = Catalogue.runtime(Catalogue.id_for(number))
		check(data.wave_set_id == Banks.ID and data.hp_percent == 99+number and data.po == 60 and data.xp == 100,"Dix missions du chapitre 2, mêmes règles de récompense et courbe de PV")
		var counts: int = 0
		for wave in range(1,11):
			var forecast: Dictionary = Model.wave_forecast(wave,0,data.hp_percent,data.wave_set_id)
			check(forecast.total == Model.Campaign.schedule(wave,Banks.ID).size(),"Aperçu et apparitions utilisent la même séquence")
			for entry in forecast.groups:
				if entry.type == 8: counts += entry.count;check(entry.origin == "neutral" and close(entry.hp,180*data.hp_percent/100.0),"Tortue neutre aux PV du bon palier")
		check(counts > 0,"La nouveauté est présente dans chacune des dix missions")
	# Rejeu réel de parties, à pas longs puis courts ; aucune sauvegarde joueur.
	for faction in [0,1]:
		var reports: Array = []
		for step in [300.0,0.05]:
			var data: Dictionary = Catalogue.runtime("campaign.011")
			m = Model.new(true,Model.Maps.for_id(data.map_id));m.configure_wave_set(Banks.ID);m.configure_enemy_hp(data.hp_percent);m.select_faction(faction)
			Sample.play(m,step)
			var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(m)))
			check(Replay.verify(report).ok,"Le rapport de chapitre 2 se rejoue exactement, sans perte des rencontres")
			check(report.enemy_catalog.size() == 9 and report.wave_set_id == Banks.ID and "Tortue" in Report.markdown(report),"Rapport lisible avec neuvième profil neutre")
			reports.append(report)
		for key in ["result","wave","gold","fortress_hp","total_income","total_killed","total_escaped","actions","performance"]:
			check(Replay._difference(reports[0][key],reports[1][key],key).is_empty(),"Protection indépendante du découpage des images : "+key)
		var bad: Dictionary = reports[0].duplicate(true);bad.wave_set_id = "inconnu"
		check(not Replay.verify(bad).ok,"Un rapport ne peut charger un jeu de rencontres arbitraire")
	var scene = Main.new();root.add_child(scene);scene.set_process(false)
	scene.meta_profile = Profile.new("")
	for number in range(1,11):
		var id: int = scene.meta_profile.begin_mission(0,Catalogue.id_for(number),60,10,100)
		scene.meta_profile.credit_mission(id,0,10,true)
	scene._open_campaign(0);scene._launch_campaign_mission("campaign.011")
	check(scene.model.wave_set_id == Banks.ID and scene.model.enemy_hp_percent == Main.CampaignCatalogue.faction_hp_percent(11,0) and scene.model.faction == 0 and not scene.choosing_faction,"Le vrai parcours lance la mission 11 avec les bonnes rencontres")
	scene.model.wave = 2;scene.forecast_wave = -1;scene._update_wave_forecast()
	check(scene.forecast_data.groups[0].type == 8 and "25 %" in scene.forecast_rows[0].tooltip_text,"L’aperçu explique la nouvelle capacité avant la vague")
	scene.queue_free();await process_frame
	print("BANK_GUARDIAN_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
