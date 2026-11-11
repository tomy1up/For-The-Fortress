# Prototype v0.173 — Chapitre 10 : la Garnison

Sur décision du porteur (11 novembre 2026), le chapitre 10 (missions 91 à 100) clôt le biome de la citadelle ennemie avec une nouveauté : la Garnison, ennemi d'élite propre à la citadelle, plus résistant que l'élite ordinaire.

- **Garnison** (réglages de prototype à confirmer) : « Capitaine de garnison », 520 PV de base, vitesse 0,6, −4 PV de forteresse, 26 d'or. Elle accompagne les vagues 5, 7, 9 et 10 des missions 91 à 100. Identités par faction : orc face à l'Alliance, humain face à la Horde. Silhouette provisoire (celle du chef de guerre ou du maréchal), à remplacer par Codex.
- **Dix nouvelles cartes de citadelle** (91 à 100) à une, deux ou trois entrées, 60 PO et 100 XP à la première victoire, PV ennemis de 190 % à 199 %. Emplacements choisis par simulation avec les talents réels (45 à 50 points) ; les deux factions gagnent chaque carte avec leur armée de référence (10 à 23 PV d'avance).
- **Interface** : la fiche de mission annonce la Garnison ; la prévision des vagues et l'écran des rencontres la décrivent.
- Nouveau fichier d'exécution `scripts/garrison_encounters.gd`, déclaré dans les trois listes d'export.
- Les PV ennemis acceptés montent jusqu'à 199 %.

Documentation : `design/Missions_091_100_Garnison.md`.

Correction ultérieure (v0.174) : la régression complète de cette version n'était pas entièrement verte. Une suite, `test_forecast_portraits.gd`, échouait sur une hypothèse devenue fausse (le profil 10 était supposé inexistant), sans effet sur le jeu ; elle est corrigée en v0.174. Les autres suites réussissaient : 108 suites, dont 107 réussies, 74 561 contrôles Godot en comptant la suite `test_enemy_art.gd` relancée seule après correction, et 17 tests Python. Elle a détecté un vrai bogue corrigé avant publication : la vue plantait au dessin d'un ennemi de type 10 (tableaux d'échelle et de couleur trop courts). 7 essais Windows ciblés et 89 empreintes de sources du paquet réussissent. Connu : sur les cartes à trois entrées de la citadelle (94, 97, 100), les tracés se croisent près de la jonction (voir la fiche).
