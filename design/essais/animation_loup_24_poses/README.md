# Loup — candidat de marche à 24 poses

Statut au 1 novembre 2026 : **essai à valider par le porteur du projet**, hors production. La v0.105 conserve son animation historique, précédemment rejetée. Ce dossier ne constitue pas une nouvelle version jouable publiée.

## Aperçu

`Loup_24_poses_essai.mp4` montre huit secondes sur le trajet du plateau : quatre secondes à taille de jeu, puis quatre secondes agrandies ×3. La simulation avance à vitesse normale ; trois loups suivent le trajet et le premier change de direction. L'atelier ne charge aucun profil joueur. Le cadrage agrandi suit le premier loup ; le décor permet de lire le déplacement relatif.

La capture comporte 480 images à 60 ips. Le sprite utilise 24 poses par cycle, un cycle par seconde à la vitesse normale du loup. Une vidéo à 60 ips ne transforme pas ces 24 poses en 60 dessins différents.

## Fabrication et contrôle

La planche `loup_24_poses_candidat.png` a été produite avec l'outil intégré ImageGen, en conservant comme référence le loup de `prototype/assets/enemies/rosters/neutres_v001.png`. Le guide de mouvement comporte 24 phases du cycle Walk du modèle Wolf de Quaternius, rendu dans un atelier externe Godot. Le modèle 3D ne remplace pas le dessin du jeu.

Référence de mouvement : [Ultimate Animated Animal Pack](https://quaternius.com/packs/ultimateanimatedanimals.html), auteur Quaternius, licence CC0 ; [conditions](https://quaternius.com/faq.html). Le guide rendu est conservé ici pour tracer la référence utilisée.

Contrôle effectué : silhouette cartoon et raccords des quatre pattes examinés sur la planche ; rendu sur le trajet examiné sur plusieurs phases et au changement de direction ; capture exécutée sans erreur. Cela ne constitue pas une validation artistique définitive. La cadence, les appuis et la stabilité de la boucle restent à apprécier dans la vidéo. Le second contexte de faction et les interactions de combat devront être contrôlés avant intégration.

Les rangées générées ne sont pas parfaitement espacées. Le script utilise leurs limites effectives et un décalage d'enregistrement par rangée ; les PNG sont préservés sans retouche. Les statistiques, sauvegardes et fichiers de production ne sont pas modifiés.

## Reproduire l'atelier

Depuis PowerShell, avec Godot standard et le paquet Windows v0.105 présents localement :

```powershell
& 'C:\Projet\.tools\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe' --main-pack 'C:\Projet\For the Fortress!\dist\For_the_Fortress_v0.105_Windows_x64\For_the_Fortress.exe' --screen 1 --script 'C:\Projet\For the Fortress!\design\essais\animation_loup_24_poses\capture_candidate.gd'
```

Les images de capture sont écrites dans `C:\Projet\.tools\wolf24_candidate\frames`. L'atelier se ferme après capture. Les scripts de ce dossier ne sont pas chargés par le jeu.

## Prompt de génération

Outil : ImageGen intégré ; deux références : identité/style du loup original et guide de mouvement. Prompt utilisé :

> Create a production 2D animation spritesheet, 2304x1152, exact regular grid SIX columns by FOUR rows, 24 sequential walk poses reading left-to-right then top-to-bottom. Image 1 is CHARACTER IDENTITY AND STYLE reference: use ONLY its first animal, the gray cartoon wolf, never boar or bear. Preserve wolf's large head, yellow eyes, gray and cream fur, thick dark clean outlines, compact sturdy proportions and chunky paws. Image 2 is MOTION/POSE GUIDE ONLY: it contains 24 successive phases of one complete natural quadruped WALK cycle. For each output cell faithfully follow corresponding guide leg pose and foot contact phase but draw the approved 2D cartoon wolf from Image1, facing RIGHT, fixed three-quarter side camera. Translate guide joints to chunky cartoon anatomy without thin rods or detached legs. Exactly four connected legs, nearer pair light and far pair darker; visible natural knees/hocks, paws planted during stance and lifted during recovery, no running or jumping. Keep head design, fur markings, body width/height, outline weight, scale and body anchor identical across all 24 frames, only subtle natural weight shift; no pose duplications. Last frame leads smoothly into first. Each frame confined to its equal 384x288 cell with generous padding and common ground baseline and body registration, full tail and ears. Truly TRANSPARENT background, no ground, no shadows, no text, no grid, no labels. This is a usable aligned animation sheet, not a concept illustration. Every pose must be distinct and anatomically sound.

Dimensions réellement obtenues : 1774 × 887 pixels. Les exigences du prompt sont des objectifs de génération, pas une preuve qu'elles sont toutes satisfaites.
