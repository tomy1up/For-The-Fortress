# Remesure des missions 1 à 30 — v0.177

Demande du porteur (11 novembre 2026) : traiter les marges minces relevées en v0.175 sur les trois premiers chapitres, avec les talents réels (Alliance abaissée au niveau de la Horde). Mesure : armée de référence de chaque faction (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches et un chaman), emplacements par défaut de la carte, ordre d'achat des tests (emplacements 3, 4 puis 2), talents accumulés à chaque mission, PV ennemis de la mission.

**Résultat : aucune modification du jeu.** Deux des trois cas sont des artefacts de l'ordre d'achat des tests ; le troisième est réel mais partagé avec la finale du chapitre 4, et aucun réglage d'emplacements ne l'améliore sans dégrader l'autre.

## Les trois cas

| Mission | Faction | PV restants avec la référence | Meilleur résultat trouvé | Diagnostic |
| --- | --- | --- | --- | --- |
| 11 (Gué, tortue gardienne) | Alliance | 4 | 20 avec le même trio dans l'ordre d'achat 2, 3, 4 | Artefact de l'ordre d'achat des tests : la carte et la difficulté sont saines. |
| 29 (Hauts passages) | Alliance | 9 | 16 avec un autre trio | Même diagnostic : un joueur qui place autrement gagne largement. |
| 30 (Bastion des Ardoises, finale du chapitre 3) | Horde | 7 | 7 avec toutes les compositions et tous les ordres essayés (7 compositions Alliance, 6 Horde, 6 ordres) | Carte réellement serrée pour la Horde : aucun choix de composition ni d'ordre ne l'améliore. |

## Le Bastion est partagé avec la finale du chapitre 4

Une première version (v0.177 en préparation) avait changé trois emplacements du Bastion. Sur la mission 30, la Horde passait de 7 à 15 PV restants et l'Alliance de 14 à 12. **La régression a échoué** : la carte `slate_bastion` sert aussi à la **mission 40** (finale du chapitre 4, avec Vents contraires), dont les armées de référence sont réglées sur les emplacements d'origine. Avec les nouveaux emplacements, l'Alliance y perdait la mission 40.

Recherche conjointe sur les deux missions : 16 trios d'emplacements candidats (145 emplacements possibles autour des deux trajets), plus trois permutations de chaque trio, parties complètes avec les talents réels, armées de référence propres à chaque mission (celles de `test_headwinds.gd`). Sur 65 jeux évalués, trois seulement permettent aux deux factions de gagner les deux missions. Marge minimale sur les quatre parties (mission 30 Alliance / Horde, mission 40 Alliance / Horde) :

| Jeu d'emplacements | PV restants | Marge minimale |
| --- | --- | --- |
| **Emplacements d'origine** | 14 / 7 / 14 / 5 | **5** |
| Meilleur candidat | 12 / 15 / 3 / 5 | 3 |
| Second candidat | 13 / 15 / 10 / 1 | 1 |

Les emplacements d'origine sont donc les meilleurs de la recherche : le changement a été **annulé**.

## Ce que cela signifie

- **Missions 11 et 29** : leur faible marge vient de l'ordre d'achat fixe des tests, pas de la carte. Rien à corriger.
- **Missions 30 et 40, côté Horde** : 7 et 5 PV restants avec la référence. Ce sont les plus petites marges des chapitres 1 à 4. Elles ne se corrigent pas par les emplacements seuls.
- Pistes pour la suite, qui sont des décisions de direction : (1) donner à la finale du chapitre 4 sa propre carte (nouvel identifiant), ce qui permet de régler chacune ; (2) allonger légèrement le trajet commun du Bastion, ce qui facilite les deux missions pour les deux factions (à mesurer) ; (3) laisser telles quelles ces deux finales serrées pour la Horde, qui gagne.
- Les trente premières missions restent gagnables par les deux factions avec leur armée de référence (marges de 4 à 20 PV).

## Limites

- La mesure utilise les armées de référence et les emplacements par défaut ; elle ne remplace pas l'essai en jeu.
- Les chapitres 1 à 3 gardent des missions faciles par conception d'ouverture : une marge de 20 PV (aucune perte) y est attendue.
