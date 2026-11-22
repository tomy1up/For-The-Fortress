# Habillage des citadelles — proposition du 11 novembre 2026

Les chapitres 9 et 10 se déroulent dans la citadelle de la faction adverse. La maquette reprend la pierre claire, le bleu et l’or de l’Alliance. La Horde emploie le bois, le fer sombre, le rouge et quelques défenses d’ivoire. La forteresse à protéger conserve l’identité de la faction jouée.

![Comparatif des quatre pièces de décor par faction](essais/citadelles/Architecture_comparee.png)

Les quatre pièces sont un portail ouvert, un rempart court, une tour de guet et un étendard. Les PNG transparents sont dans `design/essais/citadelles/`. Ils ont été dessinés à partir des forteresses existantes comme références de palette, de contours et de perspective. Le portail est un élément d’architecture posé en bordure. Les vrais points d’entrée restent repérés par la route et les annonces existantes.

| Faction de la citadelle | Faction jouée | Sol proposé | Faces du plateau |
| --- | --- | --- | --- |
| Alliance | Horde | `#4F5964` | `#424B57`, `#303843` |
| Horde | Alliance | `#524847` | `#443A39`, `#322C2D` |

Le fichier [Reperes.json](essais/citadelles/Reperes.json) donne les dimensions, les points d’ancrage, les hauteurs proposées et les placements d’essai. Les maquettes utilisent 62 px pour le portail, 45 px pour le rempart, 69 px pour la tour et 37 px pour l’étendard à la taille de jeu.

## Contrôle sur le plateau

Les décors ont été montés sur quatre captures Godot de la v0.174, prises sur l’écran de droite avec profil isolé. Les Glacis, mission 81, testent une entrée. Les Portes Jumelles, mission 87, testent trois entrées. Les positions sont communes aux deux factions sur chaque carte. Les pixels visibles des pièces ont été contrôlés contre les zones réservées autour des routes, des entrées, des six emplacements et de la forteresse. Les maquettes sont des compositions sur captures. Le décor n’est pas branché en jeu.

| Carte | Citadelle de l’Alliance | Citadelle de la Horde |
| --- | --- | --- |
| Les Glacis | [Maquette Alliance](essais/citadelles/Mission_81_citadelle_alliance.png) | [Maquette Horde](essais/citadelles/Mission_81_citadelle_horde.png) |
| Les Portes Jumelles | [Maquette Alliance](essais/citadelles/Mission_87_citadelle_alliance.png) | [Maquette Horde](essais/citadelles/Mission_87_citadelle_horde.png) |

**Retour du porteur, 11 novembre 2026.** Les maquettes lui paraissent « propres ». Le prochain contrôle porte sur la lisibilité du décor en combat.

Si cette direction convient, intégrer les pièces côté décor et commencer par les deux cartes d’essai. Sélectionner l’architecture par faction adverse et garder le même placement logique pour les deux versions. Pour les autres cartes, vérifier les marges à partir de leur géométrie avant de choisir les emplacements. En combat, contrôler les silhouettes, les portées au survol, les annonces d’entrée et le tri des objets en profondeur. L’aperçu de mission peut reprendre la palette de sol. Les règles de combat, les routes, les emplacements de recrutement et l’architecture de la forteresse du joueur ne nécessitent aucun changement.

## Extension aux chapitres 9 et 10

Le lot ajoute 91 pièces sur 17 cartes, des missions 83 à 100 hors 87 déjà habillée. Les Remparts alignent quatre sections de mur sur le bord nord. Les Deux Tours encadrent un rempart avec deux tours. La Cour d’Armes ouvre un espace autour d’un portail flanqué d’étendards. Au Cœur de la Citadelle, deux tours encadrent le portail et des bannières marquent le flanc opposé. Le placement tient compte du contour visible des pièces des deux factions, de la largeur des chemins, des pastilles d’entrée et des six emplacements de recrutement.

Les 34 captures ont été prises dans Godot sur l’écran de droite, dans les deux factions. Les cartes du chapitre 9 sont montrées à la vague 1 après 11 s de combat. Le chapitre 10 est montré à la vague 5 après 8 s, avec le capitaine dans les scènes capturées. L’outil de capture lance cette vague directement. Les étendards de L’Armurerie et des Escaliers ont été déplacés après un premier passage pour les éloigner des silhouettes des attaquants.

- [Missions 83 à 86](essais/citadelles_extension/Citadelles_83_86.jpg)
- [Missions 88 à 91](essais/citadelles_extension/Citadelles_88_91.jpg)
- [Missions 92 à 95](essais/citadelles_extension/Citadelles_92_95.jpg)
- [Missions 96 à 100](essais/citadelles_extension/Citadelles_96_100.jpg)

Le Pont-levis, mission 82, sert actuellement de témoin sans placement dans `test_decor_art.gd`. Ses six placements ont été essayés en mémoire dans les deux factions et attendent le déplacement de ce témoin vers un identifiant sans décor. [Captures de l’essai](essais/citadelles_extension/Citadelle_82_essai.jpg) · [Placements prêts à intégrer](essais/citadelles_extension/Pont_levis_placements.json).

Vérifications sur le lot actif. Le validateur d’animations a trouvé zéro problème. La régression ciblée a passé les suites décor et Garnison, soit 15 779 contrôles Godot et 17 tests Python.

## Décors adaptés aux nouveaux tracés des missions 91 à 100

Le lot du 22 novembre 2026 réutilise les portails, remparts, tours et étendards des deux factions. Les 53 emplacements ont été contrôlés contre la chaussée, les entrées, les six cases de défense et la forteresse. Sur la Grande Salle, un portail et deux tours rythment la bordure en laissant dégagées les trois entrées. Dans L’Armurerie, les remparts occupent un espace intérieur et l’étendard a été déplacé vers la bordure opposée à l’entrée basse.

Les vingt captures ont été prises sur la vague 5 dans une copie de la v0.238 avec les dix décors activés. Les suites décor et Garnison passent, avec respectivement 11 418 et 4 474 contrôles. Le lot attend la validation visuelle du porteur. Pour l’activation après validation, retirer uniquement les dix identifiants garrison_* de REWORKED_MAPS dans decor_art.gd.

- [Missions 91 à 94](essais/citadelles_refonte/Citadelles_91_94.jpg)
- [Missions 95 à 97](essais/citadelles_refonte/Citadelles_95_97.jpg)
- [Missions 98 à 100](essais/citadelles_refonte/Citadelles_98_100.jpg)
