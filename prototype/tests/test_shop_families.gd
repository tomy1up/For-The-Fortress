extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Linked = preload("res://scripts/meta_talents_linked.gd")
const Fixture = preload("res://tests/test_linked_talents.gd")
const Screen = preload("res://scripts/meta_screen.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var profile = Profile.new("")
		var screen = Screen.new();root.add_child(screen);screen.open(profile,faction)
		for index in range(Linked.NODE_COUNT):
			var node: Dictionary = Linked.node(faction,index)
			for card in Model.Shop.CARDS:
				if card.faction == faction and card.family in node.effect.get("types",[]):
					check(node.description.contains(card.name) and node.description.contains(Model.ROSTER[card.family].name),"Chaque talent concerné cite la base et son alternative")
				elif card.faction != faction:
					check(not node.description.contains(card.name),"Aucune alternative étrangère dans une description")
			var preview: Dictionary = Linked.rank_preview(faction,Linked.empty_ranks(),index)
			if not preview.is_empty():
				var gain: String = screen._rank_gain(index)
				for unit in preview.units:
					for card in Model.Shop.for_faction(faction):
						if card.family == unit.type: check(gain.contains(card.name),"Le prochain rang cite également l’alternative bénéficiaire")
		for tree in range(3):
			var ranks: Array = Fixture.build(tree)
			check(Linked.valid(ranks),"Configuration liée 31/20 valide")
			for card in Model.Shop.CARDS:
				var expected: Dictionary = Linked.effects(faction,ranks,card.family)
				check(Linked.effects(faction,ranks,card.type) == expected and Model.MetaTalents.effects(faction,ranks,card.type) == expected,"Les effets de famille concordent avec les configurations liées actuelles")
		for code in [1,3,4]:
			var description: String = Model.Campaign.bonus_description(code,faction).to_lower()
			for card in Model.Shop.for_faction(faction):
				if card.type > 9: continue # Les libellés de bonus ne citent que les quatre alternatives d'origine (limite de la boutique étendue).
				if code == 1 or faction == 1:
					check(description.contains(card.name.to_lower()),"Les bonus concernés explicitent les alternatives du bon camp")
		screen.free()
	print("SHOP_FAMILIES_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
