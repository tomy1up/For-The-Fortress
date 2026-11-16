# Boutique · Mage de la foudre

Visuel du type 22 (`alliance.lightning`) approuvé par le porteur le 14 novembre 2026. Le mage concentre un arc électrique entre ses deux mains. Le manteau prune et les épaules argentées le distinguent sur le plateau du Mage humain et du Pyromancien.

[Comparatif des trois mages](essais/boutique_guetteurs/Mage_foudre_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur | Origine du tir |
| --- | --- | --- | ---: | --- |
| `mage_foudre_humain_v001.png` | `Rect2(0,0,914,1278)` | `(355,1278)` | 60 px | `(20.0,-47.5)` |

Sur la copie v0.197, portrait, déblocage, recrutement et premier tir vérifiés. Les 85 contrôles du test d’illustrations passent. Le sprite est fixe et le tir reprend le visuel du Mage humain.

Pour la future animation, rapprocher légèrement les mains pour charger l’arc puis ouvrir la main avancée pour libérer l’éclair. Faire partir l’effet de cette main vers la cible principale et montrer ses ramifications vers les cibles secondaires réellement touchées. Conserver la sélection des cibles et les dégâts actuels.

## Charge et éclair en chaîne

Le mage rapproche les mains pour charger, engage le buste et projette la main haute vers la cible. Les semelles restent en appui. La charge dans les mains est bleu pâle pour assurer le raccord avec l’éclair du jeu. Après la décharge, les épaules et les mains reviennent dans leur garde.

[Voir la charge et la chaîne à taille réelle](essais/gestes_combat/mage_foudre/Mage_de_la_foudre_en_jeu.gif)

Type 22 (`defender.alliance.lightning`). L’essai fournit une garde et trois inclinaisons de 20 poses sur 0,80 s. L’éclair part à 0,32 s depuis la main avancée, sur la première pose sans arc entre les mains. Le fichier `lachers.json` donne les repères par inclinaison. Appliquer le côté de tir au repère et à la pose. Réutiliser la chaîne du moteur en reliant la cible principale et les points secondaires du tir. Pour l’impact, l’essai montre un éclat sur les cibles atteintes. Les anneaux de zone génériques du mage restent réservés aux autres attaques.

Sur copie v0.223, six tirs contrôlés sur la mission 94 à ×1 et ×2, vers la droite en montant et vers la gauche en descendant. Les quatre premiers tirs touchent chacun la cible principale et deux voisins. Origine et extrémités de chaque branche contrôlées, ainsi que la pose en pause. Les 60 poses sont cadrées et les semelles gardent leur appui. Validateur à zéro problème sur 37 dossiers et bibliothèque à 178 contrôles réussis. Le porteur valide le lot `e90fd72`.
