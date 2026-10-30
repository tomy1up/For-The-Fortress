# Suivi du prototype

État du 31 octobre 2026 — prototype v0.98, GDD principal v0.15 et fiches complémentaires, décisions d’enchaînement v0.22 et de préparation v0.23 (30 secondes).

## Périmètre réalisé

**Prochain lot cadré par le porteur du projet, le 26 octobre 2026** : présentation, lisibilité des encarts et fantasy cartoon. Décision historique : aucune progression permanente dans ce lot de présentation ; évolution demandée le 27 octobre et livrée à titre de prototype en v0.67. Proposition de premier chantier : hiérarchiser le choix des bonus, puis les spécialisations. [Décisions validées et proposition de réalisation](Orientation_presentation_2026-10-26.md).

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

## v0.45 — Sources de compilation, 25 octobre 2026

Empreintes des dix sources de distribution relevées avant export et comparées après compilation puis avant archivage. Le manifeste conserve ce relevé initial. Vérification locale du paquet par --source-project. 25 suites, 14 171 contrôles Godot et 15 tests Python réussis, dont six tests de sources. [Détail](Sources_compilation_v045.md).

## v0.46 — Rejeu des rapports, 25 octobre 2026

Outil de rejeu en lecture seule pour rapports au format 2, non embarqué dans le jeu distribué. Vérifie le journal et le résultat contre les règles actuelles, et signale les différences de version. 26 suites, 14 213 contrôles Godot, dont 42 dédiés, et 15 tests Python réussis. Deux rapports issus du paquet Windows v0.45 rejoués sans modification. [Détail](Rejeu_rapports_v046.md).

## v0.47 — Calcul des comparaisons de bonus, 25 octobre 2026

Trois comparaisons réutilisées pendant la lecture, invalidées quand faction, vague, offres, bonus, défense, budget, PV ou activation des synergies changent. 27 suites, 14 283 contrôles Godot dont 70 dédiés, 15 tests Python réussis. Mesure locale sans rendu : mise à jour du panneau environ 1,35–1,40 ms avant, 0,23–0,25 ms après sur six N4 à budget imposé. [Limites et protocole](Calcul_bonus_v047.md).

## v0.48 — Échap dans les panneaux, 25 octobre 2026

Fermeture du récapitulatif et du bilan, annulation sans dépense de la spécialisation. Choix obligatoires conservés. 28 suites, 14 313 contrôles Godot dont 30 dédiés, 15 tests Python réussis. [Détail](Echap_panneaux_v048.md).

## v0.49 — Consignes contextuelles, 26 octobre 2026

Le texte de gauche suit les étapes de partie, sans instruction de première vague en combat ou en fin de partie. Compteur renommé Combat simulé et expliqué au survol. Douze textes vérifiés à 60 px de haut sur 76 et 213 px de largeur maximale sur 238. 28 suites, 14 313 contrôles Godot et 15 tests Python réussis. [Détail](Consignes_contextuelles_v049.md).

## v0.50 — Relevé du boss, 26 octobre 2026

Observation de l’issue du boss, de son temps de résolution et des PV retirés. Lecture dans le rapport et au survol de la vague 10 ; aucun changement du modèle de combat. Champ optionnel ajouté au format 2, anciens rapports acceptés par le rejeu. 29 suites, 14 339 contrôles Godot dont 26 dédiés, 15 tests Python réussis. [Détail](Releve_boss_v050.md).

## v0.51 — Barre de préparation, 26 octobre 2026

Barre proportionnelle au délai réel restant, sous le bouton de lancement. Lecture seule, sans clic ni focus ; teinte de pause et accent dans les cinq dernières secondes. 29 suites, 14 350 contrôles Godot, dont onze ajouts à la suite d’enchaînement, 15 tests Python réussis. [Détail](Barre_preparation_v051.md).

## v0.52 — Présentation de la carte, 26 octobre 2026

Relief du plateau, contraste des berges et de l’eau, garde-corps du pont, étages de feuillage et détails de la porte. Dessin seul, sans collision ni nouvelle ressource externe. 29 suites, 14 350 contrôles Godot et 15 tests Python réussis. [Détail](Presentation_carte_v052.md).

## v0.53 — Infobulle après lancement, 26 octobre 2026

Comportement observé dans la partie native v0.52 : l’aide réapparaissait sous la souris après le départ et recouvrait l’interface. Lancement sous le pointeur : aide masquée jusqu’à sa sortie, puis consultable au retour. 29 suites, 14 350 contrôles Godot et 15 tests Python réussis. [Détail](Infobulle_lancement_v053.md).

## v0.54 — Lecture progressive des choix, 26 octobre 2026

Réalisation du premier lot demandé : trois cartes de bonus condensées et détails facultatifs, y compris pour les bonus acquis ; rôles des spécialisations et chiffres sur demande. 30 suites, 14 558 contrôles Godot dont 208 nouveaux, et 15 tests Python réussis. Règles, statistiques et pauses conservées. [Détail](Lecture_progressive_v054.md).

## v0.55 — Silhouettes et attaques des défenseurs, 26 octobre 2026

Les six défenseurs possèdent des proportions et équipements distinctifs, avec contours, ombres et accents de spécialisation. Leur mouvement bref lit uniquement les tirs réellement résolus. 31 suites, 14 621 contrôles Godot dont 63 nouveaux, 15 tests Python et contrats du GDD réussis. Statistiques, portées, ciblage et progression inchangés. [Détail](Presentation_defenseurs_v055.md).

## v0.56 — Projectiles et impacts, 26 octobre 2026

Formes distinctes pour les six attaques, points de départ sur les équipements, explosions discrètes et marques sur les véritables victimes. Habillage de 0,12 seconde simulée, impacts immédiats et extinction en 0,32 seconde. 32 suites, 14 681 contrôles Godot dont 60 nouveaux, 15 tests Python et contrats du GDD réussis. Aucun changement de simulation. [Détail](Presentation_attaques_v056.md).

## v0.57 — Lecture du recrutement et des améliorations, 26 octobre 2026

Fiches par défaut centrées sur le rôle et les dégâts ; aperçus d’amélioration centrés sur les gains et le prix ; aides de recrutement condensées. Voir les chiffres conserve les valeurs et règles exactes. 33 suites, 14 819 contrôles Godot dont 138 nouveaux, 15 tests Python et contrats du GDD réussis. Aucune modification de simulation ou de pause. [Détail](Lecture_recrutement_v057.md).

## v0.58 — Bilan essentiel, 26 octobre 2026

Une première vue courte présente résultat, PV, passés, or gagné, premières pertes, plus fortes pertes et statut du boss. Les tableaux de vagues et de contributions restent disponibles dans leurs onglets. 34 suites, 14 855 contrôles Godot dont 36 nouveaux, 15 tests Python et contrats du GDD réussis. Aucun changement des rapports ou de la simulation. [Détail](Bilan_essentiel_v058.md).

## v0.59 — Silhouettes des ennemis, 26 octobre 2026

Les huit profils reçoivent des corps et équipements cartoon plus distincts. Les jauges sont légèrement relevées pour dégager les casques. Échelles, ordre de dessin, détection au survol, déplacements et caractéristiques conservés. 34 suites, 14 855 contrôles Godot, 15 tests Python et contrats du GDD réussis. [Détail](Presentation_ennemis_v059.md).

## v0.60 — Assets Horde transparents, 27 octobre 2026

Trois PNG individuels intégrés au plateau dans le style validé, proportions conservées, ancrage des pieds, mipmaps et badges existants. Une pose par classe avec recul au tir ; armes non animées indépendamment. 35 suites, 14 876 contrôles Godot et 16 tests Python réussis. Les 17 sources contrôlées incluent désormais les images et leurs paramètres d’import. [Détail et prompts](Assets_Horde_v060.md).

## v0.61 — Assets Alliance transparents, 27 octobre 2026

Archer elfe, arbalétrier nain et mage humain illustrés dans le style cartoon retenu. Rendu commun aux six défenseurs, cadres et équipements propres à chaque faction, filtrage avec mipmaps et badges conservés. Une pose par classe avec recul au tir, sans animation indépendante des armes. 36 suites, 14 901 contrôles Godot dont 25 nouveaux, 16 tests Python et contrats du GDD réussis. Les 24 sources de distribution incluent désormais les trois images Alliance et leurs imports. [Détail et prompts](Assets_Alliance_v061.md).

## v0.62 — Orientation et mouvements d’attaque, 27 octobre 2026

Les six défenseurs regardent vers le côté de leur dernier vrai tir, conservé entre deux attaques pendant le combat. Mouvement propre à chaque classe, miroir des points de départ des projectiles, badges et ombres stables. 37 suites, 15 075 contrôles Godot dont 174 nouveaux, 16 tests Python et contrats du GDD réussis. Aucun changement de combat ou d’équilibrage. [Détail](Animations_attaque_v062.md).

## v0.63 — Réaction aux dégâts, 27 octobre 2026

Éclaircissement bref des ennemis touchés et extinction de la portion de PV perdue dans leur jauge. Lecture des pertes réelles, incluant les ticks du chaman, sans chiffre flottant ni modification de combat. 38 suites, 15 138 contrôles Godot dont 63 nouveaux, 16 tests Python et contrats du GDD réussis. [Détail](Reaction_degats_v063.md).

## v0.64 — Trois ennemis illustrés, 27 octobre 2026

Grouillant, Pillard et Sprinter reçoivent des PNG transparents dans le style cartoon retenu. Tailles relatives conservées, orientation selon le chemin, mouvement global de marche et survol adapté à la silhouette. Les cinq autres profils gardent leur dessin procédural. 39 suites, 15 184 contrôles Godot dont 46 nouveaux, 16 tests Python et contrats du GDD réussis. Les 31 sources de distribution incluent images et imports de ce lot. [Détail et prompts](Assets_Ennemis_v064.md).

## Correction de conception après v0.64 — 27 octobre 2026

Règle rappelée et confirmée : neutres communs, attaquants spécifiques du camp adverse uniquement, catalogue distinct des défenseurs construits. Le prototype possède encore un catalogue commun ; ses PNG d’ennemis restent provisoires. Une [proposition de répartition](Origine_ennemis_2026-10-27.md), demandée par le porteur du projet, distingue trois neutres et cinq identités par camp adverse. Cette répartition n’est pas encore approuvée et aucun changement de règles, de vagues ou d’exécutable n’est livré par cette note. Priorité à la validation du catalogue avant la suite des illustrations.

## v0.65 — Neutres et attaquants adverses, 27 octobre 2026

Trois neutres communs (loup, sanglier, ours), cinq attaquants Horde face à l’Alliance et cinq attaquants Alliance face à la Horde. Catalogue d’ennemis distinct des six défenseurs construits ; treize identités illustrées dans trois atlas transparents. Prévisions, inspection, boss, R-12 et rapports cohérents avec le camp joué. Profils statistiques et dix vagues conservés. 40 suites, 15 974 contrôles Godot, 16 tests Python et contrats du GDD réussis. 32 sources contrôlées pour la distribution. [Détail et prompts](Catalogue_attaquants_v065.md).

## v0.66 — Palette des attaquants Horde, 27 octobre 2026

À la demande du joueur, la planche Horde espacée retrouve les tons plus sobres de la grande référence. Nouvel atlas horde_v003, cadres et ancrages remesurés, silhouettes et hauteurs de rendu conservées. Alliance, faune, défenseurs et règles inchangés. [Détails](Palette_Horde_v066.md).

## v0.67 — Progression et talents par faction, 27 octobre 2026

Ressources, points, trois arbres et compteurs de respécialisation propres à chaque camp. Gains sauvegardés après les vagues, talents appliqués au début de la tentative, reset confirmé à coût croissant puis plafonné. Valeurs et effets provisoires ; difficulté sans talent conservée pour comparaison. [Règles et validation](Progression_factions_v067.md).

## v0.68 — Arbres verticaux et paliers par colonne, 27 octobre 2026

Trois colonnes à icônes, rangs visibles et lecture des effets au survol/clavier. Trois lignes par arbre : 0, 5 et 10 points investis dans ses lignes précédentes. Cinq talents par arbre, valeurs d’essai et deux spécialités finales exclusives. Profil v0.67 migré avec restitution gratuite des points investis ; ressources, points achetés, compteurs et parcours de gains préservés. [Détails et preuves](Arbres_verticaux_v068.md).

## v0.69 — Lire les gains et préparer la partie suivante, 27 octobre 2026

Carte de ressources au bilan, détail des gains sauvegardés, solde du camp et points achetables. Accès aux talents uniquement après le résultat global ; gains provisoires non versés entre les vagues/cartes et progression acquise conservée après fermeture. Aperçu du prochain rang sans dépense. Enregistrement en attente distingué d’un gain sauvegardé, reprise explicite et tentatives automatiques espacées. Progression conservée après fermeture, fichier chiffré et authentifié par Windows, anciens JSON non importés automatiquement. Montants et effets inchangés. [Détails et validation](Lecture_progression_v069.md).

## v0.70 — Retrouver les talents actifs de la partie, 28 octobre 2026

Rappel discret avant et pendant la partie ; survol avec les bonus permanents de la faction. Quatrième onglet Talents au bilan global : trois arbres, noms et rangs retenus, PV initiaux et effets par défenseur. Lecture seule de la configuration fixée au départ, sans accès aux arbres pendant le parcours. Le rapport Markdown reprend ces informations. Prix, effets, sauvegarde protégée et frontière de versement inchangés. [Détails et validation](Resume_talents_v070.md).

## v0.71 — Préparer sa faction à l’accueil, 28 octobre 2026

Deux colonnes présentent ressources, points actifs et à affecter, PV initiaux et conseil de préparation. Distinction entre points déjà possédés et achat possible ; plafond respecté. Rappels actualisés après affectation, erreur de profil signalée sans faux solde nul. Aucun achat ni changement automatique. [Détails et validation](Accueil_progression_v071.md).

## v0.72 — Repères de talents et progression des paliers, 28 octobre 2026

Repères sur les icônes pour distinguer rang investissable, maximum, palier fermé, spécialité exclue et point à acheter. Progression chiffrée et jauges par palier ; état rappelé dans le détail au survol/clavier. Règles, prix, effets et sauvegarde inchangés. [Détails et validation](Reperes_talents_v072.md).

## v0.73 — Comprendre la respécialisation avant paiement, 28 octobre 2026

Confirmation avec coût, solde restant, points à placer après remboursement et prochain prix plafonné. Annulation sans prélèvement, devis périmé refusé, confirmation invalidée à la fermeture ou au changement de faction. Compteurs, montants et sauvegarde inchangés. [Détails et validation](Apercu_respecialisation_v073.md).

## v0.74 — Dissipation des ennemis éliminés, 28 octobre 2026

Nuage cartoon bref au lieu de la mort, y compris pour une malédiction létale. Dernier effet terminé après la vague, sans cible conservée, attente ni récompense différée. Animation déterministe et nombre d’effets affichés borné. [Détails et validation](Dissipation_ennemis_v074.md).

## v0.75 — Annonces de début de vague, 28 octobre 2026

Annonce de deux secondes réelles dans l’en-tête après chaque départ réussi, manuel ou automatique. Numéro, effectif et finale avec boss adverse. Apparition et extinction douces, aucun clic ou pause, jauge du boss dégagée. [Détails et validation](Annonce_vagues_v075.md).

## v0.76 — Identité des forteresses par faction, 28 octobre 2026

Forteresse Alliance en pierre claire, toits bleus et liserés dorés ; forteresse Horde en bois renforcé, métal, rouge et défenses ivoire. Dessin natif avec contours cartoon et bannières animées. Même cour, point d’arrivée et emplacement E6 dégagé. [Détails et validation](Forteresses_factions_v076.md).

## v0.77 — État visible de la forteresse, 28 octobre 2026

Aspect endommagé à la moitié des PV, critique au quart, bannière abaissée à zéro. Fissures, fumée discrète, teinte et libellé explicite ; lecture relative au maximum actuel. Aucun malus ajouté. [Détails et validation](Etat_forteresse_v077.md).

## v0.78 — Avertissement avant départ automatique, 28 octobre 2026

Rappel dans l’en-tête pour les cinq dernières secondes de préparation ; annonce du boss avant la finale. Caché pendant les lectures suspendant le délai, remplacé par l’annonce de départ à zéro. Même délai et mêmes pauses. [Détails et validation](Avertissement_depart_v078.md).

## Complément v0.78 — Audit de la progression, 28 octobre 2026

512 scénarios de contrôle reproduits à l’identique : deux factions, quatre configurations de talents, deux placements, 32 graines. Budget vérifié pour chaque scénario, aucun profil chargé ni gain versé. La référence gagne sans talent dans ses 64 essais ; le placement réparti échoue sans talent et profite davantage de la progression. Taux limités à ces politiques, sans extrapolation aux joueurs humains. Données et scripts versionnés, coûts et difficulté inchangés. [Résultats et limites](Bilan_progression_v078.md).

La destination existante et le dossier des données du joueur sont refusés par le script de mesure, sans écrasement. Les empreintes des sources de jeu concordent avec le paquet v0.78 ; seuls des outils de développement et documents sont ajoutés. Aucun nouvel exécutable nécessaire pour ce complément.

## Complément v0.78 — Atelier de difficulté isolé, 28 octobre 2026

2 048 scénarios comparent quatre coefficients de PV ennemis sur des copies temporaires. Référence reproduite, budgets vérifiés et projet intact. Un coefficient uniforme accentue fortement les écarts entre factions dans ces politiques ; aucune modification livrée au joueur. [Hypothèses, résultats et limites](Hypotheses_PV_ennemis_v078.md).

## v0.79 — Silhouette avant recrutement, 28 octobre 2026

Projection translucide du défenseur sur l’emplacement libre, au survol ou au clavier. Cohérence des six classes et factions, profondeur de dessin, repère E1–E6 dégagé et disponibilité distinguée. Aucun achat ni instance simulée dans le modèle. [Détails et validation](Silhouette_achat_v079.md).

## Vision long terme — demande du 28 octobre 2026

La [feuille de route long terme](Feuille_de_route_long_terme.md) intègre le texte et la référence visuelle fournis : cible de 200 missions, PO uniques par première réussite, chapitres et infini après 100 missions. Les suggestions de l’ancienne réponse restent des propositions, notamment les récompenses cosmétiques et défis. La respécialisation payante est conservée ; l’articulation mission/partie et le budget de PO restent à cadrer. Le prototype ne change pas encore d’économie.

## v0.80 — Données des cartes, 28 octobre 2026

Le tracé, les emplacements et le décor du Gué sont regroupés dans une définition partagée entre le combat, le dessin et les interactions. Cartes incohérentes refusées ; rapports adaptés aux géométries de test. Une seule carte jouable, sans modification de la progression ou de l’économie. [Détails et validation](Donnees_cartes_v080.md). La [vision long terme](Feuille_de_route_long_terme.md) est consignée séparément, sans implémenter les règles encore ouvertes.

## v0.81 — Panneau de combat simplifié, 28 octobre 2026

Résumé des ennemis restants et des arrivées à la forteresse, compteurs complets et temps simulé accessibles à la demande. Jauge de PV relative au maximum actuel, avec les seuils visuels déjà utilisés sur la forteresse. Aucun changement de règle ou de décompte. [Détails et validation](Combat_lisible_v081.md).

## v0.82 — Portraits dans la prévision, 29 octobre 2026

Illustration de chaque groupe avant le départ, tirée des mêmes atlas que les ennemis du combat. Faune neutre commune et attaquants du camp adverse, noms et avertissements conservés sans agrandir le panneau. [Détails et validation](Portraits_prevision_v082.md).

## Clarifications de campagne — 29 octobre 2026

Première clarification, ensuite révisée : plusieurs missions devaient composer une partie complète. La réponse suivante fixe finalement la possibilité de ne jouer qu’une mission et le versement des PO dès sa première victoire. Les nouveautés persistantes restent aux missions 11–20, 31–40, 51–60, etc., puis peuvent réapparaître ponctuellement. [Décisions de cadrage](Cadrage_campagne_2026-10-29.md) et [feuille de route actualisée](Feuille_de_route_long_terme.md). Aucun changement du jeu v0.82 pour cette mise à jour documentaire.

## Révision des récompenses de mission — 29 octobre 2026

Le joueur peut s’arrêter après une seule mission. Ses PO sont versées dès la première victoire sur cette mission ; aucune récompense initiale répétée aux victoires suivantes, ni versée à la défaite. Les PO antérieures restent acquises. Cette décision remplace l’attente d’une fin globale multi-missions pour la future campagne. [Cadrage révisé](Cadrage_campagne_2026-10-29.md) et [feuille de route](Feuille_de_route_long_terme.md). Le jeu v0.82 garde son économie actuelle jusqu’à l’intégration et à la migration contrôlée.

## Richesse et plafond des talents — 29 octobre 2026

Les trois arbres par faction doivent être nettement enrichis et partager un plafond imposant des arbitrages : acheter tous les points autorisés ne signifie pas remplir tous les talents. Les premières victoires des 100 premières missions doivent financer ce plafond, dont le nombre et le prix restent à définir. Le prototype actuel peut encore saturer ses trois petits arbres ; ce n’est pas la cible validée. [Orientation et constat chiffré](Orientation_talents_2026-10-29.md).

## v0.83 — Registre des premières récompenses, 29 octobre 2026

Fondation persistante pour les premières victoires par mission : reçu et gain atomiques, séparation des factions, reprise sans doublon et migration conservant les acquis. Répartition budgétaire paramétrable sans montant final. La nouvelle économie n’est pas encore raccordée au Gué jouable ; les arbres enrichis et leur plafond restent à concevoir. [Réalisation et validation](Registre_missions_v083.md).

## Économie et boutique — précisions du 29 octobre 2026

Chaque mission, également après la 100e, verse ses PO à la première victoire. Le financement du maximum de points à 100 missions est un repère sans dépenses facultatives ; les achats en boutique peuvent le retarder. La boutique ouvre des stratégies avec des unités ayant forces et faiblesses, sans remplaçantes systématiquement supérieures. Les trajectoires talents, boutique et mixtes devront être testées pour éviter impasses et trivialisation. [Cadre économique](Economie_campagne_2026-10-29.md). Aucun nouveau barème ou mécanisme de réserve imposée.

## Étude des arbres enrichis et du reset — 29 octobre 2026

[Proposition concrète](Proposition_talents_enrichis_2026-10-29.md) : 18 talents par arbre sur six lignes, module de calcul avec paliers, plafond partagé et exclusions, sans raccordement au jeu. Le coût du reset est rouvert : gratuité ou PO renouvelables à définir ; aucune option appliquée. [Cadre économique actualisé](Economie_campagne_2026-10-29.md).

## v0.84 — Reset gratuit, 29 octobre 2026

Décision explicite : les resets entre les missions sont gratuits, les talents restent fixés pendant la mission. Confirmation sans paiement, aucun débit de PO, point acheté conservé, anciens compteurs sans effet sur le coût. Les gains de chaque première victoire continuent après la mission 100 ; le repère budgétaire à 100 exclut les dépenses facultatives en boutique. La boutique ouvre des stratégies sans remplaçantes systématiquement supérieures. [Réalisation et validation](Reset_gratuit_v084.md), [cadre économique](Economie_campagne_2026-10-29.md). La proposition de 18 talents par arbre reste en cours d’intégration, hors jeu jouable.

## Version v0.85 — arbres enrichis

[Lot détaillé](Arbres_enrichis_v085.md) : trois arbres de 21 talents, sept lignes, plafond 51 par faction, majeurs aux seuils 15 et 30, migration sans perte des gains et bilan complet avec défilement. Prix, nouveaux effets et équilibre restent provisoires. Le barème de campagne de 510 PO est une proposition non activée.

## Version v0.86 — vocabulaire des monnaies

[PO persistantes et or de combat](Monnaies_lisibles_v086.md) : accueil, arbres et résultats utilisent le nom demandé pour la progression ; le plateau distingue son or temporaire. Aucun changement de gains, coûts, format de profil ou règle de combat.

## Version v0.87 — XP des talents

[XP de première victoire](Experience_talents_2026-10-29.md) : Gué à 60 PO + 100 XP une seule fois par faction, attribution automatique de points par XP, sauvegarde au schéma 5 et conversion des anciens points sans perte. Le prix des points en PO est retiré. La campagne au-delà du Gué, la boutique et la refonte en talents liés restent à développer.

## Version v0.88 — architecture des talents

[Arbres liés](Arbres_lies_v088.md) : quatre colonnes avec cases vides, sept lignes visibles, flèches et exigence du rang maximal du parent en plus du palier. Noms et détails à la sélection. Migration au schéma 6 avec gains conservés et restitution gratuite des points si une ancienne répartition est incompatible ; anciens rapports rejouables. Les liens et positions précis restent provisoires.

## Version v0.89 — flèches de talents droites

[Parents et enfants alignés verticalement](Fleches_droites_v089.md), avec des cases libres sur le trajet et sans coude ni traversée d’icône. Présentation corrigée dans les six arbres ; règles, rangs, statistiques et sauvegardes v0.88 conservés.

## Version v0.90 — parcours par faction

[Parcours de campagne](Parcours_campagne_v090.md) : vingt chapitres de dix positions, choix de mission, récompenses de première victoire affichées, succès conservés par faction, retour après résultat et accès aux talents. Une seule mission jouable, les autres à venir. Lancement refusé si la tentative ne peut pas être sauvegardée ; résultat conservé tant que son crédit échoue. Chaque mission repart à neuf, avec les talents persistants de sa faction. Arbres à quatre colonnes de v0.89 conservés.

## Version v0.91 — trois missions jouables

[Échantillon de campagne](Echantillon_campagne_v091.md) : Gué, Bois du Gué et Hauts du Gué, dix vagues chacun, PV ennemis à 100/101/102 %, autres paramètres de combat inchangés. Déblocage séquentiel dans chaque faction, gains uniques de prototype à 60 PO et 100 XP, premier point réellement accessible après deux victoires. Géométrie, titres, aperçus et rapports suivent la mission ; les anciens rapports du Gué restent rejouables. Les difficultés et la lisibilité demandent encore des essais humains.

## Version v0.92 — lisibilité de la progression

[Parcours et bilan](Lisibilite_progression_v092.md) : suggestion de la prochaine mission jouable, dernier contenu réussi proposé à la fin de l’échantillon, sélection manuelle préservée lors de la consultation des talents. Nom de mission dans chaque onglet du bilan, message de point disponible et bouton pour le placer, XP du prochain point et détails du solde au survol. L’avertissement de résultat non enregistré reste prioritaire même lors d’un rejeu sans récompense. Trois missions, règles de combat et progression persistante conservées.

## Comparaison des trois missions — 30 octobre 2026

[Relevé de 2 592 simulations](Comparaison_trois_missions_v092.md) : deux factions, trois cartes, trois graines, six triplets d’emplacements, quatre compositions et trois moments d’amélioration. Aucun talent dans les deux premières missions ; mission 3 comparée sans talent puis avec un seul point dans chacun des trois arbres. Budget normal vérifié dans chaque cas, douze témoins identiques à petits et grands pas, 24 rejeux complets et 144 résultats Horde historiques identiques. Les 45 sources du paquet Windows correspondent toujours au projet ; le binaire v0.92 et l’équilibrage sont conservés. La variété des résultats et le poids de la géométrie invitent à améliorer la lecture des cartes avant de modifier les statistiques. Aucun taux de victoire humain n’est déduit de ces politiques fixes.

## Version v0.93 — aperçu du terrain

[Tracé et emplacements avant mission](Apercus_cartes_v093.md) : le panneau de la mission sélectionnée dessine les données réelles du terrain, l’entrée, la forteresse et les six emplacements. Une carte verrouillée reste consultable, sans devenir jouable avant le succès requis. Les missions à venir restent sans terrain inventé. Présentation du panneau ajustée sans modifier les trois missions, leur difficulté ou les acquis persistants.

## Version v0.94 — états et repérage dans le parcours

[Missions futures et chapitre visible](Etats_parcours_v094.md) : cercle en pointillés pour le contenu à venir, cadenas pour le succès requis, coche pour la réussite. Les chapitres sans contenu jouable l’annoncent explicitement. Une progression indisponible n’est plus présentée comme une simple mission verrouillée. La liste défile pour révéler le chapitre sélectionné après mise en page, sans voler le focus ni déplacer le parcours fermé ou recouvert par les talents. Trois cartes, combat, économie, sauvegardes et talents conservés.

## Version v0.95 — points et rôles des arbres

[Lecture des talents](Lecture_talents_v095.md) : les points disponibles, leur plafond partagé et l’XP remplacent l’ancien en-tête chargé. Les PO restent accessibles au survol. Le rôle de chaque arbre accompagne son compteur ; des coins clairs repèrent le talent décrit au survol et au clavier. L’aide s’adapte à la disponibilité des points, avec les erreurs et migrations prioritaires. Géométrie des arbres, règles et données de progression conservées.

## Prochain lot retenu — 30 octobre 2026

Le porteur du projet choisit **d’étendre l’essai aux missions 4–10**, après ce lot de lisibilité. Les nouvelles valeurs resteront des réglages de prototype. Le contenu de ces sept missions est à préparer et à tester ; il n’est pas réputé livré par la v0.95. Les nouveautés de chapitre restent prévues à partir du bloc 11–20.

## Version v0.96 — premier chapitre jouable

[Missions 4 à 10](Missions_4_10_v096.md) : sept terrains supplémentaires, dix vagues et six emplacements chacun, PV de prototype à 103–109 %. Dix premières victoires donnent 600 PO, 1 000 XP et cinq points de talent par faction avec le barème actuel. Le dernier point est obtenu après la mission 10. Anciens profils conservés, mission 4 accessible après les trois premiers succès ; les missions 11–200 restent à venir. Les tracés et les valeurs restent à équilibrer par des essais humains.

## Version v0.97 — décor des nouveaux terrains

[Habillage du plateau](Decor_terrains_v097.md) : buissons, rochers et sapins sur les missions 4–10. Disposition stable, zones libres autour du chemin, des défenseurs et de la forteresse. Décor calculé au changement de terrain ; données des cartes, combats, tirages et progression conservés. Les couleurs et formes restent une proposition artistique de prototype.

## Version v0.98 — relecture des vagues

[Contexte historique dans le bilan](Analyse_vagues_v098.md) : sélectionner une vague affiche sa défense au départ et ses bonus actifs. Le résumé des pertes ouvre une vague à examiner, sans inventer la cause d’une défaite. Retour explicite à la défense finale, sélection au clavier et vagues absentes désactivées. Dix missions, combats et progression persistante conservés.

## Prochain lot retenu — 31 octobre 2026

Le porteur du projet choisit **la boutique et ses premières unités alternatives** avant le bloc de missions 11–20, puis précise la composition : **trois types habituels de la mission plus un quatrième type choisi parmi les unités achetées**, utilisable pendant toute la mission. La [préparation de la boutique](Preparation_boutique_2026-10-31.md) distingue les règles validées des propositions de périmètre et des modalités ouvertes. La v0.98 ne contient pas encore de boutique.

## Orientation long terme — biomes et cumuls, 31 octobre 2026

[Décisions sur les biomes](Biomes_cumul_2026-10-31.md) : un biome pour deux chapitres, avec nouveaux attaquants ou affixe au second chapitre. L’affixe peut affaiblir la défense ou renforcer les attaquants. Après la mission 100, cumuler le contenu précédent tout en poursuivant les nouveautés. Le mode infini réutilisera aussi les attaquants et affixes dans une accumulation progressive. Biomes, paramètres et règles exactes de cumul restent à concevoir ; aucun de ces contenus n’est annoncé comme déjà jouable.
