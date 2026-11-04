extends SceneTree
const Model=preload("res://scripts/valley_model.gd")
const Main=preload("res://scripts/main.gd")
const View=preload("res://scripts/valley_view.gd")
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var guard: Dictionary=Model.make_enemy(8,8,0)
	var second: Dictionary=Model.make_enemy(3,8,0)
	var target: Dictionary=Model.make_enemy(1,1,0)
	var positions: Dictionary={1:Vector2.ZERO,8:Vector2(2,0),3:Vector2(-2,0)}
	check(Model.Banks.guardian_for(target,[guard,second],positions)==3,"Protection à la borne incluse ; égalité départagée par identifiant")
	check(Model.Banks.guardian_for(target,[second,guard],positions)==3,"Aucune dépendance à l'ordre des gardiennes")
	positions[8]=Vector2(1,0)
	check(Model.Banks.guardian_for(target,[second,guard],positions)==8,"La plus proche est prioritaire")
	check(Model.Banks.guardian_for(target,[second,guard],positions,{8:guard.hp})==3,"Une gardienne tuée directement ne protège pas le coup")
	guard.hp=0;second.hp=0
	check(Model.Banks.guardian_for(target,[guard,second],positions)==-1,"Aucun lien avec une gardienne morte")
	guard.hp=180;second.hp=180;positions[8]=Vector2(2.0001,0);positions[3]=Vector2(-3,0)
	check(Model.Banks.guardian_for(target,[guard,second],positions)==-1,"Hors rayon, aucune protection")
	for camp in range(2):
		var scene=Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(camp)
		scene.model.enemies.clear();scene.model.phase="combat";scene.model.spawn_schedule.clear()
		for type in [8,1,2,7]:
			var enemy: Dictionary=Model.make_enemy(scene.model.enemies.size(),type,0,camp)
			enemy.distance=8.0+scene.model.enemies.size()*.5;scene.model.enemies.append(enemy)
		var before: Array=[scene.model.enemies.duplicate(true),scene.model.gold,scene.model.rng.state,scene.model.elapsed]
		scene.map_view.inspected_enemy_id=0
		var links: Array[Dictionary]=scene.map_view.inspected_protection_links()
		check(links.size()==2,"Le survol de la gardienne relie seulement ses deux voisins, pas le boss")
		scene.map_view.inspected_enemy_id=1;links=scene.map_view.inspected_protection_links()
		check(links.size()==1 and links[0].guardian_id==0 and links[0].enemy_id==1,"Le voisin montre uniquement sa gardienne actuelle")
		check([scene.model.enemies,scene.model.gold,scene.model.rng.state,scene.model.elapsed]==before,"L'observation ne change ni combat ni hasard")
		scene.model.enemies[0].hp=0
		check(scene.map_view.inspected_protection_links().is_empty(),"La mort de la gardienne retire immédiatement le lien")
		scene.model.enemies[0].hp=180;scene.model.enemies[1].distance=20
		check(scene.map_view.inspected_protection_links().is_empty(),"Le déplacement hors rayon retire le lien")
		scene.model.enemies[1].distance=8.5
		for phase in ["preparation","finished","bonus","victory","defeat"]:
			scene.model.phase=phase
			check(scene.map_view.inspected_protection_links().is_empty(),"Aucun lien hors combat")
		scene.model.phase="combat";scene.model.enemies.resize(1)
		scene.inspection_pointer=View.enemy_bounds(scene.model.enemies[0],camp).get_center()
		scene._update_enemy_inspector()
		check(scene.enemy_inspector.visible and scene.enemy_status.text=="Aucun voisin protégé","Une gardienne isolée annonce aucun voisin")
		scene.model.curses.assign([{"enemy_id":0,"source_id":1,"damage":1.0}]);scene._update_enemy_inspector()
		check(scene.enemy_status.text.contains("Maudite"),"La malédiction n'est plus masquée par le rôle Gardienne")
		var enemy: Dictionary=Model.make_enemy(1,1,0,camp);enemy.distance=9
		scene.model.enemies.append(enemy)
		scene.inspection_pointer=View.enemy_bounds(enemy,camp).get_center();scene._update_enemy_inspector()
		check(scene.map_view.inspected_enemy_id==1 and scene.enemy_status.text=="25 % des dégâts transférés","Le voisin indique la part de dégâts absorbée")
		scene.model.curses.assign([{"enemy_id":1,"source_id":1,"damage":1.0}]);scene._update_enemy_inspector()
		check(scene.enemy_status.text=="25 % des dégâts transférés · Maudit","Protection et malédiction sont lisibles ensemble")
		var font: Font=scene.enemy_status.get_theme_font("font")
		check(font.get_string_size(scene.enemy_status.text,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x<=scene.enemy_status.size.x,"Le statut tient dans sa ligne")
		scene.free()
	print("GUARDIAN_INSPECTION_TESTS checks=%d failures=%d"%[checks,failures])
	quit(0 if failures==0 else 1)
