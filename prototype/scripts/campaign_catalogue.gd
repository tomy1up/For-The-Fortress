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
	return result

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
