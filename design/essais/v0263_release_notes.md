# Prototype v0.263 — Héroïque : toujours plus de PV que le Normal

Décisions du porteur du 28 novembre 2026 : les PV ennemis montent avec la difficulté. L'Héroïque a toujours plus de PV que le Normal, et le Mythique en aura plus que l'Héroïque. Ce sont les bonus qui doivent porter le joueur.

## Ce qui change

- En **Héroïque**, chaque mission garde au moins les **PV du Normal + 5 %**. Ce plancher a été choisi par le porteur parmi trois planchers mesurés (+5, +10 et +20 %).
- **149 réglages sur 400 sont relevés**, presque tous aux chapitres 11 à 20. Exemple : la mission 101 passe de 207 à 256 % pour l'Alliance (Normal : 244 %), et de 223 à 260 % pour la Horde (Normal : 248 %).
- Les chapitres 1 à 9 ne changent pas : leurs PV sont déjà bien au-dessus de ceux du Normal.
- Le Normal ne change pas.

**Effet mesuré** (joueur avisé, trois tirages neufs) :
- aux chapitres 11 à 20, la meilleure composition finit avec 35 % (Alliance) et 32 % (Horde) de ses PV de forteresse, au lieu de 51 et 54 % ;
- 8 missions sur 400 sont perdues par toutes les compositions.

Un renfort des bonus va être proposé au porteur pour revenir dans la cible de 40 à 70 %.

Fiche : `design/Plancher_Heroique_v0263.md`.

## Contrôles

- Régression complète : 155 suites sur 155, 266 306 contrôles Godot, 17 tests Python. `test_heroic_calibration.gd` (2 007 contrôles) vérifie maintenant que les PV héroïques dépassent ceux du Normal pour les 400 réglages et que 149 réglages sont relevés au plancher.
- Les rapports des versions 0.257 à 0.262 se rejouent sans changement ; le Normal est inchangé.
- Paquet Windows vérifié : 1 050 cas et 672 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures inspectées depuis le jeu exporté, onglet Héroïque : mission 101 à 256 % (Alliance) et 260 % (Horde), conformes au catalogue.
