# Vapeurs toxiques · Marais

Proposition du 24 novembre 2026 sur la v0.248 pour les missions 41 à 60. Les bassins commencent à fumer pendant l’annonce. Quand l’affixe s’active, les nappes vertes s’élèvent et une volute plus petite s’installe au pied de chaque défenseur. Les vapeurs se dissipent progressivement. Les routes et leurs passages inondés gardent leurs couleurs et leurs bordures.

- [GIF de l’annonce, de la montée et de la dissipation sur la mission 51](essais/miasma_v0248/Vapeurs_toxiques_en_combat.gif)
- [Comparatif sur la mission 51 et essais sur les missions 41 et 58](essais/miasma_v0248/Vapeurs_toxiques_comparatif.jpg)

## Planches et branchement proposé

`prototype/assets/animations/effect.miasma/` contient deux planches transparentes. Cadre 144 × 90, ancre (72 ; 65) au pied de la volute et hauteur de 90 px à l’échelle 1.

| État | Planche | Utilisation essayée |
| --- | --- | --- |
| `warning` | 32 images, progression | Une volute sur chaque bassin pendant les 3 secondes de l’annonce. |
| `mist` | 36 images, 24 IPS | Boucle déphasée par position pendant la fenêtre active de 4 secondes. Également posée sous chaque défenseur présent. |

Utiliser le centre projeté de chaque bassin dans `map_definition.water_areas`, avec `MarshArt.POOLS` en repli si la carte ne fournit pas les siens. L’échelle des bassins est comprise entre 0,74 et 1,27 selon la taille du bassin. Pour les défenseurs, utiliser le centre projeté de l’emplacement avec un décalage de 4 px vers le bas, une échelle de 0,67 et 0,88 fois l’opacité courante. Les planches se dessinent dans la passe qui précède les silhouettes et les jauges. La montée active dure 0,43 s et le retrait commence 0,72 s avant la fin. Le branchement d’essai et les déphasages utilisent l’horloge de combat. Le bandeau et la réduction des dégâts restent pilotés par le moteur. Revenir au repère d’origine si la planche manque.

## Contrôles

151 captures des missions 41, 48, 51 et 58 dans les deux factions. Deux cycles contrôlés, dont des vues à six défenseurs et trois entrées en 58. Le GIF raccourcit l’annonce et le milieu de la phase active. Validateur à zéro problème sur 69 dossiers. Bibliothèque d’animations et affixes de biome au vert, 233 et 1 160 contrôles réussis. Premier jet validé par le porteur le 24 novembre 2026. Le branchement de production reste à faire par Claude Code.
