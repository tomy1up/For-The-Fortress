extends Node2D
var entry_forecast: Array[Dictionary] = []
var highlighted_entries: Array[int] = []

const Model = preload("res://scripts/valley_model.gd")
const MarshArt = preload("res://scripts/marsh_art.gd")
const SoundPlayer = preload("res://scripts/sound_player.gd")
const SoundDirector = preload("res://scripts/sound_director.gd")
const HordeArt = preload("res://scripts/horde_art.gd")
const AllianceArt = preload("res://scripts/alliance_art.gd")
const EnemyArt = preload("res://scripts/enemy_art.gd")
const EnemyWalkArt = preload("res://scripts/enemy_walk_art.gd")
const SheetAnimations = preload("res://scripts/animation_library.gd")
const DecorArt = preload("res://scripts/decor_art.gd")
var walking_meshes:=EnemyWalkArt.new()
var wolf_turn_preview := Callable()
const ShopArt = preload("res://scripts/shop_art.gd")
const FortressArt = preload("res://scripts/fortress_art.gd")
const ORIGIN := Vector2(658, 174)
const AXIS := Vector2(27, 13.5)
const INK := Color("d9e4d7")
const SLOT_FILL := Color("213e3b")
const IMPACT_DURATION := 0.32 # Secondes de simulation, comme les autres effets du combat.
const DAMAGE_TRAIL_DURATION := 0.40
const HIT_FLASH_DURATION := 0.16
const HIT_REACTION_DURATION := 0.28
## Signal bref d'élimination (décision du porteur, 15 novembre 2026, réglages de prototype à confirmer) : bref éclat et fondu d'environ 0,15 s pour les ennemis
## ordinaires, flexion et fondu de 0,25 s pour les élites, traitement long conservé pour les boss. Rendu seulement : aucun effet sur le combat.
const ELIMINATION_DURATION := 0.15
const ELITE_ELIMINATION_DURATION := 0.25
const BOSS_ELIMINATION_DURATION := 0.45
const ELITE_TYPES: Array[int] = [3,5,6,10]
const BOSS_TYPES: Array[int] = [7]
const BURST_MERGE_DISTANCE := 20.0 # px d'écran : des éclats plus proches (et simultanés) n'en forment qu'un
var _ghost_alpha: float = 1.0
var _ghost_squash: float = 1.0
const MAX_ELIMINATION_EFFECTS := 24
var elimination_tail: float = 0.0
var sound_player: Node = null
var sound_director: RefCounted = null
## Suivi purement visuel des défenseurs (achat, passage de niveau, revente), cadencé en temps réel : le modèle ne bouge pas en préparation.
var _seen_model: Object = null
var _seen_defenders: Array[Dictionary] = []
var _defender_events: Dictionary = {}
var _sold_ghosts: Array[Dictionary] = []
var flag_phase: float = 0.0
var model: RefCounted:
	set(value):
		model = value
		reset_royal_animation()
		terrain_details.assign(scenery_for(model.map_definition) if model != null else [])
var terrain_details: Array[Dictionary] = []
var selected: int = -1
var purchase_preview: Dictionary = {}
var upgrade_preview: Dictionary = {}
var preview_synergy_unit: Dictionary = {}
var inspected_enemy_id: int = -1
var royal_hurt_age: float = 2.0
var royal_rally_age: float = 2.0
var breach_feedback: Dictionary = {}:
	set(value):
		breach_feedback = value
		if int(value.get("damage",0)) > 0 and int(value.get("count",0)) > 0: royal_hurt_age = 0.0

func reset_royal_animation() -> void:
	royal_hurt_age = 2.0;royal_rally_age = 2.0

func signal_wave_started() -> void:
	royal_rally_age = 0.0

var font: Font = ThemeDB.fallback_font

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func _process(delta: float) -> void:
	_track_defenders()
	_play_sounds()
	if _sheet_animation_running(): queue_redraw()
	royal_hurt_age = minf(2.0,royal_hurt_age+maxf(0.0,delta))
	royal_rally_age = minf(2.0,royal_rally_age+maxf(0.0,delta))
	flag_phase = fmod(flag_phase+maxf(0.0,delta),TAU)
	if model == null or model.active or model.phase not in ["finished","bonus","victory","defeat"]:
		elimination_tail = 0.0
	elif elimination_tail < maxf(BOSS_ELIMINATION_DURATION,SheetAnimations.death_window())+0.5:
		elimination_tail = minf(maxf(BOSS_ELIMINATION_DURATION,SheetAnimations.death_window())+0.5,elimination_tail+maxf(0.0,delta))
		queue_redraw()

## Sons de combat (banques libres, voir `sound_bank.gd`) : détectés d'après les événements du modèle, jamais écrits dans le modèle.
func _play_sounds() -> void:
	if model == null or not is_inside_tree(): return
	if sound_player == null:
		sound_player = SoundPlayer.new()
		add_child(sound_player)
		sound_director = SoundDirector.new(launch_delay,PROJECTILE_FLIGHT)
	sound_player.play_all(sound_director.update(model))

## Recalage visuel des dégâts (retour du porteur, 16 novembre 2026) : le coup est résolu à l'instant du tir, mais l'affichage (barre de vie, éclat, mort) attend l'arrivée du projectile
## (lâcher différé puis vol). Les dégâts sur la durée (brûlure, malédiction) s'affichent à leur instant. Rendu seulement : le combat ne change pas.
static func damage_landing_delay(event: Dictionary) -> float:
	if str(event.get("component","")) == "curse" or int(event.get("source_type",-1)) < 0: return 0.0
	return launch_delay({"type":int(event.source_type)})+PROJECTILE_FLIGHT

## Âge visuel d'un événement de dégâts ou d'élimination (négatif tant que le projectile n'est pas arrivé).
func event_age(event: Dictionary) -> float:
	return model.elapsed-float(event.time)-damage_landing_delay(event)

## PV affichés : les dégâts dont le projectile n'est pas encore arrivé ne sont pas encore retirés.
func visual_hp(enemy: Dictionary) -> float:
	var shown: float = float(enemy.hp)
	if model == null: return shown
	for index in range(model.damage_events.size()-1,-1,-1):
		var event: Dictionary = model.damage_events[index]
		if model.elapsed-float(event.time) > 1.0: break
		if event.enemy_id == enemy.id and event_age(event) < 0.0 and model.elapsed >= float(event.time): shown += float(event.hp_before)-float(event.hp_after)
	return shown

func recent_eliminations(window: float = BOSS_ELIMINATION_DURATION) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if model == null or model.phase not in ["combat","finished","bonus","victory","defeat"]: return result
	for index in range(model.elimination_events.size()-1,-1,-1):
		var event: Dictionary = model.elimination_events[index]
		var raw_age: float = model.elapsed-event.time+(0.0 if model.active else elimination_tail)
		var age: float = raw_age-damage_landing_delay(event)
		if raw_age >= window+0.5: break
		if age >= window: continue
		if raw_age >= 0.0:
			result.append({"event":event,"age":age})
			if result.size() >= MAX_ELIMINATION_EFFECTS: break
	return result

static func elimination_duration(type: int) -> float:
	return BOSS_ELIMINATION_DURATION if type in BOSS_TYPES else ELITE_ELIMINATION_DURATION if type in ELITE_TYPES else ELIMINATION_DURATION

## Éclat d'une élimination ; `crowd` éliminations simultanées proches se regroupent en un seul éclat un peu plus large.
static func elimination_particles(event: Dictionary, age: float, crowd: int = 1) -> Array[Dictionary]:
	var particles: Array[Dictionary] = []
	var duration: float = elimination_duration(int(event.type))
	if age < 0.0 or age >= duration: return particles
	var t: float = age/duration
	var scale: float = (1.5 if event.type in BOSS_TYPES else 1.0)*(1.0+0.3*float(clampi(crowd,1,4)-1))
	var center: Vector2 = project(event.point)+Vector2(0,-10*scale)
	for index in range(5):
		var angle: float = index*TAU/5+fmod(float(event.enemy_id)*0.61,TAU)
		var offset := Vector2(cos(angle)*(4+14*t),sin(angle)*(2+5*t)-12*t)*scale
		particles.append({"point":center+offset,"radius":(4.0+1.4*(index%2))*(1.0-0.55*t)*scale,"alpha":0.65*(1.0-t)})
	return particles

static func project(point: Vector2) -> Vector2:
	return ORIGIN + Vector2((point.x - point.y) * AXIS.x, (point.x + point.y) * AXIS.y)

func purchase_ghost() -> Dictionary:
	if model == null or not model.can_build() or selected < 0 or selected >= model.defenders.size(): return {}
	if not model.defenders[selected].is_empty() or not purchase_preview.has("type"): return {}
	var type: int = int(purchase_preview.type)
	if type not in model.available_types(): return {}
	return {"slot":selected,"type":type,"point":project(_map_slots()[selected]),"available":model.purchase_error(selected,type).is_empty()}

static func range_outline(center: Vector2, radius: float) -> PackedVector2Array:
	var ring := PackedVector2Array()
	for step in range(65):
		var angle: float = TAU * step / 64.0
		ring.append(project(center + Vector2(cos(angle), sin(angle)) * radius))
	return ring

static func impact_opacity(age: float) -> float:
	return clampf(1.0 - age / IMPACT_DURATION, 0.0, 1.0) if age >= 0.0 else 0.0

static func damage_opacity(age: float, duration: float = DAMAGE_TRAIL_DURATION) -> float:
	return clampf(1.0-age/duration,0.0,1.0) if age >= 0.0 and duration > 0.0 else 0.0

static func damage_span(event: Dictionary, maximum: float) -> Vector2:
	if maximum <= 0.0: return Vector2.ZERO
	return Vector2(clampf(event.hp_after/maximum,0.0,1.0),clampf(event.hp_before/maximum,0.0,1.0))

func recent_enemy_damage(enemy_id: int) -> Array[Dictionary]:
	var recent: Array[Dictionary] = []
	if model == null or not model.active: return recent
	for index in range(model.damage_events.size()-1,-1,-1):
		var event: Dictionary = model.damage_events[index]
		var age: float = event_age(event)
		if model.elapsed-float(event.time) >= DAMAGE_TRAIL_DURATION+0.5: break
		if event.enemy_id == enemy_id and age >= 0.0 and age < DAMAGE_TRAIL_DURATION: recent.append(event)
	return recent

## Âge du dernier coup reçu par cet ennemi, ou une valeur négative s'il n'en a pas reçu récemment (animation `hurt`).
func last_hit_age(enemy_id: int) -> float:
	if model == null or not model.active: return -1.0
	for index in range(model.damage_events.size()-1,-1,-1):
		var event: Dictionary = model.damage_events[index]
		var age: float = event_age(event)
		if model.elapsed-float(event.time) > 3.5: break
		if event.enemy_id == enemy_id and age >= 0.0: return age
	return -1.0

func enemy_hit_strength(events: Array[Dictionary]) -> float:
	var strength: float = 0.0
	for event in events: strength = maxf(strength,damage_opacity(event_age(event),HIT_FLASH_DURATION))
	return strength

static func hit_reaction_pulse(age: float) -> float:
	if not is_finite(age) or age < 0.0 or age >= HIT_REACTION_DURATION: return 0.0
	# Une brève prise d’impact suivie d’un retour progressif au repos.
	if age < 0.045: return sin(age/0.045*PI/2.0)
	return pow(cos((age-0.045)/(HIT_REACTION_DURATION-0.045)*PI/2.0),2)

static func enemy_reaction_weight(type: int) -> float:
	return {3:0.7,5:0.55,6:0.7,7:0.45,8:0.35}.get(type,1.0)

func inspected_protection_links() -> Array[Dictionary]:
	var links: Array[Dictionary] = []
	if model == null or not model.active or inspected_enemy_id < 0: return links
	var positions: Dictionary = {}
	for enemy in model.enemies: positions[enemy.id] = model.enemy_position(enemy)
	for enemy in model.enemies:
		var guardian: int = Model.Banks.guardian_for(enemy,model.enemies,positions)
		if guardian >= 0 and (enemy.id == inspected_enemy_id or guardian == inspected_enemy_id):
			links.append({"enemy_id":enemy.id,"guardian_id":guardian,"from":positions[enemy.id],"to":positions[guardian]})
	return links

static func enemy_reaction_pose(enemy: Dictionary, events: Array[Dictionary], now: float) -> Dictionary:
	var strength: float = 0.0
	for event in events:
		if event.get("enemy_id",-1) != enemy.id: continue
		var lost: float = maxf(0.0,float(event.hp_before)-float(event.hp_after))
		if lost <= 0.0 or enemy.get("max_hp",0.0) <= 0.0: continue
		var fraction: float = clampf(lost/float(enemy.max_hp),0.0,1.0)
		var pulse: float = hit_reaction_pulse(now-float(event.time)-damage_landing_delay(event))*(0.35+0.65*sqrt(fraction))
		strength = maxf(strength,pulse) # Les coups simultanés ne cumulent pas leur recul.
	strength *= enemy_reaction_weight(int(enemy.get("type",1)))
	return {"strength":strength,"offset":Vector2(-3.5*strength,0.7*strength),"rotation":-0.105*strength}

static func enemy_body_transform(enemy: Dictionary, facing: float, pose: Dictionary, elapsed: float, moving: bool, route_direction := Vector2.ZERO) -> Transform2D:
	var scale: float = _enemy_scale(enemy)
	var stride: float = sin(elapsed*10.0*enemy.get("speed",1.0)+enemy.id)*2.0 if moving else 0.0
	# Les pieds restent proches de leur ancrage. Ni recul logique, ni ralentissement.
	var offset: Vector2 = pose.get("offset",Vector2.ZERO)
	var mirror := Transform2D(Vector2(facing*scale,0),Vector2(0,scale),Vector2.ZERO)
	var reaction := Transform2D(float(pose.get("rotation",0.0)),Vector2.ONE,0.0,offset)
	var result: Transform2D = mirror*reaction
	if route_direction != Vector2.ZERO:
		result.origin += (route_direction-Vector2(facing, 0.0))*offset.x*scale
	result.origin.y -= absf(stride)*0.3*scale
	return result

static func secondary_segments(shot: Dictionary) -> Array[PackedVector2Array]:
	var segments: Array[PackedVector2Array] = []
	var origin: Vector2 = shot.to
	for target in shot.get("secondary", []):
		segments.append(PackedVector2Array([project(origin), project(target)]))
		if Model.family(shot.type) == 3: origin = target
	return segments

const ARROW_TYPES: Array[int] = [11] # Tireur d'élite elfe : flèche, bien que sa famille de combat reste celle de l'arbalétrier.
const BULLET_TYPE := 12 # Arquebusière naine : balle de plomb et traînée de poudre, bien que sa famille de combat reste celle de l'archer.
const CANNON_TYPE := 13 # Bombardier nain : boulet en cloche.
const SHORT_BOLT_TYPE := 47 # Tirailleur gnome : carreau court d'arbalète de poing.
const SWORD_TYPE := 46 # Fantassin squelette : coup d'épée courte, sans projectile lancé.
const PIKE_TYPES: Array[int] = [14,20] # Piquier humain et lance-épieu orc : coup à courte portée, sans projectile lancé.
const PEBBLE_TYPE := 25 # Fronde elfe : galet, bien que sa famille de combat reste celle de l'archer.
const FIRE_TYPE := 15 # Pyromancien humain : boule de feu.
const SHARD_TYPES: Array[int] = [18,30] # Lance-éclats gobelin et mage de givre : éclat de cristal.
const CARTRIDGE_TYPE := 37 # Piégeur nain : cartouche en bois.
const BOLT_TYPES: Array[int] = [38,43] # Balliste royale et baliste de guerre : gros carreau de siège.
const RUNE_TYPE := 42 # Poseur de mines : disque runique.
const VIAL_TYPE := 39 # Alchimiste gnome : fiole.
const COIN_TYPE := 36 # Marchand mercenaire : pièce d'or.
const GOLD_SHARD_TYPE := 32 # Prêtre guerrier : éclat doré.
const WISP_TYPE := 33 # Chaman des marais : feu follet.
const PULSE_TYPES: Array[int] = [34,35] # Totem de guerre et ancien des tribus : impulsion, onde cuivrée.
const DART_TYPE := 29 # Sarbacane gobeline : dard.
const STONE_TYPE := 19 # Catapulte gobeline : pierre en cloche.
const EMBER_TYPE := 21 # Brûleur de cendres : braise partie de la grille du brasero.
const LIGHTNING_TYPE := 22 # Mage de la foudre : éclair jusqu'aux cibles touchées.
const JAVELIN_TYPE := 17 # Lanceur de javeline troll : projectile de lance, pas de hache.
const PROJECTILE_FLIGHT := 0.12 # Habillage du tir déjà résolu ; aucune attente de dégâts.
## Lâcher différé de certains gestes (secondes après le tir) : le projectile quitte la main à ce moment et le marqueur d'impact apparaît à son arrivée. Les dégâts restent résolus à l'instant du tir.
const LAUNCH_DELAYS: Dictionary = {4: 0.12, 5: 0.12, 11: 0.27, 12: 0.045, 13: 0.16, 14: 0.256, 15: 0.288, 17: 0.288, 18: 0.1125, 10: 0.52, 19: 0.5, 20: 0.28, 21: 0.336, 22: 0.32, 23: 0.6, 24: 0.44, 25: 0.4, 26: 0.52} # Sapeur gobelin (v0.210) : charge tenue pendant l'armé ; chaman orc (v0.211) : éclair libéré depuis le crâne du bâton.

## Visée inclinée du Tireur d'élite elfe (décision du porteur, 15 novembre 2026) : sept planches (0°, ±8°, ±16°, ±24°) ; l'angle est choisi une fois d'après la
## position à l'écran de la cible vue depuis le pivot de l'arc, puis sert à la pose, à l'origine de la flèche et à sa direction de départ. Positif : vers le bas.
const AIMED_TYPE := 11
## Lancer incliné du Javelinier troll (type 17, trois planches −12°, 0°, +12°, lâcher à 0,288 s) : points de départ de la pointe depuis le pied (`lachers.json`).
## Bombardier nain (type 13, lâcher à 0,16 s) : le boulet part à 26° au-dessus de l'horizontale puis suit une trajectoire en cloche.
## Piquier humain (type 14, estoc à deux mains, contact à 0,256 s) : trois planches (−12°, 0°, +12°), la pique est dessinée dans les planches ; seul l'éclat de contact est
## dessiné par le jeu, à la pointe donnée par angle (`contact.json`).
const PIKEMAN_TYPE := 14
const PIKE_TIPS: Dictionary = {-12:Vector2(49.6188,-37.8302),0:Vector2(50.294,-30.897),12:Vector2(49.6188,-23.9638)}
## Pyromancien humain (type 15, incantation, lâcher à 0,288 s) : trois planches (−12°, 0°, +12°), boule de feu lancée depuis le point donné par angle (`lachers.json`).
const PYROMANCER_TYPE := 15
const PYRO_TIPS: Dictionary = {-12:Vector2(32.8654,-50.375),0:Vector2(32.8465,-47.9359),12:Vector2(32.7376,-45.5035)}
## Lance-éclats gobelin (type 18, cristal lancé en ligne droite, lâcher à 0,1125 s) : cinq planches (−36°, −12°, 0°, +12°, +36°). La planche est celle dont l'angle s'écarte le moins
## de la droite entre sa propre pointe (`lachers.json`) et l'impact ; le cristal dessiné suit cette droite pendant tout le vol.
const SHARDTHROWER_TYPE := 18
const SHARD_TIPS: Dictionary = {-36:Vector2(16.1448,-34.5325),-12:Vector2(20.0201,-30.3707),0:Vector2(20.7757,-25.8869),12:Vector2(20.4848,-21.8582),36:Vector2(17.5151,-14.8514)}
## Sentinelle elfe (type 10, tir avec transfert de poids, flèche à 0,52 s en trajet rectiligne) : trois planches (−12°, 0°, +12°), choisie comme celle du Lance-éclats.
const SENTINEL_TYPE := 10
const SENTINEL_TIPS: Dictionary = {-12:Vector2(21.9512,-42.0693),0:Vector2(22.1997,-39.3846),12:Vector2(21.7661,-36.6909)}
## Brûleur de cendres (type 21, poussée du brasero, braise à 0,336 s) : trois planches (−12°, 0°, +12°), la braise part de la grille donnée par planche (`lachers.json`). Pas de trait de malédiction ;
## si la cible est derrière la grille en abscisse, le vol est omis (impact et flammes à l'arrivée seulement).
const EMBER_GRATE: Dictionary = {-12:Vector2(38.2931,-21.8431),0:Vector2(37.3524,-20.0139),12:Vector2(36.1413,-18.3476)}
## Mage de la foudre (type 22, charge puis éclair en chaîne, départ à 0,32 s) : trois planches (−12°, 0°, +12°), l'éclair part de la main avancée donnée par planche (`lachers.json`).
## Une seule chaîne relie la cible principale et les cibles secondaires réellement touchées, avec des ramifications et un éclat sur chaque cible touchée (pas d'anneau de zone).
const LIGHTNING_HANDS: Dictionary = {-12:Vector2(33.7671,-54.6456),0:Vector2(33.5726,-52.1781),12:Vector2(33.2027,-49.7461)}
## Archer double (type 23, tir unique, flèche à 0,60 s) : cinq planches (−36°, −12°, 0°, +12°, +36°) ; la planche est choisie comme celle du Lance-éclats d'après le segment depuis sa propre pointe encochée (`lachers.json`),
## la flèche suit ce segment en ligne droite jusqu'à l'impact. Le tir unique et le bonus sur cible blessée restent ceux du modèle.
const DOUBLE_ARCHER_TYPE := 23
const DOUBLE_ARCHER_TIPS: Dictionary = {-36:Vector2(18.8839,-50.0676),-12:Vector2(21.6973,-46.0707),0:Vector2(22.0608,-43.1431),12:Vector2(21.6973,-40.2154),36:Vector2(18.8839,-36.2185)}
## Arbalète lourde (type 24, tir unique, carreau à 0,44 s) : six planches (−24°, −12°, 0°, +12°, +24°, +36°) choisies comme celles du Lance-éclats d'après le segment depuis leur propre pointe (`lachers.json`) ;
## le carreau suit ce segment en ligne droite ; si la cible est déjà derrière la pointe à l'écran, seul l'impact est joué. Multiplicateurs de dégâts inchangés.
const HEAVY_CROSSBOW_TYPE := 24
const HEAVY_CROSSBOW_TIPS: Dictionary = {-24:Vector2(34.1793,-45.1271),-12:Vector2(37.5025,-37.5104),0:Vector2(39.1696,-29.3692),12:Vector2(39.1075,-21.0593),24:Vector2(37.3191,-12.9439),36:Vector2(33.8825,-5.3776)}
## Fronde elfe (type 25, galet à 0,40 s sur la première pose à poche vide) : cinq planches (−12°, 0°, +12°, +24°, +36°) choisies comme celles du Lance-éclats d'après le segment depuis leur propre repère
## (`lachers.json`, retourné avec la planche) ; petit galet du jeu en ligne droite, impact unique.
const SLING_TIPS: Dictionary = {-12:Vector2(-7.7875,-71.8596),0:Vector2(-4.5179,-71.5098),12:Vector2(-1.1735,-70.4733),24:Vector2(2.1359,-68.7885),36:Vector2(5.2289,-66.5305)}
## Hache en chaîne (type 26, lancer puis ricochets, départ à 0,52 s) : cinq planches (−12°, 0°, +12°, +24°, +36°) choisies comme celles du Lance-éclats d'après le segment depuis leur propre repère (`lachers.json`,
## centre de la dernière hache tenue, retourné avec la planche) ; la même hache (`hache_double.png`) vole en ligne droite puis suit les points de `shot.secondary` (0,068 s par ricochet, remontée de 3 px) ;
## l'éclat de chaque impact apparaît à l'arrivée de la hache. Si la cible est déjà derrière le repère à l'écran, la hache n'est pas dessinée en vol.
const CHAIN_AXE_TYPE := 26
const CHAIN_AXE_TIPS: Dictionary = {-12:Vector2(30.6191,-42.4234),0:Vector2(31.458,-35.9809),12:Vector2(31.3951,-29.5322),24:Vector2(30.7863,-23.1865),36:Vector2(29.2924,-17.2422)}
const CHAIN_AXE_ANGLES: Dictionary = {-12:-28.0,0:-16.0,12:-4.0,24:8.0,36:20.0}
const CHAIN_AXE_BOUNCE := 0.068
const CHAIN_AXE_TEXTURE: Texture2D = preload("res://assets/units/shop/hache_double_v001.png")
const CHAIN_AXE_PIVOT_PX := Vector2(574.0,207.0)
const CHAIN_AXE_SCALE := 0.05228215767634855
const SHARD_TEXTURE: Texture2D = preload("res://assets/units/shop/eclat_v001.png")
const SHARD_PIVOT_PX := Vector2(181.0,36.0)
const SHARD_SCALE := 0.10441044104410441
## Catapulte gobeline (type 19, bras sur pivot, lâcher à 0,50 s) : trois planches (profil, vue du dessus « up », vue du dessous « down ») selon la hauteur de la cible au sol à l'écran.
## La pierre part du centre donné par planche (`lacher.json`, depuis le pied, côté horizontal retourné pour un tir à gauche) et suit une courbe quadratique dont la tangente initiale a la pente de la planche.
const CATAPULT_CENTERS: Dictionary = {"":Vector2(28.1625,-45.6041),"_up":Vector2(24.9855,-31.5008),"_down":Vector2(24.9855,-56.4851)}
const CATAPULT_SLOPES: Dictionary = {"":1.6297,"_up":2.352,"_down":1.352}
const CATAPULT_CONTROL := 0.44
const CATAPULT_DIAGONAL_MIN := 5.0
const CATAPULT_DIAGONAL_RATIO := 0.16
const CATAPULT_TEXTURE: Texture2D = preload("res://assets/units/shop/pierre_v001.png")
const CATAPULT_PIVOT_PX := Vector2(93.0,59.0)
const CATAPULT_SCALE := 0.106
## Lance-épieu orc (type 20, estoc à deux mains, contact à 0,28 s) : sept planches ; celle retenue est celle dont la pointe au contact (`contact.json`, depuis le pied, signe
## horizontal retourné pour un coup à gauche) est la plus proche de l'impact projeté. Un seul éclat de contact est dessiné à cette pointe, selon l'angle de la planche.
const SPEARMAN_TYPE := 20
const SPEAR_POINTS: Dictionary = {"attack":{"pitch":0,"point":Vector2(47.9702,-24.0115)},"attack_up12":{"pitch":-12,"point":Vector2(46.8385,-33.3695)},"attack_down12":{"pitch":12,"point":Vector2(47.1458,-14.6209)},
	"attack_close":{"pitch":0,"point":Vector2(39.1025,-24.0115)},"attack_far":{"pitch":0,"point":Vector2(56.099,-24.0115)},"attack_close_up":{"pitch":-12,"point":Vector2(33.6424,-33.3695)},"attack_close_down":{"pitch":12,"point":Vector2(33.9497,-14.6209)}}
const STEP_TYPES: Array[int] = [14,15,17,21,22]
const TILTED_TYPES: Array[int] = [10,11,14,15,17,18,21,22,23,24,25,26]
const CURVED_TYPES: Array[int] = [11,13,17]
const JAVELIN_PIVOT := Vector2(0.0,-41.3453)
const JAVELIN_TIPS: Dictionary = {-12:Vector2(55.3409,-51.4028),0:Vector2(56.1005,-41.3453),12:Vector2(54.9211,-31.3319)}
const JAVELIN_STEP := 12
const CANNON_ANGLE := 26.0
const JAVELIN_TEXTURE: Texture2D = preload("res://assets/units/shop/javeline_v001.png")
const JAVELIN_PIVOT_PX := Vector2(485.0,28.0) # pointe dans l'image source (495 x 60)
const JAVELIN_SCALE := 0.12
const AIM_PIVOT := Vector2(0.0,-33.44) # pivot de l'arc, depuis le pied
const AIM_LENGTH := 38.2 # pivot -> pointe de la flèche encochée
const AIM_STEP := 8
const AIM_LIMIT := 24

static func aim_pitch(shot: Dictionary) -> int:
	if int(shot.get("type",-1)) in [SHARDTHROWER_TYPE,SENTINEL_TYPE,DOUBLE_ARCHER_TYPE,HEAVY_CROSSBOW_TYPE,PEBBLE_TYPE,CHAIN_AXE_TYPE]:
		var impact: Vector2 = project(shot.to)+Vector2(0,-12)
		var facing_side: float = shot_facing(shot)
		var best: int = 0
		var best_error: float = INF
		var tips: Dictionary = step_tips(int(shot.type))
		for candidate in tips:
			var tip: Vector2 = project(shot.from)+Vector2(tips[candidate].x*facing_side,tips[candidate].y)
			var line: Vector2 = impact-tip
			var error: float = absf(rad_to_deg(atan2(line.y,maxf(absf(line.x),0.0001)))-float(candidate))
			if error < best_error: best_error = error;best = int(candidate)
		return best
	if int(shot.get("type",-1)) in STEP_TYPES:
		var hand: Vector2 = project(shot.from)+Vector2(0.0,float(step_tips(int(shot.type))[0].y))
		var gap: Vector2 = project(shot.to)+Vector2(0,-12)-hand
		var angle: float = rad_to_deg(atan2(gap.y,maxf(absf(gap.x),0.0001)))
		return clampi(int(roundf(angle/float(JAVELIN_STEP)))*JAVELIN_STEP,-JAVELIN_STEP,JAVELIN_STEP)
	var pivot: Vector2 = project(shot.from)+AIM_PIVOT
	var delta: Vector2 = project(shot.to)+Vector2(0,-12)-pivot
	var degrees: float = rad_to_deg(atan2(delta.y,maxf(absf(delta.x),0.0001)))
	return clampi(int(roundf(degrees/float(AIM_STEP)))*AIM_STEP,-AIM_LIMIT,AIM_LIMIT)

static func step_tips(type: int) -> Dictionary:
	return PIKE_TIPS if type == PIKEMAN_TYPE else PYRO_TIPS if type == PYROMANCER_TYPE else SHARD_TIPS if type == SHARDTHROWER_TYPE else SENTINEL_TIPS if type == SENTINEL_TYPE else EMBER_GRATE if type == EMBER_TYPE else LIGHTNING_HANDS if type == LIGHTNING_TYPE else DOUBLE_ARCHER_TIPS if type == DOUBLE_ARCHER_TYPE else HEAVY_CROSSBOW_TIPS if type == HEAVY_CROSSBOW_TYPE else SLING_TIPS if type == PEBBLE_TYPE else CHAIN_AXE_TIPS if type == CHAIN_AXE_TYPE else JAVELIN_TIPS

static func aim_variant(pitch: int) -> String:
	return "attack" if pitch == 0 else "attack_%s%d" % ["down" if pitch > 0 else "up",absi(pitch)]

static func aim_direction(shot: Dictionary) -> Vector2:
	if int(shot.get("type",-1)) == SPEARMAN_TYPE:
		var spear_angle: float = deg_to_rad(float(SPEAR_POINTS[spear_variant(shot)].pitch))
		return Vector2(shot_facing(shot)*cos(spear_angle),sin(spear_angle))
	if int(shot.get("type",-1)) == CANNON_TYPE: return Vector2(shot_facing(shot)*cos(deg_to_rad(CANNON_ANGLE)),-sin(deg_to_rad(CANNON_ANGLE)))
	var angle: float = deg_to_rad(float(aim_pitch(shot)))
	return Vector2(shot_facing(shot)*cos(angle),sin(angle))

static func aimed_origin(shot: Dictionary) -> Vector2:
	if int(shot.get("type",-1)) in STEP_TYPES or int(shot.get("type",-1)) in [SHARDTHROWER_TYPE,SENTINEL_TYPE,DOUBLE_ARCHER_TYPE,HEAVY_CROSSBOW_TYPE,PEBBLE_TYPE,CHAIN_AXE_TYPE]:
		var tip: Vector2 = step_tips(int(shot.type))[aim_pitch(shot)]
		return project(shot.from)+Vector2(tip.x*shot_facing(shot),tip.y)
	return project(shot.from)+AIM_PIVOT+aim_direction(shot)*AIM_LENGTH

## Trajet de la flèche : part dans l'axe du trait dessiné puis rejoint le point d'impact (courbe quadratique dont la tangente initiale est l'axe de visée).
static func aimed_curve(shot: Dictionary, progress: float) -> Dictionary:
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var control: Vector2 = origin+aim_direction(shot)*(target-origin).length()*0.5
	var inverse: float = 1.0-progress
	var point: Vector2 = origin*inverse*inverse+control*2.0*inverse*progress+target*progress*progress
	var tangent: Vector2 = ((control-origin)*inverse+(target-control)*progress).normalized()
	return {"point":point,"direction":tangent}

## Vue de la Catapulte gobeline : « » (profil), « _up » ou « _down », d'après l'écart vertical entre l'emplacement et le point visé au sol, à l'écran.
static func catapult_view(from_board: Vector2, to_board: Vector2) -> String:
	var gap: Vector2 = project(to_board)-project(from_board)
	var limit: float = maxf(CATAPULT_DIAGONAL_MIN,CATAPULT_DIAGONAL_RATIO*absf(gap.x))
	if gap.y < -limit: return "_up"
	if gap.y > limit: return "_down"
	return ""

static func catapult_origin(shot: Dictionary) -> Vector2:
	var center: Vector2 = CATAPULT_CENTERS[catapult_view(shot.from,shot.to)]
	return project(shot.from)+Vector2(center.x*shot_facing(shot),center.y)

## La pierre n'est pas dessinée en vol quand la cible est déjà derrière la cuillère en abscisse (la zone s'affiche seulement à l'arrivée).
static func catapult_stone_flies(shot: Dictionary) -> bool:
	return (project(shot.to).x-catapult_origin(shot).x)*shot_facing(shot) > 0.0

static func catapult_curve(shot: Dictionary, progress: float) -> Dictionary:
	var origin: Vector2 = catapult_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var reach: float = (target.x-origin.x)*CATAPULT_CONTROL
	var control: Vector2 = origin+Vector2(reach,-absf(reach)*float(CATAPULT_SLOPES[catapult_view(shot.from,shot.to)]))
	var inverse: float = 1.0-progress
	var point: Vector2 = origin*inverse*inverse+control*2.0*inverse*progress+target*progress*progress
	var tangent: Vector2 = ((control-origin)*inverse+(target-control)*progress).normalized()
	return {"point":point,"direction":tangent}

static func spear_tip(shot: Dictionary, variant: String) -> Vector2:
	var point: Vector2 = SPEAR_POINTS[variant].point
	return project(shot.from)+Vector2(point.x*shot_facing(shot),point.y)

static func spear_variant(shot: Dictionary) -> String:
	var impact: Vector2 = project(shot.to)+Vector2(0,-12)
	var best: String = "attack"
	var best_distance: float = INF
	for variant in SPEAR_POINTS:
		var distance: float = spear_tip(shot,variant).distance_to(impact)
		if distance < best_distance-0.000001: best_distance = distance;best = variant
	return best

static func shot_origin(shot: Dictionary, pose_age: float = 0.0) -> Vector2:
	if int(shot.get("type",-1)) == SPEARMAN_TYPE: return spear_tip(shot,spear_variant(shot))
	if int(shot.get("type",-1)) == STONE_TYPE: return catapult_origin(shot)
	if int(shot.get("type",-1)) in TILTED_TYPES: return aimed_origin(shot)
	# Points d'équipement des silhouettes, distincts du centre logique de portée.
	var art = defender_art(int(shot.type))
	var muzzle: Vector2 = art.MUZZLES[int(shot.type)]
	var pose := {"pulse": attack_pulse(pose_age), "direction": shot_facing(shot)}
	return project(shot.from)+attack_transform(int(shot.type), pose)*muzzle

static func defender_art(type: int) -> GDScript:
	return ShopArt if ShopArt.TEXTURES.has(type) else AllianceArt if AllianceArt.TEXTURES.has(type) else HordeArt

static func shot_facing(shot: Dictionary) -> float:
	return -1.0 if project(shot.to).x < project(shot.from).x else 1.0

static func projectile_position(shot: Dictionary, age: float) -> Vector2:
	var progress: float = clampf(age / PROJECTILE_FLIGHT,0.0,1.0)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var point: Vector2 = origin.lerp(target,progress)
	if int(shot.type) in CURVED_TYPES: return aimed_curve(shot,progress).point
	if int(shot.type) == STONE_TYPE: return catapult_curve(shot,progress).point
	if Model.family(shot.type) in [3,4]: point.y -= sin(PI*progress)*(15.0 if Model.family(shot.type) == 4 else 8.0)
	elif int(shot.type) == CANNON_TYPE: point.y -= sin(PI*progress)*12.0
	elif int(shot.type) == VIAL_TYPE: point.y -= sin(PI*progress)*10.0
	elif int(shot.type) == EMBER_TYPE: point.y -= sin(PI*progress)*6.0
	return point

func _draw_projectile(shot: Dictionary, age: float, color: Color) -> void:
	if age < 0.0 or age >= PROJECTILE_FLIGHT: return
	var point: Vector2 = projectile_position(shot,age)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var direction: Vector2 = (target-origin).normalized()
	if direction.is_zero_approx(): direction = Vector2.RIGHT
	if int(shot.type) in CURVED_TYPES: direction = aimed_curve(shot,clampf(age/PROJECTILE_FLIGHT,0.0,1.0)).direction
	if int(shot.type) in [PIKEMAN_TYPE,SPEARMAN_TYPE]: direction = aim_direction(shot)
	var side: Vector2 = direction.orthogonal()
	if int(shot.type) == JAVELIN_TYPE:
		_draw_javelin(point,direction,side,shot_facing(shot))
		return
	if int(shot.type) == BULLET_TYPE:
		_draw_bullet(point,direction)
		return
	if int(shot.type) == CANNON_TYPE:
		_draw_cannonball(point,direction)
		return
	if int(shot.type) == SWORD_TYPE:
		_draw_sword_strike(origin,direction,side,age/PROJECTILE_FLIGHT)
		return
	if int(shot.type) == HEAVY_CROSSBOW_TYPE and (target.x-origin.x)*shot_facing(shot) <= 0.0: return # cible derrière la pointe : impact seul
	if int(shot.type) == SHARDTHROWER_TYPE:
		_draw_crystal_shard(point,direction,shot_facing(shot))
		return
	if int(shot.type) in [PIKEMAN_TYPE,SPEARMAN_TYPE]:
		_draw_pike_contact(origin,direction,side,age/PROJECTILE_FLIGHT)
		return
	if int(shot.type) in PIKE_TYPES:
		_draw_pike_thrust(origin,direction,side,age/PROJECTILE_FLIGHT)
		return
	if int(shot.type) == PEBBLE_TYPE:
		_draw_pebble(point,direction)
		return
	if int(shot.type) == FIRE_TYPE:
		_draw_fireball(point,direction,age,1.0)
		return
	if int(shot.type) == EMBER_TYPE:
		if (project(shot.to).x-origin.x)*shot_facing(shot) > 0.0: _draw_fireball(point,direction,age,0.6)
		return
	if int(shot.type) in SHARD_TYPES:
		_draw_shard(point,direction,side)
		return
	if int(shot.type) == CARTRIDGE_TYPE:
		_draw_cartridge(point,direction,side)
		return
	if int(shot.type) == RUNE_TYPE:
		_draw_rune_disc(point,age)
		return
	if int(shot.type) == SHORT_BOLT_TYPE:
		_draw_short_bolt(point,direction,side)
		return
	if int(shot.type) in BOLT_TYPES:
		_draw_ballista_bolt(point,direction,side)
		return
	if int(shot.type) == VIAL_TYPE:
		_draw_vial(point,age)
		return
	if int(shot.type) == COIN_TYPE:
		_draw_coin(point,age)
		return
	if int(shot.type) == GOLD_SHARD_TYPE:
		_draw_shard(point,direction,side,Color("f3d27a"))
		return
	if int(shot.type) == WISP_TYPE:
		_draw_wisp(point,age)
		return
	if int(shot.type) in PULSE_TYPES:
		_draw_pulse(point,age,Color("d99a5b") if int(shot.type) == 35 else Color("e8c87a"))
		return
	if int(shot.type) == DART_TYPE:
		_draw_dart(point,direction,side)
		return
	if int(shot.type) == STONE_TYPE:
		if catapult_stone_flies(shot): _draw_stone(point,shot_facing(shot))
		return
	if int(shot.type) == LIGHTNING_TYPE:
		_draw_lightning(shot,origin,target,age)
		return
	var style: int = 0 if int(shot.type) in ARROW_TYPES else Model.family(int(shot.type))
	match style:
		0,1:
			var length: float = 13.0 if style == 0 else 9.0
			draw_line(point-direction*length,point,Color("ead9a8"),1.8 if style == 0 else 3.0,true)
			draw_colored_polygon(PackedVector2Array([point+direction*3,point-direction*3+side*3,point-direction*3-side*3]),Color("e4f0e7"))
			for sign in [-1,1]: draw_line(point-direction*(length-3),point-direction*length+side*sign*3,color,1.5,true)
		2:
			draw_circle(point,7,Color(color,0.12),true,-1,true)
			draw_circle(point,3.5,color,true,-1,true)
			draw_circle(point+Vector2(-1,-1),1.5,Color("ecffff"),true,-1,true)
		3:
			if int(shot.type) == CHAIN_AXE_TYPE:
				if (target.x-origin.x)*shot_facing(shot) > 0.0: _draw_chain_axe(point,shot,age)
			else: _draw_spinning_axe(point, age)
		4:
			var roll := sin(age/PROJECTILE_FLIGHT*PI)*0.75*shot_facing(shot)
			var fuse := point+Vector2(4,-8).rotated(roll)
			draw_circle(point,5,Color("253a3e"),true,-1,true)
			draw_arc(point,4,3.7+roll,5.0+roll,8,Color("a6b7a9"),1.5,true)
			draw_line(point+Vector2(2,-4).rotated(roll),fuse,Color("d8b16b"),1.5,true)
			draw_circle(fuse,4.0,Color(1.0,0.57,0.22,0.26),true,-1,true)
			draw_circle(fuse,1.7,Color("fff0b4"),true,-1,true)
			for spark in range(3):
				var phase := fposmod(age*17.0+float(spark)/3.0,1.0)
				var offset := Vector2.UP.rotated(roll+(spark-1)*0.65)*lerpf(2.0,7.0,phase)
				draw_circle(fuse+offset,1.1,Color(1.0,0.72,0.34,1.0-phase),true,-1,true)
		5:
			var cross := PackedVector2Array([point+Vector2(0,-6),point+Vector2(4,0),point+Vector2(0,6),point+Vector2(-4,0)])
			draw_colored_polygon(cross,color)
			draw_line(point+Vector2(0,-3),point+Vector2(0,3),Color("f5def5"),1.5,true)

## Galet de la fronde elfe (type 25) : petite pierre grise et sillage léger.
func _draw_pebble(point: Vector2, direction: Vector2) -> void:
	draw_line(point-direction*8.0,point,Color(0.85,0.85,0.8,0.35),1.6,true)
	draw_circle(point,3.0,Color("6f726c"),true,-1,true)
	draw_circle(point+Vector2(-0.8,-0.8),1.0,Color("c9ccc2"),true,-1,true)

## Boule de feu (pyromancien) ou braise (brûleur de cendres, échelle réduite) : noyau clair, halo orange, étincelles.
func _draw_fireball(point: Vector2, direction: Vector2, age: float, scale: float) -> void:
	for trail in range(3):
		draw_circle(point-direction*(4.0+trail*4.5)*scale,(4.2-trail*1.0)*scale,Color(1.0,0.45,0.12,0.30-trail*0.08),true,-1,true)
	draw_circle(point,7.0*scale,Color(1.0,0.4,0.1,0.22),true,-1,true)
	draw_circle(point,4.2*scale,Color("ff8a2a"),true,-1,true)
	draw_circle(point,2.2*scale,Color("fff0b4"),true,-1,true)
	for spark in range(3):
		var phase := fposmod(age*19.0+float(spark)/3.0,1.0)
		draw_circle(point+Vector2.UP.rotated((spark-1)*0.9)*lerpf(3.0,8.0,phase)*scale,1.0,Color(1.0,0.75,0.3,1.0-phase),true,-1,true)

## Éclat de cristal du lance-éclats gobelin : losange turquoise allongé.
func _draw_shard(point: Vector2, direction: Vector2, side: Vector2, fill: Color = Color("7fe8e0")) -> void:
	var shard := PackedVector2Array([point+direction*6.0,point+side*2.4,point-direction*5.0,point-side*2.4])
	draw_colored_polygon(shard,fill)
	shard.append(shard[0])
	draw_polyline(shard,Color("1a4a50"),1.1,true)
	draw_line(point-direction*5.0,point+direction*3.0,Color(1.0,1.0,1.0,0.6),0.9,true)

## Cartouche en bois du piégeur nain : petit cylindre cerclé de fer.
func _draw_cartridge(point: Vector2, direction: Vector2, side: Vector2) -> void:
	var back: Vector2 = point-direction*6.0
	draw_line(back,point,Color("1f2420"),5.0,true)
	draw_line(back,point,Color("b98a4e"),3.4,true)
	draw_line(back+direction*2.0+side*2.0,back+direction*2.0-side*2.0,Color("6b6f72"),1.2,true)
	draw_line(point-direction*1.0+side*2.0,point-direction*1.0-side*2.0,Color("6b6f72"),1.2,true)

## Gros carreau de la balliste royale : long fût, pointe de fer et empennage.
func _draw_ballista_bolt(point: Vector2, direction: Vector2, side: Vector2) -> void:
	var tail: Vector2 = point-direction*20.0
	draw_line(tail,point,Color("1a2524"),4.4,true)
	draw_line(tail,point,Color("c8a46a"),2.6,true)
	var head := PackedVector2Array([point+direction*8.0,point+side*3.2,point-side*3.2])
	draw_colored_polygon(head,Color("d6dad8"))
	draw_line(tail,tail+direction*6.0+side*3.4,Color("e4e0cf"),1.6,true)
	draw_line(tail,tail+direction*6.0-side*3.4,Color("e4e0cf"),1.6,true)

## Disque runique du poseur de mines : disque de pierre gravé qui tourne, lueur orange.
func _draw_rune_disc(point: Vector2, age: float) -> void:
	var spin: float = age/PROJECTILE_FLIGHT*TAU*2.0
	draw_circle(point,7.5,Color(1.0,0.55,0.15,0.22),true,-1,true)
	draw_circle(point,4.8,Color("3a3430"),true,-1,true)
	draw_arc(point,3.2,spin,spin+TAU*0.75,10,Color("ffb04a"),1.4,true)
	draw_circle(point,1.2,Color("ffe3a0"),true,-1,true)

## Carreau court de l'arbalète de poing du tirailleur gnome : petit fût clair, pointe de fer, deux plumes.
func _draw_short_bolt(point: Vector2, direction: Vector2, side: Vector2) -> void:
	var tail: Vector2 = point-direction*9.0
	draw_line(tail,point,Color("1a2524"),3.0,true)
	draw_line(tail,point,Color("d9bf8a"),1.6,true)
	draw_colored_polygon(PackedVector2Array([point+direction*4.0,point+side*2.0,point-side*2.0]),Color("d6dad8"))
	draw_line(tail,tail+direction*3.0+side*2.0,Color("c0504a"),1.2,true)
	draw_line(tail,tail+direction*3.0-side*2.0,Color("c0504a"),1.2,true)

## Fiole de l'alchimiste gnome : verre verdâtre qui tourne, liquide vif.
func _draw_vial(point: Vector2, age: float) -> void:
	var spin: float = age/PROJECTILE_FLIGHT*TAU
	var axis := Vector2(0,-1).rotated(spin)
	draw_circle(point,6.5,Color(0.55,1.0,0.4,0.2),true,-1,true)
	draw_line(point-axis*3.0,point+axis*3.5,Color("cfe9d8"),4.6,true)
	draw_line(point-axis*3.0,point+axis*1.0,Color("7ee05a"),3.2,true)
	draw_line(point+axis*3.5,point+axis*5.5,Color("8a6a3a"),2.0,true)

## Pièce du marchand mercenaire : disque d'or qui tourne sur lui-même.
func _draw_coin(point: Vector2, age: float) -> void:
	var squash: float = absf(cos(age/PROJECTILE_FLIGHT*TAU*1.5))*0.8+0.2
	draw_set_transform(point,0.0,Vector2(1.0,squash))
	draw_circle(Vector2.ZERO,4.4,Color("8a6a1c"),true,-1,true)
	draw_circle(Vector2.ZERO,3.3,Color("f3d27a"),true,-1,true)
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

## Feu follet du chaman des marais : lueur verte qui palpite.
func _draw_wisp(point: Vector2, age: float) -> void:
	var pulse: float = 1.0+sin(age*60.0)*0.15
	draw_circle(point,8.0*pulse,Color(0.35,0.9,0.5,0.20),true,-1,true)
	draw_circle(point,4.4*pulse,Color("6fe08c"),true,-1,true)
	draw_circle(point,2.0,Color("eafff0"),true,-1,true)

## Impulsion du totem de guerre (dorée) ou onde de l'ancien des tribus (cuivrée) : anneau qui grandit en avançant.
func _draw_pulse(point: Vector2, age: float, color: Color) -> void:
	var grow: float = clampf(age/PROJECTILE_FLIGHT,0.0,1.0)
	draw_arc(point,3.0+grow*6.0,0.0,TAU,20,Color(color,0.9-grow*0.4),2.0,true)
	draw_circle(point,2.2,color,true,-1,true)

## Dard de la sarbacane gobeline : fine tige claire à pointe sombre.
func _draw_dart(point: Vector2, direction: Vector2, side: Vector2) -> void:
	draw_line(point-direction*11.0,point,Color("e7d9a8"),1.6,true)
	draw_line(point-direction*11.0,point-direction*8.0+side*2.0,Color("c0504a"),1.2,true)
	draw_line(point-direction*11.0,point-direction*8.0-side*2.0,Color("c0504a"),1.2,true)
	draw_circle(point,1.6,Color("2f3a34"),true,-1,true)

## Pierre de la catapulte gobeline : le dessin du lot de Codex (`pierre.png`), retourné une seule fois selon le côté du tir.
func _draw_stone(point: Vector2, facing: float) -> void:
	draw_set_transform(point,0.0,Vector2(facing,1.0))
	draw_texture_rect(CATAPULT_TEXTURE,Rect2(-CATAPULT_PIVOT_PX*CATAPULT_SCALE,CATAPULT_TEXTURE.get_size()*CATAPULT_SCALE),false)
	draw_set_transform(Vector2.ZERO)

## Éclair du mage de la foudre : tracé brisé depuis la main avancée jusqu'à la cible, puis vers les cibles secondaires réellement touchées.
func _draw_lightning(shot: Dictionary, origin: Vector2, target: Vector2, age: float) -> void:
	var fade: float = 1.0-clampf(age/PROJECTILE_FLIGHT,0.0,1.0)*0.4
	var chains: Array = [[origin,target]]
	var previous: Vector2 = target
	for extra in shot.get("secondary",[]):
		var point: Vector2 = project(extra)+Vector2(0,-12)
		chains.append([previous,point])
		previous = point
	for link in chains:
		var path := _jagged_path(link[0],link[1],int(age*60.0))
		draw_polyline(path,Color(0.55,0.75,1.0,0.45*fade),5.0,true)
		draw_polyline(path,Color(0.92,0.97,1.0,fade),1.8,true)
		# Ramifications : brèves branches de part et d'autre du tracé principal.
		for index in range(1,path.size()-1,2):
			var forward: Vector2 = (path[index+1]-path[index-1]).normalized()
			var side_sign: float = 1.0 if (index/2+int(age*60.0)) % 2 == 0 else -1.0
			var tip: Vector2 = path[index]+(forward*0.5+forward.orthogonal()*side_sign).normalized()*7.0
			draw_line(path[index],tip,Color(0.55,0.75,1.0,0.4*fade),3.0,true)
			draw_line(path[index],tip,Color(0.92,0.97,1.0,0.85*fade),1.1,true)
	# Éclat sur chaque cible réellement touchée.
	for hit in [target]+chains.slice(1).map(func(link): return link[1]):
		var flare: float = fade
		draw_circle(hit,5.0,Color(0.55,0.75,1.0,0.35*flare),true,-1,true)
		draw_circle(hit,2.4,Color(0.95,0.99,1.0,flare),true,-1,true)
		for ray in range(4):
			var spoke: Vector2 = Vector2.RIGHT.rotated(ray*PI/2.0+PI/4.0)
			draw_line(hit+spoke*3.0,hit+spoke*7.0,Color(0.92,0.97,1.0,0.8*flare),1.2,true)

static func _jagged_path(from: Vector2, to: Vector2, seed_value: int) -> PackedVector2Array:
	var path := PackedVector2Array([from])
	var axis: Vector2 = to-from
	var normal: Vector2 = axis.orthogonal().normalized()
	var steps: int = maxi(3,int(axis.length()/9.0))
	for step in range(1,steps):
		var jitter: float = sin(float(seed_value*37+step*91))*5.0
		path.append(from+axis*float(step)/float(steps)+normal*jitter)
	path.append(to)
	return path

## Boulet du bombardier nain (type 13) : sphère de fonte avec fumée de poudre.
func _draw_cannonball(point: Vector2, direction: Vector2) -> void:
	for puff in range(3):
		draw_circle(point-direction*(5.0+puff*5.0),3.5-puff*0.8,Color(0.78,0.78,0.74,0.32-puff*0.08),true,-1,true)
	draw_circle(point,4.6,Color("1d2224"),true,-1,true)
	draw_circle(point+Vector2(-1.4,-1.4),1.6,Color("c7d2cf"),true,-1,true)

## Éclat de cristal du Lance-éclats (type 18) : le dessin du lot de Codex, orienté selon la droite de vol ; le reflet à gauche garde l'éclairage en haut.
func _draw_crystal_shard(point: Vector2, direction: Vector2, facing: float) -> void:
	draw_set_transform_matrix(Transform2D(direction,direction.orthogonal()*facing,point))
	draw_texture_rect(SHARD_TEXTURE,Rect2(-SHARD_PIVOT_PX*SHARD_SCALE,SHARD_TEXTURE.get_size()*SHARD_SCALE),false)
	draw_set_transform(Vector2.ZERO)

## Éclat de contact du Piquier humain (type 14) : bref éclat à la pointe de la pique dessinée dans la planche (aucune pique dessinée par le jeu).
func _draw_pike_contact(origin: Vector2, direction: Vector2, side: Vector2, progress: float) -> void:
	var t: float = clampf(progress,0.0,1.0)
	var fade: float = 1.0-t
	draw_circle(origin,3.6*(1.0-0.4*t),Color(1.0,0.97,0.85,0.55*fade),true,-1,true)
	for index in range(3):
		var spread: float = (float(index)-1.0)*0.7
		var ray: Vector2 = (direction.rotated(spread)*(4.0+7.0*t))
		draw_line(origin+ray*0.4,origin+ray,Color(1.0,1.0,0.92,0.9*fade),1.4,true)
	draw_circle(origin,1.6,Color(1.0,1.0,1.0,fade),true,-1,true)

## Coup de pique de l'ancien rendu (lance-épieu orc, type 20) : la pointe jaillit vers la cible sur 15 px puis se retire.
func _draw_pike_thrust(origin: Vector2, direction: Vector2, side: Vector2, progress: float) -> void:
	var reach: float = sin(PI*clampf(progress,0.0,1.0))*15.0
	var tip: Vector2 = origin+direction*reach
	draw_line(origin-direction*6.0,tip,Color("1a2524"),3.6,true)
	draw_line(origin-direction*6.0,tip,Color("c79a62"),2.0,true)
	var head := PackedVector2Array([tip+direction*6.0,tip+side*2.6,tip-side*2.6])
	draw_colored_polygon(head,Color("dfeae6"))
	draw_line(tip+direction*6.0,tip-direction*1.0,Color(1.0,1.0,1.0,0.6),1.0,true)

## Coup d'épée courte du fantassin squelette : croissant clair qui balaie un arc devant lui. L'épée elle-même est dans le sprite : on ne redessine pas de lame.
func _draw_sword_strike(origin: Vector2, direction: Vector2, _side: Vector2, progress: float) -> void:
	var t: float = clampf(progress,0.0,1.0)
	var center: float = direction.angle()
	var head: float = center+lerpf(-0.95,0.95,t)
	var tail: float = head-0.9
	var fade: float = 1.0-t*0.5
	var radius: float = 15.0
	var base: Vector2 = origin-direction*3.0
	draw_arc(base,radius,tail,head,14,Color(0.96,0.93,0.82,0.38*fade),8.0,true)
	draw_arc(base,radius,tail+0.25,head,12,Color(0.98,0.96,0.88,0.95*fade),3.4,true)
	draw_circle(base+Vector2.from_angle(head)*radius,2.0,Color(1.0,1.0,0.95,fade),true,-1,true)

## Balle de l'arquebusière naine (type 12) : boule de plomb précédée d'un éclat de poudre, sans empennage de flèche.
func _draw_bullet(point: Vector2, direction: Vector2) -> void:
	draw_line(point-direction*9.0,point,Color(1.0,0.82,0.45,0.55),2.2,true)
	draw_circle(point,2.6,Color("2a2d2e"),true,-1,true)
	draw_circle(point+Vector2(-0.8,-0.8),1.0,Color("d8e2dc"),true,-1,true)

## Javeline du lanceur de javeline troll (type 17) : lance droite, sans rotation, au lieu de la hache de sa famille.
func _draw_javelin(point: Vector2, direction: Vector2, side: Vector2, facing: float = 1.0) -> void:
	if JAVELIN_TEXTURE != null:
		# Dessin du lot de Codex : le même sprite que la javeline tenue en main ; le reflet à gauche garde l'éclairage en haut.
		draw_set_transform_matrix(Transform2D(direction,direction.orthogonal()*facing,point))
		draw_texture_rect(JAVELIN_TEXTURE,Rect2(-JAVELIN_PIVOT_PX*JAVELIN_SCALE,Vector2(495.0,60.0)*JAVELIN_SCALE),false)
		draw_set_transform(Vector2.ZERO)
		return
	var tail: Vector2 = point-direction*17.0
	draw_line(tail,point,Color("1a2524"),3.6,true)
	draw_line(tail,point,Color("c79a62"),2.0,true)
	var head := PackedVector2Array([point+direction*7.0,point+side*2.8,point-side*2.8])
	draw_colored_polygon(head,Color("d6e6e0"))
	head.append(head[0])
	draw_polyline(head,Color("1a2524"),1.2,true)
	draw_line(tail,tail+direction*5.0+side*3.0,Color("e0b44a"),1.4,true)
	draw_line(tail,tail+direction*5.0-side*3.0,Color("e0b44a"),1.4,true)

## Pastilles d'état au-dessus de la barre de PV, dans l'ordre marque, pillage, volatilité, centrées avec 18 px d'entraxe.
static func enemy_badges(enemy: Dictionary, elapsed: float) -> Array[String]:
	var badges: Array[String] = []
	if float(enemy.get("marked_until",-1.0)) > elapsed: badges.append("mark")
	if float(enemy.get("loot_until",-1.0)) >= elapsed: badges.append("loot")
	if float(enemy.get("volatile_until",-1.0)) >= elapsed and not enemy.get("exploded",false): badges.append("volatile")
	return badges

func _draw_enemy_badges(enemy: Dictionary, bar_position: Vector2) -> void:
	var badges: Array[String] = enemy_badges(enemy,model.elapsed)
	var textures := {"mark":FX_MARK,"loot":FX_LOOT,"volatile":FX_VOLATILE}
	for index in range(badges.size()):
		var center := Vector2(bar_position.x+12.0+(float(index)-float(badges.size()-1)*0.5)*FX_BADGE_SPACING,bar_position.y-10.0)
		draw_circle(center,FX_BADGE_SIZE.x*0.62,Color(0.05,0.07,0.06,0.78),true,-1,true) # fond sombre : le marqueur reste lisible sur tous les décors
		draw_arc(center,FX_BADGE_SIZE.x*0.62,0.0,TAU,20,FX_BADGE_COLORS[badges[index]],1.6,true)
		draw_texture_rect(textures[badges[index]],Rect2(center-FX_BADGE_SIZE*0.5,FX_BADGE_SIZE),false)

## Explosions de réaction en chaîne : anneau bref et éclats, à la position de l'ennemi mort.
func _draw_volatile_bursts() -> void:
	for event in model.explosion_events:
		var age: float = model.elapsed-float(event.time)
		if age < 0.0 or age >= FX_BURST_DURATION: continue
		var scale: float = (0.7+age/FX_BURST_DURATION*0.5)*clampf(float(event.radius)/1.4,0.8,1.6)
		var size := Vector2(41,27)*scale
		var center: Vector2 = project(event.position)+Vector2(0,-6)
		draw_texture_rect(FX_BURST,Rect2(center-size*0.5,size),false,Color(1,1,1,1.0-age/FX_BURST_DURATION))

## Hache en chaîne : la texture du lot de Codex, partie de l'angle de la planche puis en rotation comme la hache ordinaire ; retournée une seule fois selon le côté du tir.
func _draw_chain_axe(point: Vector2, shot: Dictionary, age: float) -> void:
	var facing: float = shot_facing(shot)
	var start_angle: float = deg_to_rad(float(CHAIN_AXE_ANGLES[aim_pitch(shot)]))
	draw_set_transform(point,(start_angle+age/PROJECTILE_FLIGHT*TAU)*facing,Vector2(facing,1.0))
	draw_texture_rect(CHAIN_AXE_TEXTURE,Rect2(-CHAIN_AXE_PIVOT_PX*CHAIN_AXE_SCALE,CHAIN_AXE_TEXTURE.get_size()*CHAIN_AXE_SCALE),false)
	draw_set_transform(Vector2.ZERO)

func _draw_spinning_axe(point: Vector2, age: float) -> void:
	var rotation: float = age/PROJECTILE_FLIGHT*TAU
	var shaft := Vector2(cos(rotation),sin(rotation))
	var edge: Vector2 = shaft.orthogonal()
	draw_line(point-shaft*6,point+shaft*5,Color("1a2524"),4.0,true)
	draw_line(point-shaft*6,point+shaft*5,Color("d0ac75"),2.5,true)
	var blade := PackedVector2Array([point+shaft*4,point+shaft*7+edge*6,point-shaft*2+edge*7,point-shaft*3+edge*3])
	draw_colored_polygon(blade,Color("c9e5da"))
	blade.append(blade[0])
	draw_polyline(blade,Color("1a2524"),1.4,true)

func _draw_hit_marker(point: Vector2, alpha: float, primary: bool, type: int, age: float) -> void:
	type = Model.family(type)
	var color: Color = [Color("f0d796"),Color("e1e9dc"),Color("90dceb"),Color("a8ddbd"),Color("f2b269"),Color("d1a3ed")][type]
	color.a = alpha
	var spread: float = (5.0 if primary else 3.0)+minf(maxf(age,0.0)/IMPACT_DURATION,1.0)*4.0
	if type == 5:
		var diamond := PackedVector2Array([point+Vector2(0,-spread),point+Vector2(spread*0.65,0),point+Vector2(0,spread),point+Vector2(-spread*0.65,0),point+Vector2(0,-spread)])
		draw_polyline(diamond,color,1.8,true)
	else:
		draw_circle(point,spread,color,false,1.7 if primary else 1.2,true)
		if primary:
			for index in range(4):
				var direction := Vector2.RIGHT.rotated(index*PI/2+PI/4)
				draw_line(point+direction*(spread+2),point+direction*(spread+5),color,1.5,true)
	if age < 0.08: draw_circle(point,2.5 if primary else 1.5,Color(color,alpha*0.8),true,-1,true)

static func launch_delay(shot: Dictionary) -> float:
	return float(LAUNCH_DELAYS.get(int(shot.get("type",-1)),0.0))

func _draw_impact(shot: Dictionary, age: float) -> void:
	var delay: float = launch_delay(shot)
	if delay <= 0.0:
		_draw_impact_body(shot,age,true)
		return
	if age < delay: return
	if age < delay+PROJECTILE_FLIGHT:
		var flight_color: Color = _impact_color(Model.family(shot.type))
		if Model.family(shot.type) == 5 and int(shot.type) != EMBER_TYPE: _draw_cast_bolt(shot,age,flight_color,1.0)
		_draw_projectile(shot,age-delay,flight_color)
		return
	_draw_impact_body(shot,age-delay-PROJECTILE_FLIGHT,false)

## Éclair du chaman : tracé brisé de la main (ou du crâne du bâton) jusqu'à la cible.
func _draw_cast_bolt(shot: Dictionary, age: float, color: Color, alpha: float) -> void:
	var origin: Vector2 = shot_origin(shot,age)
	var target: Vector2 = project(shot.to)+Vector2(0,-12)
	var direction: Vector2 = target-origin
	var side: Vector2 = direction.normalized().orthogonal()
	var bolt := PackedVector2Array([origin,origin+direction*0.3+side*4,origin+direction*0.55-side*4,origin+direction*0.78+side*3,target])
	draw_polyline(bolt,Color(color,alpha*0.65),1.5,true)

## Instant de pose d'une malédiction, déduit de ses tics (aucun état de simulation ajouté).
static func curse_applied_at(curse: Dictionary) -> float:
	return float(curse.next_at)-(3.0-float(curse.ticks_left))

## Types qui infligent une brûlure (Pyromancien humain, Brûleur de cendres) : leurs dégâts sur la durée se dessinent en flammes, pas en anneau de malédiction.
const FIRE_CURSE_TYPES: Array[int] = [15,21]
const BURN_TICK_FLARE := 0.45

func curse_source_type(curse: Dictionary) -> int:
	for defender in model.defenders:
		if not defender.is_empty() and int(defender.get("instance_id",-1)) == int(curse.source_id): return int(defender.type)
	return -1

## Brûlure en cours sur un ennemi : petites langues de flamme qui vacillent (dessinées dans le repère de l'ennemi, centré sur ses pieds).
func _draw_burning(phase: float) -> void:
	for index in range(3):
		var wobble: float = sin(phase*9.0+float(index)*2.1)
		var x: float = (float(index)-1.0)*5.5
		var base: float = -9.0-float(index%2)*3.0
		var height: float = 9.0+3.0*wobble
		var outer := PackedVector2Array([Vector2(x-3.2,base),Vector2(x-1.0+wobble*0.8,base-height*0.55),Vector2(x+wobble,base-height),Vector2(x+1.6,base-height*0.5),Vector2(x+3.2,base)])
		draw_colored_polygon(outer,Color(0.98,0.45,0.12,0.92))
		var inner := PackedVector2Array([Vector2(x-1.6,base),Vector2(x+wobble*0.6,base-height*0.62),Vector2(x+1.6,base)])
		draw_colored_polygon(inner,Color(1.0,0.86,0.32,0.95))

## Éclat orange et nombre qui monte à chaque tic de brûlure (le tic réel du modèle ; amount = PV retirés).
func _draw_burn_tick(center: Vector2, enemy: Dictionary, amount: float, age: float) -> void:
	if age < 0.0 or age >= BURN_TICK_FLARE or amount <= 0.0: return
	var t: float = age/BURN_TICK_FLARE
	var scale: float = _enemy_scale(enemy)
	var body: Vector2 = center+Vector2(0,-14.0*scale)
	draw_circle(body,(7.0+9.0*t)*scale,Color(1.0,0.55,0.15,0.55*(1.0-t)),true,-1,true)
	draw_arc(body,(10.0+8.0*t)*scale,0.0,TAU,20,Color(1.0,0.8,0.35,0.85*(1.0-t)),2.0,true)
	var font: Font = ThemeDB.fallback_font
	var text_point: Vector2 = center+Vector2(0,-39.0*scale-10.0-14.0*t)
	var label: String = "-%d" % int(roundf(amount))
	draw_string_outline(font,text_point+Vector2(-10,0),label,HORIZONTAL_ALIGNMENT_CENTER,20,13,4,Color(0.2,0.05,0.0,1.0-t))
	draw_string(font,text_point+Vector2(-10,0),label,HORIZONTAL_ALIGNMENT_CENTER,20,13,Color(1.0,0.78,0.38,1.0-t))

## L'anneau de malédiction d'un chaman orc apparaît avec l'arrivée de l'éclair, pas au départ du tir (rendu seul : la malédiction existe dès le tir).
func curse_ring_visible(curse: Dictionary) -> bool:
	var source_type := -1
	for defender in model.defenders:
		if not defender.is_empty() and int(defender.get("instance_id",-1)) == int(curse.source_id):
			source_type = int(defender.type);break
	var delay: float = float(LAUNCH_DELAYS.get(source_type,0.0))
	if delay <= 0.0: return true
	return model.elapsed-curse_applied_at(curse) >= delay+PROJECTILE_FLIGHT

static func _impact_color(type: int) -> Color:
	return [Color("f0d796"),Color("e1e9dc"),Color("90dceb"),Color("a8ddbd"),Color("f2b269"),Color("d1a3ed")][type]

func _draw_impact_body(shot: Dictionary, age: float, flight: bool) -> void:
	var alpha: float = impact_opacity(age)
	if alpha <= 0.0 or not shot.has("type"): return
	var type: int = Model.family(shot.type)
	var color: Color = [Color("f0d796"),Color("e1e9dc"),Color("90dceb"),Color("a8ddbd"),Color("f2b269"),Color("d1a3ed")][type]
	color.a = alpha
	var height := Vector2(0,-12)
	var origin: Vector2 = shot_origin(shot)
	var target: Vector2 = project(shot.to)+height
	# L'impact est visible dès le tir : le déplacement bref ne retarde aucun dégât.
	_draw_hit_marker(target,alpha,true,type,age)
	if type == 5 and flight and int(shot.type) != EMBER_TYPE:
		_draw_cast_bolt(shot,age,color,alpha)
	elif type in [0,1,2]:
		draw_line(origin,target,Color(color,alpha*0.22),1 if type != 1 else 1.5,true)
	elif flight:
		var trail := PackedVector2Array()
		for index in range(9): trail.append(projectile_position(shot,PROJECTILE_FLIGHT*index/8.0))
		draw_polyline(trail,Color(color,alpha*0.18),1,true)
	if flight: _draw_projectile(shot,age,color)
	if type in [2,4] and int(shot.type) != LIGHTNING_TYPE:
		var radius: float = shot.get("radius",1.0)
		var ring := range_outline(shot.to,radius)
		# Rayon exact, remplissage discret ; seules les victimes réelles sont marquées.
		draw_colored_polygon(ring,Color(color,alpha*0.045))
		draw_polyline(ring,Color(color,alpha*0.6),1.5,true)
		var inner := range_outline(shot.to,radius*(0.25+0.75*minf(age/0.18,1.0)))
		draw_polyline(inner,Color(color,alpha*0.4),1,true)
	var segments := secondary_segments(shot)
	var bounce_duration := CHAIN_AXE_BOUNCE if int(shot.type) == CHAIN_AXE_TYPE else (IMPACT_DURATION-PROJECTILE_FLIGHT)/maxi(1,segments.size())
	var axe_position := Vector2.INF
	for index in range(segments.size()):
		var segment := segments[index]
		var secondary: Vector2 = segment[1]+height
		if type == 3:
			var start: Vector2 = segment[0]+height
			var progress := (age if int(shot.type) == CHAIN_AXE_TYPE else age-PROJECTILE_FLIGHT)/bounce_duration-index
			draw_line(start,secondary,Color(color,alpha*0.65),1.8,true)
			if progress >= 0.0 and progress < 1.0:
				axe_position = start.lerp(secondary,progress)-Vector2(0.0,sin(PI*progress)*(3.0 if int(shot.type) == CHAIN_AXE_TYPE else 4.0))
		if int(shot.type) != CHAIN_AXE_TYPE or age >= float(index+1)*bounce_duration: _draw_hit_marker(secondary,alpha,false,type,age)
	if axe_position.is_finite():
		if int(shot.type) == CHAIN_AXE_TYPE: _draw_chain_axe(axe_position,shot,PROJECTILE_FLIGHT+age)
		else: _draw_spinning_axe(axe_position,age)


static func enemy_art_id(enemy: Dictionary, defending_faction: int = -1) -> String:
	if defending_faction in [0,1]: return Model.Enemies.for_profile(int(enemy.get("type",1)),defending_faction).id
	if EnemyArt.TEXTURES.has(enemy.get("identity_id","")): return enemy.identity_id
	return Model.Enemies.for_profile(int(enemy.get("type",1)),0).id

static func enemy_bounds(enemy: Dictionary, defending_faction: int = -1, route_points: Array[Vector2] = Model.PATH_POINTS, route_length: float = Model.PATH_LENGTH) -> Rect2:
	var center: Vector2 = project(Model.position_at(enemy.distance,route_points,route_length))
	var scale: float = _enemy_scale(enemy)
	var width: float = maxf(28.0,32.0*scale)
	var bounds := Rect2(center+Vector2(-width/2.0,-39.0*scale),Vector2(width,47.0*scale))
	if EnemyArt.TEXTURES.has(enemy_art_id(enemy,defending_faction)):
		var image: Rect2 = EnemyArt.destination(enemy_art_id(enemy,defending_faction))
		if SheetAnimations.has_animation(enemy_art_id(enemy,defending_faction),"walk"):
			var sheet: Dictionary = SheetAnimations.spec_for(enemy_art_id(enemy,defending_faction))
			image = SheetAnimations.destination(sheet,sheet.animations.walk)
		var facing: float
		if EnemyWalkArt.supports(enemy_art_id(enemy,defending_faction)):
			var motion: Dictionary=EnemyWalkArt.path_motion(enemy.distance,route_points,AXIS)
			image=image.merge(EnemyWalkArt.projected_bounds(motion.direction))
			facing = route_facing(motion.direction)
		else:
			facing = enemy_facing(enemy,route_points,route_length)
		if facing < 0.0: image.position.x = -image.end.x
		bounds = bounds.merge(Rect2(center+image.position*scale,image.size*scale).grow(1.0))
	return bounds.grow(8.0) # Marge fixe couvrant les poses, sans survol qui tremble avec le corps.

static func route_facing(direction: Vector2) -> float:
	return -1.0 if direction.x < 0.0 else 1.0

static func enemy_facing(enemy: Dictionary, route_points: Array[Vector2] = Model.PATH_POINTS, route_length: float = Model.PATH_LENGTH) -> float:
	var distance: float = clampf(enemy.distance,0.0,route_length)
	return route_facing(EnemyWalkArt.path_motion(distance,route_points,AXIS).direction)


func enemy_at(point: Vector2) -> int:
	if model == null: return -1
	var found: int = -1
	var front_y: float = -INF
	for enemy in model.enemies:
		if enemy.hp <= 0.0 or not enemy_bounds(enemy,model.faction,model.enemy_route_points(enemy),model.enemy_route_length(enemy)).has_point(point): continue
		var y: float = project(model.enemy_position(enemy)).y
		if y >= front_y: # Même priorité visuelle que le dessin, dernier acteur en cas d'égalité.
			front_y = y
			found = enemy.id
	return found

static func covered_route(center: Vector2, radius: float, route_points: Array[Vector2] = Model.PATH_POINTS, route_length: float = Model.PATH_LENGTH) -> Array[PackedVector2Array]:
	var sections: Array[PackedVector2Array] = []
	for window in Model.coverage_windows(center, radius, route_points):
		var points := PackedVector2Array([project(Model.position_at(window.first,route_points,route_length))])
		var distance: float = 0.0
		for index in range(1, route_points.size()):
			distance += route_points[index-1].distance_to(route_points[index])
			if distance > window.first + Model.EPS and distance < window.last - Model.EPS:
				points.append(project(route_points[index]))
		points.append(project(Model.position_at(window.last,route_points,route_length)))
		sections.append(points)
	return sections


func synergy_links(candidate: Dictionary = {}) -> Array[Dictionary]:
	var links: Array[Dictionary] = []
	if model == null or selected < 0 or selected >= model.defenders.size(): return links
	var unit: Dictionary = model.defenders[selected] if candidate.is_empty() else candidate
	if unit.is_empty() or int(unit.get("type",-1)) not in model.available_types(): return links
	for rule in Model.Campaign.PROXIMITY + Model.Campaign.SPECIALISATIONS:
		for partner in model.synergy_partners(selected,rule,-1,candidate):
			links.append({"code":rule.code,"partner":partner,"specialised":rule.has("branches")})
	return links

func _draw_synergy_links(candidate: Dictionary = {}) -> void:
	var planned: bool = not candidate.is_empty()
	for link in synergy_links(candidate):
		var offset := Vector2(0,4 if link.specialised else 0)
		var start: Vector2 = project(_map_slots()[selected]) + offset
		var finish: Vector2 = project(_map_slots()[link.partner]) + offset
		var color := Color("8bd5e6") if planned else Color("8cbde0") if link.specialised else Color("e1bb70")
		if planned:
			var length: float = start.distance_to(finish)
			var direction: Vector2 = (finish-start).normalized()
			for step in range(0,int(ceil(length)),12):
				draw_line(start+direction*step,start+direction*minf(step+7,length),color,2,true)
		else:
			draw_line(start,finish,Color(color,0.65),2,true)
		draw_circle(finish,7 if planned else 5,color,false,2,true)

func polygon(points: Array[Vector2], color: Color) -> void:
	var projected := PackedVector2Array()
	for point in points:
		projected.append(project(point))
	draw_colored_polygon(projected, color)

func _map_slots() -> Array[Vector2]:
	return model.slots if model != null else Model.SLOTS

func _map_path() -> Array[Vector2]:
	return model.path_points if model != null else Model.PATH_POINTS

## Tronçons inondés projetés à l'écran, un tracé par tronçon.
static func flooded_polylines(definition: Dictionary) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	for stretch in definition.get("flooded",[]):
		var points: Array[Vector2] = []
		var length: float = definition.path_length
		if definition.has("routes"):
			for route in definition.routes:
				if route.id == stretch.route: points.assign(route.path_points);length = route.path_length
		else: points.assign(definition.path_points)
		if points.is_empty(): continue
		var line := PackedVector2Array()
		var steps: int = maxi(2,ceili((float(stretch.to)-float(stretch.from))*4.0))
		for step in range(steps+1): line.append(project(Model.position_at(lerpf(float(stretch.from),float(stretch.to),float(step)/steps),points,length)))
		result.append(line)
	return result

static func routes_for(definition: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if definition.has("routes"): result.assign(definition.routes)
	else: result.append({"id":"main","path_points":definition.path_points,"path_length":definition.path_length})
	return result

func map_covered_routes(center: Vector2, radius: float) -> Array[PackedVector2Array]:
	var sections: Array[PackedVector2Array] = []
	for route in routes_for(model.map_definition):
		var points: Array[Vector2] = [];points.assign(route.path_points)
		sections.append_array(covered_route(center,radius,points,route.path_length))
	return sections

func entry_coverage_percentages(center: Vector2, radius: float) -> Array[int]:
	var percentages: Array[int] = []
	for route in model.routes:
		var points: Array[Vector2] = []
		points.assign(route.path_points)
		var length := 0.0
		for window in Model.coverage_windows(center,radius,points):
			length += window.last-window.first
		percentages.append(clampi(roundi(100.0*length/route.path_length),0,100))
	return percentages

static func _segment_in_rect(first: Vector2, last: Vector2, area: Rect2) -> bool:
	if area.has_point(first) or area.has_point(last): return true
	var corners: Array[Vector2] = [area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(first,last,corners[index],corners[(index+1)%4]) != null: return true
	return false

static func scenery_bounds(item: Dictionary) -> Rect2:
	var center: Vector2 = project(item.point)
	if item.kind in ["willow","ruin","reeds"]: return MarshArt.bounds(center,item.kind)
	return Rect2(center+Vector2(-16,-46),Vector2(32,60)) if item.kind == "pine" else Rect2(center+Vector2(-13,-14),Vector2(26,23))

static func scenery_for(definition: Dictionary) -> Array[Dictionary]:
	# Habillage des nouveaux terrains uniquement. Aucun tirage du générateur de combat.
	var result: Array[Dictionary] = []
	var mountain: bool = definition.get("decoration","") == "mountain"
	var marsh: bool = definition.get("decoration","") == "marsh"
	if not mountain and not marsh and definition.get("id","") not in Model.Maps.CHAPTER_ONE_MAPS: return result
	if not Model.Maps.validation_error(definition).is_empty(): return result
	var board := PackedVector2Array([project(Vector2.ZERO),project(Vector2(definition.size.x,0)),project(Vector2(definition.size)),project(Vector2(0,definition.size.y))])
	var reserved: Array[Rect2] = [fortress_bounds(project(definition.path_points[-1])).grow(12)]
	for route in routes_for(definition): reserved.append(Rect2(project(route.path_points[0])+Vector2(-60,-43),Vector2(116,65)))
	for slot in definition.slots: reserved.append(Rect2(project(slot)+Vector2(-44,-78),Vector2(88,110)))
	var candidates: Array[Dictionary] = []
	var seed_value: int = absi(String(definition.id).hash())
	for x in range(12):
		for y in range(7):
			var order: int = (x*29+y*47+seed_value)%101
			var kind: String = ["pine","shrub","rock"][order%3]
			if marsh: kind = ["reeds","ruin","willow"][order%3]
			if mountain and kind == "shrub": kind = "rock"
			candidates.append({"point":Vector2(0.8+x*1.45,0.8+y*1.35),"kind":kind,"order":order})
	candidates.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.order < b.order)
	for candidate in candidates:
		var area: Rect2 = scenery_bounds(candidate)
		var clear: bool = true
		for corner in [area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]:
			if not Geometry2D.is_point_in_polygon(corner,board): clear = false;break
		if not clear: continue
		for exclusion in reserved:
			if area.intersects(exclusion): clear = false;break
		if not clear: continue
		for route in routes_for(definition):
			for segment in range(1,route.path_points.size()):
				if _segment_in_rect(project(route.path_points[segment-1]),project(route.path_points[segment]),area.grow(20)): clear = false;break
			if not clear: break
		if not clear: continue
		for placed in result:
			if area.grow(7).intersects(scenery_bounds(placed)): clear = false;break
		if clear: result.append(candidate)
		if result.size() >= 22: break
	# Sur un terrain encombré, une ruine plus compacte remplace un saule déjà dégagé.
	# Ses limites sont incluses dans celles de l'arbre : les marges restent préservées.
	if marsh and not result.any(func(item):return item.kind=="ruin"):
		for item in result:
			if item.kind=="willow": item.kind = "ruin";break
	result.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return project(a.point).y < project(b.point).y)
	return result

func _draw_terrain_detail(item: Dictionary) -> void:
	var center: Vector2 = project(item.point)
	if item.kind in ["willow","ruin","reeds"]:
		MarshArt.draw_detail(self,center,item.kind)
		return
	if item.kind == "pine": _draw_tree(center);return
	if item.kind == "rock":
		draw_colored_polygon(PackedVector2Array([center+Vector2(-12,2),center+Vector2(-7,-9),center+Vector2(3,-13),center+Vector2(12,-3),center+Vector2(10,4),center+Vector2(-2,7)]),Color("697765"))
		draw_colored_polygon(PackedVector2Array([center+Vector2(-7,-9),center+Vector2(3,-13),center+Vector2(12,-3),center]),Color("95a08a"))
		draw_line(center+Vector2(3,-13),center,Color("52634f"),2,true)
	else:
		draw_circle(center+Vector2(-6,-2),6,Color("2b5140"))
		draw_circle(center+Vector2(5,-4),7,Color("496e50"))
		draw_circle(center+Vector2(0,-8),5,Color("5f8154"))
		if item.order%2 == 0:
			draw_circle(center+Vector2(-4,-6),1.5,Color("d6be78"))
			draw_circle(center+Vector2(6,-8),1.5,Color("d6be78"))

func _draw() -> void:
	walking_meshes.begin_frame()
	var definition: Dictionary = model.map_definition if model != null else Model.Maps.valley()
	var mountain: bool = definition.decoration == "mountain"
	var marsh: bool = definition.decoration == "marsh"
	var citadel: bool = definition.decoration == "citadel" # Repères de couleur neutres, habillage par faction à produire (TODO_VISUELS.md).
	var volcanic: bool = definition.decoration == "volcanic" # Repères de couleur neutres, habillage à produire (TODO_VISUELS.md).
	var board: Vector2i = definition.size
	var ghost: Dictionary = purchase_ghost()
	var corners: Array[Vector2] = [Vector2.ZERO, Vector2(board.x, 0), Vector2(board.x, board.y), Vector2(0, board.y)]
	var base := PackedVector2Array()
	for corner in corners:
		base.append(project(corner) + Vector2(0, 16))
	draw_colored_polygon(base, Color("172c2b"))
	var palette: Dictionary = DecorArt.palette(str(definition.decoration),model.faction if model != null else 0)
	# Deux faces donnent de l'épaisseur au plateau, sans déplacer sa surface logique.
	for edge in [[corners[1],corners[2],Color("315247") if marsh else Color("4a403d") if volcanic else Color("4a4a52") if citadel else Color("34444c") if mountain else Color("263e34")],[corners[2],corners[3],Color("233e37") if marsh else Color("352e2d") if volcanic else Color("35353c") if citadel else Color("27363f") if mountain else Color("1c322c")]]:
		var first: Vector2 = project(edge[0])
		var last: Vector2 = project(edge[1])
		var face_color: Color = edge[2] if palette.is_empty() else palette.face_right if edge[0] == corners[1] else palette.face_left
		draw_colored_polygon(PackedVector2Array([first,last,last+Vector2(0,16),first+Vector2(0,16)]),face_color)
	polygon(corners, palette.ground if not palette.is_empty() else MarshArt.GROUND if marsh else Color("3d3837") if volcanic else Color("55555d") if citadel else Color("4a5b65") if mountain else Color("3a513e"))
	if marsh: MarshArt.draw_ground(self,project,false,definition.get("water_areas",MarshArt.POOLS))
	for x in range(board.x+1):
		draw_line(project(Vector2(x, 0)), project(Vector2(x, board.y)), Color(0.75, 0.86, 0.7, 0.055), 1)
	for y in range(board.y+1):
		draw_line(project(Vector2(0, y)), project(Vector2(board.x, y)), Color(0.75, 0.86, 0.7, 0.055), 1)
	if definition.decoration == "valley": _draw_valley_water()
	var ash: Dictionary = DecorArt.overlay(str(definition.decoration))
	if not ash.is_empty(): draw_texture(ash.texture,ash.position) # Cendres : après la couleur du sol, avant la chaussée.
	var screen_routes: Array[PackedVector2Array] = []
	for entry in routes_for(definition):
		var route := PackedVector2Array()
		for point in entry.path_points: route.append(project(point))
		screen_routes.append(route)
	for route in screen_routes: draw_polyline(route,Color("2d3a42") if mountain else Color("26372e"),28,true)
	for route in screen_routes:
		draw_polyline(route,MarshArt.ROAD if marsh else Color("b3a17b"),20,true)
		for point in route: draw_circle(point,10,MarshArt.ROAD if marsh else Color("b3a17b"))
	for route in screen_routes: draw_polyline(route,Color("c7b58d"),2,true)
	# Tronçons inondés : repère fonctionnel provisoire, habillage à produire (TODO_VISUELS.md).
	var water: Dictionary = DecorArt.water_overlay_for(definition)
	if not water.is_empty():
		draw_texture(water.texture,water.position) # Calque d'eau de Codex, au-dessus de la chaussée et de ses joints, sous emplacements et unités.
	else:
		for line in flooded_polylines(definition):
			draw_polyline(line,Color(0.22,0.5,0.58,0.62),20,true)
			draw_polyline(line,Color(0.55,0.82,0.88,0.55),2,true)
	if marsh:
		var paths: Array = routes_for(definition).map(func(route):return route.path_points)
		MarshArt.draw_joints(self,project,paths)
	var highlighted_segments := {}
	for index in highlighted_entries:
		if index < 0 or index >= screen_routes.size():
			continue
		var route := screen_routes[index]
		for step in range(1, route.size()):
			var start := route[step-1]
			var finish := route[step]
			var segment := Vector4(start.x, start.y, finish.x, finish.y)
			var tint := Color("f2dfb2") if highlighted_segments.has(segment) else entry_color(index)
			highlighted_segments[segment] = tint
	for segment: Vector4 in highlighted_segments:
		draw_line(Vector2(segment.x, segment.y), Vector2(segment.z, segment.w), highlighted_segments[segment], 5.0, true)
	if definition.decoration == "valley": _draw_valley_bridge()
	for tree in definition.trees:
		_draw_tree(project(tree))
	for item in terrain_details: _draw_terrain_detail(item)
	var preview: Dictionary = purchase_preview if not purchase_preview.is_empty() else upgrade_preview
	if model != null and selected >= 0 and not preview.is_empty():
		var preview_ring := range_outline(_map_slots()[selected], preview.range)
		draw_colored_polygon(preview_ring, Color(0.35, 0.8, 0.95, 0.12))
		draw_polyline(preview_ring, Color("8bd5e6"), 2.5, true)
		for section in map_covered_routes(_map_slots()[selected],preview.range):
			draw_polyline(section, Color("8bd5e6"), 6, true)
		if not preview_synergy_unit.is_empty(): _draw_synergy_links(preview_synergy_unit)
	if model != null and selected >= 0 and not model.defenders[selected].is_empty():
		var stats: Dictionary = model.get_stats(selected)
		var shown_range: float = float(stats.range)*model.range_factor_now() # Rafale de sable : l'anneau montre la portée réduite.
		var ring := range_outline(_map_slots()[selected], shown_range)
		draw_colored_polygon(ring, Color(0.8, 0.85, 0.5, 0.05))
		draw_polyline(ring, Color(0.8, 0.85, 0.5, 0.35), 1.5, true)
		if preview.is_empty():
			for section in map_covered_routes(_map_slots()[selected],shown_range):
				draw_polyline(section,Color(0.9,0.77,0.48,0.65),4,true)
		if preview.is_empty(): _draw_synergy_links()
	for index in range(_map_slots().size()):
		var center: Vector2 = project(_map_slots()[index])
		var diamond := PackedVector2Array([center + Vector2(-26, 0), center + Vector2(0, -13), center + Vector2(26, 0), center + Vector2(0, 13)])
		draw_colored_polygon(diamond, SLOT_FILL)
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color("ddbd78") if selected == index else Color("779b89"), 2, true)
		var occupied: bool = model != null and not model.defenders[index].is_empty()
		occupied = occupied or (not ghost.is_empty() and ghost.slot == index)
		draw_string(font, center + Vector2(-9, 22 if occupied else 5), "E%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)
	_draw_fortress(project(_map_path()[-1]))
	for index in range(screen_routes.size()):
		var entrance: Vector2 = screen_routes[index][0]
		if index in highlighted_entries:
			draw_arc(entrance, 9.0, 0.0, TAU, 24, entry_color(index), 2.0, true)
		draw_circle(entrance,5,Color("debd7f") if screen_routes.size()==1 else entry_color(index))
		if screen_routes.size()==1: draw_string(font,entrance+Vector2(-48,-20),"ENTRÉE",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("a7b8aa"))
	if model != null:
		var protection_positions: Dictionary = {}
		for enemy in model.enemies:
			if model.active and not model.protection_events.is_empty():
				protection_positions[enemy.id] = model.enemy_position(enemy)
			if enemy.type != Model.Banks.GUARD_TYPE: continue
			var ring := PackedVector2Array()
			var center: Vector2 = model.enemy_position(enemy)
			for step in range(49): ring.append(project(center+Vector2.from_angle(TAU*step/48)*Model.Banks.RADIUS))
			draw_polyline(ring,Color(0.62,0.79,0.43,0.42),1.4,true)
		for link in inspected_protection_links():
			draw_line(project(link.from)+Vector2(0,-12),project(link.to)+Vector2(0,-12),Color(0.72,0.89,0.56,0.65),1.5,true)
			draw_arc(project(link.from)+Vector2(0,3),12,0,TAU,32,Color("b8d889"),1.5,true)
		_draw_eruption_warning()
		_draw_sandstorm()
		_draw_rockfall()
		_draw_seamist()
		_draw_decor_props(model.map_definition)
		var actors: Array[Dictionary] = []
		for slot in range(model.defenders.size()):
			if not model.defenders[slot].is_empty():
				actors.append({"point": project(_map_slots()[slot]), "defender": model.defenders[slot],"slot":slot,"order":actors.size()})
		for enemy in model.enemies:
			actors.append({"point": project(model.enemy_position(enemy)), "enemy": enemy,"order":actors.size()})
		if not ghost.is_empty(): actors.append({"point":ghost.point,"ghost":ghost,"order":actors.size()})
		actors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order if a.point.y == b.point.y else a.point.y < b.point.y)
		for actor in actors:
			if actor.has("ghost"):
				_draw_purchase_ghost(actor.ghost)
			elif actor.has("defender"):
				if model.guardian_aura(actor.slot) > 0.0: draw_texture_rect(FX_AURA,Rect2(actor.point+Vector2(-13.0,-3.0),Vector2(26,17)),false)
				_draw_defender(actor.point, actor.defender.type, actor.defender.get("level", 1), actor.defender.get("branch", -1), defender_pose(actor.slot))
			else:
				if Model.enemy_is_slowed(actor.enemy): draw_texture_rect(FX_SLOW,Rect2(actor.point+Vector2(-19.0,-7.0),Vector2(38,19)),false)
				var feedback: Array[Dictionary] = recent_enemy_damage(actor.enemy.id)
				_draw_pillager(actor.point, actor.enemy,enemy_hit_strength(feedback),enemy_reaction_pose(actor.enemy,feedback,model.elapsed))
				var ratio: float = clampf(visual_hp(actor.enemy) / actor.enemy.get("max_hp", 40.0), 0.0, 1.0)
				var bar_position: Vector2 = actor.point + Vector2(-12, -39 * _enemy_scale(actor.enemy))
				draw_rect(Rect2(bar_position, Vector2(24, 4)), Color("472f2a"))
				draw_rect(Rect2(bar_position, Vector2(24 * ratio, 4)), Color("edcc80") if actor.enemy.id == inspected_enemy_id else Color("a1ba75"))
				_draw_enemy_badges(actor.enemy,bar_position)
				for event in feedback:
					if str(event.get("component","")) == "curse" and int(event.get("source_type",-1)) in FIRE_CURSE_TYPES:
						_draw_burn_tick(actor.point,actor.enemy,float(event.hp_before)-float(event.hp_after),event_age(event))
				for event in feedback:
					var span: Vector2 = damage_span(event,actor.enemy.get("max_hp",40.0))
					if span.y > span.x:
						draw_rect(Rect2(bar_position+Vector2(24*span.x,0),Vector2(24*(span.y-span.x),4)),Color(Color("f3dfba"),damage_opacity(event_age(event))))
		_draw_volatile_bursts()
		_draw_eruption()
		_draw_headwinds()
		if model.active:
			for event in model.protection_events:
				var age: float = model.elapsed-event.time
				if age < 0.0 or age >= 0.4: continue
				var from: Vector2 = protection_positions.get(event.get("protected_id", -1),event.from)
				var to: Vector2 = protection_positions.get(event.get("guardian_id", -1),event.to)
				draw_line(project(from)+Vector2(0,-12),project(to)+Vector2(0,-12),Color(0.83,0.96,0.52,(1.0-age/0.4)*0.85),2,true)
			for shot in model.shots:
				_draw_impact(shot, model.elapsed - shot.time)
		_draw_eliminations()
		_draw_sold_defenders()
	_draw_affix_banner()
	for entry in entry_label_layouts():
		var box:=StyleBoxFlat.new();box.bg_color=Color("10271f");box.border_color=entry.color
		box.set_border_width_all(1);box.set_corner_radius_all(5)
		draw_style_box(box,entry.area)
		draw_string(font,entry.area.position+Vector2(8,17),entry.title,HORIZONTAL_ALIGNMENT_LEFT,-1,12,entry.color)
		if not entry.detail.is_empty(): draw_string(font,entry.area.position+Vector2(8,35),entry.detail,HORIZONTAL_ALIGNMENT_LEFT,-1,12,INK)
	if not breach_feedback.is_empty(): _draw_breach_feedback()
	walking_meshes.end_frame()

## Éliminations récentes : planche de mort quand l'ennemi en a une pour sa direction, sinon fondu de sa pose courante (orientation et équipement conservés)
## et bref éclat, regroupé quand plusieurs ennemis ordinaires tombent au même endroit au même moment.
func _draw_eliminations() -> void:
	var bursts: Array[Dictionary] = []
	for effect in recent_eliminations(maxf(BOSS_ELIMINATION_DURATION,SheetAnimations.death_window())):
		var event: Dictionary = effect.event
		var age: float = effect.age
		var type: int = int(event.type)
		var id: String = enemy_art_id({"type":type},model.faction)
		var spec: Dictionary = SheetAnimations.spec_for(id)
		var enemy := {"id":event.enemy_id,"type":type,"distance":float(event.get("distance",0.0)),"route_id":event.get("route_id",""),"hp":0.0}
		var motion := EnemyWalkArt.path_motion(enemy.distance,model.enemy_route_points(enemy),AXIS)
		var state: String = SheetAnimations.death_state(spec,motion.get("direction",Vector2.ZERO))
		if state != "" and age >= 0.0:
			_draw_sheet_death(id,state,event,age)
			continue
		var duration: float = elimination_duration(type)
		if age < 0.0:
			# Le projectile n'est pas encore arrivé : l'ennemi reste à l'écran, intact, à l'endroit de sa chute.
			if type not in BOSS_TYPES: _draw_fading_enemy(enemy,event,0.0,duration,false,false)
			continue
		if age >= duration: continue
		if type not in BOSS_TYPES: _draw_fading_enemy(enemy,event,age,duration,type in ELITE_TYPES)
		var point: Vector2 = project(event.point)
		var merged: bool = false
		if type not in BOSS_TYPES and type not in ELITE_TYPES:
			for burst in bursts:
				if burst.point.distance_to(point) < BURST_MERGE_DISTANCE and absf(float(burst.age)-age) < 0.08:
					burst.crowd += 1;merged = true;break
		if not merged: bursts.append({"event":event,"age":age,"point":point,"crowd":1})
	for burst in bursts:
		for particle in elimination_particles(burst.event,burst.age,burst.crowd):
			draw_circle(particle.point,particle.radius,Color(Color("d6c7a6"),particle.alpha))

## Pose courante de l'ennemi éliminé, qui s'éclaircit jusqu'à disparaître ; les élites fléchissent légèrement sur place.
func _draw_fading_enemy(enemy: Dictionary, event: Dictionary, age: float, duration: float, flex: bool, flash: bool = true) -> void:
	var t: float = clampf(age/duration,0.0,1.0)
	_ghost_alpha = 1.0-t
	_ghost_squash = 1.0-0.14*sin(PI*t) if flex else 1.0
	_draw_pillager(project(event.point),enemy,(1.0-t)*0.5 if flash else 0.0,{})
	_ghost_alpha = 1.0
	_ghost_squash = 1.0

func _enemy_tint(hit_strength: float) -> Color:
	var color: Color = EnemyArt.tint(hit_strength)
	color.a = _ghost_alpha
	return color

func entry_label_layouts() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if model==null or model.routes.size()<2: return result
	var font: Font=ThemeDB.fallback_font
	var busiest_route := ""
	var highest_count := 0
	for entry in entry_forecast:
		if entry.count > highest_count:
			highest_count = entry.count
			busiest_route = entry.route_id
		elif entry.count == highest_count:
			busiest_route = ""
	for index in range(model.routes.size()):
		var title: String="ENTRÉE %d"%(index+1)
		var route_id: String = model.routes[index].id
		if route_id == busiest_route:
			title += " · PRINCIPALE"
		var detail: String=""
		for entry in entry_forecast:
			if entry.route_id==route_id: detail="%d ennemi%s"%[entry.count,"" if entry.count==1 else "s"]
		var width: float=maxf(92.0,maxf(font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x,font.get_string_size(detail,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x)+16.0)
		var height: float=24.0 if detail.is_empty() else 44.0
		var origin: Vector2=project(model.routes[index].path_points[0])+Vector2(-width/2.0,-76.0-height)
		result.append({"area":Rect2(origin,Vector2(width,height)),"title":title,"detail":detail,"color":entry_color(index)})
	return result

static func entry_color(index: int) -> Color:
	return [Color("e5c779"),Color("83c4c6"),Color("c8a6e3")][index%3]

static func breach_text(count: int, damage: int) -> String:
	return "−%d PV · %d ennemi%s passé%s" % [damage,count,"" if count == 1 else "s","" if count == 1 else "s"]

func _draw_breach_feedback() -> void:
	var area: Rect2 = fortress_bounds(project(_map_path()[-1]))
	var center: Vector2 = fortress_center(project(_map_path()[-1]))
	var warning := Color("ef9b89")
	draw_rect(area.grow(3),Color(warning,0.75),false,2)
	var text: String = breach_text(breach_feedback.count,breach_feedback.damage)
	var width: float = font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x+24
	var box := Rect2(Vector2(center.x-width/2.0,area.position.y-36),Vector2(width,30))
	draw_rect(box,Color("35241f"))
	draw_rect(box,warning,false,1)
	draw_string(font,box.position+Vector2(12,21),text,HORIZONTAL_ALIGNMENT_LEFT,-1,15,warning)

const UNIT_INK := Color("192a2b")
const ATTACK_POSE_DURATION := 0.26
const ERUPTION_EFFECT_ID := "effect.eruption"
const REGEN_EFFECT_ID := "effect.regeneration"
const STORM_EFFECT_ID := "effect.sandstorm"
## Repères d'effets de la boutique (Codex, 14 novembre 2026) : dimensions d'affichage de la fiche `design/Visuels_Effets_Boutique.md`.
const FX_SLOW := preload("res://assets/effects/shop/slow.png")
const FX_MARK := preload("res://assets/effects/shop/mark.png")
const FX_LOOT := preload("res://assets/effects/shop/loot.png")
const FX_VOLATILE := preload("res://assets/effects/shop/volatile.png")
const FX_AURA := preload("res://assets/effects/shop/aura.png")
const FX_BURST := preload("res://assets/effects/shop/volatile_burst.png")
const FX_BADGE_SIZE := Vector2(22,22) # lisibilité (v0.223) : 16 px était trop petit dans une grosse bataille
const FX_BADGE_SPACING := 26.0
const FX_BADGE_COLORS: Dictionary = {"mark":Color(1.0,0.45,0.62),"loot":Color(1.0,0.82,0.3),"volatile":Color(1.0,0.55,0.15)}
const FX_BURST_DURATION := 0.45
const ROCKFALL_EFFECT_ID := "effect.rockfall"
const SEAMIST_EFFECT_ID := "effect.seamist"
# Recul horizontal, inclinaison en radians, élévation : habillage des tirs résolus.
const ATTACK_MOTIONS: Array[Vector3] = [
	Vector3(2.8,-0.035,0.0), # Archer : traction et petit recul.
	Vector3(4.0,-0.025,0.0), # Arbalétrier : recul plus sec.
	Vector3(0.8,0.015,2.5), # Mage : légère élévation de l'incantation.
	Vector3(2.0,0.070,1.0), # Troll : engagement du corps dans le lancer.
	Vector3(1.6,0.055,2.0), # Sapeur : lancer avec petit bond.
	Vector3(0.8,-0.025,2.5), # Chaman : élévation et bascule du totem.
]

# Animation issue des tirs réels, dans le temps simulé. Aucune horloge ni RNG de jeu modifiée.
static func attack_pulse(age: float) -> float:
	if age < 0.0 or age >= ATTACK_POSE_DURATION: return 0.0
	return sin(PI * age / ATTACK_POSE_DURATION)

## Chemins de toutes les routes de la carte (le chemin unique en repli).
func _all_route_points() -> Array:
	var result: Array = []
	if model == null: return result
	if model.routes.is_empty(): result.append(model.path_points)
	else:
		for route in model.routes: result.append(route.path_points)
	return result

## Côté (-1 gauche, +1 droite, 0 si indéterminé) vers lequel un défenseur placé en `slot_point` fait face par défaut : le point le plus proche
## de la route, cherché sur chaque tronçon de chaque route en coordonnées du plateau, puis comparé à l'écran. Les égalités gardent l'ordre de la carte.
static func road_facing(slot_point: Vector2, routes: Array) -> float:
	var best_point: Vector2 = road_point(slot_point,routes)
	if best_point == slot_point and routes.is_empty(): return 0.0
	var dx: float = project(best_point).x-project(slot_point).x
	if absf(dx) < 0.01: return 0.0
	return -1.0 if dx < 0.0 else 1.0

## Point de route le plus proche de `slot_point` (le point lui-même si aucune route).
static func road_point(slot_point: Vector2, routes: Array) -> Vector2:
	var best_distance: float = INF
	var best_point: Vector2 = slot_point
	for points in routes:
		for index in range(points.size()-1):
			var start: Vector2 = points[index]
			var segment: Vector2 = points[index+1]-start
			var length_squared: float = segment.length_squared()
			var along: float = 0.0 if length_squared <= 0.0 else clampf((slot_point-start).dot(segment)/length_squared,0.0,1.0)
			var nearest: Vector2 = start+segment*along
			var distance: float = slot_point.distance_squared_to(nearest)
			if distance < best_distance-0.000001:
				best_distance = distance;best_point = nearest
	return best_point

func defender_pose(slot: int) -> Dictionary:
	var pose: Dictionary = {"pulse":0.0,"direction":1.0}
	if model == null or slot < 0 or slot >= model.defenders.size(): return pose
	var defender: Dictionary = model.defenders[slot]
	# Garde par défaut (décision du porteur, 15 novembre 2026) : face au tronçon de route le plus proche, au placement et entre les vagues.
	# Pendant la vague, la direction de la dernière cible garde la priorité.
	var road: float = road_facing(model.slots[slot],_all_route_points())
	if road != 0.0: pose.direction = road
	if defender.has("last_target_position") and (model.active or road == 0.0):
		pose.direction = shot_facing({"from": model.slots[slot], "to": defender.last_target_position})
	if int(defender.get("type",-1)) == STONE_TYPE:
		# Catapulte : vue de garde selon la dernière cible, sinon le point de route le plus proche.
		var watched: Vector2 = road_point(model.slots[slot],_all_route_points())
		if defender.has("last_target_position") and (model.active or road == 0.0): watched = defender.last_target_position
		pose.idle_variant = "idle"+catapult_view(model.slots[slot],watched)
	var event: Dictionary = _defender_events.get(slot,{})
	if not event.is_empty():
		pose[str(event.kind)+"_age"] = Time.get_ticks_msec()/1000.0-float(event.start)
	if not model.active: return pose
	var eruption: Dictionary = model.eruption_status()
	if not eruption.is_empty() and eruption.state == "active" and eruption.slot == slot:
		pose.disabled = true
		pose.disabled_age = float(model.combat_affix.duration)-float(eruption.remaining)
	# Garder le côté du dernier tir de cet emplacement après la fin du mouvement.
	for index in range(model.shots.size()-1,-1,-1):
		var shot: Dictionary = model.shots[index]
		var age: float = model.elapsed-shot.time
		if shot.slot != slot or age < 0.0: continue
		pose.pulse = attack_pulse(age)
		pose.attack_age = age
		pose.direction = shot_facing(shot)
		if int(shot.get("type",-1)) in TILTED_TYPES: pose.attack_variant = aim_variant(aim_pitch(shot))
		if int(shot.get("type",-1)) == SPEARMAN_TYPE: pose.attack_variant = spear_variant(shot)
		if int(shot.get("type",-1)) == STONE_TYPE:
			var view: String = catapult_view(shot.from,shot.to)
			pose.attack_variant = "attack"+view
			pose.idle_variant = "idle"+view
		if shot.get("type", -1) == 0:
			pose.archer_stage = AllianceArt.archer_shot_stage(age, defender.ready_at-shot.time)
		elif shot.get("type", -1) == 1:
			pose.crossbow_reload = age >= ATTACK_POSE_DURATION and age < minf(0.72, (defender.ready_at-shot.time)*0.8)
		elif shot.get("type", -1) == 2 and age < ATTACK_POSE_DURATION:
			pose.staff_flash = 1.0-smoothstep(0.0, ATTACK_POSE_DURATION, age)
		break
	return pose

static func attack_transform(type: int, pose: Dictionary) -> Transform2D:
	type = Model.family(type)
	var pulse: float = clampf(pose.get("pulse",0.0),0.0,1.0)
	var direction: float = pose.get("direction",1.0)
	var motion: Vector3 = ATTACK_MOTIONS[type]
	return Transform2D(motion.y*pulse*direction,Vector2(direction,1.0),0.0,Vector2(-direction*motion.x*pulse,-motion.z*pulse))

func _unit_shape(points: Array[Vector2], color: Color, width: float = 1.5) -> void:
	var contour := PackedVector2Array(points)
	draw_colored_polygon(contour,color)
	contour.append(contour[0])
	draw_polyline(contour,UNIT_INK,width,true)

func _unit_disk(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center,radius,UNIT_INK,true,-1,true)
	draw_circle(center,radius-1.2,color,true,-1,true)

func _unit_stroke(from: Vector2, to: Vector2, color: Color, width: float = 3.0) -> void:
	draw_line(from,to,UNIT_INK,width+2.0,true)
	draw_line(from,to,color,width,true)

func _unit_face(skin: Color, wide: float, y: float, tusks: bool = false) -> void:
	_unit_disk(Vector2(0,y),wide,skin)
	draw_line(Vector2(-3,y-1),Vector2(-1,y-1),UNIT_INK,1.5,true)
	draw_line(Vector2(2,y-1),Vector2(4,y-1),UNIT_INK,1.5,true)
	if tusks:
		for side in [-1,1]:
			_unit_shape([Vector2(side*4,y+5),Vector2(side*5,y),Vector2(side*2,y+4)],Color("fff0c9"),0.8)

func _draw_purchase_ghost(ghost: Dictionary) -> void:
	var art = defender_art(ghost.type)
	if not art.TEXTURES.has(ghost.type): return
	var alpha: float = 0.52 if ghost.available else 0.34
	draw_set_transform(ghost.point+Vector2(0,2),0,Vector2(1,0.45))
	draw_arc(Vector2.ZERO,13,0,TAU,32,Color(Color("8bd5e6"),alpha),1.5,true)
	draw_set_transform(ghost.point)
	draw_texture_rect_region(art.TEXTURES[ghost.type],art.destination(ghost.type),art.FRAMES[ghost.type].source,Color(0.76,0.97,1.0,alpha))
	draw_set_transform(Vector2.ZERO)

func _draw_defender(center: Vector2, type: int, level: int = 1, branch: int = -1, pose: Dictionary = {}) -> void:
	var art = defender_art(type)
	if not art.TEXTURES.has(type): return
	_draw_illustrated_defender(center,type,pose,art)
	_draw_level_badge(center,level,branch)

func _draw_illustrated_defender(center: Vector2, type: int, pose: Dictionary, art: GDScript) -> void:
	draw_set_transform(center+Vector2(0,2),0,Vector2(1,0.45))
	draw_circle(Vector2.ZERO,12,Color(0,0,0,0.25),true,-1,true)
	var sheet_id: String = SheetAnimations.defender_id(type)
	var sheet: Dictionary = SheetAnimations.spec_for(sheet_id)
	if not sheet.is_empty() and SheetAnimations.defender_state(sheet,pose) != "":
		_draw_sheet_defender(center,sheet_id,sheet,pose)
		return
	var transform: Transform2D = attack_transform(type,pose)
	transform.origin += center
	draw_set_transform_matrix(transform)
	var texture: Texture2D = AllianceArt.ARCHER_SHOT_TEXTURES[pose.get("archer_stage", 0)] if type == 0 else art.TEXTURES[type]
	if type == 1 and pose.get("crossbow_reload", false):
		texture = AllianceArt.CROSSBOW_RELOAD_TEXTURE
	draw_texture_rect_region(texture,art.destination(type),art.FRAMES[type].source)
	var flash: float = pose.get("staff_flash", 0.0)
	if flash > 0.0:
		var crystal: Vector2 = art.MUZZLES[type]
		draw_circle(crystal, 7.0+3.0*(1.0-flash), Color(0.40,0.87,1.0,0.24*flash), true, -1.0, true)
		draw_circle(crystal, 3.0, Color(0.86,0.98,1.0,0.8*flash), true, -1.0, true)
	draw_set_transform(Vector2.ZERO)

## Défenseur animé par planche : désactivé (Éruptions), tir en cours, sinon repos. Côté de tir par miroir.
func _draw_sheet_defender(center: Vector2, id: String, spec: Dictionary, pose: Dictionary) -> void:
	var state: String = SheetAnimations.defender_state(spec,pose)
	var anim: Dictionary = spec.animations[state]
	var texture: Texture2D = SheetAnimations.texture_for(id,anim)
	if texture == null: return
	var side: float = float(pose.get("direction",1.0))*SheetAnimations.base_facing(spec)
	draw_set_transform(center,0.0,Vector2(side,1.0))
	var age: float = float(pose.get("attack_age" if state.begins_with("attack") else state+"_age",0.0))
	var cycle: float = SheetAnimations.phase(anim,0.0,Time.get_ticks_msec()/1000.0,age)
	var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,cycle))
	draw_texture_rect_region(texture,SheetAnimations.destination(spec,anim),region)
	draw_set_transform(Vector2.ZERO)

## Compare les défenseurs du modèle à ceux vus à l'image précédente pour déclencher achat, passage de niveau et revente.
func _track_defenders() -> void:
	if model == null:
		_seen_model = null;_seen_defenders.clear();_defender_events.clear();_sold_ghosts.clear()
		return
	var now: float = Time.get_ticks_msec()/1000.0
	var current_state: Array[Dictionary] = []
	for slot in range(model.defenders.size()):
		var defender: Dictionary = model.defenders[slot]
		current_state.append({} if defender.is_empty() else {"type":defender.type,"level":defender.get("level",1),"branch":defender.get("branch",-1)})
	# Nouveau modèle, ou retour à l'état initial : on adopte l'état sans animer.
	if _seen_model != model or model.action_history.is_empty():
		_seen_model = model;_seen_defenders = current_state;_defender_events.clear();_sold_ghosts.clear()
		return
	for slot in range(current_state.size()):
		var before: Dictionary = _seen_defenders[slot] if slot < _seen_defenders.size() else {}
		var after: Dictionary = current_state[slot]
		if after.is_empty():
			if not before.is_empty():
				_sold_ghosts.append({"type":before.type,"slot":slot,"start":now})
			_defender_events.erase(slot)
		elif before.is_empty() or before.type != after.type:
			_defender_events[slot] = {"kind":"buy","start":now}
		elif int(after.level) > int(before.level):
			_defender_events[slot] = {"kind":"level_up","start":now}
	_seen_defenders = current_state
	_sold_ghosts = _sold_ghosts.filter(func(ghost: Dictionary) -> bool: return now-float(ghost.start) < 4.0)
	for slot in _defender_events.keys():
		if now-float(_defender_events[slot].start) > 4.0: _defender_events.erase(slot)

## Vrai tant qu'une animation par planche exige un redessin continu (repos, achat, revente, niveau).
func _sheet_animation_running() -> bool:
	if model == null: return false
	if model.combat_affix.get("id","") in ["headwinds","sandstorm","rockfall","seamist"]: return true
	if not _sold_ghosts.is_empty(): return true
	for defender in model.defenders:
		if not defender.is_empty() and not SheetAnimations.spec_for(SheetAnimations.defender_id(int(defender.type))).is_empty(): return true
	return false

func _draw_level_badge(center: Vector2, level: int, branch: int) -> void:
	if level > 1:
		var badge: Vector2 = center + Vector2(16,6)
		_unit_disk(badge,11 if level == 4 else 9,Color("7b6c41") if level == 4 else Color("304d42"))
		var badge_text: String = str(level) + ("A" if branch == 0 else "B") if level == 4 else str(level)
		draw_string(font,badge+Vector2(-7 if level == 4 else -3,4),badge_text,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("efe0b8"))


func _draw_tree(center: Vector2) -> void:
	draw_circle(center + Vector2(0, 3), 10, Color(0, 0, 0, 0.1))
	draw_line(center, center + Vector2(0, -22), Color("80755a"), 3)
	for crown in [[14.0,-8.0,-31.0],[11.0,-18.0,-39.0],[7.5,-28.0,-45.0]]:
		var left: Vector2 = center+Vector2(-crown[0],crown[1])
		var right: Vector2 = center+Vector2(crown[0],crown[1])
		var tip: Vector2 = center+Vector2(0,crown[2])
		draw_colored_polygon(PackedVector2Array([left,tip,right]),Color("2b5140"))
		draw_colored_polygon(PackedVector2Array([tip,right,center+Vector2(0,crown[1])]),Color("496e50"))

static func fortress_style(faction: int) -> Dictionary:
	if faction == 1:
		return {"faction":1,"wall":Color("956746"),"shade":Color("624c3c"),"roof":Color("a63f31"),"flag":Color("bd4936"),"trim":Color("c5bda7")}
	return {"faction":0,"wall":Color("c2c8b6"),"shade":Color("84958a"),"roof":Color("356582"),"flag":Color("376b99"),"trim":Color("d9b968")}

static func fortress_center(anchor: Vector2) -> Vector2:
	return anchor+Vector2(68,26) # Cour allongée pour dégager les placements des nouvelles silhouettes.

static func fortress_bounds(anchor: Vector2) -> Rect2:
	return Rect2(fortress_center(anchor)+Vector2(-50,-101),Vector2(106,124))

static func fortress_condition(hp: int, maximum: int) -> int:
	if hp <= 0: return 3
	if maximum <= 0: return 0
	var ratio: float = float(hp)/maximum
	return 2 if ratio <= 0.25 else 1 if ratio <= 0.5 else 0

static func fortress_caption(condition: int) -> String:
	return ["FORTERESSE","FORTERESSE · ENDOMMAGÉE","FORTERESSE · EN DANGER","FORTERESSE DÉTRUITE"][clampi(condition,0,3)]

func _draw_fortress(anchor: Vector2) -> void:
	var center: Vector2 = fortress_center(anchor)
	var faction: int = FortressArt.side(model.faction if model != null else 0)
	var style: Dictionary = fortress_style(faction)
	var condition: int = fortress_condition(model.fortress_hp,model.max_hp) if model != null else 0
	var offset: Vector2 = FortressArt.shake(royal_hurt_age)
	var body: Rect2 = FortressArt.building_rect(faction)
	body.position += center+offset
	draw_colored_polygon(PackedVector2Array([anchor+Vector2(-12,0),anchor+Vector2(36,-5),center+Vector2(43,3),center+Vector2(0,23)]),Color("576650"))
	var brightness: float = 1.0-condition*0.13
	if royal_hurt_age < 0.15: brightness += 0.22*(1.0-royal_hurt_age/0.15)
	draw_texture_rect_region(FortressArt.BUILDINGS[faction],body,FortressArt.SOURCES[faction],Color(brightness,brightness,brightness,1))
	if condition > 0:
		var crack := PackedVector2Array([center+offset+Vector2(-12,-39),center+offset+Vector2(-8,-31),center+offset+Vector2(-11,-23),center+offset+Vector2(-6,-13)])
		draw_polyline(crack,Color("352f25"),1.6,true)
	if condition >= 2:
		for index in range(3):
			var t: float = fmod(flag_phase/TAU+float(index)/3.0,1.0)
			draw_circle(center+Vector2(-12+index*11+sin(t*TAU)*2,-45-t*22),3+3*t,Color(Color("6d7167"),0.28*(1-t)))
	var hp: int = model.fortress_hp if model != null else 20
	var pose: int = FortressArt.king_pose(hp,royal_hurt_age,royal_rally_age)
	var king_center: Vector2 = center+offset+FortressArt.king_anchor(faction)
	var royal: Transform2D = FortressArt.king_transform(pose,flag_phase,royal_hurt_age)
	royal.origin += king_center
	draw_set_transform_matrix(royal)
	draw_texture_rect_region(FortressArt.KINGS[faction],FortressArt.king_rect(faction,pose),FortressArt.KING_FRAMES[faction][pose].source)
	draw_set_transform(Vector2.ZERO)
	# Bannière décalée : elle ne traverse ni le visage ni la couronne du souverain.
	var pole: Vector2 = center+Vector2(34,-25 if condition == 3 else -94)
	draw_line(center+Vector2(34,-10 if condition == 3 else -45),pole,style.trim,1.8,true)
	var flutter: float = sin(flag_phase)*1.5
	draw_colored_polygon(PackedVector2Array([pole+Vector2(1,0),pole+Vector2(19,3+flutter),pole+Vector2(17,13+flutter),pole+Vector2(1,11)]),style.flag)
	var caption: String = fortress_caption(condition)
	var width: float = font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x
	draw_string(font,center+Vector2(-width/2,34),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ed9989") if condition >= 2 else Color("d7bd83") if condition == 1 else INK)

static func _enemy_scale(enemy: Dictionary) -> float:
	return [0.7, 1.0, 0.85, 1.2, 1.0, 1.5, 1.3, 1.7, 1.4, 1.1, 1.6, 0.8, 1.1][enemy.get("type", 1)]

static func enemy_color(type: int) -> Color:
	return [Color("789263"), Color("b45f4c"), Color("c6a16a"), Color("9e6659"), Color("967556"), Color("838e85"), Color("9777a6"), Color("aca384"),Color("91ab72"),Color("5f9aa0"),Color("b8a05c"),Color("8fb4d8"),Color("8a7f9c")][type]

func _draw_pillager(center: Vector2, enemy: Dictionary, hit_strength: float = 0.0, pose: Dictionary = {}) -> void:
	var id: String = enemy_art_id(enemy,model.faction)
	var scale: float = _enemy_scale(enemy)
	var walking: bool = EnemyWalkArt.supports(id)
	var sheet_walk: bool = not walking and SheetAnimations.has_animation(id,"walk")
	var route_points: Array[Vector2] = model.enemy_route_points(enemy)
	var motion := EnemyWalkArt.path_motion(enemy.distance, route_points, AXIS)
	var facing := route_facing(motion.direction)
	var preview: Dictionary = {}
	if walking and wolf_turn_preview.is_valid():
		preview = wolf_turn_preview.call(enemy.distance, route_points, enemy.id, scale)
	center = preview.get("center", center)
	draw_set_transform(center,0.0,Vector2.ONE*scale)
	if enemy.id == inspected_enemy_id and _ghost_alpha >= 1.0:
		draw_arc(Vector2(0,3),14,0,TAU,32,Color("edcc80"),2,true)
	for curse in model.curses:
		if curse.enemy_id != enemy.id or not curse_ring_visible(curse): continue
		if curse_source_type(curse) in FIRE_CURSE_TYPES:
			_draw_burning(model.elapsed+float(enemy.id)*0.37) # brûlure : flammes sur la cible
			break
		draw_arc(Vector2(0,-13),19,0,TAU,24,Color("be83d3"),1.5,true)
		var mark := Vector2(0,-45)
		draw_colored_polygon(PackedVector2Array([mark+Vector2(0,-5),mark+Vector2(4,0),mark+Vector2(0,5),mark+Vector2(-4,0)]),Color("d6a1ef"))
		break
	draw_circle(Vector2(0,3),10,Color(0,0,0,0.25*_ghost_alpha),true,-1,true)
	if _ghost_alpha >= 1.0: _draw_regeneration_swirl(enemy)
	var body: Transform2D = enemy_body_transform(enemy,facing,pose,model.elapsed,model.active and not walking and not sheet_walk, motion.get("direction", Vector2.ZERO))
	if _ghost_squash != 1.0: body = body.scaled_local(Vector2(1.0,_ghost_squash))
	body.origin += center
	draw_set_transform_matrix(body)
	if preview.has("texture"):
		draw_set_transform(body.origin, 0.0, Vector2(preview.get("facing", 1.0), 1.0)*scale)
		draw_mesh(preview.mesh, preview.texture, Transform2D.IDENTITY, _enemy_tint(hit_strength))
	elif walking:
		var phase: float=EnemyWalkArt.phase_for(preview.get("travel", motion.travel),enemy.id,scale)
		var orientation: Vector2 = preview.get("direction", motion.direction)
		var ground := Vector2(absf(orientation.x), orientation.y)
		draw_mesh(walking_meshes.mesh_for(enemy.id,phase,ground),EnemyWalkArt.TEXTURE,Transform2D.IDENTITY,_enemy_tint(hit_strength))
	elif sheet_walk:
		_draw_sheet_walker(id,enemy,motion,scale,facing,body,hit_strength)
	else:
		draw_texture_rect_region(EnemyArt.TEXTURES[id],EnemyArt.destination(id),EnemyArt.FRAMES[id].source,_enemy_tint(hit_strength))
	if enemy.type == Model.Banks.GUARD_TYPE and model.active and _ghost_alpha >= 1.0:
		for index in range(model.protection_events.size()-1,-1,-1):
			var event: Dictionary = model.protection_events[index]
			var age: float = model.elapsed-event.time
			if age >= 0.4: break
			if age < 0.0 or event.get("guardian_id", -1) != enemy.id: continue
			var strength := 1.0-age/0.4
			var shell := Vector2(-4,-18)
			draw_circle(shell,11.0+5.0*(1.0-strength),Color(0.78,0.96,0.49,0.18*strength),true,-1,true)
			draw_arc(shell,10.0+4.0*(1.0-strength),PI,TAU,20,Color(0.86,1.0,0.62,0.90*strength),2.0,true)
			break
	draw_set_transform(Vector2.ZERO)

## Ennemi animé par une planche d'images (format de `animation_library.gd`) : cycle de marche réglé sur la distance parcourue.
func _draw_sheet_walker(id: String, enemy: Dictionary, motion: Dictionary, scale: float, facing: float, body: Transform2D, hit_strength: float) -> void:
	var spec: Dictionary = SheetAnimations.spec_for(id)
	var info: Dictionary = {"hurt_age":last_hit_age(enemy.id),"direction":motion.get("direction",Vector2.ZERO)}
	if model.active: info.spawn_age = model.elapsed-float(enemy.get("spawn_time",0.0))
	if enemy.has("risen_at"): info.rise_age = model.elapsed-float(enemy.risen_at)
	var state: String = SheetAnimations.enemy_state(spec,info)
	if state == "": return
	var anim: Dictionary = spec.animations[state]
	var texture: Texture2D = SheetAnimations.texture_for(id,anim)
	if texture == null: return
	if SheetAnimations.is_four_view(spec): draw_set_transform_matrix(body*Transform2D(Vector2(facing,0),Vector2(0,1),Vector2.ZERO)) # quatre vues dessinées : le miroir de la route est annulé, la latéralité de l'équipement est celle du dessin
	elif SheetAnimations.base_facing(spec) < 0.0: draw_set_transform_matrix(body*Transform2D(Vector2(-1,0),Vector2(0,1),Vector2.ZERO))
	var age: float = float(info.rise_age) if state == "rise" else float(info.hurt_age) if state == "hurt" else float(info.get("spawn_age",0.0))
	var cycle: float = SheetAnimations.phase(anim,float(motion.get("travel",0.0))/scale,model.elapsed,age,fposmod(float(enemy.id)*0.37,1.0))
	var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,cycle))
	draw_texture_rect_region(texture,SheetAnimations.destination(spec,anim),region,_enemy_tint(hit_strength))

## Pièces de décor posées sur le plateau (portails, remparts, basalte…), sous les unités et l'interface.
func _draw_decor_props(definition: Dictionary) -> void:
	for prop in DecorArt.props(str(definition.id),str(definition.decoration),model.faction):
		draw_set_transform(project(prop.point),0.0,Vector2.ONE)
		draw_texture_rect(prop.texture,prop.destination,false)
	draw_set_transform(Vector2.ZERO)

## Repère fonctionnel provisoire de l'affixe Tempête de sable (chapitre 12) : voile de sable sur le plateau pendant la rafale,
## liséré qui s'épaissit pendant l'avertissement. L'habillage (voile, rafales, avertissement) revient à Codex (TODO_VISUELS.md).
func _draw_sandstorm() -> void:
	if model == null or not model.storm_enabled(): return
	var status: Dictionary = model.storm_status()
	if status.is_empty(): return
	var board: Vector2i = model.map_definition.size
	var corners: Array[Vector2] = [Vector2.ZERO,Vector2(board.x,0),Vector2(board.x,board.y),Vector2(0,board.y)]
	var area := PackedVector2Array()
	for corner in corners: area.append(project(corner))
	# Habillage de Codex : planches de l'effet `effect.sandstorm`, étirées sur l'emprise du plateau (avertissement en progression, rafale en boucle).
	var spec: Dictionary = SheetAnimations.spec_for(STORM_EFFECT_ID)
	var sheet_name: String = "warning" if status.state == "warning" else "storm"
	if not spec.is_empty() and spec.animations.has(sheet_name):
		var anim: Dictionary = spec.animations[sheet_name]
		var texture: Texture2D = SheetAnimations.texture_for(STORM_EFFECT_ID,anim)
		if texture != null:
			var bounds := Rect2(area[0],Vector2.ZERO)
			for point in area: bounds = bounds.expand(point)
			var progress_value: float = clampf(1.0-float(status.remaining)/float(model.combat_affix.warning),0.0,1.0) if status.state == "warning" else 0.0
			var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,SheetAnimations.phase(anim,0.0,model.elapsed,progress_value)))
			draw_texture_rect_region(texture,bounds,region)
			return
	if status.state == "warning":
		var progress: float = clampf(1.0-float(status.remaining)/float(model.combat_affix.warning),0.0,1.0)
		var outline: PackedVector2Array = area.duplicate();outline.append(outline[0])
		draw_polyline(outline,Color(0.93,0.78,0.45,0.25+0.5*progress),2.0+4.0*progress,true)
	else:
		draw_colored_polygon(area,Color(0.86,0.7,0.42,0.22))
		var clock: float = model.elapsed # Temps de combat : suit la vitesse du jeu, la pause et le rejeu.
		for index in range(14):
			var lane: float = fposmod(float(index)*0.381966,1.0)
			var shift: float = fposmod(clock*0.5+float(index)*0.173,1.0)
			var start: Vector2 = project(Vector2(float(board.x)*(shift*1.2-0.1),float(board.y)*lane))
			draw_line(start,start+Vector2(34,-7),Color(0.97,0.88,0.62,0.45),1.5,true)

## Repère fonctionnel provisoire de l'affixe Éboulement (chapitre 14) : anneau qui pulse à l'entrée touchée pendant l'avertissement,
## éboulis gris pendant le blocage. L'habillage revient à Codex (TODO_VISUELS.md). Le mouvement suit le temps de combat.
func _draw_rockfall() -> void:
	if model == null or not model.rockfall_enabled(): return
	var status: Dictionary = model.rockfall_status()
	if status.is_empty(): return
	var origin := Vector2.ZERO
	var found := false
	for route in model.routes:
		if route.id == status.route_id and not route.path_points.is_empty():
			origin = project(route.path_points[0]);found = true;break
	if not found: return
	# Habillage de Codex : planches de l'effet `effect.rockfall` posées au sol sur l'entrée visée (avertissement en progression, blocage en boucle).
	var spec: Dictionary = SheetAnimations.spec_for(ROCKFALL_EFFECT_ID)
	var sheet_name: String = "warning" if status.state == "warning" else "blocked"
	if not spec.is_empty() and spec.animations.has(sheet_name):
		var anim: Dictionary = spec.animations[sheet_name]
		var texture: Texture2D = SheetAnimations.texture_for(ROCKFALL_EFFECT_ID,anim)
		if texture != null:
			var progress_value: float = clampf(1.0-float(status.remaining)/float(model.combat_affix.warning),0.0,1.0) if status.state == "warning" else 0.0
			var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,SheetAnimations.phase(anim,0.0,model.elapsed,progress_value)))
			draw_set_transform(origin,0.0,Vector2.ONE)
			draw_texture_rect_region(texture,SheetAnimations.destination(spec,anim),region)
			draw_set_transform(Vector2.ZERO)
			return
	if status.state == "warning":
		var progress: float = clampf(1.0-float(status.remaining)/float(model.combat_affix.warning),0.0,1.0)
		var pulse: float = 0.5+0.5*sin(model.elapsed*TAU*2.0)
		draw_arc(origin,16.0+10.0*progress,0.0,TAU,32,Color(0.95,0.55,0.25,0.35+0.4*pulse),2.0+2.0*progress,true)
	else:
		var rubble: Array[Vector2] = [Vector2(-14,2),Vector2(-6,-8),Vector2(4,-12),Vector2(14,-4),Vector2(10,6),Vector2(-2,10)]
		var shape := PackedVector2Array()
		for point in rubble: shape.append(origin+point)
		draw_colored_polygon(shape,Color(0.38,0.36,0.4,0.95))
		draw_polyline(shape+PackedVector2Array([shape[0]]),Color(0.16,0.15,0.18,0.9),1.5,true)
		for offset in [Vector2(-6,-2),Vector2(5,-5),Vector2(1,4)]: draw_circle(origin+offset,3.0,Color(0.52,0.5,0.54,0.95))

## Repère fonctionnel provisoire de l'affixe Brume marine (chapitre 18) : liséré clair pendant l'avertissement, voile blanc-bleu sur le plateau
## pendant la brume. L'habillage revient à Codex (TODO_VISUELS.md). Le mouvement suit le temps de combat.
func _draw_seamist() -> void:
	if model == null or not model.mist_enabled(): return
	var status: Dictionary = model.mist_status()
	if status.is_empty(): return
	var board: Vector2i = model.map_definition.size
	var area := PackedVector2Array()
	for corner in [Vector2.ZERO,Vector2(board.x,0),Vector2(board.x,board.y),Vector2(0,board.y)]: area.append(project(corner))
	# Habillage de Codex : planches de l'effet `effect.seamist`, étirées sur l'emprise du plateau (avertissement en progression, brume en boucle sur le temps de combat).
	var spec: Dictionary = SheetAnimations.spec_for(SEAMIST_EFFECT_ID)
	var sheet_name: String = "warning" if status.state == "warning" else "mist"
	if not spec.is_empty() and spec.animations.has(sheet_name):
		var anim: Dictionary = spec.animations[sheet_name]
		var texture: Texture2D = SheetAnimations.texture_for(SEAMIST_EFFECT_ID,anim)
		if texture != null:
			var bounds := Rect2(area[0],Vector2.ZERO)
			for point in area: bounds = bounds.expand(point)
			var progress_value: float = clampf(1.0-float(status.remaining)/float(model.combat_affix.warning),0.0,1.0) if status.state == "warning" else 0.0
			var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,SheetAnimations.phase(anim,0.0,model.elapsed,progress_value)))
			draw_texture_rect_region(texture,bounds,region)
			return
	if status.state == "warning":
		var progress: float = clampf(1.0-float(status.remaining)/float(model.combat_affix.warning),0.0,1.0)
		var outline: PackedVector2Array = area.duplicate();outline.append(outline[0])
		draw_polyline(outline,Color(0.85,0.93,0.96,0.25+0.5*progress),2.0+4.0*progress,true)
	else:
		draw_colored_polygon(area,Color(0.85,0.93,0.97,0.28))
		var clock: float = model.elapsed
		for index in range(8):
			var lane: float = fposmod(float(index)*0.381966,1.0)
			var shift: float = fposmod(clock*0.12+float(index)*0.211,1.0)
			var start: Vector2 = project(Vector2(float(board.x)*(shift*1.2-0.1),float(board.y)*lane))
			draw_line(start,start+Vector2(60,-12),Color(0.95,0.98,1.0,0.35),6.0,true)

## Remous au pied de Gueule-de-Vase quand elle est dans l'eau et qu'il lui manque des PV (effet `effect.regeneration`).
## La phase suit le temps de combat. Le dessin se fait dans le repère de l'ennemi, pieds à l'origine.
func _draw_regeneration_swirl(enemy: Dictionary) -> void:
	if enemy.get("type",1) != Model.Drowned.TYPE or not SheetAnimations.has_animation(REGEN_EFFECT_ID,"regen"): return
	if not model.enemy_in_water(enemy) or float(enemy.hp) >= float(enemy.get("max_hp",enemy.hp)): return
	var spec: Dictionary = SheetAnimations.spec_for(REGEN_EFFECT_ID)
	var anim: Dictionary = spec.animations.regen
	var texture: Texture2D = SheetAnimations.texture_for(REGEN_EFFECT_ID,anim)
	if texture == null: return
	var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,SheetAnimations.phase(anim,0.0,model.elapsed,0.0,fposmod(float(enemy.id)*0.37,1.0))))
	draw_texture_rect_region(texture,SheetAnimations.destination(spec,anim),region)

## Mort d'un ennemi par planche : jouée une fois à l'endroit de l'élimination, dans le sens du chemin.
func _draw_sheet_death(id: String, state: String, event: Dictionary, age: float) -> void:
	var spec: Dictionary = SheetAnimations.spec_for(id)
	var anim: Dictionary = spec.animations[state]
	if age < 0.0 or age >= float(anim.duration): return
	var texture: Texture2D = SheetAnimations.texture_for(id,anim)
	if texture == null: return
	var enemy := {"type":event.type,"route_id":event.get("route_id","")}
	var route_points: Array[Vector2] = model.enemy_route_points(enemy)
	var motion := EnemyWalkArt.path_motion(float(event.get("distance",0.0)),route_points,AXIS)
	var side: float = 1.0 if SheetAnimations.is_four_view(spec) else route_facing(motion.direction)*SheetAnimations.base_facing(spec) # quatre vues : pas de miroir
	draw_set_transform(project(event.point),0.0,Vector2(side,1.0)*_enemy_scale(enemy))
	var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,SheetAnimations.phase(anim,0.0,0.0,age)))
	draw_texture_rect_region(texture,SheetAnimations.destination(spec,anim),region)
	draw_set_transform(Vector2.ZERO)

## Défenseurs revendus : l'animation `sell` joue à leur ancien emplacement.
func _draw_sold_defenders() -> void:
	var now: float = Time.get_ticks_msec()/1000.0
	for ghost in _sold_ghosts:
		var id: String = SheetAnimations.defender_id(int(ghost.type))
		var spec: Dictionary = SheetAnimations.spec_for(id)
		var age: float = now-float(ghost.start)
		if spec.is_empty() or SheetAnimations.defender_state(spec,{"sell_age":age}) != "sell": continue
		_draw_sheet_defender(project(_map_slots()[int(ghost.slot)]),id,spec,{"sell_age":age})

## Repère fonctionnel provisoire de l'affixe Vents contraires (chapitre 4) : traînées claires qui traversent le plateau
## à contre-courant des défenseurs. L'habillage (poussière, herbes couchées, étendards) revient à Codex (TODO_VISUELS.md).
func _draw_headwinds() -> void:
	if model == null or model.combat_affix.get("id","") != "headwinds": return
	var board := Vector2(model.map_definition.size)
	var clock: float = Time.get_ticks_msec()/1000.0
	for index in range(16):
		var lane: float = fposmod(float(index)*0.381966,1.0)
		var progress: float = fposmod(clock*0.22+float(index)*0.137,1.0)
		var start: Vector2 = project(Vector2(board.x*(1.05-1.1*progress),board.y*lane))
		var alpha: float = sin(progress*PI)*0.32
		draw_line(start,start+Vector2(-26,-5),Color(0.9,0.97,1.0,alpha),1.5,true)
		draw_line(start+Vector2(-6,3),start+Vector2(-20,0),Color(0.9,0.97,1.0,alpha*0.6),1.0,true)

## Repère fonctionnel provisoire de l'affixe Éruptions : l'habillage (lave, cendres) revient à Codex (TODO_VISUELS.md).
func _eruption_warning_sheet() -> bool:
	return SheetAnimations.has_animation(ERUPTION_EFFECT_ID,"warning")

## Avertissement des Éruptions par planche (effet « effect.eruption ») : au sol, sous les unités, pendant l'état `warning`.
## La progression 0 → 1 vient du jeu (`1 - remaining / warning`), donc suit la vitesse et la pause.
func _draw_eruption_warning() -> void:
	if model == null or not model.eruption_enabled() or not _eruption_warning_sheet(): return
	var status: Dictionary = model.eruption_status()
	if status.is_empty() or status.state != "warning": return
	var spec: Dictionary = SheetAnimations.spec_for(ERUPTION_EFFECT_ID)
	var anim: Dictionary = spec.animations.warning
	var texture: Texture2D = SheetAnimations.texture_for(ERUPTION_EFFECT_ID,anim)
	if texture == null: return
	var progress: float = clampf(1.0-float(status.remaining)/float(model.combat_affix.warning),0.0,1.0)
	var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,SheetAnimations.phase(anim,0.0,0.0,progress)))
	draw_set_transform(project(_map_slots()[status.slot]),0.0,Vector2.ONE)
	draw_texture_rect_region(texture,SheetAnimations.destination(spec,anim),region)
	draw_set_transform(Vector2.ZERO)

func _draw_eruption() -> void:
	if model == null or not model.eruption_enabled(): return
	var status: Dictionary = model.eruption_status()
	if status.is_empty(): return
	if status.state == "warning" and _eruption_warning_sheet(): return # Remplacé par la planche d'avertissement, dessinée sous les unités.
	var center: Vector2 = project(_map_slots()[status.slot])
	# Désactivation par planche (effet `effect.eruption`, animation `disabled`) : cendres au-dessus des pieds, âge = durée − temps restant.
	if status.state == "active" and SheetAnimations.has_animation(ERUPTION_EFFECT_ID,"disabled"):
		var spec: Dictionary = SheetAnimations.spec_for(ERUPTION_EFFECT_ID)
		var anim: Dictionary = spec.animations.disabled
		var texture: Texture2D = SheetAnimations.texture_for(ERUPTION_EFFECT_ID,anim)
		if texture != null:
			var age: float = float(model.combat_affix.duration)-float(status.remaining)
			var region: Rect2 = SheetAnimations.frame_region(anim,SheetAnimations.frame_index(anim,SheetAnimations.phase(anim,0.0,0.0,age)))
			draw_set_transform(center,0.0,Vector2.ONE)
			draw_texture_rect_region(texture,SheetAnimations.destination(spec,anim),region)
			draw_set_transform(Vector2.ZERO)
			return
	var diamond := PackedVector2Array([center+Vector2(-26,0),center+Vector2(0,-13),center+Vector2(26,0),center+Vector2(0,13)])
	if status.state == "warning":
		var pulse: float = 0.5+0.5*sin(model.elapsed*9.0)
		draw_colored_polygon(diamond,Color(1.0,0.42,0.08,0.22+0.28*pulse))
		draw_polyline(PackedVector2Array([diamond[0],diamond[1],diamond[2],diamond[3],diamond[0]]),Color(1.0,0.55,0.15,0.95),3.0,true)
	else:
		draw_colored_polygon(diamond,Color(0.1,0.08,0.08,0.82))
		for index in range(5):
			var drift := Vector2(sin(index*2.1+model.elapsed*1.3)*9.0,-14.0-index*4.0+cos(index*1.7+model.elapsed)*2.0)
			draw_circle(center+drift,10.0-index,Color(0.36,0.34,0.33,0.55))

## Bandeau d'affixe de la mission (lisibilité, v0.223) : annonce, compte à rebours et effet de l'événement en cours, au-dessus du plateau.
## Retourne {} sans affixe actif ; sinon {"text", "state" ("warning", "active" ou "permanent"), "fraction" (temps restant / durée de la phase)}.
static func affix_banner(model) -> Dictionary:
	if model == null or model.combat_affix.is_empty(): return {}
	var id: String = str(model.combat_affix.get("id",""))
	if id == "headwinds":
		return {"text":"Vents contraires · cadence −%d %%" % (100-int(model.combat_affix.cadence_percent)),"state":"permanent","fraction":1.0}
	var status: Dictionary = {}
	var name: String = ""
	var effect: String = ""
	match id:
		"eruptions":
			status = model.eruption_status();name = "Éruption"
			if not status.is_empty(): effect = "E%d %s" % [int(status.slot)+1,"sera désactivé" if status.state == "warning" else "désactivé"]
		"sandstorm":
			status = model.storm_status();name = "Tempête de sable";effect = "portée −%d %%" % int(model.combat_affix.range_percent)
		"seamist":
			status = model.mist_status();name = "Brume marine";effect = "or −%d %%" % int(model.combat_affix.gold_percent)
		"rockfall":
			status = model.rockfall_status();name = "Éboulement"
			if not status.is_empty():
				for index in range(model.routes.size()):
					if str(model.routes[index].id) == str(status.route_id): effect = "entrée %d %s" % [index+1,"sera bloquée" if status.state == "warning" else "bloquée"]
	if status.is_empty(): return {}
	var remaining: float = maxf(0.0,float(status.remaining))
	var warning: bool = status.state == "warning"
	var phase_length: float = float(model.combat_affix.warning) if warning else float(model.combat_affix.duration)
	var text: String = ("%s dans %d s" % [name,int(ceil(remaining))]) if warning else ("%s · encore %d s" % [name,int(ceil(remaining))])
	if not effect.is_empty(): text += " · " + effect
	return {"text":text,"state":str(status.state),"fraction":clampf(remaining/phase_length,0.0,1.0) if phase_length > 0.0 else 0.0}

func _draw_affix_banner() -> void:
	var banner: Dictionary = affix_banner(model)
	if banner.is_empty(): return
	var font: Font = ThemeDB.fallback_font
	var size := Vector2(430,34)
	var area := Rect2(Vector2(640.0-size.x*0.5,112.0),size)
	var warning: bool = banner.state == "warning"
	var pulse: float = 0.5+0.5*sin(Time.get_ticks_msec()/1000.0*8.0)
	var accent: Color = Color(1.0,0.62,0.16) if warning else Color(0.95,0.32,0.26) if banner.state == "active" else Color(0.6,0.8,0.95)
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.07,0.09,0.08,0.88)
	box.border_color = Color(accent,0.55+0.45*pulse) if warning else accent
	box.set_border_width_all(2)
	box.set_corner_radius_all(7)
	draw_style_box(box,area)
	# Pictogramme : triangle d'alerte (annonce), disque plein (en cours), vague (permanent).
	var icon: Vector2 = area.position+Vector2(20,17)
	if banner.state == "permanent":
		draw_arc(icon,7.0,0.0,TAU,16,accent,2.0,true)
	else:
		draw_colored_polygon(PackedVector2Array([icon+Vector2(0,-9),icon+Vector2(9,7),icon+Vector2(-9,7)]),accent)
		draw_string(font,icon+Vector2(-3,6),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.1,0.07,0.04))
	draw_string(font,area.position+Vector2(38,22),str(banner.text),HORIZONTAL_ALIGNMENT_LEFT,size.x-48.0,15,Color(0.97,0.95,0.88))
	if banner.state != "permanent":
		draw_rect(Rect2(area.position+Vector2(8,size.y-6),Vector2((size.x-16.0)*float(banner.fraction),3)),accent)

func _draw_valley_water() -> void:
	# La rivière et le pont sont des éléments visuels, sans collision.
	polygon([Vector2(5.86,0),Vector2(7.14,0),Vector2(7.14,10),Vector2(5.86,10)],Color("68755a"))
	polygon([Vector2(6, 0), Vector2(7, 0), Vector2(7, 10), Vector2(6, 10)], Color("407b7d"))
	polygon([Vector2(6.76,0),Vector2(7,0),Vector2(7,10),Vector2(6.76,10)],Color("315e67"))
	for y in range(10):
		draw_line(project(Vector2(6.16,y+0.24)),project(Vector2(6.52,y+0.28)),Color("83b7ab"),1.2,true)
		draw_line(project(Vector2(6.45,y+0.65)),project(Vector2(6.82,y+0.68)),Color("659c9c"),1.2,true)

func _draw_valley_bridge() -> void:
	polygon([Vector2(5.8, 6.55), Vector2(7.2, 6.55), Vector2(7.2, 7.45), Vector2(5.8, 7.45)], Color("77654c"))
	for plank in range(8):
		var x: float = 5.85 + plank * 0.18
		draw_line(project(Vector2(x, 6.6)), project(Vector2(x, 7.4)), Color("b29a6b"), 2)
	for bank in [6.55,7.45]:
		var first: Vector2 = project(Vector2(5.8,bank))
		var last: Vector2 = project(Vector2(7.2,bank))
		draw_line(first+Vector2(0,-5),last+Vector2(0,-5),Color("c3aa78"),2,true)
		for post in [first,last]: draw_line(post,post+Vector2(0,-8),Color("725c42"),3,true)
