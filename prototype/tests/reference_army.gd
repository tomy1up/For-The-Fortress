extends RefCounted
## Composition de référence des suites de campagne : garde-fou de la difficulté, elle doit gagner chaque mission avec la stratégie d'achat fixe des tests
## (deux unités à l'ouverture sur les emplacements 3 et 4, la troisième à la vague 2 sur l'emplacement 2, mêmes améliorations, choix de bonus avisé `choose_bonus` depuis la v0.255).
## Alliance : archer elfe et deux arbalétriers nains, arbre Maîtrise du tir, sur toute la campagne.
## Horde, depuis la v0.235 (décision du porteur du 21 novembre 2026 de changer la référence, O-028) : deux lanceurs de haches et un chaman orc (arbre Fureur de guerre)
## jusqu'au chapitre 7, puis deux sapeurs gobelins et un chaman orc (arbre Démolition) à partir de la mission 71. Jusqu'à la v0.234, les haches servaient partout et
## bridaient 89 missions de la Horde au-dessus de la cible de marge. Fiche : `design/Rebalancage_v0235.md`.
const ALLIANCE: Array = [0,1,1]
const HORDE_EARLY: Array = [3,3,5]
const HORDE_LATE: Array = [4,4,5]
## Première mission jouée par la seconde référence de la Horde.
const HORDE_SWITCH_MISSION: int = 71

static func types(faction: int, mission: int) -> Array:
	if faction == 0: return ALLIANCE.duplicate()
	return (HORDE_LATE if mission >= HORDE_SWITCH_MISSION else HORDE_EARLY).duplicate()

## Premier talent investi (cinq rangs, puis un rang du suivant), dont l'arbre reçoit ensuite tous les points : arbre 1 de l'Alliance (index 5), arbre 0 (index 0) ou 2 (index 10) de la Horde.
static func first_talent(faction: int, mission: int) -> int:
	if faction == 0: return 5
	return 10 if mission >= HORDE_SWITCH_MISSION else 0

## Choix de bonus avisé (v0.255, décision du porteur du 25 novembre 2026 : « Garantie des tests seulement ») : l'armée de référence ne prend plus la première offre sans
## contrepartie (`Model.reference_bonus`), elle choisit la carte la mieux notée pour sa faction et relance une fois si la meilleure carte proposée est sous la médiane.
## Notes : PV de forteresse restants (en %) quand le bonus est imposé au premier choix de la référence, 40 missions, tirages 7, 8 et 9, règles v0.254
## (`design/essais/equilibre_bonus/v255/valeur_bonus.txt`). La cible de difficulté, elle, reste mesurée avec la première offre (MAJ-79).
## Bonus héroïques (codes 60 à 74, valeurs de la v0.261) : imposés au premier choix en contexte héroïque (champions, rappels, second choix héroïque) aux PV du Normal,
## notes ramenées à cette échelle par trois repères (Armes affûtées, Lames runiques, Armée d'élite) ; `design/essais/equilibre_bonus/v261/`. Elles départagent les deux cartes du second choix.
const BONUS_VALUES: Array = [
	[51,62,52,32,32,61,59,36,41,41,43,50,59,58,31,31,63,31,31,62,63,49,45,34,28,42,53,52,53,50,47,52,50,53,59,61,82,24,24,27,70,76,39,56,55,54,45,65,50,60,40,61,31,96,93,90,46,21,88,28,54,66,66,84,90,84,89,50,88,66,84,53,61,50,82],
	[31,46,38,15,30,34,38,11,15,14,21,25,10,40,13,15,17,55,9,46,37,26,25,8,6,20,32,24,30,17,17,28,24,28,30,41,59,15,30,34,32,68,23,64,42,32,22,20,47,55,22,56,14,93,93,85,19,72,83,53,38,54,68,76,89,79,71,47,73,57,84,58,53,37,68]
]
## Relance si la meilleure carte vaut moins que la médiane de la faction.
const REROLL_BELOW: Array = [50,30]

static func bonus_value(faction: int, code: int) -> int:
	return int(BONUS_VALUES[clampi(faction,0,1)][code])

static func best_bonus(faction: int, offer: Array) -> int:
	var best: int = int(offer[0])
	for code in offer:
		if bonus_value(faction,int(code)) > bonus_value(faction,best): best = int(code)
	return best

## Choisit le bonus de la phase « bonus » : relance d'abord si l'offre est faible et qu'une relance reste, puis prend la carte la mieux notée.
static func choose_bonus(model) -> bool:
	if model.phase != "bonus" or model.bonus_offer.is_empty(): return false
	if model.rerolls_available() > 0 and bonus_value(model.faction,best_bonus(model.faction,model.bonus_offer)) < REROLL_BELOW[clampi(model.faction,0,1)]: model.reroll_bonus()
	return model.choose_bonus(best_bonus(model.faction,model.bonus_offer))
