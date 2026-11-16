extends SceneTree
const Art = preload("res://scripts/shop_art.gd")
const View = preload("res://scripts/valley_view.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void:
	for card in Shop.CARDS:
		var type: int = card.type
		if type >= Art.PROVISIONAL_FROM and not Art.OWN_ART.has(type): continue # Illustration provisoire de la famille, en attendant Codex.
		check(View.defender_art(type) == Art and Art.TEXTURES[type] != View.defender_art(card.family).TEXTURES[card.family],"Chaque alternative a son illustration propre")
		var image: Image = Art.TEXTURES[type].get_image()
		check(image != null and image.get_pixel(0,0).a == 0.0,"Sprite transparent sans décor au coin")
		var frame: Dictionary = Art.FRAMES[type]
		check(Rect2(Vector2.ZERO,image.get_size()).encloses(frame.source),"Le cadre source reste dans le PNG")
		var bounds: Rect2 = Art.destination(type)
		check(Rect2(-44,-78,88,110).encloses(bounds) and is_zero_approx(bounds.end.y),"Silhouette dans l’espace réservé du plateau et ancrée sur ses pieds")
		var shot: Dictionary = {"type":type,"from":Vector2(2,6),"to":Vector2(3,3)}
		var right: Vector2 = View.shot_origin(shot)-View.project(shot.from)
		shot.to = Vector2(1,7)
		check(type in View.TILTED_TYPES or type in [View.STONE_TYPE,View.SPEARMAN_TYPE] or (right.is_equal_approx(Art.MUZZLES[type]) and (View.shot_origin(shot)-View.project(shot.from)).is_equal_approx(Vector2(-right.x,right.y))),"Origine des projectiles propre à la nouvelle arme et symétrique")
	check(Art.portrait(10) == Art.PORTRAITS[10] and Art.portrait(10) != Art.TEXTURES[10] and Art.portrait(16) == Art.PORTRAITS[16] and Art.portrait(16) != Art.TEXTURES[16] and Art.portrait(17) == Art.TEXTURES[17],"Portrait de boutique propre à la sentinelle et au veilleur, sprite commun pour le javelinier")
	print("SHOP_ART_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
