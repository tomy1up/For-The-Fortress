# Lisibilité des combats — v0.30

23 octobre 2026. Réalisation visuelle du prototype, en complément du GDD v0.14.

## Comportement réalisé

| Effet | Repère |
| --- | --- |
| Mage humain | Impact bleu, ellipse au sol au rayon réel et marques sur les victimes secondaires |
| Sapeur gobelin | Impact orange et mêmes règles géométriques |
| Lanceur de haches troll | Trajet vert entre victimes successives, flèches de direction et marques d’impact |
| Chaman orc | Tir violet ; halo et losange au-dessus de la tête tant qu’une malédiction du modèle existe |

Le contour d’explosion représente le rayon de recherche, pas une garantie de toucher toutes les cibles présentes : le plafond de victimes et les priorités restent ceux du modèle. Les marques secondaires viennent uniquement de ses événements résolus. Aucun effet visuel ne retarde les dégâts.

Les impacts s’estompent pendant 0,32 seconde de simulation : 0,32 seconde réelle à ×1 et 0,16 à ×2. Ils disparaissent hors combat, au changement de vague et au nouvel essai. Le losange de malédiction ne prédit pas un nombre de ticks et n’ajoute aucune charge.

## Statut des décisions

- Réalisé : présentation visuelle décrite ci-dessus, sans modification du modèle de combat.
- Valeurs d’équilibrage : coûts, dégâts, rayons, plafonds, synergies, vagues et boss conservent leurs hypothèses documentées précédentes.
- Choix visuel provisoire : palette, épaisseurs et durée d’affichage, à évaluer lors des prochains essais humains. Les visuels restent temporaires.
- À confirmer par le joueur : lisibilité des combats denses à ×2 et distinction des rebonds multiples. L’inspection de captures ne remplace pas cet essai.

## Validation

46 contrôles ciblés de l’extinction, des trajets, des rayons projetés et de l’absence de mutation ; 2 685 contrôles automatisés au total. Les deux campagnes de référence gardent exactement leurs résultats. Quatre captures de contrôle du binaire utilisent des attaques réellement résolues sur la vague 8, avec budget imposé explicitement indiqué ; elles ne sont pas présentées comme des parties normales. Le paquet Windows est contrôlé sur 22 démarrages, dont ces quatre scènes.
