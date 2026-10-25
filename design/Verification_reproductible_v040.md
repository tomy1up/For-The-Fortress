# Vérification reproductible — v0.40

25 octobre 2026. Livraison d’outillage : les comportements du jeu restent ceux de v0.39.

La vérification complète est désormais dans le dépôt, avec `prototype/tests/run_regression.py`. Elle ne dépend plus d’un script privé situé dans le dossier local d’outils. Elle découvre les suites `test_*.gd`, exécute leurs contrôles en mode sans fenêtre, lance les tests Python puis compare les paramètres de référence au GDD.

## Relancer les vérifications

Python 3.10 ou supérieur et le moteur Godot du projet sont nécessaires. La référence testée reste Godot **4.7.2.stable.official.ed1daf0bf**. Aucune bibliothèque Python externe ni connexion réseau n’est utilisée.

Depuis la racine du dépôt :

```powershell
python prototype/tests/run_regression.py
```

Le moteur est recherché dans `FORTRESS_GODOT`, dans le dossier d’outils adjacent au projet utilisé sur ce PC, puis dans les commandes `godot4` ou `godot` disponibles. Pour un autre emplacement, préciser son chemin. Sous Windows, choisir le binaire `_console.exe` :

```powershell
python prototype/tests/run_regression.py --engine "C:/Outils/Godot/Godot_v4.7.2-stable_win64_console.exe" --report "C:/Projet/.tools/qa/regression.json"
```

Les chemins sont à adapter. Le lanceur fonctionne également lorsqu’il est appelé par son chemin depuis un autre répertoire. Pour ne travailler que sur une suite :

```powershell
python prototype/tests/run_regression.py --test test_valley.gd
```

Le rapport indique alors explicitement une sélection partielle. Les tests Python et contrats du GDD restent exécutés. Le délai par suite vaut 30 secondes ; `--timeout` permet de l’ajuster.

## Résultats et échecs

Un code de sortie favorable du moteur ne suffit pas : le lanceur exige un résumé unique avec un nombre de contrôles positif et zéro échec, et refuse les erreurs de script ou du moteur présentes dans le journal. Il signale aussi les dépassements de délai. Un moteur absent ou une suite inconnue est refusé avant le lancement.

Avec `--report`, un JSON et un dossier de journaux sont écrits au chemin choisi. Le rapport inclut les versions du jeu, du moteur et de Python, les suites exécutées, les contrôles, les contrats documentaires et les empreintes des sources. Une modification de ces fichiers pendant la vérification interdit d’annoncer un succès. Le cache Python n’est pas versionné.

Les erreurs renvoient un code non nul. Les contrats du GDD restent actifs même lorsque Python est lancé avec ses optimisations : ils utilisent des vérifications explicites, et non des assertions supprimables par `-O`.

## Validation de cette livraison

- **23 suites Godot, 14 004 contrôles réussis**.
- **9 tests Python** du lanceur : résumés valides, erreurs malgré une sortie à zéro, sortie en échec, absence/ambiguïté de résumé, contrôles nuls ou échoués, découverte, filtres, mauvais moteur et configuration, rejet d’une statistique modifiée par rapport au GDD.
- Contrats : 24 valeurs de défenseurs, 32 valeurs ennemies, 42 valeurs de branches et 26 groupes de vagues conformes à la référence documentaire.
- Essai réel depuis un répertoire extérieur : suite Vallée, 87 contrôles, sélection correctement signalée.
- Essai d’échec volontaire en donnant Python à la place du moteur : sortie 1 et rapport négatif, sans fausse réussite.
- **46 lancements du paquet Windows**. Les outils Python ne sont pas inclus dans le jeu et ne sont pas nécessaires pour jouer. Les lancements graphiques de contrôle restent sur l’écran de droite.

[Rapport complet de régression](essais/v040_regression.json). Aucun réglage de combat ni règle du GDD n’est modifié ; le document principal reste en v0.14.
