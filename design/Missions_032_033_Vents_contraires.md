# Missions 32 et 33 — Crêtes et Éboulis sous le vent

## Périmètre du prototype v0.156

Ces deux missions poursuivent le chapitre 4. Elles reprennent deux tracés du chapitre 3 avec Vents contraires, selon le principe d'introduction d'une règle sur le second chapitre du biome.

| Mission | Carte | PV ennemis | Points accessibles avant la première tentative |
| --- | --- | --- | --- |
| 32 | Les Crêtes des Ardoises | 131 % de la référence | 15 |
| 33 | Les Éboulis des Ardoises | 132 % de la référence | 16 |

Les tracés, emplacements et vagues sont conservés. Chaque mission comporte deux entrées vers une forteresse, six emplacements et dix vagues. La mission précédente doit être réussie dans la faction concernée.

Le réglage d'essai validé de Vents contraires reste de −10 % de cadence pour tous les défenseurs, y compris les unités de boutique. Les malédictions déjà appliquées conservent leur rythme. Les règles précises figurent dans [le premier essai](Vents_contraires_v0155.md).

Chaque première victoire donne 60 PO et 100 XP, une seule fois par faction. Les PO ne servent pas à obtenir les points de talents. Les points gagnés par l'XP peuvent être réattribués gratuitement entre les missions. La première victoire de la mission 32 débloque ainsi le seizième point pour préparer la mission 33.

## Comparaisons et limites

Le relevé local `dist/slate-missions32-33.json` utilise trois graines, trois placements, quatre compositions de trois défenseurs, deux arbres de talents et la première branche de spécialisation. Tous les points gagnés avant chaque mission sont répartis. Le premier bonus proposé est choisi.

| Mission | Alliance | Horde |
| --- | --- | --- |
| 32 | 14 victoires sur 72 | 0 sur 72 |
| 33 | 25 victoires sur 72 | 1 sur 72 |

Un second relevé avec la seconde branche et trois arbres de talents trouve également peu de victoires Horde. Ces résultats signalent les limites des compositions à trois défenseurs essayées.

Une exploration supplémentaire de la mission 32 Horde tente une quatrième recrue sur les emplacements restants. Elle trouve 16 victoires parmi 648 politiques. Ce panel comprend des tentatives de recrutement refusées par le budget ou par la limite de deux exemplaires. Il ne représente donc pas 648 défenses effectivement constituées de quatre unités, ni une estimation de la réussite d'un joueur.

La composition retenue pour confirmer la faisabilité utilise deux sapeurs et deux lanceurs de haches avec les quinze points de Démolition accessibles. Elle réussit sur trois graines et deux placements, soit six confirmations, avec 3 à 16 PV restants. Aucun or, point de talent ou bonus supplémentaire n'est injecté. Aucune unité de boutique n'est nécessaire à cette composition.

Ces confirmations prouvent l'existence d'une stratégie accessible. Elles ne suffisent pas à valider l'équilibrage de la découverte ou la diversité des choix. Le dosage reste à évaluer en jeu, particulièrement côté Horde. Les statistiques des défenseurs, les récompenses et le réglage du vent restent identiques à la v0.155.

## Vérification

Les missions 31–33 sont lancées depuis le parcours réel dans les deux factions. Le contrôle remporte chaque combat avec le budget normal, rejoue son rapport et vérifie le crédit unique de récompenses ainsi que la courbe d'XP. Il revient ensuite au parcours par le bilan et relance la mission 21 pour vérifier la restauration de la cadence et la disparition de l'annonce du vent.

9 908 contrôles Godot ciblés réussissent. Treize essais Windows vérifient les aperçus et les lancements des missions 31–33 ainsi qu'un écran de spécialisation à trois entrées. Les profils utilisés sont isolés de ceux du joueur.

## Suite

Trente-trois missions sont disponibles. Les missions 34–40 restent à produire. Les autres affixes, leurs cumuls et les autres difficultés de campagne restent des travaux futurs.
