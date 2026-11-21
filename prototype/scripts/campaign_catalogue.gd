extends RefCounted
## Structure cible du parcours. Seul le contenu marqué disponible est jouable.
const TOTAL_MISSIONS: int = 200
const CHAPTER_SIZE: int = 10
const CHAPTER_COUNT: int = TOTAL_MISSIONS/CHAPTER_SIZE
const INFINITE_REQUIREMENT: int = 100

static func id_for(number: int) -> String:
	return "campaign.%03d" % number if number >= 1 and number <= TOTAL_MISSIONS else ""

static func number_for(id: Variant) -> int:
	if not id is String or not id.begins_with("campaign."): return 0
	var suffix: String = id.trim_prefix("campaign.")
	if not suffix.is_valid_int(): return 0
	var number: int = int(suffix)
	return number if id_for(number) == id else 0

static func definition(number: int) -> Dictionary:
	if number < 1 or number > TOTAL_MISSIONS: return {}
	var chapter: int = (number-1)/CHAPTER_SIZE+1
	var result: Dictionary = {"id":id_for(number),"number":number,"chapter":chapter,"theme_pair":(chapter-1)/2+1,"introduces_rule":chapter%2 == 0,"title":"Mission %d" % number,"available":false}
	if number <= 20:
		var maps: Array[String] = ["valley_ford","ford_woods","ford_heights","ford_turns","ford_glade","ford_pass","ford_switchbacks","ford_trail","ford_approach","ford_ramparts"]
		var titles: Array[String] = ["La Vallée du Gué","Le Bois du Gué","Les Hauts du Gué","Les Détours du Gué","La Clairière du Gué","Le Défilé du Gué","Les Lacets du Gué","Le Sentier du Gué","Les Abords du Gué","Les Remparts du Gué"]
		result.merge({"title":titles[(number-1)%10],"available":true,"map_id":maps[(number-1)%10],"hp_percent":99+number,"po":60,"xp":100,"waves":10},true)
		if number > 10: result.wave_set_id = "ford_banks"
	elif number <= 40:
		var maps: Array[String] = ["slate_pass","slate_ridges","slate_scree","slate_ravine","slate_gates","slate_crossing","slate_laces","slate_cirque","slate_high_passages","slate_bastion"]
		var titles: Array[String] = ["Le Col des Ardoises","Les Crêtes des Ardoises","Les Éboulis des Ardoises","Le Ravin des Ardoises","Les Portes des Ardoises","Les Trois Passages des Ardoises","Les Lacets des Ardoises","Le Cirque des Ardoises","Les Hauts Passages des Ardoises","Le Bastion des Ardoises"]
		result.merge({"title":titles[(number-21)%10],"available":true,"map_id":maps[(number-21)%10],"hp_percent":99+number,"po":60,"xp":100,"waves":10},true)
		if number > 30: result.combat_affix = {"id":"headwinds","cadence_percent":90}
		if number == 40: result.merge({"map_id":"slate_bastion_winds","title":"Le Bastion Sous le Vent"},true) # Finale du chapitre 4 : carte propre (v0.178).
	elif number <= 50:
		var maps: Array[String] = ["marsh_threshold","marsh_basins","marsh_court","marsh_channels","marsh_cloister","marsh_causeway","marsh_fords","marsh_islets","marsh_nave","marsh_sanctuary"]
		var titles: Array[String] = ["Le Seuil des Marais","Les Bassins Engloutis","La Cour des Noyés","Les Chenaux Oubliés","Le Cloître Submergé","La Chaussée des Roseaux","Les Trois Gués Noyés","Les Îlots du Chœur","La Nef Effondrée","Le Sanctuaire Englouti"]
		result.merge({"title":titles[number-41],"available":true,"map_id":maps[number-41],"hp_percent":99+number,"po":60,"xp":100,"waves":10},true)
	elif number <= 60:
		var maps: Array[String] = ["marsh_stagnant","marsh_banks","marsh_currents","marsh_abyss","marsh_delta","marsh_overflow","marsh_pillars","marsh_crossroads","marsh_cathedral","marsh_heart"]
		var titles: Array[String] = ["Les Eaux Mortes","Les Berges Noyées","Les Gués du Double Courant","La Mare Sans Fond","Le Delta des Noyés","La Crue","Les Piliers Engloutis","Le Carrefour des Eaux","La Cathédrale Noyée","Le Cœur du Marais"]
		result.merge({"title":titles[number-51],"available":true,"map_id":maps[number-51],"hp_percent":99+number,"po":60,"xp":100,"waves":10,"wave_set_id":"marsh_drowned"},true)
	elif number <= 70:
		var maps: Array[String] = ["volcano_threshold","volcano_flows","volcano_caldera","volcano_vents","volcano_forges","volcano_bridge","volcano_organs","volcano_twin","volcano_road","volcano_core"]
		var titles: Array[String] = ["Le Seuil des Cendres","Les Coulées Figées","La Caldeira","Les Fumerolles","Les Forges Noires","Le Pont d'Obsidienne","Les Orgues de Basalte","Le Cratère Jumeau","La Route des Cendres","Le Cœur du Volcan"]
		result.merge({"title":titles[number-61],"available":true,"map_id":maps[number-61],"hp_percent":99+number,"po":60,"xp":100,"waves":10},true)
	elif number <= 80:
		# Chapitre 8 : nouveauté du biome volcanique, l'affixe Éruptions (décision du porteur, 10 novembre 2026). Valeurs d'essai.
		var maps: Array[String] = ["ash_crater","ash_chimneys","ash_cone","ash_rift","ash_geysers","ash_flow","ash_embers","ash_dome","ash_gorge","ash_heart"]
		var titles: Array[String] = ["Le Cratère Fumant","Les Cheminées","Le Cône Ardent","La Faille Rougeoyante","Les Geysers de Cendres","La Coulée Noire","Les Braises Dormantes","Le Dôme d'Obsidienne","La Gorge de Feu","Le Cœur en Éruption"]
		result.merge({"title":titles[number-71],"available":true,"map_id":maps[number-71],"hp_percent":99+number,"po":60,"xp":100,"waves":10,"combat_affix":{"id":"eruptions","interval":14,"warning":3,"duration":5}},true)
	elif number <= 90:
		# Chapitre 9 : citadelle de la faction adverse (décision du porteur, 11 novembre 2026), sans règle propre. Noms et tracés d'essai.
		var maps: Array[String] = ["citadel_glacis","citadel_drawbridge","citadel_barbican","citadel_ramparts","citadel_court","citadel_towers","citadel_gates","citadel_wall","citadel_dungeons","citadel_keep"]
		var titles: Array[String] = ["Les Glacis","Le Pont-levis","La Barbacane","Les Remparts","La Cour d'Armes","Les Deux Tours","Les Portes Jumelles","Le Chemin de Ronde","Les Oubliettes","Le Donjon"]
		result.merge({"title":titles[number-81],"available":true,"map_id":maps[number-81],"hp_percent":99+number,"po":60,"xp":100,"waves":10},true)
	elif number <= 100:
		# Chapitre 10 : nouveauté du biome de la citadelle, la Garnison (décision du porteur, 11 novembre 2026). Valeurs d'essai.
		var maps: Array[String] = ["garrison_breach","garrison_siege","garrison_machicolations","garrison_hall","garrison_barracks","garrison_watchtower","garrison_armoury","garrison_stairs","garrison_throne","garrison_heart"]
		var titles: Array[String] = ["La Brèche","Le Siège","Les Mâchicoulis","La Grande Salle","Les Casernes","La Tour de Guet","L'Armurerie","Les Escaliers","La Salle du Trône","Le Cœur de la Citadelle"]
		result.merge({"title":titles[number-91],"available":true,"map_id":maps[number-91],"hp_percent":99+number,"po":60,"xp":100,"waves":10,"wave_set_id":"citadel_garrison"},true)
	elif number <= 110:
		# Chapitre 11 : désert et ruines, premier chapitre du sixième biome, sans règle propre (décision du porteur, 11 novembre 2026).
		# Au-delà de la mission 100, plus d'XP (CAMP-011) ; PO de 60 + 5 par chapitre au-delà du dixième (valeurs d'essai).
		var maps: Array[String] = ["dune_first","dune_oasis","dune_canyon","dune_columns","dune_caravans","dune_temple","dune_well","dune_obelisks","dune_sea","dune_necropolis"]
		var titles: Array[String] = ["Les Premières Dunes","L'Oasis Asséchée","Le Canyon Rouge","Les Colonnes Brisées","La Route des Caravanes","Le Temple Ensablé","Le Puits Perdu","Les Obélisques","La Mer de Sable","La Nécropole Ancienne"]
		result.merge({"title":titles[number-101],"available":true,"map_id":maps[number-101],"hp_percent":99+number,"po":reward_po(chapter),"xp":0,"waves":10},true)
	elif number <= 120:
		# Chapitre 12 : nouveauté du biome du désert, la tempête de sable (décision du porteur, 11 novembre 2026). Valeurs d'essai.
		var maps: Array[String] = ["dune_mirage","dune_scorpion","dune_ruins","dune_arches","dune_cistern","dune_sphinx","dune_wind","dune_sarcophagus","dune_crater","dune_pyramid"]
		var titles: Array[String] = ["Le Mirage","La Vallée des Scorpions","Les Ruines Englouties","Les Arches de Grès","La Citerne Perdue","Le Sphinx Brisé","Le Col des Vents de Sable","La Salle du Sarcophage","Le Cratère de Verre","La Pyramide Ensablée"]
		result.merge({"title":titles[number-111],"available":true,"map_id":maps[number-111],"hp_percent":99+number,"po":reward_po(chapter),"xp":0,"waves":10,"combat_affix":{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":25}},true)
	elif number <= 130:
		# Chapitre 13 : souterrains et mines, premier chapitre du septième biome, sans règle propre (recommandation de Claude Code, biome à confirmer par le porteur).
		var maps: Array[String] = ["mine_entrance","mine_shaft","mine_gallery","mine_crystals","mine_cart","mine_forge","mine_lake","mine_vault","mine_collapse","mine_heart"]
		var titles: Array[String] = ["L'Entrée de la Mine","Le Puits Principal","La Galerie des Échos","La Grotte aux Cristaux","Les Rails Abandonnés","La Forge Souterraine","Le Lac Noir","La Chambre Forte","L'Éboulis","Le Cœur de la Montagne"]
		result.merge({"title":titles[number-121],"available":true,"map_id":maps[number-121],"hp_percent":99+number,"po":reward_po(chapter),"xp":0,"waves":10},true)
	elif number <= 140:
		# Chapitre 14 : nouveauté du biome des souterrains, l'éboulement (décision du porteur, 12 novembre 2026). Valeurs d'essai.
		var maps: Array[String] = ["mine_pillars","mine_vein","mine_tunnel","mine_arch","mine_twins","mine_abyss","mine_sluice","mine_crossing","mine_crypt","mine_core"]
		var titles: Array[String] = ["Les Piliers Fissurés","La Veine Oubliée","Le Tunnel Éventré","La Voûte Instable","Les Galeries Jumelles","Le Gouffre Noir","L'Écluse Souterraine","Le Carrefour des Éboulis","La Crypte des Mineurs","Le Cœur Effondré"]
		result.merge({"title":titles[number-131],"available":true,"map_id":maps[number-131],"hp_percent":99+number,"po":reward_po(chapter),"xp":0,"waves":10,"combat_affix":{"id":"rockfall","interval":18,"warning":3,"duration":7}},true)
	elif number <= 150:
		# Chapitre 15 : huitième biome, îles flottantes et cité céleste, sans règle propre (recommandation de Claude Code sur délégation du porteur, 12 novembre 2026 ; biome à confirmer).
		var maps: Array[String] = ["sky_pontoon","sky_mistbridge","sky_cloudgate","sky_spires","sky_gardens","sky_belvedere","sky_updrafts","sky_dome","sky_fallen","sky_summit"]
		var titles: Array[String] = ["Le Ponton des Nuées","Le Pont de Brume","La Porte des Nuages","Les Flèches d'Azur","Les Jardins Suspendus","Le Belvédère","Les Courants Ascendants","Le Dôme Céleste","L'Île Effondrée","La Citadelle des Cimes"]
		result.merge({"title":titles[number-141],"available":true,"map_id":maps[number-141],"hp_percent":hp_percent_for(number),"po":reward_po(chapter),"xp":0,"waves":10},true)
	elif number <= 160:
		# Chapitre 16 : nouveauté du biome des îles flottantes, l'aigle des cimes (décision du porteur, 12 novembre 2026). Valeurs d'essai.
		var maps: Array[String] = ["sky_aerie","sky_nest","sky_twinpeaks","sky_triplenest","sky_ledge","sky_col","sky_raptors","sky_roost","sky_azurefall","sky_throne"]
		var titles: Array[String] = ["L'Aire des Aigles","Le Nid de Brume","Les Pitons Jumeaux","Les Trois Aires","La Corniche Ventée","Le Col du Ciel","Les Rapaces","Le Perchoir","La Chute d'Azur","Le Trône des Nuées"]
		result.merge({"title":titles[number-151],"available":true,"map_id":maps[number-151],"hp_percent":hp_percent_for(number),"po":reward_po(chapter),"xp":0,"waves":10,"wave_set_id":"sky_eagles"},true)
	elif number <= 170:
		# Chapitre 17 : neuvième biome, côtes et récifs, sans règle propre (choix du porteur, 12 novembre 2026).
		var maps: Array[String] = ["coast_jetty","coast_lighthouse","coast_reefs","coast_wrecks","coast_quay","coast_cliff","coast_coves","coast_harbor","coast_skerry","coast_cape"]
		var titles: Array[String] = ["La Jetée Abandonnée","Le Phare Éteint","Les Récifs Blancs","La Baie des Épaves","Le Quai des Brumes","La Falaise du Guet","Les Criques Jumelles","Le Port Englouti","L'Écueil Noir","La Forteresse du Cap"]
		result.merge({"title":titles[number-161],"available":true,"map_id":maps[number-161],"hp_percent":hp_percent_for(number),"po":reward_po(chapter),"xp":0,"waves":10},true)
	elif number <= 180:
		# Chapitre 18 : nouveauté du biome des côtes, l'affixe Brume marine (décision du porteur, 12 novembre 2026). Valeurs d'essai.
		var maps: Array[String] = ["coast_beacon","coast_causeway","coast_chalk","coast_graveyard","coast_shoal","coast_phantom","coast_twinrocks","coast_arsenal","coast_storm","coast_citadel"]
		var titles: Array[String] = ["Le Phare des Brumes","La Digue Noyée","Les Falaises Blanches","Le Cimetière des Navires","Le Banc de Sable","La Baie Fantôme","Les Écueils Jumeaux","L'Arsenal Englouti","Le Cap des Tempêtes","La Citadelle des Embruns"]
		result.merge({"title":titles[number-171],"available":true,"map_id":maps[number-171],"hp_percent":hp_percent_for(number),"po":reward_po(chapter),"xp":0,"waves":10,"combat_affix":{"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":30}},true)
	elif number <= 190:
		# Chapitre 19 : dixième biome, nécropole et terres maudites, sans règle propre (choix du porteur, 13 novembre 2026).
		var maps: Array[String] = ["necro_gate","necro_road","necro_graveyard","necro_crypts","necro_fen","necro_hill","necro_mausoleums","necro_ossuary","necro_stelae","necro_royal"]
		var titles: Array[String] = ["Le Portail des Ossements","La Route des Tombes","Le Cimetière Oublié","Les Cryptes Basses","Le Marais des Défunts","La Colline des Pendus","Les Mausolées Jumeaux","L'Ossuaire","Le Champ des Stèles","La Nécropole Royale"]
		result.merge({"title":titles[number-181],"available":true,"map_id":maps[number-181],"hp_percent":hp_percent_for(number),"po":reward_po(chapter),"xp":0,"waves":10},true)
	elif number <= 200:
		# Chapitre 20 : nouveauté du biome de la nécropole, le revenant (décision du porteur, 13 novembre 2026). Valeurs d'essai.
		var maps: Array[String] = ["necro_tombgate","necro_wake","necro_catacombs","necro_bonefield","necro_mire","necro_gallows","necro_twintombs","necro_charnel","necro_obelisks","necro_throne"]
		var titles: Array[String] = ["La Porte des Tombeaux","La Veillée Funèbre","Les Catacombes","Le Champ d'Ossements","Le Bourbier des Âmes","Le Gibet Oublié","Les Tombes Jumelles","Le Charnier","Les Obélisques Noirs","Le Trône du Roi Mort"]
		result.merge({"title":titles[number-191],"available":true,"map_id":maps[number-191],"hp_percent":hp_percent_for(number),"po":reward_po(chapter),"xp":0,"waves":10,"wave_set_id":"necro_revenants"},true)
	return result

## Révision de la courbe de la Horde (décision du porteur, 15 novembre 2026, mesure dans `design/Mesure_boutique_finales_O016.md`) : à partir de la mission 150, les ennemis affrontés par la Horde ont 10 % de PV en moins (réglage de prototype à confirmer).
const HORDE_HP_FROM := 150
const HORDE_HP_FACTOR := 0.9
## Finale de la campagne (mission 200) : la Horde y gagnait 2 parties sur 12 contre 9 pour l'Alliance ; PV d'ennemis à 85 % de la courbe de base pour elle seule (décision du porteur, 15 novembre 2026, réglage de prototype à confirmer).
const HORDE_FINALE_MISSION := 200
const HORDE_FINALE_FACTOR := 0.85

## Rééquilibrage v0.232 (décision du porteur, 20 novembre 2026 : viser 40 à 70 % de marge de PV de forteresse pour la meilleure composition, parce que les bonus élargis ajoutent de la puissance ; réglage de prototype à confirmer).
## Coefficient de PV ennemis (en %) de chaque mission, par faction (Alliance, Horde), appliqué à la courbe de base ci-dessous. Mesuré mission par mission pour ramener à environ 55 % la marge de la meilleure des 30 compositions de l'étude, sans que la composition de référence des tests de chapitre (Alliance 0,1,1 ; Horde 3,3,5, bonus de référence) descende sous 25 % de marge (jamais en dessous de 100 % : une mission déjà dure n'est pas durcie). Méthode et résultats : `design/Rebalancage_bonus_v0232.md` ; outils : `tools/faction_study.gd` (HPMUL).
const REBALANCE_PERCENT := [
	[100,114,116,104,106,138,129,127,112,136,100,121,124,109,107,126,121,125,112,129,113,100,105,110,110,113,117,116,106,109,100,100,100,100,101,101,100,104,100,100,100,112,106,103,121,100,105,118,108,103,102,104,107,106,101,123,121,111,121,101,116,120,104,100,103,100,112,100,100,106,100,111,102,100,100,100,100,100,113,101,101,110,112,100,118,113,117,113,113,104,112,123,111,114,125,109,106,116,125,111,128,117,114,105,150,103,106,112,108,109,134,122,100,105,121,103,104,103,100,101,119,100,103,106,115,100,100,100,100,100,112,103,100,109,101,107,101,107,100,105,126,107,101,105,124,103,100,100,104,102,104,127,104,107,110,111,106,105,105,104,116,112,105,103,112,110,106,112,112,102,104,102,104,104,110,100,103,108,103,102,114,110,113,104,109,103,103,111,108,104,102,103,113,103,114,103,104,106,102,103],
	[100,106,104,100,100,104,118,112,103,102,100,113,104,103,100,105,115,108,102,104,106,100,103,110,101,109,115,112,102,101,100,100,100,100,100,100,100,102,100,100,104,115,100,107,111,107,104,106,117,100,100,111,100,107,103,100,103,103,102,100,122,119,104,104,105,100,118,101,100,115,100,111,103,100,102,102,101,104,108,112,107,114,111,102,119,111,125,117,116,109,111,112,118,140,118,108,113,118,136,138,123,124,124,113,150,107,116,119,114,125,150,125,109,106,139,126,127,100,108,125,123,102,100,106,112,100,100,100,100,100,129,130,120,116,120,114,120,123,114,111,136,110,115,112,133,115,113,105,102,125,135,150,140,142,138,138,132,138,125,136,139,140,137,132,137,122,121,132,139,112,119,130,130,138,139,138,128,129,128,100,146,135,137,134,140,130,127,130,133,136,115,131,124,120,141,124,126,115,124,128]
]

static func rebalance_percent(number: int, faction: int) -> float:
	return float(REBALANCE_PERCENT[faction][clampi(number,1,REBALANCE_PERCENT[faction].size())-1])

## PV ennemis effectivement joués par une faction : `hp_percent` de la mission, réduit de 10 % pour la Horde à partir de la mission 150, puis multiplié par le coefficient de rééquilibrage.
static func faction_hp_percent(number: int, faction: int) -> int:
	var base: float = float(definition(number).get("hp_percent",hp_percent_for(number)))
	if faction == 1 and number == HORDE_FINALE_MISSION: base = float(int(round(base*HORDE_FINALE_FACTOR)))
	elif faction == 1 and number >= HORDE_HP_FROM: base = float(int(round(base*HORDE_HP_FACTOR)))
	return int(round(base*rebalance_percent(number,faction)/100.0))

## PV ennemis (en % de la référence) d'une mission : `99 + numéro` jusqu'à la mission 140, puis +1 % toutes les deux missions jusqu'à la mission 180 (décision du porteur, 12 novembre 2026), puis +1 % toutes les quatre missions (+0,25 % par mission, décision du porteur, 13 novembre 2026).
static func hp_percent_for(number: int) -> int:
	if number <= 140: return 99+number
	if number <= 180: return 239+((number-139)>>1)
	return 259+((number-177)>>2)

## PO de la première victoire : 60 jusqu'au chapitre 10, puis +5 par chapitre (valeurs d'essai à confirmer).
static func reward_po(chapter: int) -> int:
	return 60+5*maxi(0,chapter-10)

## Texte des gains d'une mission : l'XP n'est affichée que si elle existe (aucune après la mission 100).
static func reward_text(po: int, xp: int, signed: bool = true) -> String:
	var plus: String = "+" if signed else ""
	return "%s%d PO · %s%d XP" % [plus,po,plus,xp] if xp > 0 else "%s%d PO" % [plus,po]

static func runtime(id: String) -> Dictionary:
	var data: Dictionary = definition(number_for(id))
	if data.is_empty() or not data.available: return {}
	var result: Dictionary = {"id":data.id,"po":data.po,"xp":data.xp,"waves":data.waves,"map_id":data.map_id,"hp_percent":data.hp_percent}
	if data.has("wave_set_id"): result.wave_set_id = data.wave_set_id
	if data.has("combat_affix"): result.combat_affix = data.combat_affix.duplicate(true)
	return result

static func unlocked(number: int, status: Dictionary) -> bool:
	var entry: Dictionary = definition(number)
	if entry.is_empty() or not entry.available or status.is_empty(): return false
	return number == 1 or status.missions[number-1] or status.missions[number-2]

static func suggested_mission(status: Dictionary) -> int:
	if status.is_empty(): return 1
	var last_available: int = 1
	for number in range(1,TOTAL_MISSIONS+1):
		if not unlocked(number,status): continue
		last_available = number
		if not status.missions[number-1]: return number
	return last_available

static func available_count() -> int:
	var total: int = 0
	for number in range(1,TOTAL_MISSIONS+1):
		if definition(number).available: total += 1
	return total
