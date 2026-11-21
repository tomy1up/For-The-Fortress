extends RefCounted
## Composition de référence des suites de campagne : garde-fou de la difficulté, elle doit gagner chaque mission avec la stratégie d'achat fixe des tests
## (deux unités à l'ouverture sur les emplacements 3 et 4, la troisième à la vague 2 sur l'emplacement 2, mêmes améliorations, bonus de référence).
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
