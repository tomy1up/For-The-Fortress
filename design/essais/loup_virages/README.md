# Loup de face en virage

Candidat ImageGen realise avec loup_corps_v002.png comme reference. La vue de face est destinee aux virages vers le bas du plateau. Trois appuis sont visibles sur cette pose. Le quatrieme reste masque par le corps. Le dessin sert de reference de volume et de palette pour la transition, avec des appuis encore a construire.

## Consigne de generation

Create a single full body transparent 2D game sprite of this exact grey cartoon wolf seen HEAD ON, facing screen bottom toward camera, from the same raised isometric game camera. Match golden eyes, grey and cream fur, dark line, flat shading and adult wolf proportions exactly. It is mid-step into a turn, shoulders and haunches anatomically connected, show four real paws with natural overlap and readable stance. No floor, shadow, glow, text, or other objects. Keep centered with transparent margin.

## Vue de dos

Candidat de volume et de palette pour la sortie vers le haut du plateau. Les quatre pattes se distinguent. Les coussinets visibles demandent une verification des appuis en mouvement avant integration.

Draw one full body 2D game sprite on transparent background of the exact grey cream cartoon wolf in the two references, seen directly from BEHIND, moving away toward top of screen, matching the elevated isometric camera. The back of the head and both ears are visible at the top, no eyes, muzzle or face visible. Torso, hocks and feet anatomically joined. Tail lowered and slightly off center, no giant tail. Show two clearly distinguishable hind paws and two partially visible forepaws in a natural walk turn pose. Preserve exact grey and cream color palette, heavy dark contours, angular fur and flat shading of references. No floor shadow glow text or other objects. One full silhouette with ample transparent margins.

## Variante de face avec quatre pattes visibles

La variante rend les quatre pattes distinctes. La patte avant tendue reste du meme cote que sur la premiere pose. Garder cette image comme reference anatomique pour le raccord. Une vraie inversion d'appui reste a dessiner.

Draw the exact same grey cream wolf sprite from the exact same front elevated isometric camera and matching head and body dimensions. Draw the next walk pose, with the previously extended front paw now bending and lifting while the other front paw extends and plants. Keep nose and head centered, shift the chest slightly over the new supporting paw. Show both hind legs clearly with natural overlapping anatomy where possible. Same coat shapes, dark outline, gold eyes, and flat palette. One full body sprite, transparent background, no floor, shadow, or labels.

## Trois quarts avant

Dessin intermediaire entre le profil et la face. Les quatre pattes sont lisibles et la queue plus haute devra etre raccordee en mouvement.

One isolated 2D game sprite, same exact grey and cream cartoon wolf from the references. Draw an intermediate raised isometric angle between the two images: nose points diagonally DOWN RIGHT, about 35 degrees right of the straight-towards-viewer pose. The visible flank and rear body extend toward the upper left. All four anatomically connected paws, staggered walk with front screen-right paw forward and an opposite rear paw planted. Match fur, head size, eyes, black outlines and palette. Keep real perspective and proportions, no stretching. Transparent background, no floor, glow, shadow or labels.

## Trois quarts arriere

Candidat ImageGen pour les virages vers le haut. La vue de dos et le profil du loup ont servi de references.

Single transparent 2D game sprite of this exact grey and cream wolf. Rear three-quarter view, walking towards upper right, raised isometric camera. Rear and flank visible, head facing AWAY upper right, no eye visible. Four anatomically connected readable paws with staggered walk, weight on one rear and opposite front paw. Natural wolf proportions matching reference, angular gray cream fur and dark outline, medium tail held low with cream tip, no floor shadows glow text or other objects. Full body centered.

## Recentrage du trois quarts avant

Capture de 144 images sur le Gue. Les coordonnees sont celles du dessin source.

| Centre | Saut maximal entre vues | Derive maximale sur un appui |
| --- | --- | --- |
| (620, 898), reference | 8,69 px | 11,21 px |
| (655, 910) | 7,91 px | 11,70 px |
| (745, 975) | 10,31 px | 15,24 px |

Conserver le centre de reference. Au sixieme virage, la translation qui rapproche une patte de son point de contact eloigne l'autre. Reprendre la disposition relative des deux appuis.

Une rotation autour du centre des appuis, ajustee sur les contacts et bornee a 12 degres, donne 11,25 px de derive maximale contre 11,21 px avec la correction precedente. Le maillage reste valide sur les 144 images. L'essai est ecarte.

## Trois quarts avant, pas court

Variante v002 dessinee avec ImageGen a partir du trois quarts v001 et de la face v002. Conserver la meme echelle uniforme que le trois quarts v001, afin que la queue plus basse ne grossisse pas le personnage.

Redraw the first exact grey cream wolf from the same raised front three-quarter direction, keeping head, body, angle and palette. Change the stride to a SHORT compact passing step for turning, not a long running stride: tuck the leftmost rear foot forward under the hips, and bring the rightmost front foot back under the shoulder, reducing their screen-horizontal gap by roughly 35 percent and their vertical gap by roughly 25 percent. Keep normal leg lengths by flexing joints and adjusting posture, four distinct anatomically attached paws. Match the closer supports of the second reference, but preserve the first image's direction. Tail low, match angular fur outlines. Single full sprite with transparent background, no floor, shadow, text or glow.

## Fenetre de la vue de face

Mesure sur les memes six loups du Gue. La demi-fenetre est une fraction de la duree de la courbe.

| Demi-fenetre | Saut entre vues | Derive maximale |
| --- | --- | --- |
| 0,07 | 6,54 px | 8,31 px |
| 0,10, reference | 6,50 px | 7,84 px |
| 0,13 | 6,47 px | 7,84 px |
| 0,16 | 6,45 px | 7,84 px |

Les gains ne justifient pas d'allonger la vue de face. Garder 0,10. Le parametre de capture --front-window permet de reproduire les mesures.
