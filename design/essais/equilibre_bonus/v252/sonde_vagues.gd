extends "res://tools/faction_study.gd"
## Sonde : PV de forteresse après chaque vague, pour les 30 compositions et la référence. Env : MISSIONS, FACTIONS, SEED, HPMUL facultatif.
var trace: Array = []
func _play_waves(m, first: int, slots: Array, types: Array, look: bool) -> void:
	trace = []
	for wave in range(first,11):
		if wave == 2: m.upgrade(slots[0])
		if wave >= 2 and m.defenders[slots[2]].is_empty(): m.buy(slots[2],types[2])
		if wave >= 5:
			for slot in slots:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): break
		m.advance(10000)
		trace.append(m.fortress_hp)
		if m.phase == "defeat": break
		if m.phase == "bonus": m.choose_bonus(_pick(m))
		if wave < 10: m.prepare_next_wave()
func _initialize() -> void:
	var missions: Array = []
	for part in OS.get_environment("MISSIONS").split(","): missions.append(int(part))
	var factions: Array = []
	for part in OS.get_environment("FACTIONS").split(","): factions.append(int(part))
	for mission in missions:
		for faction in factions:
			var base: int = 0 if faction == 0 else 3
			for tree in range(3):
				for a in range(3):
					for b in range(a,3):
						for c in range(b,3):
							var outcome: Dictionary = play(mission,faction,tree,[base+a,base+b,base+c])
							print("WAVES %d %d %s %d %d%d%d %s %d %s" % [mission,faction,OS.get_environment("SEED"),tree,a,b,c,outcome.result,outcome.max,",".join(trace.map(func(x): return str(x)))])
			OS.set_environment("POLICY","ref")
			var rt: int = Talents.coordinates(Reference.first_talent(faction,mission)).x
			var ro: Dictionary = play(mission,faction,rt,Reference.types(faction,mission))
			OS.set_environment("POLICY","")
			print("WAVESREF %d %d %s %d ref %s %d %s" % [mission,faction,OS.get_environment("SEED"),rt,ro.result,ro.max,",".join(trace.map(func(x): return str(x)))])
	quit()
