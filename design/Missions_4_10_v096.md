# Premier chapitre jouable — v0.96

30 octobre 2026. **For the Fortress!** reste un nom de travail ; disponibilité juridique à confirmer.

## Portée et statuts

**Décision validée CAMP-016 :** étendre l’essai aux missions 4–10 avant de préparer une boutique. Le premier chapitre propose désormais dix missions par faction. Les nouveaux titres, tracés, récompenses et PV sont des **hypothèses de prototype**, à réviser après les essais humains.

Les règles validées restent appliquées : parcours indépendant pour chaque faction, récompenses versées dès la première victoire, aucun nouveau gain en rejeu ou en défaite, sauvegarde persistante, talents accessibles entre les missions et reset gratuit. Les PO servent à la future boutique ; l’XP débloque les points de talents. Une mission recommence avec une forteresse intacte, 150 or de combat, aucun défenseur et aucun bonus temporaire.

L’extension réutilise les dix vagues existantes et leurs ennemis, les six défenseurs actuels et leurs spécialisations. Aucune nouvelle mécanique n’est introduite dans ce chapitre : les premiers blocs d’introduction restent prévus aux missions 11–20.

## Contenu et économie d’essai

Chaque terrain comporte six emplacements fixes. La longueur désigne la distance logique parcourue sur le chemin, et non une durée de partie.

| Mission | Terrain | Longueur du chemin | PV ennemis | PO cumulées après première victoire | XP cumulée | Points débloqués |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | La Vallée du Gué | 28 | 100 % | 60 | 100 | 0 |
| 2 | Le Bois du Gué | 29 | 101 % | 120 | 200 | 1 |
| 3 | Les Hauts du Gué | 29 | 102 % | 180 | 300 | 1 |
| 4 | Les Détours du Gué | 31 | 103 % | 240 | 400 | 2 |
| 5 | La Clairière du Gué | 33 | 104 % | 300 | 500 | 2 |
| 6 | Le Défilé du Gué | 34 | 105 % | 360 | 600 | 3 |
| 7 | Les Lacets du Gué | 32 | 106 % | 420 | 700 | 3 |
| 8 | Le Sentier du Gué | 33 | 107 % | 480 | 800 | 4 |
| 9 | Les Abords du Gué | 33 | 108 % | 540 | 900 | 4 |
| 10 | Les Remparts du Gué | 34 | 109 % | 600 | 1 000 | 5 |

Les gains sont de 60 PO et 100 XP par première victoire de mission et de faction. La courbe d’essai reste `min(51, floor(51 × XP / 10 000))`. Le cinquième point n’arrive **qu’après** la mission 10 : il ne facilite pas sa première réussite. Le calcul sur 100 missions reste une référence économique ; les missions 11–200 ne sont pas encore jouables.

Seuls les PV ennemis sont multipliés : un ennemi à 40 PV possède 41,2 PV à la mission 4, et le boss à 600 PV possède 654 PV à la mission 10. Vitesse, dégâts à la forteresse et or gagné au combat ne changent pas. La référence de PV augmente linéairement, mais les tracés et les placements peuvent faciliter ou compliquer le combat : ces pourcentages ne prouvent pas une difficulté humaine strictement croissante.

## Intention des sept terrains proposés

| Terrain | Situation à comparer |
| --- | --- |
| Les Détours du Gué | Couvrir plusieurs passages autour d’un retour en profondeur. |
| La Clairière du Gué | Répartir la défense entre le centre du terrain et la fin du parcours. |
| Le Défilé du Gué | Exploiter les longs segments et les positions proches de plusieurs virages. |
| Les Lacets du Gué | Choisir entre une couverture centrale et des positions plus éloignées. |
| Le Sentier du Gué | Comparer plusieurs passages successifs près d’une même défense. |
| Les Abords du Gué | Répartir les dépenses entre les premières rencontres et le retour final. |
| Les Remparts du Gué | Consolider une composition sur un chemin plus long et le dernier réglage de PV du chapitre. |

Ces intentions ne sont pas des objectifs supplémentaires imposés au joueur. La condition de victoire reste la survie de la forteresse aux dix vagues.

## Compatibilité et vérification

Les anciens identifiants de cartes et missions sont conservés. Les trois premiers terrains, leurs emplacements et leurs PV sont inchangés. Un profil ayant remporté les trois missions retrouve ses gains et peut accéder à la mission 4, sans migration ni nouveau schéma de sauvegarde. Le schéma 6 et la protection Windows du profil restent utilisés.

Les vérifications couvrent les dix géométries, les emplacements hors du chemin et de la forteresse, les aperçus, le verrou séquentiel, le parcours complet des deux camps, la conservation des gains après réouverture et l’absence de farming. Les témoins de combat des sept nouvelles missions sont comparés à petits et grands pas puis rejoués à partir de leurs rapports. Les essais graphiques utilisent des profils de contrôle isolés, sur l’écran de droite.

## Questions ouvertes et prochaines mesures

- Mesurer en jeu la durée réelle, le confort des emplacements et la variété perçue des dix missions.
- Comparer la difficulté des factions avec plusieurs placements, compositions, bonus et talents accessibles avant chaque mission.
- Ajuster les tracés ou les PV si certaines missions créent une rupture de difficulté ; conserver les revenus sous contrôle.
- Définir ensuite le premier bloc de nouveauté des missions 11–20, sans le présenter comme déjà conçu.
- Définir la boutique d’unités alternatives : forces, faiblesses, prix et calendrier de déblocage restent ouverts.

Le GDD v0.15 reste le document de référence consolidé jusqu’à v0.92 ; cette fiche complète son état de réalisation pour v0.96.

## Résultats de validation

75 suites, **26 706 contrôles Godot** et 16 tests Python réussis. Les 811 contrôles du premier chapitre couvrent les cartes, PV, témoins de combat, parcours, reprises de profil et gains uniques. Douze scénarios conservent exactement les anciens terrains, rapports, états aléatoires, événements et dégâts de v0.95.

Le paquet Windows passe **233 lancements et 232 captures**, avec 45 sources comparées. Les sept nouvelles cartes ont été inspectées en préparation et dans les aperçus des deux factions, puis les bilans et retours après la mission 10. Les 18 rapports natifs des missions 2–10 se rejouent intégralement.

Une comparaison distincte porte sur **1 008 simulations sans talent** : sept cartes, deux factions, trois graines, six placements et quatre compositions, au budget normal. Quatorze témoins supplémentaires se rejouent ; cinq refus de destination de l’outil sont vérifiés. Les résultats ne sont pas des taux de victoire humains.

| Mission | Alliance : témoins gagnants / 72 | Horde : témoins gagnants / 72 | Alliance : politiques gagnant les 3 graines / 24 | Horde : politiques gagnant les 3 graines / 24 |
| --- | --- | --- | --- | --- |
| 4 | 46 | 16 | 12 | 4 |
| 5 | 50 | 34 | 12 | 7 |
| 6 | 70 | 41 | 22 | 13 |
| 7 | 62 | 46 | 18 | 11 |
| 8 | 69 | 46 | 21 | 10 |
| 9 | 58 | 34 | 16 | 7 |
| 10 | 62 | 38 | 16 | 11 |

La Horde reste plus sensible aux placements et compositions dans ces politiques fixes. Les tracés plus longs peuvent rendre certaines missions plus accessibles malgré la hausse des PV. Cela justifie un essai humain du chapitre avant de durcir les statistiques. Aucun ajustement supplémentaire n’est présenté comme approuvé.

[Régression](essais/v096_regression.json), [comparaison des anciennes missions](essais/v096_comparaison_anciennes_missions.json), [comparaison du chapitre](essais/v096_comparaison_chapitre_resume.json), [données brutes](essais/v096_comparaison_chapitre.json), [rejeux natifs](essais/v096_rejeux_natifs.json), [distribution](Distribution_Windows_v096.json). Pour reproduire la comparaison : lancer Godot sur le projet avec `--headless --script res://tools/survey_chapter_one.gd -- --output=<nouveau chemin absolu hors des données du joueur>`. Ajouter `--smoke` produit les quatorze témoins rejoués.
