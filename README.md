# For the Fortress!

**Prototype v0.112 — préparer les rencontres** : [vue facultative des ennemis de mission](design/Rencontres_mission_v0112.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.112). Portraits, origines, PV, première vague et pertes de forteresse sont regroupés hors de la fiche principale. Lecture sans lancement ni modification de progression.

**Prototype v0.111 — comparer les unités de boutique** : [fiches et tableau facultatif](design/Comparaison_boutique_v0111.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.111). Les chiffres de niveau 1 sont présentés face à ceux du défenseur de départ, avec une distinction entre PO de déblocage et or de recrutement. Aucun changement de prix ou de combat.

**Prototype v0.110 — protection lisible au survol** : [inspection de la Gardienne et des voisins](design/Inspection_gardienne_v0110.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.110). Les liens et le nombre de voisins éligibles apparaissent pendant l’inspection. Le statut de malédiction reste visible sur une Gardienne.

**Atelier du sanglier — à examiner** : [dessin, aperçu et contrôles](design/essais/sanglier_peau_continue/README.md). Un premier cycle expérimental adapte la foulée à la vitesse actuelle du sanglier. Un aperçu sur quatre diagonales vérifie proportions, appuis, pause et accélération. Deux [traversées du vrai tracé du Gué](design/essais/sanglier_peau_continue/sanglier_sur_le_gue_alliance.mp4) ajoutent les six virages, la pause et un impact imposé ; le montage reste un diagnostic hors campagne, avec changements de profil instantanés. Des [vues de face et de trois quarts](design/essais/sanglier_virages/README.md) préparent maintenant les raccords de virage ; ce sont des dessins statiques, pas une animation intégrée. L’ensemble reste séparé de la version jouable et n’est pas approuvé artistiquement.

**Prototype v0.109 — orientation du loup sans étirement** : [correction et contrôles](design/Orientation_loup_v0109.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.109). La démarche approuvée est conservée ; le placement diagonal utilise une rotation du personnage entier, avec conservation des proportions, des angles et des appuis. Cette correction remplace le placement de la v0.108 après le retour visuel du porteur.

**Prototype v0.108 — marche du loup validée pour le prototype** : [intégration, contrôles et limites](design/Marche_loup_v0108.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.108). Le corps et les membres partagent une peau continue ; épaules et bassin accompagnent les appuis. La cadence suit la distance réellement parcourue à l’écran. Cette version remplace les anciens essais de loup ci-dessous ; les autres unités restent à animer.

Les annonces d’animation suivantes retracent les essais précédents et leurs validations à leur date.

**Animation : étude d’une peau continue** : [diagnostic, base graphique et premier essai natif](design/essais/loup_peau_continue/README.md). Après amélioration des appuis et du corps, les raccords des membres restent insatisfaisants. Le nouveau montage teste une surface commune aux épaules et aux hanches ; il ne constitue pas encore un cycle de marche.

**Prototype v0.107 — annonces par entrée et ciblage à l’arrivée** : [règles, contrôles et limites](design/Atelier_routes_v0107.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.107). Dans l’atelier à deux entrées, les préparatifs annoncent les effectifs par trajet et les défenseurs privilégient la cible qui atteindra le plus tôt la forteresse, selon sa vitesse. Les anciens rapports gardent leur règle historique.

**Loup : pattes validées, corps à valider** : [nouvel essai du corps et comparatif](design/essais/animation_loup_corps/README.md). Les trajectoires des pattes approuvées sont conservées ; épaules, bassin, dos, tête et queue sont animés. Cet essai reste séparé de la version publiée en attendant la validation visuelle du porteur.

**Animation du loup à reprendre après retour visuel** : le cycle de la v0.105 est jugé trop saccadé. L’essai articulé suivant est rejeté et retiré du projet. [Critères d’autocontrôle et validation attendue](design/Validation_visuelle_animations.md). Le loup sera validé par le porteur avant toute extension aux autres unités. [Essai historique v0.105](design/Marche_loup_v0105.md), [version Windows historique](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.105).

**Candidat de marche à 24 poses** : [aperçu et contrôles ciblés](design/essais/animation_loup_24_poses/README.md), hors production et en attente du retour artistique du porteur. Les contrôles techniques ne valident pas la démarche.

**Prototype v0.106 — atelier à deux entrées** : [La Confluence](design/Atelier_routes_v0106.md) permet de tester deux chemins vers une forteresse, avec recrutement, combat, portées et rapports. Lancer `Lancer_atelier_routes.cmd` dans le paquet Windows ; aucun profil joueur ni gain de progression. L'atelier reste distinct des vingt missions. Tracé, alternance et ciblage entre routes sont des propositions de prototype. [Socle géométrique](design/Preparation_routes_convergentes.md).

**Prototype v0.104 — forteresses et souverains** : deux bâtiments et deux rois propres aux factions, avec quatre poses liées aux départs de vagues, pertes de PV et défaites. Cour visuelle adaptée pour garder les emplacements dégagés ; aucun changement de combat ou de progression. [Illustrations, règles et limites](design/Forteresses_souverains_v0104.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.104). Les apparences sont des propositions de prototype.

**Prototype v0.103 — réactions aux dégâts** : les attaquants s’inclinent et reculent brièvement lorsqu’ils perdent des PV, avec une réaction plus discrète pour les ennemis lourds. Ce mouvement reste visuel et n’arrête pas leur avancée. [Règles et limites](design/Reactions_corporelles_v0103.md), [version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.103). Les cycles de marche et les animations détaillées des membres restent à réaliser.

**Prototype v0.102 — chapitre 2 et Gardienne à l’essai** : [règles, chiffres provisoires et limites](design/Gardienne_des_berges_v0102.md). Vingt missions jouables ; les missions 11–20 reprennent les dix tracés du Gué avec de nouvelles rencontres. Une tortue neutre reçoit une partie des dégâts de ses voisins. Le choix Gardienne/Protectrice reste à confirmer après essai. [Version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.102).

**Chantiers visuels et futurs parcours** : animations des défenseurs synchronisées aux projectiles, réactions des attaquants aux dégâts, forteresse et roi propres à chaque faction, puis entrées multiples, routes convergentes et plusieurs forteresses. [TODO et questions ouvertes](design/Feuille_de_route_long_terme.md). À développer.

**GDD 0.18 — référence jeu 0.109** : documents Word et Markdown synchronisés, vingt missions, boutique, talents par famille et sauvegarde au schéma 7. Démarche du loup approuvée pour le prototype ; placement diagonal corrigé à éprouver. Atelier à deux entrées et ciblage au temps d’arrivée documentés séparément de la campagne. Le sanglier reste un essai non intégré. [Vérification documentaire](design/essais/gdd_v018_verification.json).

**Mode infini** : [Normal, Héroïque et Mythique](design/Infini_difficultes_2026-10-31.md), chacun ouvert après les dix premiers chapitres de campagne dans la difficulté correspondante, par faction. À développer.

**Succès** : [principe et premières pistes](design/Succes_2026-10-31.md), dont une unité envisagée après les vingt chapitres de chaque difficulté. Liste, critères et récompenses à définir.

**Design long terme — 31 octobre 2026** : [biomes et difficulté cumulative](design/Biomes_cumul_2026-10-31.md). Deux chapitres par biome, nouveaux attaquants ou affixes au second chapitre, combinaisons après la mission 100 et accumulation progressive en mode infini. Ces contenus restent à développer.

**Difficultés de campagne** : [Normal, Héroïque, Mythique](design/Difficultes_campagne_2026-10-31.md). La campagne actuelle correspond au Normal ; 100 premières missions réussies ouvrent la difficulté suivante, avec un parcours successif propre à chaque difficulté et faction. Les modes avancés restent à développer.

**Version v0.101 (31 octobre 2026)** : [coût du grenadier ajusté](design/Grenadier_prix_v0101.md). Le recrutement passe de 90 à 75 or de combat ; le déblocage reste à 240 PO. Dégâts, portée et cadence conservés. Réglage de prototype à éprouver. [Version Windows](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.101).

**Quatrième défenseur prioritaire — 3 744 simulations complémentaires** : [résultats et limites](design/Comparaison_priorite_boutique_v0991.md). Les deux spécialisations sont atteintes pour chaque alternative ; cette priorité ne garantit pas davantage de victoires. Aucun réglage modifié.

**Comparaison des unités de boutique — 7 488 simulations** : [résultats et limites](design/Comparaison_boutique_v0991.md). Les rôles d’ouverture et de renfort donnent des résultats différents ; traqueur et grenadier demandent une attention particulière. Ces politiques fixes ne mesurent pas le taux de victoire humain et ne modifient aucun réglage.

**Comparaison des trois missions — 2 592 simulations** : [résultats et limites](design/Comparaison_trois_missions_v092.md). Deux factions, trois tirages, six placements, quatre compositions et comparaison du premier point en mission 3. Des stratégies sans talent gagnent chaque carte ; géométrie et composition pèsent sur la difficulté. Ces simulations ne mesurent pas le taux de victoire humain et n’entraînent aucun changement d’équilibrage ou de binaire.

**Audit de progression — 512 scénarios** : [résultats et limites](design/Bilan_progression_v078.md). Budget normal, deux placements et quatre configurations de talents ; aucune modification d’équilibrage.

**Origine des ennemis — 27 octobre 2026** : la [règle et la répartition](design/Origine_ennemis_2026-10-27.md) sont mises en jeu dans la [v0.65](design/Catalogue_attaquants_v065.md). Loup, sanglier et ours restent communs. Les autres attaquants viennent du camp adverse ; le catalogue commun et les trois images humanoïdes v0.64 sont remplacés.

**Direction artistique validée — 27 octobre 2026** : la [planche Horde](design/concepts/Direction_cartoon_Horde_v001.md) devient la référence cartoon des prochains personnages. Les six défenseurs sont désormais illustrés sur fond transparent : [Horde v0.60](design/Assets_Horde_v060.md), [Alliance v0.61](design/Assets_Alliance_v061.md).

Jeu solo de Tower Defense à parties roguelike dans un univers médiéval-fantasy coloré. Le joueur choisit entre l’Alliance des Royaumes et la Horde des Cendres, installe ses défenseurs sur des emplacements fixes et protège sa forteresse contre des vagues d’ennemis.

**Nom de travail : disponibilité juridique à confirmer.** Les noms des factions sont provisoires.

**Orientation validée le 26 octobre 2026** : priorité à la présentation et à la compréhension des écrans, fantasy cartoon avec unités reconnaissables, aucune progression permanente dans ce lot de présentation (décision ensuite remplacée par les arbres persistants des v0.67 à v0.69), difficulté exigeante où plusieurs défaites avant la première victoire sont attendues. [Décisions et proposition du prochain lot](design/Orientation_presentation_2026-10-26.md).

## Documents

- [GDD Word](For_the_Fortress_GDD.docx) : présentation structurée avec sommaire et tableaux.
- [GDD Markdown](For_the_Fortress_GDD.md) : référence éditoriale adaptée au versionnement Git.
- Version documentaire : **0.18 — 2 novembre 2026**, référence jeu **0.109** : 72 pages, 61 sections et 79 tableaux synchronisés en Word et Markdown. Les versions suivantes sont décrites dans leurs fiches complémentaires. [Contrôles documentaires](design/essais/gdd_v018_verification.json).

## Mécaniques établies

- Deux factions jouables avec races, classes et orientations distinctes.
- Chemins fixes, emplacements prédéfinis et attaques automatiques.
- Achats, améliorations et ventes uniquement entre les vagues.
- Quatre niveaux par défenseur ; deux branches de spécialisation au niveau 4.
- Un bonus parmi trois propositions aléatoires, actif jusqu’à la fin de la partie.
- Synergies de diversité raciale, de spécialisation et de proximité.
- Revente à 70 % du total investi, suivie du recalcul des synergies.

## Prototype de référence

Dix cartes isométriques du thème du Gué, avec six emplacements et dix vagues chacune. PV ennemis de 100 % à 109 % ; vitesse, dégâts à la forteresse et gains de combat identiques. Six défenseurs de départ, trois par faction, et quatre alternatives de boutique proposées. Le joueur choisit un seul quatrième type pour sa mission. Capital initial de travail : 150 or de combat ; forteresse : 20 PV avant talents. Choix roguelite après les vagues 3, 6 et 9. Première vague manuelle, puis 30 secondes de préparation entre vagues ; les choix de bonus attendent le joueur.

Chaque mission repart à neuf. La première victoire rapporte actuellement 60 PO et 100 XP par faction, valeurs de prototype. L’XP débloque les points de talent ; les PO débloquent des unités en boutique. Rejouer ou perdre ne redonne pas ces gains. Les deux parcours, XP, PO et talents sont indépendants et sauvegardés. La courbe de référence vise 51 points après 100 premières victoires ; les 190 autres missions restent à réaliser.

Durée ciblée : 8 à 12 minutes, à mesurer. Les sept profils ordinaires et le boss déterminent les statistiques ; leurs identités en jeu sont des animaux neutres ou des attaquants du camp adverse. Les réglages figurent dans le GDD avec le statut d’hypothèses.

Les coûts de recrutement des défenseurs de départ de 50, 75 et 100 or, les DPS de 8, 9,6 et 10,8 et les améliorations de 50, 100 et 150 or restent des **hypothèses non équilibrées**.

## Intentions commerciales

PC sur Steam en priorité ; Godot avec GDScript ; modèle premium et prix de travail de 7,99 €. La cible de campagne est de 200 missions, organisées en chapitres et thèmes. Les nouveautés sont prévues aux blocs 11–20, 31–40, etc. L’infini se débloquera après les 100 premières missions de la faction ; il n’est pas encore jouable. Boutique d’unités alternatives, contenu étendu et objectifs commerciaux restent à préciser. Aucun calendrier ni engagement de production n’est déduit de ces cibles.

## Séquence de référence des dix vagues

La [séquence détaillée des dix vagues](design/Proposition_dix_vagues.md) est approuvée pour le prototype et intégrée au GDD v0.6. Quantités et intervalles restent des réglages H. Elle prévoit 182 ennemis, 770 or de récompenses maximales et 4 min 33,1 s de fenêtres d’apparition, hors fins de combat et préparations.

## Progression approuvée

La [progression des niveaux 2 à 4](design/Proposition_progression_niveaux.md) est intégrée au GDD v0.7 : dégâts × 1 / 1,5 / 2,25 / 3,25 du N1 au N4, cadence et portée inchangées. Le principe est validé ; les valeurs restent des hypothèses H à tester. Les tableaux couvrent les six défenseurs, leurs effets secondaires et leurs coûts cumulés.

## Spécialisations approuvées

La [fiche des douze spécialisations](design/Proposition_specialisations.md) est intégrée au GDD v0.8. Le choix est inclus dans le coût du N4, exclusif et fixé jusqu’à la vente. Les effets sont approuvés ; les noms restent provisoires et les valeurs sont des hypothèses H à tester.

## Carte approuvée

La [fiche de La Vallée du Gué](design/Proposition_Vallee_du_Gue.md) est intégrée au GDD v0.9 : trajet de 28 unités et six emplacements, avec [plan](design/Vallee_du_Gue_plan.svg), couvertures et temps de traversée. Le tracé et les conventions sont approuvés ; les dimensions restent des valeurs H à tester. Le plan présente la géométrie vue du dessus, avant projection isométrique.

## Résolution du combat approuvée

La [fiche de résolution du combat](design/Proposition_resolution_combat.md) est intégrée au GDD v0.10 : premier tir, égalités, dégâts instantanés, malédictions hors portée et événements simultanés, avec douze cas de référence. Ces règles sont approuvées pour le prototype.

## Bonus roguelite approuvés

La [proposition des douze bonus roguelite](design/Proposition_bonus_roguelite.md) est intégrée au GDD v0.11 : dégâts, cadence, portée, zones, niveaux, forteresse et prix. Tirage uniforme de trois offres distinctes, bonus choisis exclus, pourcentages additionnés par composante. Le chaman est exclu du bonus de cadence ; les valeurs restent H.

## Synergies approuvées

La [proposition de synergies](design/Proposition_synergies.md) est intégrée au GDD v0.12 : six associations de proximité et six associations de spécialisations, conditions, cumuls et budgets. Le volet racial est conservé sans activation avec un seul type par race ; les valeurs restent H.

## Recrutement et vente approuvés

La [proposition de recrutement et de vente](design/Proposition_recrutement_vente.md) prévoit deux copies maximum par type et une vente à 70 % du montant réellement payé, arrondie à l’entier inférieur par exemplaire. Elle est intégrée au GDD v0.13. Les comportements sont validés ; la limite de deux exemplaires et les coûts restent H.

## Réalisation du prototype approuvée

Le [cahier de réalisation du premier prototype](design/Proposition_realisation_prototype.md) décrit les panneaux de préparation et de combat, les étapes L0 à L6 et les critères de vérification. Le cadre est intégré au GDD v0.14. Les critères sont à exécuter ; ils ne constituent pas des résultats de test. Le premier essai utilise Godot avec GDScript, en 2D isométrique.

La [feuille de route long terme](design/Feuille_de_route_long_terme.md) consigne la vision du 28 octobre 2026 : cible de 200 missions, chapitres, PO de première réussite et infini après les 100 premières missions. Décisions, propositions de l’ancienne réponse et questions ouvertes sont distinguées ; cette économie ne remplace pas encore celle du prototype.

## Statuts et suivi

Le GDD utilise **V** validé, **H** hypothèse, **C** cible, **O** ouvert et **P** proposition. La feuille de route et les conventions de suivi sont proposées, sans nouvelle fonctionnalité approuvée. Les calculs économiques dérivés sont identifiés.

Le combat Alliance au niveau 1 est précisé dans le GDD : archer à 8 dégâts par seconde, arbalétrier à 24 dégâts toutes les 2,5 secondes et mage à 27 dégâts toutes les 2,5 secondes, avec jusqu’à deux cibles secondaires à 40 %. Portées initiales : 4, 5 et 3,5 unités. Les rôles et le ciblage de l’ennemi le plus avancé sont validés ; les nombres restent à tester.

Le combat Horde est également validé pour les essais : troll avec rebond, sapeur avec explosion et chaman avec malédiction. Leurs DPS théoriques sur une cible restent 8, 9,6 et 10,8. Les victimes secondaires les plus proches du point d’impact sont prioritaires. Tous les nouveaux réglages numériques restent provisoires.

Les éliminations rapportent immédiatement une récompense unique, identique pour les deux factions, y compris par malédiction. Un ennemi atteignant la forteresse inflige ses dégâts puis quitte la partie sans récompense. Aucune prime de fin de vague pour le premier essai.

Prochain travail : recueillir les essais humains de L6 avec la version Windows autonome et la fiche de retour. La progression entre les parties reste ouverte.

Mettre à jour le Markdown et le Word dans une même révision. Documenter toute modification avec un identifiant, une date, un statut, une source et son impact. Une valeur manquante reste « À définir » et ne vaut pas zéro.

Le [prototype Godot](prototype/README.md) est en **v0.35 — 24 octobre 2026** : deux factions, six défenseurs, progression N1 à N4, douze spécialisations, dix vagues, boss, trois choix roguelite et douze synergies activables. Les 12 578 contrôles passent. Le [bilan comparatif](design/Bilan_equilibrage_v019.md) ajoute 1 728 parties automatisées et 109 111 vérifications d’intégrité, sans modifier les réglages. Le [bilan des améliorations](design/Bilan_ameliorations_v020.md) compare aussi 384 essais isolés et 768 suites depuis 96 états communs, à trois types et positions conservés. Les coûts actuels sont maintenus. Les [références v0.18](design/Resultats_campagne_v018.md) restent reproductibles. Un [premier retour Horde](design/Retours_joueurs.md) est recueilli ; la [fiche d’essai joueur](design/Fiche_essai_joueur.md) permet de compléter les observations. Le volet racial reste différé. Les valeurs d’équilibrage restent H et les documents de conception restent en v0.14.

Pour jouer sans Godot, télécharger le ZIP de la [version Windows v0.22](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.22), extraire le dossier puis lancer For_the_Fortress.exe. Sur ce PC, la version prête est aussi dans dist/For_the_Fortress_v0.22_Windows_x64. Le lanceur prototype/Lancer_le_prototype.cmd reste disponible pour le projet source. Le [suivi du prototype](design/Suivi_prototype.md) distingue les lots réalisés et ceux à venir.

La [v0.22 autonome](design/Distribution_Windows_v022.md) ajoute l’enchaînement automatique avec 60 secondes de préparation après le premier lancement manuel. Les choix d’amélioration attendent le joueur. Cette [décision validée](design/Decision_enchainement_v022.md) complète le GDD principal v0.14, dont les versions Word et Markdown restent inchangées et concordantes. Les nombres de combat sont conservés.

## Rapports de partie — v0.36

Le bilan permet d’exporter les décisions, offres de bonus, ressources et résultats dans deux fichiers locaux. [Fonctionnement et validation](design/Rapports_partie_v036.md). 12 717 contrôles et 38 lancements Windows vérifiés.

## Aperçu des synergies — v0.37

Les liens et les gains prévus sont visibles avant de recruter ou spécialiser un défenseur. [Détail](design/Apercu_synergies_v037.md). 13 879 contrôles réussis et 42 lancements Windows vérifiés, sans changement d’équilibrage.

## Activité des défenseurs — v0.38

Le bilan détaille les contributions des recrues, y compris celles vendues, avec une mesure des PV retirés sans excédent létal. [Convention et vérifications](design/Activite_defenseurs_v038.md). 13 952 contrôles et 45 lancements Windows, sans changement d’équilibrage.

## Relecture de la finale

La [matrice instrumentée en v0.38](design/Bilan_finale_v038.md) confirme les résultats historiques de 1 728 scénarios et distingue le boss de la fin de vague. Données et outils de reproduction versionnés ; aucun réglage changé. Les essais humains restent nécessaires pour le ressenti de difficulté.

## Suivi du boss — v0.39

Jauge permanente pendant sa présence en combat, sans changement de statistiques. [Détail](design/Suivi_boss_v039.md). 14 004 contrôles et 46 lancements Windows réussis.

## Vérifications du projet — v0.40

Le [lanceur complet de régression](prototype/tests/run_regression.py) et les contrats du GDD sont versionnés. [Instructions et validation](design/Verification_reproductible_v040.md) : 14 004 contrôles Godot, 9 tests Python et 46 lancements Windows réussis.

## Emplacements au clavier — v0.41

Touches 1 à 6 et pavé numérique pour sélectionner les six emplacements. [Détail](design/Selection_clavier_v041.md). 14 072 contrôles Godot, 9 tests Python et 46 lancements Windows réussis.

## Commandes des dialogues — v0.42

Verrouillage des commandes de fond pendant les panneaux : prévention des redémarrages et changements de vitesse involontaires au clavier. [Détail](design/Commandes_modales_v042.md). 14 156 contrôles Godot, 9 tests Python et 46 lancements Windows réussis.

## Identifier la version du jeu — v0.43

La fenêtre et le bas de l’écran indiquent la version embarquée. Les contrôles du ZIP comparent aussi cette version à la notice, au nom du dossier et aux rapports de partie. [Détail](design/Identification_version_v043.md)

## Clavier pendant les changements de phase — v0.44

Au lancement manuel ou automatique, une commande devenue inactive libère le focus. Une commande encore disponible le conserve. [Détail](design/Focus_combat_v044.md).

## Cohérence des sources compilées — v0.45

L’export compare les empreintes des sources avant et après compilation puis avant archivage. Le vérificateur du paquet accepte `--source-project` pour comparer dix fichiers au projet local. [Protocole](design/Sources_compilation_v045.md).

## Rejouer un rapport de partie — v0.46

Un outil réservé au développement vérifie les décisions d’un rapport JSON contre le modèle actuel : offres, dépenses, vagues, composition, contributions et résultat. Il ne modifie pas le fichier. [Utilisation et limites](design/Rejeu_rapports_v046.md).

## Calcul des comparaisons de bonus — v0.47

Les trois comparaisons ne sont plus recalculées à chaque image pendant la lecture. Les données pertinentes restent surveillées pour conserver des textes actuels. [Mesure et vérification](design/Calcul_bonus_v047.md).

## Fermer un panneau avec Échap — v0.48

Échap ferme le récapitulatif ou le bilan, et annule une spécialisation sans payer. Les choix de faction et de bonus obligatoires restent ouverts. [Règles et vérifications](design/Echap_panneaux_v048.md).

## Consignes selon la situation — v0.49

Le panneau de gauche indique quoi faire à chaque étape et cesse de parler de première vague après celle-ci. Le compteur précise « Combat simulé » ; une aide au survol explique les vitesses et les temps exclus. [Détail](design/Consignes_contextuelles_v049.md).

## Suivi du boss final — v0.50

Le rapport et l’aide de la vague 10 distinguent boss éliminé, arrivé à la forteresse, encore en chemin ou non rencontré. Les temps mesurés restent des temps de simulation. [Détail et limites](design/Releve_boss_v050.md).

## Voir le temps de préparation — v0.51

Une barre suit les 30 secondes restantes, se fige pendant une lecture suspendue et disparaît au départ de la vague. Le texte du bouton reste disponible. [Détail](design/Barre_preparation_v051.md).

## Présentation de la carte — v0.52

La carte gagne en relief et en détails de décor. Géométrie, emplacements, portées et statistiques conservent leurs valeurs. Les visuels restent temporaires. [Détail](design/Presentation_carte_v052.md).

## Infobulle après lancement — v0.53

Après activation sous la souris, l’aide du bouton de lancement attend que la souris le quitte. Revenir dessus permet de consulter la composition. [Vérification](design/Infobulle_lancement_v053.md).

## Choisir sans tout lire — v0.54

Les cartes de bonus présentent le gain, les unités concernées et les conditions utiles. Voir les détails ouvre la règle complète et la comparaison réelle. Les spécialisations affichent leur rôle ; Voir les chiffres révèle les valeurs exactes. [Présentation et vérifications](design/Lecture_progressive_v054.md).

## Défenseurs reconnaissables — v0.55

Les six défenseurs ont des proportions, visages et équipements distincts. Un bref recul accompagne leurs attaques réelles. Dessins originaux produits par le jeu, sans changement des statistiques. [Présentation et contrôles](design/Presentation_defenseurs_v055.md).

## Projectiles et impacts — v0.56

Les six classes ont des projectiles distincts, des points de départ sur leur équipement et des impacts adaptés. Les marques secondaires correspondent aux victimes réellement enregistrées ; le trajet visuel ne retarde pas les dégâts. [Présentation et contrôles](design/Presentation_attaques_v056.md).

## Recrutement et amélioration — v0.57

Les fiches mettent en avant le rôle, les dégâts utiles et le prix. Voir les chiffres affiche les cadences, portées et règles complètes. Les portées et partenaires restent prévisualisés dans les deux vues. [Présentation et contrôles](design/Lecture_recrutement_v057.md).

## Bilan essentiel — v0.58

Le premier bilan affiche le résultat, les chiffres clés et les moments où la forteresse a perdu des PV. Vagues et Défenseurs conservent les tableaux détaillés. [Présentation et contrôles](design/Bilan_essentiel_v058.md).

## Ennemis reconnaissables — v0.59

Les huit profils ont des silhouettes, visages et équipements distincts dans la même direction cartoon que les défenseurs. Statistiques et règles inchangées. [Présentation et contrôles](design/Presentation_ennemis_v059.md).

## Personnages Horde illustrés — v0.60

Le troll, le gobelin et le chaman utilisent les PNG transparents issus de la planche validée. Leur ancrage, leurs tailles et le filtrage sont adaptés au plateau. [Assets, limites et consignes de génération](design/Assets_Horde_v060.md).
