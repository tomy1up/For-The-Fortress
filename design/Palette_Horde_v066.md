# Palette des attaquants Horde — v0.66

27 octobre 2026. Le joueur demande de reprendre les couleurs de la grande planche Horde. La planche espacée intégrée en v0.65 avait des tissus rouges plus vifs et des couleurs plus saturées : cette différence existe dans les fichiers eux-mêmes, indépendamment de leur taille d’affichage. Elle est apparue lors de la correction de disposition effectuée avec l’outil d’image.

## Réalisation

Nouvel atlas [horde_v003.png](../prototype/assets/enemies/rosters/horde_v003.png), créé avec l’outil intégré image_gen en prenant la petite planche fournie par le joueur comme cible et [sa grande planche de référence](concepts/Horde_reference_couleurs_v066.png) comme référence de couleur. Rouges assombris, tons de peau et cuirs plus sobres. Il s’agit d’une édition générative rapprochant les palettes, sans garantie d’identité exacte des pixels.

Les cinq identités, poses et équipements sont conservés. Les cadres et ancrages ont été remesurés pour tenir compte des petits écarts de contours de l’édition. Les hauteurs de rendu restent celles de la v0.65 ; les personnages restent séparés et le fond transparent. L’ancienne planche est conservée dans Git, sans être exportée dans le paquet v0.66. L’Alliance, la faune et les défenseurs construits ne sont pas modifiés. Aucun changement de mécanique ou d’équilibrage.

## Consigne exacte d’édition

Ordre des entrées : 1. planche Horde espacée v002 ; 2. grande planche Horde de référence. Fond transparent demandé explicitement.

```text
Use case: precise-object-edit. Asset type: transparent game enemy sprite atlas, For the Fortress. Image 1 is the EDIT TARGET: five smaller, widely separated Horde characters in a 2172x724 transparent atlas. Image 2 is the COLOR REFERENCE ONLY: the same five characters larger and closer together, with a darker, more muted palette. Change ONLY the target's colors and tonal treatment to match image 2: subdued dark burgundy reds instead of bright saturated scarlet, muted olive green skin, subdued cyan troll skin, darker leather and neutral grey metal. Preserve the EXACT layout, relative sizes, poses, shapes, outlines, weapons, character identities and positions of image 1. Keep all five completely separated and feet at the same baseline. Preserve the original 3:1 canvas and true transparent background. This is strictly a palette correction of image 1, not a redesign or a composition change. Do not add any objects, labels, text, drop shadows or background. Preserve transparency. Match the original larger image's local material colors and subdued contrast, without changing the geometry.
```

For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Validation

40 suites et 15 974 contrôles Godot, 16 tests Python et contrats du GDD réussis. Le paquet final a passé 88 lancements et produit 87 captures ; ses 32 sources correspondent au projet local. Les 154 contrôles graphiques couvrent notamment transparence, cadrage, ancrage, proportions et survol.

[Horde dans le paquet final](essais/captures/QA-v066_attaquants_horde.png) et [Alliance conservée](essais/captures/QA-v066_attaquants_alliance.png) inspectées. Les empreintes des images et imports Alliance/faune, ainsi que des sources du modèle et d’équilibrage, sont identiques à la v0.65. Scènes de contrôle automatisées, sans nouveau retour humain ni campagne native manuelle complète. [Rapport de régression](essais/v066_regression.json) et [relevé de distribution](Distribution_Windows_v066.json).
