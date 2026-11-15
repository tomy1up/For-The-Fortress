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

## Raccords retravaillés après retour du porteur

La première version tenait les poses plusieurs images d’affilée. Cette variante utilise 24 images sur 0,48 s. Les poses de passage suivent des repères communs sur les appuis, le torse, les mains et le bâton. La garde d’origine encadre le geste. Le crâne garde son point de départ à (±49, −55) à la libération de l’éclair, 0,12 s après le déclenchement.

[Avant et après à taille native](essais/gestes_combat/chaman_incantation/fluide/Chaman_avant_apres.gif)

Les captures du Gué ont été reprises sur la même copie v0.208, dans les deux sens à ×1 et ×2 et à temps figé autour de l’unité. Le validateur couvre 25 dossiers sans problème et les 157 contrôles de la bibliothèque passent. Un léger adoucissement du contour de la manche et du halo est visible sur certaines poses intermédiaires en grand. L’ordre d’apparition de l’anneau de malédiction reste à régler côté rendu. La variante de la planche se trouve dans `fluide/defender.horde.shaman/` et attend un avis visuel.

## Proportions corrigées après retour du porteur

Le porteur juge la variante fluide mais constate un changement de volume pendant le tir. Les poses d’attaque ont été recalées sur la tête et la carrure de la garde, puis les poses de passage ont été recalculées. Le bâton s’incline pendant la poussée. Les pieds, la prise et le départ de l’éclair restent ancrés dans la planche. La durée est de 0,48 s, avec le déclenchement visuel à 0,12 s.

[Avant et après à taille native](essais/gestes_combat/chaman_incantation/volume/Chaman_proportions_avant_apres.gif)

Nouvelle planche dans `volume/defender.horde.shaman/`. Contrôlée au Gué sur la copie v0.208 à ×1 et ×2 dans les deux sens, avec arrêt du temps simulé. Validateur : 25 dossiers, zéro problème. Bibliothèque : 157 contrôles réussis. L’anneau de malédiction apparaît encore avant l’éclair sur cette copie. La variante corrigée attend le retour du porteur.

## Garde et incantation à partir du même dessin

Le porteur signale que la version précédente présente encore un changement de taille, surtout en fin d’attaque. La nouvelle planche anime un seul dessin, celui de la garde. La tête se déplace sans changer d’échelle, les pieds sont ancrés et le bâton pivote avec la main. Le début et la fin de l’attaque sont identiques au repos pixel pour pixel sur la planche. Deux comparaisons du corps en jeu (E2, ×1 et ×2) sont également identiques avant et après le sort.

[Comparatif à taille native](essais/gestes_combat/chaman_incantation/garde_unique/Chaman_garde_avant_apres.gif)

La nouvelle variante se trouve dans `garde_unique/defender.horde.shaman/`. Le geste est plus mesuré : le mouvement du bâton se lit par sa bascule et le départ de l’éclair. 24 images sur 0,48 s. L’éclair part à 0,12 s de (±33,25, −57,25) par rapport aux pieds sur la copie d’essai v0.208. Vérifications au Gué dans les deux sens à ×1 et ×2 et à temps figé. Validateur : 25 dossiers, zéro problème. Bibliothèque : 157 contrôles réussis. L’anneau de malédiction reste à synchroniser côté rendu.

## Geste d’origine et gabarit raccordé

Le porteur a écarté l’essai à partir d’un seul dessin de garde parce que le mouvement avait perdu son amplitude. Cette variante reprend les poses dessinées de préparation, de projection et d’accompagnement. Les poses ont été ramenées à une hauteur de corps comparable autour d’un même point d’appui, puis les poses de passage ont été recalculées. La reprise de garde prend plus de temps. L’image de garde sert aussi de début et de fin à la planche. Le même filtrage mipmap est appliqué au repos et à l’attaque.

[Comparatif en jeu avec le geste d’origine](essais/gestes_combat/chaman_incantation/geste_et_gabarit/Chaman_geste_et_gabarit.gif)

Variante à évaluer dans `geste_et_gabarit/defender.horde.shaman/`. 28 images de 496 × 400 px sur 0,56 s, ancre (190, 349), hauteur d’affichage 86,36 px pour le cadre avec marge. L’éclair part à 0,12 s de (±51,625, −58,875). Sur la copie v0.208, les captures à ×1 et ×2 montrent le retour à la garde pixel pour pixel sur le recadrage du corps à E2. Les deux sens et le temps figé ont été vérifiés. Validateur : 25 dossiers, zéro problème. Bibliothèque : 157 contrôles réussis. L’anneau de malédiction reste à synchroniser.

## Correction locale du gabarit sur le geste validé

Le porteur valide le geste de la variante précédente mais voit encore le corps rétrécir puis s’élargir. La nouvelle variante utilise ses 28 images dans le même ordre, sur la même durée de 0,56 s. Les appuis et le départ de l’éclair à 0,12 s restent positionnés au même endroit. La correction agit localement sur le torse et la capuche des images les plus étroites, avec une transition douce au retour. L’aire pondérée de la silhouette autour du torse, mesurée dans la même fenêtre relative aux pieds, varie désormais d’environ 5 % au lieu de 9,5 %. Cet indicateur sert à comparer les planches. Le porteur juge cette variante « bien mieux » le 15 novembre 2026. C’est la version retenue pour l’intégration.

[Comparatif à taille native](essais/gestes_combat/chaman_incantation/gabarit_constant/Chaman_taille_corrigee.gif)

La planche se trouve dans `gabarit_constant/defender.horde.shaman/`. Elle utilise des cadres de 512 × 416 px, un pied (198, 357) et une hauteur de cadre de 89,82 px. La marge supplémentaire conserve l’échelle du dessin. Les mipmaps sont actives dans l’essai. Contrôle au Gué à ×1 et ×2 dans les deux sens et à temps figé. Le corps revient à la même pose de garde pixel pour pixel sur le recadrage de contrôle E2. Validateur : 25 dossiers, zéro problème. Bibliothèque : 157 contrôles réussis. L’anneau de malédiction doit encore être synchronisé côté rendu.
