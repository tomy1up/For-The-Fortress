# Prototype v0.254 — Bonus faibles et trop forts rééquilibrés

Décision du porteur du 24 novembre 2026 (« Tout valider »). Valeurs et recalage : réglages de prototype à confirmer en partie réelle.

## Bonus trop forts, baissés

- **Lames runiques** : +12 % de dégâts et +6 % de cadence (au lieu de +20 % et +10 %).
- **Exercice de tir** : +8 % de cadence (au lieu de +12 %).
- **Cadence effrénée** : +15 % de cadence, toujours −0,5 de portée (au lieu de +25 %).
- **Pari risqué** : +20 % de dégâts, toujours −4 PV (au lieu de +30 %).

## Bonus faibles, relevés

- **Chausse-trappes** : chaque ennemi est ralenti 3 s au premier tir direct qu'il reçoit, au lieu de 2 s à son apparition, quand il est encore loin des tours.
- **Temps suspendu** : ralenti 8 s au premier tir direct reçu (au lieu de 4 s à l'apparition), et les ralentissements durent toujours 50 % de plus.
- **Malédiction tenace** : trois échéances et +100 % aux dégâts sur la durée.
- **Marché noir** : les améliorations ne coûtent plus que 5 % de plus (au lieu de 15 %).
- **Forteresse blindée** : −5 % de dégâts (au lieu de −10 %).
- **Élite sacrifiée** : −5 % aux niveaux 1 et 2 (au lieu de −10 %).

## Difficulté

- 62 missions ont un nouveau coefficient de PV ennemis (12 hausses, 50 baisses, surtout côté Horde), pour revenir dans la cible et pour que l'armée de référence gagne toujours.
- Sur toute la campagne, **379 réglages sur 398** sont dans la cible. Restent au-dessus : Alliance 2, 3, 13, 33, 40, 132 ; Horde 2, 3, 25, 28, 33, 34, 39, 43, 46, 81, 88. Juste en dessous : Alliance 67 et Horde 40.
- L'écart de valeur entre les bonus se resserre nettement, mais le poids du tirage pour une armée fixe baisse peu, car les épiques et les rares les plus forts font encore la différence.

Fiche : `design/Bonus_reequilibres_v0254.md`.

## Contrôles

- Régression complète : 149 suites sur 149, 249 818 contrôles Godot, 17 tests Python (nouvelle suite `test_bonus_values_v254.gd`, tests de bonus mis aux nouvelles valeurs).
- Campagne remesurée sur les 398 réglages, recalée, puis garde des 28 suites de campagne : l'armée de référence gagne partout.
- Paquet Windows vérifié : 1 050 cas et 670 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Cartes des dix bonus modifiés capturées dans le jeu exporté, dans les deux factions. La note de Pari risqué ne répète plus la ligne « Effet immédiat sur la forteresse ».
