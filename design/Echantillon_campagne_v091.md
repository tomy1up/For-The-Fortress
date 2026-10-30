# Trois missions de campagne — prototype v0.91

30 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Décisions retenues

CAMP-014 : premier échantillon de **trois missions de dix vagues**, dans le même thème, avec des configurations différentes. CAMP-015 : PV ennemis à **100 %, 101 % puis 102 %**, sans changer leur vitesse, leurs dégâts à la forteresse ni leurs récompenses de combat. Chaque mission repart à neuf ; XP, PO, talents et premières victoires restent persistants et séparés par faction.

## Contenu proposé pour l’essai

| Mission | Carte | Longueur logique | Emplacements | PV ennemis | Première victoire |
| --- | --- | --- | --- | --- | --- |
| 1 | La Vallée du Gué | 28 | 6 | 100 % | 60 PO + 100 XP |
| 2 | Le Bois du Gué | 29 | 6 | 101 % | 60 PO + 100 XP |
| 3 | Les Hauts du Gué | 29 | 6 | 102 % | 60 PO + 100 XP |

Les noms des nouvelles cartes, leurs tracés et emplacements, le **déblocage séquentiel** et les montants de récompense constituent des hypothèses de prototype. Le choix de trois missions et leurs pourcentages de PV sont explicitement retenus. Le barème de 100 XP par mission suit la courbe de référence existante ; les 60 PO des missions 2 et 3 permettent de tester le parcours sans prétendre fixer l’économie de la future boutique.

Les dix compositions de vagues et leurs espacements sont conservés pour comparer les cartes et la hausse de PV. Aucune nouvelle famille d’ennemis ni nouvelle mécanique de chapitre n’est introduite dans ces trois premières missions. Les factions gardent leurs attaquants adverses et les familles neutres.

## Parcours et progression

Le Gué est immédiatement accessible. Gagner une mission débloque la suivante dans le même camp ; le verrou est revérifié au lancement, même si l’écran est ancien. Les missions verrouillées portent un cadenas et indiquent le succès requis. Une victoire de l’Alliance ne débloque rien dans la Horde, et inversement.

Un profil neuf reçoit 100 XP puis 200 XP cumulées après ses deux premières victoires. Le premier seuil est à 197 XP : **un point de talent devient réellement disponible après la mission 2** et peut être investi avant la mission 3. Après les trois missions : 300 XP, 180 PO et un point débloqué, hors dépenses. Les anciens acquis restent intacts. Les missions 4–200 restent à venir ; rejouer les trois premières ne redonne ni PO ni XP.

Chaque départ vide le plateau et les bonus temporaires, rend l’or initial et restaure les PV maximum selon les talents fixés au départ. Une défaite conserve les gains antérieurs et ne valide pas la mission suivante. Le retour au parcours est facultatif après chaque résultat, avec les mêmes protections d’enregistrement que v0.90.

## Cohérence des statistiques et des rapports

La hausse est fixée par la mission, jamais par le nombre de tentatives. Les PV exacts gardent leurs décimales : par exemple 40,4 et 40,8 pour un ennemi de référence à 40 PV. Aperçus de vagues, inspection, jauges et bilan du boss utilisent ces valeurs. Les gains de combat et les dégâts à la forteresse ne sont pas augmentés.

Les rapports des nouvelles cartes contiennent leur géométrie et leur pourcentage de PV, puis se rejouent avec ces règles. Un pourcentage falsifié ou manquant est rejeté s’il rend le combat incohérent. Les rapports historiques du Gué gardent leur format et ses statistiques de référence. Le titre et le dessin de carte suivent la mission sans modifier le nom de l’application ni le chemin de progression persistante.

## Équilibrage à éprouver

Un petit supplément de PV peut faire franchir un seuil de coups nécessaires : la difficulté réelle n’augmente pas uniformément de 1 %. Les scénarios de contrôle trouvent des stratégies gagnantes sans talent dans les deux factions, avec des choix de recrutement et d’amélioration différents. Cela vérifie l’absence d’un obstacle absolu avant le premier point ; cela ne mesure pas le taux de victoire des joueurs.

Une exploration automatisée de 144 politiques Horde compare six triplets de positions, quatre compositions de départ et trois moments de tentative d’amélioration, sur les deux nouvelles cartes. Une demande peut être refusée faute d’or ; les règles et budgets normaux restent appliqués. Les résultats doivent aider les prochains essais humains, pas justifier à eux seuls l’équilibrage définitif.

## Validation

70 suites et **23 822 contrôles Godot**, 16 tests Python et contrats du GDD réussis. Les 465 contrôles de l’échantillon éprouvent les PV exacts, les paramètres inchangés, les règles figées, la visibilité des emplacements, les trois cartes à deux pas de simulation, les victoires sans talent dans chaque faction, les rapports rejouables, le premier point après deux victoires, le retour après défaite et l’absence de gains au rejeu.

Le paquet Windows passe **175 lancements et 174 captures**, avec 45 sources comparées. Quatorze scénarios du nouvel échantillon montrent les deux cartes dans les deux factions, leurs inspections, bilans et le parcours final. Les **quatre rapports exportés par le binaire** pour les nouvelles missions ont été rejoués intégralement avec concordance. Les **40 scénarios historiques du Gué** gardent rapports, aléas, événements et dégâts identiques à v0.90. Le service de profil, son schéma 6, les talents et leurs quatre colonnes restent inchangés.

[Régression](essais/v091_regression.json), [comparaison du Gué](essais/v091_comparaison_combat.json), [exploration Horde](essais/v091_exploration_horde.json), [rejeux des rapports du binaire](essais/v091_rejeux_natifs.json), [distribution](Distribution_Windows_v091.json). Exemple : [nouvelle carte](essais/captures/QA-v091_alliance_sample_3_preparation.png), [premier point acquis et investi](essais/captures/QA-v091_horde_sample_3_journey.png). Ces contrôles ne remplacent pas les essais humains d’équilibrage.
