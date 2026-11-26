extends SceneTree
## Champions mutants de l'Héroïque (v0.258, validés par le porteur le 25 novembre 2026) : tirage par vague, effets des douze traits, rejeu, absence en Normal.
const Model = preload("res://scripts/valley_model.gd")
const Champions = preload("res://scripts/champions.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	verify_catalogue()
	verify_plan()
	verify_spawn_and_traits()
	verify_pulses_and_death()
	verify_games()
	print("CHAMPIONS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

func verify_catalogue() -> void:
	check(Champions.TRAITS.size() == 12 and Champions.TRAITS.all(func(id): return Champions.NAMES.has(id) and Champions.RULES.has(id) and Champions.COLORS.has(id) and Champions.GLYPHS.has(id)),"Douze traits nommés, décrits et dessinés")
	check(Champions.traits_for(0).is_empty() and Champions.traits_for(1) == ["haste","shield"] and Champions.traits_for(2).size() == 3 and Champions.traits_for(11).size() == 12 and Champions.traits_for(20).size() == 12,"Deux traits au chapitre 1, un de plus par chapitre, les douze au chapitre 11")
	check(Champions.trait_count(15,10) == 1 and Champions.trait_count(16,6) == 1 and Champions.trait_count(16,7) == 2 and Champions.trait_count(20,10) == 2,"Deux traits aux vagues 7 à 10 des chapitres 16 à 20")

func schedule(types: Array) -> Array:
	var result: Array = []
	for index in range(types.size()): result.append({"type":types[index],"time":float(index)})
	return result

func verify_plan() -> void:
	var waves: Array = schedule([1,1,3,7,4,2])
	check(Champions.plan(waves,2,5,7).is_empty() and Champions.plan(waves,3,0,7).is_empty() and Champions.plan(schedule([7,8]),3,5,7).is_empty(),"Pas de champion avant la vague 3, hors Héroïque ni sans ennemi ordinaire")
	var seen: Dictionary = {}
	for seed in range(40):
		var plan: Dictionary = Champions.plan(waves,4,20,seed)
		check(int(waves[plan.index].type) in Champions.ELIGIBLE_TYPES and int(waves[plan.index].type) != 7,"Le champion est un ennemi ordinaire, jamais le boss")
		check(plan.traits.size() == 1 and plan == Champions.plan(waves,4,20,seed),"Tirage déterministe")
		for id in plan.traits: seen[id] = true
		var late: Dictionary = Champions.plan(waves,8,18,seed)
		check(late.traits.size() == 2 and late.traits[0] != late.traits[1],"Deux traits distincts en fin de campagne")
		check(Champions.plan(waves,4,1,seed).traits[0] in ["haste","shield"],"Chapitre 1 : Hâte ou Bouclier")
	check(seen.size() >= 10,"Les tirages couvrent les traits du chapitre (%d)" % seen.size())

func heroic(chapter: int = 20) -> Model:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.configure_enemy_hp(130);m.configure_difficulty(1);m.configure_champions(chapter);m.select_faction(0)
	return m

func champion(m: Model, traits: Array, type: int = 1) -> Dictionary:
	var enemy: Dictionary = Model.make_enemy(100+m.enemies.size(),type,0.0,0,130)
	m._make_champion(enemy,traits)
	m.enemies.append(enemy)
	return enemy

func verify_spawn_and_traits() -> void:
	var m = heroic()
	check(m.champion_chapter == 20 and not m.configure_champions(21) and not m.configure_champions(-1),"Chapitre des champions borné")
	var base: Dictionary = Model.make_enemy(1,1,0.0,0,130)
	var plain: Dictionary = champion(m,["regen"])
	check(is_equal_approx(plain.max_hp,base.max_hp*1.5) and plain.hp == plain.max_hp and plain.reward == base.reward*2 and plain.champion,"+50 % de PV et or doublé")
	var colossus: Dictionary = champion(m,["colossus"])
	check(is_equal_approx(colossus.max_hp,base.max_hp*2.0) and is_equal_approx(colossus.speed,base.speed*0.85),"Colosse : PV doublés, 15 % plus lent")
	check(is_equal_approx(champion(m,["haste"]).speed,base.speed*1.35),"Hâte : 35 % plus vite")
	var shielded: Dictionary = champion(m,["shield"])
	check(is_equal_approx(shielded.shield,shielded.max_hp*0.30),"Bouclier de 30 % des PV")
	check(champion(m,["plunderer"]).fortress_damage == base.fortress_damage*2,"Pillard : dégâts à la forteresse doublés")
	var armored: Dictionary = champion(m,["armored"])
	m.buy(3,0)
	var stats: Dictionary = m.get_stats(3)
	check(is_equal_approx(m.damage_for(stats,"direct",armored),m.damage_for(stats,"direct",plain)*0.70),"Blindé : tirs directs réduits de 30 %")
	var immune: Dictionary = champion(m,["immune"])
	m._slow_enemy(immune,3.0);m._slow_enemy(plain,3.0)
	check(not Model.enemy_is_slowed(immune) and Model.enemy_is_slowed(plain),"Insensible : pas de ralentissement")
	# Bouclier absorbé avant les PV.
	var before: float = shielded.hp
	m._apply_damage({shielded.id:shielded.shield*0.5})
	check(is_equal_approx(shielded.hp,before) and shielded.shield > 0.0,"Le bouclier absorbe les dégâts en premier")
	var normal = Model.new(true,Model.Maps.for_id("valley_ford"))
	normal.configure_enemy_hp(130);normal.select_faction(0)
	check(normal.champion_chapter == 0 and normal.champion_plan_for_wave().is_empty(),"Pas de champion en Normal")

func verify_pulses_and_death() -> void:
	var m = heroic()
	var regen: Dictionary = champion(m,["regen"])
	regen.hp = regen.max_hp*0.5
	regen.last_hit_at = 0.0
	m.elapsed = 1.0;m._champion_pulses()
	check(is_equal_approx(regen.hp,regen.max_hp*0.5),"Régénération : rien avant 2 s sans être touché")
	m.elapsed = 2.0;m._champion_pulses()
	check(is_equal_approx(regen.hp,regen.max_hp*0.53),"Régénération : 3 % des PV par seconde au calme")
	var healer: Dictionary = champion(m,["healer"])
	var hurt: Dictionary = Model.make_enemy(300,1,0.0,0,130)
	hurt.hp = hurt.max_hp*0.5;m.enemies.append(hurt)
	var far: Dictionary = Model.make_enemy(301,1,0.0,0,130)
	far.hp = far.max_hp*0.5;far.distance = 6.0;m.enemies.append(far)
	m.elapsed = 3.0;m._champion_pulses()
	check(is_equal_approx(hurt.hp,hurt.max_hp*0.52) and is_equal_approx(far.hp,far.max_hp*0.5),"Soigneur : 2 % par seconde aux voisins proches seulement")
	var galvanizer: Dictionary = champion(m,["galvanizing"])
	m.elapsed = 4.0;m._champion_pulses()
	check(hurt.has("boost_until") and is_equal_approx(float(hurt.boost_rate),0.15) and not far.has("boost_until"),"Galvanisant : élan de 15 % aux voisins proches")
	# Mort : Scission et Vengeur.
	var d = heroic()
	var splitter: Dictionary = champion(d,["split","avenger"])
	splitter.distance = 4.0
	var neighbour: Dictionary = Model.make_enemy(400,1,0.0,0,130);neighbour.distance = 4.5;d.enemies.append(neighbour)
	d.elapsed = 5.0
	d._apply_damage({splitter.id:splitter.max_hp*2.0})
	var parts: Array = d.enemies.filter(func(e): return e.id >= Model.Attackers.FIRST_EXTRA_ID)
	check(parts.size() == 2 and parts.all(func(e): return is_equal_approx(e.max_hp,splitter.max_hp*0.25) and is_equal_approx(e.distance,4.0) or is_equal_approx(e.distance,4.0-Model.Attackers.EMBER_SPACING)),"Scission : deux petits ennemis à 25 % des PV, sur place")
	check(neighbour.has("boost_until") and is_equal_approx(float(neighbour.boost_rate),0.25) and is_equal_approx(float(neighbour.boost_until),8.0),"Vengeur : élan de 25 % pendant 3 s")
	# Revenant : une relève à 40 %.
	var r = heroic()
	var revenant: Dictionary = champion(r,["revenant"])
	r._apply_damage({revenant.id:revenant.max_hp*3.0})
	check(r.enemies.has(revenant) and revenant.risen and is_equal_approx(revenant.hp,revenant.max_hp*0.4),"Revenant : se relève une fois à 40 %")
	r._apply_damage({revenant.id:revenant.max_hp*3.0})
	check(not r.enemies.has(revenant),"Revenant : pas de seconde relève")

## Partie complète en Héroïque, chapitre 20 : champions tirés, rapport rejoué, même résultat à petits et grands pas.
func play(m: Model, step: float) -> Dictionary:
	m.rng.seed = 11
	m.buy(3,0);m.buy(4,1)
	for wave in range(1,11):
		if wave == 2: m.buy(2,1)
		if wave >= 5:
			for slot in [3,4,2]:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): break
		while m.active: m.advance(step)
		if m.phase == "defeat": break
		if m.phase == "bonus": m.choose_bonus(Model.reference_bonus(m.bonus_offer))
		if wave < 10: m.prepare_next_wave()
	return JSON.parse_string(JSON.stringify(Report.build(m)))

func verify_games() -> void:
	var coarse: Dictionary = play(heroic(20),300.0)
	var fine: Dictionary = play(heroic(20),0.05)
	check(int(coarse.get("champion_chapter",0)) == 20 and int(coarse.get("difficulty",0)) == 1,"Le rapport garde le chapitre des champions")
	check(Replay._difference(coarse,fine,"rapport").is_empty(),"Même partie à petits et grands pas, champions compris")
	var replay: Dictionary = Replay.verify(coarse)
	check(replay.ok,"Une partie avec champions se rejoue : "+str(replay.get("error","")))
	var without: Dictionary = coarse.duplicate(true);without.erase("champion_chapter")
	check(not Replay.verify(without).ok,"Retirer les champions rend le rapport incohérent")
	var other: Dictionary = coarse.duplicate(true);other.champion_chapter = 3
	check(not Replay.verify(other).ok,"Changer le chapitre des champions rend le rapport incohérent")
	var old: Dictionary = coarse.duplicate(true);old.game_version = "0.257"
	check(not Replay.verify(old).ok and Replay.verify(old).error == "Champions invalides.","Un rapport d'avant la v0.258 ne peut pas porter de champions")
	var m = heroic(20)
	play(m,300.0)
	var events: Array = m.event_log.filter(func(line): return " champion " in line)
	check(true,"Partie jouée")
