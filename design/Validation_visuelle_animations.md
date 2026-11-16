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

## Catapulte gobeline · 16 novembre 2026

| Critère | Vérification sur la copie v0.220 |
| --- | --- |
| Appuis et mécanisme | Bras et cuillère pivotent ensemble. Dans les vues diagonales, la nouvelle projection place deux rangées de patins sur un même plan. Le châssis et les pieds du servant ne se déplacent pas durant le tir. |
| Prise et lâcher | Pierre assise jusqu’à la première cuillère vide à 0,50 s. La trajectoire prolonge le dernier mouvement de la cuillère vers la cible. Bras et cuillère dépassent le pivot côté cible avant le lâcher. Sens horizontal du vol vérifié à 16 intervalles, avec impact et deux cibles secondaires par tir. |
| Retour | La cuillère vide dépasse sa position de garde puis revient. Première et dernière poses identiques. |
| En jeu | Six tirs sur la mission 94 après correction de l’orientation. Quatre diagonales à ×1 et deux à ×2, garde face à la route, pose contrôlée en pause. [Capture à taille native](essais/gestes_combat/catapulte_gobeline/Catapulte_gobeline_en_jeu.gif). Le porteur valide le lot `c71b7b3` après comparaison des quatre diagonales. |

## Lance-épieu orc · 16 novembre 2026

| Critère | Vérification sur la copie v0.223 |
| --- | --- |
| Appuis et prise | 140 poses cadrées, semelles fixes. Le buste participe à l’estoc et le manche reste dans les deux mains. |
| Contact | Éclat à la pointe au bout de 0,28 s, position évaluée par rapport à l’ennemi. L’épieu reste visible dans la prise pendant le retrait. |
| En jeu | Six coups, deux orientations et pause, à ×1 et ×2. [Capture de la mission 94](essais/gestes_combat/lance_epieu_orc/Lance_epieu_orc_en_jeu.gif). Lot `a151adb` validé par le porteur. |

## Brûleur de cendres · 16 novembre 2026

| Critère | Vérification sur la copie v0.223 |
| --- | --- |
| Appuis et poids | Les semelles restent fixes dans les 60 poses. Le buste pousse la poignée et le bol suit avec un léger retard. |
| Départ et brûlure | La braise part de la grille à 0,336 s. Les flammes sur l’ennemi apparaissent à l’impact. Les dégâts périodiques du jeu ont été observés. |
| En jeu | Des deux côtés à ×1 et ×2, avec pose figée en pause. [Capture de la mission 94](essais/gestes_combat/bruleur_cendres/Bruleur_de_cendres_en_jeu.gif). Lot `9eb30c2` validé par le porteur. |

## Mage de la foudre · 16 novembre 2026

| Critère | Vérification sur la copie v0.223 |
| --- | --- |
| Appuis et geste | Les semelles restent identiques dans les 60 poses. Les mains resserrent l’arc puis l’épaule accompagne la décharge. |
| Éclair | Part à 0,32 s depuis la main avancée. La chaîne atteint les points du tir et chaque impact testé correspond à un ennemi touché. |
| En jeu | Six tirs dans les deux sens à ×1 et ×2, avec pause, sur la mission 94. [Capture à taille réelle](essais/gestes_combat/mage_foudre/Mage_de_la_foudre_en_jeu.gif). Lot `e90fd72` validé par le porteur. |

## Veilleur des cendres · 16 novembre 2026

| Critère | Vérification sur la copie v0.223 |
| --- | --- |
| Appuis et geste | Les semelles sont stables sur les 63 poses. L’épaule avance au lancer et la longue-vue reste à la ceinture. |
| Lâcher | Première pose à main ouverte à 0,36 s. Le départ suit la pose et la hachette tourne en ligne droite jusqu’à l’impact. |
| En jeu | Six tirs sur la mission 94 à ×1 et ×2, des deux côtés, avec contrôle de la pause. [Capture à taille réelle](essais/gestes_combat/veilleur_cendres/Veilleur_des_cendres_en_jeu.gif). L’angle neutre a été contrôlé sur planche. Lot `1779fe3` validé par le porteur. |

## Archer double · 16 novembre 2026

| Critère | Vérification sur la copie v0.223 |
| --- | --- |
| Appuis et geste | Pieds stables et garde identique au début et à la fin des 120 poses. Prise au carquois et relevé de l’arc visibles à taille native. |
| Lâcher | La flèche quitte l’arc à 0,60 s à partir de la pointe dessinée. Le vol suit le segment jusqu’à l’impact. |
| En jeu | Six tirs sur la mission 94 à ×1 et ×2, en descente à droite et en visée neutre à gauche, avec pause. Les trois autres angles ont été contrôlés sur planche. [Capture](essais/gestes_combat/archer_double/Archer_double_en_jeu.gif). Lot `226ec17` validé par le porteur. |

## Arbalète lourde · 16 novembre 2026

| Critère | Vérification sur la copie v0.226 |
| --- | --- |
| Appuis et recul | Semelles stables sur les 168 poses. Le recul remonte dans l’épaule avant la reprise de garde. |
| Carreau | Départ à 0,44 s depuis la pointe dessinée. Trajet rectiligne, avec impact seul à bout portant quand le départ projeté dépasse la cible. |
| En jeu | Six tirs sur le nouveau tracé de la mission 94 à ×1 et ×2, des deux côtés et avec pause. [Capture](essais/gestes_combat/arbalete_lourde/Arbalete_lourde_en_jeu.gif). Lot `aa7462b` validé par le porteur. |

## Fronde elfe · 16 novembre 2026

| Critère | Vérification sur la copie v0.226 |
| --- | --- |
| Appuis et geste | Les semelles sont fixes dans les 105 poses. L’épaule entraîne la rotation et la poche vide accompagne le bras devant le corps. |
| Lâcher | Le galet part de la poche à 0,40 s. Un brin est libéré et le vol se prolonge en ligne droite vers un seul impact. |
| En jeu | Dix tirs sur la mission 94 refondue, des deux côtés à ×1 et ×2, avec pause. [Capture à taille réelle](essais/gestes_combat/fronde_elfe/Fronde_elfe_en_jeu.gif). Lot `a683912` validé par le porteur. |

## Hache en chaîne · 17 novembre 2026

| Critère | Vérification sur la copie v0.226 |
| --- | --- |
| Appuis et geste | Les semelles restent stables dans les 120 poses. La hache remonte depuis la hanche et le bras accompagne le lâcher. |
| Lâcher et rebonds | Départ à 0,52 s depuis la hache tenue. La même hache suit l’ordre des impacts enregistrés par le jeu. Trois rebonds vérifiés au premier tir de chaque scénario. |
| En jeu | Dix tirs sur la mission 94, dans les deux sens à ×1 et ×2, avec pause. [Capture à taille réelle](essais/gestes_combat/hache_en_chaine/Hache_en_chaine_en_jeu.gif). Lot `f0b6867` validé par le porteur. |
