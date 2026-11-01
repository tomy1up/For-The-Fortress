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

## Guide dessiné de la pose 8/12

Outil ImageGen intégré, transparence demandée. Entrées : source continue du loup (identité), capture `corrective_08.png` (pose à corriger). Résultat copié sans modification sous `pose_passage_dessinee_v001.png`. Guide uniquement ; cadrage et proportions non conservés assez précisément pour une frame.

```text
Use case: precise-object-edit. Asset: single drawn corrective key pose for a 2D cartoon wolf walk, NOT an animation sheet. Input 1 is the identity/style reference: preserve this exact stocky gray and cream wolf, yellow eyes, large black outlines, face, fur markings and short powerful canine build. Input 2 is the edit target and exact pose/framing guide; it has ugly pinching at the near hip and shoulder. Redraw ONLY the wolf from input 2 as a coherent anatomically sound animal in the SAME mid-stride pose facing right. Remove the text, dark background and ground line; output genuine transparent background. Keep all four legs and their same general foot positions from input 2: near forepaw drawn inward below the chest, far foreleg stretched to the right; near hindpaw inward under the pelvis, far hindleg behind. Make each visible upper limb flow continuously from its shoulder or hip, with natural muscle mass and fur, no creased collapsed pelvis, no tiny disconnected limb stuck under the belly, no black outline cutting across a limb root. The shoulder supports the chest; the thigh emerges from a broad connected rump, knee angles forward and hock bends backward. Do not add accessories, extra feet or legs. Keep torso length, head size and coat colors from the reference, no recoloring, no realism style, no glow, no ground shadow. Match the 1280x800 canvas of input 2 if possible, wolf located exactly in the same area and at the same scale as the wolf in input 2 so this can be assessed against the original pose. One wolf only, no text, no comparison panels.
```

## Édition localisée non retenue

Outil ImageGen intégré, transparence demandée. Entrées : capture originale `corrective_08.png` (cible), guide précédent (forme de hanche seulement). Le résultat change encore les proportions et le cadrage ; il n’est pas intégré.

```text
Use case: precise-object-edit. Input 1 is the EXACT edit target. Input 2 is ONLY a reference for repairing the pinched near hip; DO NOT copy its changed head proportions. Surgical localized correction of the gray wolf in input 1, for an animation key frame. Preserve input 1's exact wolf size, head size, face angle, ear positions, head outline, eyes, nose, tail, spine, shoulder, four foot positions, near foreleg and far legs. Keep the subject at the same coordinates and scale within the original 1280x800 canvas, with nose at approximately (875,415) and foot bottoms at approximately y540. Change only the collapsed fur/crease at the near hip where the thigh meets the rump: make a smooth fleshy canine thigh attachment like input 2, flowing into the belly and rump, with no ugly inward pinch. Preserve the tiny image's existing head/body ratio exactly; do not beautify or redraw the whole character, do not make its head smaller, do not lengthen its legs. Strip away the text, ground line, and green background to genuine transparency. Single wolf only, same pose and framing, black clean outlines, existing gray and cream palette, yellow eyes. No extra feet or accessories, no shadows, no glow. This is a registered pose repair, not a new wolf illustration.
```
