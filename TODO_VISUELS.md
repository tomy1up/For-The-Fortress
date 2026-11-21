# Visuels à réaliser — file de Codex

Tâches artistiques confiées à Codex : visuels, animations, effets visuels, icônes, habillage et décor. Claude Code ajoute ici les besoins visuels qu'il rencontre en codant et ne les réalise pas lui-même. Codex coche ou retire une tâche quand il l'a livrée, et note la version concernée.

**Mission d'ensemble animations, unités et effets** : voir [TODO_ANIMATIONS_UNITES.md](TODO_ANIMATIONS_UNITES.md) (approche en phases, inventaire complet, affixes, ordre de production).

Format : une case par tâche, avec le contexte (mission, unité, écran), ce qui existe déjà et les contraintes (fichiers, taille, intégration attendue).

## À faire

- **Décision du porteur, 15 novembre 2026.** La boutique est limitée à 20 unités par faction. Le Fantassin squelette (46) et le Tirailleur gnome (47) sont retirés du catalogue par Claude. Leurs visuels restent dans les archives de design et leurs animations sortent de la file.

- [x] **Première représentation des gnomes de l’Alliance** — le servant de la Balliste royale a été validé le 14 novembre 2026. Sprite prêt à intégrer. [Fiche](design/Visuels_Boutique_Balliste_Royale.md).

- [ ] **Effets de boutique** — première maquette disponible. Faire valider la lisibilité, brancher les repères et vérifier l’affichage en combat avec plusieurs états simultanés. [Fiche](design/Visuels_Effets_Boutique.md).

- [ ] **Silhouettes uniques pour toutes les unités, décision du porteur du 14 novembre 2026** — vérifier les défenseurs de base, les alternatives de boutique et les attaquants à leur taille sur le plateau. Comparer en priorité les unités d’une même famille, au repos et à l’attaque lorsque l’animation existe. Chaque unité doit avoir un signe lisible par sa silhouette, son équipement ou sa posture, renforcé par sa palette. En v0.197, les 36 alternatives des types 10 à 45 utilisent des silhouettes de famille. Les types 10, 11, 16 et 17 ont une proposition sur la branche art, dont la sentinelle redessinée face à l’archer de base. Revoir aussi la silhouette en joue du tireur d’élite face à cet archer. Chez les attaquants, la garnison orque et le chef de guerre partagent le même cadre.

- [ ] **Boutique étendue, quatrième lot (v0.196)** — dix unités (types 36 à 45 : marchand mercenaire, piégeur nain, balliste royale, alchimiste, vétéran royal ; pillard gobelin, poseur de mines, baliste de guerre, gobelin kamikaze, chef de guerre vétéran) à illustrer ; deux effets de jeu de plus sans visuel : pillage (4 s) et volatilité (4 s, puis explosion). Le catalogue de 20 unités par faction est complet côté règles. Voir `design/Boutique_20_unites_proposition.md`. Illustrations fixes des types 36 à 45 livrées sur la branche artistique. Le branchement des derniers sprites, les animations et les effets de combat restent à suivre.

- [ ] **Boutique étendue, troisième lot (v0.194)** — six unités (types 30 à 35 : mage de givre, éclaireur-observateur, prêtre guerrier ; chaman des marais, totem de guerre, ancien des tribus) à illustrer ; trois effets de jeu sans visuel : ralentissement (60 % de vitesse, 3 s), marque de cible (4 s) et aura de gardien (rayon 3,6). Voir `design/Boutique_20_unites_proposition.md`.

- [ ] **Boutique étendue, second lot (v0.193)** — huit unités (types 22 à 29 : mage de la foudre, archer double, arbalète lourde, fronde elfe ; hache en chaîne, lanceur double, lanceur de masse, sarbacane), illustration de famille provisoire. À illustrer comme le premier lot. Voir `design/Boutique_20_unites_proposition.md`.

- [ ] **Boutique étendue, premier lot (v0.192)** — douze unités (types 10 à 21 : sentinelle, tireur d'élite, arquebusier, bombarde, piquier, pyromancien côté Alliance ; veilleur, javelinier, lance-éclats, catapulte, lance-épieu, brûleur côté Horde) qui réutilisent l'illustration de leur famille. À illustrer (même cadrage que les alternatives `rodeur`, `mousquetaire`, `traqueur`, `grenadier`) puis à animer. Voir `design/Boutique_20_unites_proposition.md`.

- [ ] **Revenant, chapitre 20** — portrait et planche de relève livrés pour branchement. [Aperçus](design/Visuels_Necropole.md#revenant).

- [ ] **Aigle des cimes, chapitre 16 (v0.186)** — nouvel attaquant neutre, rapide et fragile (`enemy.neutral.eagle`). Vol livré en combat. Associer le portrait de l’aigle à la prévision et à l’éclaireur. Voir `design/Missions_151_160_Aigle.md`.

- [x] **Variantes du décor volcanique** — basalte éclaté, ruine d’angle et 120 placements recomposés sur les missions 61–80. Contrôle en combat dans les deux factions et à ×2 sur les six cases du Cratère Fumant. [Variantes et captures](design/Visuels_Biome_Volcanique.md#variantes-et-placements-des-missions-61-à-80)


- [ ] **Habillage des marais, missions 41–45** : palette, chaussées, bassins, roseaux, saules et piliers brisés sont encore des formes de prototype à affiner (`prototype/scripts/marsh_art.gd`, `scenery_for` dans `valley_view.gd`). Les bassins restent décoratifs : ne pas recouvrir routes ni emplacements. Références : `design/Mission_041_Seuil_des_Marais.md`, `design/Missions_042_043_Marais.md`, `design/Missions_044_045_Marais.md`.
- [ ] **Garnison, missions 91–100 (v0.173)** — *capitaine humain intégré en v0.176 ; sa marche a été livrée pour avis. Capitaine orc intégré avec sa marche à quatre vues en v0.216. Le porteur retient un [signal bref d’élimination](design/Visuels_Garnison.md#signal-bref-délimination). La flexion du Capitaine orc côté sud-est est prête comme référence du signal d’élite. Le rendu commun reste à intégrer.*  : nouvel ennemi d'élite de la citadelle, une version par faction (« Capitaine de garnison orc » quand on joue l'Alliance, id `enemy.horde.garrison` ; « Capitaine de garnison humain » quand on joue la Horde, id `enemy.alliance.garrison`). Silhouette provisoire : celle du chef de guerre / du maréchal (`enemy_art.gd`, mêmes cadres). À produire : sprite, marche, mort, lisibilité à côté de l'élite ordinaire et du boss (la Garnison est plus lente et plus massive que l'élite, moins que le boss). Référence : `design/Missions_091_100_Garnison.md`.
- [ ] **Citadelles, missions 81–100** — *décor intégré sur les vingt cartes en v0.178 ; ancienne note : décor intégré en v0.176 sur les missions 81 et 87 (`design/Format_decor.md`) ; extension livrée et vérifiée dans les deux factions sur 83–86 et 88–100. Le Pont-levis (82) a une proposition essayée en jeu et attend l’ajustement du test témoin avant intégration.*  : décision du porteur du 11 novembre 2026, thématique unique : citadelle de la faction adverse (Horde quand on joue l'Alliance, Alliance quand on joue la Horde). Les cartes (`scripts/citadel_maps.gd`, décor `citadel`) sont identiques pour les deux factions ; le code ne pose que des couleurs de pierre neutres (sol `55555d`, faces `4a4a52` / `35353c` dans `valley_view.gd`, `55555d` dans `campaign_screen.gd`). À produire : deux habillages (citadelle orque/morte-vivante et citadelle humaine/naine/elfe) choisis d'après `model.faction`, remparts, tours, portes, étendard, chemin et forteresse lisibles. Le chapitre 10 (Garnison, ennemi d'élite) demandera aussi les visuels d'unité de la Garnison. Référence : `design/Missions_081_090_Citadelle.md`.
- [ ] **Vents contraires, chapitre 4 (v0.175)** : le code pose un repère neutre (traînées claires qui traversent le plateau, `_draw_headwinds` dans `valley_view.gd`) tant que l'affixe est actif. À remplacer par un habillage cohérent avec les marais et les ardoises (poussière, herbes couchées, étendards, nuages), lisible sans masquer chemin ni unités. Réf. : affixe « Tous les défenseurs attaquent 10 % moins souvent » (`Missions_031_040_*`).
- [x] **Tempête de sable, missions 111–120 (v0.180)** — *intégrée en v0.182. Contraste renforcé après contrôle en jeu sur 111–120 à ×1 et ×2, en attente d’intégration*. [Contrôles en combat](design/Visuels_Biome_Desert.md#chapitre-12--la-tempête-de-sable).
- [x] **Désert et ruines, missions 101–120** — *habillage complet intégré en v0.182. Palette des miniatures intégrée en v0.181.* [Captures des deux chapitres](design/Visuels_Biome_Desert.md).
- [x] **Éruptions, missions 71–80** — *avertissement renforcé et désactivation intégrés en v0.182.* Cendres et retour à l’état normal vérifiés après intégration sur les six emplacements à ×1 et ×2, dans les deux factions. [Captures et fiche](design/Avertissement_Eruptions.md#désactivation-par-les-cendres).
- [ ] **Biome volcanique, missions 61–80 (v0.167)** — *première version intégrée en v0.176 (palette, cendres, quatre pièces sur les 20 cartes) ; variantes de pièces et nouvelles dispositions livrées sur les vingt cartes, à confirmer par le porteur. Alerte contrôlée sur la 71 à ×1 et à ×2.*  : décision du porteur du 10 novembre 2026 (terres volcaniques et cendres, chapitres 7 et 8). Tout l'habillage est à produire : le code ne pose que des repères de couleur neutres (sol `3d3837` et deux faces `4a403d` / `352e2d` dans `valley_view.gd`, `3d3837` dans l'aperçu de `campaign_screen.gd`), sans décor automatique (`scenery_for` ne traite pas encore le décor `volcanic`), sans bassins ni coulées. À prévoir : palette du sol et de la chaussée, décor (roches, cendres, fumerolles, ruines noircies), éventuelles coulées décoratives posées hors des chemins et des emplacements, forteresse et défenseurs lisibles sur fond sombre. Cartes : `scripts/volcanic_maps.gd` (vingt cartes, chapitres 7 et 8) ; références : `design/Missions_061_070_Volcan.md` et `design/Missions_071_080_Eruptions.md`.
- [ ] **Eau et bassins des missions 52–60 (v0.165)** : les neuf cartes (`scripts/drowned_maps.gd`) ont des tronçons inondés tracés en bleu par le code et quatre bassins décoratifs posés automatiquement dans les espaces libres. À habiller : lisibilité de l'eau sur les trajets à plusieurs entrées (certaines eaux sont sur la partie commune, d'autres sur une seule branche), forme et placement des bassins, décor. Les marges des chemins et des emplacements sont vérifiées par `test_drowned_chapter.gd` ; les ruines et roseaux dépendent de l'identifiant de la carte (le placement du décor est tiré de cet identifiant).
- [x] **Tronçons inondés, missions 51–60** — dix calques reliés aux cartes. Transitions de la 51, croisement et survol des routes de la 58 contrôlés dans les deux factions. L’aperçu de mission reste à traiter. [Contrôles et extension](design/Visuels_Troncons_Inondes.md#contrôle-en-combat-et-extension-sur-la-v0178)
- [ ] **Bassins des missions 46–50 (v0.163)** : Chaussée des Roseaux, Trois Gués Noyés, Îlots du Chœur, Nef Effondrée et Sanctuaire Englouti utilisent des bassins posés par Claude Code comme emplacements neutres (`water_areas` dans `map_definition.gd`). Revoir leur forme, leur nombre et leur placement, sans toucher aux routes ni aux emplacements de défense (`test_marsh_campaign.gd` vérifie ces marges). La Nef (mission 49) est très encombrée : le décor automatique n'y trouve place que pour quatre éléments.
- [ ] **Ruine compacte du Cloître Submergé (mission 45)** : en v0.162, une ruine remplace un saule quand les marges écartent toutes les ruines. Prévoir un visuel de ruine adapté à cette emprise réduite, inclus dans les limites d'un saule.
- [ ] **Animations des unités** : seul le loup a une marche approuvée (`design/Marche_loup_v0108.md`, `design/Orientation_loup_v0109.md`). Les autres unités et ennemis restent à animer.
- [ ] **Sanglier** : étude non intégrée et non approuvée (`design/essais/sanglier_peau_continue/README.md`, `design/essais/sanglier_virages/README.md`).

## Livré

- [x] **Boutique, types 10, 11, 16 et 17** — quatre propositions d’illustration vérifiées en boutique et en combat sur une copie d’essai. Validés par le porteur le 14 novembre 2026 et intégrés en v0.198 (portrait de boutique propre pour les types 10 et 16 ; flèche pour le 11, balle pour le 12, javeline pour le 17). [Aperçus](design/Visuels_Boutique_Guetteurs.md).

- [x] **Nécropole 191–200 et marche du Revenant** — cinq pièces par carte et trois planches de marche vérifiées en combat. [Aperçus](design/Visuels_Necropole.md#chapitre-20--missions-191-à-200).

- [x] **Nécropole et terres maudites, missions 181–190** — cinq pièces par carte, brume et strates. Vérifié en combat dans les deux factions. [Aperçus](design/Visuels_Necropole.md).

- [x] **Côtes et récifs 171–180 et Brume marine** — cinq pièces par carte, deux planches vérifiées en combat dans les deux factions. [Aperçus](design/Visuels_Cotes_Recifs.md#chapitre-18--missions-171-à-180).

- [x] **Côtes et récifs, missions 161–170** — cinq pièces par carte, falaises et écume. Prêt pour intégration et avis visuel. [Aperçus](design/Visuels_Cotes_Recifs.md).

- [x] **Îles flottantes 151–160 et vol de l’Aigle des cimes** — cinq pièces par carte, trois planches en combat. Portrait livré pour branchement. [Aperçu](design/Visuels_Iles_Flottantes.md#chapitre-16--missions-151-à-160).

- [x] **Îles flottantes et cité céleste, missions 141–150** — cinq pièces par carte, nuages et falaises. Prêt pour intégration et avis visuel. [Aperçus](design/Visuels_Iles_Flottantes.md).

- [x] **Souterrains et mines, missions 131–140 et éboulement** — cinq pièces par carte, avertissement et blocage animés. Contrôles en combat dans les deux factions. Prêt pour intégration et avis visuel. [Aperçus](design/Visuels_Biome_Mines.md#chapitre-14--missions-131-à-140).

- [x] **Marche de Gueule-de-Vase** — trois planches de 24 poses. Les Eaux Mortes vérifiées à ×1 et ×2 dans les deux factions. En attente de retour visuel. [Aperçu](design/Visuel_Gueule_de_Vase.md#marche-de-gueule-de-vase).

- [x] **Marche des deux boss** — 24 poses par planche, quatre diagonales vérifiées à ×1 et ×2. En attente de retour visuel. [Aperçus](design/Visuels_Marche_Boss.md).

- [x] **Marche du capitaine humain** — 24 poses par planche, trois diagonales de La Brèche vérifiées à ×1 et ×2. En attente de retour visuel. [Aperçu](design/Visuels_Garnison.md#marche-du-capitaine-humain).

- [x] **Garde noir, marche** — trois planches de 24 poses et quatre diagonales vérifiées à ×1 et ×2. Aperçu en attente de retour. [Fiche](design/Visuel_Garde_Noir.md).

- [x] **Garde royal, marche** — trois planches de 24 poses et quatre diagonales vérifiées à ×1 et ×2. Aperçu en attente de retour. [Fiche](design/Visuel_Garde_Royal.md).

- [x] **Souterrains et mines, missions 121–130** — palette, calque et cinq pièces par carte, vérifiés dans les deux factions. Intégré en v0.184. [Aperçus](design/Visuels_Biome_Mines.md).

- [x] **Colosse troll, marche** — trois planches de 24 poses et quatre diagonales vérifiées à ×1 et ×2. Aperçu en attente de retour. [Fiche](design/Visuel_Colosse_Troll.md).

- [x] **Brise-remparts nain, marche** — trois planches de 24 poses, quatre diagonales vérifiées à ×1 et ×2. En attente de retour visuel. [Aperçu](design/Visuel_Brise_Remparts.md).

- [x] **Éclaireur elfe, course** — trois planches de 20 poses testées en jeu sur les quatre diagonales à ×1 et ×2. Aperçu en attente de retour du porteur. [Fiche](design/Visuel_Eclaireur_Elfe.md).

- [x] **Éclaireur gobelin, course** — trois planches de 20 images dans les ressources de jeu. Test témoin corrigé, contrôle en jeu à ×1 et ×2. Intégré sur `main` (`332c7f1`). [Aperçu](design/Visuel_Eclaireur_Gobelin.md).

- [x] **Fantassin humain, marche** — trois planches de 20 images, quatre diagonales vérifiées à ×1 et ×2 sur Les Coulées Figées. À juger en jeu par le porteur. [Aperçu](design/Visuel_Fantassin_Marche.md).

- [x] **Lanceur de masse orc, attaque** — prise approuvée, retour du bras par le même côté après le lâcher, volumes d’origine, cinq inclinaisons et repères de lancer. [Captures et contrôles](design/Visuels_Boutique_Lanceur_Masse.md#armé-et-projection-de-la-masse). Avis visuel attendu.
- [x] **Lanceur double troll, attaque** — deux bras alternés, trois inclinaisons par bras et repères de lancer. [Capture et contrôles](design/Visuels_Boutique_Lanceur_Double.md#deux-bras-alternés). Retour favorable du porteur sur le lot `b779d4d`.
- [x] **Hache en chaîne, attaque** — lancer depuis la hanche, cinq inclinaisons, hache à deux lobes et ricochets. [Capture et contrôles](design/Visuels_Boutique_Hache_En_Chaine.md#lancer-de-la-hache-et-ricochets). Lot `f0b6867` validé par le porteur.
- [x] **Fronde elfe, attaque** — rotation, lâcher du galet, accompagnement de la poche vide et cinq inclinaisons. [Capture et contrôles](design/Visuels_Boutique_Fronde.md#rotation-et-lâcher-du-galet). Lot `a683912` validé par le porteur.
- [x] **Arbalète lourde, attaque** — recul à genou, six inclinaisons et repères de carreau. [Animation et contrôles](design/Visuels_Boutique_Arbalete_Lourde.md#tir-à-genou-et-recul). Lot `aa7462b` validé par le porteur.
- [x] **Archer double, attaque** — prise au carquois, cinq inclinaisons, repères de flèche et essai en jeu à ×1 et ×2. [Animation et contrôles](design/Visuels_Boutique_Archer_Double.md#prise-au-carquois-et-tir). Lot `226ec17` validé par le porteur.
- [x] **Veilleur des cendres, attaque** — lancer bas, garde et trois inclinaisons, hachette et repères de départ. Essai en jeu à ×1 et ×2. [Animation et contrôles](design/Visuels_Boutique_Guetteurs.md#lancer-du-veilleur-des-cendres). Lot `1779fe3` validé par le porteur.
- [x] **Mage de la foudre, attaque** — charge et décharge dans les deux sens, repères de main et contrôle des ramifications en jeu. Lot `e90fd72` validé par le porteur. [Animation et contrôles](design/Visuels_Boutique_Mage_Foudre.md#charge-et-éclair-en-chaîne).

- [x] **Brûleur de cendres, attaque** — poussée du brasero, repères de grille et départ de braise validés par le porteur. Lot `9eb30c2` à intégrer. [Animation et contrôles](design/Visuels_Boutique_Bruleur.md#poussée-du-brasero).

- [x] **Lance-épieu orc, attaque** — estoc en plusieurs inclinaisons et distances, avec repère de contact. Lot `a151adb` validé par le porteur, à intégrer. [Animation et contrôles](design/Visuels_Boutique_Lance_Epieu.md#estoc-à-deux-mains).

- [x] **Catapulte gobeline, attaque** — bras sur pivot, châssis reconstruit en volume dans les diagonales, garde vers la route et tir selon la cible. Lot `c71b7b3` validé par le porteur et prêt à intégrer. [Animation et contrôles](design/Visuels_Boutique_Catapulte.md#tir-avec-bras-sur-pivot).

- [x] **Grenadier gobelin, attaque** — retour favorable du porteur sur le lot `db3d428`, prêt à intégrer avec le sprite de grenade. [Animation et preuve](design/Visuels_Gestes_Combat.md#lancer-du-grenadier-gobelin).

- [x] **Sentinelle elfe, attaque** — geste et reprise des appuis et du buste approuvés. Lot `b9aecf9` à intégrer. Lâcher depuis la pointe de la flèche, avec trajet rectiligne vérifié en jeu. [Animation et contrôles](design/Visuels_Boutique_Guetteurs.md#tir-de-la-sentinelle-elfe).

- [x] **Lanceur de haches troll, seconde proposition** — transfert de poids, rotation des épaules et reprise de la hache près de la hanche. Vérifié en combat à ×1 et ×2, en attente de l’avis du porteur. [Comparatif](design/Visuel_Troll_Lancer.md#lancer-retravaillé)

- [x] **Lanceur de haches troll, attaque** — lâcher, main vide pendant le vol et retour en garde. Quatre tirs avec rebond vérifiés au Gué, dans les deux sens à ×1 et ×2. [Animation et contrôles](design/Visuel_Troll_Lancer.md)

- [x] **Mage humain, lancement du sort** — geste de la main et éclat du cristal, contrôlés au Gué dans les deux sens à ×1 et ×2. [Animation et captures](design/Visuel_Mage_Incantation.md)

- [x] **Arbalétrier nain, tir et réarmement** — 18 images à partir des poses existantes. Vrais tirs gauche et droite vérifiés à ×1 et ×2, trois cycles enchaînés avec le bonus de cadence. [Animation et contrôles](design/essais/arbaletrier_tir/README.md#tir-par-planche-sur-les-sources-de-la-v0178)

- [x] **Guerrier orc du pilote, appuis en diagonale** — variantes de montée et descente dans les ressources locales. Les quatre diagonales ont été parcourues à ×1 et ×2. Mesures des appuis, pause, validateur et régression vérifiés. Validation artistique du porteur à venir. [Contrôles et vidéo](design/Appuis_Guerrier_Orc.md)

- [x] **Biome volcanique, proposition d’habillage pour les missions 61–80** — quatre pièces, calque de cendres, palette et 120 placements contrôlés. Maquettes sur 61, 66, 71 et 80 dans les deux factions. Intégration et contrôle en combat à faire. [Fiche et visuels](design/Visuels_Biome_Volcanique.md)

- [x] **Tronçons inondés, proposition pour les missions 51–60** — dix calques transparents, repères et contrôles sur les missions 51, 55, 58 et 60 dans les deux factions. Les bassins décoratifs et l’aperçu restent à traiter. [Fiche et maquettes](design/Visuels_Troncons_Inondes.md)

- [x] **Gueule-de-Vase, ancien Noyé** — nom retenu par le porteur, sprite fixe de batracien et planche de remous proposée. Maquettes des Eaux Mortes dans les deux factions et vidéo ×1/×2. Silhouette et remous intégrés en v0.176. [Fiche et visuels](design/Visuel_Gueule_de_Vase.md)

- [x] **Citadelles, première proposition d’habillage par faction** — huit pièces transparentes, palettes et placements d’essai pour les missions 81 et 87. Quatre maquettes inspectées sur captures. L’intégration en jeu et le placement sur les autres cartes restent ouverts. [Fiche et visuels](design/Visuels_Citadelles.md)

- [x] **Garnison, propositions de silhouettes fixes** — capitaine humain avec hallebarde rectiligne et capitaine orc avec bouclier à bande rouge. PNG transparents, points d’appui et comparaison sur La Brèche pour les deux factions. Les silhouettes attendent un retour et un essai intégré. [Fiche et visuels](design/Visuels_Garnison.md)

- [x] **Éruptions, maquette de l’avertissement** — planche transparente de 24 images, comparaison des six emplacements du Cratère Fumant et vidéo ×1/×2. Prête pour avis artistique et branchement. L’intégration en jeu et la désactivation commune restent dans la tâche Éruptions. [Fiche et visuels](design/Avertissement_Eruptions.md)

- [x] **Pilote, archer elfe sur v0.174** — repos, tir et désactivation. `prototype/assets/animations/defender.alliance.archer/` (description et trois PNG). Livré pour essai, validation artistique en attente. [Contrôles et vidéos](design/Pilote_animations.md).
- [x] **Pilote, guerrier orc sur v0.174** — cycle de marche. `prototype/assets/animations/enemy.horde.warrior/` (description et PNG). Livré pour essai, validation artistique en attente. [Contrôles et vidéos](design/Pilote_animations.md).
