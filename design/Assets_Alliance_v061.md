# Assets individuels Alliance — v0.61

27 octobre 2026. Déclinaison du style de la [planche Horde validée](concepts/Direction_cartoon_Horde_v001.md) pour les trois classes Alliance existantes. Les trois identités individuelles sont proposées par cette version et restent ajustables après retour joueur.

## Livrables et intégration

| Classe | Image transparente | Hauteur sur le plateau |
| --- | --- | --- |
| Archer elfe | [archer_v001.png](../prototype/assets/units/alliance/archer_v001.png) | 66 px, arc compris |
| Arbalétrier nain | [arbaletrier_v001.png](../prototype/assets/units/alliance/arbaletrier_v001.png) | 56 px |
| Mage humain | [mage_v001.png](../prototype/assets/units/alliance/mage_v001.png) | 66 px, chapeau et cristal compris |

L’elfe conserve sa cape verte, ses longues oreilles et son arc ; le nain sa barbe cuivrée, son casque et son arbalète ; le mage sa robe bleue, son chapeau pointu et son bâton à cristal cyan. Les PNG ont été créés séparément avec l’outil intégré `image_gen`, en utilisant la planche Horde comme référence de style uniquement. Aucun recours à la CLI/API externe. Les pixels des fichiers générés sont copiés sans retouche dans le projet ; ils possèdent un véritable canal alpha.

Le rendu utilise un cadre de la partie visible et un ancrage des pieds, définis dans `prototype/scripts/alliance_art.gd`, sans étirer les images. Des pixels quasi transparents de génération peuvent subsister dans les marges du PNG ; le cadre de dessin repose sur la zone visible (alpha > 8/255), avec deux pixels de marge. Le filtrage avec mipmaps conserve la lisibilité lors de la réduction. Le nain est plus petit que l’elfe et le mage.

Les six défenseurs partagent maintenant le même chemin de rendu. Les tables de textures et points de départ des tirs restent distinctes par faction et classe. La Horde conserve ses trois images et paramètres de la v0.60. Les badges indiquent toujours niveaux et branches. **Une seule pose par classe**, commune à ses niveaux et spécialisations ; recul au tir conservé, armes non animées indépendamment. Les variantes illustrées de spécialisation ne sont pas incluses dans ce lot.

Les coûts, dégâts, cadences, portées, effets, cibles, revenus, bonus, synergies, règles d’enchaînement et RNG ne changent pas. Les projectiles sont dessinés à partir de la position de l’équipement ; leurs dégâts restent résolus immédiatement par le modèle. Aucun nouveau personnage jouable ou mécanisme n’est ajouté. La disponibilité juridique de For the Fortress!, nom de travail, reste à confirmer.

## Validation technique

36 suites, 14 901 contrôles Godot dont 25 dédiés à ces ressources, 16 tests Python et contrats du GDD réussis. Les contrôles dédiés couvrent le canal alpha, les cadres, l’ancrage, les proportions, les points de départ des tirs, les ressources disjointes des factions et l’absence de mutation du modèle lors du rendu.

Le manifeste de distribution et son vérificateur comparent 24 sources : les 17 précédentes, `alliance_art.gd`, les trois PNG Alliance et leurs trois fichiers d’import. La détection de modification d’une image ou de ses paramètres d’import couvre les deux factions. Le [rapport de régression](essais/v061_regression.json) conserve le détail.

## Consignes exactes de génération

Mode : outil intégré. Fond transparent demandé à chaque appel. Référence de style pour les trois appels : `design/concepts/Horde_cartoon_v001.png`.

### archer

```text
Use case: stylized-concept. Asset type: one individual transparent PNG defender sprite for For the Fortress!, an isometric tower-defense game. Input image is STYLE REFERENCE ONLY: match this approved cartoon character family with thick dark contours, compact body, oversized expressive head and hands, flat frank colors, simple clean cel shading, sparse details. Create an ORIGINAL ALLIANCE character, not any Horde character from the reference. Full body and complete weapon visible, isolated and centered with small clear margins on genuine transparent alpha, feet on a horizontal baseline, slightly elevated three-quarter view facing viewer-right, the same camera angle as the reference. Designed for 60–70 px tall display: broad readable silhouette, no small ornamental detail. No floor, shadow, scenery, text, logo, signature, watermark, drawn checkerboard, extra character, additional weapon or brand insignia. Subject: ELF ARCHER. Slender but compact, very long pointed ears, pale warm skin, short swept blond hair and focused friendly face; leaf-green tunic, dark forest-green short cape, brown belt, bracers and boots, quiver visible behind one shoulder. Hold ONE large simple curved wooden longbow vertically on viewer-right, with a single nocked arrow aimed to viewer-right; both hands plausibly holding bow and string. Bow and pointed ears define the silhouette. Green and warm brown palette, no blue robe, no metal helmet. Keep both feet visible.
```

### arbaletrier

```text
Use case: stylized-concept. Asset type: one individual transparent PNG defender sprite for For the Fortress!, an isometric tower-defense game. Input image is STYLE REFERENCE ONLY: match this approved cartoon character family with thick dark contours, compact body, oversized expressive head and hands, flat frank colors, simple clean cel shading, sparse details. Create an ORIGINAL ALLIANCE character, not any Horde character from the reference. Full body and complete weapon visible, isolated and centered with small clear margins on genuine transparent alpha, feet on a horizontal baseline, slightly elevated three-quarter view facing viewer-right, the same camera angle as the reference. Designed for 60–70 px tall display: broad readable silhouette, no small ornamental detail. No floor, shadow, scenery, text, logo, signature, watermark, drawn checkerboard, extra character, additional weapon or brand insignia. Subject: DWARF CROSSBOWMAN. Short broad sturdy body, large expressive face with thick COPPER-ORANGE beard, broad nose, simple steel cap with a plain brass band; muted steel-blue tunic and shoulder guards, brown belt and large brown boots. Hold ONE large wooden-and-steel CROSSBOW horizontally in both hands across the chest, stock to viewer-left and short bolt pointing viewer-right. Distinct transverse bow limbs and thick central stock, mechanically plausible. Broad compact silhouette with short legs and complete feet visible. No axe, no bow, no gun, no hammer. Simple steel-blue, copper and brown shapes.
```

### mage

```text
Use case: stylized-concept. Asset type: one individual transparent PNG defender sprite for For the Fortress!, an isometric tower-defense game. Input image is STYLE REFERENCE ONLY: match this approved cartoon character family with thick dark contours, compact body, oversized expressive head and hands, flat frank colors, simple clean cel shading, sparse details. Create an ORIGINAL ALLIANCE character, not any Horde character from the reference. Full body and complete weapon visible, isolated and centered with small clear margins on genuine transparent alpha, feet on a horizontal baseline, slightly elevated three-quarter view facing viewer-right, the same camera angle as the reference. Designed for 60–70 px tall display: broad readable silhouette, no small ornamental detail. No floor, shadow, scenery, text, logo, signature, watermark, drawn checkerboard, extra character, additional weapon or brand insignia. Subject: HUMAN MAGE. Compact elderly human with pale warm skin, expressive brows and short white beard. Royal-blue robe with a few simple pale blue panels and restrained gold trim, wide pointed blue wizard hat, brown shoes peeking beneath the robe. Hold ONE simple wooden staff on viewer-right with a large luminous CYAN diamond crystal at its top; other hand open for casting. Blue robe, tall pointed hat and cyan crystal define the silhouette. Crystal glow is small and contained, not a large particle cloud. No purple hood, no fur collar, no skulls or totem, no bow or crossbow. Fully visible robe hem and feet.
```


## Contrôle du paquet Windows

74 lancements, 73 captures et 24 empreintes locales concordantes. Le [catalogue Alliance](essais/captures/QA-v061_alliance.png) montre les six emplacements avec des niveaux et branches distincts ; le [catalogue Horde](essais/captures/QA-v061_horde.png) vérifie les trois personnages précédents après la mise en commun du rendu. Le [mage en combat](essais/captures/QA-v061_mage_combat.png) et le [carreau de l’arbalétrier](essais/captures/QA-v061_arbaletrier_tir.png), ainsi que le tir de l’archer, ont été inspectés dans le paquet exporté. Les images sont transparentes, les équipements reconnaissables et les badges restent dégagés. Ces scènes utilisent un budget imposé pour présenter le contenu ; elles ne constituent ni une partie à budget normal, ni un retour humain, ni une validation générale d’équilibrage. Les lancements graphiques sont réservés à l’écran de droite et se ferment après capture. Les personnages restent dans une orientation illustrée fixe, sans rotation complète vers chaque cible.
