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

## Suite du travail

Comparer des configurations utilisant les dix points disponibles et des unités de boutique, examiner les pertes par entrée, puis faire tester la mission par le porteur. Adapter les placements ou le calendrier si la difficulté Horde reste excessivement restrictive. Étendre ensuite les situations du chapitre sans annoncer les missions suivantes comme terminées.
