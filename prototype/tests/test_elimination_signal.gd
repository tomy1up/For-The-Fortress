extends SceneTree
## Signal bref d'élimination (décision du porteur, 15 novembre 2026) : durées par catégorie, regroupement des éclats, choix de la planche de mort du Capitaine orc
## par diagonale et repli sur le fondu de la pose courante. Rendu seulement.
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Library = preload("res://scripts/animation_library.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	check(is_equal_approx(View.elimination_duration(1),0.15) and is_equal_approx(View.elimination_duration(10),0.25) and is_equal_approx(View.elimination_duration(7),0.45),"Durées : 0,15 s ordinaire, 0,25 s élite, 0,45 s boss")
	var event := {"time":1.0,"enemy_id":3,"type":1,"point":Vector2(4,3),"distance":4.0,"route_id":""}
	check(View.elimination_particles(event,0.14).size() == 5 and View.elimination_particles(event,0.15).is_empty(),"Éclat ordinaire éteint à 0,15 s")
	var single: Array[Dictionary] = View.elimination_particles(event,0.05,1)
	var crowd: Array[Dictionary] = View.elimination_particles(event,0.05,3)
	check(crowd.size() == single.size() and crowd[0].radius > single[0].radius and crowd[0].radius < single[0].radius*2.0,"Un éclat regroupé est plus large sans multiplier les particules")
	var elite := {"time":1.0,"enemy_id":4,"type":10,"point":Vector2(4,3),"distance":4.0,"route_id":""}
	check(not View.elimination_particles(elite,0.2).is_empty() and View.elimination_particles(elite,0.25).is_empty(),"Éclat d'élite jusqu'à 0,25 s")
	# Capitaine orc : planche dessinée pour le sud-est seulement.
	var spec: Dictionary = Library.spec_for("enemy.horde.garrison")
	check(not spec.is_empty() and spec.animations.has("death_se") and not spec.animations.has("death_nw"),"Capitaine orc : planche de mort pour le sud-est seulement")
	check(Library.death_state(spec,Vector2(1,1)) == "death_se","Direction sud-est : planche dessinée")
	for direction in [Vector2(-1,-1),Vector2(1,-1),Vector2(-1,1),Vector2(1,0),Vector2.ZERO]:
		check(Library.death_state(spec,direction) == "","Autre direction (%s) : fondu de la pose courante" % direction)
	check(Library.death_state({},Vector2(1,1)) == "" and Library.death_state(Library.spec_for("enemy.horde.warrior"),Vector2(1,1)) == Library.death_state(Library.spec_for("enemy.horde.warrior"),Vector2(-1,-1)),"Ennemi sans planche de mort : repli ; ennemi sans quatre vues : même choix partout")
	check(Library.death_window() >= 0.25,"La fenêtre de mort couvre la planche de 0,25 s")
	# Dessin complet : élites et ennemis ordinaires éliminés à différents âges, sans erreur ni modification du combat.
	var m = Model.new(true,Model.Maps.for_id("garrison_hall"))
	m.select_faction(0)
	var view := View.new();view.model = m;root.add_child(view)
	m.phase = "combat";m.elapsed = 10.0
	var types: Array = [1,1,1,10,10,3,7,0]
	for index in range(types.size()):
		m.elimination_events.append({"time":10.0-0.04*index,"enemy_id":100+index,"type":types[index],"point":Vector2(4+0.2*index,1),"distance":4.0+index,"route_id":str(m.routes[0].id) if not m.routes.is_empty() else ""})
	var before: String = JSON.stringify([m.gold,m.fortress_hp,m.enemies])
	view.queue_redraw()
	await process_frame
	await process_frame
	check(JSON.stringify([m.gold,m.fortress_hp,m.enemies]) == before and view._ghost_alpha == 1.0 and view._ghost_squash == 1.0,"Dessiner le signal ne modifie pas le combat et rétablit l'opacité")
	check(view.recent_eliminations().size() == types.size(),"Toutes les éliminations récentes sont dessinées")
	view.free()
	# Recalage des dégâts sur l'arrivée du projectile (retour du porteur, 16 novembre 2026).
	check(is_equal_approx(View.damage_landing_delay({"source_type":15,"component":"direct"}),0.288+View.PROJECTILE_FLIGHT),"Dégât direct du pyromancien : attend le lâcher puis le vol")
	check(View.damage_landing_delay({"source_type":15,"component":"curse"}) == 0.0 and View.damage_landing_delay({"source_type":-1,"component":"direct"}) == 0.0 and View.damage_landing_delay({}) == 0.0,"Brûlure et origine inconnue : aucun décalage")
	var sync = Model.new();sync.phase = "combat";sync.elapsed = 5.0
	var victim: Dictionary = Model.make_enemy(0,1,0);victim.distance = 3.0;victim.hp = 30.0;victim.max_hp = 40.0
	sync.enemies.assign([victim])
	sync.damage_events.append({"time":5.0,"enemy_id":0,"hp_before":40.0,"hp_after":30.0,"source_type":15,"component":"direct"})
	var sview := View.new();sview.model = sync
	check(is_equal_approx(sview.visual_hp(victim),40.0),"Avant l'arrivée du projectile, la barre montre encore les PV d'avant")
	sync.elapsed = 5.2
	check(is_equal_approx(sview.visual_hp(victim),40.0) and sview.recent_enemy_damage(0).is_empty(),"À 0,2 s : ni baisse de la barre ni éclat de dégâts")
	sync.elapsed = 5.5
	check(is_equal_approx(sview.visual_hp(victim),30.0) and sview.recent_enemy_damage(0).size() == 1,"Après l'arrivée (0,408 s) : la barre baisse et l'éclat apparaît")
	sync.elapsed = 5.0;sync.elimination_events.append({"time":5.0,"enemy_id":0,"type":1,"point":Vector2(2,2),"distance":3.0,"route_id":"","source_type":15,"component":"direct"})
	sync.elapsed = 5.1
	var pending: Array[Dictionary] = sview.recent_eliminations()
	check(pending.size() == 1 and pending[0].age < 0.0,"Un ennemi tué reste à l'écran tant que le projectile n'est pas arrivé")
	sync.elapsed = 5.45
	pending = sview.recent_eliminations()
	check(pending.size() == 1 and pending[0].age >= 0.0 and pending[0].age < 0.1,"Sa disparition commence à l'arrivée")
	sview.free()
	print("ELIMINATION_SIGNAL_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
