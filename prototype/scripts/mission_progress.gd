extends RefCounted
## Calcul sans profil ni effet de jeu. Aucun barème de campagne définitif.
const Catalogue = preload("res://scripts/campaign_catalogue.gd")

static func campaign_status(receipts: Dictionary) -> Dictionary:
	var missions: Array[bool] = []
	var chapters: Array[int] = [];chapters.resize(Catalogue.CHAPTER_COUNT);chapters.fill(0)
	var total: int = 0;var first_hundred: int = 0;var next_unwon: int = 0
	for number in range(1,Catalogue.TOTAL_MISSIONS+1):
		var completed: bool = _valid_receipt(receipts.get(Catalogue.id_for(number)))
		missions.append(completed)
		if completed:
			total += 1;chapters[(number-1)/Catalogue.CHAPTER_SIZE] += 1
			if number <= Catalogue.INFINITE_REQUIREMENT: first_hundred += 1
		elif next_unwon == 0: next_unwon = number
	return {"completed":total,"first_hundred":first_hundred,"infinite_eligible":first_hundred == Catalogue.INFINITE_REQUIREMENT,"missions":missions,"chapters":chapters,"next_unwon":next_unwon}

static func _valid_receipt(value: Variant) -> bool:
	if not value is Dictionary: return false
	for key in ["reward","run_id"]:
		var number: Variant = value.get(key)
		if not (number is int or number is float) or not is_finite(float(number)) or number != floorf(float(number)) or number < (1 if key == "run_id" else 0) or number > 1000000000: return false
	if value.has("xp"):
		var xp: Variant = value.xp
		if not (xp is int or xp is float) or not is_finite(float(xp)) or xp != floorf(float(xp)) or xp < 0 or xp > 1000000000: return false
	return true
static func valid_id(id: Variant) -> bool:
	if not id is String or id.is_empty() or id.length() > 64: return false
	for character in id:
		if not character in "abcdefghijklmnopqrstuvwxyz0123456789_.-": return false
	return true

static func distribute_budget(total: int, missions: int = 100) -> Array[int]:
	var rewards: Array[int] = []
	if total < 0 or total > 1000000000 or missions < 1 or missions > 10000: return rewards
	var previous: int = 0
	for number in range(1,missions+1):
		# Calcul entier : aucune pièce perdue par les arrondis.
		var cumulative: int = (total*number+missions-1)/missions
		rewards.append(cumulative-previous);previous = cumulative
	return rewards
