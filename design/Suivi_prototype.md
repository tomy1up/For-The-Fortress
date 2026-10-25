# Suivi du prototype

État du 25 octobre 2026 — prototype v0.44, GDD principal v0.14, décisions d’enchaînement v0.22 et de préparation v0.23 (30 secondes).

## Périmètre réalisé

Les dix vagues sont jouables avec les deux factions, les niveaux, les douze spécialisations, les bonus roguelite et les douze synergies activables. Les deux campagnes de référence atteignent une victoire au budget normal ; la matrice comparative et les essais à trois types constants de L6 sont consignés. Un [premier retour humain Horde](Retours_joueurs.md) est recueilli ; les essais restent à compléter.

| Lot du cahier | État | Preuve ou travail restant |
| --- | --- | --- |
| L0 Préparer | Réalisé pour Windows x86_64 | Projet source et export release autonome démarrables ; ZIP vérifié hors projet |
| L1 Traversée du Gué | Réalisé | Tracé 28 unités, six emplacements, déplacements, arrivées et PV |
| L2 Boucle minimale | Réalisé | Achats et ventes Alliance N1, tirs, récompenses, vague 1 complète, retour entre les vagues |
| L3 Couvrir le combat | Réalisé | Six défenseurs, huit profils, effets, ordre des événements et campagne intégrés |
| L4 Progression | Réalisé | N1 à N4, douze branches, choix atomique et dépenses historiques |
| L5 Partie complète | Réalisé | Dix vagues, trois choix, douze bonus, douze synergies ; victoires et défaites testées |
| L6 Essais et équilibrage | Partiel | Matrice et comparaisons d’améliorations consignées ; essais humains encore nécessaires |

## Référence historique v0.15

- 87 contrôles du modèle réussis, dont 30 couvertures comparées aux valeurs de la section 19 du GDD.
- 30 contrôles d’interface réussis ; aucun message d’erreur dans les exécutions finales.
- Boutique, combat et fin de vague rendus par Godot et inspectés visuellement.
- Tirs à l’entrée de portée, cadences, priorités, fractions de dégâts et arrivée après tirs vérifiés par des situations contrôlées.
- Même journal de combat dans le scénario de référence avec grands pas de temps, à ×1 et à ×2.

### Scénario de référence exécuté

| Paramètre | Résultat |
| --- | --- |
| Composition | Archer E1, Arbalétrier E2, tous deux N1, sans bonus ni synergies |
| Dépenses avant lancement | 125 or ; solde 25 |
| Vague | 10 Pillards de 40 PV, tous les 2,5 s, premier à t = 0 |
| Résolution | 10 éliminés, 0 arrivés, 30 tirs principaux |
| Forteresse | 20 PV restants |
| Or | 55 : 25 + 10 × 3, sans prime de vague |
| Fin | 23,5 secondes de jeu, après résolution du dernier ennemi |

Sans défenseurs : dix arrivées, 10 PV restants, 150 or inchangés, fin à 50,5 s de jeu. Les deux résultats sont contrôlés automatiquement. Ils ne valident pas l’équilibre commercial ni l’ensemble des compositions.

## Conventions d’implémentation

Les prochains événements sont les apparitions, ticks de malédiction, entrées de portée, tirs disponibles et arrivées. Le modèle avance à leur instant, puis jusqu’au temps demandé pour l’affichage ; la cadence ne dépend pas de la fréquence des images.

Les instants, progressions et bornes de couverture sont des float 64 bits. Les calculs de séparation entre ennemis restent aussi en float 64 bits ; les Vector2 servent aux positions de référence et à l’affichage. La tolérance 10⁻⁹ est réservée aux comparaisons temporelles et aux bornes de portée ; les rayons et rebonds conservent leur comparaison strictement inférieure à 1. Aucun arrondi de dégâts par impact n’est ajouté.

Le niveau 1, les prix et les valeurs de dégâts restent ceux du GDD. Les synergies sont volontairement absentes du premier essai de combat N1, conformément à la référence de test déjà approuvée. Les documents Word et Markdown du GDD ne sont pas révisés, car cette livraison implémente leurs règles sans en changer la conception.

## Résultats techniques v0.16

199 contrôles réussis : 87 pour les règles Alliance et la géométrie, 37 pour l’interface, 75 pour la Horde et les ennemis. Un contrôle documentaire distinct confirme 24 statistiques des défenseurs et 32 statistiques des ennemis. Les scénarios graphiques de choix de faction, boutique, combat, fin de vague, chaman et catalogue ont été inspectés.

Le modèle exécute les sept archétypes et le boss avec leurs vitesses, dégâts de forteresse et primes propres. Les scénarios mélangés de contrôle n’ajoutent pas de nouvelles vagues au jeu. Seule la vague 1 est actuellement accessible par l’interface.

### Référence Horde exécutée

Troll E1 + Sapeur E2 au N1 : 125 or investis, 25 au lancement. Les dix Pillards sont éliminés sans arrivée ; fin à 24,5 s, 20 PV et 55 or restants. Cette différence de durée avec la référence Alliance dépend des portées et cadences ; elle n’établit pas un équilibre global.

### Cas de référence du GDD

| Cas | Vérification exécutée |
| --- | --- |
| C-01 | Cible disponible à 0,3 s ; premier tir et prochain délai à 1,3 s |
| C-02 | Plus de cible à 1,3 s ; acquisition à 1,8 s, prochain délai à 2,8 s, aucun rattrapage |
| C-03 | Même progression, ordre d’apparition prioritaire |
| C-04 | Égalités secondaires départagées par progression puis ancienneté ; comparateur et situations d’explosion contrôlés |
| C-05 | Deux tirs visant la même cible fragile, aucun transfert des dégâts et une seule récompense |
| C-06 | Deux ticks continuent hors portée tant que la cible est présente |
| C-07 | Ancien tick à 2 s avant le nouveau tir ; nouvelles échéances à 3 et 4 s |
| C-08 | Tick létal au moment de l’arrivée, récompense unique et aucun dégât de forteresse |
| C-09 | Deux Brutes arrivant ensemble contre 3 PV : dégâts cumulés, PV à zéro et défaite |
| C-10 | Portée principale inclusive et rayon secondaire strict |
| C-11 | Fin de vague immédiate malgré les traits visuels ; effets annulés sur le mort |
| C-12 | Priorité de la défaite sur la fin de vague vérifiée ; la victoire de campagne en vague 10 reste à intégrer et tester en L5 |

Des contrôles supplémentaires couvrent deux sources de malédiction indépendantes, le renouvellement qui annule les anciennes échéances et l’élimination par tick avant le choix des nouveaux tirs. La chronologie d’un essai mêlant les huit profils et les trois défenseurs Horde est identique à grands pas, à ×1 et à ×2.

## Prochaine étape

L6 : essais de jeu, compositions, comparaison des factions et propositions d’équilibrage documentées.

## Livraison L4 — v0.17, 21 octobre 2026

Progression des six défenseurs jusqu’au N4 et douze branches implémentées à partir du GDD v0.14, sections 12 à 17, 37 et 41. Aucun changement de règle ni nouveau contenu de conception. Les réglages numériques gardent leur statut H.

Le choix de branche applique le N4 et débite 150 or en une opération. L’annulation conserve le N3 et son or ; les commandes de jeu sont bloquées derrière le dialogue. La confirmation périmée ne modifie pas un nouvel exemplaire installé au même emplacement. Chaque copie conserve son niveau, sa branche, son identité et ses paiements ; le quota reste de deux par type.

607 contrôles réussis : les 199 précédents et 408 contrôles supplémentaires sur les multiplicateurs, les 84 champs des douze fiches finales, les coûts, les remboursements, les effets en combat, les portées recalculées, les ricochets successifs, les ticks spécialisés et les six dialogues. Les 56 valeurs de base sont toujours comparées au GDD. Les six fenêtres N4, une inspection N2 et une inspection N4 ont été rendues et inspectées.

Les investissements N4 sans réduction de 350/375/400 rendent 245/262/280 or ; l’arrondi s’effectue sur le total par exemplaire. Les statistiques de branche sont des valeurs finales et ne reçoivent pas une nouvelle multiplication de niveau.

La partie reste limitée à la vague 1 : le budget normal autorise N2 seulement. N3 et N4 sont testés avec budget imposé dans des scénarios de vérification explicitement identifiés. Aucun ajout d’or au parcours normal ; aucune conclusion sur l’équilibre des dix vagues. L4 est réalisé sur ce périmètre ; l’intégration à la campagne relève de L5. L0 reste partiel, sans export Windows autonome.

Les GDD Word et Markdown restent en v0.14. Prochaine livraison : L5 (campagne, bonus et synergies), suivie des essais de campagne.

## Livraison L5 — v0.18, 21 octobre 2026

Campagne de dix vagues implémentée selon le GDD v0.14 : 26 groupes, 182 ennemis, 10 944 PV bruts et 770 or de récompenses au maximum. Trois choix obligatoires après les vagues 3, 6 et 9, catalogue de douze bonus, six associations de proximité et six de spécialisations. Le volet racial reste différé. Aucun réglage de conception n’a été changé.

969 contrôles réussis : 607 précédents, références sans bonus ni synergies explicitement isolées, et 362 pour la campagne active. Les contrôles de base et de branches restent concordants avec le GDD. Les deux campagnes de contrôle à six N4 vérifient les 182 éliminations et 770 or ; elles utilisent un budget imposé. Les deux références au budget normal (graine 42) gagnent avec 14 et 12 PV, sans or ni unité ajoutés. Voir [le protocole et les résultats](Resultats_campagne_v018.md).

Le modèle conserve unités, dépenses, or, PV et bonus entre vagues ; les délais, compteurs locaux, malédictions et horaires sont remis à zéro pour la suivante. La victoire n’est possible qu’après résolution de la vague 10 ; la défaite reste prioritaire. Aucun achat n’est permis après une fin de partie.

Les offres ont trois codes distincts et n’excluent ensuite que le choix effectué. Les composantes de dégâts additionnent les pourcentages applicables ; R-12 est évalué sur chaque victime. La cadence du chaman reste inchangée. La maçonnerie augmente une seule fois PV actuels et maximum. Prix réduits arrondis au supérieur, remboursements arrondis au inférieur sur l’investissement réel.

Les quatre pages du catalogue de bonus, le choix après vague 3, le récapitulatif, le combat tardif et les victoires ont été rendus et inspectés. Les retours à la ligne des textes ont été rendus explicites pour éviter un chevauchement des compteurs sous Windows.

L5 est réalisé. L6 reste à mener : compréhension par des joueurs, diversité des stratégies, comparaisons à budget et offres contrôlés, durées avec préparation, anomalies et propositions de réglage H. L0 demeure partiel sans export Windows autonome. Les documents de conception restent en v0.14 ; cette livraison implémente leurs règles.

## Livraison L6 initiale — v0.19, 22 octobre 2026

1 728 parties automatisées au budget normal : deux factions, quatre placements, trois politiques de dépenses, trois priorités de bonus, deux choix de branches et douze graines. Aucun paramètre de gameplay changé. Résultats, protocole, limites et relevés versionnés dans [le bilan](Bilan_equilibrage_v019.md) et [les données](essais/README.md).

109 111 vérifications d’intégrité sans échec pendant ces essais ; 969 contrôles de régression toujours réussis. La politique renforts gagne ses 576 essais ; la politique référence 399/576 ; la spécialisation des deux unités initiales 82/576. Le nombre de types et la couverture changent avec les politiques : aucune conclusion isolée sur le prix des améliorations. 54 parties activent une association N4 réellement financée.

L6 reste partiel. La [fiche d’essai joueur](Fiche_essai_joueur.md) est prête mais aucun retour humain n’est inventé. Prochain travail : essais humains et comparaison des politiques avec les mêmes trois types, positions et budget. Les réglages H sont conservés ; toute proposition ultérieure devra préciser le changement et sa mesure. L0 reste partiel sans export autonome. Les documents de conception restent en v0.14.

## Livraison d’essais appariés — v0.20, 22 octobre 2026

96 préparations communes après vague 4, avec trois types N1 payés au budget normal. 384 essais isolés comparent l’épargne et trois dépenses N2 identiques de 50 or. 768 continuations conservent ces trois types et leurs positions en faisant varier politique d’amélioration et ensemble de branches. Les offres restent identiques aux choix communs ; les revenus futurs varient naturellement avec les éliminations.

51 801 vérifications d’intégrité réussies, dont copie profonde de l’état et du générateur, original préservé, positions et types conservés, conservation de l’or et transitions. Les 969 contrôles de régression passent. Le [bilan](Bilan_ameliorations_v020.md) et les relevés compressés sont versionnés.

L’amélioration N2 réduit les arrivées dans 53 à 55 préfixes sur 96 selon l’unité choisie, sans aggravation dans cette vague isolée. Les continuations equilibre et reference gagnent 152 et 150 fois sur 192 ; la priorité aux dégâts de groupe dépend fortement du placement. reference et priorite_0 donnent les mêmes 192 trajectoires et ne constituent pas deux confirmations indépendantes.

Décision : conserver coûts et statistiques H. Aucun fichier de gameplay ni GDD modifié. L6 reste partiel, sans observations humaines ; L0 reste partiel sans export autonome. Prochaine réalisation : préparer la distribution Windows pour faciliter l’essai joueur, puis consigner compréhension et durées avec la fiche existante.

## Livraison Windows autonome — v0.21, 22 octobre 2026

Export release Windows x86_64, données intégrées à l’EXE, sans console ni éditeur. Templates officiels 4.7.2 téléchargés et SHA-512 vérifié. Preset, script PowerShell de reconstruction, génération des notices de licences et vérificateur d’archive versionnés. Le ZIP et son SHA-256 sont livrés avec la version GitHub ; dist est exclu de Git.

Après extraction dans un dossier de contrôle séparé, cinq lancements sans erreur : démarrage headless, choix de faction, choix roguelite, victoires Alliance et Horde. Les quatre captures ont été inspectées. Les résultats de référence restent 14 PV/192 or et 12 PV/189 or ; les 969 contrôles de régression passent. Voir [le compte rendu](Distribution_Windows_v021.md).

Un premier paquet incomplet a été rejeté par le test hors projet. Le preset sélectionne désormais explicitement la scène et les cinq scripts runtime. Le paquet corrigé est celui identifié par le SHA-256 du compte rendu. Aucun réglage de gameplay changé ; seule la version de projet passe à 0.21.

L0 est réalisé sur ce périmètre Windows x86_64. L6 reste partiel : essais humains, compréhension et durées encore à recueillir. Le prototype n’est pas signé et n’a pas été testé sur un parc de machines. Le GDD reste en v0.14.

## Enchaînement automatique — v0.22, 23 octobre 2026

Demande explicite du porteur du projet : après le premier lancement manuel, succession automatique des vagues avec compte à rebours ; durée ensuite précisée à 60 secondes. La [décision D-2026-10-23-01](Decision_enchainement_v022.md) remplace le relancement manuel systématique de la conception précédente. Le GDD principal Word et Markdown restent ensemble en v0.14 ; ce complément doit être intégré lors de leur prochaine révision commune.

60 secondes réelles, indépendantes du ×2. Choix roguelite sans limite puis délai complet ; choix N4 et lecture du récapitulatif d’améliorations suspendent le temps restant de préparation. Achats et ventes restent possibles pendant le délai. Départ anticipé possible. Aucune reprise après victoire, défaite ou réinitialisation ; la vague 1 reste manuelle au nouvel essai.

1 075 contrôles réussis, dont 106 ciblés. Deux campagnes financées normalement, un seul premier départ manuel, résultats de référence conservés. Nouvelle archive Windows : six lancements hors projet, captures du compte à rebours et du choix inspectées. Aucune modification des nombres de combat ; le boss à 900 PV reste une proposition non appliquée. Les essais humains restent à compléter sur ce nouveau rythme.

## Lisibilité des synergies — v0.24, 23 octobre 2026

Les essais humains Horde et les clarifications suivantes sont consignés dans [les retours joueurs](Retours_joueurs.md). Le joueur apprécie mieux la finale et souligne l’influence des bonus choisis ; aucun réglage d’équilibrage n’est modifié. La v0.23 a réduit le délai à 30 secondes et clarifié les libellés de progression.

La v0.24 rend les associations inspectables en clair : partenaires actifs reliés à l’unité sélectionnée, traits dorés pour la proximité et bleus pour les spécialisations, aide au survol avec noms, emplacements, conditions et gains. La recherche des partenaires est commune au calcul des bonus et à leur affichage. Voir [le compte rendu](Lisibilite_synergies_v024.md).

1 198 contrôles réussis, dont 123 nouveaux ; résultats des campagnes de référence inchangés. Huit lancements du paquet Windows extrait vérifiés, dont les vues de synergies en combat des deux factions. Les aides et les liens sont inspectés visuellement. Le délai reste 30 secondes et le GDD principal reste en v0.14. L6 demeure partiel : élargir les essais humains aux compositions et factions avant toute modification d’équilibrage ou extension du contenu.

## Aperçu de portée avant achat — v0.25, 23 octobre 2026

À la demande du joueur, sélectionner un emplacement libre puis survoler un recrutement montre sa portée et la portion du chemin couverte, avant toute dépense. Le focus clavier permet aussi cette comparaison. La portée inclut les bonus acquis et les synergies de proximité applicables à la recrue. Les interdictions d’achat demeurent effectives ; le décompte continue pendant la comparaison.

1 606 contrôles réussis, dont 408 dédiés aux aperçus et à leur conformité à l’achat réel. Dix lancements du paquet extrait vérifiés ; aperçus Alliance et des trois unités Horde inspectés. Aucun changement d’équilibrage. Voir [la fiche](Apercu_achat_v025.md) et [le rapport d’export](Distribution_Windows_v025.json).

## Comparaison des améliorations — v0.26, 23 octobre 2026

Le survol ou le focus d’une amélioration affiche les valeurs actuelles et prévues, avec la portée principale future en bleu. Les spécialisations sont présentées dans un panneau latéral laissant la carte visible ; chaque branche compare ses statistiques au niveau 3 et prévisualise sa portée au survol de son bouton. Les paiements, conditions d’activation et horloges restent inchangés.

1 963 contrôles réussis, dont 357 nouveaux. Douze lancements du paquet extrait vérifiés, six vues de spécialisations inspectées. Les résultats des campagnes sont conservés. Voir [la fiche](Comparaison_ameliorations_v026.md) et [le rapport d’export](Distribution_Windows_v026.json).

## Inspection des ennemis — v0.27, 23 octobre 2026

Le survol d’un ennemi montre nom, PV, dégâts d’arrivée, récompense et malédiction éventuelle. L’ennemi est repéré sur la carte, le boss est identifié et une arrivée actuellement fatale est signalée. La lecture ne modifie ni le combat ni la sélection du défenseur et ne suspend pas le temps.

2 041 contrôles réussis, dont 78 nouveaux. Quatorze lancements du paquet extrait vérifiés ; fiches de l’ennemi ordinaire et du boss inspectées. Aucun changement d’équilibrage. Voir [la fiche](Inspection_ennemis_v027.md) et [le rapport d’export](Distribution_Windows_v027.json). Les essais humains et la comparaison des factions restent à élargir.

## Bilan de fin de partie — v0.28, 23 octobre 2026

Le bouton Bilan, à côté de Rejouer après victoire ou défaite, affiche résultats et temps simulés par vague, défense finale et bonus choisis. Le survol des lignes donne le contexte au départ des vagues. Les relevés sont conservés en mémoire jusqu’au nouvel essai, sans sauvegarde ni progression persistante.

2 237 contrôles réussis, dont 196 nouveaux. Seize lancements du paquet extrait vérifiés ; bilans de victoire et de défaite inspectés. Les références des deux factions et l’équilibrage restent inchangés. Voir [la fiche](Bilan_partie_v028.md) et [le rapport d’export](Distribution_Windows_v028.json). Ce bilan facilite les prochains retours humains par vague.

## Prévision des vagues — v0.29, 23 octobre 2026

La préparation affiche la prochaine vague, ses groupes, leurs quantités, PV et dangers, ainsi que le revenu maximal conditionnel. Le survol détaille les horaires et intervalles à vitesse ×1, avec rappel de l’effet du ×2. La fiche suit le délai existant et se masque dans les autres phases et fenêtres modales.

2 639 contrôles réussis, dont 402 nouveaux. Dix-huit lancements du paquet extrait vérifiés ; préparations de la vague 9 et du boss et aide des horaires inspectées. Aucun changement d’équilibrage. Voir [la fiche](Prevision_vagues_v029.md) et [le rapport d’export](Distribution_Windows_v029.json).

## v0.30 — Repères de combat

Explosions projetées au sol, palette distincte mage/sapeur, ricochets fléchés et marque de malédiction. Le modèle de combat reste identique. 2 685 contrôles réussis, dont 46 ciblés, et 22 démarrages du paquet Windows. Voir [le relevé détaillé](Lisibilite_combats_v030.md).

## v0.31 — Aide au recrutement, 24 octobre 2026

Le survol et le focus des recrues affichent attaques, rôle, effets et prix effectifs. Les infobulles complètent le ciblage et les limites des effets ; le refus d’achat reste distinct du contenu informatif. 2 781 contrôles réussis, dont 96 nouveaux ; 26 lancements du paquet Windows contrôlés. [Détail de la réalisation](Aide_recrutement_v031.md).

## v0.32 — Signal des percées, 24 octobre 2026

Le contrôleur compare les arrivées et PV avant/après l’avance du modèle. La vue affiche les pertes réelles pendant 2,5 secondes réelles, sans modifier le combat ou le délai. 2 822 contrôles réussis, dont 41 ciblés ; 27 lancements Windows contrôlés. [Détail de la réalisation](Signal_percees_v032.md).

## v0.33 — Comparaison des bonus, 24 octobre 2026

Projection sans mutation des douze bonus : valeurs avant/après sur la défense, PV, prix et conditions de grande cible. Calculs communs au jeu réel ; listes défilantes et récapitulatif acquis compact. 11 574 contrôles réussis, dont 8 752 ciblés ; 30 lancements Windows contrôlés. [Relevé détaillé](Comparaison_bonus_v033.md).

## v0.34 — Cohérence des factions, 24 octobre 2026

Descriptions de bonus centralisées par camp, synergies limitées aux attaques du bénéficiaire et garde explicite des améliorations adverses. 12 303 contrôles réussis, dont 729 ciblés ; 32 lancements Windows contrôlés. [Relevé détaillé](Coherence_factions_v034.md).

## v0.35 — Lisibilité, essais PC et ×10 temporaire

Dégâts à la forteresse explicités, nombres lisibles, montants économiques détaillés, routes couvertes et silhouettes renforcées. Défilement remis à zéro au bon contexte. ×10 debug ajouté sur demande explicite, sans accélérer les préparations. 12 578 contrôles et 36 lancements Windows. [Détail](Lisibilite_et_debug_v035.md) · [Essais interactifs agent](Essais_interactifs_v035.md).

## v0.36 — Journal et rapports locaux, 24 octobre 2026

Décisions acceptées, achats, améliorations, ventes, offres et choix roguelite conservés en mémoire. Export Markdown et JSON depuis le bilan, sans tirage supplémentaire ni reprise de partie. 12 717 contrôles réussis et 38 lancements Windows. [Détail et limites](Rapports_partie_v036.md).

## v0.37 — Anticiper les synergies, 25 octobre 2026

Liens bleus pointillés et détail des partenaires/gains avant recrutement et spécialisation, fondés sur les associations existantes et une unité candidate sans mutation. 13 879 contrôles réussis, dont 1 162 ciblés ; 42 lancements Windows et vérification interactive des deux factions sur l’écran de droite. [Détail](Apercu_synergies_v037.md).

## v0.38 — Mesurer l’activité, 25 octobre 2026

Observation des impacts et des PV retirés, répartition proportionnelle des coups simultanés et suivi par recrue et par vague. Onglet Défenseurs dans le bilan, avec conservation des unités vendues et export JSON schéma 2/Markdown. Aucun changement de transaction de combat ou de statistique. 13 952 contrôles réussis, dont 73 ciblés ; 45 lancements Windows vérifiés sur l’écran de droite. [Détail](Activite_defenseurs_v038.md).

## L6 — Matrice instrumentée après v0.38

1 728 scénarios rejoués, 356 868 audits sans anomalie et concordance de tous les champs historiques avec le relevé v0.19. Suivi séparé de la mort du boss et de la résolution de la vague : 1 060 finales atteintes, 1 059 boss éliminés et deux défaites malgré le boss éliminé. Aucun réglage modifié. [Résultats, limites et données](Bilan_finale_v038.md). Le paquet Windows v0.38 reste inchangé ; ce complément concerne les outils d’essai et la documentation.

## v0.39 — Jauge du boss, 25 octobre 2026

Vie et dégâts à la forteresse visibles sans survol, avec signal de défaite conditionnel et masquage hors combat ou derrière les écrans de choix. 14 004 contrôles réussis, dont 52 ciblés, et 46 lancements Windows vérifiés sur l’écran de droite. [Détail](Suivi_boss_v039.md). Aucun réglage modifié.

## v0.40 — Vérification complète versionnée, 25 octobre 2026

Lanceur sans fenêtre, découverte des suites, contrôle des résumés/erreurs, journaux JSON, empreintes des sources et contrats du GDD inclus dans le dépôt. 23 suites et 14 004 contrôles Godot, 9 tests Python ; filtres, appel depuis un autre répertoire et mauvais moteur vérifiés. 46 lancements Windows. [Instructions et preuve](Verification_reproductible_v040.md). Comportements du jeu conservés.

## v0.41 — Sélection au clavier, 25 octobre 2026

Sélection E1–E6 commune au clic et aux touches, prise en compte AZERTY/pavé numérique, garde des panneaux et conservation des ressources et délais. 14 072 contrôles Godot dont 68 ciblés, 9 tests Python et 46 lancements Windows. Test interactif sur le second écran. [Détail](Selection_clavier_v041.md).

## v0.42 — Protection des commandes de fond, 25 octobre 2026

Défaut reproduit de redémarrage derrière un choix. Focus et activation des commandes de fond bloqués pendant les panneaux ; boutons du panneau et reprise des commandes vérifiés. 14 156 contrôles Godot, dont 76 dédiés et huit extensions de contrôles existants, 9 tests Python et 46 lancements Windows. [Détail](Commandes_modales_v042.md).

## v0.43 — Identification de la version, 25 octobre 2026

Version embarquée affichée dans le titre et le pied de fenêtre, conservée après redémarrage. Vérification de concordance entre dossier, notice, version du programme capturé et rapports. 25 suites, 14 159 contrôles Godot et 9 tests Python réussis. [Détail](Identification_version_v043.md).

## v0.44 — Focus pendant les changements de phase, 25 octobre 2026

Défaut reproduit : le bouton de lancement désactivé gardait le focus pendant le combat. Le focus est désormais rendu à une commande disponible, sans déplacer une sélection encore valide. 25 suites, 14 171 contrôles Godot, dont 12 ajouts dédiés aux deux factions, et 9 tests Python réussis. [Détail](Focus_combat_v044.md).
