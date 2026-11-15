# Prototype v0.210 — Lancer animé du Sapeur gobelin

- **Planche** : `assets/animations/defender.horde.sapper/` (12 images de 320 × 256, 0,36 s, mode événement), livrée par Codex (`d3fd823`, validée `780fb15`) et validée par le porteur le 15 novembre 2026 comme référence de qualité pour les autres unités.
- **Projectile** : `LAUNCH_DELAYS` (`valley_view.gd`) : la charge du sapeur quitte la main 0,12 s après le tir, depuis le point visuel (±34, −27) des pieds (`horde_art.gd`).
- **Marqueur d'impact** : il apparaît à l'arrivée du projectile (0,24 s après le tir), avec l'anneau de rayon et les marqueurs secondaires. Les dégâts, PV et morts restent résolus à l'instant du tir : aucune règle modifiée.
- Test ajouté (`test_projectile_presentation.gd`) : seul le type 4 est différé ; départ visuel (±34, −27). Limite : le rendu animé en combat reste à juger par le porteur dans le jeu publié.
