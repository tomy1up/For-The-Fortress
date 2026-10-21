# Dix vagues jouables sur La Vallée du Gué

**Prototype v0.18 — 21 octobre 2026.** Référence de conception : GDD v0.14. For the Fortress! reste un nom de travail.

Cette version réalise L5 : une campagne complète de dix vagues pour les deux factions, trois choix roguelite et les synergies approuvées. Les six défenseurs, leurs quatre niveaux et douze spécialisations sont conservés. Les règles sont celles du GDD v0.14 ; les réglages numériques restent H et aucune nouvelle mécanique de conception n’est ajoutée.

## Jouer localement


Sur ce PC, double-cliquer sur **Lancer_le_prototype.cmd** dans ce dossier. Le moteur officiel portable a été préparé dans C:/Projet/.tools/Godot-4.7.2, en dehors du dépôt Git.

Autre possibilité : ouvrir project.godot dans Godot 4.7.2 standard, puis lancer la scène principale avec F6 ou le projet avec F5. Aucun module externe n’est nécessaire. Sur un autre PC, récupérer [Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/) et ouvrir ce projet. Le lanceur PowerShell accepte aussi -EnginePath avec le chemin du moteur.

## Prise en main

1. Choisir Alliance des Royaumes ou Horde des Cendres. La faction reste fixe pendant cet essai.
2. Cliquer sur E1 à E6, puis acheter un défenseur de sa faction : 50, 75 ou 100 or. Deux exemplaires maximum par type.
3. Cliquer sur une unité pour lire ses statistiques, afficher sa portée, améliorer son niveau ou consulter son remboursement avant une vente.
4. Lancer la vague 1 : dix Pillards de 40 PV, apparitions à t = 0 puis toutes les 2,5 s. Les tirs sont automatiques.
5. Observer les éliminations, l’or et les arrivées ; changer la vitesse entre ×1 et ×2 si souhaité.
6. Entre les vagues, acheter, améliorer ou vendre, puis lancer la suivante. Survoler le bouton de lancement pour voir sa composition et ses intervalles.
7. Après les vagues 3, 6 et 9, choisir un bonus parmi trois offres distinctes. Le choix est gratuit et obligatoire avant la préparation suivante.
8. Consulter « Bonus acquis » et les synergies de l’unité sélectionnée ; survoler leurs codes pour lire les effets.
9. Survivre jusqu’à la résolution complète de la vague 10. « Nouvel essai » repart avec 150 or et 20 PV, sans bonus ni défense.

Les achats, améliorations, ventes et la relance d’un essai sont bloqués pendant le combat. Le bouton de lancement passe à la vague suivante ; il ne répète pas la précédente. La victoire et la défaite bloquent toute nouvelle dépense. Consulter les bonus acquis pendant un combat ne met pas le jeu en pause.

## Règles implémentées

| Défenseur N1 | Achat | Dégâts principaux | Intervalle | Portée | Effet secondaire |
| --- | --- | --- | --- | --- | --- |
| Archer elfe | 50 | 8 | 1 s | 4 | Aucun |
| Arbalétrier nain | 75 | 24 | 2,5 s | 5 | Aucun |
| Mage humain | 100 | 27 | 2,5 s | 3,5 | 10,8 dégâts à deux autres ennemis au maximum, à moins de 1 unité de l’impact |
| Lanceur de haches troll | 50 | 16 | 2 s | 3,5 | Un rebond de 8 dégâts sur une autre victime à moins de 1 unité |
| Sapeur gobelin | 75 | 24 | 2,5 s | 3 | 9,6 dégâts à trois autres ennemis au maximum, à moins de 1 unité de l’impact |
| Chaman orc | 100 | 12 | 2 s | 4,5 | Malédiction de 4,8 dégâts à +1 s puis +2 s |

La cible principale est l’ennemi à portée le plus avancé ; à égalité, priorité à l’apparition la plus ancienne. Le mage, le troll et le sapeur choisissent leurs victimes secondaires par distance à l’impact, puis progression et ordre d’apparition. Les impacts sont instantanés ; les traits dessinés ne retardent pas les dégâts.

Les tirs simultanés prennent leurs décisions sur le même état et leurs dégâts sont additionnés. Un mort ne rapporte qu’une seule récompense. Chaque Pillard éliminé donne immédiatement 3 or ; une arrivée retire 1 PV et ne donne aucun or. Il n’y a pas de prime de fin de vague.

La vente rend la partie entière inférieure de 70 % du montant payé pour cet exemplaire : 35, 52 ou 70 or au N1 sans réduction. Elle libère l’emplacement et une place dans le quota. Un nouvel achat crée un nouvel exemplaire N1. Les prix et statistiques conservent leur statut H.

Les malédictions continuent hors portée, restent indépendantes entre chamans et se renouvellent sans se cumuler pour un même couple source–cible. Les anciens ticks sont résolus avant les nouveaux tirs, puis viennent les dégâts d’arrivée. Mort et arrivée annulent les ticks futurs.

Les synergies et bonus sont actifs dans le jeu normal. La défaite est prioritaire sur toute fin de vague ; la victoire nécessite la résolution de toute la vague 10 et au moins 1 PV restant. Une élimination au moment d’une arrivée empêche les dégâts de cette arrivée.

## Progression et spécialisations (L4)

Les achats et améliorations restent réservés aux intervalles entre vagues. Les passages N1 → N2, N2 → N3 et N3 → N4 coûtent respectivement 50, 100 et 150 or. Les dégâts de base sont multipliés par 1 ; 1,5 ; 2,25 ; 3,25 selon le niveau ; les valeurs finales des branches N4 remplacent ensuite ces références, sans seconde multiplication.

Au N3, le bouton ouvre un choix entre deux branches avec les statistiques finales. Confirmer paie 150 or et applique simultanément le N4 et sa branche. Annuler conserve le N3 et l’or. Le choix reste fixé jusqu’à la vente. Deux exemplaires d’un même type peuvent choisir des branches différentes ; leur quota commun reste de deux.

| Défenseur | Branche A | Branche B |
| --- | --- | --- |
| Archer | Veilleur des remparts | Tireur de volée |
| Arbalétrier | Brise-siège | Sentinelle des tours |
| Mage | Arcaniste de concentration | Maître des déflagrations |
| Troll | Fendeur de crânes | Maître des ricochets |
| Sapeur | Expert en démolition | Artificier des foules |
| Chaman | Chaman de guerre | Tisseur de malédictions |

Les douze fiches numériques suivent les sections 15 à 17 du GDD. La portée et les effets affichés correspondent au niveau et à la branche actuels. Le Maître des ricochets touche jusqu’à trois victimes successives distinctes ; les explosions restent centrées sur la cible principale.

La vente rembourse 70 % de toutes les dépenses réelles de l’exemplaire, arrondis une seule fois à l’entier inférieur. Sans réduction, un N4 coûte au total 350, 375 ou 400 or et rend 245, 262 ou 280 or selon son prix de recrutement. Une vente suivie d’un rachat crée un nouveau N1.

Les vagues successives permettent désormais de financer N3 et N4 avec les revenus réels. Les deux campagnes de référence atteignent une spécialisation N4 avant le boss sans or ajouté. Les scénarios de six N4 restent des tests à budget imposé, distincts des références financées normalement.

## Campagne, bonus et synergies

Les dix compositions du GDD sont exécutées : 182 ennemis et 770 or au maximum, sans prime de fin de vague. Premier ennemi à t = 0, intervalles internes inchangés, groupe suivant 4 s après la dernière apparition du précédent. Le temps de vague repart à zéro au lancement ; la défense, l’or, les PV et les bonus persistent. La durée de combat cumulée est affichée séparément des préparations.

Après les vagues 3, 6 et 9, trois codes distincts sont tirés avec poids égaux. Le code choisi est retiré du catalogue de cette partie ; les deux autres restent disponibles. Il n’y a ni relance, ni copie d’un même bonus. Les douze effets R-01 à R-12 suivent les sections 25 à 29 du GDD : dégâts additifs par composante et par victime, cadence hors chaman, portée, propagation, niveau, PV maximum et réductions de prix futures.

Les six synergies de proximité utilisent les centres logiques à distance ≤ 5. Les six associations de spécialisations exigent les branches N4 correspondantes, sans distance. Chaque code s’applique une seule fois par bénéficiaire, même avec deux partenaires admissibles. Les copies sont évaluées séparément ; les effets se retirent dès que le dernier partenaire admissible est vendu. Le volet racial reste non activable avec le roster actuel.

L’inspection affiche les statistiques effectives, les codes de synergie et leurs effets au survol. R-12 est signalé séparément car ses +20 % dépendent du type de chaque victime. Les prix courants et le remboursement historique tiennent compte des bonus économiques ; aucune dépense passée n’est réécrite.

## Profils ennemis intégrés

Grouillant, Pillard, Sprinter, Brute, Maraudeur, Colosse, Élite et Seigneur de siège utilisent les PV, vitesses, dégâts et récompenses du GDD. Chacun est vérifié par des essais de traversée, d’arrivée et d’élimination. Le boss inflige 20 dégâts à l’arrivée et donne 40 or s’il est éliminé.

Les huit profils apparaissent désormais dans leurs vagues approuvées, jusqu’au Seigneur de siège en vague 10. R-09 permet de porter le maximum à 24 PV ; un boss arrivant contre une forteresse intacte à 24 PV en laisse 4 et ne provoque pas automatiquement la défaite.

## Vérifications effectuées

Godot 4.7.2.stable.official.ed1daf0bf, GDScript, rendu Compatibility ; 21 octobre 2026.

| Contrôle | Résultat |
| --- | --- |
| Modèle : transactions, quota, ventes, vagues, ciblage, mage, simultanéité et cadence | 87 contrôles réussis, dont 30 comparaisons des couvertures au GDD |
| Interface : faction, boutique, descriptions, verrouillages, vitesse et relance | 37 contrôles réussis |
| Horde et ennemis : effets, huit profils, chronologie et cas du GDD | 75 contrôles réussis |
| Progression : niveaux, douze branches en combat, dépenses, ventes et six dialogues | 408 contrôles réussis |
| Campagne : dix vagues, offres, bonus, synergies, économies, deux victoires financées normalement | 362 contrôles réussis |
| Lancements graphiques et captures | Choix roguelite, douze fiches de bonus, récapitulatif, combat tardif et victoires inspectés pour v0.18 |
| Comparaison de chronologie | Identique avec un grand pas, à ×1 et à ×2, y compris dans un essai mêlant huit profils et les trois défenseurs Horde |

Références reproductibles, sans bonus ni synergies : Archer en E1 + Arbalétrier en E2, fin à 23,5 s ; Troll en E1 + Sapeur en E2, fin à 24,5 s. Dans chaque essai : départ après achats à 25 or, dix éliminations, aucune arrivée, 20 PV et 55 or restants. Ce résultat vérifie ce scénario ; il ne démontre pas l’équilibre de la partie ou des factions.

**Total : 969 contrôles réussis.** Les références historiques sans bonus ni synergies utilisent un constructeur de test dédié ; le jeu normal active toujours les synergies. Les tests de campagne vérifient les règles actives et la conservation de l’économie.

Deux victoires au budget normal, graine de vérification 42, choix R-06 puis R-11 puis R-10 : Alliance 14 PV, 192 or, 178 éliminations et 4 arrivées ; Horde 12 PV, 189 or, 175 éliminations et 7 arrivées. Temps de combat simulé cumulé : 372,755 s et 392,541 s. Ces résultats ne mesurent ni le temps de préparation humain ni l’équilibre général. Le [compte rendu](../design/Resultats_campagne_v018.md) donne le protocole et les offres.

Les tests peuvent être relancés depuis ce dossier avec le moteur :

~~~powershell
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_valley.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_interface.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_horde.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_progression.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_campaign.gd
~~~

Vérifier le résumé failures=0 et l’absence de messages ERROR, même si le processus rend un code de sortie nul. Les fichiers .godot sont un cache local exclu de Git ; les fichiers .gd.uid sont suivis.

## État et suite

L1, L2, L3, L4 et L5 sont réalisés. L0 reste partiellement réalisé : le projet démarre avec le moteur portable préparé localement, mais l’export Windows autonome reste à produire. Les documents de conception restent en v0.14 ; v0.18 désigne la révision du prototype et du dépôt.

Prochain lot L6 : essais de jeu, diversité des compositions, comparaison à budget et offres identiques, anomalies de compréhension et propositions d’équilibrage séparées des règles. La cible de 8 à 12 minutes reste à mesurer avec les préparations humaines. Voir le [cahier de réalisation](../design/Proposition_realisation_prototype.md), le [suivi du prototype](../design/Suivi_prototype.md) et les [choix techniques](../design/Choix_techniques_prototype.md).
