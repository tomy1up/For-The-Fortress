# Prototype v0.214 — Finale de la Horde allégée

- **Décision du porteur (15 novembre 2026)** : à la mission 200, les ennemis de la Horde ont 85 % des PV de la courbe de base (224 % au lieu de 238 %) ; `Catalogue.HORDE_FINALE_FACTOR`. Les missions 150 à 199 restent à 90 %, l'Alliance et les 149 premières missions sont inchangées.
- **Mesure** (`design/Mesure_boutique_finales_O016.md`, section « Finales de la Horde ») : à 90 %, la Horde gagnait 2 parties sur 12 à la mission 200 contre 9 pour l'Alliance ; à 85 %, 8 sur 12. Les missions 191 à 199 étaient déjà au niveau de l'Alliance ou plus aisées.
- Tests : `test_horde_curve.gd` (mission 200 : 264 % Alliance, 224 % Horde). Réglage de prototype à confirmer en jeu.
