# v0.106 — La Confluence, atelier à deux entrées

## Périmètre

La demande de variantes de parcours prend la forme d'un **atelier isolé**, accessible avec `Lancer_atelier_routes.cmd` dans le paquet Windows ou l'argument `--atelier-routes` depuis les sources. Il utilise deux entrées qui convergent vers une forteresse, six emplacements et les dix vagues de référence. Il ne constitue pas la mission 21 et ne remplace aucune des vingt missions de campagne.

L'atelier ne crée pas de profil, ne charge pas la progression du joueur et ne verse ni PO ni XP. Les choix de faction, recrutements, améliorations, bonus, préparation automatique à 30 secondes, vitesses et rapport de fin restent utilisables. Les talents persistants et les unités de boutique du joueur ne sont pas importés dans cet essai.

## Réglages proposés pour l'essai

| Élément | Proposition de prototype, à éprouver |
| --- | --- |
| Terrain | La Confluence, plateau de 18 × 10 ; chemins de 27 et 28 unités |
| Affectation | Apparitions alternées entre les deux entrées, en conservant les instants et types des vagues existantes |
| Cible principale | Parmi les ennemis à portée, priorité à la plus petite distance restante sur sa route jusqu'à la forteresse, puis à l'apparition la plus ancienne |
| Secondaires | Proximité physique réelle entre ennemis, y compris lorsqu'ils proviennent de routes différentes ; mêmes rayons et limites de victimes |
| Rencontres | Vagues historiques du Gué, PV de référence à 100 %, mêmes coûts et récompenses de combat |

L'affectation alternée et la règle de ciblage entre routes de longueurs différentes ne sont pas présentées comme des décisions finales approuvées. Une question de conception a été soumise au porteur sur la distance restante ou le temps avant arrivée. Le prototype emploie provisoirement la première option. Les réglages des vingt missions à chemin unique sont conservés.

## Raccordements réalisés

Chaque ennemi conserve sa route et atteint la forteresse selon la longueur de celle-ci. Les fenêtres de portée des défenseurs sont calculées par route et recalculées lors des améliorations ou bonus concernés. Les rebonds, explosions, impacts, morts et protections utilisent les positions effectives. Une malédiction continue à suivre l'identifiant de sa victime.

Les deux chemins et entrées sont dessinés. L'aperçu de portée couvre les portions de chaque chemin réellement à portée ; le survol, le miroir et l'ordre visuel utilisent la route de l'ennemi. Les décors évitent les différents trajets. Le bâtiment final est unique.

Les rapports au format 2 conservent la géométrie complète avec leurs actions. L'affectation alternée est déterministe à partir de l'ordre des apparitions. Les rapports historiques à chemin unique restent pris en charge. Les définitions incohérentes et les identifiants explicites inconnus sont refusés.

## Vérification et limites

La suite multitrajet passe **72 contrôles**, dont les arrivées distinctes à 12 et 14 secondes sur une petite carte synthétique, les portées propres à chaque entrée, les secondaires après jonction, l'absence de proximité fictive avant jonction, la tortue, la malédiction, le survol, les rapports avec défenseurs et l'égalité du combat avec différents pas de temps.

La [régression complète](essais/v0106_regression.json) passe **91 suites Godot, 38 064 contrôles et 17 tests Python**. Le [paquet Windows](Distribution_Windows_v0106.json) passe **11 cas ciblés sur 257**, avec 73 empreintes sources comparées au projet local. Les captures exportées [Alliance](essais/captures/QA-v0106_routes_alliance.png) et [Horde](essais/captures/QA-v0106_routes_horde.png) sont examinées ; essais graphiques sur l'écran de droite. Ce n'est pas une validation native exhaustive ni une partie humaine complète.

La présentation détaillée des groupes par entrée, l'équilibrage humain, l'intégration à un futur biome et les cartes à plusieurs forteresses restent à faire. Les règles de PV et de défaite de plusieurs forteresses ne sont pas décidées ici.

Le candidat de marche du loup à 24 poses reste hors production en attente de la validation du porteur. Ce lot n'étend pas son animation aux autres unités. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.
