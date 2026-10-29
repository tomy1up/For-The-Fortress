extends SceneTree
const Experience = preload("res://scripts/talent_experience.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void:
	check(Experience.points_for_xp(0) == 0 and Experience.points_for_xp(Experience.TARGET_XP) == 51,"Zéro point au départ, exactement 51 au budget des cent premières missions")
	check(Experience.points_for_xp(99*Experience.XP_PER_MISSION) < 51,"Le maximum n’est pas atteint avant la centième mission de référence")
	for point in range(1,52):
		var threshold: int = Experience.xp_for_points(point)
		check(Experience.points_for_xp(threshold) == point and Experience.points_for_xp(threshold-1) == point-1,"Chaque seuil entier débloque exactement un point, sans arrondi anticipé")
		var preview: Dictionary = Experience.progress(threshold-1)
		check(preview.next_xp == threshold and preview.remaining == 1 and not preview.at_cap,"Le prochain point est annoncé au seuil exact")
	var previous: int = 0
	for mission in range(1,201):
		var progress: Dictionary = Experience.progress(mission*Experience.XP_PER_MISSION)
		check(progress.points >= previous and progress.points <= 51,"Progression monotone, sans point supplémentaire après le plafond")
		previous = progress.points
	check(Experience.progress(20000).at_cap and Experience.progress(20000).remaining == 0,"XP ultérieure conservable sans dépasser 51 points")
	check(Experience.xp_for_points(52) == -1,"Aucun prix XP inventé au-delà du plafond")
	print("TALENT_EXPERIENCE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
