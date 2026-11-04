extends SceneTree
const Geometry=preload("res://scripts/route_geometry.gd")
const Model=preload("res://scripts/valley_model.gd")
const Maps=preload("res://scripts/map_definition.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks+=1
	if not value: failures+=1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	# Deux entrées d'inégale longueur, jonction (4,4), sortie commune (10,4).
	var upper: Array[Vector2]=[Vector2(0,2),Vector2(4,2),Vector2(4,4),Vector2(10,4)]
	var lower: Array[Vector2]=[Vector2(0,8),Vector2(4,8),Vector2(4,4),Vector2(10,4)]
	var routes: Array[Dictionary]=[{"id":"upper","path_points":upper,"path_length":12.0},{"id":"lower","path_points":lower,"path_length":14.0}]
	check(Geometry.network_error(routes).is_empty() and Geometry.common_exit_error(routes).is_empty(),"Deux entrées rejoignent une forteresse")
	check(Geometry.position_at(7,upper,12)==Vector2(5,4) and Geometry.position_at(7,lower,14)==Vector2(4,5),"Une même progression ne désigne pas le même lieu")
	check(Geometry.cross_separation_squared(7,upper,12,7,lower,14)==2.0,"Proximité physique entre deux trajets")
	check(Geometry.cross_separation_squared(7,upper,12,9,lower,14)==0.0,"Après jonction : même position malgré deux progressions différentes")
	check(Geometry.cross_separation_squared(3,upper,12,3,lower,14)==36.0,"Avant jonction : pas de proximité fictive entre entrées")
	var cover: Dictionary=Geometry.network_coverage(Vector2(7,4),1.0,routes)
	check(cover.upper==[{"first":8.0,"last":10.0}] and cover.lower==[{"first":10.0,"last":12.0}],"Portée sur le tronc commun exprimée dans chaque trajet")
	var upper_only: Dictionary=Geometry.network_coverage(Vector2(1,2),0.5,routes)
	check(upper_only.upper==[{"first":0.5,"last":1.5}] and upper_only.lower.is_empty(),"Défenseur couvrant une seule entrée")
	check(Geometry.network_coverage(Vector2(4,4),0.0,routes).upper==[{"first":6.0,"last":6.0}],"Jonction tangente : fenêtre ponctuelle fusionnée")
	for route in routes:
		var points: Array[Vector2]=[];points.assign(route.path_points)
		check(Geometry.position_at(-100,points,route.path_length)==points[0] and Geometry.position_at(100,points,route.path_length)==points[-1],"Progression bornée par la longueur de son trajet")
	var copied:=Geometry.network_copy(routes)
	copied[0].path_points[0]=Vector2(9,9)
	check(routes[0].path_points[0]==Vector2(0,2),"Le réseau possède ses coordonnées")
	var selected:=Geometry.route_for(routes,"lower");selected.path_points[0]=Vector2(9,9)
	check(routes[1].path_points[0]==Vector2(0,8) and Geometry.route_for(routes,"absent").is_empty(),"Sélection isolée et trajet inconnu rejeté")
	var other_exit:=routes.duplicate(true);other_exit[1].path_points[-1]=Vector2(11,4);other_exit[1].path_length=15.0
	check(Geometry.network_error(other_exit).is_empty() and not Geometry.common_exit_error(other_exit).is_empty(),"Réseau géométrique distinct de la règle à forteresse unique")
	var destinations := {"west": Vector2(10,4), "east": Vector2(11,4)}
	other_exit[0].destination_id = "west"
	other_exit[1].destination_id = "east"
	check(Geometry.destinations_error(other_exit,destinations).is_empty(),"Deux sorties distinctes peuvent designer deux forteresses")
	check(not Geometry.destinations_error(routes,destinations).is_empty(),"Une destination doit etre explicite")
	check(not Geometry.destinations_error(other_exit,{"west": Vector2(10,4)}).is_empty(),"Une sortie inconnue est rejetee")
	check(not Geometry.destinations_error(other_exit,{"west": Vector2(10,4), "east": Vector2(11,5)}).is_empty(),"Le trajet doit atteindre la forteresse declaree")
	check(not Geometry.destinations_error(other_exit,{"west": Vector2(10,4), "east": Vector2(11,4), "unused": Vector2(12,4)}).is_empty(),"Chaque forteresse doit avoir un trajet")
	check(not Geometry.destinations_error(other_exit,{"west": Vector2(10,4), "east": Vector2(10,4)}).is_empty(),"Deux forteresses ne partagent pas le meme point")

	var invalid: Array=[]
	invalid.append([]);invalid.append(null);invalid.append([3])
	for mutation in ["duplicate_id","missing_id","empty_id","space_id","missing_points","zero_segment","nan_point","wrong_length","infinite_length"]:
		var broken:=routes.duplicate(true)
		match mutation:
			"duplicate_id": broken[1].id="upper"
			"missing_id": broken[0].erase("id")
			"empty_id": broken[0].id=""
			"space_id": broken[0].id=" upper"
			"missing_points": broken[0].erase("path_points")
			"zero_segment": broken[0].path_points[1]=broken[0].path_points[0]
			"nan_point": broken[0].path_points[1]=Vector2(NAN,2)
			"wrong_length": broken[0].path_length=14.0
			"infinite_length": broken[0].path_length=INF
		invalid.append(broken)
	for broken in invalid:
		check(not Geometry.network_error(broken).is_empty() and Geometry.network_copy(broken).is_empty(),"Réseau incohérent refusé sans route de secours")
	check(Geometry.network_coverage(Vector2.ZERO,-1.0,routes).is_empty() and Geometry.network_coverage(Vector2.ZERO,INF,routes).is_empty(),"Portées invalides refusées")
	check(Geometry.network_coverage(Vector2(NAN,0),1.0,routes).is_empty(),"Position de défenseur invalide refusée")
	# Le voisinage strict < 1 doit conserver ses bornes float 64, sur deux routes.
	check(Geometry.cross_separation_squared(7,upper,12,10,lower,14)==1.0,"Rebond : frontière exacte")
	check(Geometry.cross_separation_squared(7,upper,12,10-1e-10,lower,14)<1.0,"Rebond : très légèrement dans la portée")
	check(Geometry.cross_separation_squared(7,upper,12,10+1e-10,lower,14)>1.0,"Rebond : très légèrement hors de portée")
	print("ROUTE_GEOMETRY_TESTS checks=%d failures=%d"%[checks,failures])
	quit(0 if failures==0 else 1)
