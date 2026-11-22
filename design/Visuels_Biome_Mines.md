# Souterrains et mines · habillage du chapitre 13

Le porteur a validé le biome le 12 novembre 2026. Cet habillage est une première proposition sur les sources de la v0.183. L’ardoise bleutée et les strates sombres donnent le ton de la mine. Les lanternes et la forge apportent des touches chaudes, les cristaux restent bleu-vert pour se distinguer de la roche.

Les dix cartes ont cinq pièces chacune. Les étais et lanternes marquent les premières galeries. Les cristaux structurent la Grotte aux Cristaux (124), les chariots et traverses les Rails Abandonnés (125), et un foyer et une enclume la Forge Souterraine (126). Le Lac Noir (127) reçoit deux bassins décoratifs. Les rails ont deux orientations et sont posés hors des routes empruntées par les ennemis.

Les six pièces de base ont été produites à partir d’une planche d’illustrations isométriques sur fond transparent. Le calque de strates et les bassins complètent la palette dans la clé `mine` de `assets/decor/decor.json`.

## Vérification en combat

Les ancres restent à au moins 1,16 unité des trajets et 1,45 des emplacements. Les silhouettes projetées ont aussi été comparées au tracé des routes, aux losanges, aux repères d’entrée et à la forteresse. Les dix cartes ont été jouées avec deux défenseurs au début de la première vague, dans les deux factions. Les missions 124, 127 et 130 ont été vérifiées à ×1 et ×2, soit 26 passages au total. L’état du combat est identique avant et après le dessin. Les suites décor, aperçu de campagne et chapitre des mines passent (22 632 contrôles Godot, 17 tests Python).

- [Missions 121 à 125](essais/mines_ch13/Mines_121_125.jpg)
- [Missions 126 à 130](essais/mines_ch13/Mines_126_130.jpg)

## Chapitre 14 · missions 131 à 140

Les dix cartes reprennent la palette et les pièces du chapitre 13, avec cinq placements par carte. Les Piliers Fissurés s’appuient sur les étais, la Veine Oubliée sur les cristaux et les Galeries Jumelles sur des rails et des chariots en miroir. Les bassins du Gouffre Noir et de l’Écluse Souterraine sont décoratifs.

Les ancres des pièces sont à au moins 1,25 unité des routes, 1,50 des emplacements et 2,65 des entrées. Les silhouettes visibles ont aussi été comparées aux chaussées, aux repères d’entrée et à la forteresse sur le plateau projeté.

- [Missions 131 à 135](essais/mines_ch14/Mines_131_135.jpg)
- [Missions 136 à 140](essais/mines_ch14/Mines_136_140.jpg)

### Éboulement

Un anneau ambre en pointillés s’accentue à l’approche du blocage. Pendant la fermeture, un amas de blocs d’ardoise couvre le point d’entrée et un peu de poussière dérive au-dessus. Les deux planches de `effect.rockfall` ont 24 images de 150 × 112 px. Le jeu fournit la progression de `warning` et cadence `blocked` sur le temps de combat (12 images/s, boucle de 2 s).

Contrôles sur les sources v0.190 avec le branchement `77e54d3`. Les dix cartes ont été contrôlées dans les deux factions à ×1, et les 131, 134 et 140 également à ×2. Les 26 passages ont couvert l’entrée ouverte, l’avertissement, le blocage et la réouverture. Le second éboulement a été contrôlé sur ces trois cartes aux deux vitesses et dans les deux factions, avec un changement d’entrée visible. Le validateur couvre 20 dossiers sans problème et les six suites ciblées passent (29 196 contrôles Godot et 17 tests Python). L’habillage est prêt pour intégration et avis visuel du porteur.

[Extrait en combat](essais/mines_ch14/Eboulement_en_combat.gif) · [Quatre états à ×2](essais/mines_ch14/Eboulement_quatre_etats.jpg)

## Décor sur les nouveaux tracés des missions 121 à 130

Les dix cartes réutilisent les pièces des mines sur 50 emplacements adaptés. Deux étais marquent l’entrée, les rails et chariots s’alignent sur la mission 125 et le foyer de la Forge Souterraine est groupé avec un chariot et un étai. Le Lac Noir conserve ses deux bassins décoratifs. Un cristal et un étai ont été déplacés après inspection sur les missions 124 et 127 pour dégager les silhouettes.

Les vingt vues finales ont été capturées sur la vague 5 dans les deux factions, sur une copie de la v0.238. Les contrôles de décor incluent les 50 pièces visibles dans chaque faction, leurs ancres et leurs marges des routes et des cases dans la copie de test. Cette suite passe 11 130 contrôles, et la suite du chapitre en passe 5 024. Le porteur a validé le lot 23713fc le 22 novembre 2026. Pour l’activer, retirer uniquement les dix identifiants de mine_entrance à mine_heart de REWORKED_MAPS.

- [Missions 121 à 124](essais/mines_refonte/Mines_121_124.jpg)
- [Missions 125 à 127](essais/mines_refonte/Mines_125_127.jpg)
- [Missions 128 à 130](essais/mines_refonte/Mines_128_130.jpg)

## Décor sur les nouveaux tracés des missions 131 à 140

Cinquante emplacements sont adaptés à la nouvelle géométrie. Les étais rythment les Piliers Fissurés et la Voûte Instable. Les rails et chariots longent les Galeries Jumelles. Les bassins repèrent le Gouffre Noir et l’Écluse Souterraine. Sur les dix cartes, les pièces gardent leurs distances avec les routes, les cases et les entrées où se dessine l’éboulement.

Les 34 captures en combat sur copie v0.238 couvrent la vague 5 dans les deux factions sur chaque carte. La Voûte Instable et le Cœur Effondré sont également montrés à l’annonce, à la réouverture et sur des vagues suivantes. Les vagues 5 à 7 de la Voûte Instable montrent le blocage successif de ses trois entrées. Les suites décor, éboulement et chapitre passent avec 12 000, 498 et 5 746 contrôles respectivement.

Le bandeau Éboulement chevauche des étiquettes d’entrée, notamment en 134 et 140. Le point a été consigné pour Claude Code. Le porteur a validé le lot f2a2d99 le 22 novembre 2026. L’activation par Claude Code passe par le retrait des dix identifiants de mine_pillars à mine_core de REWORKED_MAPS.

- [Missions 131 à 134](essais/eboulement_refonte/Eboulement_131_134.jpg)
- [Missions 135 à 137](essais/eboulement_refonte/Eboulement_135_137.jpg)
- [Missions 138 à 140](essais/eboulement_refonte/Eboulement_138_140.jpg)
- [Annonce, blocage et réouverture au Cœur Effondré](essais/eboulement_refonte/Coeur_phases_eboulement.jpg)
- [Trois entrées bloquées sur trois vagues à la Voûte Instable](essais/eboulement_refonte/Voute_entrees.jpg)
