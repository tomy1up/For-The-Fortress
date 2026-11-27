# Prototype v0.259 — Héroïque : le cumul des nouveautés

Lot 3 du cadrage des difficultés. Règles et valeurs validées par le porteur le 26 novembre 2026 ; réglages de prototype à confirmer en jeu.

## Ce qui change

- En **Héroïque**, à partir du chapitre 3, chaque mission **rappelle une nouveauté d'un biome déjà traversé** : un ancien attaquant (missions impaires) ou un ancien affixe (missions paires). À partir du chapitre 11, chaque mission en rappelle **deux** : un attaquant et un affixe.
- **Attaquant rappelé** : un groupe s'ajoute aux vagues 4, 7 et 10 (Tortues, Bouquetins, Golems, Capitaine de garnison aux vagues 7 et 10, Taupes, Aigles ou Crabes).
- **Affixe rappelé** : il garde les valeurs de son biome, mais il est avancé de 6 s pour tomber entre deux déclenchements de l'affixe du biome.
- Le rappel est fixe pour chaque mission et annoncé avant le lancement : dans l'écran de campagne, le bloc « Rappels de l'Héroïque » remplace celui du mode infini, et « Voir les ennemis » montre les attaquants rappelés.
- En partie, la ligne d'affixe affiche les deux affixes, et le bandeau signale l'affixe rappelé par « Rappel ».
- Le Normal ne change pas.

**Attention :** l'Héroïque n'est toujours pas calibré. Le cumul le rend encore plus dur que la v0.258 ; le calibrage mission par mission reste à faire (lot 5).

Fiche : `design/Cumul_nouveautes_v0259.md`.

## Contrôles

- Régression complète : 153 suites sur 153, 252 514 contrôles Godot, 17 tests Python (nouvelle suite `test_heroic_recalls.gd`, 2 394 contrôles : les 180 missions héroïques des chapitres 3 à 20 jouées puis rejouées).
- Sans rappel, le combat reste identique au bit près : les suites des affixes, des champions et du rejeu des anciens rapports passent sans changement.
- Paquet Windows vérifié : 1 050 cas et 672 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures inspectées, depuis les sources et le jeu exporté : écran de campagne (rappels de la mission 101), éruption rappelée dans le désert (mission 101), crue rappelée dans le marais (mission 44), tortues rappelées (mission 23).
- Mesure de l'Héroïque avec le cumul : voir la fiche.
