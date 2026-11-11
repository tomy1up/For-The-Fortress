# Prototype v0.174 — Cadre technique des animations

À la demande du porteur, premier jalon de la mission animations et unités confiée à Codex : un format de planches d'images permet de déposer des animations sans modifier le code. Le jeu ne change pas pour le joueur tant qu'aucune planche n'est livrée.

- **Format** (`design/Format_animations.md`) : un dossier par unité dans `prototype/assets/animations/<id>/` avec `animation.json` et des planches PNG en bande horizontale. Modes `distance` (marche réglée sur le chemin parcouru), `time` (repos) et `event` (tir, désactivation).
- **Branché** : marche des ennemis (`walk`), repos, tir et désactivation par l'affixe Éruptions des défenseurs (`idle`, `attack`, `disabled`). Formats acceptés mais pas encore déclenchés : mort, coup reçu, apparition, achat, revente, niveau.
- **Repli** : description absente ou invalide, planche manquante ou de mauvaise taille : l'illustration fixe actuelle est dessinée.
- **Contrôle** : `tools/validate_animations.gd` (erreurs précises) et suite `test_animation_library.gd`.
- **Export** : les `.png` et `.json` de `assets/animations` sont inclus tels quels et leurs empreintes contrôlées automatiquement, sans déclaration fichier par fichier ; nouveau script `scripts/animation_library.gd` déclaré dans les trois listes.
- Éprouvé avec des planches synthétiques (rectangles de couleur) ; aucun art réel livré.
- Correction de la v0.173 : `test_forecast_portraits.gd` échouait sur une hypothèse devenue fausse (profil 10 supposé inexistant) ; test corrigé, sans effet sur le jeu. Les notes de la v0.173 ont été rectifiées.

La régression complète réussit : 109 suites, 75 546 contrôles Godot (la suite `test_forecast_portraits.gd`, corrigée en cours de route, est comptée par sa relance seule) et 17 tests Python. Essai du chemin complet : un export avec des planches synthétiques (rectangles de couleur) pour un guerrier orc et un archer a été lancé et capturé : les deux apparaissent dans le jeu exporté, avec les PNG bruts inclus par le filtre d'inclusion ; ces planches d'essai ont ensuite été retirées.

Vérification Windows : 5 essais ciblés et 90 empreintes de sources du paquet réussissent (un premier lancement a échoué sur une assertion d'instantané de menu, non reproduite à la relance des mêmes cas).
