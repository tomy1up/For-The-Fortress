# Prototype v0.216 — Marche du Capitaine orc en quatre vues

- **Lot de Codex** `9fe2608` (appuis resserrés, validé par le porteur le 15 novembre 2026) : quatre planches de 24 poses (352 × 304, ancre (174, 258), foulée 11,54 px) pour `enemy.horde.garrison`, convertie du format grille de Codex (12 colonnes, 2 lignes) en bandes horizontales (`assets/animations/enemy.horde.garrison/walk_nw|ne|sw|se.png`).
- **Format** : clé `directions: four` (`animation_library.gd`) avec les vues `walk_nw`, `walk_ne`, `walk_sw`, `walk_se`, sans miroir ; l'état est choisi par les signes de la direction à l'écran ; la phase de marche reste liée à la distance, donc se conserve au virage ; le miroir de route est annulé dans `_draw_sheet_walker`.
- **Contrôles** : suite d'animations (167), validateur (26 dossiers, 0 problème), captures de la mission 94 aux deux factions (références mises à jour pour l'Alliance, qui affronte le capitaine orc).
- **Reste à produire (Codex)** : transitions dessinées de virage et animation de mort. Le changement de vue est direct au virage.
- Aucune règle ni valeur de jeu modifiée.
