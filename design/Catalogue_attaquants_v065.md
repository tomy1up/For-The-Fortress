# Catalogue d’attaquants — v0.65

27 octobre 2026. Mise en jeu de la [règle d’origine et de la répartition proposée](Origine_ennemis_2026-10-27.md), après la demande de poursuivre le développement. Base de réalisation révisable après retour joueur, sans prétendre à une validation individuelle de chaque nom.

## Catalogue effectivement joué

| Profil statistique conservé | Joueur Horde : neutres ou Alliance | Joueur Alliance : neutres ou Horde |
| --- | --- | --- |
| Grouillant | Loup de meute — neutre | Loup de meute — neutre |
| Pillard | Fantassin humain — Alliance | Guerrier orc — Horde |
| Sprinter | Sanglier sauvage — neutre | Sanglier sauvage — neutre |
| Brute | Ours sauvage — neutre | Ours sauvage — neutre |
| Maraudeur | Éclaireur elfe — Alliance | Éclaireur gobelin — Horde |
| Colosse | Brise-remparts nain — Alliance | Colosse troll — Horde |
| Élite | Garde royal humain — Alliance | Garde noir mort-vivant — Horde |
| Seigneur de siège | Maréchal de l’Alliance — Alliance | Chef de guerre orc — Horde |

Treize identités au total, huit par campagne. Les identifiants `enemy.*` sont séparés des défenseurs construits. Le catalogue ne permet la résolution d’un attaquant de faction que dans la campagne adverse ; les trois neutres sont communs. Les huit types numériques restent les profils statistiques de la simulation. Les apparitions portent également l’identifiant, le nom et l’origine résolus. Les helpers sans faction restent disponibles pour les références historiques de profils, mais le jeu et les prévisions passent explicitement le camp défendu.

Les prévisions de vague, l’inspection, le boss et les aides de lancement utilisent les identités résolues. L’encart d’inspection indique l’origine dans sa ligne d’état existante, avec le statut de malédiction éventuel, sans ajouter de ligne. Le changement de faction invalide la prévision en cache. R-12 garde ses quatre profils bénéficiaires (3, 5, 6, 7), mais les détails listent maintenant les véritables noms des cibles. Un attaquant adverse peut être cité comme **cible** ; les bénéficiaires des bonus restent les défenseurs du camp joué.

## Trois planches transparentes utilisées en jeu

- [Faune neutre](../prototype/assets/enemies/rosters/neutres_v001.png) : loup, sanglier, ours.
- [Attaquants Alliance](../prototype/assets/enemies/rosters/alliance_v002.png) : fantassin, éclaireur elfe, brise-remparts nain, garde royal, maréchal.
- [Attaquants Horde](../prototype/assets/enemies/rosters/horde_v002.png) : guerrier orc, éclaireur gobelin, colosse troll, garde mort-vivant, chef de guerre.

Les trois PNG sont des atlas : des cadres de dessin isolent chaque silhouette sans retoucher les pixels. Ils sont créés avec l’outil intégré `image_gen` sur fond réellement transparent, dans le style de la planche Horde retenue. Les premières planches Alliance et Horde ont été corrigées avec le même outil pour séparer toutes les armes et silhouettes. Ces sources d’édition sont conservées dans [Alliance source](concepts/Ennemis_alliance_source_v001.png) et [Horde source](concepts/Ennemis_horde_source_v001.png). Les PNG finaux sont copiés tels quels dans le projet ; les mesures de cadres et de pieds n’en modifient pas les pixels.

Les treize cadres sont consignés dans `enemy_art.gd` ; les voisins d’un même atlas ont des rectangles disjoints. Hauteur de base de 34 px avant les échelles existantes des huit profils, proportions conservées, filtrage avec mipmaps, ancrage aux pieds. Orientation à gauche/droite selon le chemin et léger mouvement global de marche. Une seule pose par identité, sans articulation indépendante des membres. Ombres, jauges, marques de malédiction et réactions aux dégâts restent séparées. Les six PNG des défenseurs sont conservés ; les trois ennemis humanoïdes de la v0.64 sont archivés et ne sont plus embarqués dans la distribution.

## Rapports et compatibilité

Le rapport conserve son format 2 et reçoit un champ facultatif `enemy_catalog` indiquant les huit identités de la campagne. Le relevé de boss utilise son vrai nom. La version Markdown comprend le catalogue et le nom du boss. Le rejeu vérifie les origines et identités exportées, et détecte leur altération.

Les rapports historiques sans `enemy_catalog` sont encore rejouables : la comparaison attend alors le nom historique Seigneur de siège et le libellé historique de R-12. Les résultats, actions, RNG et autres contrôles restent stricts ; aucune réécriture du rapport fourni.

## Périmètre et validation

Aucun changement des dix calendriers de vagues, quantités, PV, vitesses, portées, dégâts, résistances, récompenses, règles de ciblage ou progression. La faune ne gagne pas de charge ou autre capacité ; le mort-vivant n’a ni immunité ni résurrection. Les boss gardent 600 PV. Le délai reste de 30 secondes, les choix roguelike attendent le joueur et le ×10 de débogage reste disponible.

40 suites, **15 974 contrôles Godot**, **16 tests Python**, contrats du GDD réussis. Les 670 contrôles du catalogue couvrent les origines, identités, dix vagues des deux campagnes, correspondance des prévisions, inspection, R-12, rapports, rejeu et exclusions. Les 154 contrôles graphiques couvrent les treize images, leurs cadres, transparence, proportions, pieds, survol, directions et lecture sans mutation du modèle. Les contrôles de cohérence des bénéficiaires de bonus restent actifs, avec distinction explicite de la ligne de cibles R-12.

Les campagnes de référence au budget normal conservent leurs résultats : Alliance 14 PV, 192 or, 178 éliminés et 4 passés ; Horde 12 PV, 189 or, 175 éliminés et 7 passés. Ces politiques de test ne constituent pas une validation générale d’équilibrage. Le [rapport de régression](essais/v065_regression.json) et la [distribution Windows](Distribution_Windows_v065.json) consignent les preuves. Les 32 sources de distribution incluent le catalogue, les trois atlas et leurs imports.

GDD principal v0.14 complété par cette note. Aucune progression permanente. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Consignes exactes de création

Mode : outil intégré `image_gen`, `transparent_background=true`. Les trois créations initiales utilisent `design/concepts/Horde_cartoon_v001.png` comme référence de style uniquement.

### Création neutral

```text
Use case: stylized-concept. Asset type: production transparent sprite ATLAS for the tower-defense game For the Fortress!, a single coordinated row of distinct enemy characters. Reference image is STYLE ONLY: bold dark contours, compact cartoon proportions, oversized expressive heads, simple clean cel shading, broad readable color shapes, very little detail. Original designs, no brand symbols. Each figure is complete, full body and all equipment visible, facing viewer-right in a slightly elevated three-quarter view. All figures share a horizontal feet baseline. A large transparent gap MUST separate neighboring figures and all equipment; no overlaps or touching silhouettes, no shared objects. Leave clear margins on every canvas edge. Wide landscape atlas. Genuine transparent alpha background, no floor or ground shadows, scenery, text, labels, grid, icons, watermark or drawn checkerboard. Each figure occupies its own equal-width column. Intended for tiny 24–60 px game display, silhouettes exceptionally simple. Exactly THREE creatures in THREE columns, LEFT TO RIGHT: (1) a compact lean grey WOLF with pointed ears, bushy tail and alert predatory expression, four visible paws, walking to the right; (2) a sturdy russet-brown WILD BOAR with a broad snout, short visible ivory tusks, short bristly mane and four hooves, walking to the right; (3) a large heavy dark warm-brown BEAR with round ears, broad muzzle, massive shoulders and four paws, walking to the right. Wolf smaller and leaner, boar medium squat, bear tallest and heaviest. All three are natural wildlife, no clothing, weapons, armor, magic, accessories or anthropomorphic hands. Exactly one of each creature and no extra animals.
```

### Création alliance

```text
Use case: stylized-concept. Asset type: production transparent sprite ATLAS for the tower-defense game For the Fortress!, a single coordinated row of distinct enemy characters. Reference image is STYLE ONLY: bold dark contours, compact cartoon proportions, oversized expressive heads, simple clean cel shading, broad readable color shapes, very little detail. Original designs, no brand symbols. Each figure is complete, full body and all equipment visible, facing viewer-right in a slightly elevated three-quarter view. All figures share a horizontal feet baseline. A large transparent gap MUST separate neighboring figures and all equipment; no overlaps or touching silhouettes, no shared objects. Leave clear margins on every canvas edge. Wide landscape atlas. Genuine transparent alpha background, no floor or ground shadows, scenery, text, labels, grid, icons, watermark or drawn checkerboard. Each figure occupies its own equal-width column. Intended for tiny 24–60 px game display, silhouettes exceptionally simple. Exactly FIVE different ALLIANCE ENEMY infantry characters in FIVE columns, LEFT TO RIGHT. Blue, steel and restrained gold identify their common camp. Warm natural skin, no green monster skin. (1) HUMAN FOOT SOLDIER: stocky tan human, plain round steel skullcap, blue short tunic and brown boots, ONE short steel sword upright, no shield or cape. (2) ELF SCOUT: lean elf with pointed ears, blond hair, short teal-blue hooded mantle, light leather clothing and TWO small knives, no bow or quiver. (3) DWARF SIEGEBREAKER: short very broad copper-bearded dwarf, bronze-and-steel heavy armor with blue cloth, ONE massive hammer held at the side, no crossbow or firearm. (4) HUMAN ROYAL GUARD: tall armored human, steel helmet with blue crest, blue-and-gold armor, large pointed BLUE SHIELD and ONE short sword, shield silhouette unmistakable. (5) HUMAN MARSHAL BOSS: largest imposing human veteran with grey moustache, ornate but simple gold-and-steel plate, tall blue-and-gold crested helmet, broad royal-blue cape and ONE large straight sword, no mount or shield. These are ATTACKING ENEMIES, visually distinct from the playable elf archer, dwarf crossbowman and blue-robed wizard; no bows, crossbows, wizard hats, staffs or spell effects.
```

### Création horde

```text
Use case: stylized-concept. Asset type: production transparent sprite ATLAS for the tower-defense game For the Fortress!, a single coordinated row of distinct enemy characters. Reference image is STYLE ONLY: bold dark contours, compact cartoon proportions, oversized expressive heads, simple clean cel shading, broad readable color shapes, very little detail. Original designs, no brand symbols. Each figure is complete, full body and all equipment visible, facing viewer-right in a slightly elevated three-quarter view. All figures share a horizontal feet baseline. A large transparent gap MUST separate neighboring figures and all equipment; no overlaps or touching silhouettes, no shared objects. Leave clear margins on every canvas edge. Wide landscape atlas. Genuine transparent alpha background, no floor or ground shadows, scenery, text, labels, grid, icons, watermark or drawn checkerboard. Each figure occupies its own equal-width column. Intended for tiny 24–60 px game display, silhouettes exceptionally simple. Exactly FIVE different HORDE ENEMY infantry characters in FIVE columns, LEFT TO RIGHT. Rust-red cloth, dark iron and brown leather identify their common camp. (1) ORC WARRIOR: broad green-skinned orc with small tusks, plain red bandana, red short tunic and simple brown boots, ONE short axe held upright, no staff or fur collar. (2) GOBLIN SCOUT: small lime-green goblin with very long pointed ears, red scarf, dark brown light leather clothes, TWO small knives, no goggles, bombs or satchel. (3) ARMORED TROLL COLOSSUS: towering turquoise troll, huge square jaw and small tusks, simple iron helmet, very heavy dark grey armor with red cloth and ONE massive spiked wooden mace, no throwing axe, taller and heavier than all ordinary characters. (4) UNDEAD BLACK GUARD: upright skeletal warrior with clearly visible pale bone face beneath a closed dark hood, dark iron and muted purple armor, a large black-violet pointed SHIELD and ONE sword, no glowing magical effects, no staff. (5) ORC WAR CHIEF BOSS: largest broad green orc with fierce tusks, massive red-and-iron plate shoulders, long dark red cape and ONE huge two-handed battleaxe, no staff, skull totem, bow, bombs or mount. No additional characters.
```

### Correction d’espacement alliance

Référence d’édition : `design/concepts/Ennemis_alliance_source_v001.png`.

```text
Use case: identity-preserve / precise-object-edit. Edit target: the attached FIVE-character Alliance sprite atlas. Preserve EXACTLY these five original character identities, costumes, weapons, faces, colors, style and left-to-right order. Change ONLY layout and scale to create usable independent source rectangles. On a wide genuine transparent alpha canvas, make EACH figure smaller and place its horizontal center at 10%, 30%, 50%, 70%, 90% of canvas width. Every figure, INCLUDING ALL WEAPONS AND CAPES, must fit in a maximum 14%-of-canvas-width bounding box centered at its assigned center. This leaves an entirely EMPTY transparent vertical gutter of at least 6% canvas width between each neighboring pair, from top to bottom. Feet aligned on one baseline near 85% canvas height. All equipment and bodies fully visible. Keep generous clear edge margins. No overlapping horizontal bounding boxes, no touching figures, no new figures, no floor or shadows, no labels, no text or drawn checkerboard. Do not redesign the characters or swap their weapons. The empty gutters are essential for the game renderer.
```

### Correction d’espacement horde

Référence d’édition : `design/concepts/Ennemis_horde_source_v001.png`.

```text
Use case: identity-preserve / precise-object-edit. Edit target: the attached FIVE-character Horde sprite atlas. Preserve EXACTLY these five original character identities, costumes, weapons, faces, colors, style and left-to-right order. Change ONLY layout and scale to create usable independent source rectangles. On a wide genuine transparent alpha canvas, make EACH figure smaller and place its horizontal center at 10%, 30%, 50%, 70%, 90% of canvas width. Every figure, INCLUDING ALL WEAPONS AND CAPES, must fit in a maximum 14%-of-canvas-width bounding box centered at its assigned center. This leaves an entirely EMPTY transparent vertical gutter of at least 6% canvas width between each neighboring pair, from top to bottom. Feet aligned on one baseline near 85% canvas height. All equipment and bodies fully visible. Keep generous clear edge margins. No overlapping horizontal bounding boxes, no touching figures, no new figures, no floor or shadows, no labels, no text or drawn checkerboard. Do not redesign the characters or swap their weapons. The empty gutters are essential for the game renderer.
```


## Lisibilité après achat

Après un achat réussi à la souris, le pointeur peut rester sur la commande qui remplace le bouton de recrutement. Son aide de vente ou son aperçu d’amélioration reste masqué jusqu’à la sortie de cette zone. Un nouveau survol et la navigation clavier donnent accès aux informations habituelles. Les achats, ventes et améliorations conservent leurs règles et coûts. Dix contrôles supplémentaires couvrent les deux factions, le retour des aides et le nouvel essai.

## Paquet Windows et essais natifs

88 lancements, 87 captures et 32 empreintes locales concordantes. Les deux catalogues ont été inspectés : [joueur Alliance](essais/captures/QA-v065_joueur_alliance.png), [joueur Horde](essais/captures/QA-v065_joueur_horde.png). Les [cibles de R-12](essais/captures/QA-v065_bonus_cibles.png) et la [faune sous malédiction](essais/captures/QA-v065_faune_malediction.png) restent lisibles. Les rapports issus du paquet contiennent huit identités autorisées et le vrai nom du boss.

Deux contrôles natifs de la compilation intermédiaire v0.65, avant la dernière correction de présentation de l’origine dans l’encart, ont été opérés sur l’écran de droite à ×1, avec le budget normal de 150 or. Alliance : archer E1 et arbalétrier E2, face aux guerriers orcs ; [première vague terminée](essais/captures/QA-v065_native_alliance.jpg) en 23,5 secondes simulées, 10 éliminés, aucun passé, 20 PV et 55 or. La deuxième vague est ensuite partie automatiquement avant la fermeture. Horde : troll E1 et sapeur E2 face aux fantassins humains puis aux loups ; [deuxième vague terminée](essais/captures/QA-v065_native_horde.jpg) à 75,4 secondes simulées cumulées, avec 19 PV, 92 or, 17 éliminés et un passé dans cette deuxième vague. Aucun achat supplémentaire n’a été effectué. Le compte à rebours de la troisième vague est visible. Les journaux dédiés ne contiennent aucune erreur et le jeu a été fermé. Ces essais partiels opérés par l’agent ne constituent ni deux campagnes natives complètes ni un nouveau retour humain.
