# Place commune du bandeau d'affixe (v0.241)

**Statut.** Correctif demandé par le porteur le 22 novembre 2026, sur un signalement de Codex : le bandeau des Vents contraires masquait la route et des ennemis sur les missions 36 et 39 (vague 3, 6,50 s). Codex demandait aussi de vérifier une place commune pour tous les bandeaux, qui laisse les étiquettes d'entrée lisibles. **Placement de prototype à confirmer** (MAJ-82, qui remplace MAJ-77).

## Constat sur la v0.240

Le bandeau de la v0.239 restait centré à 112 px de haut. Il glissait sur le côté s'il touchait une étiquette d'entrée, puis se plaçait au-dessus ou au-dessous des étiquettes. Sur les cartes dont les étiquettes occupent tout le haut, il finissait sur le plateau. Une mesure sur toutes les missions à affixe, au combat et en préparation, compte **14 cas sur 12 missions** :

- Vents contraires 36 et 39, au combat et en préparation ;
- Éruptions 74 et 80 ;
- Tempête de sable 114 ;
- Éboulement 132, 133, 138 et 139 ;
- Brume marine 173, 177 et 178.

Sa place habituelle (112 à 146 px) recoupait aussi le panneau du boss, affiché à la vague 10 de 82 à 154 px.

## Règle

- **Une place fixe**, la même pour tous les affixes et toutes les cartes : 395 à 825 px de large, 24 à 58 px de haut (`AFFIX_BANNER_AREA`). C'est la bande du haut de l'écran, entre le titre « FOR THE FORTRESS! » et le bloc d'informations de droite (faction et vague, talents, fiche d'ennemi), sur l'axe de l'annonce de vague.
- **Ce qu'elle évite.**
  - Le plateau, dont le sommet est à 174 px. Le bandeau reste 40 px au moins au-dessus, de quoi passer au-dessus des ennemis à l'entrée.
  - Les étiquettes d'entrée, qui commencent à 64 px. L'écart est de 6 px au moins dans tous les cas mesurés.
  - Le panneau du boss.
  - La ligne d'affixe à gauche.
- **Effacement.** L'annonce de vague (« VAGUE 3 / 10 », 2 s au départ) et le compte à rebours de la vague suivante (« VAGUE 4 DANS 5 S ») occupent la même bande. Le bandeau s'efface tant qu'ils sont affichés. Seuls les Vents contraires, dont le bandeau est permanent, sont concernés en pratique. Les annonces des autres affixes tombent plus tard dans la vague, et aucune n'est affichée entre les vagues.
- **Étiquettes d'entrée.** Elles ne bougent plus à cause du bandeau. Leur écartement mutuel en préparation (MAJ-78) est inchangé.

## Contrôles

`tests/test_affix_banner.gd` vérifie la place fixe sur toutes les missions à affixe, au combat et en préparation, pour chaque entrée principale possible :

- hors du plateau, et 40 px au moins au-dessus de son sommet ;
- à 6 px au moins de chaque étiquette d'entrée ;
- hors du bloc d'informations de droite, du titre et de la ligne d'affixe ;
- dans la place de l'annonce de vague.

Le même test vérifie le lien avec l'annonce dans `main.gd` : le bandeau s'efface au départ d'une vague, revient à la fin de l'annonce, puis s'efface pendant le compte à rebours de la vague suivante.

## Limites

- Le bandeau des Vents contraires disparaît environ 2 s au départ de chaque vague, puis pendant les 5 dernières secondes de la préparation automatique. La ligne d'affixe à gauche reste affichée.
- La taille du bandeau ne change pas (430 × 34 px). Son texte reste limité à 382 px de large, comme avant.
