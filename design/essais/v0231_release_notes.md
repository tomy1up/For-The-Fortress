# Prototype v0.231 — Outillage, fiches des chapitres, courbe de difficulté

Aucun changement du jeu joué normalement.

- **Contrôles en parallèle** : `run_regression.py` lance six suites Godot à la fois (`--jobs`, 8 min 30 au lieu de 25 pour 142 suites et 159 856 contrôles) ; `verify_windows_export.py` lance quatre cas à la fois (`--jobs`, environ 15 minutes au lieu d'une heure pour 1 050 cas).
- **Captures reproductibles** : pendant les captures automatiques (`--capture=`), le battement du fanion de la forteresse et la pulsation du bandeau d'affixe sont figés ; les 28 captures d'affixes sont identiques d'une exécution à l'autre.
- **Fiches des chapitres 10 à 20** (`design/Missions_091_100…191_200`) : tableaux mis à jour avec les cartes refondues (entrées, trajets, PV restants mesurés) et note de refonte.
- **Courbe de difficulté** : `design/Courbe_difficulte_v0230.md` et `prototype/tools/difficulty_curve.gd` (PV de forteresse restants avec la composition de référence, 200 missions, deux factions). Constat à arbitrer : aux chapitres 16 à 20, la composition de référence de la Horde ne perd aucun PV sur 42 missions sur 50, celle de l'Alliance sur 5 sur 50 (écart antérieur à la refonte des cartes).
