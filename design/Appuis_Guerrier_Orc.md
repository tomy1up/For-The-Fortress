# Appuis du guerrier orc sur les diagonales — 11 novembre 2026

Le porteur a demandé de corriger le glissement des bottes constaté dans le [pilote](Pilote_animations.md). Le moteur sélectionne désormais `walk_up` sur une diagonale montante et `walk_down` sur une descendante. Les deux planches ont été ajoutées au [dossier de l’orc](../prototype/assets/animations/enemy.horde.warrior/). Le miroir gauche/droite et la phase de foulée restent communs au profil de base et aux deux variantes.

La correction déplace les appuis selon la pente et raccorde le mouvement au bas des jambes. Le haut du corps est identique au pilote. Les trois planches ont 16 poses de 192 × 208 px, une ancre commune `(104, 191)` et une foulée de 25,6 px projetés. La hauteur de cadre déclarée passe de 34 à environ 36,83 px pour compenser la marge ajoutée. La taille du personnage à l’écran est conservée.

## Contrôles

Sur deux séries de cinq poses d’appui, les points repérés sous les bottes se déplaçaient de 2,76 à 2,97 px au sol avec l’ancienne planche. Sur les variantes, le déplacement entre ces points mesurés est de 0,07 à 0,15 px. La mesure suit des détails des bottes dans les planches rendues, puis applique le déplacement sur la pente. Elle porte sur ces poses. La marche conserve 16 images par cycle et le personnage se retourne au virage. [Mesures](essais/orc_appuis/verification_appuis.json)

Deux essais avec le moteur local v0.175 sur la mission 62, Les Coulées Figées, ont parcouru les quatre diagonales à ×1 et ×2. Les deux variantes et les 16 poses ont été observées. Le contrôle confirme le même index de pose de part et d’autre d’un changement de variante à distance égale. La pause de contrôle a duré 1,42 s. Les positions et les deux images comparées pendant la pause sont identiques. Les essais ont été lancés sur l’écran de droite avec profil isolé. [Vidéo à ×1, pause et ×2](essais/orc_appuis/Marche_orc_x1_pause_x2.mp4) · [Capture à ×2](essais/orc_appuis/Les_Coulees_Figees_x2.png)

Le validateur retourne **3 dossiers et 0 problème**. La régression `test_animation_library.gd` passe **135 contrôles** sur la copie de travail du moteur v0.175. Le lanceur local `dist/pilote-animations/Essayer_appuis_orc.cmd` ouvre la même mission avec un profil en mémoire. La décision artistique finale reste au porteur.
