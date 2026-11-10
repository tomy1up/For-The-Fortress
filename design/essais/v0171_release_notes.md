# Prototype v0.171 — Avertissement des éruptions allongé

À la demande du porteur, réglage de l'affixe Éruptions du chapitre 8 : l'avertissement passe de 2 s à 3 s avant chaque désactivation. La désactivation (5 s) et la fréquence (toutes les 14 s) sont inchangées, de même que les cartes et leurs emplacements : l'avertissement n'agit que sur l'affichage, pas sur le combat, donc l'équilibrage mesuré en v0.170 reste valable (les deux factions gagnent chaque carte avec leur armée de référence).

Valeurs de prototype à confirmer en jeu : `{"id":"eruptions","interval":14,"warning":3,"duration":5}`. Les rapports de la v0.170 (avertissement de 2 s) restent rejouables.
La régression complète réussit : 105 suites, 66 556 contrôles Godot et 17 tests Python. 5 essais Windows ciblés et 87 empreintes de sources réussissent.
