# Calcul des comparaisons de bonus — v0.47

25 octobre 2026. Optimisation de lecture du panneau roguelite ; effets, prix et statistiques conservés.

## Changement

Avant cette version, les trois comparaisons étaient recalculées à chaque mise à jour de l’interface, même lorsque le choix attendait le joueur et qu’aucune donnée ne changeait. Le texte déjà affiché était ensuite comparé pour éviter une remise à zéro du défilement.

Le panneau conserve désormais une clé de données et trois textes au maximum. Cette clé inclut faction, vague, offres, bonus acquis, défenseurs, or, PV actuels et maximum, et activation des synergies. Si elle est identique, les comparaisons affichées sont réutilisées. Sinon, elles sont recalculées avec la même fonction qu’auparavant. Le nouvel essai vide les clés ; aucune valeur du modèle ni de l’aléatoire n’est changée.

Le défilement n’est remis à zéro que si le texte ou le contexte du choix change, selon la règle existante. Les boutons, la navigation au clavier, l’attente sans limite de temps et les 30 secondes accordées après le choix restent identiques.

## Mesure locale

Le script tests/benchmark_bonus_panel.gd utilise une fixture de six défenseurs niveau 4 et un budget imposé de 10 000 or. Ces valeurs ne sont pas ajoutées à une partie normale. Il mesure trois séries de 300 appels à _update_interface pour chaque faction, sans rendu, avec Godot 4.7.2 sur ce PC. Le premier appel réchauffe le panneau avant la mesure. Même script et mêmes conditions de fixture avant/après ; empreintes du script et des deux main.gd conservées.

| Faction | Médiane avant | Médiane après | Réduction du temps mesuré |
| --- | --- | --- | --- |
| Alliance | 1 350,63 µs | 233,29 µs | 82,7 % |
| Horde | 1 404,64 µs | 246,99 µs | 82,4 % |

Ces valeurs mesurent ce travail CPU d’interface dans une fixture précise. Elles ne représentent pas les FPS du jeu, le rendu graphique, les ressources de tous les PC ou l’ensemble du combat. [Échantillons et provenance](essais/v047_bonus_panel_benchmark.json). Pour répéter la mesure depuis la racine :

```powershell
godot --headless --path prototype --script res://tests/benchmark_bonus_panel.gd
```

Utiliser le même script avec le main.gd de la v0.46 pour la référence antérieure, dans une copie isolée du projet ; le benchmark lui-même a été ajouté avec la v0.47.

## Vérification

**27 suites, 14 283 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **70 contrôles dédiés** vérifient les deux factions, l’absence de recalcul pendant la lecture, l’absence de mutation du modèle et l’identité des textes avec un calcul frais après chaque changement : or, PV actuels et maximum, bonus, niveau, branche, type de défenseur, synergies, offres et vague. Les tests existants de défilement et de commandes restent réussis.

Le compte rendu du paquet Windows figure dans Distribution_Windows_v047.json. Le benchmark et ses fixtures sont exclus du paquet distribué. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

46 lancements Windows réussis sur l’écran de droite, dix empreintes locales concordantes. Les 45 captures sont identiques pixel par pixel à la v0.46 dans la région 1280 × 774, au-dessus du pied portant le numéro de version modifié. Le panneau Horde a aussi été inspecté visuellement. [Comparaison](essais/v047_visual_comparison.json).
