# Présentation de la carte — v0.52

26 octobre 2026. Passe visuelle sur le décor temporaire de La Vallée du Gué.

## Dessin

Le plateau possède deux faces de teintes différentes pour rendre son épaisseur. La surface est légèrement éclaircie. Les berges encadrent l’eau, dont les reflets restent fixes. Le pont possède des garde-corps et poteaux. Les arbres combinent trois étages de feuillage avec une face éclairée. La porte de la forteresse reçoit une arche et des lignes de maçonnerie.

Ces éléments restent du dessin généré par le projet, sans asset externe ni animation supplémentaire. Ils ne constituent pas une direction artistique finale. Aucun obstacle, collision, déplacement de route ou effet de terrain n’est ajouté. La géométrie logique, les six places, les calculs de portée et l’ordre de dessin des unités sont conservés. Aucun tirage aléatoire n’est introduit dans les décors.

## Vérification

29 suites, **14 350 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Une première capture de préparation après vague 8 a été produite par Godot sur l’écran de droite et inspectée : route, E1–E6, unités, partenaires, portées et pont restent visibles. La validation du paquet final et les captures retenues sont consignées dans Distribution_Windows_v052.json. Aucun test permanent n’est ajouté pour ce dessin statique.

La notice utilise désormais une description au présent de l’enchaînement, plutôt que de le présenter encore comme la nouveauté de la version.

Combat, budget, vagues et boss à 600 PV restent identiques. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

## Contrôle du paquet

46 lancements automatisés réussis sur l’écran de droite, dix empreintes locales concordantes. [Carte du paquet](essais/captures/QA-v052_carte.png) et aperçu de portée Horde inspectés. Pour les 45 captures, les zones d’interface à gauche et en bas sont identiques pixel par pixel à la v0.51, hors décor et pied portant la version : [comparaison](essais/v052_ui_comparison.json).

## Partie native de contrôle

L’agent a ensuite joué une partie complète dans l’exécutable, via souris et clavier, sur l’écran de droite. Aucun budget ni état du jeu n’a été modifié par script. Le ×10 temporaire a été sélectionné avant la première vague. Les vagues 2, 3, 6 et 9 sont parties automatiquement ; les autres départs après la première ont été anticipés par le bouton.

Le choix après vague 3 est resté ouvert pendant une attente mesurée de 35 secondes. Sa validation a réarmé 30 secondes entières. La spécialisation de l’archer a suspendu le décompte puis l’a repris avec trois secondes affichées. Les offres consultées nommaient les unités Alliance, sans mention d’unité Horde.

| Indicateur | Observation |
| --- | --- |
| Résultat | Victoire Alliance, 18/20 PV |
| Or restant / revenu total | 189 / 764 |
| Éliminés / passés | 180 / 2 |
| Défense finale | E1 archer niveau 4, Veilleur des remparts ; E2 arbalétrier niveau 3 ; E3 mage niveau 2 |
| Bonus | R-06 Impacts appuyés ; R-02 Exercice de tir ; R-12 Chasse aux colosses |
| Combat simulé cumulé | 331,330723650741 s |
| Boss | Éliminé à 6,696428571 s de la vague 10 ; 600 PV retirés |

Le rapport exporté depuis le bilan a été rejoué par l’outil : 45 actions et toutes les données contrôlées concordent, y compris les contributions et le relevé du boss. L’empreinte du fichier est identique avant/après. Le [rapport intégral](essais/v052_native_report.json) et le [relevé du contrôle](essais/v052_native_run.json) sont versionnés.

[Attente de bonus](essais/captures/QA-v052_choix_attente.jpg) · [Victoire](essais/captures/QA-v052_victoire_native.jpg) · [Bilan et boss](essais/captures/QA-v052_bilan_natif.jpg). Le jeu a été fermé après vérification.

Cet essai est un contrôle opéré par l’agent, pas un nouveau retour humain ni une validation générale d’équilibrage. Le temps simulé ne mesure pas la durée réelle de la session.

Pour rejouer le fichier conservé avec le moteur de cette version :

```powershell
godot --headless --path prototype --script res://tests/replay_run.gd -- '--report=C:/Projet/For the Fortress!/design/essais/v052_native_report.json'
```
