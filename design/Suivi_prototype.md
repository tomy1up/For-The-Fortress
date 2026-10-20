# Suivi du prototype

État du 20 octobre 2026 — prototype v0.15, GDD v0.14.

## Périmètre réalisé

La première vague est jouable avec les trois défenseurs Alliance au N1. Cette étape suit le lot L2 approuvé ; elle n’enlève pas la Horde du périmètre final du prototype.

| Lot du cahier | État | Preuve ou travail restant |
| --- | --- | --- |
| L0 Préparer | Partiel | Projet Godot démarrable ; export autonome non encore produit |
| L1 Traversée du Gué | Réalisé | Tracé 28 unités, six emplacements, déplacements, arrivées et PV |
| L2 Boucle minimale | Réalisé | Achats et ventes Alliance N1, tirs, récompenses, vague 1 complète, retour entre les vagues |
| L3 Couvrir le combat | À compléter | Ciblage et tirs simultanés Alliance réalisés ; Horde, autres ennemis, boss et malédictions à ajouter |
| L4 Progression | À faire | Niveaux et douze branches ; limite de copies et remboursements N1 déjà réalisés pour L2 |
| L5 Partie complète | À faire | Dix vagues successives, sélection de faction, bonus et synergies, fins de partie complètes |
| L6 Essais et équilibrage | À faire | Campagne d’essais à mener après intégration ; résultats techniques actuels consignés ci-dessous |

## Résultats techniques v0.15

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

Les prochains événements sont les apparitions, entrées de portée, tirs disponibles et arrivées. Le modèle avance à leur instant, puis jusqu’au temps demandé pour l’affichage ; la cadence ne dépend pas de la fréquence des images.

Les instants, progressions et bornes de couverture sont des float 64 bits. Les Vector2 servent à la géométrie et à l’affichage. La tolérance 10⁻⁹ est réservée aux comparaisons temporelles et aux bornes de portée ; le rayon secondaire du mage conserve sa comparaison strictement inférieure à 1. Aucun arrondi de dégâts par impact n’est ajouté.

Le niveau 1, les prix et les valeurs de dégâts restent ceux du GDD. Les synergies sont volontairement absentes du premier essai de combat N1, conformément à la référence de test déjà approuvée. Les documents Word et Markdown du GDD ne sont pas révisés, car cette livraison implémente leurs règles sans en changer la conception.

## Prochaine étape

Compléter L3 : ajouter les trois défenseurs Horde N1 et les autres archétypes, puis vérifier rebonds, explosions, malédictions et tous les événements simultanés avant de lancer l’équilibrage des dix vagues.
