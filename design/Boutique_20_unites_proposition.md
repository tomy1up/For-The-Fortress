# Boutique : proposition de catalogue à 20 unités par faction

**Statut : proposition de Claude Code, à valider par le porteur avant tout code.** Toutes les valeurs sont des réglages de prototype à confirmer. Contexte : CAMP-008 (la boutique ouvre des stratégies grâce à des unités ayant des forces et des faiblesses, aucune remplaçante systématiquement supérieure) et CAMP-012 (les PO des missions 1 à 200 servent à la boutique).

## Décision du porteur (13 novembre 2026)

La valeur totale des unités de la boutique doit **au moins égaler le total de PO accumulé** pendant la campagne en difficulté Normal. Le porteur retient une taille d'environ **20 unités par faction**.

## Les chiffres

| Mesure | Valeur |
| --- | --- |
| PO par faction, missions 1 à 100 (60 PO × 100) | 6 000 |
| PO par faction, missions 101 à 200 (65 à 110 PO selon le chapitre, dix missions chacun) | 8 750 |
| **Total par faction sur les 200 missions** | **14 750** |
| Catalogue actuel par faction (deux unités à 180 et 240 PO) | 420 (2,8 % des PO) |

Les PO sont propres à chaque faction (CAMP-010) : chaque faction a donc besoin d'un catalogue de valeur ≥ 14 750 PO.

## Barème de prix proposé (par faction)

20 unités = les 2 alternatives existantes (180 et 240 PO) + 18 nouvelles, de 300 à 1 300 PO :

300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1 020, 1 080, 1 140, 1 200, 1 250, 1 300.

Somme des 18 nouvelles : 14 550 ; avec les 420 existantes : **14 970 PO ≥ 14 750** (marge de 220). Le joueur peut donc dépenser tous ses PO, mais pas acheter chaque unité à chaque partie : une seule unité alternative est choisie par mission (règle actuelle, section 57 du GDD).

## Déblocage par chapitre (proposé)

Une unité à 1 300 PO ne doit pas être achetable dès le chapitre 3 : le déblocage suit les PO cumulés, avec environ une nouvelle unité par chapitre à partir du chapitre 2 (les prix suivent le cumul de PO du joueur qui achète à peu près tout ce qu'il peut). Exemple de rythme : unités 3 et 4 au chapitre 2 (en plus des deux existantes), une unité par chapitre ensuite, les dernières aux chapitres 19 et 20. Les unités se débloquent à l'achat avec des PO ; la condition de chapitre évite d'acheter la plus chère avec les PO des tout premiers chapitres.

## Dix-huit archétypes (communs aux deux factions, noms à valider)

Chaque archétype a une **force et une faiblesse** (CAMP-008) ; aucun ne remplace systématiquement une unité de départ. Les noms par faction sont des propositions.

| # | Archétype | Force | Faiblesse | Alliance (proposition) | Horde (proposition) | Règle |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Guetteur de longue portée | Portée très grande | Dégâts faibles | Guetteur des crêtes | Veilleur des cendres | existante |
| 2 | Tireur d'élite | Un coup très fort | Recharge très lente | Tireur d'élite elfe | Lanceur de javeline troll | existante |
| 3 | Mitrailleur | Cadence très haute | Dégâts minuscules | Arquebusier nain | Lance-éclats gobelin | existante |
| 4 | Artilleur | Explosion très large | Lent, portée moyenne | Bombarde naine | Catapulte gobeline | existante |
| 5 | Lancier | Bon marché pour sa puissance | Portée courte | Piquier humain | Lance-épieu orc | existante |
| 6 | Incendiaire | Dégâts sur la durée | Impact initial faible | Pyromancien humain | Brûleur de cendres | existante (type chaman) |
| 7 | Ricocheur | Plusieurs cibles en chaîne | Impact réduit | Arbalète à répétition | Hache en chaîne | existante |
| 8 | Tir croisé | Bonus sur cible déjà touchée | Dégâts faibles sur cible fraîche | Archer double | Chaman de marque | à confirmer |
| 9 | Briseur | Dégâts forts contre les lourds | Faibles contre les petits | Arbalète lourde | Lanceur de masse | à confirmer |
| 10 | Chasseur de légers | Dégâts forts contre les rapides | Faibles contre les lourds | Fronde elfe | Sarbacane gobeline | à confirmer |
| 11 | Entravant | Ralentit la cible | Dégâts très faibles | Mage de givre | Chaman des marais | **règle nouvelle** |
| 12 | Marqueur | Les voisins infligent plus de dégâts à la cible | Aucun dégât propre | Éclaireur-observateur | Totem de guerre | **règle nouvelle** |
| 13 | Gardien | Bonus aux défenseurs voisins | Peu de dégâts propres | Prêtre guerrier | Anciens des tribus | **règle nouvelle** |
| 14 | Pilleur | Gagne de l'or sur éliminations | Fragile et lent | Marchand mercenaire | Pillard gobelin | **règle nouvelle** |
| 15 | Sapeur d'entrée | Efficace près de l'entrée | Inutile à portée de forteresse | Piégeur nain | Poseur de mines | **règle nouvelle** |
| 16 | Tourelle de forteresse | Efficace près de la forteresse | Inutile loin | Balliste royale | Baliste de guerre | existante (emplacement) |
| 17 | Réaction en chaîne | Une élimination déclenche une explosion | Dégâts directs faibles | Alchimiste | Gobelin kamikaze | **règle nouvelle** |
| 18 | Unité-pivot | Bonus croissant par vague survivante | Faible au début | Vétéran royal | Chef de guerre vétéran | **règle nouvelle** |

Neuf archétypes réutilisent des règles existantes (statistiques, rebond, explosion, durée) ; les neuf autres demandent des règles de combat nouvelles, à valider **une par une** par le porteur (périmètre fonctionnel) avant que je les code.

## Équilibrage

- Méthode : comme pour les arbres de talents (`design/Equilibrage_arbres_talents_v0168.md`), mesurer chaque unité avec la stratégie de référence de sa faction, la substituer à l'unité de départ la plus proche, et vérifier qu'aucune n'est strictement meilleure partout (il existe toujours des cartes ou des vagues où une autre unité fait mieux). Le test de parité sera ajouté à la régression.
- La boutique est la source de puissance après la mission 100 (plus de points de talent) : les marges de la référence aux chapitres 18 à 20 (3 à 11 PV) devront être remesurées avec les unités achetables (O-016).

## Production

- 18 unités par faction, soit 36 unités à illustrer et animer par Codex. Livraison par lots de 6 par faction (trois lots : chapitres 2 à 7, 8 à 13, 14 à 20), chacun testé et publié ; en attendant les visuels, une silhouette d'unité existante teintée sert d'emplacement.
- Aucun visuel ni valeur n'est produit avant la validation du porteur.

## Questions pour le porteur

1. La liste des dix-huit archétypes convient-elle (ajouts, retraits, noms) ?
2. Les neuf règles nouvelles : lesquelles valides-tu, lesquelles écartes-tu ?
3. Une seule unité alternative par mission (règle actuelle) ou plusieurs ?
4. Le barème de 300 à 1 300 PO et le déblocage par chapitre te conviennent-ils ?
