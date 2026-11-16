# Validation visuelle des animations

## État du loup au 2 novembre 2026

Le porteur approuve la démarche « thorax et bassin » pour le prototype, puis confirme que l’animation lui convient en jeu. Il rejette cependant l’étirement diagonal de la v0.108. La [v0.109](Orientation_loup_v0109.md) corrige ce placement en conservant les courbes et le dessin approuvés : rotation rigide, appuis et cadence liés au déplacement. Les contrôles techniques ne valent pas approbation du nouveau placement par le porteur.

Décision du porteur du projet, 1 novembre 2026 : l’animation doit donner une impression naturelle de marche. L’agent doit effectuer son propre contrôle visuel avant de présenter un résultat. La validation du porteur reste nécessaire avant d’étendre le travail du loup aux autres unités.

## Retour sur les essais du loup

Le cycle de huit poses de la v0.105 est jugé trop saccadé et ne donne pas une impression convaincante de marche. Le petit format en jeu ne justifie pas ce défaut.

Le montage articulé essayé ensuite est rejeté : pattes trop fines, raccords incorrects et silhouette dénaturée. Il est retiré du projet et archivé hors production. Aucune v0.106 de ce montage n’est compilée ni publiée. Les planches de sanglier et d’ours produites pendant cet essai ne sont pas intégrées.

La v0.105 demeure une version historique disponible, avec une animation du loup à reprendre ; son existence ne constitue pas une approbation artistique.

## Contrôle avant présentation

| Critère | Vérification visuelle attendue |
| --- | --- |
| Silhouette | Le loup conserve les proportions et le caractère de son dessin original, sans membres anormalement fins, allongés ou déformés. |
| Anatomie et raccords | Quatre pattes identifiables, articulations plausibles, épaules et hanches rattachées au corps, aucun élément détaché ou trou visible. |
| Appuis | Les pattes se posent, portent le corps et se relèvent selon une démarche cohérente. Absence de pédalage, de glissement évident ou de saut involontaire. |
| Accord du pas et de la vitesse | Exigence précisée par le porteur le 1 novembre : pendant la poussée, la patte en appui reste presque fixe par rapport au sol tandis que le corps avance. La longueur du cycle dessiné doit correspondre à la distance parcourue ; la cadence augmente avec la vitesse et s'arrête avec le déplacement. Un simple choix de 24 ips ne démontre pas cet accord. |
| Fluidité | Aucun changement brutal de forme, de longueur de membre ou de position. La fin du cycle rejoint son début sans à-coup. |
| Poids du corps | Le mouvement des épaules, du bassin et du corps accompagne les appuis sans rebond artificiel ni impression de marionnette. |
| Déplacement réel | Observer le loup avançant sur une route du plateau, avec un sol et un décor fixes permettant de juger ses contacts. Un atelier sur place sert seulement au diagnostic. |
| Taille et direction | Examiner la taille de jeu et un agrandissement raisonnable, dans les deux sens et les deux contextes de faction. L’agrandissement ne sert pas à masquer un défaut du rendu courant. |
| Présentation de la preuve | Fournir une vidéo fluide du rendu réel ; ne pas expliquer une animation défectueuse par le seul format du GIF. Indiquer les éventuelles limites de capture. |

Un défaut évident sur l’un de ces critères impose une correction avant présentation. Une amélioration de la fluidité ne suffit pas si l’anatomie ou la silhouette ne convient pas.

## Contrôle technique distinct

Vérifier séparément le survol, les réactions aux dégâts, l’arrêt du mouvement, les changements de direction et les vitesses de combat. Préserver les statistiques, les trajets logiques, les récompenses, les identités de faction et la progression persistante. La vitesse ×10 demeure un outil de débogage ; la démarche se juge d’abord à vitesse normale.

Des tests réussis démontrent uniquement les propriétés qu’ils contrôlent. La continuité mathématique, l’alignement de deux segments ou le nombre de poses ne prouvent pas qu’un animal paraît naturel.

Retour sur le candidat à 24 poses : le porteur le juge meilleur, mais encore saccadé et insuffisamment naturel dans son enregistrement de mission. Il demande une poussée et un rythme cohérents avec le déplacement. Ce candidat demeure **non validé**. Contrôler la séquence appui → poussée → levée → retour, les transitions entre poses et la distance d'un cycle avec un repère de sol fixe, à vitesse normale puis à une autre vitesse. Les mesures de dérive des pattes servent au diagnostic ; aucun seuil numérique d'acceptation n'est approuvé à ce stade.

## Validation du porteur du projet

Présenter un candidat après cet autocontrôle, avec un aperçu en déplacement et une version jouable si nécessaire. Signaler explicitement ce qui reste à valider. Attendre le retour sur le loup avant d’appliquer la méthode aux autres animaux ou unités.

## Autocontrôle du pilote — 11 novembre 2026

| Critère | Archer elfe | Guerrier orc |
| --- | --- | --- |
| Silhouette et raccords | Arc, carquois et cape reconnaissables à taille de jeu. Poses du tir issues du dessin existant. Le bras protège le visage pendant la désactivation. | Hache, bandana et silhouette courte reconnaissables. Les jambes restent rattachées à la tunique et les bottes se distinguent au pas. |
| Appuis et poids | Pieds stables au repos. La compression des épaules et le geste de protection signalent la désactivation. | Les bottes alternent appui et retour. Le haut du corps descend légèrement à la prise de poids. Un léger glissement reste perceptible dans l’axe vertical de la diagonale. |
| Cadence et fluidité | Respiration en boucle et lâcher lisible avant la récupération. La mise en joue est brève, car le tir du modèle part au début de l’événement. | Les 16 poses défilent en jeu. La cadence suit le déplacement à ×1 et ×2. En pause de contrôle, la marche se fige. Le passage de la dernière à la première pose est moins marqué que le retournement instantané aux angles. |
| Taille et direction | Tir observé à droite au Gué et des deux côtés au Cratère. L’arc et la tête émergent des cendres en jeu. | Profil gauche et droit observés sur les deux pentes du plateau. Le miroir garde les proportions. Une vue de face reste à dessiner si les futurs trajets l’exigent. |
| Preuves | Repos, tir, désactivation et reprise visibles dans les vidéos à 60 images/s. | Déplacement sur le tracé réel avec décor fixe, vues à taille de jeu et contrôle image par image en agrandissement. |

La vérification de pause est réalisée avec la scène de contrôle figée. Le repos est calculé sur l’horloge réelle dans le moteur et peut changer de pose si un autre écran force un nouveau dessin. Les images, résultats et limites du pilote sont regroupés dans [Pilote_animations.md](Pilote_animations.md). La décision artistique appartient au porteur.

## Grenadier gobelin · 16 novembre 2026

| Critère | Vérification sur la copie v0.220 |
| --- | --- |
| Appuis et volume | Semelles identiques sur les vingt poses. Le buste recule pendant l’armé et avance au lâcher, sans changement d’échelle. |
| Prise et lâcher | La grenade quitte la main à 0,42 s, sur la première pose à main vide. L’arc rejoint l’impact et le bras poursuit le geste. |
| Retour | La main revient vers la ceinture puis la dernière pose rejoint la garde à l’identique. |
| En jeu | Six tirs sur la mission 94, dans les deux sens à ×1 et ×2, pose contrôlée en pause. [Capture à taille native](essais/gestes_combat/grenadier_gobelin/Grenadier_gobelin_en_jeu.gif). Retour favorable du porteur sur le lancer. |
