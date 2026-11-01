# Consignes ImageGen — étude de peau continue

Outil : ImageGen intégré. Images de préparation, sans validation artistique ou intégration au jeu.

## Base retenue pour l’étude

Référence : `prototype/assets/enemies/rosters/neutres_v001.png`, premier animal seulement. Transparence demandée. Résultat copié sans modification sous `loup_proche_source_v001.png`.

```text
Edit/reference role: use ONLY the first grey cartoon wolf in the provided atlas as the identity and style reference. Create ONE animation-rigging source illustration, not an animation sheet. Preserve this wolf's exact grey and cream fur palette, yellow eyes, chunky proportions, black line weight and friendly fierce fantasy cartoon design. Full body facing RIGHT in a clean side/three-quarter-side view, calm neutral standing pose. Main requirement: the torso, near-side shoulder and foreleg, and near-side haunch and hindleg are drawn as ONE anatomically continuous animal with uninterrupted fur and shared volume. Exactly TWO visible legs: the nearer foreleg and nearer hindleg. REMOVE the far-side two legs entirely, leaving transparent space between the two near legs for rigging. Both near paws on the same horizontal baseline, beneath their respective shoulder/hip rather than an extreme stride. Foreleg nearly vertical with a gentle elbow, hindleg anatomically bent with broad furry thigh and recognizable hock. Short sturdy wolf legs, broad paws. Natural visible transitions from chest into upper foreleg and rump into thigh; NO detached limbs, NO circular joint caps, NO horizontal body outline drawn across the limb roots, NO disjoint shoulder rings, NO mechanical sockets. Head, torso, tail and both near legs form a single finished continuous character silhouette. Entire wolf centered with generous transparent margins, no clipped ears/tail/paws. No other animals, no additional body parts, no labels, no grid, no scenery, no shadows. Truly transparent background. This is a new experimental rigging base preserving the supplied character, not a redesigned wolf.
```

## Tentative de nettoyage non retenue

Résultat `exec-04f8a961-e631-4c13-a85c-f8dd0850e8c0.png`, laissé à son emplacement de génération. Cadrage non préservé et frange toujours visible : cette sortie ne remplace pas la base.

```text
Precise cleanup edit of this experimental two-visible-leg wolf rigging source. Preserve EXACTLY the wolf drawing, pose, proportions, markings, grey/cream/yellow palette, black outline, dimensions and location. Change ONLY the background/edge transparency: remove every grey or black soft halo, glow, cast shadow and background wash outside the actual solid black character contour. Outside the character silhouette must be fully transparent alpha=0. Keep interior fur, eyes and outline fully opaque with crisp clean anti-aliased edges. Do not add the far legs, do not redraw the pose, do not recolor or change the character. This must be a clean isolated continuous character sprite on genuinely transparent background, with no shadow.
```
