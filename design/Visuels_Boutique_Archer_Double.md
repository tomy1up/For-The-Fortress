# Boutique · Archer double

Le type 23 (`alliance.doublearcher`) inflige +90 % de dégâts aux ennemis déjà blessés. Proposition du 14 novembre 2026 pour sa pose sur le plateau : arc ivoire abaissé, main au carquois et écharpe safran. Le porteur a donné un avis favorable à l’apparence. Le comparatif montre la variante de pose retenue pour l’essai.

[Comparatif sur le plateau](essais/boutique_guetteurs/Archer_double_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur |
| --- | --- | --- | ---: |
| `archer_double_v001.png` | `Rect2(0,0,1125,1349)` | `(510,1349)` | 60 px |

Portrait, déblocage, recrutement et premier tir vérifiés sur copie v0.197, avec 90 contrôles d’illustrations réussis. Le sprite est fixe. Pour l’animation, la main au carquois saisit une flèche, l’arc se relève, puis la flèche part au lâcher. Ajuster le point de départ à la pose de lâcher lors du branchement de l’animation. Conserver le tir unique et le bonus sur cible blessée.

## Prise au carquois et tir

L’Archer double saisit une flèche, relève son arc ivoire, puis ramène la corde sous le menton. Les épaules accompagnent le relevé, les pieds restent ancrés et le bras de corde poursuit son geste après le lâcher. L’arc redescend avant le retour de la main au carquois.

[Capture sur la mission 94 à taille réelle](essais/gestes_combat/archer_double/Archer_double_en_jeu.gif)

La garde et les cinq inclinaisons de `defender.alliance.doublearcher` sont dans `essais/gestes_combat/archer_double/`. Chaque planche compte 24 poses sur 0,96 s. La flèche est visible sur l’arc jusqu’à la pose à 0,56 s. Le départ est à 0,60 s, sur la première pose après le lâcher. `lachers.json` donne la position de la pointe depuis le pied sur la dernière pose encochée. Choisir parmi 0°, ±12° et ±36° à partir du trajet depuis chaque pointe candidate. Retourner le repère avec la pose. La pointe du projectile dessiné par le jeu suit le segment de départ jusqu’à l’impact. Le tir unique et le bonus sur cible blessée restent ceux du type 23.

Six tirs à ×1 et ×2 sur la copie v0.223, sur la mission 94, à droite en descente à +36° et à gauche avec la pose neutre. Pose figée en pause et 17 positions vérifiées par trajet. Les autres inclinaisons ont été contrôlées sur planche. Les 120 poses gardent les semelles identiques, restent dans leur cadre et reprennent la garde au dernier dessin. Le validateur a relevé 39 dossiers et zéro problème. Les 180 contrôles de la bibliothèque passent. Avis visuel du porteur attendu.
