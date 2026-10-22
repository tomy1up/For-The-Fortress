# Suivi du prototype

État du 23 octobre 2026 — prototype v0.22, GDD principal v0.14 et complément validé D-2026-10-23-01.

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
