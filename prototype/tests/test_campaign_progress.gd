extends SceneTree
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Progress = preload("res://scripts/mission_progress.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func receipt() -> Dictionary: return {"reward":0,"xp":0,"run_id":1}
func run_checks() -> void:
	var ids: Dictionary = {}
	for number in range(1,201):
		var id: String = Catalogue.id_for(number);var definition: Dictionary = Catalogue.definition(number)
		check(not ids.has(id) and Catalogue.number_for(id) == number,"Identifiant de mission unique et stable sur les deux cents positions")
		ids[id] = true
		if number > 120: check(not definition.available and not definition.has("po") and not definition.has("xp") and Catalogue.runtime(id).is_empty(),"Contenu absent non jouable, sans récompense inventée")
	check(Catalogue.available_count() == 120 and Catalogue.runtime("campaign.001") == {"id":"campaign.001","po":60,"xp":100,"waves":10,"map_id":"valley_ford","hp_percent":100},"La mission du Gué et ses gains de référence restent inchangés")
	for invalid in ["campaign.1","campaign.000","campaign.201","campaign.+001","campaign.0001","campaign.001.extra",null,1]: check(Catalogue.number_for(invalid) == 0,"Identifiant non canonique refusé")
	for number in [0,-1,201]: check(Catalogue.definition(number).is_empty() and Catalogue.id_for(number).is_empty(),"Position hors parcours refusée")
	for pair in [[1,1],[10,1],[11,2],[20,2],[21,3],[100,10],[101,11],[200,20]]: check(Catalogue.definition(pair[0]).chapter == pair[1],"Dix missions par chapitre aux frontières du parcours")
	for pair in [[1,20],[21,40],[81,100],[181,200]]: check(Catalogue.definition(pair[0]).theme_pair == Catalogue.definition(pair[1]).theme_pair,"Même groupe de thème pour deux chapitres successifs")
	for number in [11,20,31,40,51,60,91,100]: check(Catalogue.definition(number).introduces_rule,"Bloc prévu d’introduction sur 11–20, 31–40 et suivants")
	for number in [1,10,21,30,41,50,81,90]: check(not Catalogue.definition(number).introduces_rule,"Aucune inversion des blocs d’introduction confirmés")
	var records: Dictionary = {}
	var status: Dictionary = Progress.campaign_status(records)
	check(status.completed == 0 and status.first_hundred == 0 and not status.infinite_eligible and status.next_unwon == 1,"Parcours neuf sans succès ni déblocage de l’infini")
	for number in range(101,201): records[Catalogue.id_for(number)] = receipt()
	status = Progress.campaign_status(records)
	check(status.completed == 100 and status.first_hundred == 0 and not status.infinite_eligible,"Cent missions de seconde moitié ne remplacent pas les cent premières")
	records.clear()
	for number in range(1,100): records[Catalogue.id_for(number)] = receipt()
	records[Catalogue.id_for(200)] = receipt();status = Progress.campaign_status(records)
	check(status.completed == 100 and status.first_hundred == 99 and not status.infinite_eligible and status.next_unwon == 100,"Une mission manquante parmi les cent premières garde la condition verrouillée")
	records[Catalogue.id_for(100)] = receipt();status = Progress.campaign_status(records)
	check(status.first_hundred == 100 and status.infinite_eligible and status.completed == 101,"Les cent premières réussites satisfont précisément la condition de la faction")
	check(status.chapters[0] == 10 and status.chapters[9] == 10 and status.chapters[19] == 1,"Compteurs de chapitre dérivés du registre, sans nouveau stockage")
	for number in range(101,201): records[Catalogue.id_for(number)] = receipt()
	check(Progress.campaign_status(records).next_unwon == 0 and Progress.campaign_status(records).completed == 200,"Parcours entièrement réussi compté une seule fois")
	records = {"capture.xp":receipt(),"campaign.1":receipt(),"campaign.201":receipt(),"campaign.001":null,"campaign.002":{"reward":0,"run_id":0},"campaign.003":{"reward":-1,"run_id":1},"campaign.004":{"reward":0,"run_id":1,"xp":-1},"campaign.005":{"reward":0,"run_id":1.5},"campaign.006":receipt()}
	status = Progress.campaign_status(records)
	check(status.completed == 1 and status.missions[5] and not status.missions[0],"Reçus invalides, non canoniques et hors campagne ignorés")
	# Réussites obtenues par le service réel, sauvegardées puis relues par faction.
	var path: String = "user://test_campaign_progress_%d.json" % Time.get_ticks_usec()
	var p = Profile.new(path)
	var id: int = p.begin_mission(0,"campaign.001",60,10,100)
	check(p.credit_mission(id,0,10,true) and p.campaign_status(0).completed == 1 and p.campaign_status(1).completed == 0,"Une victoire Alliance ne valide aucune mission Horde")
	id = p.begin_mission(1,"campaign.001",60,10,100)
	check(p.credit_mission(id,1,9,false) and p.campaign_status(1).completed == 0,"Une défaite ne valide pas de mission")
	id = p.begin_mission(1,"campaign.001",60,10,100)
	check(p.credit_mission(id,1,10,true) and p.campaign_status(1).completed == 1,"La Horde obtient sa propre première réussite")
	var before: String = JSON.stringify(p.data);p.campaign_status(0);p.campaign_status(1)
	check(JSON.stringify(p.data) == before,"Consulter le parcours ne modifie ni gains ni tentative")
	Profile.Codec.cache.clear();p = Profile.new(path)
	check(p.campaign_status(0).completed == 1 and p.campaign_status(1).completed == 1 and p.data.banks[0].xp == 100 and p.data.banks[1].resource == 60,"Deux parcours et leurs gains retrouvés après réouverture")
	p.blocked = true;check(p.campaign_status(0).is_empty() and p.campaign_status(2).is_empty(),"Profil bloqué ou faction inconnue : aucune fausse progression nulle")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("CAMPAIGN_PROGRESS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
