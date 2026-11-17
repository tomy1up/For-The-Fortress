# Prototype v0.228 — Lanceur double troll (type 27)

- **Geste du Lanceur double troll** (lot `b779d4d` de Codex, validé par le porteur) : six planches (trois inclinaisons par bras), deux haches (`hache_basse`, `hache_haute`). Les bras alternent à chaque tir de chaque défenseur, en commençant par la hache basse, et l'alternance se poursuit entre les vagues. La hache part à 0,48 s depuis le centre de la planche du bras actif et tourne le long d'un trajet rectiligne ; un seul impact par tir ; à bout portant, si l'impact est déjà derrière le point de lâcher, la hache n'est pas dessinée en vol. Le bonus sur cible blessée et les valeurs de combat sont inchangés.
- **Choix technique** : l'alternance est un état de rendu (un compteur par défenseur, conservé entre les vagues), jamais écrit dans le modèle ni dans les rapports.
- **Contrôles** : `test_marksman_aim.gd` (3 856 contrôles dont alternance, choix de la planche du bras, point de départ).
