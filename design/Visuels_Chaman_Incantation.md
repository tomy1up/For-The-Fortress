# Chaman orc · incantation

Proposition d’animation pour `defender.horde.shaman` (type 5). Quatre poses dessinées avec le générateur intégré en prenant le sprite du Chaman pour référence. Il rassemble son énergie en se tassant sur ses appuis, engage l’épaule en projetant le bâton, puis laisse retomber les manches en revenant en garde. Le crâne reste relié au bâton tout au long du geste.

[Capture animée à taille native](essais/gestes_combat/chaman_incantation/Chaman_incantation_en_jeu.gif)

| Réglage d’essai | Valeur |
| --- | --- |
| Planche | 15 images de 448 × 352 px, quatre poses dessinées et pose de garde |
| Durée | 0,45 s de temps simulé |
| Ancre | Pied en (166, 325), échelle de planche 76 px |
| Éclair | À 0,12 s, point de départ relatif au pied (±49, −55) |

Comparaison en jeu sur une copie v0.208, au Gué. Incantation à gauche depuis E1 et vers la droite depuis E2, chacune à ×1 et ×2. L'image reste identique autour du Chaman lorsque le temps simulé est figé. Validateur à 25 dossiers et zéro problème. Bibliothèque à 157 contrôles réussis.

La copie décale le rendu de l’éclair à la pose où le crâne s’illumine. L’anneau de malédiction est déjà visible avant le départ de l’éclair, car il reflète l’état de la simulation. Pour l’intégration, synchroniser son apparition avec l’éclair côté rendu. Le retour à la garde passe par des poses tenues. L’étude attend un avis artistique.
