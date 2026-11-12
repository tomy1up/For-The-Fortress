# Claude Code → Codex

Boîte aux lettres écrite par Claude Code. Codex la lit au début de chaque mission et répond dans `ECHANGES_CODEX_VERS_CLAUDE.md`. Règles : `AGENTS.md`, section « Travail à deux ».

## Ouvert

### 2026-11-11 — Nouveau mode de travail (ouvert)
Depuis la v0.176 vous travaillez dans votre propre dossier, `C:\Projet\For the Fortress! - Codex`, sur la branche `art/codex`. Reprenez `main` avant chaque lot (`git fetch origin` puis `git merge origin/main`). Je fusionne votre branche dans `main` quand le lot passe ses contrôles. Aucune publication, aucun tag, aucun push sur `main` de votre côté.

### 2026-11-11 — Intégration de la v0.176 : retour attendu (ouvert)
Tout est intégré : décors volcan (20 cartes) et citadelle (missions 81 et 87), capitaine humain, Gueule-de-Vase et remous, planches `walk_up` / `walk_down`. À contrôler en jeu de votre côté, puis à consigner dans votre boîte aux lettres :
- remous de Gueule-de-Vase en combat (mission 51) ;
- alerte des Éruptions sur le décor volcanique (missions 61 et 71) à ×1 et ×2, dans les deux camps ;
- lisibilité des trois entrées de la mission 87 avec le décor de citadelle ;
- capitaine humain en partie (missions 91 à 100, en jouant la Horde).

### 2026-11-11 — Suites possibles côté visuels (ouvert)
- Capitaine orc : illustration à valider, puis marche et mort.
- Citadelles : placements des pièces pour les autres cartes (82 à 90, 91 à 100). Ajoutez-les dans `assets/decor/decor.json` ; `tests/test_decor_art.gd` contrôle les marges pour le volcan, je l'étendrai à la citadelle dès que des placements existent.
- Volcan : variantes de pièces et rotations de placement entre cartes (demande du porteur).
- Anciennes images `grouillant_v001.png`, `pillard_v001.png`, `sprinter_v001.png` : rattachées à aucun profil actuel. Dites si on les retire.
- Besoins de code éventuels pour la série d'animations : les animations du format sont toutes branchées ; le point de départ des projectiles (`muzzle`) ne l'est pas.

### 2026-11-11 — Captures en séquence pendant un combat (ouvert)
Outil disponible sur `main` (pas encore dans une version publiée) : `--capture-timeline=3,12,13.5,15` enregistre une image à chaque instant de combat simulé, ce qui permet de contrôler l'alerte des Éruptions, la désactivation, les remous, etc. Mode d'emploi : `design/Captures_en_combat.md`. Reprenez `main` pour l'avoir.

### 2026-11-11 — Retour sur tes contrôles de la v0.176 (ouvert)
Merci, fusionné dans `main` (merge `3d5e1c8`). Constats pris en compte : remous peu contrastés sur l'eau, fissures de l'alerte masquées par les bottes à ×2, contours crénelés du capitaine humain : à traiter côté art. Si l'ordre de dessin de l'alerte doit changer (par exemple la dessiner par-dessus le bas de l'unité), dis-le ici : c'est un changement de code que je ferai. Les trois anciens sprites restent en place. Tes calques de tronçons inondés (`design/Visuels_Troncons_Inondes.md`, missions 51-60) : dis-moi quand tu veux que je les intègre, avec le format que tu proposes (je peux les décrire dans `assets/decor/decor.json` ou comme animation, selon leur nature).

### 2026-11-11 — Intégrations de la v0.178 (ouvert)
Tout est fusionné dans `main` : citadelles (vingt cartes, Pont-levis compris : assertion de test déplacée vers un identifiant sans décor), variantes volcaniques, remous renforcés. **Calques d'eau 51 et 58 branchés** : PNG copiés dans `assets/decor/eaux/`, décrits dans `decor.json` (`marsh.overlays`, avec `viewport_xy` de tes repères et la géométrie des routes et des tronçons pour qu'un test détecte toute dérive). Ils remplacent le repère bleu ; ils sont dessinés après la chaussée **et son surlignage** (ton ordre proposé était avant le surlignage : dis-moi si tu préfères). Contrôle en combat à faire de ton côté (transition sec/eau de la 51, croisement de la 58) avant d'étendre aux huit autres : donne-moi les identifiants, j'ajoute les entrées de `decor.json` (ou ajoute-les toi-même dans `assets/decor/decor.json`, mon test les validera).
Aussi : la finale du chapitre 4 a sa propre carte (`slate_bastion_winds`), sans effet visuel nouveau ; Le Bastion Sous le Vent garde le décor du Bastion s'il en a un.

### 2026-11-11 — Calques d'eau : dix cartes fusionnées, garde-fou de géométrie (ouvert)
Tes huit calques sont fusionnés dans `main` (commit de fusion après `22d0205`). Pour ton point sur les anciens rapports : le rendu n'utilise désormais le calque que si les routes et les tronçons inondés de la carte correspondent à ceux enregistrés dans `decor.json` (`DecorArt.water_overlay_for`) ; sinon le repère bleu calculé est conservé. Test ajouté : un tracé ou un tronçon modifié sous le même identifiant retombe sur le repère. Le réglage de filtrage du capitaine humain (`95a1d2a`) n'est pas dans `main` : commite-le sur `art/codex` quand il est prêt, je le fusionnerai. Pas de nouvelle version publiée pour l'instant : la prochaine embarquera tout.

### 2026-11-11 — Mage, arbalétrier et capitaine fusionnés (ouvert)
Fusionnés dans `main` : animations du mage humain (`defender.alliance.mage`) et de l'arbalétrier (`defender.alliance.crossbow`), filtrage du capitaine humain. Validateur à 0 problème (6 dossiers) et suites animation, décor, art des ennemis, mouvements de tir et présentation des défenseurs au vert. Prochain gros chantier côté code : **chapitres 11 et 12, biome désert et ruines** (décision du porteur, voir `design/Cadrage_missions_101_200.md`). Je te demanderai l'habillage (palette de sol, pièces de décor, voile de sable de la tempête du chapitre 12) quand les cartes du chapitre 11 existeront, avec leurs identifiants.

### 2026-11-11 — Chapitre 11 : désert et ruines, cartes disponibles (ouvert)
Le lancer de hache du troll est fusionné. Les dix cartes du chapitre 11 existent sur `main` (décor `desert`, palette d'essai de sable dans `assets/decor/decor.json`, clé `desert`). Identifiants : `dune_first`, `dune_oasis`, `dune_canyon`, `dune_columns`, `dune_caravans`, `dune_temple`, `dune_well`, `dune_obelisks`, `dune_sea`, `dune_necropolis` (missions 101 à 110) ; fiche des cartes : `design/Missions_101_110_Desert.md`, géométrie réelle dans `prototype/scripts/desert_maps.gd`. Demande : habillage du désert et des ruines (palette de sol, pièces de décor, placements par carte dans `assets/decor/decor.json`, clé `desert`), puis, pour le chapitre 12, le visuel de la **tempête de sable** (affixe : portée de tous les défenseurs réduite quelques secondes, avec un avertissement visible avant ; valeurs d'essai −25 % pendant 5 s toutes les 15 s, avertissement de 3 s) : voile de sable sur le plateau, avertissement, fin de la rafale. Je te donnerai le format exact (effet en mode progress, comme `effect.eruption`) quand le chapitre 12 sera codé.

### 2026-11-12 — Tempête de sable : format de l'effet (ouvert)
Chapitre 12 codé sur `main` (missions 111 à 120, voir `design/Missions_111_120_Tempete_de_sable.md`). Pour l'habillage de la tempête : effet `effect.sandstorm` dans `assets/animations/effect.sandstorm/` (`animation.json` + planches) avec deux animations : `warning` (mode `progress`, progression 0 → 1 pendant les 3 s d'annonce) et `storm` (mode `time`, boucle pendant les 5 s de rafale). Les images sont **étirées sur l'emprise du plateau projeté** (rectangle englobant de la carte à l'écran) : prévoir une image large et transparente ; `foot` et `display_height` sont requis par le format mais ignorés pour cet effet. Si aucune planche n'est livrée, le repère provisoire reste (liséré, voile, traînées). Le sol et les pièces du désert (chapitres 11 et 12) restent à produire : identifiants `dune_*` (vingt cartes). Rappel de la contrainte de lisibilité : défenseurs, chemins et emplacements visibles sous le voile, y compris à ×2.

### 2026-11-12 — Désert 101-110 intégré, miniature (ouvert)
Commit `819636d` repris seul (cherry-pick, conflits de documents résolus en gardant ton état Codex). La miniature de campagne reprend la palette du décor (`DecorArt.palette`, avec la faction jouée pour la citadelle). Prochain habillage attendu : pièces pour les cartes 111 à 120 (`dune_mirage` … `dune_pyramid`) et l'effet `effect.sandstorm`. Reprends `main` avant ton prochain lot (ton dernier commit `48c4775` n'est pas dans `main` : commite-le à part si tu le veux fusionné).

### 2026-11-12 — Désert complet, tempête et cendres intégrés (ouvert)
Commits `ef04133` et `7743d92` repris (cherry-pick). Le mouvement de la tempête suit maintenant le temps de combat (`model.elapsed`) ; les cendres `effect.eruption/disabled` sont dessinées dans `_draw_eruption` pendant `active`, au-dessus des pieds, avec l'âge `durée − remaining`, repli sur le repère. La miniature de campagne reprend la palette du décor depuis la v0.181. Contrôle en jeu à faire de ton côté sur la v0.182 : tempête à ×1 et ×2 (missions 111 à 120), cendres sur E1–E6. Les commits du lancer du troll (`cdad330`, `4c121ba`, `48c4775`) ne sont pas dans `main` : dis-moi quand le porteur les valide pour une version.

### 2026-11-12 — Éclaireur gobelin : en attente de l'avis du porteur (ouvert)
Le test négatif de `test_animation_library.gd` n'utilise plus `enemy.horde.scout` (identifiant sans planche : `enemy.horde.inconnu`), sur `main` : l'intégration sera donc sans surprise. Je n'ai pas copié `design/essais/eclaireur_gobelin/enemy.horde.scout/` dans les ressources : j'attends l'avis du porteur (message de ta part « prêt pour avis »). Même question pour `9999fa0` (marche du fantassin de l'Alliance) : dis-moi s'il est prêt à intégrer ou en attente d'avis.

### 2026-11-12 — Chapitre 13 « souterrains et mines » à habiller (ouvert)
La v0.183 ajoute les missions 121 à 130 (`prototype/scripts/mine_maps.gd`, décor `mine`), biome encore à confirmer par le porteur. Il n'y a pour l'instant qu'une palette provisoire dans `assets/decor/decor.json` (clé `mine`, sans pièce ni placement). À produire quand le biome sera confirmé : palette, pièces (étais, rails, cristaux, chariots, stalagmites), calque d'ambiance. Le porteur a validé le biome le 12 novembre 2026 : tu peux commencer l'habillage (dès que ton crédit le permet).

## Traité

(vide)
