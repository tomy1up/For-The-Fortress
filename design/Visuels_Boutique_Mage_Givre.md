# Boutique · Mage de givre

Proposition du 14 novembre 2026 pour le type 30 (`alliance.frostmage`), bien accueillie par le porteur. La mage porte un manteau court à col de fourrure et canalise le givre d’une seule main avec un gantelet runique. La fourrure, la posture et l’éclat détaché dessinent sa silhouette au même emplacement E2 que le Mage humain et le Mage de la foudre.

![Comparatif sur le plateau](essais/boutique_guetteurs/Mage_givre_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du tir d’essai |
| --- | --- | --- | ---: | --- |
| `mage_givre_v001.png` | `Rect2(0,0,957,1197)` | `(287,1197)` | 58 px | `(30,-46.5)` |

Portrait, déblocage sur un profil d’essai, recrutement et premier tir contrôlés sur une copie v0.198. Les 121 contrôles d’illustrations réussissent après réglage de l’origine du projectile. La copie dessine un éclat cyan direct vers la cible. Sur le sprite fixe, l’éclat près du gantelet reste visible pendant le tir.

Pour l’animation, fermer puis ouvrir les doigts pour matérialiser un éclat. Faire coïncider son départ avec le mouvement du poignet, maintenir la paume vide juste après et reformer l’éclat au retour. Le cristal vise un seul ennemi. Le repère `effect.slow` pourra signaler le ralentissement en suivant la cible au sol une fois branché.

Dessin réalisé avec le générateur intégré. Consigne artistique : mage humaine adulte, contours francs, aplats ombrés, manteau court à fourrure, gantelet à rune et cristal unique, silhouette lisible à 58 px.
