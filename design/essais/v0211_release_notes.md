# Prototype v0.211 — Incantation animée du Chaman orc

- **Planche** : `assets/animations/defender.horde.shaman/` (attaque 28 images de 512 × 416, 0,56 s ; garde `idle.png` ; hauteur 89,8 px), livrée par Codex (gabarit constant, `142e92d`) et validée par le porteur le 15 novembre 2026. Mipmaps activés sur la garde et l'attaque.
- **Éclair** : `LAUNCH_DELAYS` (type 5) : il part à 0,12 s depuis le crâne du bâton, à (±51,625, −58,875) des pieds (`horde_art.gd`).
- **Anneau de malédiction** : calé sur l'arrivée de l'éclair côté rendu (`curse_ring_visible`, instant de pose déduit des tics, aucun état de simulation ajouté). Dégâts, tics et malédiction restent ceux du tir.
- Tests : `test_projectile_presentation.gd` (types différés, départ, instant de pose) ; marge du départ du chaman élargie dans `test_horde_art.gd` (garde animée plus haute que le sprite fixe).
- Limite : rendu en combat à juger par le porteur dans le jeu publié ; non capturé en combat avant publication.
