# Prototype v0.234 — Recalibrage avec les 60 bonus, trois gestes de boutique animés

Valeurs de prototype à confirmer en partie réelle.

## Difficulté

- **PV d'ennemis recalibrés mission par mission et faction par faction** avec les 60 bonus, la rareté et la relance de la v0.233. Cible du porteur inchangée : la meilleure composition finit avec 40 à 70 % de ses PV de forteresse.
- Méthode affinée : moyenne sur trois tirages de bonus, mesures tous les 5 % de PV, garde-fou de la composition de référence des tests, puis ajustement jusqu'à ce que chaque suite de campagne passe. La mission 1 reste à ses PV de référence.
- Coefficient moyen : 112 % pour l'Alliance (109 % en v0.233), 122 % pour la Horde (116 %).
- Mesure sur 36 000 parties (200 missions, deux factions, 30 compositions, trois tirages) :
  - meilleure marge moyenne de l'Alliance : **56,3 %** (68,5 % en v0.233), 174 missions sur 200 dans la cible ;
  - meilleure marge moyenne de la Horde : **69,4 %** (85,5 % en v0.233), 108 missions dans la cible, 5 encore gagnées à 100 % (19 en v0.233) ;
  - victoires toutes compositions confondues : 16,6 % (Alliance) et 16,5 % (Horde).
- La Horde reste au-dessus de la cible sur 90 missions, surtout aux chapitres 7 et 13 : sa composition de référence (deux haches et un chaman) doit gagner chaque mission et ne le ferait plus avec davantage de PV. Question posée au porteur (O-028).
- Fiche : `design/Rebalancage_v0234.md`. Les rapports des versions antérieures se rejouent avec leurs PV enregistrés.

## Animations

- **Lanceur de masse orc (type 28)** : attaque en poses entières de Codex, validée par le porteur (lot `5238ec8`). Cinq inclinaisons (−12°, 0°, +12°, +24°, +36°) de 26 poses sur 1,04 s, choisies selon le trajet vers la cible.
- La masse quitte la main à 0,56 s, sur la première pose à main ouverte, depuis le repère de l'inclinaison jouée, puis tourne pendant un vol rectiligne jusqu'à l'impact. À bout portant, seul l'impact est joué.
- Les dégâts, la cadence et les multiplicateurs contre les lourds et les petits ne changent pas.
- **Mage de givre (type 30)** : formation puis projection d'un cristal, de Codex (lot `43b95a7`). Trois vues (−32°, −16°, +22°) de 18 poses sur 0,72 s, choisies selon le trajet vers la cible.
- Le cristal part à 0,36 s, sur la première pose à paume vide, depuis le repère de la vue jouée, et file en ligne droite jusqu'à la cible. La pose, le repère et le cristal se retournent ensemble selon le côté du tir.
- Les dégâts et le ralentissement de 40 % pendant 3 s ne changent pas.
- **Sarbacane gobeline (type 29)** : inspiration puis souffle, de Codex (lot `112ffcd`). Trois vues (tube à environ −22°, −2° et +16°) de 14 poses sur 0,56 s ; la vue retenue est celle dont le tube est le plus proche de l'axe vers la cible.
- Le dard part à 0,24 s, au premier souffle, depuis l'ouverture du tube de la vue jouée, et file en ligne droite (sans la petite cloche des projectiles lancés). La pose et le repère se retournent ensemble.
- Les multiplicateurs contre les rapides et les lourds ne changent pas.

## Contrôles

- Régression complète : 144 suites sur 144, 197 278 contrôles Godot et 17 tests Python.
- Nouveaux contrôles des types 28, 29 et 30 dans `test_marksman_aim.gd` : instant de départ, repère de chaque inclinaison, vol rectiligne, orientation du cristal, planches chargées.
- Validateur des animations : 47 dossiers, aucun problème.
