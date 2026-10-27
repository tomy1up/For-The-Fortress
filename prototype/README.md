# Dix vagues jouables sur La Vallée du Gué

**Version v0.61 (27 octobre 2026)** : l’archer elfe, l’arbalétrier nain et le mage humain rejoignent les trois personnages Horde dans le style cartoon retenu. [Version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.61).

**Prototype v0.61 — 27 octobre 2026.** Référence : GDD v0.14 complété par la décision d’enchaînement automatique du 23 octobre 2026. For the Fortress! reste un nom de travail.

Le jeu conserve le périmètre L5 : une campagne complète de dix vagues pour les deux factions, trois choix roguelite et les synergies approuvées. Les six défenseurs, leurs quatre niveaux et douze spécialisations sont conservés. La v0.23 applique la [révision du délai et des libellés](../design/Decision_preparation_v023.md) et conserve la [décision validée d’enchaînement automatique](../design/Decision_enchainement_v022.md) : après le premier départ manuel, les vagues suivantes partent après 30 secondes (révision v0.23). Les choix d’amélioration attendent le joueur. Les nombres de combat restent H.

## Version Windows autonome

Le [ZIP v0.61](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.61) contient le jeu Windows x86_64, la notice, les licences et la fiche d’essai. Extraire tout le dossier, puis lancer For_the_Fortress.exe. Aucun Godot installé ni accès réseau requis pour jouer. Prototype non signé, visuels temporaires ; vérification sur le PC actuel, sans validation d’autres configurations matérielles.

Sur ce PC : dist/For_the_Fortress_v0.61_Windows_x64 depuis la racine du dépôt. Voir [le relevé d’export](../design/Distribution_Windows_v061.json) pour les empreintes et les commandes de reconstruction. Les exécutables générés sont exclus de Git et attachés à la version GitHub.

## Jouer depuis le projet source


Sur ce PC, double-cliquer sur **Lancer_le_prototype.cmd** dans ce dossier. Le moteur officiel portable a été préparé dans C:/Projet/.tools/Godot-4.7.2, en dehors du dépôt Git.

Autre possibilité : ouvrir project.godot dans Godot 4.7.2 standard, puis lancer la scène principale avec F6 ou le projet avec F5. Aucun module externe n’est nécessaire. Sur un autre PC, récupérer [Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/) et ouvrir ce projet. Le lanceur PowerShell accepte aussi -EnginePath avec le chemin du moteur.

## Prise en main

1. Choisir Alliance des Royaumes ou Horde des Cendres. La faction reste fixe pendant cet essai.
2. Cliquer sur E1 à E6, puis acheter un défenseur de sa faction : 50, 75 ou 100 or. Deux exemplaires maximum par type.
3. Cliquer sur une unité pour lire ses statistiques, afficher sa portée, améliorer son niveau ou consulter son remboursement avant une vente.
4. Lancer la vague 1 : dix Pillards de 40 PV, apparitions à t = 0 puis toutes les 2,5 s. Les tirs sont automatiques.
5. Observer les éliminations, l’or et les arrivées ; alterner ×1, ×2 et ×10 debug. Le ×10 est temporaire pour les essais.
6. Entre les vagues, acheter, améliorer ou vendre pendant les 30 secondes avant le départ automatique. Cliquer sur le bouton pour partir plus tôt. Survoler le bouton de lancement pour voir sa composition et ses intervalles.
7. Après les vagues 3, 6 et 9, choisir un bonus parmi trois offres distinctes, sans limite de temps. Le délai complet de 30 secondes commence après le choix.
8. Consulter « Bonus acquis » et les synergies de l’unité sélectionnée ; survoler leurs codes pour lire les effets.
9. Survivre jusqu’à la résolution complète de la vague 10. « Nouvel essai » repart avec 150 or et 20 PV, sans bonus ni défense.

Les achats, améliorations, ventes et la relance d’un essai sont bloqués pendant le combat. Le bouton de lancement passe à la vague suivante ; il ne répète pas la précédente. La victoire et la défaite bloquent toute nouvelle dépense. Consulter les bonus acquis pendant un combat ne met pas le jeu en pause. Pendant la préparation, leur lecture suspend le décompte ; le choix de spécialisation le suspend également. Fermer ou résoudre ces fenêtres reprend le temps restant. Ni ×2 ni ×10 ne modifient les 30 secondes.

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

Les dix compositions du GDD sont exécutées : 182 ennemis et 770 or au maximum, sans prime de fin de vague. Premier ennemi à t = 0, intervalles internes inchangés, groupe suivant 4 s après la dernière apparition du précédent. Le premier lancement est manuel, les suivants automatiques après le délai ; un départ anticipé reste possible. Le temps de vague repart à zéro au lancement ; la défense, l’or, les PV et les bonus persistent. La durée de combat cumulée est affichée séparément des préparations.

Après les vagues 3, 6 et 9, trois codes distincts sont tirés avec poids égaux. Le code choisi est retiré du catalogue de cette partie ; les deux autres restent disponibles. Il n’y a ni relance, ni copie d’un même bonus. Les douze effets R-01 à R-12 suivent les sections 25 à 29 du GDD : dégâts additifs par composante et par victime, cadence hors chaman, portée, propagation, niveau, PV maximum et réductions de prix futures.

Les six synergies de proximité utilisent les centres logiques à distance ≤ 5. Les six associations de spécialisations exigent les branches N4 correspondantes, sans distance. Chaque code s’applique une seule fois par bénéficiaire, même avec deux partenaires admissibles. Les copies sont évaluées séparément ; les effets se retirent dès que le dernier partenaire admissible est vendu. Le volet racial reste non activable avec le roster actuel.

L’inspection affiche les statistiques effectives, les codes de synergie et leurs effets au survol. R-12 est signalé séparément car ses +20 % dépendent du type de chaque victime. Les prix courants et le remboursement historique tiennent compte des bonus économiques ; aucune dépense passée n’est réécrite.

## Profils ennemis intégrés

Grouillant, Pillard, Sprinter, Brute, Maraudeur, Colosse, Élite et Seigneur de siège utilisent les PV, vitesses, dégâts et récompenses du GDD. Chacun est vérifié par des essais de traversée, d’arrivée et d’élimination. Le boss inflige 20 dégâts à l’arrivée et donne 40 or s’il est éliminé.

Les huit profils apparaissent désormais dans leurs vagues approuvées, jusqu’au Seigneur de siège en vague 10. R-09 permet de porter le maximum à 24 PV ; un boss arrivant contre une forteresse intacte à 24 PV en laisse 4 et ne provoque pas automatiquement la défaite.

## Vérifications effectuées

Godot 4.7.2.stable.official.ed1daf0bf, GDScript, rendu Compatibility ; contrôles de régression relancés le 23 octobre 2026.

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

**Total actuel : 12 578 contrôles réussis**, dont 53 pour le ×10, 203 pour la lisibilité économique et numérique, 10 pour les remises à zéro de défilement, 729 pour la cohérence des factions, 8 752 pour les projections des bonus, 403 pour la prévision des vagues, 196 pour le bilan, 86 pour l’inspection ennemie, 357 pour les comparaisons d’amélioration, 504 pour les aperçus d’achat, 123 pour les partenaires et la lisibilité des synergies et 106 pour l’enchaînement automatique (premier lancement, échéance, pauses de choix, ×2, relance, deux campagnes financées et fins de partie). Les références historiques sans bonus ni synergies utilisent un constructeur de test dédié ; le jeu normal active toujours les synergies. Les tests de campagne vérifient les règles actives et la conservation de l’économie.

Deux victoires au budget normal, graine de vérification 42, choix R-06 puis R-11 puis R-10 : Alliance 14 PV, 192 or, 178 éliminations et 4 arrivées ; Horde 12 PV, 189 or, 175 éliminations et 7 arrivées. Temps de combat simulé cumulé : 372,755 s et 392,541 s. Ces résultats ne mesurent ni le temps de préparation humain ni l’équilibre général. Le [compte rendu](../design/Resultats_campagne_v018.md) donne le protocole et les offres.

Les tests peuvent être relancés depuis ce dossier avec le moteur :

~~~powershell
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_valley.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_interface.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_horde.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_progression.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_campaign.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_autoplay.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_synergy_feedback.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_purchase_preview.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_upgrade_preview.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_enemy_inspection.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_run_summary.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_wave_forecast.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_combat_feedback.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_breach_feedback.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_bonus_preview.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_faction_coherence.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_player_readability.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_bonus_scroll_reset.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 120 --script res://tests/test_debug_speed.gd
~~~

Vérifier le résumé failures=0 et l’absence de messages ERROR, même si le processus rend un code de sortie nul. Les fichiers .godot sont un cache local exclu de Git ; les fichiers .gd.uid sont suivis.

## Premiers essais comparatifs (L6)

La v0.19 ajoute des outils d’essai et des relevés ; les règles et réglages jouables sont inchangés depuis v0.18. Le [bilan](../design/Bilan_equilibrage_v019.md) compare 1 728 parties de politiques fixes, avec 109 111 vérifications d’intégrité sans échec. Les 969 contrôles de régression restent distincts et réussis.

Dans cette matrice, la politique renforts gagne 576/576 parties ; référence 399/576 ; spécialisation de deux unités initiales 82/576. Les placements, types et couvertures diffèrent entre politiques : ces résultats ne suffisent pas à conclure que les niveaux sont trop chers ou qu’une faction est équilibrée. 54 parties financent réellement une association N4. Aucun réglage n’est changé à partir de ces seuls résultats.

Les [données et commandes de reproduction](../design/essais/README.md) sont versionnées. Une [fiche d’essai](../design/Fiche_essai_joueur.md) sert à recueillir compréhension, choix et durées humaines. Aucun essai humain ni temps de préparation humain n’est présenté comme déjà mesuré.

## Améliorations à trois types constants (v0.20)

Le [nouveau bilan](../design/Bilan_ameliorations_v020.md) conserve trois types et leurs positions depuis 96 préparations communes après vague 4. Il compare 384 essais de vague 5 (épargne ou un N2 à 50 or) puis 768 continuations avec différentes répartitions et branches. Les copies d’état et de générateur sont vérifiées ; les revenus futurs ne sont jamais artificiellement égalisés.

Les trois traitements N2 réduisent les arrivées dans 53 à 55 états sur 96 selon la cible et ne les augmentent dans aucun de ces essais isolés. En continuation, equilibre gagne 152/192 scénarios contre 150/192 pour reference ; la meilleure répartition dépend du placement. Les 51 801 vérifications d’intégrité réussissent et les 969 contrôles de régression passent toujours. Les trajectoires parfois identiques ne sont pas des observations indépendantes.

Aucun coût ni dégât changé : ces résultats ne justifient pas une baisse générale des améliorations. Les archives et commandes sont dans [les données d’essais](../design/essais/README.md). Les essais humains et leurs durées restent à recueillir.

## État et suite

L1, L2, L3, L4 et L5 sont réalisés. L0 est réalisé pour le prototype Windows x86_64 : le projet source et la distribution autonome démarrent. Les essais humains et la validation sur d’autres machines restent à mener. Les documents de conception restent en v0.14 ; v0.22 désigne la révision du prototype et du dépôt.

L6 est partiellement réalisé : la matrice automatisée et les comparaisons à trois types constants sont consignées ; restent les essais humains avant de décider un réglage. La distribution Windows autonome v0.22 permet de tester également la préparation chronométrée. La cible de 8 à 12 minutes reste à mesurer avec les préparations humaines. Voir le [cahier de réalisation](../design/Proposition_realisation_prototype.md), le [suivi du prototype](../design/Suivi_prototype.md) et les [choix techniques](../design/Choix_techniques_prototype.md).

## Reconstruire et vérifier le ZIP

Installer les templates standard de Godot 4.7.2 avec le gestionnaire d’export, puis exécuter Exporter_Windows.ps1 depuis PowerShell. La version demandée doit correspondre à application/config/version dans project.godot. Le script vérifie le moteur exact, génère les notices de licences, exporte la scène et les cinq scripts runtime explicitement sélectionnés, intègre les données dans l’EXE, puis produit notice, manifeste, ZIP et empreinte SHA-256 dans dist.

Les tests, outils d’essai et documents de développement sont exclus du paquet de jeu. Pour lancer le contrôle sur l’archive extraite hors du projet :

~~~powershell
python prototype/tests/verify_windows_export.py dist/For_the_Fortress_v0.35_Windows_x64.zip --destination C:/Projet/.tools/controle_export
~~~

Cette dernière commande se lance depuis la racine du dépôt avec Python sur Windows. Elle vérifie les cinq fichiers attendus, le manifeste, l’architecture PE x86_64, le démarrage sans éditeur et trente-cinq captures graphiques (36 lancements au total). L’inspection des captures reste à faire séparément ; la commande ne prétend pas remplacer un essai humain.

## Lecture des synergies (v0.24)

Sélectionnez un défenseur : les traits dorés relient ses partenaires de proximité actifs ; les traits bleus relient ses partenaires de spécialisation actifs. Survolez la ligne des synergies au-dessus de la fiche pour lire noms, emplacements, gains et conditions des associations possibles. Les statistiques comprennent déjà les gains ; plusieurs partenaires ne doublent pas une même association. La lecture au survol ne suspend pas le décompte ni le combat.

## Comparer les portées avant achat (v0.25)

Sélectionnez un emplacement libre puis survolez un bouton de recrutement (ou donnez-lui le focus au clavier). Le cercle bleu montre la portée effective du futur défenseur de niveau 1 ; la portion bleue du chemin indique les positions où il pourra viser les ennemis. Les bonus acquis et les synergies de portée apportées par les voisins sont inclus. L’aperçu ne dépense rien, reste disponible en cas de manque d’or ou de quota atteint et ne suspend pas le décompte. L’achat exige toujours un clic valide.

## Comparer les améliorations (v0.26)

Survoler le bouton Niveau 2 ou Niveau 3 (ou lui donner le focus clavier) affiche les valeurs actuelles et prévues, ainsi que le rayon et la route couverte en bleu. Le clic reste nécessaire pour payer et appliquer l’amélioration. Le choix de spécialisation est placé à gauche pour laisser la carte visible : chaque branche compare ses statistiques au niveau actuel ; survoler son bouton montre sa portée future. Annuler conserve niveau, or et délai restant. Les comparaisons ordinaires ne suspendent pas les 30 secondes ; le choix de spécialisation continue de les suspendre.

## Identifier les ennemis (v0.27)

Pendant le combat, survoler un ennemi le met en évidence et affiche sa fiche en haut à droite : nom, PV actuels et maximum, perte de PV si arrivé à la forteresse, or gagné si éliminé et malédiction éventuelle. Une arrivée fatale au regard des PV actuels est signalée ; le boss est identifié. La fiche suit le survol et disparaît si l’ennemi meurt, sort du survol ou si une fenêtre modale est ouverte. Aucun changement de sélection de défenseur ou de vitesse ; le combat continue.

## Lire le bilan de partie (v0.28)

Après une victoire ou une défaite, cliquer sur Bilan à côté de Rejouer. Le tableau indique pour chaque vague les ennemis éliminés ou passés, les PV perdus, l’or gagné et le temps de combat simulé (hors préparations et choix). Survoler une ligne montre les défenseurs et bonus actifs au départ de cette vague. La défense finale et les bonus choisis sont rappelés en bas. Les vagues non jouées sont distinguées de la vague perdue. Le bilan reste en mémoire pour cet essai et est effacé au suivant ; aucune sauvegarde de partie n’est ajoutée.

## Anticiper la vague suivante (v0.29)

Pendant la préparation, la fiche en haut à droite présente les prochains groupes dans leur ordre d’apparition : nom, quantité, PV par ennemi et perte de PV s’il passe. Les couleurs correspondent aux profils du combat ; le boss et une arrivée individuellement fatale sont signalés. Survoler un groupe donne ses horaires, son intervalle et ses récompenses. Le gain indiqué au pied est conditionnel à l’élimination de tous les ennemis. Le décompte reste 30 secondes et continue pendant la lecture. Les choix modaux et les combats masquent cette fiche.

## Lire les impacts (v0.30)

Les explosions du mage (bleu) et du sapeur (orange) suivent le sol isométrique et leur rayon réel. Les petites marques désignent les victimes secondaires réellement touchées ; le contour ne garantit pas que tout ennemi dans la zone subit des dégâts. Les ricochets verts relient les victimes successives avec une flèche de direction. Une marque violette au-dessus de la tête accompagne la malédiction active. Les impacts s’estompent sur 0,32 seconde simulée (0,16 seconde réelle à ×2). Voir [le relevé de réalisation](../design/Lisibilite_combats_v030.md).

## Comprendre les recrues (v0.31)

Survoler une recrue ou lui donner le focus affiche ses dégâts directs, sa cadence, sa portée et son prix, avec les bonus et synergies actuels. La seconde ligne explique les effets secondaires, avec un plafond de victimes plutôt qu’un nombre garanti. Le rôle du défenseur accompagne la route bleue. L’infobulle précise le ciblage, les limites du rayon et le renouvellement des malédictions. Un motif d’achat impossible reste visible, sans invitation contradictoire à acheter. Le survol ne suspend pas les 30 secondes et ne dépense rien. Voir [le relevé](../design/Aide_recrutement_v031.md).

## Repérer les percées ennemies (v0.32)

Une arrivée dommageable fait apparaître près de la forteresse le nombre d’ennemis passés et les PV réellement perdus. Le compteur de vie est brièvement mis en évidence. Le signal dure 2,5 secondes réelles, également à ×2 ; il ne suspend aucun événement. Une nouvelle arrivée remplace le signal, le départ de la vague suivante et le nouvel essai l’effacent. Voir [le relevé](../design/Signal_percees_v032.md).

## Comparer les bonus roguelite (v0.33)

Après les vagues 3, 6 et 9, chaque proposition montre son effet avant/après sur les défenseurs actuels, identifiés par emplacement. Les listes longues défilent dans leur colonne. Les gains de PV, les prix futurs et les dégâts conditionnels contre les grandes cibles sont distingués. Un bonus sans bénéficiaire actuel le signale et rappelle son éventuel intérêt pour les futures recrues. La lecture reste sans limite de temps et seul le clic applique le bonus. Le récapitulatif des bonus acquis conserve sa présentation compacte. Voir [le relevé](../design/Comparaison_bonus_v033.md).

## Cohérence des factions (v0.34)

Les descriptions des bonus passent par une sélection centrale selon la faction, dans les offres comme dans le récapitulatif. Exercice de tir ne mentionne plus de chaman en Alliance ; les explosions, rebonds et malédictions ne sont décrits que pour le camp qui les possède. Les synergies ne promettent plus un effet secondaire ou de malédiction absent du défenseur. Achats et aperçus adverses sont refusés ; les améliorations et spécialisations sont aussi refusées même sur une unité adverse injectée dans un état de contrôle. Les douze bonus restent communs aux deux camps et gardent leurs effets. Voir [le relevé](../design/Coherence_factions_v034.md).

## Lisibilité et débogage (v0.35)

La fiche ennemie explique que la forteresse perd les PV indiqués si l’ennemi l’atteint, et que le joueur gagne l’or indiqué en l’éliminant. Les nombres affichent au maximum deux décimales ; les calculs restent précis. Les aides de vente et d’amélioration détaillent les investissements, pertes et soldes futurs. La route couverte par une unité sélectionnée est dorée ; les aperçus restent bleus. Silhouettes et équipements temporaires distinguent les huit ennemis et les races des défenseurs. Les listes de bonus repartent en haut lors d’un nouveau choix ou d’une nouvelle partie.

Le bouton de vitesse suit temporairement ×1 → ×2 → ×10 debug → ×1, sur demande du porteur du projet. Seul le combat accélère ; préparations, choix et durée de lecture des percées gardent leurs règles. Retirer 10.0 de COMBAT_SPEEDS et adapter l’aide lors du retrait du mode debug. [Détail](../design/Lisibilite_et_debug_v035.md) · [Essais interactifs](../design/Essais_interactifs_v035.md).

## Rapport de débogage local

En fin de partie : **Bilan → Exporter le rapport**, puis **Ouvrir le dossier du rapport**. Le Markdown résume les vagues et décisions ; le JSON conserve les détails et les offres de bonus. Aucun envoi réseau ni reprise de partie. Voir [le détail](../design/Rapports_partie_v036.md).

## Anticiper les synergies (v0.37)

Survolez une recrue ou une spécialisation : les liens bleus pointillés montrent ses partenaires prévus. L’infobulle du bouton précise les emplacements et les gains ; les statistiques affichées les incluent déjà. Plusieurs partenaires ne multiplient pas un même bonus. [Fonctionnement et vérification](../design/Apercu_synergies_v037.md).

## Activité des défenseurs (v0.38)

En fin de partie, ouvrir **Bilan → Défenseurs** pour les attaques et PV réellement retirés, dont ceux du boss. Survoler une ligne pour les impacts directs, secondaires et malédictions propres à cette unité. Les recrues vendues restent dans le bilan. Les rapports exportés incluent ces mesures. [Convention et vérifications](../design/Activite_defenseurs_v038.md).

## Suivre le boss (v0.39)

Sa jauge de vie reste visible sans survol pendant le combat, avec les dégâts qu’il infligerait à la forteresse. La fiche au survol conserve ses informations complémentaires. [Détail et validation](../design/Suivi_boss_v039.md).

## Vérification complète (v0.40)

Depuis la racine du dépôt : `python prototype/tests/run_regression.py`. Utiliser `--engine` pour préciser Godot et `--report` pour conserver un JSON et les journaux. Les 23 suites Godot, tests Python et contrats du GDD sont intégrés au dépôt. [Instructions et validations](../design/Verification_reproductible_v040.md).

## Sélection au clavier (v0.41)

Utiliser 1 à 6 ou le pavé numérique pour sélectionner E1 à E6. Les touches physiques de la rangée supérieure fonctionnent sur AZERTY sans Maj. La sélection reste sans dépense et les panneaux de choix la bloquent. [Détail et vérification](../design/Selection_clavier_v041.md).

## Dialogues et clavier (v0.42)

Pendant un choix, récapitulatif ou bilan, les commandes de fond ne reçoivent plus le focus clavier et ne peuvent pas relancer la partie ou changer sa vitesse. Les commandes du panneau restent disponibles. [Correction et vérification](../design/Commandes_modales_v042.md).

## Identifier la version du jeu — v0.43

La fenêtre et le bas de l’écran indiquent la version embarquée. Les contrôles du ZIP comparent aussi cette version à la notice, au nom du dossier et aux rapports de partie. [Détail](../design/Identification_version_v043.md)

## Clavier pendant les changements de phase — v0.44

Au lancement manuel ou automatique, une commande devenue inactive libère le focus. Une commande encore disponible le conserve. [Détail](../design/Focus_combat_v044.md).

## Cohérence des sources compilées — v0.45

L’export compare les empreintes des sources avant et après compilation puis avant archivage. Le vérificateur du paquet accepte `--source-project` pour comparer dix fichiers au projet local. [Protocole](../design/Sources_compilation_v045.md).

## Rejouer un rapport de partie — v0.46

Un outil réservé au développement vérifie les décisions d’un rapport JSON contre le modèle actuel : offres, dépenses, vagues, composition, contributions et résultat. Il ne modifie pas le fichier. [Utilisation et limites](../design/Rejeu_rapports_v046.md).

## Calcul des comparaisons de bonus — v0.47

Les trois comparaisons ne sont plus recalculées à chaque image pendant la lecture. Les données pertinentes restent surveillées pour conserver des textes actuels. [Mesure et vérification](../design/Calcul_bonus_v047.md).

## Fermer un panneau avec Échap — v0.48

Échap ferme le récapitulatif ou le bilan, et annule une spécialisation sans payer. Les choix de faction et de bonus obligatoires restent ouverts. [Règles et vérifications](../design/Echap_panneaux_v048.md).

## Consignes selon la situation — v0.49

Le panneau de gauche indique quoi faire à chaque étape et cesse de parler de première vague après celle-ci. Le compteur précise « Combat simulé » ; une aide au survol explique les vitesses et les temps exclus. [Détail](../design/Consignes_contextuelles_v049.md).

## Suivi du boss final — v0.50

Le rapport et l’aide de la vague 10 distinguent boss éliminé, arrivé à la forteresse, encore en chemin ou non rencontré. Les temps mesurés restent des temps de simulation. [Détail et limites](../design/Releve_boss_v050.md).

## Voir le temps de préparation — v0.51

Une barre suit les 30 secondes restantes, se fige pendant une lecture suspendue et disparaît au départ de la vague. Le texte du bouton reste disponible. [Détail](../design/Barre_preparation_v051.md).

## Présentation de la carte — v0.52

La carte gagne en relief et en détails de décor. Géométrie, emplacements, portées et statistiques conservent leurs valeurs. Les visuels restent temporaires. [Détail](../design/Presentation_carte_v052.md).

## Infobulle après lancement — v0.53

Après activation sous la souris, l’aide du bouton de lancement attend que la souris le quitte. Revenir dessus permet de consulter la composition. [Vérification](../design/Infobulle_lancement_v053.md).

## Choisir sans tout lire — v0.54

Les cartes de bonus présentent le gain, les unités concernées et les conditions utiles. Voir les détails ouvre la règle complète et la comparaison réelle. Les spécialisations affichent leur rôle ; Voir les chiffres révèle les valeurs exactes. [Présentation et vérifications](../design/Lecture_progressive_v054.md).

## Défenseurs reconnaissables — v0.55

Les six défenseurs ont des proportions, visages et équipements distincts. Un bref recul accompagne leurs attaques réelles. Dessins originaux produits par le jeu, sans changement des statistiques. [Présentation et contrôles](../design/Presentation_defenseurs_v055.md).

## Projectiles et impacts — v0.56

Les six classes ont des projectiles distincts, des points de départ sur leur équipement et des impacts adaptés. Les marques secondaires correspondent aux victimes réellement enregistrées ; le trajet visuel ne retarde pas les dégâts. [Présentation et contrôles](../design/Presentation_attaques_v056.md).

## Recrutement et amélioration — v0.57

Les fiches mettent en avant le rôle, les dégâts utiles et le prix. Voir les chiffres affiche les cadences, portées et règles complètes. Les portées et partenaires restent prévisualisés dans les deux vues. [Présentation et contrôles](../design/Lecture_recrutement_v057.md).

## Bilan essentiel — v0.58

Le premier bilan affiche le résultat, les chiffres clés et les moments où la forteresse a perdu des PV. Vagues et Défenseurs conservent les tableaux détaillés. [Présentation et contrôles](../design/Bilan_essentiel_v058.md).

## Ennemis reconnaissables — v0.59

Les huit profils ont des silhouettes, visages et équipements distincts dans la même direction cartoon que les défenseurs. Statistiques et règles inchangées. [Présentation et contrôles](../design/Presentation_ennemis_v059.md).

## Personnages Horde illustrés — v0.60

Le troll, le gobelin et le chaman utilisent les PNG transparents issus de la planche validée. Leur ancrage, leurs tailles et le filtrage sont adaptés au plateau. [Assets, limites et consignes de génération](../design/Assets_Horde_v060.md).
