# Prototype v0.222 — Audit des unités et des bonus : trois règles tranchées par le porteur

Suite à l'audit de cohérence demandé par le porteur (fiche contre comportement réel), trois règles sont décidées le 16 novembre 2026 :

- **Dégâts sur la durée (dots) et talents du Mage** : les talents de l'arbre du Mage qui améliorent les explosions améliorent aussi la brûlure du Pyromancien humain (même progression). Les descriptions de talents parlent désormais de « dégâts sur la durée (malédictions, brûlures) » ; côté Mage : « explosions et dégâts sur la durée ».
- **Bonus « Exercice de tir » (R-02)** : le texte est explicite et le bonus s'applique aussi aux alternatives de boutique du chaman (Brûleur de cendres, Chaman des marais) ; le chaman orc de base et ses spécialisations restent exclus.
- **Aura du Prêtre guerrier et de l'Ancien des tribus** : rayon porté de 3,6 à **4,2 cases**, le plus petit rayon qui garantit au moins un voisin sur chacune des 181 cartes de la campagne (les cartes ne sont pas modifiées, pour ne pas toucher les autres unités). Mesure : à 3,6, sept cartes (dont la Vallée du Gué) n'avaient aucun voisin à portée ; à 4,2, aucune.
- **Règles datées** : les rapports d'avant la v0.222 se rejouent avec les anciennes règles (`Model.rules_v222`, `Replay.rules_v222_for`) ; testé par rejeu.
- **Audits automatiques ajoutés** : `test_unit_effects.gd` (77 contrôles, les 46 unités), `test_bonus_effects.gd` (379 contrôles, les douze bonus de partie) et `test_rules_v222.gd` (20 contrôles).
- Valeurs de prototype à confirmer en jeu (équilibre non mesuré au-delà des tests).
