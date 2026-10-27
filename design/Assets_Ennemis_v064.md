# Premier lot d’ennemis illustrés — v0.64

27 octobre 2026. Déclinaison de la [direction cartoon retenue](concepts/Direction_cartoon_Horde_v001.md) après les six défenseurs. Les apparences individuelles sont proposées par cette version et restent ajustables après retour joueur.

## Livrables

| Profil existant | PNG transparent | Hauteur sur le plateau |
| --- | --- | --- |
| Grouillant | [grouillant_v001.png](../prototype/assets/enemies/grouillant_v001.png) | 23,8 px |
| Pillard | [pillard_v001.png](../prototype/assets/enemies/pillard_v001.png) | 34 px |
| Sprinter | [sprinter_v001.png](../prototype/assets/enemies/sprinter_v001.png) | 28,9 px |

Capuche verte et couteau, tunique rouge et calotte métallique avec épée, puis posture penchée et foulard rouge : les signes distinctifs des profils de la v0.59 sont conservés. Ces ennemis sont les mêmes adversaires pour les deux factions ; aucune nouvelle race, unité jouable ou capacité n’est introduite. Les armes et équipements restent décoratifs, sans résistance ou protection nouvelle.

Les trois images ont été créées séparément avec l’outil intégré `image_gen`, en utilisant la planche Horde comme référence de style uniquement. Aucun recours à la CLI/API externe. Les PNG générés sont copiés dans le projet sans modification de leurs pixels et possèdent un vrai canal alpha. Les cadres de la zone visible (alpha > 8/255, marge de deux pixels) et les ancrages des pieds sont consignés dans `prototype/scripts/enemy_art.gd`.

## Intégration au plateau

Une hauteur de base de 34 px est multipliée par les échelles existantes de 0,7, 1 et 0,85. Les proportions des images sont conservées, avec filtrage par mipmaps. Les jauges et les centres logiques restent à leurs positions actuelles. Les couleurs de prévision gardent les catégories existantes vert, rouge et ocre ; elles ne constituent pas un prélèvement exact des teintes des PNG.

Les trois illustrations sont retournées horizontalement selon la direction projetée du prochain morceau de chemin. À la forteresse, la direction du dernier morceau est conservée. Une légère élévation périodique de l’image entière reprend la phase de marche existante, en temps simulé. **Une pose par profil** : les jambes ne sont pas animées séparément et il n’y a pas de rotation complète en huit directions.

La zone de survol de ces trois profils inclut le rectangle de l’illustration, y compris l’arme et le foulard. Elle conserve le minimum précédent et couvre les deux orientations ainsi que le petit mouvement vertical. Ce changement concerne uniquement la détection visuelle à la souris ; les positions, portées et cibles du combat ne changent pas. Les priorités de survol en cas de superposition restent fondées sur l’ordre de profondeur.

Ombres, anneaux de sélection, marques de malédiction, jauges et portions de PV perdues restent dessinés séparément. Sur les trois PNG, la réaction à un dégât devient un gain bref de luminosité, avec alpha conservé ; sa durée de 0,16 seconde simulée et le suivi des pertes réelles de la v0.63 restent identiques. Les profils procéduraux gardent leur éclaircissement des couleurs précédent.

## Périmètre et suite

Brute, Maraudeur, Colosse, Élite et Seigneur de siège conservent leurs dessins procéduraux et leur animation de jambes actuelle. Leur zone de survol reste inchangée. Ils pourront être adaptés dans un prochain lot.

Aucun changement des PV, vitesses, dégâts à la forteresse, récompenses, résistances, ciblage, compositions des vagues, bonus, synergies ou progression. Les six défenseurs conservent leurs PNG. Le boss reste à 600 PV. Aucune progression permanente. GDD principal v0.14 ; For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Vérification

39 suites, **15 184 contrôles Godot** dont 46 nouveaux, **16 tests Python** et contrats du GDD réussis. Les contrôles dédiés couvrent transparence, cadres, proportions, pieds, taille relative, direction sur le chemin, zones de survol dans les deux sens, conservation des cinq zones précédentes, luminosité avec alpha conservé et rendu répété sans mutation des ennemis, dégâts, malédictions, rapport ou RNG.

Les 31 sources contrôlées à l’export et à la vérification locale incluent le nouveau script, les trois PNG et leurs trois imports. La détection d’une image ou d’un import modifié couvre désormais aussi les ennemis. Le [rapport de régression](essais/v064_regression.json) et le [contrôle du paquet Windows](Distribution_Windows_v064.json) conservent les résultats. Les captures de contrôle à budget imposé ne constituent ni un retour humain ni une nouvelle validation générale d’équilibrage.

## Consignes exactes de génération

Mode : outil intégré. Fond transparent demandé à chaque appel. Référence de style : `design/concepts/Horde_cartoon_v001.png`.

### grouillant

```text
Use case: stylized-concept. Asset type: ONE individual transparent PNG enemy sprite for For the Fortress!, an isometric tower-defense game. Input image is STYLE REFERENCE ONLY. Match the approved compact cartoon family: thick dark contours, oversized head and hands, broad simple shapes, flat frank colors and sparse clean cel shading. ORIGINAL character, not one of the three defenders in the reference. Full body and complete weapon visible, centered with clear small margins, genuine transparent alpha canvas, feet on horizontal baseline. Slightly elevated three-quarter view facing viewer-right, a readable marching/advancing pose. Intended for tiny 25–35 px in-game height: make silhouette and clothing contrast exceptionally simple and readable, no tiny decoration. Warm tan skin, round ears, hostile determined expression; enemy of BOTH playable factions, no Alliance or Horde insignia. No floor, ground shadow, scenery, backdrop, text, watermark, signature, drawn checkerboard, extra characters, floating icons or extra weapons. Subject: GROUILLANT, the smallest light raider. Small hunched compact figure under a large pointed muted SAGE-GREEN hood with dark interior framing a mischievous tan face; simple sage-green short tunic, plain brown rope belt, brown boots. ONE short steel knife held low on viewer-right. Green pointed hood dominates the silhouette, little face visible. No cape, armor, shield, sword, pointed ears, monster skin or goblin goggles.
```

### pillard

```text
Use case: stylized-concept. Asset type: ONE individual transparent PNG enemy sprite for For the Fortress!, an isometric tower-defense game. Input image is STYLE REFERENCE ONLY. Match the approved compact cartoon family: thick dark contours, oversized head and hands, broad simple shapes, flat frank colors and sparse clean cel shading. ORIGINAL character, not one of the three defenders in the reference. Full body and complete weapon visible, centered with clear small margins, genuine transparent alpha canvas, feet on horizontal baseline. Slightly elevated three-quarter view facing viewer-right, a readable marching/advancing pose. Intended for tiny 25–35 px in-game height: make silhouette and clothing contrast exceptionally simple and readable, no tiny decoration. Warm tan skin, round ears, hostile determined expression; enemy of BOTH playable factions, no Alliance or Horde insignia. No floor, ground shadow, scenery, backdrop, text, watermark, signature, drawn checkerboard, extra characters, floating icons or extra weapons. Subject: PILLARD, a basic stocky foot raider. Large determined tan face, plain round STEEL SKULLCAP with no horns or crest. Muted BRICK-RED tunic, broad plain brown belt with one simple brass buckle, brown boots and wrist wraps. ONE straight short steel sword held upright on viewer-right. Red torso and round steel cap dominate. No shield, cape, large armor plates, axe, pointed ears, robe, hat or insignia.
```

### sprinter

```text
Use case: stylized-concept. Asset type: ONE individual transparent PNG enemy sprite for For the Fortress!, an isometric tower-defense game. Input image is STYLE REFERENCE ONLY. Match the approved compact cartoon family: thick dark contours, oversized head and hands, broad simple shapes, flat frank colors and sparse clean cel shading. ORIGINAL character, not one of the three defenders in the reference. Full body and complete weapon visible, centered with clear small margins, genuine transparent alpha canvas, feet on horizontal baseline. Slightly elevated three-quarter view facing viewer-right, a readable marching/advancing pose. Intended for tiny 25–35 px in-game height: make silhouette and clothing contrast exceptionally simple and readable, no tiny decoration. Warm tan skin, round ears, hostile determined expression; enemy of BOTH playable factions, no Alliance or Horde insignia. No floor, ground shadow, scenery, backdrop, text, watermark, signature, drawn checkerboard, extra characters, floating icons or extra weapons. Subject: SPRINTER, a swift lean runner. Compact body leaning forward with bent knees in a clear running pose, big focused tan face, short dark brown swept hair, no helmet or hood. Simple SAND-OCHRE light tunic and brown belt/boots. ONE broad BRICK-RED SCARF trailing to viewer-left. ONE short steel knife in the front hand on viewer-right, other hand empty. The forward lean and red trailing scarf define the silhouette. No cape, shield, armor, bow, long sword, pointed ears or magic.
```


## Paquet Windows vérifié

87 lancements, 86 captures et 31 empreintes locales concordantes. Le [catalogue des huit profils](essais/captures/QA-v064_catalogue_ennemis.png) montre les trois nouvelles illustrations et les cinq dessins procéduraux conservés. Les nouvelles silhouettes ont été inspectées en [combat avec le sapeur](essais/captures/QA-v064_combat_sapeur.png), en inspection et pendant un [dégât périodique du chaman](essais/captures/QA-v064_malediction.png). Jauges, marques de malédiction, réaction lumineuse et fond transparent restent lisibles. Les contrôles graphiques ont eu lieu sur l’écran de droite et les jeux de contrôle se ferment après capture. Ces scènes servent au contrôle du rendu et ne constituent pas un essai joueur.
