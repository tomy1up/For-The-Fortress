# Panneau de combat simplifié — v0.81

28 octobre 2026. Suite du travail de présentation et de compréhension des encarts demandé par le porteur du projet. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Lecture principale

Le panneau de gauche affiche deux lignes : ennemis restants et nombre ayant atteint la forteresse pendant la vague. Le total restant inclut les ennemis déjà sur la route et ceux qui ne sont pas encore apparus. Les ennemis éliminés ou arrivés sont exclus. Après une vague terminée, pendant le choix du bonus ou au résultat final, la première ligne devient le nombre éliminé sur le total de la vague ; une défaite ne présente pas les ennemis non résolus comme une suite encore jouable.

Le bouton « Chiffres du combat » restitue les compteurs complets déjà disponibles : apparus sur le total, éliminés, passés, encore en chemin et temps de combat simulé. « Réduire les détails » revient au résumé. Le temps simulé n’encombre plus la lecture par défaut. Les valeurs restent celles de la vague courante, et le temps reste cumulé sur la partie.

Le bouton est accessible au clavier et au pointeur. Il reste bloqué derrière l’accueil, les talents et les panneaux de choix ou de lecture ; un signal forcé ne contourne pas ce verrou. La nouvelle partie restaure la vue simplifiée. Cette préférence locale n’est pas ajoutée au profil.

## Santé de la forteresse

Une jauge accompagne le texte des PV, qui reste toujours disponible. Son maximum suit les talents et améliorations de la partie. Vert au-dessus de la moitié des PV, doré à la moitié ou moins, rouge au quart ou moins : les seuils sont ceux de l’aspect de la forteresse déjà livré. Aucun malus ni nouvelle règle de soin. La lecture ne dépend pas uniquement de la couleur.

## Limites et invariants

Ouvrir ces chiffres ne suspend ni le combat ni les 30 secondes de préparation et ne modifie pas les règles de pause existantes. Aucun achat, gain, ressource, talent, tir, aléa ou événement de jeu supplémentaire. Les libellés génériques conviennent aux deux factions. L’économie de campagne et les PO de première réussite de la feuille de route restent à cadrer ; aucun changement de progression dans ce lot.

## Validation

58 suites et 17 704 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 152 nouveaux contrôles couvrent les deux factions, les phases non modales, le résumé et les compteurs détaillés, les arrivées réelles, les limites de lecture, les dimensions du texte et des commandes, la jauge pour deux maxima de PV et les seuils existants. Le temps de préparation continue pendant la consultation ; aucune modification de l’état du modèle ou de l’aléatoire par le bouton.

Le paquet Windows passe 134 lancements et produit 133 captures, avec 38 sources comparées au projet. [Régression](essais/v081_regression.json) et [distribution](Distribution_Windows_v081.json). Le modèle, la vue de carte, sa définition, les rapports, les statistiques, les vagues, les talents et les sources du profil ont les mêmes empreintes que v0.80. Tous les essais isolent les profils et les lancements graphiques utilisent l’écran de droite. Aucun nouvel essai humain d’équilibrage.

Captures du paquet final : [Alliance, résumé](essais/captures/QA-v081_alliance_hud_compact.png), [Alliance, détails](essais/captures/QA-v081_alliance_hud_details.png), [Horde, résumé](essais/captures/QA-v081_horde_hud_compact.png), [Horde, détails](essais/captures/QA-v081_horde_hud_details.png), [PV endommagés](essais/captures/QA-v081_alliance_fortress_damaged.png) et [PV critiques](essais/captures/QA-v081_horde_fortress_critical.png).
