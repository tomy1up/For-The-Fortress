# Prototype v0.262 — Héroïque calibré mission par mission

Calibrage de l'Héroïque (lot 5 du cadrage), sur la cible validée par le porteur le 27 novembre 2026 : la meilleure composition d'un joueur avisé finit chaque mission héroïque avec 40 à 70 % de ses PV de forteresse. Réglages de prototype à confirmer en jeu.

## Ce qui change

- En **Héroïque**, les PV ennemis ne sont plus ceux du Normal × 1,3 partout. Chaque mission a son propre coefficient pour chaque faction.
- **Chapitres 1 à 10 :** l'Héroïque devient nettement plus dur qu'avant. Les PV vont de 1,8 à 2,1 fois ceux du Normal au chapitre 1, puis environ 1,2 fois au chapitre 10.
- **Chapitres 11 à 20 :** l'Héroïque devient jouable. Les PV restent proches de ceux du Normal (82 à 120 %), car les champions et les deux rappels par mission suffisent à le durcir. **95 réglages sur 400** (44 pour l'Alliance, 51 pour la Horde) ont moins de PV que le Normal, tous dans ces chapitres.
- Sur les tirages du calibrage, **386 réglages sur 400 sont dans la cible** (marge moyenne : 56 % pour l'Alliance, 58 % pour la Horde). En v0.261, la marge moyenne était de 31 et 41 %, et beaucoup de missions étaient perdues.
- Les quatorze réglages hors cible sont des falaises (de 32 à 80 % de marge), que les PV seuls ne peuvent pas corriger.
- Le Normal ne change pas. Champions, rappels, bonus héroïques et récompenses non plus.

Contrôle sur trois autres tirages : 294 réglages sur 400 dans la cible, marge moyenne 49 % (Alliance) et 51 % (Horde), aucune mission perdue par toutes les compositions. Sur des tirages neufs, la marge est environ 7 points plus basse, mais reste dans la cible.

Fiche : `design/Calibrage_Heroique_v0262.md`.

## Contrôles

- Régression complète : 155 suites sur 155, 265 505 contrôles Godot, 17 tests Python. Nouvelle suite `test_heroic_calibration.gd` (1 206 contrôles) ; `test_difficulties.gd` suit la nouvelle formule.
- Les rapports des versions 0.257 à 0.261 se rejouent sans changement (les PV joués sont enregistrés dans le rapport) ; le Normal est inchangé.
- Paquet Windows vérifié : 1 050 cas et 672 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures inspectées depuis le jeu exporté, onglet Héroïque : mission 101 à 207 % (Alliance) et 223 % (Horde), mission 25 à 217 % (Horde), conformes au catalogue.
