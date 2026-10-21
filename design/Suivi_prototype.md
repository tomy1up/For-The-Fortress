# Suivi du prototype

État du 20 octobre 2026 — prototype v0.16, GDD v0.14.

## Périmètre réalisé

La première vague est jouable avec les deux factions et leurs trois défenseurs N1. Le combat du lot L3 et les huit profils ennemis sont intégrés ; leurs rencontres dans les dix vagues seront assemblées en L5.

| Lot du cahier | État | Preuve ou travail restant |
| --- | --- | --- |
| L0 Préparer | Partiel | Projet Godot démarrable ; export autonome non encore produit |
| L1 Traversée du Gué | Réalisé | Tracé 28 unités, six emplacements, déplacements, arrivées et PV |
| L2 Boucle minimale | Réalisé | Achats et ventes Alliance N1, tirs, récompenses, vague 1 complète, retour entre les vagues |
| L3 Couvrir le combat | Réalisé pour le N1 | Six défenseurs, huit profils, rebonds, explosions, ticks et ordre des événements testés ; campagne complète en L5 |
| L4 Progression | À faire | Niveaux et douze branches ; limite de copies et remboursements N1 déjà réalisés pour L2 |
| L5 Partie complète | À faire | Dix vagues successives, bonus et synergies, fins de partie complètes ; sélection de faction déjà réalisée |
| L6 Essais et équilibrage | À faire | Campagne d’essais à mener après intégration ; résultats techniques actuels consignés ci-dessous |

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

L5 : campagne de dix vagues, bonus roguelite et synergies déjà définis dans le GDD.

## Livraison L4 — v0.17, 21 octobre 2026

Progression des six défenseurs jusqu’au N4 et douze branches implémentées à partir du GDD v0.14, sections 12 à 17, 37 et 41. Aucun changement de règle ni nouveau contenu de conception. Les réglages numériques gardent leur statut H.

Le choix de branche applique le N4 et débite 150 or en une opération. L’annulation conserve le N3 et son or ; les commandes de jeu sont bloquées derrière le dialogue. La confirmation périmée ne modifie pas un nouvel exemplaire installé au même emplacement. Chaque copie conserve son niveau, sa branche, son identité et ses paiements ; le quota reste de deux par type.

607 contrôles réussis : les 199 précédents et 408 contrôles supplémentaires sur les multiplicateurs, les 84 champs des douze fiches finales, les coûts, les remboursements, les effets en combat, les portées recalculées, les ricochets successifs, les ticks spécialisés et les six dialogues. Les 56 valeurs de base sont toujours comparées au GDD. Les six fenêtres N4, une inspection N2 et une inspection N4 ont été rendues et inspectées.

Les investissements N4 sans réduction de 350/375/400 rendent 245/262/280 or ; l’arrondi s’effectue sur le total par exemplaire. Les statistiques de branche sont des valeurs finales et ne reçoivent pas une nouvelle multiplication de niveau.

La partie reste limitée à la vague 1 : le budget normal autorise N2 seulement. N3 et N4 sont testés avec budget imposé dans des scénarios de vérification explicitement identifiés. Aucun ajout d’or au parcours normal ; aucune conclusion sur l’équilibre des dix vagues. L4 est réalisé sur ce périmètre ; l’intégration à la campagne relève de L5. L0 reste partiel, sans export Windows autonome.

Les GDD Word et Markdown restent en v0.14. Prochaine livraison : L5 (campagne, bonus et synergies), suivie des essais de campagne.
