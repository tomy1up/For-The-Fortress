# Repères de boutique — prototype v0.100

L’accueil et les infobulles des PO et des talents indiquaient encore une « future boutique ». La boutique est accessible depuis le parcours depuis la v0.99. Ces textes décrivent désormais son usage actuel : les PO débloquent des unités et l’XP débloque les points de talent, séparément pour chaque faction.

L’accueil précise aussi qu’une unité de boutique peut s’ajouter aux trois défenseurs de départ, pour annoncer la composition possible avant d’ouvrir le parcours.

La notice et la présentation du projet sont aussi actualisées : dix missions jouables, 190 positions de campagne encore à développer, retour au parcours après les dix réussites et sauvegarde au schéma 7 avec conservation des acquis antérieurs. Il ne s’agit pas de nouveaux contenus de campagne ni d’un nouveau format de sauvegarde dans cette version.

Le mousquetaire conserve l’illustration sombre retenue en v0.99.1. Prix, statistiques, talents, gains et règles de combat restent inchangés.

## Comparaisons complémentaires

La [priorité d’investissement dans le quatrième défenseur](Comparaison_priorite_boutique_v0991.md) ajoute 3 744 simulations à la comparaison initiale. Les deux branches de chaque alternative sont effectivement atteintes. Épargner pour le niveau maximal ne garantit pas davantage de victoires ; les réglages restent provisoires et ne sont pas modifiés à partir de ces seules politiques fixes.

Les outils de simulation conservent la politique historique par défaut et vérifient sa compatibilité avec les relevés archivés. Leur option de priorité sert aux essais ; elle ne change pas la gestion des unités par le joueur.

For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Validation de livraison

Six suites ciblées passent **911 contrôles Godot** et **16 tests Python** : accueil et talents, résumé de configuration, boutique et deux méthodes de simulation. Le paquet Windows passe **neuf cas sélectionnés**, huit captures et 56 comparaisons de sources. L’accueil neuf et préparé ainsi que les talents des deux factions ont été examinés sur l’écran de droite. Les 84 suites recensées et les 243 cas disponibles n’ont pas tous été réexécutés.

52 sources embarquées conservent leur empreinte de v0.99.1, dont le modèle, les statistiques, les cartes, les talents, le profil et les illustrations. Les deux scripts d’affichage modifiés ne diffèrent que par leurs textes ; les autres différences sont le numéro de version et le chemin d’export.

[Distribution](Distribution_Windows_v0100.json), [contrôles ciblés](essais/v0100_regression.json), [accueil](essais/captures/QA-v0100_selection.png).
