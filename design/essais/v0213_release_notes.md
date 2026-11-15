# Prototype v0.213 — Libellés corrigés et outils de contrôle

- **Correction** : le panneau d'une alternative de boutique sans effet secondaire affichait « Rebond : 0 × 0 max. » (Fantassin squelette) ; les lignes « Rebond », « Explosion » et « Malédiction » ne s'affichent plus que si l'unité a réellement cet effet (`_compact_damage`, `main.gd`). Trouvé par la régression visuelle.
- **Captures** : `--capture-state=effects --capture-type=N` accepte les types 0 à 47 (alternatives de boutique comprises).
- **Outils de contrôle** (aucun effet sur le jeu) : régression visuelle de 206 captures (`prototype/tests/visual_regression.py`, références dans `design/essais/captures_reference/`) et 120 parties aléatoires reproductibles dans la régression (`test_fuzz_games.gd`). Détails : `design/Regression_visuelle.md`.
- Aucune règle ni valeur de jeu modifiée.
