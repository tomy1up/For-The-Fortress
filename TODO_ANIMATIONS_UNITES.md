# Animations, unités et effets — mission complète pour Codex

Préparé par Claude Code le 11 novembre 2026, à partir de la v0.173 (cent missions jouables). Ce fichier regroupe tout le travail artistique lié aux **animations**, aux **créations d'unités** (dont les toutes nouvelles) et aux **effets visuels des affixes**. Il complète [TODO_VISUELS.md](TODO_VISUELS.md), qui garde l'habillage des cartes et des biomes. Rôles : Codex produit, Claude Code intègre et teste (voir `AGENTS.md`, « Répartition des rôles »).

Tout visuel ou toute valeur non validé reste « habillage de prototype à confirmer ». Le porteur valide chaque famille d'animation avant son extension aux autres unités (décision du 1er novembre 2026, voir `design/Validation_visuelle_animations.md`).

## 1. Approche recommandée (à valider par le porteur)

1. **Phase 0 — cadre technique (Claude Code) : livré en v0.174, voir [design/Format_animations.md](design/Format_animations.md).** Un chargeur d'animations générique : chaque unité fournit ses images et un petit fichier de description (`.json` : animations, nombre d'images, cadence, point d'appui au sol, point de départ des projectiles, côté regardé par défaut). Le code le lit sans modification par unité, avec repli sur l'image fixe actuelle. Codex n'a alors qu'à déposer des fichiers. Livré : `scripts/animation_library.gd`, contrôle `tools/validate_animations.gd`, dossier `prototype/assets/animations/`. Branchés (v0.174 puis v0.175) : marche (avec variantes `walk_up` / `walk_down` selon la pente), coup reçu, apparition et mort des ennemis ; repos, tir, désactivation, achat, niveau et revente des défenseurs ; avertissement des Éruptions (`effect.eruption`, mode `progress`).
2. **Phase 1 — pilote (Codex).** Deux unités seulement, une par camp et par rôle : un défenseur (archer elfe) et un ennemi (guerrier orc). Cycle complet (voir §3) validé par le porteur en jeu avant toute extension.
3. **Phase 2 — production par priorité** (§7), famille par famille, avec validation du porteur à chaque famille.
4. **Phase 3 — effets, affixes et habillage des biomes**, en parallèle de la phase 2 puisqu'ils sont indépendants des unités.

Pourquoi : sans cadre commun, chaque animation demande du code propre (c'est ce qu'a coûté le loup : maillage et courbes dédiés). Avec un format commun, une animation = des fichiers déposés, vérifiés par un test automatique (cadres disjoints, point d'appui, boucle fermée).

Choix de technique à arbitrer par le porteur, pilote à l'appui :

- **Planches d'images (recommandé pour la série)** : 12 à 16 images par cycle de marche, boucle fermée, fond transparent. Simple à intégrer, prévisible, coût de rendu faible. Les cycles de 8 poses du loup ont été jugés trop saccadés : viser 12 à 16 et valider.
- **Déformation de maillage (méthode du loup)** : rendu très fluide, mais lourd à produire pour chaque unité (maillage, courbes, tests). À réserver aux créatures qui le justifient (ours, sanglier, tortue).
- **Couches séparées pour les défenseurs** (corps, bras, arme, projectile) : permet une vraie animation d'attaque sans refaire l'illustration entière ; plus de travail par unité mais réutilisable pour tous les niveaux.

## 2. Contraintes communes

- Style cartoon retenu : `design/Assets_Alliance_v061.md`, `design/Assets_Horde_v060.md`, `design/Assets_Ennemis_v064.md`. Les nouvelles unités doivent rester cohérentes avec ces références et lisibles à la taille de jeu (hauteur d'affichage d'environ 34 px pour un ennemi standard, voir `FRAMES` dans `scripts/enemy_art.gd`).
- Vue isométrique : les routes suivent des diagonales (quatre directions de déplacement à l'écran). Une route presque de face reste à dessiner (limite connue du loup). Fournir au moins deux orientations (droite et gauche, la seconde pouvant être le miroir quand la symétrie le permet) ; la véritable vue frontale est un bonus.
- Fond transparent, pas de scintillement une fois réduit (niveaux de détail), point d'appui au sol défini, boucle de marche fermée sans à-coup.
- Accord pas et vitesse : le cycle suit la distance parcourue (pied d'appui presque fixe par rapport au sol), pas un temps fixe. Les ennemis ont des vitesses de 0,45 à 1,65 ; le jeu tourne à plusieurs vitesses et peut être mis en pause.
- Aucune animation ne modifie le combat : le modèle est résolu par événements, les animations ne sont qu'un habillage. Les durées (0,26 s pour un tir) ne retardent ni dégâts ni récompenses.
- Contrôle visuel obligatoire avant présentation (tableau de `design/Validation_visuelle_animations.md`).
- **Animations par planches** : déposer les fichiers dans `prototype/assets/animations/<id>/` suffit (inclusion et empreintes automatiques), puis lancer `tools/validate_animations.gd`. Tout autre nouvel asset d'exécution doit être déclaré dans les trois listes d'export (`export_presets.cfg`, `Exporter_Windows.ps1`, `tests/export_sources.py`), sinon le jeu exporté ne démarre pas ; un test lancé depuis les sources ne le voit pas.
- Si Codex doit toucher au code pour intégrer, garder les tests au vert et le signaler dans `PASSATION.md`.

## 3. Cycle d'animation à fournir par type

**Défenseur** : repos (légère respiration), attaque vers la droite et vers la gauche (anticipation, tir, récupération, 0,26 s simulée en jeu aujourd'hui), achat (apparition), amélioration de niveau (niveaux 1 à 4 lisibles), spécialisation (branche choisie visible), revente (disparition), désactivation (affixe Éruptions, voir §5), état sélectionné/survolé si besoin.

**Ennemi** : marche (boucle fermée), mort (petite animation ou dissolution), coup reçu (le jeu a déjà un flash de dégâts), arrivée à la forteresse (impact sur la forteresse), apparition à l'entrée.

**Boss** (Seigneur de siège : maréchal ou chef de guerre) : marche plus lourde, mort plus marquée, présence lisible.

## 4. Inventaire des unités

État au 11 novembre 2026. « Image fixe » = une illustration unique retournée et animée globalement par le code (mouvement de présentation, pas d'articulation).

### Défenseurs (6 de base + 4 de boutique)

| Camp | Unité | État visuel actuel | À produire |
| --- | --- | --- | --- |
| Alliance | Archer elfe | Image fixe + 3 poses de tir (encochage, lâcher, réarmement) | Animation d'attaque complète G/D, repos, niveaux 1–4, spécialisations, achat/revente |
| Alliance | Arbalétrier nain | Image fixe + pose de réarmement | Idem, armement lent lisible |
| Alliance | Mage humain | Image fixe | Idem, incantation, effet d'explosion |
| Horde | Lanceur de haches troll | Image fixe | Idem, lancer et rebond |
| Horde | Sapeur gobelin | Image fixe | Idem, lancer de charge |
| Horde | Chaman orc | Image fixe | Idem, totem, malédiction |
| Alliance (boutique) | Rôdeur elfe | Image fixe | Animation d'attaque rapide (intervalle 0,7 s) |
| Alliance (boutique) | Mousquetaire nain | Image fixe (2 versions) | Tir lent à longue portée, fumée |
| Horde (boutique) | Traqueur troll | Image fixe | Tir et rebond secondaire |
| Horde (boutique) | Grenadier gobelin | Image fixe | Lancer et explosion de zone |

Les niveaux 1 à 4 et les spécialisations (deux branches par défenseur) n'ont aujourd'hui aucune différence visuelle autre que des indicateurs d'interface : à étudier avec le porteur (ajouts d'équipement, aura, couleur d'accent).

### Ennemis par camp adverse

Les attaquants sont ceux du camp opposé au joueur. Chaque profil a donc **deux identités** (une vue par camp) ; les neutres sont communs.

| Profil | Face à la Horde (camp Alliance) | Face à l'Alliance (camp Horde) | État actuel |
| --- | --- | --- | --- |
| 1 | Fantassin humain | Guerrier orc | Image fixe (atlas `alliance_v002`, `horde_v003`) |
| 4 | Éclaireur elfe | Éclaireur gobelin | Image fixe |
| 5 | Brise-remparts nain | Colosse troll | Image fixe |
| 6 | Garde royal humain | Garde noir mort-vivant | Image fixe |
| 7 (boss) | Maréchal de l'Alliance | Chef de guerre orc | Image fixe |
| **10 (nouveau)** | **Capitaine de garnison humain** | **Capitaine de garnison orc** | **Silhouette provisoire du maréchal / chef de guerre** |

Neutres : Loup de meute (profil 0 ; **seule marche approuvée**, `design/Marche_loup_v0108.md`, `Orientation_loup_v0109.md`), Sanglier sauvage (profil 2 ; études non approuvées dans `design/essais/sanglier_*`), Ours sauvage (profil 3 ; image fixe), Tortue gardienne des berges (profil 8 ; image fixe), **Noyé (profil 9 ; nouveau, silhouette de tortue provisoire)**.

Anciennes illustrations non rattachées à un profil actuel : `assets/enemies/grouillant_v001.png`, `pillard_v001.png`, `sprinter_v001.png` (à relier ou retirer, à décider avec Claude Code).

### Unités toutes nouvelles (créations)

| Unité | Version | Description et besoins |
| --- | --- | --- |
| **Noyé** | v0.164 (mission 51) | Créature neutre des marais, 150 PV de base, régénère dans l'eau. Silhouette, marche, effet visible pendant la régénération dans l'eau. Échelle de jeu 1,1. Réf. : `design/Mission_051_Eaux_Mortes_Noye.md`. |
| **Tortue gardienne** | chapitre 2 (missions 11 à 20) | Existe en image fixe. Besoin : marche, et **lien de protection** lisible avec ses voisins (le code trace aujourd'hui des liens provisoires). |
| **Capitaine de garnison** (2 versions) | v0.173 (chapitre 10) | Unité d'élite de la citadelle, 520 PV de base, vitesse 0,6. Doit se distinguer de l'élite ordinaire (360 PV, 0,75) et du boss (600 PV, 0,45) : massive, plus lente que l'élite, avec équipement de commandement. Orc quand on joue l'Alliance, humain quand on joue la Horde. Réf. : `design/Missions_091_100_Garnison.md`. |
| **Forteresses et rois** | existants | `assets/fortresses/` : états d'endommagement de la forteresse (`fortress_caption` : trois niveaux de condition dans `valley_view.gd`), réaction à l'impact d'un ennemi, roi visible. À évaluer. |

## 5. Effets visuels des affixes et règles (priorité haute : ils portent une information de jeu)

Chaque effet doit se lire en un coup d'œil, à vitesse du jeu augmentée, sans cacher l'unité ni le chemin.

| Affixe / règle | Où | Information à transmettre | État du code |
| --- | --- | --- | --- |
| **Éruptions** (missions 71–80) | `valley_model.gd` : `eruption_status()` renvoie `{slot, state "warning"/"active", number, remaining}` ou `{}` | 3 s avant la désactivation : l'emplacement visé ; puis 5 s : l'unité désactivée ne tire plus ; fin claire. Choix du porteur à trancher : **recommandation de Claude Code** : fissures de lave et braises (avertissement) puis nuage de cendres sur l'unité (désactivation). Le porteur aime l'idée des cendres et s'interroge sur la lave ; le visuel doit rester cohérent avec toutes les unités. | `valley_view.gd::_draw_eruption` : losange orange pulsant puis losange sombre et cercles gris, provisoire |
| **Vents contraires** (chapitre 4) | Affixe : tous les défenseurs attaquent 10 % moins souvent | Une indication de vent sur la carte et/ou sur les défenseurs (poussière, herbes couchées, étendards), sans surcharger | Repère provisoire (v0.175) : traînées claires sur le plateau, `_draw_headwinds` |
| **Noyé et tronçons inondés** (chapitre 6) | `flooded` dans les cartes ; `enemy_in_water` | Où l'eau régénère, et quand un Noyé régénère | Trait bleu translucide provisoire (voir `TODO_VISUELS.md`) |
| **Tortue gardienne** (chapitre 2) | Absorbe 25 % des dégâts des voisins proches | Lien de protection entre la tortue et les voisins protégés, absorption visible | Liens provisoires (`inspected_protection_links`, `valley_view.gd`) |
| **Garnison** (chapitre 10) | Ennemi d'élite | Infobulle de prévision déjà posée | Silhouette provisoire |

Autres effets de combat à habiller (projectiles et impacts) : flèche de l'archer (3 poses existantes), carreau de l'arbalétrier, projectile du mage et explosion secondaire, hache et rebond du troll, charge du sapeur et explosion, malédiction du chaman (+1 s, +2 s), balle du mousquetaire, tir du rôdeur, tir et rebond du traqueur, grenade et explosion du grenadier. Points de départ par classe : `art.MUZZLES` (voir `design/Animations_attaque_v062.md`).

## 6. Habillage de décor lié aux unités

Voir `TODO_VISUELS.md` pour le détail par biome. Rappel du lien avec les unités : en **citadelle** (chapitres 9 et 10), l'habillage dépend de la faction jouée (citadelle de la Horde quand on joue l'Alliance et inversement) ; les ennemis y sont déjà ceux du camp adverse.

## 7. Ordre de production proposé

1. **Pilote** (consigne prête à lancer : [PILOTE_CODEX.md](PILOTE_CODEX.md)) : archer elfe (repos, tir, désactivation) + guerrier orc (marche) → validation du porteur en jeu. La mort n'est pas branchée en v0.174.
2. **Affixe Éruptions** (effet d'avertissement et de désactivation) : seul effet qui porte une règle de jeu visible déjà livrée.
3. **Ennemis les plus fréquents** : fantassin / guerrier (profil 1), éclaireur (4), puis colosse / brise-remparts (5), garde (6).
4. **Défenseurs de base** : arbalétrier, mage, lanceur, sapeur, chaman ; niveaux 1 à 4 et spécialisations.
5. **Neutres** : sanglier (reprendre les études), ours, tortue (marche + lien), Noyé (silhouette définitive + régénération).
6. **Boss et Garnison** : maréchal, chef de guerre, capitaines de garnison.
7. **Boutique** : rôdeur, mousquetaire, traqueur, grenadier.
8. **Vents contraires**, états de la forteresse, projectiles et impacts restants.

## 8. Livraison et suivi

- Une case par asset livré dans `TODO_VISUELS.md` (section « Livré »), avec la version et les fichiers.
- Pour chaque famille : étude comparative si un choix artistique est ouvert, fiche `design/` avec la décision du porteur et sa date, captures de contrôle dans les deux camps.
- Les chiffres de combat ne changent pas pendant ce travail : si un besoin de gameplay apparaît (par exemple une animation plus longue que l'intervalle de tir d'un rôdeur à 0,7 s), le signaler à Claude Code.

## 9. Questions ouvertes pour le porteur

- Technique d'animation à retenir pour la série (planches, couches séparées, maillage) après le pilote.
- Éruptions : lave, cendres ou les deux (recommandation en §5).
- Faut-il une différence visuelle par niveau (1 à 4) et par spécialisation, ou seulement des indicateurs d'interface ?
- Nom de la Garnison : conserver « Capitaine de garnison humain / orc » ou reprendre « maréchal » et « chef de guerre » (déjà pris par les boss) ?
- Son : toujours pas abordé ; à décider avant d'animer les impacts si l'on veut caler image et son.
