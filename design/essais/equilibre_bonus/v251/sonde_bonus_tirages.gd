extends "res://tools/faction_study.gd"
## Sonde des bonus choisis par la référence selon le tirage (24 novembre 2026). À copier dans `prototype/tools/` pour la lancer : godot --headless --path prototype --script res://tools/sonde_bonus_tirages.gd
func _pick(m) -> int:
	var code: int = Model.reference_bonus(m.bonus_offer)
	print("PICK wave=%d hp=%d offer=%s pick=%d" % [m.wave,m.fortress_hp,str(m.bonus_offer),code])
	return code
func _initialize() -> void:
	for mission in [30,40,100,200]:
		for seed in [7,8,9]:
			OS.set_environment("SEED",str(seed))
			OS.set_environment("POLICY","ref")
			var tree: int = Talents.coordinates(Reference.first_talent(1,mission)).x
			var outcome: Dictionary = play(mission,1,tree,Reference.types(1,mission))
			print("RESULT mission=%d seed=%d %s hp=%d/%d" % [mission,seed,outcome.result,outcome.hp,outcome.max])
	quit()
