# Îles flottantes et cité céleste · missions 141 à 150

Le biome a été confirmé par le porteur le 12 novembre 2026. Cet habillage de prototype associe un sol bleu ardoise, des falaises suspendues et des nuages discrets. Les arches en pierre claire, les toitures turquoise et les jardins de lavande donnent son identité à la cité céleste.

La planche d’origine comporte six pièces. Quatre ont une variante miroir. Chaque mission reçoit cinq placements dans `sky.placements`. Les Flèches d’Azur portent deux tours, les Jardins Suspendus trois jardinières, et le Dôme Céleste introduit l’observatoire. Les ruines et les éclats de roche caractérisent L’Île Effondrée. Le calque des nuages et falaises utilise l’origine du plateau isométrique.

Les ancres des pièces restent à au moins 1,25 unité des routes, 1,45 des emplacements et 2,57 des entrées. Les silhouettes projetées ont été contrôlées autour de la chaussée, des emplacements et de la forteresse.

## Contrôles

Les dix missions ont été ouvertes en combat à ×1 dans les deux factions, avec deux défenseurs et l’anneau de portée affiché. Les missions 144, 148 et 150 ont également été vérifiées à ×2, soit 26 passages. Contrôle sur les sources de la v0.191. Validateur à zéro problème et quatre suites ciblées au vert (29 238 contrôles Godot et 17 tests Python). Le lot est prêt pour intégration et avis visuel.

- [Missions 141 à 145](essais/iles_ch15/Iles_141_145.jpg)
- [Missions 146 à 150](essais/iles_ch15/Iles_146_150.jpg)
- [Citadelle des Cimes, Horde à ×2](essais/iles_ch15/Citadelle_des_Cimes_en_combat.jpg)

## Chapitre 16 · missions 151 à 160

Les dix cartes ont cinq pièces chacune. Les groupes de rochers soulignent les aires d’envol, et le Trône des Nuées reprend le dôme, une arche et une tour. Les ancres restent à au moins 1,25 unité des chemins, 1,52 des emplacements et 2,85 des entrées.

### Aigle des cimes

Le rapace a une tête dorée, un bec crochu et des ailes brunes. Le corps s’incline légèrement selon la pente projetée et l’ombre marque la position de l’ennemi au sol. Le vol suit la distance parcourue, avec trois planches de 24 poses de 336 × 256 px et une foulée de 16 px à l’échelle de base. Le PNG fixe pour la prévision et l’éclaireur est livré dans `assets/enemies/rosters/aigle_des_cimes_v001.png`. Le branchement du portrait est demandé à Claude Code. Cadre `Rect2(0,0,336,256)`, ancre `Vector2(179,234)`, hauteur de cadre `52.0`.

Sur les sources de la v0.191, les 26 passages en vague 3 ont parcouru les 24 poses et trois diagonales dans les deux factions. Les missions 154, 158 et 160 ont aussi été vérifiées à ×2. Le validateur couvre 21 dossiers, zéro problème. Six suites ciblées passent (29 604 contrôles Godot et 17 tests Python). Décors et vol en combat prêts pour intégration et avis visuel.

- [Aigle en combat](essais/iles_ch16/Aigle_en_combat.gif)
- [Missions 151 à 155](essais/iles_ch16/Iles_151_155.jpg)
- [Missions 156 à 160](essais/iles_ch16/Iles_156_160.jpg)

## Décor sur les nouveaux tracés des missions 141 à 150

Les dix cartes réutilisent les pièces de la cité céleste sur 50 emplacements adaptés. Le Pont de Brume regroupe les vestiges dans sa boucle. Deux tours se détachent sur les Flèches d’Azur, puis trois jardinières ponctuent les Jardins Suspendus. Le dôme et l’arche servent de repères en 148. Les fragments de roche ont été éloignés du défenseur sur les Courants Ascendants après une première capture.

Les vingt vues finales datent de la vague 5 sur une copie de la v0.238 dans les deux factions. Les ancres sont à au moins 1,25 unité des routes, 1,45 des cases et 2,65 des entrées. Les silhouettes projetées ont aussi été contrôlées contre les routes, la forteresse et les étiquettes d’entrée. Les suites décor et chapitre passent avec 11 390 et 5 580 contrôles. Le porteur a validé le lot 60d2efe le 22 novembre 2026. L’activation par Claude Code passe par le retrait des dix identifiants de sky_pontoon à sky_summit de REWORKED_MAPS.

- [Missions 141 à 144](essais/iles_refonte/Iles_141_144.jpg)
- [Missions 145 à 147](essais/iles_refonte/Iles_145_147.jpg)
- [Missions 148 à 150](essais/iles_refonte/Iles_148_150.jpg)

## Décor sur les nouveaux tracés des missions 151 à 160

Les 50 emplacements réutilisent les rochers, arches, tours et ruines de la cité céleste. Les Pitons Jumeaux sont ponctués de deux tours, les Trois Aires conservent trois départs dégagés et le Trône des Nuées rassemble l’arche, le dôme et la flèche. Après inspection, les tours en 158 et 160 ont été rapprochées de l’intérieur du plateau pour que leurs bases se lisent mieux.

Les vingt vues finales montrent la vague 3 à 19,20 s, avec les aigles en vol dans les deux factions sur copie v0.238. Les tests de décor et de campagne passent avec 11 390 et 5 786 contrôles. La suite du déplacement des ennemis passe 1 278 contrôles. Le lot attend l’avis du porteur. Après validation, l’activation par Claude Code passe par le retrait des dix identifiants de sky_aerie à sky_throne de REWORKED_MAPS.

- [Missions 151 à 154](essais/aigles_refonte/Iles_151_154.jpg)
- [Missions 155 à 157](essais/aigles_refonte/Iles_155_157.jpg)
- [Missions 158 à 160](essais/aigles_refonte/Iles_158_160.jpg)
