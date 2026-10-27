# Assets individuels Horde — v0.60

27 octobre 2026. Mise en jeu du style de la [planche Horde validée](concepts/Direction_cartoon_Horde_v001.md).

## Livrables et intégration

| Classe | Image transparente | Hauteur sur le plateau |
| --- | --- | --- |
| Lanceur de haches troll | [troll_v001.png](../prototype/assets/units/horde/troll_v001.png) | 66 px |
| Sapeur gobelin | [gobelin_v001.png](../prototype/assets/units/horde/gobelin_v001.png) | 48 px |
| Chaman orc | [chaman_v001.png](../prototype/assets/units/horde/chaman_v001.png) | 66 px, bâton et effet compris |

Les trois PNG individuels reprennent la planche retenue par le porteur du projet : troll turquoise à crête rouge et hache, petit gobelin vert avec lunettes et bombe, chaman orc en robe violette avec totem. Les fichiers possèdent un vrai canal alpha, sans fond opaque ni ombre incorporée. Ils ont été produits séparément avec l’outil intégré `image_gen`, à partir de la planche comme référence d’identité. Aucun recours à la CLI/API externe. Les images originales sont copiées dans le projet sans modification de leurs pixels.

Le rendu du plateau cadre la partie utile de chaque image, conserve ses proportions et ancre le personnage par les pieds. Les cadres et ancrages sont consignés dans `prototype/scripts/horde_art.gd`. La taille relative du gobelin est plus petite. Le filtrage avec mipmaps évite le crénelage lors de la forte réduction. Une ombre discrète est dessinée par le jeu.

Les badges des niveaux et branches restent affichés séparément. Chaque classe utilise pour l’instant **une pose illustrée**, commune à ses niveaux et spécialisations ; ce ne sont pas encore des feuilles d’animation. Le recul bref du personnage au moment des vrais tirs est conservé. Les armes sont comprises dans l’image : elles ne disposent pas encore de mouvements indépendants. Les points de départ des projectiles ont été adaptés à leurs positions visuelles.

## Périmètre

Les trois classes Horde utilisent ces images dans la v0.60. Les défenseurs Alliance et les ennemis conservent leurs silhouettes actuelles. La portée, les emplacements, les décisions de ciblage, la cadence, les dégâts, les prix, les bonus et les vagues sont inchangés. Aucune progression permanente introduite. La lisibilité définitive et les animations détaillées restent à évaluer pendant les essais joueurs.

## Vérification

35 suites, **14 876 contrôles Godot**, **16 tests Python** et contrats du GDD réussis. Les 21 contrôles nouveaux vérifient le chargement des trois textures, leur alpha, les cadres, l’ancrage au sol, les proportions, les départs de projectiles, les tailles relatives et la lecture sans mutation du modèle. Un test Python supplémentaire contrôle le rejet d’un PNG ou de paramètres d’import devenus différents du paquet annoncé.

Le suivi des sources inclut désormais **17 fichiers** : les dix sources précédentes, le module d’illustrations, les trois PNG et leurs trois fichiers d’import. Les images et les paramètres d’import sont aussi surveillés pendant la régression. Les contrôles Windows et natifs sont consignés dans Distribution_Windows_v060.json.

## Consignes exactes de génération

Référence : `design/concepts/Horde_cartoon_v001.png`. Trois appels indépendants au générateur intégré, chacun avec `transparent_background=true`. Les noms ci-dessous désignent des assets et non des variantes de mécanique.

### troll

```text
Use case: identity-preserve / background-extraction. Asset type: one individual transparent PNG character asset for the tower defense game For the Fortress!. Input image is the APPROVED original concept board; preserve the selected character's exact visual identity, thick dark contours, compact cartoon proportions, expressive face, clean cel shading, outfit colors, equipment and pose. Isolate ONLY the specified character, with the other two characters completely absent. Recreate it faithfully as a clean game cutout, not a new character design. Full body and all equipment visible, generous small clear margins, centered on an otherwise genuinely transparent alpha canvas. No floor, no oval ground shadow, no scenery, no text, no signature, no watermark, no backdrop color, no drawn checkerboard. Character faces the same three-quarter direction as in the reference; keep its feet on a horizontal baseline. Crisp opaque colored shapes with antialiased alpha edges, strong silhouette suitable for 48–68 pixel game display. Select the LEFT turquoise-blue TROLL AXE THROWER: red crest, large pointed ears, small tusks, broad throwing axe held in his right hand on viewer's left, brown leather harness, simple brown waist cloth and wraps, turquoise bare feet. Keep ONE axe. Do not turn him green or give him armor, a shield, bomb or staff.
```

### gobelin

```text
Use case: identity-preserve / background-extraction. Asset type: one individual transparent PNG character asset for the tower defense game For the Fortress!. Input image is the APPROVED original concept board; preserve the selected character's exact visual identity, thick dark contours, compact cartoon proportions, expressive face, clean cel shading, outfit colors, equipment and pose. Isolate ONLY the specified character, with the other two characters completely absent. Recreate it faithfully as a clean game cutout, not a new character design. Full body and all equipment visible, generous small clear margins, centered on an otherwise genuinely transparent alpha canvas. No floor, no oval ground shadow, no scenery, no text, no signature, no watermark, no backdrop color, no drawn checkerboard. Character faces the same three-quarter direction as in the reference; keep its feet on a horizontal baseline. Crisp opaque colored shapes with antialiased alpha edges, strong silhouette suitable for 48–68 pixel game display. Select the MIDDLE small lime-green GOBLIN SAPPER: huge pointed ears, oversized round golden goggles, mischievous grin, ochre wrapped tunic, brown satchel, ONE round dark bomb with short lit fuse in his left hand on viewer's right, green feet. Preserve compact small body. No axe, no staff, no gun.
```

### chaman

```text
Use case: identity-preserve / background-extraction. Asset type: one individual transparent PNG character asset for the tower defense game For the Fortress!. Input image is the APPROVED original concept board; preserve the selected character's exact visual identity, thick dark contours, compact cartoon proportions, expressive face, clean cel shading, outfit colors, equipment and pose. Isolate ONLY the specified character, with the other two characters completely absent. Recreate it faithfully as a clean game cutout, not a new character design. Full body and all equipment visible, generous small clear margins, centered on an otherwise genuinely transparent alpha canvas. No floor, no oval ground shadow, no scenery, no text, no signature, no watermark, no backdrop color, no drawn checkerboard. Character faces the same three-quarter direction as in the reference; keep its feet on a horizontal baseline. Crisp opaque colored shapes with antialiased alpha edges, strong silhouette suitable for 48–68 pixel game display. Select the RIGHT moss-green ORC SHAMAN: broad jaw and small tusks, purple hood and robe, pale fur shoulder collar, simple rope belt, green feet, wooden staff with a simple horned bone skull totem and small purple magical curl. Preserve the reference's silhouette. No axe or sword. Do not make a new warrior.
```

GDD principal v0.14. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Contrôle final du paquet

74 lancements, 73 captures et 17 empreintes locales concordantes. Le [catalogue Horde](essais/captures/QA-v060_horde.png), à budget imposé pour montrer les niveaux, et le [chaman en combat](essais/captures/QA-v060_chaman_combat.png), également en scène de contrôle, ont été inspectés dans le paquet Windows. Les images sont transparentes et leur réduction filtrée conserve des formes lisibles.

Un contrôle natif séparé du même exécutable a été effectué sur l’écran de droite avec le budget normal de 150 or : troll E1 et sapeur E2, première vague en ×1. La [fin de vague](essais/captures/QA-v060_premiere_vague_native.jpg), après 24,5 secondes simulées, montre 10 éliminés, aucun passé, 20 PV et 55 or restants. Le décompte suivant est visible. Le journal dédié ne contient aucune erreur et le jeu a été fermé. Le chaman est vérifié dans les captures du paquet, sans prétendre qu’il a été acheté lors de ce contrôle natif. Cet essai opéré par l’agent ne constitue ni un retour joueur ni une validation générale d’équilibrage.
