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

Un essai de selection du raccord par phase de marche a privilegie les instants avec le moins de pattes au sol. Les pattes des groupes 1 et 2 comptaient davantage dans le choix. Sur la capture du Gue, le saut maximal passe de 6,502 a 6,465 px et la derive reste a 7,836 px. La variante est ecartee.

## Face, pas court

Variante v003, generee avec ImageGen a partir de la face v002 et du trois quarts avant v002. Echelle uniforme conservee. La silhouette montre davantage le flanc, ce qui reste a juger sur la sequence complete.

One transparent 2D game sprite. Redraw the exact grey cream wolf of the first image in the same head-on elevated camera, nose aimed down screen, at the short compact mid-turn gait of the second image. Reduce the distance between the rearmost and leading front foot by flexing the foreleg and bringing the rear foot under the pelvis. Keep four distinct anatomically attached feet, with clear visible contact on a front foot and the opposite rear foot. Keep head scale, gray cream palette, gold eyes, linework, angular fur; keep the tail low behind the body. Do not stretch the silhouette. No ground, cast shadow, glow or text.

## Comparaison des deux dessins de face

Relancer `res://tools/qa_wolf_ingame.gd -- --wolf-pivot` avec puis sans `--previous-front` pour comparer les dessins v002 et v003 sur les memes six virages. Les captures sont separees par variante et par phase initiale (`--id-offset=3`).

| Decalage | Derive maximale | Saut maximal entre vues | Aire double minimale |
| --- | --- | --- | --- |
| 0 | 6,676 px | 5,916 px | 0,159 px² |
| 3 | 8,508 px | 6,201 px | 0,118 px² |

Les deux dessins donnent les memes mesures. Ces mesures portent sur les points du maillage, communs aux deux textures. Pour juger le raccord des appuis dessines, il reste a verifier leur position dans chaque texture et a comparer les captures a la taille du plateau. Essai isole du jeu distribue.

Les mesures ci-dessus precedaient le recalage du dessin v002. La comparaison utilise maintenant un cadrage et quatre reperes de pattes propres a ce dessin, releves visuellement. A decalage 0, la v002 recalee donne 6,671 px de derive, 5,986 px de saut et 0,135 px2 d'aire double minimale. La v003 conserve 6,676 px et 5,916 px. L'ecart est trop faible pour retenir une variante sur ces mesures seules.

## Translation du dessin pendant le virage

Essai avec le dessin v003 et `--turn-shift=0` ou `--turn-shift=4`. Le plafond par defaut reste a 2 px. Le parametre deplace la pose entiere sans ajouter d'etirement.

| Plafond | Decalage 0, saut maximal | Decalage 3, saut maximal |
| --- | --- | --- |
| 0 px | 6,086 px | 6,492 px |
| 2 px | 5,916 px | 6,201 px |
| 4 px | 5,053 px | 5,380 px |

Le raccord de face vers le trois quarts est le pire avant correction dans ces essais. Le plafond de 4 px reduit le saut entre vues, mais a la phase 3 le deplacement maximal entre deux images d'une meme vue passe de 0,812 a 1,009 px. Les triangles restent valides. Il reste a comparer visuellement le deplacement du corps par rapport au chemin avant de changer le reglage de reference.

Le [comparatif au ralenti](comparatif_translation.mp4) montre les six virages avec le meme cadrage, a la phase initiale 3. A gauche, plafond de 2 px. A droite, plafond de 4 px. Le recadrage conserve l'echelle du jeu et la video est ralentie de moitie. Les 144 images proviennent de captures dans la scene du Gue avec un profil isole. Les loups sont places a l'avance pres des virages pour faciliter la comparaison.

Le suivi de la translation du corps inclut aussi le retour au profil. Dans les quatre captures (decalages 0 et 3, plafonds 2 et 4 px), le saut maximal de la translation entre deux images atteint exactement le plafond teste. Le gain sur les pattes a 4 px s'accompagne donc d'un a-coup du corps de 4 px. Conserver le reglage de reference pour l'atelier tant que la translation n'est pas raccordee progressivement au profil.

### Retour progressif au profil

Avec `--turn-shift=4 --taper-turn-shift`, le decalage du corps revient progressivement a zero aux deux bords de la zone du virage. Sur les six virages du Gue, le saut maximal de translation descend de 4 px a 1,211 px (decalage 0) et 1,474 px (decalage 3). Le saut d'appui entre deux vues reste de 5,053 et 5,380 px. Le saut maximal dans une meme vue augmente de 1,022 a 1,728 px et de 1,009 a 1,587 px. Aucun triangle retourne sur les deux captures de 144 images. Garder cet essai optionnel pour la comparaison visuelle.

### Impact pendant le virage, cote Horde

Le [comparatif au ralenti](comparatif_horde_impact.mp4) utilise `--horde --wolf-pivot --wolf-hit --id-offset=3`. A gauche, reglage de reference a 2 px. A droite, retour progressif a 4 px. Chaque capture declenche six evenements de degats a l'image 42, avec un profil isole. Les 144 images du montage ont ete decodees sans erreur. Les mesures de translation excluent le recul ajoute par le rendu de combat. Le passage de 6,201 a 5,380 px entre vues concerne donc les appuis du virage seul.
