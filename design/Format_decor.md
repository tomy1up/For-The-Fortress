# Format du décor par données — version 1 (v0.176)

Cadre livré par Claude Code le 11 novembre 2026 pour intégrer les décors de Codex (citadelles, terres volcaniques) sans coder carte par carte. Valeurs et placements : habillages de prototype à confirmer en jeu.

## Principe

`prototype/assets/decor/decor.json` décrit, par décor de carte (`citadel`, `volcanic`), des palettes de sol, un calque facultatif et des pièces posées par carte ; les images sont dans les sous-dossiers de `assets/decor/`. Elles sont lues brutes et incluses telles quelles dans le paquet (filtre d'inclusion `assets/decor/*`), leurs empreintes sont contrôlées automatiquement. Sans fichier valide, le jeu garde les repères de couleur neutres.

Code : `scripts/decor_art.gd` (chargeur), `valley_view.gd` (`_draw_decor_props`, palette du sol et des faces, calque de cendres).

## Structure de `decor.json`

```
{"version": 1,
 "citadel": {"assets": {"alliance": {"portail": {"file": "citadelles/alliance_portail.png", "size": [w, h], "anchor": [x, y], "height": 62}, ...}, "horde": {...}},
             "palette": {"alliance": {"ground": [r, g, b], "faces": [[r, g, b], [r, g, b]]}, "horde": {...}},
             "placements": {"citadel_gates": [{"object": "portail", "xy": [7.2, 0.5]}, ...]}},
 "volcanic": {"assets": {...}, "palette": {"ground": [...], "faces": [...]}, "overlay": {"file": "volcan/Texture_cendres.png", "position": [391, 178]}, "placements": {"volcano_threshold": [...], ...}}}
```

- `size` et `anchor` en pixels de l'image ; `height` = hauteur affichée de l'image entière en pixels de jeu (l'échelle en découle) ; l'ancre est posée sur le point logique `xy` (coordonnées de plateau, projetées par le jeu).
- `faces` : face droite puis face gauche du plateau.
- `citadel` : l'architecture et le sol sont ceux du **camp adverse** de celui qui joue (citadelle de la Horde quand on joue l'Alliance). Les placements sont communs aux deux camps ; la forteresse du joueur est inchangée.
- `volcanic` : commun aux deux camps. Le calque `overlay` est dessiné après la couleur du sol, avant la chaussée.
- Les pièces sont dessinées sous les unités et l'interface, après la chaussée.

## Cartes décorées

- Volcan : les 20 cartes des missions 61 à 80 (six pièces chacune, six types de pièces depuis les variantes de Codex en v0.178 ; placements vérifiés par test contre les marges des routes et des emplacements).
- Citadelle : les vingt cartes des missions 81 à 100 (extension de Codex en v0.178 ; marges contrôlées par test pour les deux camps).
- Marais : calques d'eau des tronçons inondés sur Les Eaux Mortes (51) et Le Carrefour des Eaux (58) (`marsh.overlays` dans `decor.json`, voir ci-dessous).

## Ajouter ou modifier

1. Déposer les images dans `assets/decor/<dossier>/` et compléter `decor.json`.
2. Vérifier : `python prototype/tests/run_regression.py --test test_decor_art.gd` (images présentes et de la bonne taille, ancres, placements dans le plateau et à 1 unité des emplacements, 0,9 de la chaussée).
3. Contrôler en jeu dans les deux camps (survol, portées, annonces d'entrée, tri en profondeur) avant d'étendre.

## Calques d'eau des marais (v0.178)

`decor.json` : `"marsh": {"overlays": {"<id de carte>": {"file": "eaux/<png>", "position": [x, y], "size": [w, h], "routes": [...], "flooded": [...]}}}`. Le PNG est dessiné à `position` (coordonnées d'écran du plateau, origine isométrique du jeu) après la chaussée et avant les emplacements et les unités ; il remplace le repère bleu provisoire des tronçons inondés. Sans PNG (ou carte non décrite), le repère bleu est conservé. Les champs `routes` et `flooded` recopient la géométrie sur laquelle le calque a été dessiné : `tests/test_decor_art.gd` les compare à la carte réelle et échoue si la géométrie évolue sans nouveau calque. Les règles de régénération restent portées par les données `flooded` du modèle.
