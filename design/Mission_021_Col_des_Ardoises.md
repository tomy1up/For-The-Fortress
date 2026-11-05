# Mission 21 — Le Col des Ardoises

Le prototype ouvre la première mission du chapitre 3 après la réussite de la mission 20 dans la même faction. Le biome montagneux commence ici. Les missions 22 à 40 restent à produire.

## Décisions appliquées

La progression suit un parcours indépendant par faction. Chaque mission remet le combat à neuf et applique les talents persistants au départ. La première victoire accorde des PO et de l’XP une seule fois. Les talents restent fixés pendant la mission.

Un biome couvre deux chapitres. Les nouvelles familles d’attaquants ou affixes propres à ce biome seront introduits au second chapitre, aux missions 31 à 40. La mission 21 expérimente une géométrie à deux entrées convergentes.

## Réglages proposés pour cet essai

| Paramètre | Valeur |
| --- | --- |
| Carte | Le Col des Ardoises |
| Entrées | Deux, vers une forteresse |
| Longueurs des routes | 28 et 33 unités logiques |
| Portion commune | 17 unités logiques |
| Emplacements | Six |
| Vagues | Dix, calendrier de référence du Gué |
| PV ennemis | 120 % de la référence |
| Première victoire | 60 PO et 100 XP |
| Répartition | Vague 1 égale, puis environ deux tiers par l’entrée principale, alternée chaque vague |

Le nom, le terrain, les positions, les rencontres et les valeurs sont des propositions de prototype. Le passage à cette nouvelle géométrie peut provoquer un saut de difficulté supérieur au seul point de pourcentage de PV.

## Contrôles effectués

Le relevé local `dist/slate-pass-talents.json` comprend 1 728 simulations avec trois graines, six dispositions, quatre compositions, trois moments de tentative d’amélioration et quatre configurations de talents. La politique utilise les achats et améliorations normaux et choisit le premier bonus proposé. Elle ne charge aucun profil joueur.

| Faction | Sans talent | Six points dans un arbre |
| --- | --- | --- |
| Alliance | 22 victoires sur 216 | 158 sur 648 |
| Horde | 0 victoire sur 216 | 10 sur 648 |

Ces résultats montrent une différence de difficulté entre les factions sous les politiques testées. Ils ne mesurent pas la probabilité de victoire d’un joueur et ne suffisent pas à déclarer la carte équilibrée. Le profil ayant réussi les vingt premières missions dispose de dix points, alors que ces essais en investissent six.

Le test d’intégration démarre la mission depuis le parcours, remporte un combat dans chaque faction, vérifie le crédit unique de 60 PO et 100 XP, puis relit les gains et la réussite depuis un profil temporaire sauvegardé. Le paquet Windows contrôle l’aperçu des deux routes et le lancement de la mission dans les deux factions.

## Comparaison avec dix points disponibles

Le relevé local `dist/slate-pass-ten-points-final.json` reprend les 1 728 cas en investissant dix points dans chaque configuration avec talents. Après les cinq premiers rangs et un rang du talent suivant, la politique remplit les premiers talents accessibles dans le même arbre selon leur ordre de catalogue. Elle respecte les prérequis et le plafond gagné avant la mission.

| Faction | Sans talent | Dix points dans un arbre |
| --- | --- | --- |
| Alliance | 22 victoires sur 216 | 288 sur 648 |
| Horde | 0 victoire sur 216 | 27 sur 648 |

Ce résultat confirme l’écart sous les politiques observées. Trois répartitions concentrées dans un arbre ne couvrent pas l’ensemble des configurations hybrides possibles.

Un second relevé, `dist/slate-e2-candidates.json`, compare trois positions de l’emplacement E2. Il utilise trois graines, deux dispositions, deux compositions et deux configurations à dix points, soit 24 cas par faction et par position.

| Position E2 | Alliance | Horde |
| --- | --- | --- |
| (1,2 ; 5), référence | 17 victoires sur 24 | 2 sur 24 |
| (3 ; 4,5) | 22 sur 24 | 2 sur 24 |
| (3 ; 5,5) | 16 sur 24 | 2 sur 24 |

Le déplacement seul d’E2 ne réduit pas l’écart dans cet échantillon. Le placement publié est conservé en attendant d’autres comparaisons.

Le relevé `dist/slate-e3-candidates.json` déplace ensuite E3 vers la partie commune, avec les mêmes 24 cas par faction et par position.

| Position E3 | Alliance | Horde |
| --- | --- | --- |
| (5,5 ; 6,8), référence | 17 victoires sur 24 | 2 sur 24 |
| (8 ; 6,8) | 13 sur 24 | 0 sur 24 |
| (9 ; 6,8) | 14 sur 24 | 0 sur 24 |

Ces candidats sont écartés. La comparaison des placements conserve la branche A des spécialisations pour chaque unité. Le relevé ne permet donc pas de conclure sur les compositions choisissant d’autres branches.

La commande de comparaison accepte `--all-earned-points` pour répartir les points obtenus avant la mission et `--branch=1` pour comparer la branche B à la branche A utilisée par défaut. Les valeurs choisies sont inscrites dans le rapport. L’option `--smoke` limite le relevé à huit cas et vérifie leur relecture.

Le relevé `dist/slate-branches.json` compare les branches A et B sur les 24 cas de référence par faction, avec les positions publiées.

| Spécialisations choisies pour toutes les unités | Alliance | Horde |
| --- | --- | --- |
| Branche A | 17 victoires sur 24 | 2 sur 24 |
| Branche B | 10 sur 24 | 2 sur 24 |

Le changement systématique de branche ne résout pas l’écart observé. L’étape suivante consiste à examiner les compositions et les pertes avant les spécialisations, puis à comparer des choix de branches adaptés à chaque unité. Les huit cas du contrôle court en branche B sont rejoués sans divergence.

## Dispositions autour du chemin commun

Le relevé `dist/slate-core-placement.json` explore cinq dispositions, trois graines, quatre compositions et deux configurations à dix points. Il comprend 240 cas. Les premières dispositions du relevé initial ne couvraient pas systématiquement les emplacements proches de la portion commune dès le départ.

Dans le tableau, les deux premiers emplacements sont occupés au départ. Le troisième est recruté dès que le budget le permet, à partir de la vague 2. Les améliorations suivent la politique de référence.

| Ordre de recrutement | Alliance | Horde | PV perdus par la Horde, moyenne sur les vagues 1 à 3 |
| --- | --- | --- | --- |
| E2, E4, E5 | 24 victoires sur 24 | 0 sur 24 | 6,125 |
| E4, E3, E5 | 24 sur 24 | 23 sur 24 | 1,625 |
| E4, E5, E3 | 24 sur 24 | 24 sur 24 | 1,75 |
| E5, E3, E4 | 24 sur 24 | 24 sur 24 | 1,875 |
| E5, E4, E3 | 24 sur 24 | 24 sur 24 | 1,75 |

Le placement initial change fortement le résultat de la Horde dans ces essais. Les écarts précédents ne suffisent donc pas à établir une faiblesse générale de la faction sur cette carte. Le terrain et les statistiques publiés restent ceux de la v0.147. Le naturel des choix en première découverte, la difficulté humaine et les autres configurations de talents restent à évaluer.

Douze victoires de la disposition E4, E5, E3 sont également rejouées à partir du rapport de combat, dans les deux factions, sur trois graines et deux compositions. Le relevé est enregistré dans `dist/slate-core-replayed.json`.

## Suite du travail

Comparer des configurations utilisant les dix points disponibles et des unités de boutique, examiner les pertes par entrée, puis faire tester la mission par le porteur. Adapter les placements ou le calendrier si la difficulté Horde reste excessivement restrictive. Étendre ensuite les situations du chapitre sans annoncer les missions suivantes comme terminées.
