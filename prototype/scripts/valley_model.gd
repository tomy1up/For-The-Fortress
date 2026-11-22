extends RefCounted

const Campaign = preload("res://scripts/campaign_data.gd")
const Metrics = preload("res://scripts/combat_metrics.gd")
const Progression = preload("res://scripts/progression_data.gd")
const Enemies = preload("res://scripts/enemy_catalogue.gd")
const MetaTalents = preload("res://scripts/meta_talents.gd")
## Distances dans le plan logique du GDD, avant projection isométrique.

const Shop = preload("res://scripts/shop_catalogue.gd")
var auxiliary_type: int = -1
var auxiliary_base_cost: int = -1 # Coût historique de diagnostic ; jamais chargé depuis une sauvegarde joueur.
const Maps = preload("res://scripts/map_definition.gd")
const Routes = preload("res://scripts/route_geometry.gd")
# Alias conservés pour les outils et références historiques du Gué.
const PATH_POINTS: Array[Vector2] = Maps.VALLEY_PATH
const SLOTS: Array[Vector2] = Maps.VALLEY_SLOTS
const PATH_LENGTH: float = Maps.VALLEY_LENGTH
var map_definition: Dictionary
var map_error: String = ""
const Banks = preload("res://scripts/bank_encounters.gd")
const Drowned = preload("res://scripts/drowned_encounters.gd")
const Garrison = preload("res://scripts/garrison_encounters.gd")
const Eagle = preload("res://scripts/eagle_encounters.gd")
const Revenant = preload("res://scripts/revenant_encounters.gd")
var wave_set_id: String = "ford"
var route_target_policy: String = "arrival_time"
var protection_events: Array[Dictionary] = [] # Observation visuelle, aucun effet de jeu.
var explosion_events: Array[Dictionary] = [] # Explosions de réaction en chaîne (instant, position, rayon) : observation visuelle, aucun effet de jeu.
var enemy_hp_percent: int = 100
var combat_affix: Dictionary = {}
var eruption_next: int = 1 # Numéro de la prochaine éruption de la vague (affixe Éruptions).
var storm_next: int = 0 # Indice de la prochaine frontière de tempête de sable (début puis fin de chaque rafale).
var path_points: Array[Vector2] = []
var slots: Array[Vector2] = []
var path_length: float
var routes: Array[Dictionary] = []
const INITIAL_GOLD: int = 150
const INITIAL_HP: int = 20

const EPS: float = 0.000000001
const ROSTER: Array[Dictionary] = [
	{"name": "Archer elfe", "price": 50, "damage": 8.0, "interval": 1.0, "range": 4.0},
	{"name": "Arbalétrier nain", "price": 75, "damage": 24.0, "interval": 2.5, "range": 5.0},
	{"name": "Mage humain", "price": 100, "damage": 27.0, "interval": 2.5, "range": 3.5, "secondary_damage": 10.8, "secondary_cap": 2, "radius": 1.0},
	{"name": "Lanceur de haches troll", "short_name": "Lanceur de haches", "price": 50, "damage": 16.0, "interval": 2.0, "range": 3.5, "secondary_damage": 8.0, "secondary_cap": 1, "radius": 1.0},
	{"name": "Sapeur gobelin", "price": 75, "damage": 24.0, "interval": 2.5, "range": 3.0, "secondary_damage": 9.6, "secondary_cap": 3, "radius": 1.0},
	{"name": "Chaman orc", "price": 100, "damage": 12.0, "interval": 2.0, "range": 4.5, "curse_damage": 4.8},
	{"name":"Rôdeur elfe","price":60,"damage":6.0,"interval":0.7,"range":3.5},
	{"name":"Mousquetaire nain","price":90,"damage":38.0,"interval":4.0,"range":6.0},
	{"name":"Traqueur troll","price":65,"damage":10.0,"interval":1.25,"range":4.0,"secondary_damage":4.0,"secondary_cap":1,"radius":1.0},
	{"name":"Grenadier gobelin","price":75,"damage":18.0,"interval":2.0,"range":2.7,"secondary_damage":6.0,"secondary_cap":4,"radius":1.15},
	{"name":"Sentinelle elfe","price":60,"damage":6.5,"interval":1.6,"range":7.0},
	{"name":"Tireur d’élite elfe","price":95,"damage":64.0,"interval":5.0,"range":6.0},
	{"name":"Arquebusière naine","price":85,"damage":3.2,"interval":0.3,"range":3.0},
	{"name":"Bombardier nain","price":100,"damage":26.0,"interval":4.0,"range":4.0,"secondary_damage":18.0,"secondary_cap":5,"radius":1.6},
	{"name":"Piquier humain","price":55,"damage":14.0,"interval":1.2,"range":2.2},
	{"name":"Pyromancien humain","price":85,"damage":17.0,"interval":2.0,"range":4.0,"curse_damage":22.0},
	{"name":"Veilleur des cendres","price":70,"damage":6.0,"interval":1.6,"range":7.0},
	{"name":"Lanceur de javeline troll","price":105,"damage":56.0,"interval":4.5,"range":5.0},
	{"name":"Lance-éclats gobelin","price":85,"damage":3.5,"interval":0.35,"range":3.2},
	{"name":"Catapulte gobeline","price":100,"damage":23.0,"interval":4.2,"range":4.2,"secondary_damage":16.0,"secondary_cap":5,"radius":1.7},
	{"name":"Lance-épieu orc","price":55,"damage":15.0,"interval":1.3,"range":2.2},
	{"name":"Brûleur de cendres","price":105,"damage":5.0,"interval":2.0,"range":4.2,"curse_damage":7.2},
	{"name":"Mage de la foudre humain","price":85,"damage":13.0,"interval":1.8,"range":3.8,"secondary_damage":7.0,"secondary_cap":3,"radius":1.3},
	{"name":"Archer double","price":80,"damage":6.5,"interval":1.1,"range":4.0,"wounded_bonus":0.9},
	{"name":"Arbalète lourde","price":90,"damage":32.0,"interval":3.0,"range":4.5,"heavy_mult":1.8,"small_mult":0.5},
	{"name":"Fronde elfe","price":75,"damage":9.0,"interval":0.9,"range":4.5,"fast_mult":1.8,"heavy_mult":0.5},
	{"name":"Hache en chaîne","price":90,"damage":12.0,"interval":1.8,"range":3.5,"secondary_damage":7.5,"secondary_cap":3,"radius":1.3},
	{"name":"Lanceur double troll","price":80,"damage":6.2,"interval":1.1,"range":4.0,"wounded_bonus":0.85},
	{"name":"Lanceur de masse orc","price":100,"damage":32.0,"interval":3.2,"range":3.8,"heavy_mult":1.8,"small_mult":0.5},
	{"name":"Sarbacane gobeline","price":75,"damage":8.5,"interval":0.9,"range":4.5,"heavy_mult":0.5,"fast_mult":1.8},
	{"name":"Mage de givre","price":85,"damage":12.0,"interval":1.6,"range":4.2,"slow_seconds":3.0},
	{"name":"Éclaireur-observateur","price":60,"damage":3.0,"interval":1.5,"range":5.0,"mark_seconds":4.0,"mark_bonus":0.55},
	{"name":"Prêtre guerrier","price":80,"damage":9.0,"interval":2.0,"range":3.5,"aura_radius":4.2,"aura_bonus":0.4},
	{"name":"Chaman des marais","price":90,"damage":5.0,"interval":1.8,"range":4.2,"curse_damage":4.0,"slow_seconds":3.0},
	{"name":"Totem de guerre","price":60,"damage":3.0,"interval":1.5,"range":5.0,"mark_seconds":4.0,"mark_bonus":0.55},
	{"name":"Ancien des tribus","price":80,"damage":9.0,"interval":2.0,"range":3.5,"aura_radius":4.2,"aura_bonus":0.4},
	{"name":"Marchand mercenaire","price":70,"damage":8.0,"interval":1.8,"range":3.5,"loot_seconds":4.0,"loot_bonus":1.2},
	{"name":"Piégeur nain","price":80,"damage":22.0,"interval":2.4,"range":3.8,"entrance_mult":1.8,"exit_mult":0.4},
	{"name":"Balliste royale","price":95,"damage":36.0,"interval":3.5,"range":5.5,"entrance_mult":0.4,"exit_mult":1.8},
	{"name":"Alchimiste","price":90,"damage":6.0,"interval":2.0,"range":4.0,"volatile_seconds":4.0,"volatile_damage":80.0,"volatile_radius":1.4},
	{"name":"Vétéran royal","price":60,"damage":12.0,"interval":2.0,"range":4.0,"pivot_bonus":0.16},
	{"name":"Pillard gobelin","price":70,"damage":7.0,"interval":1.8,"range":3.5,"loot_seconds":4.0,"loot_bonus":1.2},
	{"name":"Poseur de mines","price":90,"damage":22.0,"interval":2.4,"range":3.8,"entrance_mult":1.8,"exit_mult":0.4},
	{"name":"Baliste de guerre","price":105,"damage":36.0,"interval":3.5,"range":5.5,"exit_mult":1.8,"entrance_mult":0.4},
	{"name":"Gobelin des braises","price":90,"damage":6.0,"interval":2.0,"range":4.0,"volatile_seconds":4.0,"volatile_damage":80.0,"volatile_radius":1.4},
	{"name":"Chef de guerre vétéran","price":60,"damage":11.0,"interval":2.0,"range":4.0,"pivot_bonus":0.16},
	{"name":"Fantassin squelette","price":40,"damage":6.0,"interval":0.6,"range":2.0},
	{"name":"Tirailleur gnome","price":45,"damage":6.0,"interval":0.65,"range":2.6},
]

const ENEMY_TYPES: Array[Dictionary] = [
	{"name": "Grouillant", "hp": 12.0, "speed": 1.15, "fortress_damage": 1, "reward": 1},
	{"name": "Pillard", "hp": 40.0, "speed": 1.0, "fortress_damage": 1, "reward": 3},
	{"name": "Sprinter", "hp": 24.0, "speed": 1.65, "fortress_damage": 1, "reward": 3},
	{"name": "Brute", "hp": 120.0, "speed": 0.7, "fortress_damage": 2, "reward": 7},
	{"name": "Maraudeur", "hp": 80.0, "speed": 1.2, "fortress_damage": 2, "reward": 6},
	{"name": "Colosse", "hp": 240.0, "speed": 0.5, "fortress_damage": 3, "reward": 14},
	{"name": "Élite", "hp": 360.0, "speed": 0.75, "fortress_damage": 4, "reward": 20},
	{"name": "Seigneur de siège", "hp": 600.0, "speed": 0.45, "fortress_damage": 20, "reward": 40},
]

var wave: int = 1
var max_hp: int = INITIAL_HP
var total_killed: int = 0
var total_escaped: int = 0
var arrivals_by_route: Dictionary = {}
var wave_arrivals_by_route: Dictionary = {}
var total_income: int = 0
var completed_time: float = 0.0
var bonuses: Array[int] = [] # indices 0..11 du catalogue R
var bonus_offer: Array[int] = []
var rng := RandomNumberGenerator.new()
var synergies_enabled: bool = true # Désactivé uniquement dans les références historiques de test.
var faction: int = 0
var meta_ranks: Array = MetaTalents.empty_ranks()
## Règles de la v0.222 (décisions du porteur, 16 novembre 2026), fausses pour rejouer un rapport plus ancien : les talents de l'arbre du Mage s'appliquent aussi aux dégâts sur la durée
## (dots) du Pyromancien humain ; le bonus « Exercice de tir » (R-02) profite aussi aux alternatives de boutique du chaman ; l'aura des gardiens porte à AURA_RADIUS.
var rules_v222: bool = true
## Règles de la v0.232 (extension du catalogue à 36 bonus, décision du porteur, 17 novembre 2026) : faux pour rejouer un rapport plus ancien, dont le tirage ne puise que dans les douze premiers bonus.
var rules_v232: bool = true
## Indices (code − 1) des bonus R-13 à R-36, valeurs et noms de prototype à confirmer.
const B_RAPID := 12
const B_SLOW := 13
const B_BARRAGE := 14
const B_CURSE := 15
const B_FAR := 16
const B_CLOSE := 17
const B_SUPPORT := 18
const B_GAMBLE := 19
const B_FRENZY := 20
const B_LONG := 21
const B_MARKET := 22
const B_FORTRESS := 23
const B_ELITE := 24
const B_TIGHT := 25
const B_LONE := 26
const B_MIXED := 27
const B_LAST := 28
const B_AMBUSH := 29
const B_FIRST := 30
const B_FINISH := 31
const B_MORALE := 32
const B_FASTHUNT := 33
const B_SMALLHUNT := 34
const B_LOOT := 35
## Règles de la v0.233 (second lot, décision du porteur, 21 novembre 2026) : rareté des offres (commun, rare, épique, plus de rares en fin de partie), une relance gratuite par partie,
## et 24 bonus rares et épiques (R-37 à R-60). Faux pour rejouer un rapport plus ancien (tirage uniforme parmi les 36 premiers bonus, sans relance).
var rules_v233: bool = true
const B_RUNIC := 36
const B_ECHO := 37
const B_TENACIOUS := 38
const B_CALTROPS := 39
const B_REPAIRS := 40
const B_TREASURE := 41
const B_INTEREST := 42
const B_PROMOTION := 43
const B_EXECUTE := 44
const B_GIANTS := 45
const B_GATE := 46
const B_COVER := 47
const B_DESPAIR := 48
const B_LEVY := 49
const B_HUNTMARK := 50
const B_BOUNTY := 51
const B_LASTSTAND := 52
const B_ELITEARMY := 53
const B_ASCENSION := 54
const B_BLOODLUST := 55
const B_BASTION := 56
const B_FIRESTORM := 57
const B_ROYAL := 58
const B_STASIS := 59
## Relances gratuites des offres de bonus par partie (règles v0.233).
const REROLLS_PER_RUN := 1
var rerolls_left: int = 0
var last_stand_used: bool = false # Dernier souffle (R-53) : une fois par partie.
var gate_wave: int = -1 # Herse (R-47) : vague où le premier passage a déjà été bloqué.
const AURA_RADIUS := 4.2 # plus petit rayon qui garantit un voisin sur chacune des 181 cartes de la campagne (distance maximale entre deux emplacements voisins : 4,12)
const LEGACY_AURA_RADIUS := 3.6
## Brûlure des unités à `curse_damage` hors famille du chaman (Pyromancien humain), appliquée depuis la v0.221 (décision du porteur, 16 novembre 2026) ; faux pour rejouer un ancien rapport.
var burn_for_all_curse_units: bool = true
var talent_rules: int = MetaTalents.Expanded.RULES_CURRENT # Jeu de règles des arbres de talents ; un autre jeu sert à rejouer un ancien rapport.
var next_instance_id: int = 0
var curses: Array[Dictionary] = []
var spawn_schedule: Array[Dictionary] = []
var gold: int = INITIAL_GOLD
var fortress_hp: int = INITIAL_HP
var elapsed: float = 0.0
var phase: String = "preparation"
var active: bool:
	get:
		return phase == "combat"
var spawned: int = 0
var killed: int = 0
var escaped: int = 0
var enemies: Array[Dictionary] = []
var defenders: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var damage_events: Array[Dictionary] = [] # Observation des pertes réelles, réservée au rendu.
var elimination_events: Array[Dictionary] = [] # Observation visuelle, sans effet de jeu.
var bought_waves: Dictionary = {} # Vague d'achat de chaque défenseur (instance_id), pour l'unité-pivot ; hors de l'état comparé des rapports.
var event_log: Array[String] = []
var wave_history: Array[Dictionary] = []
var _wave_record: Dictionary = {}
var action_history: Array[Dictionary] = []
var initial_rng_seed: String = ""
var initial_rng_state: String = ""

func _init(enable_synergies: bool = true, definition: Dictionary = {}) -> void:
	var source: Dictionary = Maps.valley() if definition.is_empty() else definition
	map_error = Maps.validation_error(source)
	map_definition = (source if map_error.is_empty() else Maps.valley()).duplicate(true)
	path_points.assign(map_definition.path_points)
	slots.assign(map_definition.slots)
	path_length = map_definition.path_length
	if map_definition.has("routes"): routes = Routes.network_copy(map_definition.routes)
	synergies_enabled = enable_synergies
	rng.randomize()
	reset()

func reset() -> void:
	auxiliary_base_cost = -1
	meta_ranks = MetaTalents.empty_ranks()
	action_history.clear()
	initial_rng_seed = ""
	initial_rng_state = ""
	wave_history.clear()
	_wave_record.clear()
	gold = INITIAL_GOLD
	faction = 0
	next_instance_id = 0
	curses.clear()
	wave = 1
	max_hp = INITIAL_HP
	total_killed = 0
	total_escaped = 0
	arrivals_by_route.clear()
	total_income = 0
	completed_time = 0.0
	bonuses.clear()
	bonus_offer.clear()
	rerolls_left = REROLLS_PER_RUN
	last_stand_used = false
	gate_wave = -1
	spawn_schedule = Campaign.schedule(wave,wave_set_id)
	fortress_hp = INITIAL_HP
	elapsed = 0.0
	phase = "preparation"
	spawned = 0
	killed = 0
	escaped = 0
	wave_arrivals_by_route.clear()
	enemies.clear()
	shots.clear()
	damage_events.clear()
	protection_events.clear()
	explosion_events.clear()
	elimination_events.clear()
	bought_waves.clear()
	event_log.clear()
	defenders.clear()
	for index in range(slots.size()):
		defenders.append({})
	if not map_error.is_empty(): phase = "invalid_map"

func available_types() -> Array[int]:
	var result: Array[int] = []
	result.assign([0,1,2] if faction == 0 else [3,4,5])
	var extra: Dictionary = Shop.for_type(auxiliary_type)
	if not extra.is_empty() and extra.faction == faction: result.append(auxiliary_type)
	return result

static func family(type: int) -> int:
	return Shop.family(type)

func configure_auxiliary(value: Variant) -> bool:
	if not (value is int or value is float) or not is_finite(float(value)) or value != floorf(float(value)): return false
	if int(value) != -1 and Shop.for_type(int(value)).is_empty(): return false
	if not action_history.is_empty() or phase != "preparation" or wave != 1 or gold != INITIAL_GOLD: return false
	auxiliary_type = int(value);auxiliary_base_cost = -1;return true

## Change l'unité de boutique de la mission après le choix de faction, tant que rien n'est acheté ni lancé (décision du porteur, 16 novembre 2026).
## Le rapport enregistre la configuration finale : le rejeu retrouve la même unité dès le départ.
func change_auxiliary(value: Variant) -> bool:
	if not (value is int or value is float) or not is_finite(float(value)) or value != floorf(float(value)): return false
	var type: int = int(value)
	if type != -1 and (Shop.for_type(type).is_empty() or Shop.for_type(type).faction != faction): return false
	if phase != "preparation" or wave != 1 or spawned != 0 or gold != INITIAL_GOLD or not bonuses.is_empty(): return false
	for kind in action_history:
		if kind.kind != "faction": return false
	for defender in defenders:
		if not defender.is_empty(): return false
	auxiliary_type = type;auxiliary_base_cost = -1;return true

func configure_auxiliary_cost(value: Variant) -> bool:
	if not (value is int or value is float) or not is_finite(float(value)) or value != floorf(float(value)) or value < 1 or value > 1000000: return false
	if auxiliary_type < 0 or not action_history.is_empty() or phase != "preparation" or wave != 1 or gold != INITIAL_GOLD: return false
	auxiliary_base_cost = int(value);return true

func base_recruit_cost(type: int) -> int:
	return auxiliary_base_cost if type == auxiliary_type and auxiliary_base_cost > 0 else int(ROSTER[type].price)

func select_faction(choice: int) -> bool:
	if choice not in [0, 1] or wave != 1 or not bonuses.is_empty() or phase != "preparation" or spawned != 0 or gold != INITIAL_GOLD:
		return false
	if auxiliary_type >= 0 and Shop.for_type(auxiliary_type).get("faction",-1) != choice: return false
	for defender in defenders:
		if not defender.is_empty():
			return false
	faction = choice
	max_hp = INITIAL_HP+MetaTalents.extra_hp(faction,meta_ranks)
	fortress_hp = max_hp
	_record_action("faction",{"faction":choice})
	return true

func _record_action(kind: String, details: Dictionary = {}) -> void:
	var entry: Dictionary = {"sequence":action_history.size()+1,"kind":kind,"wave":wave,"phase":phase,
		"combat_seconds":snappedf(completed_time+elapsed,0.000001),"gold":gold,"fortress_hp":fortress_hp}
	entry.merge(details.duplicate(true))
	action_history.append(entry)

## Limite des PV ennemis : 264 % jusqu'à la v0.231, 400 % depuis le rééquilibrage de la v0.232 (les anciens rapports restent valides).
const MAX_ENEMY_HP_PERCENT := 400

static func valid_enemy_hp_percent(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floorf(float(value)) and value >= 100 and value <= MAX_ENEMY_HP_PERCENT

func configure_combat_affix(value: Variant) -> bool:
	if not value is Dictionary or not action_history.is_empty() or phase != "preparation" or wave != 1 or gold != INITIAL_GOLD: return false
	if not value.is_empty():
		match value.get("id"):
			"headwinds":
				if value.size() != 2: return false
				var percent: Variant = value.get("cadence_percent")
				if not _whole_number(percent) or percent < 1 or percent > 100: return false
			"eruptions":
				# Intervalle entre deux éruptions, délai d'annonce et durée de désactivation, en secondes de combat.
				if value.size() != 4: return false
				var interval: Variant = value.get("interval");var warning: Variant = value.get("warning");var duration: Variant = value.get("duration")
				if not _whole_number(interval) or not _whole_number(warning) or not _whole_number(duration): return false
				if interval < 8 or interval > 40 or warning < 1 or warning > 4 or duration < 2 or duration > 12 or duration+warning+1 > interval: return false
			"sandstorm":
				# Tempête de sable : portée de tous les défenseurs réduite de `range_percent` % pendant `duration` s, toutes les `interval` s, annoncée `warning` s avant.
				if value.size() != 5: return false
				var s_interval: Variant = value.get("interval");var s_warning: Variant = value.get("warning");var s_duration: Variant = value.get("duration");var s_percent: Variant = value.get("range_percent")
				if not _whole_number(s_interval) or not _whole_number(s_warning) or not _whole_number(s_duration) or not _whole_number(s_percent): return false
				if s_interval < 10 or s_interval > 40 or s_warning < 1 or s_warning > 4 or s_duration < 2 or s_duration > 12 or s_percent < 5 or s_percent > 60 or s_duration+s_warning+1 > s_interval: return false
			"seamist":
				# Brume marine : l'or d'élimination est réduit de `gold_percent` % pendant `duration` s, toutes les `interval` s, annoncée `warning` s avant.
				if value.size() != 5: return false
				var m_interval: Variant = value.get("interval");var m_warning: Variant = value.get("warning");var m_duration: Variant = value.get("duration");var m_percent: Variant = value.get("gold_percent")
				if not _whole_number(m_interval) or not _whole_number(m_warning) or not _whole_number(m_duration) or not _whole_number(m_percent): return false
				if m_interval < 10 or m_interval > 40 or m_warning < 1 or m_warning > 4 or m_duration < 2 or m_duration > 12 or m_percent < 10 or m_percent > 60 or m_duration+m_warning+1 > m_interval: return false
			"rockfall":
				# Éboulement : une entrée est bloquée `duration` s toutes les `interval` s, annoncée `warning` s avant ; les apparitions prévues pendant ce temps passent par l'entrée suivante. Exige au moins deux entrées.
				if value.size() != 4 or routes.size() < 2: return false
				var r_interval: Variant = value.get("interval");var r_warning: Variant = value.get("warning");var r_duration: Variant = value.get("duration")
				if not _whole_number(r_interval) or not _whole_number(r_warning) or not _whole_number(r_duration): return false
				if r_interval < 10 or r_interval > 40 or r_warning < 1 or r_warning > 4 or r_duration < 2 or r_duration > 12 or r_duration+r_warning+1 > r_interval: return false
			_: return false
	combat_affix = value.duplicate(true)
	return true

static func _whole_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floorf(float(value))

func affix_description() -> String:
	match combat_affix.get("id",""):
		"headwinds": return "Vents contraires · −%d %% de cadence" % (100-int(combat_affix.cadence_percent))
		"eruptions": return "Éruptions · un défenseur désactivé %d s toutes les %d s" % [int(combat_affix.duration),int(combat_affix.interval)]
		"seamist": return "Brume marine · or d'élimination −%d %% pendant %d s toutes les %d s" % [int(combat_affix.gold_percent),int(combat_affix.duration),int(combat_affix.interval)]
		"rockfall": return "Éboulement · une entrée bloquée %d s toutes les %d s" % [int(combat_affix.duration),int(combat_affix.interval)]
		"sandstorm": return "Tempête de sable · portée −%d %% pendant %d s toutes les %d s" % [int(combat_affix.range_percent),int(combat_affix.duration),int(combat_affix.interval)]
	return ""

func affix_tooltip() -> String:
	match combat_affix.get("id",""):
		"headwinds": return "Tous les défenseurs attaquent 10 % moins souvent. Les dégâts périodiques déjà appliqués gardent leur rythme. Réglage d’essai."
		"seamist": return "Toutes les %d s de combat, une brume marine réduit de %d %% l'or gagné par élimination pendant %d s (arrondi à l'entier le plus proche, au moins 1 or). Elle est annoncée %d s avant. Réglage d’essai." % [int(combat_affix.interval),int(combat_affix.gold_percent),int(combat_affix.duration),int(combat_affix.warning)]
		"rockfall": return "Toutes les %d s de combat, un éboulement bloque une entrée pendant %d s : les ennemis qui devaient y apparaître passent par l'entrée suivante. L'entrée touchée est signalée %d s avant. Réglage d’essai." % [int(combat_affix.interval),int(combat_affix.duration),int(combat_affix.warning)]
		"sandstorm": return "Toutes les %d s de combat, une rafale de sable réduit de %d %% la portée de tous les défenseurs pendant %d s. Elle est annoncée %d s avant. Réglage d’essai." % [int(combat_affix.interval),int(combat_affix.range_percent),int(combat_affix.duration),int(combat_affix.warning)]
		"eruptions": return "Toutes les %d s de combat, un défenseur choisi au hasard parmi ceux en place est désactivé pendant %d s : il ne tire plus. Son emplacement est signalé %d s avant. Les dégâts périodiques déjà appliqués continuent. Réglage d’essai." % [int(combat_affix.interval),int(combat_affix.duration),int(combat_affix.warning)]
	return ""

func mist_enabled() -> bool:
	return combat_affix.get("id","") == "seamist"

## Instant de la vague (secondes de combat) où la brume numéro `number` (à partir de 1) se lève.
func mist_start_time(number: int) -> float:
	return float(combat_affix.interval)*number

func mist_active_now() -> bool:
	if not mist_enabled(): return false
	var number: int = int(floor((elapsed+EPS)/float(combat_affix.interval)))
	return number >= 1 and elapsed < mist_start_time(number)+float(combat_affix.duration)-EPS

## Or d'une élimination à l'instant courant : réduit pendant la brume, arrondi à l'entier le plus proche, au moins 1 or.
func kill_reward(base: int) -> int:
	if not mist_active_now(): return base
	return maxi(1,roundi(float(base)*(100.0-float(combat_affix.gold_percent))/100.0))

## État observé par l'interface : {} hors combat, sinon l'avertissement ("warning") ou la brume en cours ("active").
func mist_status() -> Dictionary:
	if not mist_enabled() or not active: return {}
	var interval: float = float(combat_affix.interval)
	var number: int = int(floor((elapsed+EPS)/interval))
	if number >= 1 and elapsed < mist_start_time(number)+float(combat_affix.duration)-EPS:
		return {"state":"active","number":number,"remaining":mist_start_time(number)+float(combat_affix.duration)-elapsed}
	var upcoming: int = number+1
	if elapsed >= mist_start_time(upcoming)-float(combat_affix.warning)-EPS:
		return {"state":"warning","number":upcoming,"remaining":mist_start_time(upcoming)-elapsed}
	return {}

func rockfall_enabled() -> bool:
	return combat_affix.get("id","") == "rockfall"

## Instant de la vague (secondes de combat) où l'éboulement numéro `number` (à partir de 1) bloque son entrée.
func rockfall_time(number: int) -> float:
	return float(combat_affix.interval)*number

## Entrée bloquée à l'instant `time` de la vague `wave_number` ("" si aucune) : l'éboulement n tombe sur l'entrée (n + vague) modulo le nombre d'entrées.
func rockfall_blocked_route(time: float, wave_number: int) -> String:
	if not rockfall_enabled() or routes.size() < 2: return ""
	var number: int = int(floor((time+EPS)/float(combat_affix.interval)))
	if number < 1 or time >= rockfall_time(number)+float(combat_affix.duration)-EPS: return ""
	return str(routes[(number+wave_number)%routes.size()].id)

## État observé par l'interface : {} hors combat, sinon l'avertissement ("warning") ou le blocage en cours ("active") avec l'entrée touchée.
func rockfall_status() -> Dictionary:
	if not rockfall_enabled() or not active: return {}
	var interval: float = float(combat_affix.interval)
	var number: int = int(floor((elapsed+EPS)/interval))
	if number >= 1 and elapsed < rockfall_time(number)+float(combat_affix.duration)-EPS:
		return {"state":"active","number":number,"route_id":str(routes[(number+wave)%routes.size()].id),"remaining":rockfall_time(number)+float(combat_affix.duration)-elapsed}
	var upcoming: int = number+1
	if elapsed >= rockfall_time(upcoming)-float(combat_affix.warning)-EPS:
		return {"state":"warning","number":upcoming,"route_id":str(routes[(upcoming+wave)%routes.size()].id),"remaining":rockfall_time(upcoming)-elapsed}
	return {}

func eruption_enabled() -> bool:
	return combat_affix.get("id","") == "eruptions"

## Tempête de sable (affixe) : rafales régulières qui réduisent la portée de tous les défenseurs.
func storm_enabled() -> bool:
	return combat_affix.get("id","") == "sandstorm"

func storm_start_time(number: int) -> float:
	return float(combat_affix.interval)*number

## Frontières de rafale : indice 2k = début de la rafale k+1, 2k+1 = sa fin.
func storm_boundary_time(index: int) -> float:
	var number: int = index/2+1
	return storm_start_time(number)+(float(combat_affix.duration) if index%2 == 1 else 0.0)

## Vrai pendant une rafale (instant de combat courant) ; la portée est alors réduite.
func storm_active_now() -> bool:
	if not storm_enabled(): return false
	var number: int = int(floor((elapsed+EPS)/float(combat_affix.interval)))
	return number >= 1 and elapsed < storm_start_time(number)+float(combat_affix.duration)-EPS

## Coefficient de portée en vigueur : 1 hors rafale, 1 − pourcentage pendant la rafale.
func range_factor_now() -> float:
	return 1.0-float(combat_affix.range_percent)/100.0 if storm_active_now() else 1.0

## État observé par l'interface : {} hors combat, sinon l'avertissement ("warning") ou la rafale en cours ("active").
func storm_status() -> Dictionary:
	if not storm_enabled() or not active: return {}
	var interval: float = float(combat_affix.interval)
	var number: int = int(floor((elapsed+EPS)/interval))
	if number >= 1 and elapsed < storm_start_time(number)+float(combat_affix.duration)-EPS:
		return {"state":"active","number":number,"remaining":storm_start_time(number)+float(combat_affix.duration)-elapsed}
	var upcoming: int = number+1
	if elapsed >= storm_start_time(upcoming)-float(combat_affix.warning)-EPS:
		return {"state":"warning","number":upcoming,"remaining":storm_start_time(upcoming)-elapsed}
	return {}

## Instant de la vague (secondes de combat) où l'éruption numéro `number` désactive son défenseur.
func eruption_time(number: int) -> float:
	return float(combat_affix.interval)*number

# Tirage déterministe, sans toucher au générateur du combat : mêmes éruptions quel que soit le pas de temps et au rejeu.
func _eruption_roll(number: int) -> int:
	var value: int = posmod(int(initial_rng_seed),2147483629)+wave*7919+number*104729
	for round in range(3):
		value = ((value >> 16) ^ value)*73244475 & 0xFFFFFFFF
	return (value >> 16) ^ value

## Emplacement frappé par l'éruption `number` : un défenseur en place, tiré au sort ; -1 sans défenseur.
func eruption_slot(number: int) -> int:
	var occupied: Array[int] = []
	for slot in range(defenders.size()):
		if not defenders[slot].is_empty(): occupied.append(slot)
	return -1 if occupied.is_empty() else occupied[_eruption_roll(number)%occupied.size()]

## État observé par l'interface : {} hors combat, sinon l'éruption annoncée ("warning") ou en cours ("active").
func eruption_status() -> Dictionary:
	if not eruption_enabled() or not active: return {}
	var interval: float = float(combat_affix.interval)
	var number: int = int(floor(elapsed/interval+EPS))
	if number >= 1 and elapsed < eruption_time(number)+float(combat_affix.duration)-EPS:
		var struck: int = eruption_slot(number)
		if struck >= 0: return {"slot":struck,"state":"active","number":number,"remaining":eruption_time(number)+float(combat_affix.duration)-elapsed}
	var upcoming: int = number+1
	if elapsed >= eruption_time(upcoming)-float(combat_affix.warning)-EPS:
		var announced: int = eruption_slot(upcoming)
		if announced >= 0: return {"slot":announced,"state":"warning","number":upcoming,"remaining":eruption_time(upcoming)-elapsed}
	return {}

func configure_enemy_hp(value: Variant) -> bool:
	if not valid_enemy_hp_percent(value) or not action_history.is_empty() or phase != "preparation" or gold != INITIAL_GOLD: return false
	enemy_hp_percent = int(value);return true

func configure_wave_set(value: Variant) -> bool:
	if not Banks.valid_set(value) or not action_history.is_empty() or phase != "preparation" or wave != 1 or gold != INITIAL_GOLD: return false
	wave_set_id = value;spawn_schedule = Campaign.schedule(wave,wave_set_id);return true

static func enemy_definition(type: int) -> Dictionary:
	return Banks.GUARD if type == Banks.GUARD_TYPE else Drowned.DEFINITION if type == Drowned.TYPE else Garrison.DEFINITION if type == Garrison.TYPE else Eagle.DEFINITION if type == Eagle.TYPE else Revenant.DEFINITION if type == Revenant.TYPE else ENEMY_TYPES[type]

static func scaled_enemy_hp(type: int, percent: int = 100) -> float:
	return float(enemy_definition(type).hp) if percent == 100 else float(enemy_definition(type).hp)*(float(percent)/100.0)

static func make_enemy(id: int, type: int, spawn_time: float, defending_faction: int = -1, hp_percent: int = 100) -> Dictionary:
	var definition: Dictionary = enemy_definition(type)
	var enemy: Dictionary = {"id": id, "type": type, "spawn_time": spawn_time, "distance": 0.0,
		"hp": scaled_enemy_hp(type,hp_percent), "max_hp": scaled_enemy_hp(type,hp_percent), "speed": definition.speed,
		"fortress_damage": definition.fortress_damage, "reward": definition.reward}
	if defending_faction != -1:
		var identity: Dictionary = Enemies.for_profile(type,defending_faction)
		if identity.is_empty(): return {}
		enemy.merge({"identity_id":identity.id,"name":identity.name,"origin":identity.origin})
	return enemy

static func wave_forecast(number: int, defending_faction: int = -1, hp_percent: int = 100, set_id: String = "ford") -> Dictionary:
	if not Banks.valid_set(set_id): return {}
	if number < 1 or number > Campaign.WAVES.size() or not valid_enemy_hp_percent(hp_percent): return {}
	if defending_faction != -1 and defending_faction not in [0,1]: return {}
	var schedule: Array[Dictionary] = Campaign.schedule(number,set_id)
	var groups: Array[Dictionary] = []
	var offset: int = 0
	var income: int = 0
	for source in Campaign.waves_for(set_id)[number-1]:
		var type: int = source[0]
		var count: int = source[1]
		var enemy: Dictionary = enemy_definition(type)
		groups.append({"type":type,"count":count,"name":enemy.name,"hp":scaled_enemy_hp(type,hp_percent),"fortress_damage":enemy.fortress_damage,"reward":enemy.reward,"interval":source[2],"first_at":schedule[offset].time,"last_at":schedule[offset+count-1].time})
		if defending_faction != -1:
			var identity: Dictionary = Enemies.for_profile(type,defending_faction)
			groups[-1].merge({"name":identity.name,"identity_id":identity.id,"origin":identity.origin},true)
		income += count*enemy.reward
		offset += count
	return {"wave":number,"groups":groups,"total":schedule.size(),"income":income}

func spawn_route_id(index: int, entry: Dictionary, forecast_wave: int = -1) -> String:
	if routes.is_empty(): return ""
	if entry.has("route_id"): return str(entry.route_id)
	var number := wave if forecast_wave < 0 else forecast_wave
	var route_index := index%routes.size()
	if number > 1 and map_definition.get("route_pattern") == "alternating_pressure":
		var preferred := number%2
		route_index = 1-preferred if index%3 == 2 else preferred
	if rockfall_enabled() and entry.has("time") and routes[route_index].id == rockfall_blocked_route(float(entry.time),number): route_index = (route_index+1)%routes.size()
	return routes[route_index].id

func forecast_for_routes(number: int) -> Dictionary:
	var data: Dictionary = wave_forecast(number,faction,enemy_hp_percent,wave_set_id)
	if data.is_empty() or routes.is_empty(): return data
	var indices: Dictionary = {}
	data.entries = []
	for index in range(routes.size()):
		indices[routes[index].id] = index
		data.entries.append({"route_id":routes[index].id,"number":index+1,"count":0,"first_at":-1.0,"last_at":-1.0})
	var schedule: Array[Dictionary] = Campaign.schedule(number,wave_set_id)
	var offset: int = 0
	for group in data.groups:
		var allocations: Array[Dictionary] = []
		for entry in data.entries:
			allocations.append({"route_id":entry.route_id,"number":entry.number,"count":0,"first_at":-1.0,"last_at":-1.0})
		for index in range(offset,offset+group.count):
			var route_id: String = spawn_route_id(index,schedule[index],number)
			if not indices.has(route_id): return {}
			for allocation in [data.entries[indices[route_id]],allocations[indices[route_id]]]:
				if allocation.count==0: allocation.first_at=schedule[index].time
				allocation.count+=1
				allocation.last_at=schedule[index].time
		group.entries=allocations.filter(func(entry: Dictionary)->bool:return entry.count>0)
		offset+=group.count
	return data

func can_build() -> bool:
	return phase == "preparation" or phase == "finished"

func count_type(type: int) -> int:
	var count: int = 0
	for defender in defenders:
		if not defender.is_empty() and defender.type == type:
			count += 1
	return count

func purchase_error(slot: int, type: int) -> String:
	if not can_build():
		return "Achats possibles uniquement entre les vagues."
	if slot < 0 or slot >= slots.size():
		return "Sélectionnez un emplacement."
	if type < 0 or type >= ROSTER.size():
		return "Défenseur inconnu."
	if type not in available_types():
		if Shop.for_type(type).get("faction",-1) == faction: return "Cette alternative n’a pas été choisie pour la mission."
		return "Ce défenseur appartient à l’autre faction."
	if not defenders[slot].is_empty():
		return "Cet emplacement est occupé."
	if count_type(type) >= 2:
		return "Deux exemplaires de ce type sont déjà déployés."
	if gold < purchase_cost(type):
		return "Or insuffisant."
	return ""

func buy(slot: int, type: int) -> bool:
	if not purchase_error(slot, type).is_empty():
		return false
	var stats: Dictionary = ROSTER[type]
	defenders[slot] = {"instance_id": next_instance_id, "type": type, "level": 1, "branch": -1, "paid": purchase_cost(type), "ready_at": 0.0,
		"windows": coverage_windows(slots[slot], stats.range, path_points)}
	bought_waves[defenders[slot].instance_id] = wave
	next_instance_id += 1
	gold -= purchase_cost(type)
	_refresh_windows()
	_record_action("buy",{"slot":slot,"type":type,"instance_id":defenders[slot].instance_id,"cost":defenders[slot].paid})
	return true

static func stats_for(type: int, level: int = 1, branch: int = -1) -> Dictionary:
	var stats: Dictionary = ROSTER[type].duplicate(true)
	var multiplier: float = Progression.DAMAGE_MULTIPLIERS[level - 1]
	stats.damage *= multiplier
	stats.secondary_damage = stats.get("secondary_damage", 0.0) * multiplier
	stats.curse_damage = stats.get("curse_damage", 0.0) * multiplier
	stats.secondary_cap = stats.get("secondary_cap", 0)
	stats.radius = stats.get("radius", 1.0)
	stats.branch_name = ""
	if level == 4 and branch in [0, 1]:
		var specialization: Dictionary = Progression.BRANCHES[type * 2 + branch] if type < 6 else Shop.BRANCHES[type][branch]
		for key in specialization:
			if key == "name":
				stats.branch_name = specialization.name
			else:
				stats[key] = specialization[key]
	return stats

func synergy_partners(slot: int, rule: Dictionary, branch_override: int = -1, candidate: Dictionary = {}) -> Array[int]:
	var partners: Array[int] = []
	if not synergies_enabled or slot < 0 or slot >= defenders.size(): return partners
	var unit: Dictionary = defenders[slot] if candidate.is_empty() else candidate
	if unit.is_empty(): return partners
	var side: int = rule.types.find(family(unit.type))
	if side < 0: return partners
	var specialised: bool = rule.has("branches")
	var level: int = 4 if branch_override >= 0 else unit.level
	var branch: int = branch_override if branch_override >= 0 else unit.branch
	if specialised and (level != 4 or branch != rule.branches[side]): return partners
	for other_slot in range(defenders.size()):
		var partner: Dictionary = defenders[other_slot]
		if other_slot == slot or partner.is_empty() or family(partner.type) != rule.types[1-side]: continue
		if specialised:
			if partner.level != 4 or partner.branch != rule.branches[1-side]: continue
		elif slots[slot].distance_squared_to(slots[other_slot]) > 25.0: continue
		partners.append(other_slot)
	return partners

func synergy_effects(slot: int, branch_override: int = -1, candidate: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0,"codes":[]}
	for rule in Campaign.PROXIMITY + Campaign.SPECIALISATIONS:
		if synergy_partners(slot, rule, branch_override, candidate).is_empty(): continue
		var side: int = rule.types.find(family((defenders[slot] if candidate.is_empty() else candidate).type))
		for i in range(4):
			result[["direct","secondary","curse","range"][i]] += rule.effects[side][i]
		result.codes.append(rule.code) # Un même code une seule fois, même avec plusieurs partenaires.
	return result

func purchase_preview_stats(slot: int, type: int) -> Dictionary:
	# Requête seule : ni recrutement, ni paiement, ni changement des unités ou du générateur.
	if slot < 0 or slot >= defenders.size() or not defenders[slot].is_empty() or type not in available_types(): return {}
	return get_stats(slot, -1, {"type":type,"level":1,"branch":-1})

func upgrade_preview_stats(slot: int, branch: int = -1) -> Dictionary:
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty(): return {}
	if defenders[slot].type not in available_types(): return {}
	var candidate: Dictionary = defenders[slot].duplicate(true)
	if candidate.level >= 4 or (candidate.level == 3 and branch not in [0,1]) or (candidate.level < 3 and branch != -1): return {}
	candidate.level += 1
	if candidate.level == 4: candidate.branch = branch
	return get_stats(slot, -1, candidate)

func get_stats(slot: int, branch_override: int = -1, candidate: Dictionary = {}) -> Dictionary:
	return _stats_with_bonuses(slot,branch_override,candidate,bonuses)

func _stats_with_bonuses(slot: int, branch_override: int, candidate: Dictionary, active_bonuses: Array) -> Dictionary:
	if slot < 0 or slot >= defenders.size(): return {}
	var defender: Dictionary = defenders[slot] if candidate.is_empty() else candidate
	if defender.is_empty(): return {}
	var level: int = 4 if branch_override >= 0 else defender.get("level",1)
	var stats: Dictionary = stats_for(defender.type,level,branch_override if branch_override >= 0 else defender.get("branch",-1))
	stats.price = base_recruit_cost(defender.type)
	var synergy: Dictionary = synergy_effects(slot,branch_override,candidate)
	var meta: Dictionary = MetaTalents.effects(faction,meta_ranks,defender.type,talent_rules)
	# Dégâts sur la durée du Pyromancien : ils progressent avec les talents d'explosion du Mage (v0.222).
	if rules_v222 and float(meta.curse) == 0.0 and family(defender.type) == 2 and float(ROSTER[defender.type].get("curse_damage",0.0)) > 0.0: meta.curse = float(meta.secondary)
	var extra_bonus: Dictionary = _extra_bonus_effects(slot,defender,level,active_bonuses)
	var common: float = (0.10 if 0 in active_bonuses else 0.0) + (0.15 if 6 in active_bonuses and level <= 2 else 0.0) + (0.12 if 7 in active_bonuses and level >= 3 else 0.0) + guardian_aura(slot,active_bonuses) + pivot_bonus(defender) + float(extra_bonus.common)
	stats.reference_damage = stats.damage
	stats.reference_secondary = stats.secondary_damage
	stats.reference_curse = stats.curse_damage
	stats.direct_bonus = common + synergy.direct + meta.direct + (0.15 if 5 in active_bonuses else 0.0)
	stats.secondary_bonus = common + synergy.secondary + meta.secondary + (0.20 if 3 in active_bonuses and family(defender.type) in [2,3,4] else 0.0) + float(extra_bonus.secondary)
	stats.curse_bonus = common + synergy.curse + meta.curse + float(extra_bonus.curse)
	stats.damage = stats.reference_damage * (1.0+stats.direct_bonus)
	stats.secondary_damage = stats.reference_secondary * (1.0+stats.secondary_bonus)
	stats.curse_damage = stats.reference_curse * (1.0+stats.curse_bonus)
	stats.range += synergy.range + meta.range + (0.5 if 2 in active_bonuses else 0.0)
	if 1 in active_bonuses and (family(defender.type) != 5 or (rules_v222 and defender.type >= 6)): stats.interval /= 1.12 # v0.222 : les alternatives de boutique du chaman en profitent
	if combat_affix.get("id","") == "headwinds": stats.interval /= float(combat_affix.cadence_percent)/100.0
	if 4 in active_bonuses and family(defender.type) in [2,3,4]: stats.radius += 0.2
	if float(extra_bonus.range) != 0.0: stats.range = maxf(1.0,stats.range+float(extra_bonus.range))
	if float(extra_bonus.rate) != 1.0: stats.interval /= float(extra_bonus.rate)
	if int(extra_bonus.cap) > 0 and int(stats.secondary_cap) > 0:
		stats.secondary_cap += int(extra_bonus.cap)
		stats.radius += float(extra_bonus.radius) # Pluie de feu (R-58) : rayon et distance de rebond des unités à effet de zone
	if float(extra_bonus.support) != 1.0:
		for key in ["mark_bonus","loot_bonus","volatile_damage","slow_seconds"]:
			if stats.has(key): stats[key] = float(stats[key])*float(extra_bonus.support)
	if float(extra_bonus.slow) != 1.0 and stats.has("slow_seconds"): stats.slow_seconds = float(stats.slow_seconds)*float(extra_bonus.slow) # Temps suspendu (R-60)
	stats.synergies = synergy.codes
	return stats

## Effets des bonus R-13 à R-36 sur un défenseur (règles v0.232) : gain commun à tous les dégâts, gain de malédiction, portée, cadence (facteur), cibles secondaires et force des soutiens.
## Les rôles se lisent sur les valeurs de base du roster, jamais sur les valeurs déjà modifiées.
func _extra_bonus_effects(slot: int, defender: Dictionary, level: int, active_bonuses: Array) -> Dictionary:
	var result: Dictionary = {"common":0.0,"curse":0.0,"range":0.0,"rate":1.0,"cap":0,"support":1.0,"secondary":0.0,"radius":0.0,"slow":1.0}
	var any: bool = false
	for code in active_bonuses:
		if code >= Campaign.LEGACY_BONUS_COUNT:
			any = true
			break
	if not any: return result
	var reference: Dictionary = ROSTER[defender.type]
	var base_interval: float = float(reference.interval)
	var base_range: float = float(reference.range)
	var common: float = 0.0
	if B_RAPID in active_bonuses and base_interval <= 1.3+EPS: common += 0.25
	if B_SLOW in active_bonuses and base_interval >= 2.4-EPS: common += 0.25
	if B_BARRAGE in active_bonuses: result.cap += 1
	if B_CURSE in active_bonuses and float(reference.get("curse_damage",0.0)) > 0.0: result.curse = 0.35
	if B_FAR in active_bonuses and base_range >= 4.5-EPS: common += 0.20
	if B_CLOSE in active_bonuses and base_range <= 3.6+EPS: common += 0.25
	if B_SUPPORT in active_bonuses and (reference.has("aura_bonus") or reference.has("mark_bonus") or reference.has("slow_seconds") or reference.has("loot_bonus") or reference.has("volatile_damage")): result.support = 1.3
	if B_GAMBLE in active_bonuses: common += 0.30
	if B_FRENZY in active_bonuses:
		result.rate *= 1.25
		result.range -= 0.5
	if B_LONG in active_bonuses:
		result.range += 1.0
		common -= 0.10
	if B_FORTRESS in active_bonuses: common -= 0.10
	if B_ELITE in active_bonuses: common += 0.30 if level >= 3 else -0.10
	if B_MORALE in active_bonuses: common += 0.02*float(maxi(0,wave-1))
	if B_TIGHT in active_bonuses or B_LONE in active_bonuses or B_MIXED in active_bonuses:
		var nearest: float = INF
		var types: Array[int] = [int(defender.type)]
		for other in range(defenders.size()):
			if other == slot or defenders[other].is_empty(): continue
			nearest = minf(nearest,slots[slot].distance_to(slots[other]))
			if int(defenders[other].type) not in types: types.append(int(defenders[other].type))
		if B_TIGHT in active_bonuses and nearest <= 3.0+EPS: common += 0.15
		if B_LONE in active_bonuses and nearest > 4.2+EPS:
			common += 0.25
			result.range += 0.5
		if B_MIXED in active_bonuses: common += 0.05*float(mini(4,types.size()))
	# Rares et épiques (règles v0.233).
	var group: bool = int(reference.get("secondary_cap",0)) > 0
	if B_RUNIC in active_bonuses:
		common += 0.20
		result.rate *= 1.10
	if B_ECHO in active_bonuses:
		result.cap += 2
		if group: result.secondary += 0.25
	if B_COVER in active_bonuses and base_range >= 4.5-EPS:
		common += 0.15
		result.range += 1.0
	if B_DESPAIR in active_bonuses: common += minf(0.45,0.03*float(maxi(0,max_hp-fortress_hp)))
	if B_ELITEARMY in active_bonuses:
		common += 0.35
		result.rate *= 1.20
	if B_BLOODLUST in active_bonuses: common += minf(0.50,0.01*float(total_killed))
	if B_FIRESTORM in active_bonuses:
		result.cap += 2
		result.radius += 0.5
		if group: result.secondary += 0.40
	if B_STASIS in active_bonuses: result.slow = 1.5
	result.common = common
	return result

## Unité-pivot : +`pivot_bonus` par vague survivée depuis son achat, plafonné à +90 %.
func pivot_bonus(defender: Dictionary) -> float:
	var per: float = float(ROSTER[defender.type].get("pivot_bonus",0.0))
	if per <= 0.0 or not bought_waves.has(defender.get("instance_id",-1)): return 0.0
	return minf(0.9,per*float(maxi(0,wave-int(bought_waves[defender.instance_id]))))

## Bonus de dégâts reçu des gardiens voisins (unités à `aura_bonus`) : ceux qui se trouvent à `aura_radius` de l'emplacement, sans compter l'unité elle-même.
func guardian_aura(slot: int, active_bonuses: Variant = null) -> float:
	var bonus := 0.0
	var strength: float = 1.3 if B_SUPPORT in (bonuses if active_bonuses == null else active_bonuses) else 1.0
	for other in range(defenders.size()):
		if other == slot or defenders[other].is_empty(): continue
		var guard: Dictionary = ROSTER[defenders[other].type]
		if float(guard.get("aura_bonus",0.0)) > 0.0 and slots[slot].distance_to(slots[other]) <= (float(guard.get("aura_radius",0.0)) if rules_v222 else LEGACY_AURA_RADIUS)+EPS: bonus += float(guard.aura_bonus)*strength
	return bonus

func damage_for(stats: Dictionary, component: String, victim: Dictionary) -> float:
	return _damage_with_bonuses(stats,component,victim,bonuses)

## Types d'ennemis lourds, petits et rapides pour les règles des unités de boutique (valeurs de prototype à confirmer).
const HEAVY_ENEMY_TYPES: Array[int] = [3,5,6,7,10]
const SMALL_ENEMY_TYPES: Array[int] = [0,1,2,4,11]
const FAST_ENEMY_TYPES: Array[int] = [0,2,4,11]

## Multiplicateur propre à l'unité selon la cible, sur le tir direct : ennemi déjà blessé, lourd, petit ou rapide.
static func target_multiplier(stats: Dictionary, victim: Dictionary) -> float:
	var multiplier := 1.0
	var kind: int = int(victim.get("type",1))
	if kind in HEAVY_ENEMY_TYPES: multiplier *= float(stats.get("heavy_mult",1.0))
	if kind in SMALL_ENEMY_TYPES: multiplier *= float(stats.get("small_mult",1.0))
	if kind in FAST_ENEMY_TYPES: multiplier *= float(stats.get("fast_mult",1.0))
	if float(victim.get("hp",0.0)) < float(victim.get("max_hp",0.0))-EPS: multiplier *= 1.0+float(stats.get("wounded_bonus",0.0))
	return multiplier

## Multiplicateur selon l'avancée de la cible sur sa route (sapeur d'entrée, tourelle de forteresse) : près de l'entrée (moins de 35 % du trajet) ou près de la forteresse (plus de 65 %).
func progress_multiplier(stats: Dictionary, victim: Dictionary) -> float:
	if not stats.has("entrance_mult") and not stats.has("exit_mult"): return 1.0
	if not victim.has("distance"): return 1.0
	var length: float = enemy_route_length(victim) if victim.has("route_id") or routes.is_empty() else path_length
	if length <= 0.0: return 1.0
	var fraction: float = float(victim.distance)/length
	if fraction < 0.35: return float(stats.get("entrance_mult",1.0))
	if fraction > 0.65: return float(stats.get("exit_mult",1.0))
	return 1.0

func _damage_with_bonuses(stats: Dictionary, component: String, victim: Dictionary, active_bonuses: Array) -> float:
	var reference: float = stats[{"direct":"reference_damage","secondary":"reference_secondary","curse":"reference_curse"}[component]]
	var extra: float = 0.20 if 11 in active_bonuses and victim.type in [3,5,6,7] else 0.0
	extra += _victim_bonus(component,victim,active_bonuses)
	var marked: float = 1.0+float(victim.get("mark_bonus",0.0)) if float(victim.get("marked_until",-1.0)) > elapsed+EPS and float(stats.get("mark_seconds",0.0)) <= 0.0 else 1.0
	return reference * (1.0+stats[component+"_bonus"]+extra) * ((target_multiplier(stats,victim)*progress_multiplier(stats,victim)) if component == "direct" else 1.0) * marked

## Gains des bonus R-29 à R-35 qui dépendent de la cible (règles v0.232) : position sur la route, PV restants, rapidité et taille. Sans effet sur une cible factice (aperçu), qui n'a ni position ni PV.
func _victim_bonus(component: String, victim: Dictionary, active_bonuses: Array) -> float:
	var extra: float = 0.0
	var any: bool = false
	for code in active_bonuses:
		if code >= B_LAST:
			any = true
			break
	if not any: return extra
	if (B_LAST in active_bonuses or B_AMBUSH in active_bonuses) and victim.has("distance"):
		var length: float = enemy_route_length(victim) if victim.has("route_id") or routes.is_empty() else path_length
		if length > 0.0:
			var fraction: float = float(victim.distance)/length
			if B_LAST in active_bonuses and fraction > 0.65: extra += 0.25
			if B_AMBUSH in active_bonuses and fraction < 0.35: extra += 0.25
	if victim.has("hp") and victim.has("max_hp"):
		if B_FIRST in active_bonuses and component == "direct" and float(victim.hp) >= float(victim.max_hp)-EPS: extra += 0.25
		if B_FINISH in active_bonuses and float(victim.hp) < 0.5*float(victim.max_hp)-EPS: extra += 0.30
	if B_FASTHUNT in active_bonuses and int(victim.get("type",-1)) in FAST_ENEMY_TYPES: extra += 0.30
	if B_SMALLHUNT in active_bonuses and int(victim.get("type",-1)) in SMALL_ENEMY_TYPES: extra += 0.25
	if B_GIANTS in active_bonuses and int(victim.get("type",-1)) in HEAVY_ENEMY_TYPES: extra += 0.40 # Tueur de géants (R-46), boss compris
	return extra

func _refresh_windows() -> void:
	for slot in range(defenders.size()):
		if not defenders[slot].is_empty():
			defenders[slot].windows = coverage_windows(slots[slot], get_stats(slot).range, path_points)
			if not routes.is_empty(): defenders[slot].route_windows = Routes.network_coverage(slots[slot],get_stats(slot).range,routes)
			if storm_enabled():
				var reduced: float = get_stats(slot).range*(1.0-float(combat_affix.range_percent)/100.0)
				defenders[slot].storm_windows = coverage_windows(slots[slot], reduced, path_points)
				if not routes.is_empty(): defenders[slot].storm_route_windows = Routes.network_coverage(slots[slot],reduced,routes)

func purchase_cost(type: int) -> int:
	return _discounted_cost(base_recruit_cost(type),10,bonuses)

func _discounted_cost(base: float, discount_code: int, active_bonuses: Array) -> int:
	if B_LEVY in active_bonuses or B_ROYAL in active_bonuses:
		# Levée en masse (R-50, −30 %) et Fortune royale (R-59, −20 %) : achats et améliorations ; multipliés avec R-10, R-11 et R-23. Arrondi supérieur.
		var reduced: float = (0.9 if discount_code in active_bonuses else 1.0)*(0.7 if B_LEVY in active_bonuses else 1.0)*(0.8 if B_ROYAL in active_bonuses else 1.0)
		if B_MARKET in active_bonuses: reduced *= 0.75 if discount_code == 10 else 1.15
		return maxi(1,int(ceil(base*reduced-0.000000001)))
	if B_MARKET in active_bonuses:
		# Marché noir (R-23) : achats −25 %, améliorations +15 % ; marge d'un milliardième contre les erreurs d'arrondi des flottants.
		var factor: float = (0.9 if discount_code in active_bonuses else 1.0)*(0.75 if discount_code == 10 else 1.15)
		return maxi(1,int(ceil(base*factor-0.000000001)))
	return maxi(1,int(ceil(base * (0.9 if discount_code in active_bonuses else 1.0))))

func bonus_preview(code: int) -> Dictionary:
	# Lecture seule : aucun choix, soin, paiement, recalcul de fenêtres ou tirage.
	if code < 0 or code >= Campaign.BONUSES.size() or code in bonuses: return {}
	var projected: Array = bonuses.duplicate()
	projected.append(code)
	var units: Array[Dictionary] = []
	for slot in range(defenders.size()):
		if defenders[slot].is_empty(): continue
		var before: Dictionary = get_stats(slot)
		var promoted: int = promoted_level(code,defenders[slot])
		var candidate: Dictionary = {}
		if promoted > 0:
			candidate = defenders[slot].duplicate(true)
			candidate.level = promoted
		# Les statistiques « après » se lisent avec la forteresse telle qu'elle sera après le choix (Rage du désespoir dépend des PV perdus) ; état rétabli aussitôt.
		var saved_hp: Array[int] = [max_hp,fortress_hp]
		var fortress: Dictionary = bonus_fortress_change(code)
		max_hp += int(fortress.max)
		fortress_hp = clampi(fortress_hp+int(fortress.current),1,max_hp)
		var after: Dictionary = _stats_with_bonuses(slot,-1,candidate,projected)
		max_hp = saved_hp[0]
		fortress_hp = saved_hp[1]
		var large_before: Dictionary = {}
		var large_after: Dictionary = {}
		for component in ["direct","secondary","curse"]:
			large_before[component] = damage_for(before,component,{"type":7})
			large_after[component] = _damage_with_bonuses(after,component,{"type":7},projected)
		var level: int = defenders[slot].level
		units.append({"slot":slot,"type":defenders[slot].type,"before":before,"after":after,"level_after":promoted if promoted > 0 else level,
			"large_before":large_before,"large_after":large_after,
			"upgrade_before":upgrade_cost(slot),"upgrade_after":_discounted_cost(Progression.UPGRADE_COSTS[(promoted if promoted > 0 else level)-1],9,projected) if (promoted if promoted > 0 else level) < 4 else 0})
	var purchases: Array[Dictionary] = []
	for type in available_types():
		purchases.append({"type":type,"before":purchase_cost(type),"after":_discounted_cost(base_recruit_cost(type),10,projected)})
	var upgrades: Array[Dictionary] = []
	for cost in Progression.UPGRADE_COSTS:
		upgrades.append({"before":_discounted_cost(cost,9,bonuses),"after":_discounted_cost(cost,9,projected)})
	return {"units":units,"purchases":purchases,"upgrades":upgrades,
		"hp_before":fortress_hp,"hp_after":clampi(fortress_hp+int(bonus_fortress_change(code).current),1,max_hp+int(bonus_fortress_change(code).max)),
		"max_before":max_hp,"max_after":max_hp+int(bonus_fortress_change(code).max),
		"gold_before":gold,"gold_after":gold+bonus_gold_change(code)}

func prepare_next_wave() -> bool:
	if phase != "finished" or wave >= 10: return false
	completed_time += elapsed
	wave += 1
	elapsed = 0.0
	spawned = 0
	killed = 0
	escaped = 0
	wave_arrivals_by_route.clear()
	shots.clear()
	damage_events.clear()
	protection_events.clear()
	explosion_events.clear()
	elimination_events.clear()
	bought_waves.clear()
	curses.clear()
	event_log.clear()
	spawn_schedule = Campaign.schedule(wave,wave_set_id)
	phase = "preparation"
	_record_action("wave_prepare")
	return true

func choose_bonus(code: int) -> bool:
	if phase != "bonus" or code not in bonus_offer or code in bonuses: return false
	var offered: Array[int] = bonus_offer.duplicate()
	bonuses.append(code)
	bonus_offer.clear()
	var change: Dictionary = bonus_fortress_change(code)
	max_hp += int(change.max)
	fortress_hp = clampi(fortress_hp+int(change.current),1,max_hp)
	gold += bonus_gold_change(code)
	for slot in range(defenders.size()):
		var promoted: int = promoted_level(code,defenders[slot])
		if promoted > 0: defenders[slot].level = promoted # Promotion (R-44) et Ascension (R-55) : gratuites, l'or payé (et donc la revente) ne change pas.
	_refresh_windows()
	phase = "finished"
	_record_action("bonus_choice",{"offered":offered,"chosen":code})
	return true

## Vagues après lesquelles le joueur choisit un bonus : 3, 6 et 9 avant la v0.232 ; 2, 4, 6 et 8 depuis (quatre choix, réglage de prototype à confirmer).
const BONUS_WAVES_LEGACY: Array[int] = [3,6,9]
const BONUS_WAVES: Array[int] = [2,4,6,8]
func bonus_waves() -> Array[int]:
	return BONUS_WAVES if rules_v232 else BONUS_WAVES_LEGACY

## Effet immédiat d'un bonus sur la forteresse : variation du maximum et des PV actuels (Maçonnerie renforcée +4, Pari risqué −4, Forteresse blindée +8).
func bonus_fortress_change(code: int) -> Dictionary:
	if code == 8: return {"max":4,"current":4}
	if code == B_GAMBLE: return {"max":-4,"current":-4}
	if code == B_FORTRESS: return {"max":8,"current":8}
	if code == B_BASTION: return {"max":12,"current":max_hp+12-fortress_hp} # Forteresse imprenable (R-57) : soin complet
	return {"max":0,"current":0}

## Or reçu immédiatement au choix d'un bonus : Trésor de guerre (R-42) +100, Fortune royale (R-59) +150.
static func bonus_gold_change(code: int) -> int:
	if code == B_TREASURE: return 100
	if code == B_ROYAL: return 150
	return 0

## Niveau gratuit donné par un bonus à un défenseur actuel (0 : aucun) : Promotion (R-44) niveau 1 → 2, Ascension (R-55) niveaux 1-2 → 3.
static func promoted_level(code: int, defender: Dictionary) -> int:
	if defender.is_empty(): return 0
	var level: int = int(defender.get("level",1))
	if code == B_PROMOTION and level == 1: return 2
	if code == B_ASCENSION and level <= 2: return 3
	return 0

## Politique de choix de référence des essais automatiques (non jouée) : le premier bonus proposé qui ne comporte aucune contrepartie ; sinon le premier proposé.
static func reference_bonus(offer: Array) -> int:
	for code in offer:
		if int(code) not in [B_GAMBLE,B_FRENZY,B_LONG,B_MARKET,B_FORTRESS,B_ELITE]: return int(code)
	return int(offer[0])

func _offer_bonus() -> void:
	var state_before: String = str(rng.state)
	bonus_offer.assign(_draw_offers([]))
	phase = "bonus"
	_record_action("bonus_offer",{"offered":bonus_offer.duplicate(),"rng_state_before":state_before,"rng_state_after":str(rng.state)})

## Trois offres distinctes, jamais un bonus déjà pris. Avant la v0.233 : tirage uniforme (12 bonus avant la v0.232, 36 ensuite), inchangé pour rejouer les anciens rapports.
## Depuis la v0.233 : chaque carte tire d'abord sa rareté (`Campaign.RARITY_WEIGHTS` selon le rang du choix), puis un bonus de cette rareté ; à défaut, une rareté voisine.
## `excluded` (relance) : bonus à éviter si possible, ici les trois offres remplacées.
func _draw_offers(excluded: Array) -> Array[int]:
	var offer: Array[int] = []
	if not rules_v232 or not rules_v233:
		var pool: Array[int] = []
		for code in range(Campaign.V232_BONUS_COUNT if rules_v232 else Campaign.LEGACY_BONUS_COUNT):
			if code not in bonuses: pool.append(code)
		for index in range(3):
			var selected_index: int = rng.randi_range(0,pool.size()-1)
			offer.append(pool[selected_index])
			pool.remove_at(selected_index)
		return offer
	var rank: int = clampi(bonus_waves().find(wave),0,Campaign.RARITY_WEIGHTS.size()-1)
	var weights: Array = Campaign.RARITY_WEIGHTS[rank]
	for index in range(3):
		var roll: int = rng.randi_range(0,99)
		var tier: int = 0 if roll < int(weights[0]) else 1 if roll < int(weights[0])+int(weights[1]) else 2
		var candidates: Array[int] = []
		for attempt in [tier,tier-1,tier-2,tier+1,tier+2]:
			if attempt < 0 or attempt > 2: continue
			candidates = _offer_candidates(Campaign.RARITIES[attempt],offer,excluded)
			if not candidates.is_empty(): break
		if candidates.is_empty(): candidates = _offer_candidates("",offer,[])
		offer.append(candidates[rng.randi_range(0,candidates.size()-1)])
	return offer

func _offer_candidates(rarity: String, offer: Array, excluded: Array) -> Array[int]:
	var result: Array[int] = []
	for code in range(Campaign.BONUSES.size()):
		if code in bonuses or code in offer or code in excluded: continue
		if rarity.is_empty() or Campaign.bonus_rarity(code) == rarity: result.append(code)
	return result

## Relance (règles v0.233) : remplace les trois offres par trois autres, une fois par partie, sans coût. Le tirage suit les mêmes raretés que l'offre remplacée.
func reroll_bonus() -> bool:
	if phase != "bonus" or not rules_v232 or not rules_v233 or rerolls_left <= 0: return false
	var previous: Array[int] = bonus_offer.duplicate()
	var state_before: String = str(rng.state)
	bonus_offer.assign(_draw_offers(previous))
	rerolls_left -= 1
	_record_action("bonus_reroll",{"previous":previous,"offered":bonus_offer.duplicate(),"rng_state_before":state_before,"rng_state_after":str(rng.state)})
	return true

## Relances encore disponibles dans cette partie (0 sous les anciennes règles).
func rerolls_available() -> int:
	return rerolls_left if rules_v232 and rules_v233 else 0

func upgrade_cost(slot: int) -> int:
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty():
		return 0
	var level: int = defenders[slot].get("level", 1)
	return _discounted_cost(Progression.UPGRADE_COSTS[level-1],9,bonuses) if level < 4 else 0

func upgrade_error(slot: int, branch: int = -1) -> String:
	if not can_build():
		return "Améliorations possibles uniquement entre les vagues."
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty():
		return "Sélectionnez un défenseur."
	if defenders[slot].type not in available_types():
		return "Ce défenseur appartient à l’autre faction."
	var level: int = defenders[slot].get("level", 1)
	if level >= 4:
		return "Niveau maximum atteint."
	if gold < upgrade_cost(slot):
		return "Or insuffisant."
	if level == 3 and branch not in [0, 1]:
		return "Choisissez une spécialisation pour atteindre le niveau 4."
	if level < 3 and branch != -1:
		return "La spécialisation se choisit au passage au niveau 4."
	return ""

func upgrade(slot: int, branch: int = -1) -> bool:
	if not upgrade_error(slot, branch).is_empty():
		return false
	var paid: int = upgrade_cost(slot)
	var defender: Dictionary = defenders[slot]
	defender.level += 1
	if defender.level == 4:
		defender.branch = branch
	defender.paid += paid
	gold -= paid
	_refresh_windows()
	_record_action("upgrade",{"slot":slot,"type":defender.type,"instance_id":defender.instance_id,"level":defender.level,"branch":defender.branch,"cost":paid})
	return true

func refund(slot: int) -> int:
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty():
		return 0
	return int(floor(defenders[slot].paid * 70.0 / 100.0))

func sell(slot: int) -> bool:
	if not can_build() or refund(slot) <= 0:
		return false
	var unit: Dictionary = defenders[slot].duplicate(true)
	var received: int = refund(slot)
	gold += received
	defenders[slot] = {}
	_refresh_windows()
	_record_action("sell",{"slot":slot,"type":unit.type,"instance_id":unit.instance_id,"received":received,"invested":unit.paid})
	return true

func start() -> bool:
	if phase != "preparation":
		return false
	for entry in spawn_schedule:
		if entry.has("route_id") and route_by_id(entry.route_id).is_empty(): return false
	if initial_rng_state.is_empty():
		initial_rng_seed = str(rng.seed)
		initial_rng_state = str(rng.state)
	var army: Array[Dictionary] = []
	for slot in range(defenders.size()):
		var unit: Dictionary = defenders[slot]
		if not unit.is_empty(): army.append({"slot":slot,"type":unit.type,"level":unit.level,"branch":unit.branch,"paid":unit.paid,"instance_id":unit.instance_id})
	_wave_record = {"wave":wave,"hp_before":fortress_hp,"max_hp":max_hp,"income_before":total_income,"army":army,"bonuses":bonuses.duplicate(),"planned":spawn_schedule.size()}
	_wave_record["performance"] = Metrics.create(army)
	phase = "combat"
	for defender in defenders:
		if not defender.is_empty():
			defender.ready_at = 0.0
	_record_action("wave_start",{"army":army.duplicate(true),"bonuses":bonuses.duplicate()})
	eruption_next = 1
	storm_next = 0
	_resolve_instant()
	return true

func advance(seconds: float) -> void:
	if not active or seconds <= 0.0 or not is_finite(seconds):
		return
	var target_time: float = elapsed + seconds
	# Résoudre les événements à leur instant exact, même si un écran saute une image.
	while active:
		var next_time: float = _next_event_time()
		if next_time > target_time + EPS:
			elapsed = target_time
			_update_positions()
			return
		elapsed = maxf(elapsed, next_time)
		_resolve_instant()

## Ralentissement (unités entravantes de la boutique) : la vitesse est multipliée par SLOW_FACTOR tant que `slow_until` n'est pas atteint.
## La position reste une forme fermée du temps : distance = vitesse × (t − apparition − retard cumulé − (1 − facteur) × durée ralentie).
## La fin d'un ralentissement est un événement du moteur, donc le résultat ne dépend pas du pas de simulation.
const SLOW_FACTOR := 0.6

func _end_slows() -> void:
	for enemy in enemies:
		if enemy.has("slow_until") and float(enemy.slow_until) <= elapsed+EPS:
			enemy.delay = float(enemy.get("delay",0.0))+(1.0-SLOW_FACTOR)*(float(enemy.slow_until)-float(enemy.slow_start))
			enemy.erase("slow_until");enemy.erase("slow_start")

func _slow_enemy(enemy: Dictionary, seconds: float) -> void:
	var until: float = elapsed+seconds
	if enemy.has("slow_until"): enemy.slow_until = maxf(float(enemy.slow_until),until)
	else:
		enemy.slow_start = elapsed
		enemy.slow_until = until

static func enemy_is_slowed(enemy: Dictionary) -> bool:
	return enemy.has("slow_until")

## Instant où l'ennemi atteint la distance `d` sur sa route, compte tenu du ralentissement en cours (les ralentissements futurs recalculent à leur événement).
func time_at_distance(enemy: Dictionary, d: float) -> float:
	var speed: float = float(enemy.get("speed",1.0))
	var delay: float = float(enemy.get("delay",0.0))
	if enemy.has("slow_until"):
		var start: float = float(enemy.slow_start)
		var slowed: float = (d/speed+float(enemy.spawn_time)+delay-(1.0-SLOW_FACTOR)*start)/SLOW_FACTOR
		if slowed <= float(enemy.slow_until): return slowed
		return float(enemy.spawn_time)+delay+(1.0-SLOW_FACTOR)*(float(enemy.slow_until)-start)+d/speed
	return float(enemy.spawn_time)+delay+d/speed

func distance_at(enemy: Dictionary, t: float) -> float:
	var speed: float = float(enemy.get("speed",1.0))
	var base: float = t-float(enemy.spawn_time)
	if enemy.has("delay"): base -= float(enemy.delay)
	if enemy.has("slow_until") and t > float(enemy.slow_start): base -= (1.0-SLOW_FACTOR)*(minf(t,float(enemy.slow_until))-float(enemy.slow_start))
	return clampf(base*speed,0.0,enemy_route_length(enemy))

func _next_event_time() -> float:
	var next_time: float = INF
	if spawned < spawn_schedule.size():
		next_time = spawn_schedule[spawned].time
	for curse in curses:
		next_time = minf(next_time, curse.next_at)
	if eruption_enabled(): next_time = minf(next_time,eruption_time(eruption_next))
	if storm_enabled(): next_time = minf(next_time,storm_boundary_time(storm_next))
	for enemy in enemies:
		next_time = minf(next_time, time_at_distance(enemy,enemy_route_length(enemy)))
		if enemy.has("slow_until") and float(enemy.slow_until) > elapsed+EPS: next_time = minf(next_time,float(enemy.slow_until))
	for defender in defenders:
		if defender.is_empty():
			continue
		for enemy in enemies:
			for window in _windows_for(defender,enemy):
				var first: float = maxf(defender.ready_at, time_at_distance(enemy,window.first))
				var last: float = time_at_distance(enemy,window.last)
				if first > elapsed + EPS and first <= last + EPS:
					next_time = minf(next_time, first)
	return next_time

func _update_positions() -> void:
	for enemy in enemies:
		var previous: float = enemy.distance
		enemy.distance = distance_at(enemy,elapsed)
		if enemy.get("type",1) == Drowned.TYPE and enemy.hp < enemy.max_hp:
			# Régénération exacte par tronçon inondé : même résultat quel que soit le pas de temps.
			enemy.hp = minf(enemy.max_hp,enemy.hp+Drowned.regenerated(map_definition.get("flooded",[]),str(enemy.get("route_id","")),enemy.max_hp,enemy.speed,previous,enemy.distance))

func enemy_in_water(enemy: Dictionary) -> bool:
	return enemy.get("type",1) == Drowned.TYPE and Drowned.in_water(map_definition.get("flooded",[]),str(enemy.get("route_id","")),enemy.distance)

func _resolve_instant() -> void:
	_end_slows()
	# 1. Apparitions et positions ; les arrivants restent ciblables jusqu'à la phase 4.
	while spawned < spawn_schedule.size() and spawn_schedule[spawned].time <= elapsed + EPS:
		var entry: Dictionary = spawn_schedule[spawned]
		var enemy: Dictionary = make_enemy(spawned, entry.type, entry.time,faction,enemy_hp_percent)
		if not routes.is_empty(): enemy.route_id = spawn_route_id(spawned,entry)
		# Chausse-trappes (R-40, 2 s) et Temps suspendu (R-60, 4 s) : ralenti dès l'apparition.
		var entry_slow: float = 4.0 if B_STASIS in bonuses else 2.0 if B_CALTROPS in bonuses else 0.0
		if entry_slow > 0.0: _slow_enemy(enemy,entry_slow)
		enemies.append(enemy)
		spawned += 1
	_update_positions()
	# 1 bis. Éruptions (affixe) : le défenseur frappé ne tire plus avant la fin de sa désactivation.
	while eruption_enabled() and eruption_time(eruption_next) <= elapsed + EPS:
		var struck: int = eruption_slot(eruption_next)
		if struck >= 0:
			defenders[struck].ready_at = maxf(float(defenders[struck].ready_at),eruption_time(eruption_next)+float(combat_affix.duration))
			event_log.append("%.9f éruption %d emplacement %d" % [elapsed,eruption_next,struck])
		eruption_next += 1
	# 1 ter. Tempête de sable (affixe) : les frontières de rafale sont des événements ; les fenêtres de portée suivent l'instant courant.
	while storm_enabled() and storm_boundary_time(storm_next) <= elapsed + EPS:
		event_log.append("%.9f tempête %d %s" % [elapsed,storm_next/2+1,"fin" if storm_next%2 == 1 else "début"])
		storm_next += 1
	# 2. Anciens ticks additionnés, puis morts retirés avant le choix des nouveaux tirs.
	var damage: Dictionary = {}
	var hits: Array[Dictionary] = []
	var pending: Array[Dictionary] = []
	for curse in curses:
		if curse.next_at <= elapsed + EPS:
			_add_damage(damage, curse.enemy_id, curse.damage)
			hits.append({"source_id":curse.source_id,"enemy_id":curse.enemy_id,"component":"curse","amount":curse.damage})
			event_log.append("%.9f tick source %d cible %d" % [elapsed, curse.source_id, curse.enemy_id])
			curse.ticks_left -= 1
			curse.next_at += 1.0
		if curse.ticks_left > 0:
			pending.append(curse)
	curses = pending
	_apply_damage(damage,hits)
	# 3. Tous les défenseurs visent le même état des survivants, sans ordre privilégié.
	damage = {}
	hits = []
	var applications: Array[Dictionary] = []
	for slot in range(defenders.size()):
		var defender: Dictionary = defenders[slot]
		if defender.is_empty() or defender.ready_at > elapsed + EPS:
			continue
		var stats: Dictionary = get_stats(slot)
		var targets: Array[Dictionary] = []
		for enemy in enemies:
			for window in _windows_for(defender,enemy):
				if enemy.distance >= window.first - EPS and enemy.distance <= window.last + EPS:
					targets.append(enemy)
					break
		if targets.is_empty():
			continue
		targets.sort_custom(_target_priority)
		var primary: Dictionary = targets[0]
		var impact: Vector2 = enemy_position(primary)
		defender.last_target_position = impact
		var direct_damage: float = damage_for(stats,"direct",primary)
		_add_damage(damage, primary.id, direct_damage)
		hits.append({"source_id":defender.instance_id,"enemy_id":primary.id,"component":"direct","amount":direct_damage})
		if float(stats.get("slow_seconds",0.0)) > 0.0: _slow_enemy(primary,float(stats.slow_seconds))
		# Pillage posé par ce tir : « new » si la cible n'était pas pillée, « renewed » sinon (lu par la vue pour le badge du Pillard gobelin, sans effet sur le combat).
		var loot_state: String = "renewed" if float(primary.get("loot_until",-1.0)) >= elapsed else "new"
		if float(stats.get("loot_seconds",0.0)) > 0.0:
			primary.loot_until = elapsed+float(stats.loot_seconds)
			primary.loot_bonus = maxf(float(primary.get("loot_bonus",0.0)),float(stats.get("loot_bonus",0.0)))
		# Volatilité posée par ce tir : « new » si la cible n'était pas volatile, « renewed » sinon (lu par la vue pour le badge du Gobelin des braises, sans effet sur le combat).
		var volatile_state: String = "renewed" if float(primary.get("volatile_until",-1.0)) >= elapsed else "new"
		if float(stats.get("volatile_seconds",0.0)) > 0.0:
			primary.volatile_until = elapsed+float(stats.volatile_seconds)
			primary.volatile_damage = maxf(float(primary.get("volatile_damage",0.0)),float(stats.get("volatile_damage",0.0)))
			primary.volatile_radius = maxf(float(primary.get("volatile_radius",0.0)),float(stats.get("volatile_radius",1.0)))
		# Marque posée par ce tir : « new » si la cible n'était pas marquée, « renewed » sinon (lu par la vue pour le losange de l'Éclaireur-observateur, sans effet sur le combat).
		var mark_state: String = "renewed" if float(primary.get("marked_until",-1.0)) > elapsed else "new"
		var placed_mark: bool = float(stats.get("mark_seconds",0.0)) > 0.0 or B_HUNTMARK in bonuses
		if float(stats.get("mark_seconds",0.0)) > 0.0:
			primary.marked_until = elapsed+float(stats.mark_seconds)
			primary.mark_bonus = maxf(float(primary.get("mark_bonus",0.0)),float(stats.get("mark_bonus",0.0)))
		elif B_HUNTMARK in bonuses:
			# Marque du chasseur (R-51) : tout tir direct marque sa cible 3 s, +10 % de dégâts des autres défenseurs ; une marque plus forte ou plus longue est conservée.
			primary.marked_until = maxf(float(primary.get("marked_until",-1.0)),elapsed+3.0)
			primary.mark_bonus = maxf(float(primary.get("mark_bonus",0.0)),0.10)
		var shot: Dictionary = {"time": elapsed, "slot": slot, "type": defender.type,
			"target_id": primary.id, "from": slots[slot], "to": impact, "secondary": [], "radius": stats.radius}
		if placed_mark: shot.mark = mark_state
		if float(stats.get("loot_seconds",0.0)) > 0.0: shot.loot = loot_state
		if float(stats.get("volatile_seconds",0.0)) > 0.0: shot.volatile = volatile_state
		event_log.append("%.9f tir E%d cible %d" % [elapsed, slot + 1, primary.id])
		if family(defender.type) in [2, 3, 4]:
			var hit_ids: Array[int] = [primary.id]
			var origin: Dictionary = primary
			for hit in range(stats.secondary_cap):
				var candidates: Array[Dictionary] = []
				for enemy in enemies:
					var squared: float = enemy_separation_squared(origin,enemy)
					if enemy.id not in hit_ids and squared < stats.radius * stats.radius:
						candidates.append({"enemy": enemy, "squared": squared})
				if candidates.is_empty():
					break
				candidates.sort_custom(_nearby_priority)
				var victim: Dictionary = candidates[0].enemy
				var secondary_damage: float = damage_for(stats,"secondary",victim)
				_add_damage(damage, victim.id, secondary_damage)
				hits.append({"source_id":defender.instance_id,"enemy_id":victim.id,"component":"secondary","amount":secondary_damage})
				hit_ids.append(victim.id)
				shot.secondary.append(enemy_position(victim))
				# Les explosions restent centrées sur l'impact ; les ricochets avancent.
				if family(defender.type) == 3:
					origin = victim
		if family(defender.type) == 5 or (burn_for_all_curse_units and family(defender.type) == 2 and float(stats.get("curse_damage",0.0)) > 0.0):
			applications.append({"source_id": defender.instance_id, "enemy_id": primary.id, "damage": damage_for(stats,"curse",primary)})
		shots.append(shot)
		defender.ready_at = elapsed + stats.interval
	_apply_damage(damage,hits)
	for application in applications:
		if _has_enemy(application.enemy_id):
			_apply_curse(application.source_id, application.enemy_id, application.damage)
	# 4. Les survivants arrivés infligent leurs dégâts sans récompense.
	var survivors: Array[Dictionary] = []
	var arrival_damage: int = 0
	for enemy in enemies:
		if enemy.distance >= enemy_route_length(enemy) - EPS:
			escaped += 1
			total_escaped += 1
			if not routes.is_empty():
				var route_id: String = enemy.route_id
				arrivals_by_route[route_id] = arrivals_by_route.get(route_id, 0)+1
				wave_arrivals_by_route[route_id] = wave_arrivals_by_route.get(route_id, 0)+1
			if B_GATE in bonuses and gate_wave != wave:
				# Herse (R-47) : le premier ennemi qui atteint la forteresse dans la vague ne lui inflige aucun dégât.
				gate_wave = wave
				event_log.append("%.9f herse %d" % [elapsed, enemy.id])
			else: arrival_damage += enemy.get("fortress_damage", 1)
			event_log.append("%.9f arrivee %d" % [elapsed, enemy.id])
		else:
			survivors.append(enemy)
	enemies = survivors
	_purge_curses()
	fortress_hp = maxi(0, fortress_hp - arrival_damage)
	if fortress_hp == 0 and B_LASTSTAND in bonuses and not last_stand_used:
		# Dernier souffle (R-53) : une fois par partie, la forteresse reste debout à 1 PV et regagne 10 PV.
		last_stand_used = true
		fortress_hp = mini(max_hp,1+10)
		event_log.append("%.9f dernier souffle" % elapsed)
	# 5. Défaite prioritaire sur le choix, la fin et la victoire.
	if fortress_hp == 0:
		phase = "defeat"
	elif spawned == spawn_schedule.size() and enemies.is_empty():
		_wave_cleared_bonuses()
		if wave == 10:
			phase = "victory"
		elif wave in bonus_waves():
			_offer_bonus()
		else:
			phase = "finished"
	if not active: _finish_wave_record()

## Effets de fin de vague gagnée : Réparations (R-41, +2 PV sans dépasser le maximum) et Intérêts (R-43, +10 % de l'or possédé, 25 au plus, arrondi inférieur, compté dans les gains).
func _wave_cleared_bonuses() -> void:
	if B_REPAIRS in bonuses and fortress_hp < max_hp:
		fortress_hp = mini(max_hp,fortress_hp+2)
		event_log.append("%.9f réparations" % elapsed)
	if B_INTEREST in bonuses:
		var interest: int = mini(25,int(floor(float(gold)*0.10)))
		if interest > 0:
			gold += interest
			total_income += interest
			event_log.append("%.9f intérêts +%d" % [elapsed, interest])

func _finish_wave_record() -> void:
	if _wave_record.is_empty() or _wave_record.wave != wave: return
	var record: Dictionary = _wave_record.duplicate(true)
	if not routes.is_empty():
		record["arrivals_by_route"] = wave_arrivals_by_route.duplicate()
	record.merge({"hp_after":fortress_hp,"hp_lost":record.hp_before-fortress_hp,"income":total_income-record.income_before,"killed":killed,"escaped":escaped,"spawned":spawned,"remaining":enemies.size(),"seconds":elapsed,"result":"defeat" if phase == "defeat" else "cleared"})
	wave_history.append(record)
	_record_action("wave_end",{"result":record.result,"killed":killed,"escaped":escaped,"income":record.income,"seconds":elapsed})
	_wave_record.clear()

func _has_enemy(id: int) -> bool:
	for enemy in enemies:
		if enemy.id == id:
			return true
	return false

func _purge_curses() -> void:
	var surviving: Array[Dictionary] = []
	for curse in curses:
		if _has_enemy(curse.enemy_id):
			surviving.append(curse)
	curses = surviving

## Origine visuelle des dégâts de chaque ennemi (type du défenseur et composante) : observation pour le rendu, qui recale l'affichage sur l'arrivée du projectile. Sans effet de jeu.
var _damage_sources: Dictionary = {}

func _record_damage_sources(hits: Array) -> void:
	_damage_sources.clear()
	for hit in hits:
		var composante: String = str(hit.get("component",""))
		if _damage_sources.has(hit.enemy_id) and (composante == "curse" or _damage_sources[hit.enemy_id].component != "curse"): continue
		var type: int = -1
		for defender in defenders:
			if not defender.is_empty() and int(defender.get("instance_id",-2)) == int(hit.get("source_id",-1)): type = int(defender.type);break
		_damage_sources[hit.enemy_id] = {"source_type":type,"component":composante}

func _apply_damage(damage: Dictionary, hits: Array = []) -> void:
	_record_damage_sources(hits)
	if enemies.any(func(enemy): return enemy.get("type",1) == Banks.GUARD_TYPE):
		var positions: Dictionary = {}
		for enemy in enemies: positions[enemy.id] = enemy_position(enemy)
		var redirected: Dictionary = Banks.redirect(enemies,damage,hits,positions)
		damage = redirected.damage;hits = redirected.hits
		for transfer in redirected.transfers:
			if transfer.amount <= 0.0: continue
			protection_events.append({"time":elapsed,"from":positions[transfer.protected_id],"to":positions[transfer.guardian_id],
				"amount":transfer.amount,"guardian_id":transfer.guardian_id,"protected_id":transfer.protected_id})
		while protection_events.size() > 24: protection_events.pop_front()
	Metrics.credit(_wave_record.get("performance",[]),enemies,damage,hits)
	var survivors: Array[Dictionary] = []
	var blasts: Array[Dictionary] = []
	for enemy in enemies:
		var hp_before: float = enemy.hp
		enemy.hp -= damage.get(enemy.id, 0.0)
		# Exécution (R-45) : un ennemi touché qui tombe sous 10 % de ses PV maximum est achevé, sauf le boss.
		if B_EXECUTE in bonuses and enemy.hp < hp_before and enemy.hp > 0.0 and enemy.hp < 0.10*float(enemy.max_hp)-EPS and int(enemy.get("type",1)) != 7:
			enemy.hp = 0.0
			event_log.append("%.9f exécution %d" % [elapsed, enemy.id])
		if enemy.hp < hp_before:
			var origin: Dictionary = _damage_sources.get(enemy.id,{})
			damage_events.append({"time":elapsed,"enemy_id":enemy.id,"hp_before":hp_before,"hp_after":maxf(0.0,enemy.hp),"source_type":int(origin.get("source_type",-1)),"component":str(origin.get("component",""))})
		_settle_enemy(enemy,survivors,blasts)
	# Réaction en chaîne : un ennemi marqué « volatile » qui meurt explose et blesse ses voisins ; les explosions peuvent en provoquer d'autres, chaque ennemi n'explose qu'une fois.
	while not blasts.is_empty():
		var next_blasts: Array[Dictionary] = []
		var remaining: Array[Dictionary] = []
		for enemy in survivors:
			var splash := 0.0
			for blast in blasts:
				if blast.source.id != enemy.id and enemy_separation_squared(blast.source,enemy) <= blast.radius*blast.radius: splash += blast.damage
			if splash > 0.0:
				var before: float = enemy.hp
				enemy.hp -= splash
				damage_events.append({"time":elapsed,"enemy_id":enemy.id,"hp_before":before,"hp_after":maxf(0.0,enemy.hp)})
			_settle_enemy(enemy,remaining,next_blasts)
		survivors = remaining
		blasts = next_blasts
	enemies = survivors
	_purge_curses()

## Règle d'un ennemi après dégâts : relève du revenant (une seule fois), élimination avec or (pillage et brume marine compris) et explosion éventuelle, sinon survie.
func _settle_enemy(enemy: Dictionary, survivors: Array[Dictionary], blasts: Array[Dictionary]) -> void:
	if enemy.hp <= 0.0 and enemy.get("type",1) == Revenant.TYPE and not enemy.get("risen",false):
		# Le revenant se relève une seule fois avec la moitié de ses PV maximum ; aucune récompense ni élimination comptée à cet instant.
		enemy.risen = true
		enemy.risen_at = elapsed # Observation visuelle : lance l'animation de relève.
		enemy.hp = enemy.max_hp*Revenant.RISE_FRACTION
		event_log.append("%.9f relève %d" % [elapsed, enemy.id])
		survivors.append(enemy)
		return
	if enemy.hp <= 0.0:
		var origin_of_death: Dictionary = _damage_sources.get(enemy.id,{})
		elimination_events.append({"time":elapsed,"enemy_id":enemy.id,"type":enemy.get("type",1),"point":enemy_position(enemy),"distance":enemy.distance,"route_id":str(enemy.get("route_id","")),"source_type":int(origin_of_death.get("source_type",-1)),"component":str(origin_of_death.get("component",""))})
		killed += 1
		total_killed += 1
		var base: int = enemy.get("reward", 3)
		if B_BOUNTY in bonuses: base += 2 # Prime de guerre (R-52), avant les autres modificateurs d'or
		if float(enemy.get("loot_until",-1.0)) >= elapsed-EPS: base = roundi(float(base)*(1.0+float(enemy.get("loot_bonus",0.0))))
		if B_LOOT in bonuses: base = roundi(float(base)*1.25) # Prime de butin (R-36)
		var reward: int = kill_reward(base)
		gold += reward
		total_income += reward
		event_log.append("%.9f mort %d +%d" % [elapsed, enemy.id, reward])
		if float(enemy.get("volatile_until",-1.0)) >= elapsed-EPS and not enemy.get("exploded",false):
			enemy.exploded = true
			event_log.append("%.9f explosion %d" % [elapsed, enemy.id])
			explosion_events.append({"time":elapsed,"position":enemy_position(enemy),"radius":float(enemy.get("volatile_radius",1.0))})
			while explosion_events.size() > 24: explosion_events.pop_front()
			blasts.append({"source":enemy,"damage":float(enemy.get("volatile_damage",0.0)),"radius":float(enemy.get("volatile_radius",1.0))})
	else:
		survivors.append(enemy)

func _apply_curse(source_id: int, enemy_id: int, damage: float) -> void:
	var surviving: Array[Dictionary] = []
	for curse in curses:
		if curse.source_id != source_id or curse.enemy_id != enemy_id:
			surviving.append(curse)
	surviving.append({"source_id": source_id, "enemy_id": enemy_id,
		"damage": damage, "next_at": elapsed + 1.0, "ticks_left": 3 if B_TENACIOUS in bonuses else 2}) # Malédiction tenace (R-39) : une échéance de plus
	curses = surviving

static func _add_damage(damage: Dictionary, id: int, amount: float) -> void:
	damage[id] = damage.get(id, 0.0) + amount

func _target_priority(a: Dictionary, b: Dictionary) -> bool:
	if not routes.is_empty():
		var first: float = enemy_arrival_delay(a) if route_target_policy=="arrival_time" else enemy_route_length(a)-a.distance
		var second: float = enemy_arrival_delay(b) if route_target_policy=="arrival_time" else enemy_route_length(b)-b.distance
		if first != second: return first < second
		return a.id < b.id
	return _progress_priority(a,b)

func configure_route_target_policy(value: Variant) -> bool:
	# Historical diagnostics only; freeze the rule before any player decision.
	if not value is String or value not in ["arrival_time","remaining_distance"] or routes.is_empty(): return false
	if not action_history.is_empty() or phase!="preparation" or wave!=1 or gold!=INITIAL_GOLD: return false
	route_target_policy=value
	return true

static func _progress_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.distance != b.distance:
		return a.distance > b.distance
	return a.id < b.id

func _nearby_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.squared != b.squared: return a.squared < b.squared
	return _target_priority(a.enemy,b.enemy)

static func _secondary_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.squared != b.squared:
		return a.squared < b.squared
	return _progress_priority(a.enemy, b.enemy)

func point_on_path(progress: float) -> Vector2:
	return position_at(progress, path_points, path_length)

func route_by_id(id: Variant) -> Dictionary:
	if not id is String: return {}
	for route in routes:
		if route.id==id: return route
	return {}

func enemy_route(enemy: Dictionary) -> Dictionary:
	return route_by_id(enemy.get("route_id",""))

func enemy_route_length(enemy: Dictionary) -> float:
	return path_length if routes.is_empty() else float(enemy_route(enemy).path_length)

func enemy_arrival_delay(enemy: Dictionary) -> float:
	if enemy.has("slow_until") or enemy.has("delay"): return maxf(0.0,time_at_distance(enemy,enemy_route_length(enemy))-elapsed)
	return maxf(0.0,enemy_route_length(enemy)-enemy.distance)/float(enemy.get("speed",1.0))

func enemy_route_points(enemy: Dictionary) -> Array[Vector2]:
	if routes.is_empty(): return path_points
	var route: Dictionary = enemy_route(enemy)
	var points: Array[Vector2] = [];points.assign(route.path_points);return points

func enemy_position(enemy: Dictionary) -> Vector2:
	return position_at(enemy.distance,enemy_route_points(enemy),enemy_route_length(enemy))

func enemy_separation_squared(first: Dictionary, second: Dictionary) -> float:
	return Routes.cross_separation_squared(first.distance,enemy_route_points(first),enemy_route_length(first),second.distance,enemy_route_points(second),enemy_route_length(second))

func _windows_for(defender: Dictionary, enemy: Dictionary) -> Array:
	var stormy: bool = storm_active_now() and defender.has("storm_windows")
	if not routes.is_empty(): return defender.get("storm_route_windows" if stormy else "route_windows",{}).get(enemy.get("route_id",""),[])
	return defender.storm_windows if stormy else defender.windows

static func coverage_windows(center: Vector2, radius: float, route_points: Array[Vector2] = PATH_POINTS) -> Array[Dictionary]:
	return Routes.coverage_windows(center,radius,route_points)

static func position_components(progress: float, route_points: Array[Vector2] = PATH_POINTS, route_length: float = PATH_LENGTH) -> Dictionary:
	return Routes.position_components(progress,route_points,route_length)

static func separation_squared(first: float, second: float, route_points: Array[Vector2] = PATH_POINTS, route_length: float = PATH_LENGTH) -> float:
	return Routes.separation_squared(first,second,route_points,route_length)

static func position_at(progress: float, route_points: Array[Vector2] = PATH_POINTS, route_length: float = PATH_LENGTH) -> Vector2:
	return Routes.position_at(progress,route_points,route_length)
