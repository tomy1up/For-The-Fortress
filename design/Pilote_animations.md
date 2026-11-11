# Pilote des animations — 11 novembre 2026

Deux unités animées sur les sources de la v0.174, commit de départ `5783f3f`. Ces planches sont des habillages de prototype proposés au porteur pour un essai en jeu.

| Unité | Planche | Images | Réglage d’essai |
| --- | --- | ---: | --- |
| Archer elfe | `idle.png` | 8 × 256² | 8 images/s, respiration légère et arc abaissé |
| Archer elfe | `attack.png` | 10 × 256² | 0,40 s, traction déjà engagée à l’ouverture, lâcher à 0,04 s puis réarmement et retour au repos |
| Archer elfe | `disabled.png` | 8 × 256² | 5 s, posture de protection et cendres en mouvement |
| Guerrier orc | `walk.png` | 16 × 192² | 25,6 px de déplacement projeté par cycle, calés sur le recul horizontal des appuis |

Les PNG transparents et leurs descriptions sont dans [`defender.alliance.archer`](../prototype/assets/animations/defender.alliance.archer/) et [`enemy.horde.warrior`](../prototype/assets/animations/enemy.horde.warrior/). Les tailles déclarées sont 66 px pour le cadre de l’archer et 34 px pour celui de l’orc. Pieds ancrés en `(113, 249)` et `(104, 187)` dans les planches. La valeur `(214, 117)` déclarée pour le départ de flèche correspond à l’ancrage historique de jeu, environ `(26, −34)` px par rapport au pied.

L’archer réutilise ses dessins de tir existants. Deux nouvelles poses conservent son équipement et sa palette pour le repos et la désactivation. L’orc reprend la silhouette à hache et bandana du roster Horde. Les dessins ont été produits à partir de ces références avec génération d’images, puis recalés et mis en bandes. Un filtrage à la préparation des planches réduit le crénelage du PNG brut à la taille du plateau. Ordre de grandeur observé sur ce premier lot, opérations partagées comprises : environ 10 minutes de production et d’itérations pour les deux unités en parallèle, avec davantage de réglages pour l’archer. Ce relevé ne permet pas d’estimer une cadence individuelle pour la série.

## Essais sur le plateau

- **Mission 1, La Vallée du Gué.** Archer en E2, première vague de guerriers orcs. Le clip de 22,5 s couvre le départ à ×1, une pause de contrôle de 1,58 s, la reprise et le passage à ×2 vers 15 s. Deux images décodées pendant la pause sont identiques et le temps simulé, les positions et la pose du défenseur restent fixes. [Vidéo du Gué](essais/pilote_animations/Guerrier_et_archer_au_Gue.mp4) · [Plateau à ×2](essais/pilote_animations/Plateau_Gue_x2.png)
- **Mission 71, Le Cratère Fumant.** Archer en E3, première vague à ×2. Le tir dans les deux sens et les 5 s simulées de désactivation sont observés, soit 150 images vidéo à 60 images/s. Les deux sessions parcourent les 16 poses de marche. [Vidéo des Éruptions](essais/pilote_animations/Archer_sous_les_cendres.mp4) · [Archer désactivé](essais/pilote_animations/Archer_desactive.png)

Les deux vidéos montrent la scène de jeu sur l’écran de droite avec un profil de contrôle en mémoire. Les essais portent sur des extraits de la première vague. Les lanceurs locaux `dist/pilote-animations/Essayer_au_Gue.cmd` et `Essayer_les_Eruptions.cmd` utilisent une copie du commit `5783f3f` avec les quatre planches des deux unités. Les deux démarrages ont été vérifiés. Ils ouvrent les mêmes missions en préparation, avec l’archer déjà placé. Le joueur lance la vague et peut régler sa vitesse.

Le validateur retourne `dossiers=2 problemes=0`. La régression ciblée `test_animation_library.gd` réussit avec 76 contrôles Godot et 17 tests Python exécutés par le lanceur. Voir [l’autocontrôle visuel](Validation_visuelle_animations.md#autocontrôle-du-pilote--11-novembre-2026) pour ses observations et limites.

## Points à évaluer avec le porteur

- La démarche garde un léger glissement sur la composante verticale des diagonales. Le profil est retourné au virage par le moteur. Une vue dédiée par orientation ou un maillage pourra être évalué si ce mouvement gêne à taille réelle.
- Le moteur déclenche la flèche dès le début du tir, avec le départ historique. La planche place le lâcher dans les 40 premières millisecondes pour réduire le décalage perceptible. Le champ `muzzle` est prêt si Claude Code décide de le brancher au rendu.
- L’animation du défenseur montre des cendres pendant la désactivation. Le repère de carte actuel reste visible. Le choix de l’habillage de l’avertissement et de la combinaison lave/cendres relève d’un prochain lot.
- Le porteur peut juger le naturel à la taille du plateau, l’intérêt du format par planches pour la série et l’effort artistique acceptable avant toute extension. Le loup conserve son maillage approuvé. Les études du sanglier attendent ce retour et le choix de sa technique.

## Suite du pilote — appuis de l’orc

**Suite livrée pour essai sur le moteur v0.175.** Les deux variantes sont branchées dans les sources locales. Les mesures et les vidéos finales sont dans [Appuis_Guerrier_Orc.md](Appuis_Guerrier_Orc.md). Le diagnostic ci-dessous concerne le pilote initial.

Le 11 novembre 2026, le porteur indique que le résultat lui paraît bien et demande de traiter le glissement s’il persiste. Les changements du moteur examinés après son retour ajoutent des animations d’événements. La marche de l’orc utilise toujours le même profil retourné horizontalement selon le trajet. La limitation du pilote demeure.

Le déplacement projeté sur le plateau change de signe en hauteur selon la pente. À foulée de 25,6 px et 16 poses, le personnage avance d’environ 0,72 px en hauteur par intervalle de pose. Pour un appui de trois intervalles, le dessin doit compenser environ 2,15 px vers le haut sur une pente et 2,15 px vers le bas sur l’autre. Ces valeurs décrivent la géométrie du plateau. La dérive résiduelle du pied dépend de la pose dessinée et reste à mesurer sur le candidat corrigé.

Proposition à coordonner avec Claude Code : laisser le moteur choisir entre deux planches de marche, l’une pour le trajet qui monte à l’écran et l’autre pour celui qui descend, avec miroir gauche/droite et phase de foulée conservée. Codex cale chaque botte en appui, en conservant le torse droit et les proportions de la silhouette. Vérifier ensuite le contact avec un repère de sol fixe sur les quatre diagonales, aux vitesses ×1 et ×2, puis au virage et en pause. Les chiffres de combat et la marche du loup restent ceux du jeu.
