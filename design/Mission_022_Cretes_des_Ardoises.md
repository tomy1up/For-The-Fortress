# Mission 22 — Les Crêtes des Ardoises

La seconde mission montagneuse est accessible après la mission 21 dans la même faction. Son nom, ses emplacements et son tracé sont des propositions de prototype.

Les deux routes mesurent chacune 28 unités logiques et convergent après 13 unités. Les 15 dernières unités sont communes. La mission 21 proposait une partie commune de 17 unités et des longueurs d’approche différentes.

La route haute traverse deux coudes avant la jonction. La route basse longe le bord inférieur du plateau. Six emplacements proposent une couverture de la branche haute, de la branche basse ou de la partie commune. L’aperçu du parcours dessine les deux routes et les deux entrées.

| Paramètre d’essai | Valeur |
| --- | --- |
| PV ennemis | 121 % de la référence |
| Vagues | Dix, calendrier de référence |
| Répartition | Égalité en vague 1, puis entrée principale alternée |
| Première victoire | 60 PO et 100 XP |
| Remise à neuf | Forteresse à son maximum, 150 or de combat, plateau vide et aucun bonus de mission |
| Progression conservée | Talents, XP, PO et acquisitions de boutique de la faction |

Le contenu du biome reste en préparation. L’introduction d’un nouvel attaquant ou d’un affixe propre à ce biome est prévue au chapitre 4, conformément au rythme par couples de chapitres.

## Contrôles

La mission passe par le lancement normal du parcours. Le test d’intégration vérifie le verrou précédent, le combat avec les ressources normales, le rejeu du rapport, le crédit unique des gains, la sauvegarde puis la relecture du profil temporaire, dans les deux factions.

Le relevé local `dist/slate-ridges-candidate.json` compare 240 politiques fixes à dix points de talents, sur trois graines, cinq dispositions et quatre compositions. Ces simulations servent à repérer des situations gagnantes ou bloquantes. Elles ne constituent pas une validation humaine de l’équilibrage.

L’Alliance remporte 78 cas sur 120, la Horde 23 sur 120. Les ordres de recrutement E4, E5, E3 et E5, E4, E3 ne sont pas équivalents sur ce tracé. Le test d’intégration utilise une politique gagnante observée dans chaque faction, avec les mêmes budgets et règles d’amélioration que le jeu.

Les missions 23 à 200 restent à développer.
