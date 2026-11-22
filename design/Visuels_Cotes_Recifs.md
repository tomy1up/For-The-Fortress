# Côtes et récifs · missions 161 à 170

Le porteur a choisi le biome le 12 novembre 2026. Cet habillage de prototype reprend la mer turquoise, le bois gris et la pierre claire d’un port abandonné. Le calque prolonge les flancs du plateau en falaises et pose un filet d’écume à leur pied.

Six pièces et quatre variantes miroir composent le décor. Les jetées et les casiers marquent la Jetée Abandonnée et le Quai des Brumes. Le Phare Éteint a des vitres assombries. La Baie des Épaves place deux coques en miroir, et la Forteresse du Cap se reconnaît à son arche de pierre.

Les dix cartes ont cinq pièces chacune. Leurs ancres restent à au moins 1,25 unité des routes, 1,50 des emplacements et 2,30 des entrées. Les silhouettes projetées ont été contrôlées autour des chemins, des repères d’entrée et de la forteresse.

## Contrôles

Les dix missions ont été lancées en combat à ×1 dans les deux factions avec deux défenseurs et un anneau de portée affiché. Les missions 164, 166 et 170 ont aussi été vérifiées à ×2, soit 26 passages sur les sources de la v0.192. Le validateur couvre 21 dossiers sans problème. Les quatre suites ciblées passent (30 356 contrôles Godot et 17 tests Python).

- [Missions 161 à 165](essais/coast_ch17/Cotes_161_165.jpg)
- [Missions 166 à 170](essais/coast_ch17/Cotes_166_170.jpg)
- [Forteresse du Cap, Horde à ×2](essais/coast_ch17/Forteresse_du_Cap_en_combat.jpg)

## Chapitre 18 · missions 171 à 180

Cinq pièces par carte. Le phare change de rive sur la 171, le Cimetière des Navires accueille trois coques, et l’Arsenal Englouti rapproche les casiers de l’arche. Les ancres restent à au moins 1,25 unité des chemins, 1,58 des emplacements et 2,30 des entrées. Les silhouettes projetées ont été contrôlées autour des chemins et de la forteresse.

### Brume marine

Un liseré turquoise se renforce durant les trois secondes d’avertissement. Ensuite, des nappes bleu pâle traversent le plateau sous les unités. Le voile et le liseré disparaissent à la fin des six secondes d’effet. Les planches occupent un cadre de 320 × 160 px : 18 images pour `warning` en progression et 36 pour `mist` à 12 images/s sur le temps de combat. Le branchement de Claude Code (`6b3d706`) les étire sur l’emprise du plateau.

Chaque carte a été contrôlée avant l’alerte, pendant l’avertissement, sous la brume et après dissipation dans les deux factions. Les missions 174, 178 et 180 ont aussi été vérifiées à ×2, soit 26 passages et 104 captures sur les sources de la v0.193. Le validateur couvre 22 dossiers sans problème. Six suites ciblées passent (30 569 contrôles Godot et 17 tests Python). Visuels prêts pour intégration et avis du porteur.

- [La Brume marine en quatre états](essais/Brume_marine/Brume_quatre_etats.jpg)
- [Missions 171 à 175](essais/Brume_marine/Cotes_171_175.jpg)
- [Missions 176 à 180](essais/Brume_marine/Cotes_176_180.jpg)

## Décors sur les nouveaux tracés des missions 161 à 180

Les jetées, phares, épaves, casiers et arches sont repositionnés pour les nouveaux parcours du littoral. Il y a cinq pièces par carte. Les trois épaves distinguent la mission 174. Le phare et l’arche marquent la Citadelle des Embruns à l’est du plateau.

Sur une copie de la v0.238 avec les 40 décors du littoral et de la nécropole activés, 48 captures couvrent les vingt missions dans les deux factions. Les missions 171 à 180 montrent le plateau sous la Brume marine. Sur 174 et 180, l’avertissement, la brume active et la dissipation ont été contrôlés séparément. Les contrôles de géométrie (19 230 pour les deux biomes), de la Brume marine (59) et des chapitres 17 (5 920) et 18 (6 114) passent.

Le bandeau chevauche Entrée 1 sur 174 et 180, et effleure ou recouvre le bord d’Entrée 2 sur 173 et 178. Les étiquettes d’Entrée 1 sont aussi serrées contre le bandeau sur 173, 176, 177 et 178. Ce défaut de l’interface est signalé à Claude Code. Avis du porteur attendu avant activation des décors.

- [Missions 161 à 165, Alliance et Horde](essais/cotes_necropole_refonte/Missions_161_165.jpg)
- [Missions 166 à 170, Alliance et Horde](essais/cotes_necropole_refonte/Missions_166_170.jpg)
- [Missions 171 à 175, Alliance et Horde](essais/cotes_necropole_refonte/Missions_171_175.jpg)
- [Missions 176 à 180, Alliance et Horde](essais/cotes_necropole_refonte/Missions_176_180.jpg)
- [Avertissement, brume et dissipation](essais/cotes_necropole_refonte/Brume_marine_en_combat.jpg)
- [Bandeau et étiquettes à taille native](essais/cotes_necropole_refonte/Verification_bandeau.jpg)
