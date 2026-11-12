# Visuels à réaliser — file de Codex

Tâches artistiques confiées à Codex : visuels, animations, effets visuels, icônes, habillage et décor. Claude Code ajoute ici les besoins visuels qu'il rencontre en codant et ne les réalise pas lui-même. Codex coche ou retire une tâche quand il l'a livrée, et note la version concernée.

**Mission d'ensemble animations, unités et effets** : voir [TODO_ANIMATIONS_UNITES.md](TODO_ANIMATIONS_UNITES.md) (approche en phases, inventaire complet, affixes, ordre de production).

Format : une case par tâche, avec le contexte (mission, unité, écran), ce qui existe déjà et les contraintes (fichiers, taille, intégration attendue).

## À faire

- [ ] **Souterrains et mines, missions 121–130 (v0.183)** — biome validé par le porteur le 12 novembre 2026, habillage à produire. Le code pose une palette provisoire (`mine` dans `assets/decor/decor.json`), sans pièce ni placement. Cartes : `prototype/scripts/mine_maps.gd`.

- [x] **Variantes du décor volcanique** — basalte éclaté, ruine d’angle et 120 placements recomposés sur les missions 61–80. Contrôle en combat dans les deux factions et à ×2 sur les six cases du Cratère Fumant. [Variantes et captures](design/Visuels_Biome_Volcanique.md#variantes-et-placements-des-missions-61-à-80)


- [ ] **Habillage des marais, missions 41–45** : palette, chaussées, bassins, roseaux, saules et piliers brisés sont encore des formes de prototype à affiner (`prototype/scripts/marsh_art.gd`, `scenery_for` dans `valley_view.gd`). Les bassins restent décoratifs : ne pas recouvrir routes ni emplacements. Références : `design/Mission_041_Seuil_des_Marais.md`, `design/Missions_042_043_Marais.md`, `design/Missions_044_045_Marais.md`.
- [ ] **Garnison, missions 91–100 (v0.173)** — *capitaine humain intégré en v0.176 ; reste : capitaine orc (illustration à valider), marche et mort.*  : nouvel ennemi d'élite de la citadelle, une version par faction (« Capitaine de garnison orc » quand on joue l'Alliance, id `enemy.horde.garrison` ; « Capitaine de garnison humain » quand on joue la Horde, id `enemy.alliance.garrison`). Silhouette provisoire : celle du chef de guerre / du maréchal (`enemy_art.gd`, mêmes cadres). À produire : sprite, marche, mort, lisibilité à côté de l'élite ordinaire et du boss (la Garnison est plus lente et plus massive que l'élite, moins que le boss). Référence : `design/Missions_091_100_Garnison.md`.
- [ ] **Citadelles, missions 81–100** — *décor intégré sur les vingt cartes en v0.178 ; ancienne note : décor intégré en v0.176 sur les missions 81 et 87 (`design/Format_decor.md`) ; extension livrée et vérifiée dans les deux factions sur 83–86 et 88–100. Le Pont-levis (82) a une proposition essayée en jeu et attend l’ajustement du test témoin avant intégration.*  : décision du porteur du 11 novembre 2026, thématique unique : citadelle de la faction adverse (Horde quand on joue l'Alliance, Alliance quand on joue la Horde). Les cartes (`scripts/citadel_maps.gd`, décor `citadel`) sont identiques pour les deux factions ; le code ne pose que des couleurs de pierre neutres (sol `55555d`, faces `4a4a52` / `35353c` dans `valley_view.gd`, `55555d` dans `campaign_screen.gd`). À produire : deux habillages (citadelle orque/morte-vivante et citadelle humaine/naine/elfe) choisis d'après `model.faction`, remparts, tours, portes, étendard, chemin et forteresse lisibles. Le chapitre 10 (Garnison, ennemi d'élite) demandera aussi les visuels d'unité de la Garnison. Référence : `design/Missions_081_090_Citadelle.md`.
- [ ] **Vents contraires, chapitre 4 (v0.175)** : le code pose un repère neutre (traînées claires qui traversent le plateau, `_draw_headwinds` dans `valley_view.gd`) tant que l'affixe est actif. À remplacer par un habillage cohérent avec les marais et les ardoises (poussière, herbes couchées, étendards, nuages), lisible sans masquer chemin ni unités. Réf. : affixe « Tous les défenseurs attaquent 10 % moins souvent » (`Missions_031_040_*`).
- [x] **Tempête de sable, missions 111–120 (v0.180)** — *planches d’avertissement et de rafale livrées, en attente d’intégration*. [Contrôles en combat](design/Visuels_Biome_Desert.md#chapitre-12--la-tempête-de-sable).
- [ ] **Désert et ruines, missions 101–120 (v0.179)** — *palette, calque et placements terminés sur les vingt cartes, en attente d’intégration*. La palette des miniatures de campagne reste à brancher. [Captures des deux chapitres](design/Visuels_Biome_Desert.md).
- [ ] **Éruptions, missions 71–80** — *avertissement renforcé et planche de désactivation livrée pour intégration.* Cendres et retour à l’état normal contrôlés sur les six emplacements à ×1 et ×2. Le branchement de la désactivation reste à faire. [Captures et fiche](design/Avertissement_Eruptions.md#désactivation-par-les-cendres).
- [ ] **Biome volcanique, missions 61–80 (v0.167)** — *première version intégrée en v0.176 (palette, cendres, quatre pièces sur les 20 cartes) ; variantes de pièces et nouvelles dispositions livrées sur les vingt cartes, à confirmer par le porteur. Alerte contrôlée sur la 71 à ×1 et à ×2.*  : décision du porteur du 10 novembre 2026 (terres volcaniques et cendres, chapitres 7 et 8). Tout l'habillage est à produire : le code ne pose que des repères de couleur neutres (sol `3d3837` et deux faces `4a403d` / `352e2d` dans `valley_view.gd`, `3d3837` dans l'aperçu de `campaign_screen.gd`), sans décor automatique (`scenery_for` ne traite pas encore le décor `volcanic`), sans bassins ni coulées. À prévoir : palette du sol et de la chaussée, décor (roches, cendres, fumerolles, ruines noircies), éventuelles coulées décoratives posées hors des chemins et des emplacements, forteresse et défenseurs lisibles sur fond sombre. Cartes : `scripts/volcanic_maps.gd` (vingt cartes, chapitres 7 et 8) ; références : `design/Missions_061_070_Volcan.md` et `design/Missions_071_080_Eruptions.md`.
- [ ] **Eau et bassins des missions 52–60 (v0.165)** : les neuf cartes (`scripts/drowned_maps.gd`) ont des tronçons inondés tracés en bleu par le code et quatre bassins décoratifs posés automatiquement dans les espaces libres. À habiller : lisibilité de l'eau sur les trajets à plusieurs entrées (certaines eaux sont sur la partie commune, d'autres sur une seule branche), forme et placement des bassins, décor. Les marges des chemins et des emplacements sont vérifiées par `test_drowned_chapter.gd` ; les ruines et roseaux dépendent de l'identifiant de la carte (le placement du décor est tiré de cet identifiant).
- [ ] **Gueule-de-Vase, ex-Noyé (mission 51)** — silhouette, nom et remous intégrés en v0.176. Contraste des remous renforcé et contrôlé à ×1 et ×2 dans les deux factions. La marche reste à produire. [Comparatif](design/Visuel_Gueule_de_Vase.md#contraste-des-remous-en-combat)
- [x] **Tronçons inondés, missions 51–60** — dix calques reliés aux cartes. Transitions de la 51, croisement et survol des routes de la 58 contrôlés dans les deux factions. L’aperçu de mission reste à traiter. [Contrôles et extension](design/Visuels_Troncons_Inondes.md#contrôle-en-combat-et-extension-sur-la-v0178)
- [ ] **Bassins des missions 46–50 (v0.163)** : Chaussée des Roseaux, Trois Gués Noyés, Îlots du Chœur, Nef Effondrée et Sanctuaire Englouti utilisent des bassins posés par Claude Code comme emplacements neutres (`water_areas` dans `map_definition.gd`). Revoir leur forme, leur nombre et leur placement, sans toucher aux routes ni aux emplacements de défense (`test_marsh_campaign.gd` vérifie ces marges). La Nef (mission 49) est très encombrée : le décor automatique n'y trouve place que pour quatre éléments.
- [ ] **Ruine compacte du Cloître Submergé (mission 45)** : en v0.162, une ruine remplace un saule quand les marges écartent toutes les ruines. Prévoir un visuel de ruine adapté à cette emprise réduite, inclus dans les limites d'un saule.
- [ ] **Animations des unités** : seul le loup a une marche approuvée (`design/Marche_loup_v0108.md`, `design/Orientation_loup_v0109.md`). Les autres unités et ennemis restent à animer.
- [ ] **Sanglier** : étude non intégrée et non approuvée (`design/essais/sanglier_peau_continue/README.md`, `design/essais/sanglier_virages/README.md`).

## Livré

- [x] **Éclaireur elfe, course** — trois planches de 20 poses testées en jeu sur les quatre diagonales à ×1 et ×2. Aperçu en attente de retour du porteur. [Fiche](design/Visuel_Eclaireur_Elfe.md).

- [x] **Éclaireur gobelin, course** — trois planches de 20 images dans les ressources de jeu. Test témoin corrigé, avis visuel favorable et contrôle en jeu à ×1 et ×2. En attente d’intégration dans `main`. [Aperçu](design/Visuel_Eclaireur_Gobelin.md).

- [x] **Fantassin humain, marche** — trois planches de 20 images, quatre diagonales vérifiées à ×1 et ×2 sur Les Coulées Figées. À juger en jeu par le porteur. [Aperçu](design/Visuel_Fantassin_Marche.md).

- [x] **Lanceur de haches troll, seconde proposition** — transfert de poids, rotation des épaules et reprise de la hache près de la hanche. Vérifié en combat à ×1 et ×2, en attente de l’avis du porteur. [Comparatif](design/Visuel_Troll_Lancer.md#lancer-retravaillé)

- [x] **Lanceur de haches troll, attaque** — lâcher, main vide pendant le vol et retour en garde. Quatre tirs avec rebond vérifiés au Gué, dans les deux sens à ×1 et ×2. [Animation et contrôles](design/Visuel_Troll_Lancer.md)

- [x] **Mage humain, lancement du sort** — geste de la main et éclat du cristal, contrôlés au Gué dans les deux sens à ×1 et ×2. [Animation et captures](design/Visuel_Mage_Incantation.md)

- [x] **Arbalétrier nain, tir et réarmement** — 18 images à partir des poses existantes. Vrais tirs gauche et droite vérifiés à ×1 et ×2, trois cycles enchaînés avec le bonus de cadence. [Animation et contrôles](design/essais/arbaletrier_tir/README.md#tir-par-planche-sur-les-sources-de-la-v0178)

- [x] **Guerrier orc du pilote, appuis en diagonale** — variantes de montée et descente dans les ressources locales. Les quatre diagonales ont été parcourues à ×1 et ×2. Mesures des appuis, pause, validateur et régression vérifiés. Validation artistique du porteur à venir. [Contrôles et vidéo](design/Appuis_Guerrier_Orc.md)

- [x] **Biome volcanique, proposition d’habillage pour les missions 61–80** — quatre pièces, calque de cendres, palette et 120 placements contrôlés. Maquettes sur 61, 66, 71 et 80 dans les deux factions. Intégration et contrôle en combat à faire. [Fiche et visuels](design/Visuels_Biome_Volcanique.md)

- [x] **Tronçons inondés, proposition pour les missions 51–60** — dix calques transparents, repères et contrôles sur les missions 51, 55, 58 et 60 dans les deux factions. Les bassins décoratifs et l’aperçu restent à traiter. [Fiche et maquettes](design/Visuels_Troncons_Inondes.md)

- [x] **Gueule-de-Vase, ancien Noyé** — nom retenu par le porteur, sprite fixe de batracien et planche de remous proposée. Maquettes des Eaux Mortes dans les deux factions et vidéo ×1/×2. L’intégration et la marche restent ouvertes. [Fiche et visuels](design/Visuel_Gueule_de_Vase.md)

- [x] **Citadelles, première proposition d’habillage par faction** — huit pièces transparentes, palettes et placements d’essai pour les missions 81 et 87. Quatre maquettes inspectées sur captures. L’intégration en jeu et le placement sur les autres cartes restent ouverts. [Fiche et visuels](design/Visuels_Citadelles.md)

- [x] **Garnison, propositions de silhouettes fixes** — capitaine humain avec hallebarde rectiligne et capitaine orc avec bouclier à bande rouge. PNG transparents, points d’appui et comparaison sur La Brèche pour les deux factions. Les silhouettes attendent un retour et un essai intégré. [Fiche et visuels](design/Visuels_Garnison.md)

- [x] **Éruptions, maquette de l’avertissement** — planche transparente de 24 images, comparaison des six emplacements du Cratère Fumant et vidéo ×1/×2. Prête pour avis artistique et branchement. L’intégration en jeu et la désactivation commune restent dans la tâche Éruptions. [Fiche et visuels](design/Avertissement_Eruptions.md)

- [x] **Pilote, archer elfe sur v0.174** — repos, tir et désactivation. `prototype/assets/animations/defender.alliance.archer/` (description et trois PNG). Livré pour essai, validation artistique en attente. [Contrôles et vidéos](design/Pilote_animations.md).
- [x] **Pilote, guerrier orc sur v0.174** — cycle de marche. `prototype/assets/animations/enemy.horde.warrior/` (description et PNG). Livré pour essai, validation artistique en attente. [Contrôles et vidéos](design/Pilote_animations.md).
