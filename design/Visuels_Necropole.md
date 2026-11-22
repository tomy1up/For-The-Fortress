# Nécropole et terres maudites · missions 181 à 190

Le porteur a choisi le biome le 13 novembre 2026. L’habillage de prototype associe pierre gris-os, sol violet et accents vert pâle. Un calque de strates prolonge les flancs du plateau, avec une brume basse autour des bords.

Les six pièces et quatre variantes miroir sont réparties à raison de cinq par carte. Le Portail des Ossements s’ouvre sur une arche funéraire. Les Cryptes Basses et les Mausolées Jumeaux reprennent les toits violets, tandis que l’Ossuaire concentre les ruines et les ossements. Le Marais des Défunts utilise des arbres morts et des lanternes vertes.

Les ancres sont à au moins 1,25 unité des routes, 1,52 des emplacements et 2,30 des entrées. Les silhouettes projetées ont été contrôlées autour de la chaussée, des repères et de la forteresse.

## Contrôles

Les dix cartes ont été contrôlées en combat à ×1 dans les deux factions, avec deux défenseurs et un anneau de portée affiché. Les missions 184, 187 et 190 ont également été vérifiées à ×2. Les 26 passages ont été effectués sur les sources de la v0.193. Le validateur couvre 22 dossiers sans problème. Les trois suites ciblées passent (24 222 contrôles Godot et 17 tests Python). Lot prêt pour intégration et avis visuel.

- [Missions 181 à 185](essais/necro_ch19/Necropole_181_185.jpg)
- [Missions 186 à 190](essais/necro_ch19/Necropole_186_190.jpg)
- [Nécropole Royale, Horde à ×2](essais/necro_ch19/Necropole_Royale_en_combat.jpg)

## Chapitre 20 · missions 191 à 200

Les dix cartes reçoivent cinq pièces chacune. Le Champ d’Ossements compte trois amas de ruines, les Tombes Jumelles reprennent les deux orientations du mausolée et les Obélisques Noirs ont trois pierres à rune verte. Les ancres restent à au moins 1,25 unité des trajets, 1,52 des emplacements et 2,30 des entrées.

### Revenant

Squelette neutre au linceul violet et aux yeux verts. La marche associe des appuis alternés, un léger mouvement du torse et une oscillation des pans de tissu. Trois planches de 24 poses en mode distance, cadre de 372 × 354 px, foulée de 16,6 px. Le portrait PNG fixe est livré dans `assets/enemies/rosters/revenant_v001.png`, avec un cadre `Rect2(0,0,372,354)`, une ancre `Vector2(170,327)` et une hauteur de cadre de 45,5. Le catalogue d’art et les listes d’export restent à mettre à jour pour le portrait.

La planche `rise` est une proposition de 24 images sur 0,72 s. Le squelette se redresse et une lueur verte s’élève autour des pieds. L’aperçu de la relève est une lecture isolée de la planche. La planche reste dans `design/essais/necro_ch20/` en attendant que le jeu accepte l’état `rise` et le déclenche à la relève avec le temps de combat. La logique de retour à mi-vie est déjà vérifiée par les tests du jeu.

Les 26 passages en vague 4 sur les sources de la v0.193 couvrent les deux factions, et les missions 194, 197 et 200 également à ×2. Les 24 poses de marche défilent dans chaque essai. Le validateur couvre 23 dossiers sans problème. Sept suites ciblées passent (31 528 contrôles Godot et 17 tests Python).

- [Le Trône du Roi Mort en combat](essais/necro_ch20/Trone_du_Roi_Mort_en_combat.jpg)
- [Aperçu isolé de la relève](essais/necro_ch20/Releve_apercu.gif)
- [Missions 191 à 195](essais/necro_ch20/Necropole_191_195.jpg)
- [Missions 196 à 200](essais/necro_ch20/Necropole_196_200.jpg)

## Décors sur les nouveaux tracés des missions 181 à 200

Les arches, mausolées, stèles, ossements, arbres morts et obélisques sont repositionnés pour les nouveaux parcours. Il y a cinq pièces par carte. Les cryptes vont par paire sur les missions 184, 187 et 197. Trois obélisques à rune verte marquent la mission 199.

Quarante captures couvrent les vingt missions à ×1 dans les deux factions sur une copie de la v0.238. Les missions 191 à 200 ont été saisies à la vague 4 à 24,50 s, avec des Revenants en combat. Les contrôles de géométrie (19 230 pour les deux biomes), des chapitres 19 (6 362) et 20 (6 562) et du Revenant (28) passent. Avis du porteur attendu avant activation des décors.

- [Missions 181 à 185, Alliance et Horde](essais/cotes_necropole_refonte/Missions_181_185.jpg)
- [Missions 186 à 190, Alliance et Horde](essais/cotes_necropole_refonte/Missions_186_190.jpg)
- [Missions 191 à 195, Alliance et Horde](essais/cotes_necropole_refonte/Missions_191_195.jpg)
- [Missions 196 à 200, Alliance et Horde](essais/cotes_necropole_refonte/Missions_196_200.jpg)
