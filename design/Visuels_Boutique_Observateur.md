# Boutique · Éclaireur-observateur

Visuel fixe du type 31 (`alliance.observer`) validé par le porteur le 14 novembre 2026. À genou, le personnage désigne la cible d’une main et lève un fanion cerise de l’autre. Le losange du fanion reprend la forme du repère qui apparaît au-dessus des PV de la cible.

![Comparatif et capture du marquage](essais/boutique_guetteurs/Eclaireur_observateur_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur |
| --- | --- | --- | ---: |
| `eclaireur_observateur_v001.png` | `Rect2(0,0,1293,1072)` | `(556,1072)` | 53 px |

Son action inflige 3 dégâts de base et marque l’ennemi pendant 4 s. Les autres défenseurs infligent +55 % de dégâts à cette cible pendant le marquage. Dans la copie v0.199, le dessin de la flèche du type 31 est masqué. Le losange `mark.png` s’affiche au-dessus des PV selon `marked_until`. La première application réelle de la marque a été contrôlée pendant le combat. Le portrait, le déblocage et le recrutement ont également été vérifiés. Les 106 contrôles d’illustrations passent sur cette copie.

Le sprite fixe présente déjà le signal. Pour l’animer, partir du fanion abaissé et faire apparaître le losange au moment où l’observateur lève le fanion et désigne la cible. L’intégration du losange et la pose de repos restent à faire.

Dessin réalisé avec le générateur intégré. La Sentinelle a servi de référence pour les contours et aplats, avec une nouvelle silhouette humaine à genou et un fanion à losange.

## Signal au fanion

En garde, l’éclaireur reste à genou, fanion bas et main libre posée sur le genou. Il relève le fanion, se tourne légèrement et désigne l’ennemi. Le losange se dévoile au premier geste pointé à 0,32 s. Le fanion revient en garde et le losange reste sur la cible marquée. Six dessins entiers, 20 images sur 0,80 s. Hauteur de 59 px hors fanion.

[Signal en combat](essais/gestes_combat/observateur/Observateur_en_jeu.gif) · [Planche des six poses](essais/gestes_combat/observateur/Planche_observateur.png)

Le fichier signal.json fixe le délai visuel. La copie d’essai masque la flèche héritée de la famille et retarde le premier affichage du badge de marquage. Les dégâts et le marquage sont appliqués au moment prévu par la simulation. En intégration, conserver les marques déjà affichées, y compris celles issues du bonus Marque du chasseur. Dix marquages vérifiés sur la mission 94 v0.233, à gauche et à droite, ×1 et ×2 avec pause. 48 dossiers valides, 189 contrôles d’animation et 77 des effets réussis. Avis du porteur attendu.

Consignes au générateur d’images intégré. Reprendre le même éclaireur à genou, veste bleu pétrole, écharpe orange, casquette brune et barbe grise. Garder les appuis au sol et le fanion cerise à losange dans la même main. Décomposer le fanion bas, l’armé, le signal avec le doigt de la main libre, puis le retour.
