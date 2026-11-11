# Contrôle des visuels intégrés à la v0.176

Les contrôles ont utilisé les sources de la v0.176 avec l’outil de capture ajouté au commit `bf8c654`. Les parties ont été lancées sur l’écran de droite, avec un profil de contrôle en mémoire. Les captures à instants fixes servent à comparer le rendu. Un essai distinct a fait avancer la boucle du jeu à pas fixes avec les vitesses ×1 et ×2.

| Contrôle | Observation en combat |
| --- | --- |
| **Mission 51 · Gueule-de-Vase** | À la vague 2 dans les deux factions, les remous apparaissent sous la créature blessée à son entrée dans le tronçon inondé. À 10,90 s, ses PV remontent de 168,08 à 168,27 côté Alliance et de 159,68 à 159,87 côté Horde sur le pas observé. À taille de jeu, le turquoise des remous se confond par endroits avec la chaussée inondée. |
| **Mission 61 · Volcan** | Le décor est visible. Aucune alerte ni désactivation dans les 19,5 premières secondes simulées à ×1 et à ×2, dans les deux factions. Cette mission sert de témoin sans affixe. |
| **Mission 71 · Éruptions** | Dans les deux factions, l’alerte apparaît à 11 s, la même case se désactive à 14 s, puis le signal disparaît à 19 s. Les durées mesurées sur la boucle de jeu sont de 3 s puis 5 s à ×1, et de 1,5 s puis 2,5 s à ×2. Les fissures ressortent sur le sol sombre, mais les bottes masquent une partie du signal. Le nuage de cendres et la case assombrie distinguent la désactivation. |
| **Mission 87 · Les Portes Jumelles** | Les trois pastilles d’entrée et les routes restent lisibles. Les tours, remparts et étendards restent à l’écart des entrées. La citadelle adverse change selon la faction jouée. |
| **Missions 91–100 · Capitaine humain** | La silhouette bleue et or et la hallebarde apparaissent à la vague 5 dans les dix missions côté Horde. Des contours fins de l’arme et de l’armure deviennent crénelés à taille de jeu. Un essai de rendu à petite échelle reste à faire. |

## Captures

- [Remous des Eaux Mortes, deux instants agrandis dans chaque faction](essais/controle_visuel_v0176/mission_51_remous.png)
- [Cratère Fumant, alerte à 13,50 s, désactivation à 15 s et reprise à 19,50 s](essais/controle_visuel_v0176/mission_71_eruptions.png)
- [Volcan sans affixe et trois entrées des Portes Jumelles](essais/controle_visuel_v0176/missions_61_et_87.png)
- [Capitaine humain dans les dix missions de la Garnison](essais/controle_visuel_v0176/missions_91_100_capitaine.png)

## Vérifications automatiques

| Outil ou test Godot | Résultat |
| --- | --- |
| `validate_animations.gd` | 4 dossiers, 0 problème |
| `test_animation_library.gd` | 136 contrôles, 0 échec |
| `test_decor_art.gd` | 2 901 contrôles, 0 échec |
| `test_drowned_chapter.gd` | 4 632 contrôles, 0 échec |
| `test_garrison_chapter.gd` | 4 546 contrôles, 0 échec |

Le jugement de lisibilité porte sur les scènes capturées. L’alerte a été inspectée sur les emplacements E1 et E4 selon la composition. La durée mesurée à ×2 laisse 1,5 s pour repérer l’alerte. Il reste à comparer sa visibilité à cette vitesse en jeu libre et sur les autres emplacements.
