# Terres volcaniques — proposition d’habillage du 11 novembre 2026

Le plateau prend une teinte de cendre froide, avec des dépôts irréguliers et des pierres plus sombres sur la tranche. Quatre pièces ponctuent les espaces libres : colonnes de basalte, ruine noircie, fumerolle et dalle de lave figée. Les fissures de la lave décorative restent ternes pour que les braises d’une Éruption ressortent sous l’emplacement visé.

![Maquette du Cratère Fumant avec alerte sur l’archer](essais/volcan/Mission_71_alliance.png)

La chaussée claire garde sa couleur et son tracé. Palette proposée pour le sol `#443C41`, avec faces `#3B3034` et `#2C252B`. Le [calque des cendres](essais/volcan/Texture_cendres.png) est transparent. Les quatre pièces PNG sont dans `design/essais/volcan/`. Consignes artistiques : basalte facetté, ruine basse sans ouverture, vapeur grise en deux volutes et croûte de lave à fissures rouge brique. Les contours et la perspective reprennent le style des forteresses du jeu. [Pièces agrandies](essais/volcan/Pieces_volcaniques.png)

Le [fichier de repères](essais/volcan/Reperes.json) donne les ancrages, les dimensions et les positions logiques proposées pour les **20 cartes des missions 61 à 80**. Six éléments par carte, soit 120 placements, ont été vérifiés contre les marges des routes, des six emplacements, des entrées et de la forteresse. Le contrôle tient compte de l’ombre des pièces et du support au sol. Les placements sont communs aux deux factions.

| Carte | Ce que la maquette vérifie |
| --- | --- |
| [61 — Le Seuil des Cendres](essais/volcan/Mission_61_alliance.png) | Le décor situe le biome dès la première mission. |
| [66 — Le Pont d’Obsidienne](essais/volcan/Mission_66_alliance.png) | Les deux entrées et leur jonction restent visibles. |
| [71 — Le Cratère Fumant](essais/volcan/Mission_71_alliance.png) | L’alerte orange ressort au pied du défenseur. [Vue Horde](essais/volcan/Mission_71_horde.png) |
| [80 — Le Cœur en Éruption](essais/volcan/Mission_80_alliance.png) | Le décor laisse dégagée la carte à trois entrées. |

Les huit maquettes ont été examinées sur des captures Godot de la v0.174, dans les deux factions, prises sur l’écran de droite avec profil isolé. L’alerte sur la mission 71 est une composition de contrôle avec la planche de fissures déjà proposée. L’ensemble reste hors ressources d’exécution. Le sol et la lave figée sont purement décoratifs.

**Retour du porteur, 11 novembre 2026.** Cette direction lui convient pour une première version. Pour la suite, il demande des variantes de pièces et des rotations de placement du décor existant entre les cartes, afin de réduire la répétition visuelle. À chaque nouvelle composition, vérifier les marges des routes et des emplacements ainsi que la lisibilité de l’alerte des Éruptions.

Pour un premier essai en jeu, utiliser les missions 61 et 71. Poser les cendres après la couleur du sol et avant la chaussée. Dessiner les pièces au point de pose prévu, sous les unités et l’interface. Contrôler l’alerte des Éruptions à ×1 et ×2 dans les deux factions, puis vérifier les marges à partir des données de la carte avant d’étendre l’habillage. Le jeu peut utiliser la même palette de sol dans l’aperçu de mission.

## Variantes et placements des missions 61 à 80

Deux pièces rejoignent les quatre d’origine. Le **basalte éclaté** associe une colonne haute à droite, un pilier brisé et des blocs bas. La **ruine d’angle** montre un retour de mur effondré, avec une extrémité plus haute. Les deux PNG transparents sont référencés dans `prototype/assets/decor/decor.json` et affichés à 42 et 34 px de haut. L’orientation générale vient des compositions sur le plateau et des silhouettes dessinées, avec un éclairage cohérent.

Les 120 placements ont été recomposés. Les Fumerolles et les Geysers de Cendres regroupent les volutes, tandis que les Orgues de Basalte alignent quatre formations rocheuses. Les Coulées Figées disposent leurs dalles au premier plan et les Braises Dormantes les placent sur le bord opposé. Les fissures décoratives restent ternes. Le contrôle des marges tient compte de la silhouette projetée, de la chaussée, des entrées, des emplacements et de la forteresse.

- [Missions 61 à 65](essais/volcan_variantes/Volcan_61_65.jpg)
- [Missions 66 à 70](essais/volcan_variantes/Volcan_66_70.jpg)
- [Missions 71 à 75](essais/volcan_variantes/Volcan_71_75.jpg)
- [Missions 76 à 80](essais/volcan_variantes/Volcan_76_80.jpg)
- [Alerte et désactivation en combat](essais/volcan_variantes/Eruptions_alerte_et_impact.jpg)
- [Alerte à ×2 sur les six emplacements de la mission 71](essais/volcan_variantes/Eruptions_x2_six_emplacements.jpg)

Les 40 scènes de combat ont été capturées dans Godot avec un profil isolé, à la vague 1. Le signal reste identifiable sur la cendre à 13,5 s de simulation. Sur la mission 71, les douze captures à ×2 couvrent les six cases dans chaque faction, avec un seul défenseur par essai pour sélectionner la case. Une partie du tracé reste masquée par les pieds des personnages. Ces captures contrôlent la visibilité aux instants choisis. La perception de l’alerte pendant une partie libre reste à évaluer.

Le validateur d’animations relève zéro problème. La régression ciblée passe les suites décor, volcan, affixe et chapitre des Éruptions, avec 18 586 contrôles Godot et 17 tests Python.

**Retour du porteur, 11 novembre 2026.** Les variantes lui paraissent bien d’après les captures.

### Consignes de génération des deux variantes

Les variantes ont été générées avec l’outil d’image intégré en prenant chaque pièce d’origine comme référence de palette, de contours et d’éclairage. Les PNG ont été recadrés pour la pose au sol.

- **Basalte éclaté.** Sprite isométrique cartoon avec un pilier large et bas à gauche, une petite colonne brisée au milieu et un pilier hexagonal plus haut à droite, plus deux petits éclats. Empreinte compacte, pierre mauve anthracite, plans facettés, contours presque noirs, lumière en haut à gauche, lisibilité à 45 px. Sprite seul sur fond transparent, sans sol, ombre portée, lave, lueur, végétation ni texte.
- **Ruine d’angle.** Sprite isométrique cartoon d’un angle de mur en L, avec trois rangées de pierres à droite et une seule rangée à gauche, entourée de quelques gros blocs tombés. Contours et palette de la ruine existante, lumière en haut à gauche et lecture à 32 px. Sprite seul sur fond transparent, sans sol, ombre portée, fumée, lave, braises, végétation, personnage ni texte.
