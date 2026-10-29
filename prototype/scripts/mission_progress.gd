extends RefCounted
## Calcul sans profil ni effet de jeu. Aucun barème de campagne définitif.
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
