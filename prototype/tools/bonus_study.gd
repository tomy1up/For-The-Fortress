extends "res://tools/faction_study.gd"
## Valeur des bonus (v0.253) : l'armée de référence des tests (`tests/reference_army.gd`) joue chaque mission avec un bonus imposé au premier choix (vague 2),
## puis le choix de référence aux choix suivants. CODE=-1 : premier choix naturel (référence). Sert à repérer les bonus trop faibles ou trop décisifs.
## Usage : MISSIONS=2,7,… FACTIONS=0,1 SEED=7 [CODES=0,1,…] godot --headless --path prototype --script res://tools/bonus_study.gd
## Sortie : « BONUS mission faction tirage code résultat PV_restants PV_maximaux ».
var forced: int = -1

func _pick(m) -> int:
	if m.bonuses.is_empty() and forced >= 0:
		m.bonus_offer.assign([forced])
		return forced
	return Model.reference_bonus(m.bonus_offer)

func _initialize() -> void:
	var missions: Array = []
	for part in OS.get_environment("MISSIONS").split(",",false): missions.append(int(part))
	var factions: Array = [0,1]
	if OS.get_environment("FACTIONS") != "":
		factions = []
		for part in OS.get_environment("FACTIONS").split(",",false): factions.append(int(part))
	var codes: Array = [-1]
	if OS.get_environment("CODES") != "":
		codes = []
		for part in OS.get_environment("CODES").split(",",false): codes.append(int(part))
	else:
		for code in range(Model.Campaign.BONUSES.size()): codes.append(code)
	OS.set_environment("POLICY","")
	for mission in missions:
		for faction in factions:
			var tree: int = Talents.coordinates(Reference.first_talent(faction,mission)).x
			for code in codes:
				forced = code
				var outcome: Dictionary = play(mission,faction,tree,Reference.types(faction,mission))
				print("BONUS %d %d %s %d %s %d %d" % [mission,faction,OS.get_environment("SEED"),code,outcome.result,outcome.hp,outcome.max])
	quit()
