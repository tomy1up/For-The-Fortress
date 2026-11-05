# Missions 23 à 25 — Variations du biome des Ardoises

Ces trois missions poursuivent le chapitre 3 après les Crêtes. Le biome couvre les chapitres 3 et 4. Les nouveaux attaquants ou affixes propres au biome restent à concevoir pour le chapitre 4.

Les noms, tracés, emplacements et réglages suivants sont des propositions de prototype.

| Mission | Carte | Routes | Situation proposée | PV ennemis |
| --- | --- | --- | --- | --- |
| 23 | Les Éboulis des Ardoises | Deux routes de 30 unités, dont 21 communes | Défendre une jonction précoce et plusieurs coudes communs | 122 % |
| 24 | Le Ravin des Ardoises | Un chemin de 37 unités | Répartir la défense le long de plusieurs passages proches | 123 % |
| 25 | Les Portes des Ardoises | Deux routes de 34 et 32 unités, dont 12 communes | Couvrir les branches avant une jonction tardive | 124 % |

Chaque carte propose six emplacements, dix vagues de référence et une forteresse. Sur les deux cartes multitrajets, la première vague est répartie à égalité puis l’entrée principale alterne à chaque vague.

La première victoire dans la faction rapporte 60 PO et 100 XP, avec un crédit unique. Chaque mission repart avec la forteresse à son maximum, 150 or de combat, un plateau vide et aucun bonus de mission. Les talents et acquisitions persistants sont appliqués selon les règles existantes.

## Simulations et limites

Le relevé local `dist/slate-missions23-25.json` comprend 432 politiques fixes. Pour chaque mission et faction, il compare trois graines, trois dispositions, quatre compositions et deux configurations de talents. Les configurations investissent les points obtenus par les premières victoires précédentes, soit 11 avant les missions 23 et 24 et 12 avant la mission 25.

| Mission | Alliance | Horde |
| --- | --- | --- |
| 23 | 60 victoires sur 72 | 26 sur 72 |
| 24 | 72 sur 72 | 51 sur 72 |
| 25 | 68 sur 72 | 22 sur 72 |

Ces résultats décrivent les politiques testées. Ils ne mesurent pas la probabilité de victoire d’un joueur. La carte 24 permet davantage de victoires malgré le point de pourcentage supplémentaire de PV. La géométrie participe à la difficulté et la progression humaine reste à évaluer.

Le contrôle d’intégration lance les missions par le parcours, remporte un combat dans chaque faction avec les achats normaux, rejoue les rapports, vérifie les gains uniques puis leur conservation après réouverture du profil temporaire. Les captures Windows contrôlent les aperçus et les lancements de chaque carte.

Les missions 26 à 200 restent à développer.
