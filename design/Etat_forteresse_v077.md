# État visible de la forteresse — v0.77

28 octobre 2026. Présentation des dégâts dans les deux architectures v0.76. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Repères visuels

| PV restants | Présentation |
| --- | --- |
| Plus de la moitié | Aspect sain et bannière haute |
| Moitié ou moins | Façade assombrie, marquage de dégâts et libellé « Endommagée » |
| Quart ou moins, strictement positif | Marques renforcées, fumée discrète et libellé « En danger » |
| Zéro | Aspect assombri, bannière abaissée et libellé « Forteresse détruite » |

Ces seuils sont des choix de présentation, sans malus de jeu. Le compteur de PV demeure la mesure exacte. La lecture se fait sur le maximum actuel, y compris après les talents et R-09. Le soin de R-09 peut améliorer l’aspect immédiatement. Nouvelle partie : aucune ancienne dégradation conservée.

## Périmètre conservé

Les deux factions gardent leur architecture, leur cour et leur point d’arrivée. E6 reste dégagé. Les fissures et fumées appartiennent à la vue, ne consomment aucun tirage aléatoire et ne changent aucun PV, ennemi, coût, récompense ou profil. Aucun système de réparation ou pénalité n’est ajouté.

## Validation

54 suites et 17 174 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 36 nouveaux contrôles vérifient quinze cas de PV et de maximum, les seuils inclusifs, les libellés, le dessin sans mutation, E6 dégagé dans chaque état, le soin réel de R-09 et la remise à zéro.

Le ZIP Windows passe 126 lancements, produit 125 captures et correspond à 37 sources locales. Le modèle, les vagues, les statistiques, les talents, le profil et les rapports ont les mêmes empreintes source que v0.76. Captures inspectées : état critique [Alliance](essais/captures/QA-v077_alliance_fortress_critical.png) et [Horde](essais/captures/QA-v077_horde_fortress_critical.png), autres états conservés dans le dossier de captures. [Régression](essais/v077_regression.json) et [distribution](Distribution_Windows_v077.json). Profils isolés ; aucun nouvel essai humain d’équilibrage.
