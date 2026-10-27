extends SceneTree
const Main = preload("res://scripts/main.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func prepare(scene: Node, faction: int) -> void:
	scene._choose_faction(faction); scene.model.gold = 10000
	for slot in range(6): scene.model.buy(slot,faction*3+slot%3)
	scene.model.phase = "bonus"; scene.model.wave = 3; scene.model.bonus_offer.assign([2,9,8]); scene._update_interface()
	scene._open_bonus_details(0)
func run_checks() -> void:
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); prepare(scene,faction)
		await process_frame
		await process_frame
		var scroll: ScrollContainer = scene.bonus_impact_scrollers[0]
		check(scroll.get_v_scroll_bar().max_value > scroll.size.y,"Six bénéficiaires produisent une vraie liste défilante")
		scroll.scroll_vertical = 80
		await process_frame
		var previous: int = scroll.scroll_vertical
		scene._update_interface()
		check(previous > 0 and scroll.scroll_vertical == previous,"Les rafraîchissements ordinaires ne ramènent pas la lecture au début")
		scene.model.wave = 6; scene._update_interface(); scene._open_bonus_details(0)
		check(scroll.scroll_vertical == 0,"Un nouveau choix repart en haut même si les chiffres sont identiques")
		scroll.scroll_vertical = 80; scene._reset()
		check(scene.model.phase == "bonus" and scroll.scroll_vertical == 80,"Le choix obligatoire ne peut pas être effacé par une commande de fond")
		scene._choose_bonus(0); scene.model.phase = "defeat"; scene._reset()
		check(scroll.scroll_vertical == 0 and not scene.bonus_panel.visible,"Nouvel essai efface aussi le défilement de l'ancienne partie")
		prepare(scene,faction)
		check(scroll.scroll_vertical == 0,"Rejouer la même faction ne conserve pas une position de lecture ancienne")
		scene.free()
	print("BONUS_SCROLL_RESET_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
