# Orientation du loup — prototype v0.109

2 novembre 2026. For the Fortress! est un nom de travail, disponibilité juridique à confirmer.

## Retour et règle de rendu

Le porteur juge l’animation du loup satisfaisante, mais signale que le personnage paraît étiré sur les chemins diagonaux. Son objectif est un déplacement naturel, cohérent avec le chemin et sans déformation de l’unité.

La v0.108 projetait l’axe longitudinal du dessin sur la direction du chemin tout en gardant son axe vertical vertical à l’écran. Les deux axes n’étaient donc plus perpendiculaires : cette transformation cisaillait toute la silhouette. L’absence de triangles retournés contrôlée précédemment ne suffisait pas à détecter ce défaut.

La v0.109 utilise deux axes perpendiculaires de longueur unitaire. Le personnage est orienté par rotation rigide, puis éventuellement retourné horizontalement selon son sens de déplacement. Les proportions et les angles du dessin sont conservés à chaque pose. Le survol et les limites du maillage utilisent la même transformation.

La direction suit le segment parcouru. La phase reste calculée à partir de la distance parcourue à l’écran, de la foulée et de la taille du loup. Les appuis restent donc calés sur l’avancée. Le dessin, les courbes du cycle et les valeurs de combat ne sont pas modifiés. Le rendu n’accède pas au profil joueur.

## Vérification

- Comparaison de toutes les arêtes et des produits scalaires des triangles entre la pose de profil et son orientation dans les quatre diagonales, à quatre instants du cycle : ni étirement ni cisaillement.
- Maintien des contrôles d’appui des quatre pattes, de pause, de cadence, de fermeture, de survol sur vingt missions et d’isolation des identités de faction.
- Comparatif natif des quatre directions, à pose identique : `essais/v0109_comparaison_orientation.png`. Ancien placement à gauche, correction à droite.
- Enregistrement de 144 images à 60 images/s dans la scène du jeu, déplacement imposé et profil isolé : `essais/v0109_loups_sans_cisaillement.mp4`. Plusieurs instants ont été examinés ; ce dispositif n’est pas une campagne complète jouée.
- Vérifications ciblées du paquet Windows dans les deux factions, en complément de la régression automatisée.

Les rapports `essais/v0109_regression.json`, `essais/v0109_wolf_geometry.json`, `essais/v0109_wolf_cpu.json` et `Distribution_Windows_v0109.json` précisent le périmètre et les résultats finaux.

Résultat : **92 suites Godot, 39 536 contrôles et 17 tests Python réussis** ; **14 cas Windows ciblés sur 263**, avec comparaison de **74 sources** et huit captures du paquet examinées. Les empreintes du dessin et des données du cycle sont identiques à celles de la v0.108 (`essais/v0109_fidelite_sources.json`). La lecture de contrôle des sommets natifs correspond exactement aux coordonnées calculées. Aucun triangle retourné n’est observé sur les 256 instants examinés par direction.

## Limites

Il s’agit d’une orientation rigide du profil existant, pas d’un nouveau dessin du loup sous plusieurs angles de caméra. Le changement d’orientation aux angles du chemin reste immédiat. Les directions presque verticales à l’écran conservent le profil plat provisoire ; les vingt missions actuelles utilisent les diagonales compatibles. Le naturel perçu du placement reste à éprouver avec le porteur. Cette correction ne valide ni n’intègre une nouvelle animation d’un autre animal.
