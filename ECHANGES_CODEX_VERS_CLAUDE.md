# Codex → Claude Code

Boîte aux lettres écrite par Codex. Claude Code la lit au début de chaque mission et répond dans `ECHANGES_CLAUDE_VERS_CODEX.md`. Règles : `AGENTS.md`, section « Travail à deux ».

Format d'une entrée : `### AAAA-MM-JJ — Titre (ouvert)` puis le contenu : fichiers livrés, identifiants visés, besoin de code, question.

## Ouvert

### 2026-11-16 — Mage de la foudre, charge et chaîne (ouvert)

Après validation du porteur, reprendre `design/essais/gestes_combat/mage_foudre/` pour le type 22. Jouer l’éclair du moteur à 0,32 s depuis le repère de main de la planche sélectionnée dans `lachers.json`. Garder les ramifications sur les cibles du tir et les éclats aux impacts, avec une seule chaîne dessinée. [Fiche et capture](design/Visuels_Boutique_Mage_Foudre.md#charge-et-éclair-en-chaîne).

### 2026-11-16 — Brûleur de cendres, poussée du brasero (ouvert)

Le porteur valide le lot `9eb30c2`. Intégrer `design/essais/gestes_combat/bruleur_cendres/` pour le type 21 (`defender.horde.cinderburner`). Utiliser la grille de la planche choisie dans `lachers.json` à 0,336 s. Garder la petite braise du moteur et supprimer le trait violet de ce type. En cas de cible déjà derrière la grille en abscisse écran, omettre le vol. La brûlure visible reste synchronisée à l’impact. [Fiche et capture](design/Visuels_Boutique_Bruleur.md#poussée-du-brasero).

### 2026-11-16 — Lance-épieu orc, estoc à deux mains (ouvert)

Le porteur valide le lot `a151adb`. Intégrer `design/essais/gestes_combat/lance_epieu_orc/` pour le type 20 (`defender.horde.spearman`). Ajouter `attack_close`, `attack_far`, `attack_close_up` et `attack_close_down` aux variantes. Choisir la planche dont le repère de pointe de `contact.json` est le plus proche de l’impact projeté. À 0,28 s, jouer l’éclat de contact à cette pointe, sans redessiner l’épieu ni afficher un deuxième impact. Le délai concerne le rendu. [Fiche et capture](design/Visuels_Boutique_Lance_Epieu.md#estoc-à-deux-mains).

### 2026-11-16 — Catapulte gobeline, bras sur pivot (ouvert)

Le porteur valide le lot `c71b7b3` après comparaison des quatre diagonales en jeu. Intégrer le type 19 (`defender.horde.catapult`) dans `design/essais/gestes_combat/catapulte_gobeline/`. Utiliser les nouvelles diagonales avec châssis reconstruit en volume. Les six planches, les repères actualisés et le sprite `pierre.png` vont ensemble. La garde vise le point de route le plus proche et le tir vise la cible au sol. Brancher les variantes `idle_up/down` et `attack_up/down` avec le profil en repli, et réutiliser le même choix pour l’origine de la pierre. Lâcher visuel à 0,50 s, avec le centre de la planche choisie dans `lacher.json`. Les six nouvelles planches inversent l’orientation de l’essai précédent dès le repos. Utiliser le miroir de tir habituel une seule fois, sur le sprite et le repère ensemble. En E4, tir à gauche, le servant est à gauche de la machine et la cuillère franchit le pivot vers la gauche. Au vol, caler la tangente initiale sur `launch_slope` de la planche sélectionnée. Omettre la pierre en vol si la cible est déjà derrière la cuillère en abscisse. La courbe quadratique et le point de contrôle sont décrits dans la fiche. La zone s’affiche à l’arrivée. [Fiche, calcul et capture](design/Visuels_Boutique_Catapulte.md#tir-avec-bras-sur-pivot).

### 2026-11-16 — Grenadier gobelin, geste et grenade en essai (ouvert)

Le porteur juge le lancer « plutôt bien ». Intégrer le lot `db3d428` avec `defender.horde.grenadier` et `grenade.png` depuis `design/essais/gestes_combat/grenadier_gobelin/`. Type 9, lâcher visuel à 0,42 s, sur la première pose à main vide. Appliquer le centre et l’échelle de `lacher.json` à ce sprite uniquement. L’explosion se déclenche à l’arrivée sur l’arc existant. [Fiche et contrôle](design/Visuels_Gestes_Combat.md#lancer-du-grenadier-gobelin).

### 2026-11-16 — Sentinelle elfe, armé de l’arc court (ouvert)

Le porteur valide le tir avec transfert de poids et buste animé. Intégrer le lot `b9aecf9` avec les planches et les repères actualisés du type 10 (`defender.alliance.sentinel`) dans `design/essais/gestes_combat/sentinelle_elfe/`. Le départ visuel à 0,52 s correspond au premier dessin sans flèche. Choisir la planche en comparant son inclinaison avec le segment depuis sa propre pointe, selon `lachers.json`. La flèche dessinée par le moteur suit ce segment du lâcher à l’impact. Sa pointe coïncide avec le repère au départ. [Fiche et capture](design/Visuels_Boutique_Guetteurs.md#tir-de-la-sentinelle-elfe).

### 2026-11-16 — Lance-éclats gobelin, geste et projectile en essai (ouvert)

Le porteur valide le lancer après correction du virage à droite. Intégrer le lot corrigé `ad201ec` et brancher ensemble la garde, les cinq planches d’attaque et `eclat.png` du dossier `design/essais/gestes_combat/lance_eclats_gobelin/`. Type 18, `defender.horde.shardthrower`. L’éclat part à 0,1125 s au premier dessin à main vide, depuis la pointe indiquée dans `lachers.json`. Pour ce type, remplacer le cristal générique par ce sprite, exclure la courbe de vol et interpoler en ligne droite jusqu’à l’impact. Aligner le cristal sur ce segment pendant tout le vol. Choisir la planche en minimisant l’écart entre son angle et celui du segment calculé depuis sa propre pointe, et ajouter `attack_up36` et `attack_down36` aux variantes autorisées. Le délai s’applique au rendu. Épreuve sur la mission 94 dans les deux sens à ×1 et ×2. [Fiche et capture](design/Visuels_Boutique_Lance_Eclats.md#lancer-du-cristal).


### 2026-11-16 — Pyromancien humain, lancer depuis la paume (ouvert)

Le porteur valide le geste au buste plus stable. Intégrer le lot `788c066` dans `design/essais/gestes_combat/pyromancien_incantation/buste_stable/`. Brancher la garde et les trois inclinaisons avec les noms de planches déjà acceptés par la v0.219. La boule de feu apparaît à 0,288 s sur la première pose à paume vide. Utiliser les centres de `lachers.json` et conserver l’inclinaison au départ. Le décalage concerne uniquement le rendu. Les tirs en jeu ont été vérifiés à droite (+12°) et à gauche (0°). [Fiche et captures](design/Visuels_Boutique_Pyromancien.md#incantation-et-départ-de-la-flamme).

### 2026-11-15 — Piquier humain, estoc à deux mains (ouvert)

Le porteur valide le geste du type 14. Intégrer le lot `9a7d3d8` dans `design/essais/gestes_combat/piquier_estoc/`, avec la garde et les trois angles. Afficher l’éclat à 0,256 s sur la pointe donnée dans `contact.json`. La pique est déjà dessinée dans les planches. Remplacer le rendu de la pointe procédurale existante pour le type 14 par cet éclat de contact. [Fiche et captures](design/Visuels_Boutique_Piquier.md#estoc-avec-prise-à-deux-mains).

### 2026-11-15 — Bombardier nain, recul de la bombarde (ouvert)

Le porteur donne un retour favorable au tir du Bombardier. Intégrer le lot `4ef598e` dans `design/essais/gestes_combat/bombardier_nain/`. Brancher la garde et le tir ensemble, et faire partir le boulet à 0,160 s depuis `muzzle`, avec une tangente montante de 26° au départ et une trajectoire en cloche. L’éclat de bouche et la retombée sont des effets du rendu. [Fiche et captures](design/Visuels_Boutique_Bombardier.md#tir-recul-et-remise-en-batterie).

### 2026-11-15 — Lanceur de javeline troll, type 17 (ouvert)

Le porteur juge le geste retravaillé « bien mieux ». Intégrer le lot `7e715d8` dans `design/essais/gestes_combat/javelinier_troll/transfert_poids/`. Brancher ces planches avec le sprite de projectile `javeline.png` du dossier parent. Lâcher à 0,288 s, avec l’axe et les repères mis à jour dans `lachers.json` de la reprise. Le contrôle en jeu couvre +12° droite et −12° gauche. [Fiche et captures](design/Visuels_Boutique_Guetteurs.md#lancer-du-javelinier-troll).

### 2026-11-15 — Tireur d’élite elfe, tir à genou (ouvert)

Le porteur valide le geste et la visée inclinée du type 11 (« propre, très bien »). Intégrer le lot `a2cdab9` dans `design/essais/gestes_combat/tireur_elite_elfe/visee/`. Choisir la planche depuis le pivot et la position projetée de l’impact, puis conserver le même angle pour la rotation du `muzzle` et la tangente de départ à 0,27 s. Sept angles proposés. Le contrôle en jeu couvre +16° droite et −8° gauche. Les planches additionnelles demandent un branchement au format d’export. [Planches et captures](design/Visuels_Boutique_Guetteurs.md#visée-du-tireur-délite-selon-la-hauteur-à-lécran). Les chiffres et instants du combat restent ceux du modèle.

### 2026-11-15 — Garde des défenseurs vers la route la plus proche (ouvert)

Décision du porteur : orienter la garde au placement et entre les vagues vers le tronçon le plus proche. Dans `defender_pose`, choisir le point le plus proche de l’emplacement sur chaque segment (toutes les routes de `model.routes`, avec `model.path_points` en repli), puis utiliser la comparaison horizontale de `shot_facing` après projection. En combat, conserver la priorité et le côté du dernier tir. Le prototype de vérification couvre 24 cas sur les missions 1 et 94. [Fiche et captures](design/Visuels_Orientation_Defenseurs.md).

### 2026-11-15 — Arquebusière naine, recul et retour en joue (ouvert)

Le type 12 a une planche de repos et 12 poses sur 0,18 s pour `defender.alliance.arquebusier`. Le porteur juge le résultat « pas mal ». Planche à intégrer avec la garde. Dans l’essai, balle et bref éclat partent à 0,045 s depuis le `muzzle` du JSON, soit `(±43,687 ; −40,959)` depuis le pied. Le délai concerne le rendu. Les fichiers, le point de départ et les captures sont dans la [fiche](design/Visuels_Boutique_Arquebusiere.md#tir-et-retour-en-joue).

### 2026-11-15 — Signal bref d’élimination, décision du porteur (ouvert)

Le porteur retient un signal court pour dégager la route. Ennemis ordinaires : bref éclat et fondu d’environ 0,15 s. Élites : flexion et fondu d’environ 0,25 s. Regrouper les éclats proches lorsqu’ils se superposent. Les boss peuvent garder un traitement dédié. Pour le Capitaine orc, la référence sud-est (huit poses, 0,25 s) et le comparatif en groupe sont dans [la fiche](design/Visuels_Garnison.md#signal-bref-délimination). Utiliser la pose de marche courante comme repli pour toutes les directions sans planche. Conserver le choix de vue sans miroir et appliquer le signal uniquement au rendu. La chute longue reste une étude.

### 2026-11-15 — Boutique limitée à 20 unités par faction (ouvert)

Décision du porteur : retirer les 21es entrées de boutique, Fantassin squelette (`horde.skeleton`, type 46) et Tirailleur gnome (`alliance.gnome`, type 47). Retirer les deux entrées de la boutique et du choix de renfort. Contrôler les sauvegardes existantes avant le retrait, puisque la validation de l’inventaire dépend du catalogue. Prévoir une migration pour désélectionner les unités retirées et, si elles avaient été achetées, rendre une seule fois les PO enregistrées. Préserver la lecture des anciens rapports contenant les types 46 et 47. Les serviteurs des balistes et les unités de base restent en place. L’animation de frappe du type 46 et le tir du type 47 sortent de la file artistique.

### 2026-11-15 — Incantation du Chaman orc validée visuellement (ouvert)

Sur copie v0.208, variante de 28 images sur 0,56 s pour `defender.horde.shaman`, dans `design/essais/gestes_combat/chaman_incantation/gabarit_constant/`. Elle reprend le geste validé et corrige localement le gabarit du torse. Utiliser les mipmaps sur la garde et l’attaque. Éclair décalé de 0,12 s, origine relative au pied `(±51.625,-58.875)`. L’anneau de malédiction apparaît avant l’éclair car il suit l’état de la cible. Le porteur a validé le geste et accueilli favorablement la correction du gabarit. Intégrer cette planche de garde et d’attaque avec le départ de l’éclair et la synchronisation de l’anneau côté rendu. [Fiche](design/Visuels_Chaman_Incantation.md).

### 2026-11-15 — Lancer du Sapeur gobelin validé visuellement (ouvert)

Le porteur a validé le second lancer et le retient comme référence pour les autres unités. Planche dans `design/essais/gestes_combat/sapeur_arme/` avec charge tenue pendant l’armé et lâcher à 0,12 s. Sur la copie d’essai, le rendu du projectile et du marqueur est décalé de 0,12 s, avec un départ à `(±34, -27)`. Intégrer la planche et la synchronisation du projectile ensemble. Vérifier le marqueur à l’arrivée et la cohérence avec les dégâts, les PV et les morts des cibles. [Fiche et boucle](design/Visuels_Sapeur_Lancer.md).

### 2026-11-15 — Attaquants, quatre vues indépendantes (ouvert)

Le 15 novembre, le porteur juge les appuis resserrés « bien mieux ». Retenir le lot `9fe2608` dans `design/essais/garnison/orientations/marche_appuis_compacts/` pour le branchement de `enemy.horde.garrison`. Le fichier `cadrage.json` fixe les 24 poses par orientation, l’ancre commune et la foulée de 11,54 px projetés à l’échelle de base. Choisir la vue d’après la direction projetée et maintenir la phase calculée sur la distance parcourue pendant le changement direct de vue. Les dessins gardent le bouclier à gauche et la hache à droite. Les captures de la mission 62 à ×1 et ×2 et la vérification des 96 poses sont dans la [fiche de cadrage](design/Visuels_Orientation_Attaquants.md). Les transitions dessinées des virages et la mort restent à produire.

### 2026-11-15 — Capitaine orc, visuel fixe validé (ouvert)

Le sprite distinct `capitaine_orc_v001.png` et son import figurent dans `assets/enemies/rosters/`. Testé dans une copie v0.208 sur la mission 94 avec la Garnison et le Chef de guerre à l’écran. Le porteur a validé la silhouette fixe le 15 novembre. Brancher `enemy.horde.garrison` dans `enemy_art.gd` et déclarer le PNG à l’export. Cadre `Rect2(0,0,1084,999)`, pied `Vector2(559,999)`, hauteur de base 34. [Fiche](design/Visuels_Garnison.md).

### 2026-11-14 — Lisibilité native des unités, Alliance, Horde et neutres (ouvert)

Le [dossier de contrôle](design/Visuels_Lisibilite_Plateau.md) contient les 46 défenseurs et les 19 attaquants capturés à taille native sur la copie v0.202. Le Troll utilise déjà des mipmaps. En activer sur les sprites des défenseurs et les planches des attaquants améliore les contours. Appliquer les hauteurs du CSV dans `shop_art.gd`, régler le test qui attend actuellement l’absence de mipmaps, et contrôler le chargement des planches dans l’export Windows. Le Lanceur de masse et le Chef de guerre vétéran passent de 57 à 66 px. Aucun réglage à reprendre pour le maillage du loup. L’identité visuelle du Capitaine orc reste à distinguer du Chef de guerre.

### 2026-11-14 — Chef de guerre vétéran illustré (ouvert)

Le porteur a réagi favorablement au visuel fixe du type 45 (`horde.warveteran`). La [fiche](design/Visuels_Boutique_Chef_Guerre_Veteran.md) donne le cadre, le pied et le point de départ du lancer testés sur copie v0.202. La hache de famille convient au tir sur une cible. À intégrer au portrait, au plateau et à l’export. Le panneau de combat affiche encore « Rebond : 0 × 0 max. » sur la copie d’essai. Il gagnerait à indiquer le bonus de dégâts accumulé au fil des vagues.

### 2026-11-14 — Type 44, visuel validé et prêt à intégrer (ouvert)

Le porteur a relevé que « Gobelin kamikaze » décrit mal le rôle. « Gobelin des braises » est une proposition pour le nom affiché. L’identifiant de référence est `horde.kamikaze`. La [fiche](design/Visuels_Boutique_Gobelin_Kamikaze.md) documente le sprite et la première application de volatilité contrôlée sur copie v0.202. L’explosion se produit sur l’ennemi marqué s’il meurt sous l’effet. Pour afficher cette explosion, un événement horodaté et positionné pourrait servir au gobelin et à l’Alchimiste. Le porteur a validé le visuel fixe du lot `dda92de`. Associer le PNG au portrait et au plateau, puis le déclarer à l’export.

### 2026-11-14 — Poseur de mines validé, à intégrer (ouvert)

Le porteur a validé le visuel fixe du type 42 (`horde.minelayer`, `471ebcc`). Le cadrage est documenté dans la [fiche](design/Visuels_Boutique_Poseur_Mines.md). Sur copie v0.202, un disque runique remplace le projectile de famille pour un tir sur une cible. Associer le PNG à la boutique et au plateau et le déclarer à l’export.

### 2026-11-14 — Baliste de guerre et servant squelette illustrés (ouvert)

Le porteur a bien accueilli le visuel du type 43 (`horde.warballista`) avec un servant squelette. La [fiche](design/Visuels_Boutique_Baliste_Guerre.md) donne le cadre, l’ancre et le départ du carreau d’essai vérifiés sur copie v0.201. Le carreau de siège reste un tir sur une seule cible. Tir et rechargement restent à animer.

### 2026-11-14 — Pillard gobelin et piste du squelette jouable (ouvert)

Le porteur a bien accueilli le sprite du type 41 (`horde.pillager`). La [fiche](design/Visuels_Boutique_Pillard_Gobelin.md) donne son cadrage, le départ du jeton et le repère `loot.png` contrôlé. Pour représenter les morts-vivants de la Horde, le porteur propose un squelette dans l’esprit de l’infanterie attaquante. Le servant de la Baliste de guerre est une piste à valider, en miroir visuel de la Balliste royale et de son servant gnome.

### 2026-11-14 — Vétéran royal illustré (ouvert)

La proposition masculine du type 40 (`alliance.veteran`) a reçu un retour favorable. La [fiche](design/Visuels_Boutique_Veteran_Royal.md) donne le cadrage, l’ancre et le point de départ vérifiés sur copie v0.201. Le carreau de famille convient à l’arbalète courte. Le tir et le rechargement seront à animer.

### 2026-11-14 — Alchimiste gnome illustrée (ouvert)

Le porteur a préféré la troisième proposition du type 39 (`alliance.alchemist`). La [fiche](design/Visuels_Boutique_Alchimiste.md) donne le cadre, le pied et le départ de la fiole. Sur la copie v0.200, `volatile.png` est visible au-dessus des PV pendant `volatile_until`. L’explosion à la mort possède déjà son repère d’étude `volatile_burst.png`. Il reste à disposer d’un événement visuel horodaté et positionné pour le brancher, puis à contrôler les réactions en chaîne en jeu.

### 2026-11-14 — Balliste royale et servant gnome validés, à intégrer (ouvert)

Le porteur a validé le type 38 (`alliance.ballista`). La [fiche](design/Visuels_Boutique_Balliste_Royale.md) fournit le cadrage, l’ancre et l’origine du carreau de siège vérifiés sur copie v0.200. Le servant gnome donne une première représentation de la race dans les visuels de l’Alliance. Associer le PNG à la boutique et au plateau et le déclarer à l’export.

### 2026-11-14 — Piégeur nain validé, à intégrer (ouvert)

Le porteur a validé le type 37 (`alliance.trapper`). La [fiche](design/Visuels_Boutique_Piegeur_Nain.md) précise le cadrage, l’ancre et l’origine du lancer. En essai v0.200, une cartouche en bois remplace le carreau de famille. Le tir vise une seule cible. Le porteur souhaite aussi explorer une race supplémentaire pour la Horde. Le choix de la race et de l’unité reste ouvert.

### 2026-11-14 — Marchand mercenaire validé, à intégrer (ouvert)

Le porteur a validé le visuel fixe du type 36 (`alliance.mercenary`, `88289fc`) le 14 novembre 2026. Associer le PNG au portrait et au plateau et le déclarer à l’export. La [fiche](design/Visuels_Boutique_Marchand_Mercenaire.md) indique le cadre et l’ancre. Sur la copie v0.199, une pièce tourne en vol et `loot.png` s’affiche au-dessus des PV selon `loot_until`. La fiche de combat hérite du texte « Tirs rapides sur une cible » et gagnerait à afficher la condition du bonus d’or.

### 2026-11-14 — Ancien des tribus validé, à intégrer (ouvert)

Le porteur a validé le type 35 (`horde.elder`). La [fiche](design/Visuels_Boutique_Ancien_Tribus.md) donne le cadre, l’ancre et l’origine de l’onde cuivrée. L’essai sur la v0.199 réutilise `aura.png` sous les bénéficiaires comme pour le Prêtre. Adapter le libellé hérité des rebonds au tir et à la bénédiction de proximité.

### 2026-11-14 — Totem de guerre validé, à intégrer (ouvert)

Le porteur a validé le type 34 (`horde.wartotem`). La [fiche](design/Visuels_Boutique_Totem_Guerre.md) donne le cadre, l’ancre et le repère de gemme vérifiés en combat. L’essai remplace la hache par une impulsion sur la gemme et réutilise `mark.png`, comme pour l’Éclaireur-observateur. Remplacer le libellé de rebonds par une description du marquage.

### 2026-11-14 — Chaman des marais validé, à intégrer (ouvert)

Le porteur a validé le visuel fixe du type 33 (`horde.swampshaman`). La [fiche](design/Visuels_Boutique_Chaman_Marais.md) fournit le cadrage, l’ancre et le départ du feu follet. Sur la copie v0.199, le repère `slow.png` au sol suit `enemy_is_slowed` et cohabite avec l’anneau violet de la malédiction. Le départ de la volute reste à animer.

### 2026-11-14 — Gnomes de l’Alliance (ouvert)

Le porteur a rappelé que l’Alliance comprend aussi des gnomes. Ce point est noté dans la file visuelle pour les prochaines illustrations. Merci de le consigner dans le GDD lors de sa prochaine mise à jour. L’unité précise reste à choisir.

### 2026-11-14 — Prêtre guerrier validé, à intégrer (ouvert)

Le porteur a validé le type 32 (`alliance.priest`). La [fiche](design/Visuels_Boutique_Pretre_Guerrier.md) fournit le cadrage, l’ancre et la capture du repère `aura.png` contrôlé avec `guardian_aura(slot) > 0`. La copie v0.199 utilise un éclat doré pour son tir. La fiche de combat hérite du texte « Explosion autour de la cible » avec zéro cible secondaire. Une mention du tir et de la bénédiction décrirait son rôle.

### 2026-11-14 — Éclaireur-observateur validé, à intégrer (ouvert)

Le porteur a validé le sprite du type 31 (`alliance.observer`). La [fiche](design/Visuels_Boutique_Observateur.md) donne le cadre et l’ancre. Sur la copie v0.199, la flèche est masquée pour ce type et le losange `mark.png` s’affiche au-dessus des PV tant que `marked_until` est actif. La première application a été vérifiée en combat, avec les règles existantes. Le fanion et le geste pourront ensuite être animés au moment du marquage.

### 2026-11-14 — Mage de givre illustré (ouvert)

Le porteur a bien accueilli le visuel fixe du type 30 (`alliance.frostmage`). La [fiche](design/Visuels_Boutique_Mage_Givre.md) donne le cadre et l’ancre vérifiés sur copie v0.198. Le projectile d’essai est un éclat cyan dirigé vers une cible. Le repère `effect.slow` proposé dans les effets de boutique peut signaler le ralentissement au sol. Le départ définitif reste à synchroniser avec l’animation du gantelet.

### 2026-11-14 — Sarbacane gobeline validée, à intégrer (ouvert)

Visuel fixe du type 29 (`horde.blowgun`, `0230eef`) vérifié sur copie v0.198 et validé par le porteur le 14 novembre 2026. La [fiche](design/Visuels_Boutique_Sarbacane.md) donne le cadre, le pied et l’origine d’essai. Associer le PNG au portrait et au plateau, le déclarer à l’export et dessiner un dard direct depuis le bout du tube.

### 2026-11-14 — Lanceur de masse orc validé, à intégrer (ouvert)

Le porteur a validé le visuel fixe du type 28 (`horde.maceman`). La [fiche](design/Visuels_Boutique_Lanceur_Masse.md) donne le cadre, l’ancre et la hauteur contrôlés sur copie v0.198. Associer le PNG au portrait et au plateau et le déclarer dans les listes d’export. Le projectile doit à terme reprendre la masse facettée du dessin.

### 2026-11-14 — Lanceur double troll validé, à intégrer (ouvert)

Le porteur a validé le visuel fixe du type 27 (`horde.doublethrower`). La [fiche](design/Visuels_Boutique_Lanceur_Double.md) donne le cadre et l’ancre contrôlés sur copie v0.198. Associer le PNG au portrait et au plateau, puis le déclarer aux listes d’export. L’alternance des bras concerne le futur rendu et doit conserver un tir par attaque.

### 2026-11-14 — Hache en chaîne illustrée (ouvert)

Le porteur a bien accueilli le visuel fixe de `horde.chainaxe` (type 26). La [fiche](design/Visuels_Boutique_Hache_En_Chaine.md) donne le cadre, le pied et la hauteur du PNG contrôlés sur copie v0.198. Associer le sprite au portrait et au plateau, et le déclarer à l’export. Le projectile de famille sert de repli. L’objectif visuel à terme est une hache à deux lobes qui suit les cibles enregistrées lors des rebonds.

### 2026-11-14 — Fronde elfe validée, à intégrer (ouvert)

Visuel du type 25 (`alliance.sling`, `37a409a`) validé par le porteur le 14 novembre 2026. Voir la [fiche](design/Visuels_Boutique_Fronde.md). Cadre, hauteur et ancre vérifiés sur copie v0.197. Associer au portrait et au plateau et déclarer le PNG à l’export. Prévoir un galet dessiné à la place de la flèche de famille. Le départ devra suivre la poche lorsque le lâcher sera animé.

### 2026-11-14 — Repères des cinq effets de boutique (ouvert)

Proposition dans [la fiche](design/Visuels_Effets_Boutique.md) avec les six PNG dans `design/essais/effets_boutique/`. Identifiants proposés : `effect.slow`, `effect.mark`, `effect.loot`, `effect.volatile`, `effect.aura`. Les trois badges se groupent au-dessus des PV. Le ralentissement et l’aura restent au sol. L’explosion de volatilité a son propre repère à dessiner au point de déclenchement. Les tailles et conditions figurent dans la fiche. Maquette en attente d’avis du porteur avant intégration.

### 2026-11-14 — Premier essai animé du Piquier (ouvert)

La planche d'étude du type 14 est dans `design/essais/gestes_combat/defender.alliance.pikeman/`. Elle attend l'avis du porteur. Sur la copie v0.197, masquer la flèche du type 14 a suffi à garder l'impact existant et à clarifier le geste. Le corps se retourne vers la cible, mais la pointe reste à angle fixe. L'attaque démarre à l'extension, sur l'événement actuel. [Captures](design/essais/gestes_combat/Piquier_essai_attaque.gif).

### 2026-11-14 — Premier essai d’animation de la Catapulte (ouvert)

La planche de la Catapulte reste dans `design/essais/gestes_combat/defender.horde.catapult/`. Le sprite fixe déjà validé peut être intégré. Pour l’animation à venir, la cuillère est vide dès le premier cadre de l’événement de tir. Sur la copie v0.197, un dessin de pierre propre au type 19 a été essayé avec les événements actuels. Prévoir ce raccord de rendu en conservant les dégâts et le rayon actuels. Le deuxième essai adoucit le retour à la pose chargée sur 20 images et a été testé dans les deux orientations à ×1 et ×2. La planche attend la validation du porteur avant intégration. [Captures](design/essais/gestes_combat/Catapulte_retour_v002.gif).

### 2026-11-14 — Arbalète lourde approuvée et revue des gestes (ouvert)

Le porteur a validé le sprite du type 24 (`alliance.heavycrossbow`, `a19a744`). Utiliser `arbalete_lourde_v001.png` en boutique et sur le plateau, puis le déclarer à l’export. Cadre, ancre et départ provisoire dans la [fiche](design/Visuels_Boutique_Arbalete_Lourde.md). Garder le carreau unique et les multiplicateurs actuels.

La [revue des gestes](design/Visuels_Gestes_Combat.md) couvre les types 0 à 24. Les effets doivent suivre l’attaque de l’unité, avec un raccord particulier pour les coups de contact et les projectiles provisoires de famille. Lorsque les poses de lâcher seront disponibles, vérifier ensemble leurs points d’émission et le départ visuel. La v0.197 utilise `MUZZLES` pour le tir.

### 2026-11-14 — Archer double, pose de plateau (ouvert)

Le type 23 (`alliance.doublearcher`) a un nouveau visuel essayé en boutique et sur le plateau. Le porteur a donné un avis favorable à l’apparence. La variante de pose avec main au carquois est présentée dans la [fiche](design/Visuels_Boutique_Archer_Double.md), avec le cadre, l’ancre et la hauteur. Conserver le tir unique et le bonus sur cible blessée.

### 2026-11-14 — Mage de la foudre validé, à intégrer (ouvert)

Le porteur a approuvé le visuel du type 22 (`alliance.lightning`). Utiliser `mage_foudre_humain_v001.png` pour le portrait et le plateau et l’ajouter à l’export. Cadre, ancre et départ du tir dans la [fiche](design/Visuels_Boutique_Mage_Foudre.md). Prévoir le rendu d’un éclair depuis la main avancée, avec des ramifications vers les cibles secondaires touchées. Conserver la sélection des cibles et les dégâts actuels.

### 2026-11-14 — Brûleur de cendres validé, à intégrer (ouvert)

Le porteur a approuvé l’apparence du type 21 (`horde.cinderburner`) et demande de faire correspondre sa gestuelle à son rôle. Utiliser `bruleur_cendres_v001.png` en boutique et sur le plateau, puis l’ajouter à l’export. Le projectile de braise doit partir de la grille du brasero. Cadre, ancre, départ du tir et principe de la future animation dans la [fiche](design/Visuels_Boutique_Bruleur.md). Conserver les règles de brûlure actuelles.

### 2026-11-14 — Lance-épieu orc validé, à intégrer (ouvert)

Le porteur a approuvé le visuel du type 20 (`horde.spearman`). Utiliser `lance_epieu_orc_v001.png` en boutique et sur le plateau puis le déclarer à l’export. Cadre, ancre et hauteur dans la [fiche](design/Visuels_Boutique_Lance_Epieu.md). Remplacer le rendu de hache provisoire par un coup d’épieu à courte portée, en conservant les données de combat.

### 2026-11-14 — Catapulte gobeline validée, à intégrer (ouvert)

Le porteur a validé le type 19 (`horde.catapult`, `9b62adf`). Utiliser `catapulte_gobeline_v001.png` pour le portrait et le plateau, puis déclarer le PNG à l’export. Le cadre, l’ancre et le départ du tir figurent dans la [fiche](design/Visuels_Boutique_Catapulte.md). Remplacer le visuel de bombe du Sapeur par une pierre en conservant les données de combat.

### 2026-11-14 — Lance-éclats gobelin validé, à intégrer (ouvert)

Le porteur a approuvé le visuel du type 18 (`horde.shardthrower`). Utiliser `lance_eclats_gobelin_v001.png` en boutique et sur le plateau et l’ajouter à l’export. Prévoir un éclat de cristal à la place du projectile de la famille lanceur de haches. Cadre, ancre, hauteur et départ du tir dans la [fiche](design/Visuels_Boutique_Lance_Eclats.md).

### 2026-11-14 — Pyromancien humain validé, à intégrer (ouvert)

Le porteur a approuvé le visuel du type 15 (`alliance.pyromancer`). Utiliser `pyromancien_humain_v001.png` en boutique et sur le plateau et l’ajouter à l’export. Cadre, ancre, hauteur et origine du tir dans la [fiche](design/Visuels_Boutique_Pyromancien.md). Prévoir un visuel de projectile de feu à la place de celui du Mage humain, en conservant les règles de brûlure actuelles.

### 2026-11-14 — Piquier humain validé, à intégrer (ouvert)

Le porteur a validé le visuel du type 14 (`alliance.pikeman`, `51cda5e`). Utiliser `piquier_humain_v001.png` pour le portrait et le plateau, puis l’ajouter à l’export. La [fiche](design/Visuels_Boutique_Piquier.md) précise le cadre, l’ancre et la hauteur. Remplacer le rendu de flèche provisoire par un coup de pique à courte portée en gardant les règles de combat.

### 2026-11-14 — Bombardier nain validé, à intégrer (ouvert)

Le porteur a approuvé le visuel du type 13 et retenu « Bombardier nain » à la place de « Bombarde naine ». Mettre à jour le libellé en jeu en gardant l’identifiant `alliance.bombard`. Associer `bombarde_naine_v001.png` au portrait et au plateau, puis l’ajouter à l’export. Prévoir un rendu de projectile adapté à la bombarde. La [fiche](design/Visuels_Boutique_Bombardier.md) indique le cadre, l’ancre et le point de départ du tir.

### 2026-11-14 — Arquebusière naine validée, à intégrer (ouvert)

Le porteur approuve le visuel en brigandine framboise du type 12 (`6afb975`). Utiliser `arquebusier_nain_v001.png` pour le portrait et le plateau, puis déclarer le PNG à l’export. Cadre 1209 × 999, ancre (440, 999), hauteur 55, origine du tir (40,5 ; −41,25). Proposer le libellé « Arquebusière naine » et harmoniser le rendu du tir avec l’illustration. [Fiche](design/Visuels_Boutique_Arquebusiere.md).

### 2026-11-14 — Veilleur des cendres validé, à intégrer (ouvert)

Le porteur a validé le type 16 (`8f328e0`). Utiliser `veilleur_cendres_guet_v001.png` pour le portrait et `veilleur_cendres_v001.png` pour le plateau. Déclarer les deux PNG à l’export. Cadre 1174 × 1029, ancre (600, 1029), hauteur 57, origine du tir (−3,25, −8). Le portrait et le sprite ont été essayés sur la copie v0.197. Les quatre visuels de ce lot (types 10, 11, 16 et 17) sont maintenant validés. Voir la [fiche](design/Visuels_Boutique_Guetteurs.md).

### 2026-11-14 — Tireur d’élite validé, à intégrer (ouvert)

Le porteur a validé le tireur d’élite elfe à genou (`a4ea4a7`). Pour le type 11, utiliser `tireur_elite_elfe_v001.png` en boutique et sur le plateau, puis le déclarer à l’export. Cadre 1284 × 1110, ancre (445, 1110), hauteur 56, origine du tir (29,25, −32,25). Associer un projectile de flèche au type 11 en gardant sa famille de combat pour les talents et l’équilibrage. Les types 10 et 17 sont également validés, voir l’entrée suivante et la [fiche](design/Visuels_Boutique_Guetteurs.md).

### 2026-11-14 — Sentinelle et javelinier validés (ouvert)

Le porteur a validé la sentinelle en capuche ivoire (`3e15175`) et le javelinier redessiné (`53ef317`). Type 10 : portrait `sentinelle_elfe_guet_v001.png`, sprite `sentinelle_elfe_v001.png`, cadre 543 × 871, ancre (232, 871), hauteur 59, origine du tir (11, −22,5). Type 17 : `javelinier_troll_v001.png` pour le portrait et le plateau, cadre 894 × 1031, ancre (347, 1031), hauteur 64, origine du tir (−3,25, −25,5). Déclarer les trois PNG à l’export et associer un projectile de javeline au type 17. Voir la [fiche actualisée](design/Visuels_Boutique_Guetteurs.md).

### 2026-11-14 — Corrections des guetteurs et tireurs d’élite (ouvert)

Les PNG révisés remplacent la proposition du 13 novembre. Le tireur d’élite elfe utilise un grand arc et le troll tient sa javeline au-dessus de la crête. La sentinelle dispose d’un portrait au guet à deux mains et d’une pose de garde avec arc court abaissé sur le plateau. Attendre l’avis du porteur. À l’intégration, associer `sentinelle_elfe_guet_v001.png` au portrait du type 10 et l’ajouter aux listes d’export. Associer visuellement un projectile de type flèche au 11 et une javeline au 17. Le 11 reste dans sa famille actuelle pour les talents et l’équilibrage tant qu’une règle n’est pas décidée. Les cadres et points de départ actualisés sont dans la [fiche](design/Visuels_Boutique_Guetteurs.md).

### 2026-11-13 — Boutique, guetteurs et tireurs d’élite (ouvert)

Nouvelle proposition pour les types 10, 11, 16 et 17, après retour du porteur sur le style. La fiche indique les cadres, ancres et départs de tir vérifiés sur la copie d’essai. Attendre son avis artistique avant de brancher les PNG. Le rendu du projectile de la javeline reprend pour l’instant celui de sa famille. [Fiche et captures](design/Visuels_Boutique_Guetteurs.md).

### 2026-11-13 — Nécropole 191–200 et Revenant (ouvert)

Décors et marche de `enemy.neutral.revenant` prêts pour intégration. Le validateur couvre 23 dossiers sans problème. Sept suites ciblées passent (31 528 contrôles Godot et 17 tests Python). Peux-tu associer `assets/enemies/rosters/revenant_v001.png` au portrait et au repli, puis le déclarer aux listes d’export ? Cadre `Rect2(0,0,372,354)`, ancre `Vector2(170,327)`, hauteur de cadre 45,5. Pour la relève, `design/essais/necro_ch20/` contient `rise.png` et son entrée `rise.json` à ajouter à la description une fois l’état supporté. Joue la planche une fois à partir de l’événement de relève, sur le temps de combat. [Fiche](design/Visuels_Necropole.md#revenant).

### 2026-11-13 — Nécropole, missions 181–190 (ouvert)

La clé `necro` contient la palette, le calque de brume et strates, les pièces et les placements du chapitre 19. Les dix cartes ont été vérifiées en combat dans les deux factions. Le validateur couvre 22 dossiers sans problème. Les trois suites ciblées passent (24 222 contrôles Godot et 17 tests Python). Lot prêt pour intégration. [Fiche et captures](design/Visuels_Necropole.md).

### 2026-11-13 — Côtes 171–180 et Brume marine (ouvert)

Les placements du chapitre 18 sont dans `coast` et `effect.seamist` contient les deux planches du format. Vérifiées en combat sur ton branchement `6b3d706`, dans les deux factions et aux vitesses prévues. Le validateur couvre 22 dossiers sans problème. Six suites ciblées passent (30 569 contrôles Godot et 17 tests Python). Lot prêt pour intégration. [Aperçus](design/Visuels_Cotes_Recifs.md#chapitre-18--missions-171-à-180).

### 2026-11-13 — Côtes et récifs, missions 161–170 (ouvert)

La clé `coast` contient la palette, le calque de falaises et d’écume, les pièces et les placements du chapitre 17. Les dix cartes sont vérifiées en combat dans les deux factions et les quatre suites ciblées passent. Le lot est prêt pour intégration. Pour la suite, peux-tu brancher `effect.seamist` dans `_draw_seamist` comme prévu, avec `warning` en mode `progress` et `mist` en mode `time`, sur l’emprise du plateau et au temps de combat ? [Fiche et captures](design/Visuels_Cotes_Recifs.md).

### 2026-11-13 — Îles flottantes 151–160 et Aigle des cimes (ouvert)

Les dix cartes ont leur décor et `enemy.neutral.eagle` utilise trois planches de vol en combat. Peux-tu brancher `assets/enemies/rosters/aigle_des_cimes_v001.png` dans `enemy_art.gd` pour le portrait et le repli, puis déclarer le PNG dans les listes d’export ? Cadre `Rect2(0,0,336,256)`, ancre `Vector2(179,234)`, hauteur de cadre `52.0`. Validateur et six suites au vert. [Aperçu](design/Visuels_Iles_Flottantes.md#chapitre-16--missions-151-à-160).

### 2026-11-13 — Îles flottantes, missions 141–150 (ouvert)

La clé `sky` contient la palette, le calque de nuages et falaises, les pièces et les placements des dix cartes du chapitre 15. Les 26 passages en combat couvrent les deux factions. Validateur à zéro problème et quatre suites ciblées au vert (29 238 contrôles Godot et 17 tests Python). Lot prêt pour intégration. [Fiche et captures](design/Visuels_Iles_Flottantes.md).

### 2026-11-13 — Décor des mines 131–140 et éboulement (ouvert)

Cinq placements par carte dans `mine.placements`, avec les pièces du chapitre 13. Les deux planches `effect.rockfall` sont dans les ressources et fonctionnent avec ton branchement `77e54d3`. Les 26 passages en combat vérifient les quatre états du premier cycle. Le second cycle a été contrôlé sur 131, 134 et 140, à ×1 et ×2 dans les deux factions. Validateur et six suites ciblées au vert. Lot prêt pour intégration. [Fiche et captures](design/Visuels_Biome_Mines.md#chapitre-14--missions-131-à-140).

### 2026-11-13 — Éboulement : format des planches (ouvert)

Je retiens `effect.rockfall` avec `warning` en mode `progress` et `blocked` en mode `time`. Pourrais-tu ajouter `blocked` au format et brancher les deux états sur l’entrée visée, ancrés au sol avec `foot` et `display_height` en pixels de jeu ? Le tas de pierres reste lisible pendant le blocage, avec de la poussière discrète animée sur le temps de combat. Garde le rendu provisoire en repli.

### 2026-11-13 — Marche de Gueule-de-Vase (ouvert)

Trois planches de 24 poses dans `enemy.neutral.drowned`, vérifiées dans la mission 51 en Alliance et en Horde à ×1 et ×2. Les remous restent lisibles en régénération. Le validateur et les cinq suites ciblées passent sur la v0.189. La marche est en attente du retour visuel du porteur. [Aperçu](design/Visuel_Gueule_de_Vase.md#marche-de-gueule-de-vase).

### 2026-11-12 — Marche des deux boss et du capitaine humain (ouvert)

Planches dans les dossiers `enemy.alliance.marshal`, `enemy.horde.warchief` et `enemy.alliance.garrison`. Le format actuel charge les trois cycles. Le validateur et les quatre suites ciblées passent. Attendre le retour visuel du porteur avant intégration. [Boss](design/Visuels_Marche_Boss.md) · [Capitaine humain](design/Visuels_Garnison.md#marche-du-capitaine-humain).

### 2026-11-12 — Marche du garde noir (ouvert)

Trois planches dans le dossier d’exécution `enemy.horde.guard`. Essais aux Coulées Figées (vague 7) sur les quatre diagonales à ×1 et ×2. Validateur et trois suites ciblées passent. Attendre l’avis visuel du porteur avant intégration. [Captures](design/Visuel_Garde_Noir.md).

### 2026-11-12 — Marche du garde royal (ouvert)

`enemy.alliance.guard` dispose de trois planches de 24 poses dans les ressources. Aucun raccord de code nécessaire. Les quatre diagonales ont été contrôlées à ×1 et ×2, validateur et trois suites ciblées au vert. Attendre l’avis visuel du porteur. [Aperçu](design/Visuel_Garde_Royal.md).

### 2026-11-12 — Habillage des souterrains et mines (ouvert)

Les missions 121–130 ont leur palette, leur calque de strates et cinq pièces par carte. Les ressources sont dans `assets/decor/mine/`, les données dans la clé `mine`. Le moteur affiche le décor avec le format existant. Les marges des dix cartes ont été vérifiées en combat dans les deux factions. [Fiche](design/Visuels_Biome_Mines.md).

### 2026-11-12 — Marche du colosse troll (ouvert)

Trois planches sur `enemy.horde.colossus`, déjà dans le dossier d’exécution. Vérifiées dans les quatre diagonales à ×1 et ×2 et au validateur. Attendre le retour visuel du porteur avant intégration. [Captures](design/Visuel_Colosse_Troll.md).

### 2026-11-12 — Marche du brise-remparts nain (ouvert)

`enemy.alliance.siegebreaker` utilise trois planches de 24 images. Elles sont dans le dossier d’exécution et passent le validateur et les trois suites ciblées. Les quatre diagonales ont été vérifiées à ×1 et ×2 en Horde. Attendre le retour visuel du porteur avant intégration. [Aperçu](design/Visuel_Brise_Remparts.md).

### 2026-11-12 — Course de l’éclaireur elfe (ouvert)

L’elfe utilise les planches de `enemy.alliance.scout` dans le dossier d’exécution. Le validateur et les sept suites ciblées du lot elfe et tempête passent. Les quatre diagonales ont été vérifiées à ×1 et ×2. Le porteur a donné un avis favorable à l’aperçu du gobelin, dont le dossier d’essai et l’ajustement de test restent décrits plus bas. [Aperçu de l’elfe](design/Visuel_Eclaireur_Elfe.md).

### 2026-11-12 — Tempête v0.182, contraste (ouvert)

La rafale publiée est discrète sur les dix cartes et dans l’export Windows (111 et 120). Les deux PNG de `effect.sandstorm` sont renforcés. La phase de la rafale suit déjà le temps de combat dans la v0.182. [Comparatif](design/Visuels_Biome_Desert.md#contraste-de-la-rafale-sur-la-v0182).

### 2026-11-12 — Course de l’éclaireur gobelin (ouvert)

Le porteur a donné un avis favorable à la course du gobelin et a demandé de passer à la suite. La correction du test `47eefa5` est reprise. Les planches sont maintenant dans `prototype/assets/animations/enemy.horde.scout/` et prêtes à intégrer. Le fantassin (`9999fa0`) a été jugé « une bonne base » et reste en attente de feu vert avant intégration. [Captures du gobelin](design/Visuel_Eclaireur_Gobelin.md).

### 2026-11-12 — Marche du fantassin humain (ouvert)

Les planches `enemy.alliance.infantry` sont prêtes sur les sources de la v0.180. Le chargeur existant les trouve sur les trois variantes de pente. Aucun raccord de code n’est requis. Validateur et trois suites ciblées passent. Attendre le retour artistique du porteur avant intégration. [Aperçu](design/Visuel_Fantassin_Marche.md).

### 2026-11-12 — Éruptions, cendres pendant la désactivation (ouvert)

L’avertissement renforcé garde son branchement actuel. La planche `effect.eruption/disabled` est valide et a été essayée en combat dans un rendu isolé sur E1–E6, dans les deux factions à ×1 et ×2. Pour la brancher dans `_draw_eruption`, lire l’âge à partir de `duration - status.remaining` pendant l’état `active`, puis dessiner la planche centrée sur le même emplacement par-dessus les pieds. Garder le repère actuel en repli si la planche est indisponible. Le rendu isolé utilise ce raccord. [Détails et aperçu](design/Avertissement_Eruptions.md#désactivation-par-les-cendres).

### 2026-11-12 — Habillage du chapitre 12 et tempête de sable (ouvert)

Les missions 111–120 ont cinq placements chacune. `effect.sandstorm` contient `warning` en progression et `storm` en boucle, 384 × 192 px par image. Les deux lots du désert peuvent être intégrés à la suite. La planche du troll reste en attente d’un avis final. La miniature de campagne utilise désormais la palette `desert` depuis la v0.181. La phase de la rafale repose sur `Time.get_ticks_msec()` dans `_draw_sandstorm`. Si tu veux que le mouvement suive la vitesse de combat et soit reproductible en rejeu, il faudra le cadencer sur le temps du modèle. [Détails et captures](design/Visuels_Biome_Desert.md#chapitre-12--la-tempête-de-sable).

### 2026-11-12 — Habillage du chapitre 11 (ouvert)

Les missions 101–110 ont leur palette, leur calque et cinq pièces par carte via `assets/decor/decor.json`. Le lot et la palette de l’aperçu de campagne sont intégrés en v0.181. Le lot est indépendant de la planche du troll, qui reste en attente d’un avis final. [Captures et contrôles](design/Visuels_Biome_Desert.md).

### 2026-11-12 — Rectification sur le lancer du troll (ouvert)

Le porteur parle de la hache dessinée dans la main. La demande précédente de signal de préparation est retirée. La planche de `defender.horde.axe` conserve la hache jusqu’à la pose de bras tendu, puis la main s’ouvre. [Comparatif](design/Visuel_Troll_Lancer.md#prise-de-la-hache-pendant-le-geste). Attendre le retour visuel du porteur avant intégration.

### 2026-11-12 — Raccords du lancer du troll (ouvert)

Après le retour du porteur sur le clipping, deux poses intermédiaires ont été ajoutées pour la rotation du bras et la reprise de la hache. La description `animation.json` et le point de départ du tir sont inchangés. Quatre tirs avec rebond vérifiés à ×1 et ×2, validateur et quatre suites ciblées au vert (511 contrôles Godot, 17 tests Python). Attendre l’avis du porteur avant intégration. [Comparatif](design/Visuel_Troll_Lancer.md#raccords-du-bras-et-de-la-hache)

### 2026-11-12 — Reprise du lancer du troll, avis attendu (ouvert)

Le porteur trouve raide la première animation publiée dans la v0.179. La seconde proposition fait participer le genou avant, les épaules et le bras libre, et ajoute une reprise de la hache près de la hanche. 24 images sur 0,80 s, testées au Gué dans les deux sens à ×1 et ×2. Validateur et quatre suites ciblées au vert (511 contrôles Godot, 17 tests Python). Attendre le retour du porteur avant d’intégrer cette proposition. [Comparatif](design/Visuel_Troll_Lancer.md#lancer-retravaillé)

La planche commence au lâcher, sur le signal d’attaque actuel. Si l’essai montre qu’il faut une préparation avant le tir, on pourra discuter d’un signal de présentation distinct. Les cartes du désert 101–110 sont disponibles pour le prochain lot d’habillage.

### 2026-11-11 — Animation de lancer du troll (ouvert)

`defender.horde.axe/attack.png` fournit douze images sur 0,48 s. Le point de départ historique de la hache est aligné sur le lâcher, puis la main reste vide pendant le vol et le rebond. Quatre tirs avec rebond ont été contrôlés au Gué, des deux côtés à ×1 et ×2. Validateur et quatre suites ciblées au vert (511 contrôles Godot, 17 tests Python). [Aperçu en combat](design/Visuel_Troll_Lancer.md)

La fusion mage, arbalétrier et capitaine humain est vérifiée. J’attends les identifiants des cartes du chapitre 11 pour le décor du désert et des ruines.

### 2026-11-11 — Lancement du sort du mage et retour arbalétrier (ouvert)

`defender.alliance.mage` fournit `attack` en 12 images sur 0,40 s. Le cristal reste sur le point de départ historique du projectile. Vrais tirs au Gué dans les deux sens à ×1 et ×2. Validateur et cinq suites ciblées au vert (12 038 contrôles Godot, 17 tests Python), dont `test_decor_art.gd` avec le contrôle de géométrie. [Aperçu et détails](design/Visuel_Mage_Incantation.md)

Le porteur a donné un retour favorable sur l’aperçu de l’arbalétrier (`162bcc0`). Le filtrage du capitaine humain est déjà commité sur `art/codex` à `95a1d2a`, contrôles terminés. Il peut rejoindre le prochain lot.

### 2026-11-11 — Tir et réarmement de l’arbalétrier (ouvert)

Le dossier `prototype/assets/animations/defender.alliance.crossbow/` fournit `attack` en 18 images sur 0,72 s. Le point de départ historique du carreau convient à la pose de lâcher. Vérification de vrais tirs gauche et droite à ×1 et ×2, puis de trois cycles avec le bonus de cadence. Le validateur et quatre suites ciblées passent (509 contrôles Godot, 17 tests Python). [Animation et contrôle](design/essais/arbaletrier_tir/README.md#tir-par-planche-sur-les-sources-de-la-v0178).

### 2026-11-11 — Contrôles de la v0.178 et extension des calques d’eau (ouvert)

Les Eaux Mortes (51) en vague 2 et Le Carrefour des Eaux (58) en vague 8 ont été vérifiés en combat dans les deux factions. Sur la 58, la créature blessée de la route centrale traverse la jonction sans récupérer de PV. La branche haute inondée déclenche bien les remous et la remontée de PV. L’ordre actuel convient. Dans `valley_view.gd`, la ligne claire de la chaussée précède le PNG, et le surlignage de survol (`highlighted_segments`) est déjà tracé par-dessus. Les captures le confirment.

Les huit autres calques sont ajoutés à `marsh.overlays` (52–57, 59 et 60). Les dix entrées correspondent à la géométrie actuelle, y compris les identifiants de route des intervalles. Les deux suites ciblées passent (16 130 contrôles Godot, 17 tests Python). [Captures en jeu](design/Visuels_Troncons_Inondes.md#contrôle-en-combat-et-extension-sur-la-v0178)

Pour un futur changement de tracé ou un ancien rapport, le contrôle de géométrie est aujourd’hui effectué par le test. Le rendu appelle `water_overlay` par identifiant seul. Si des rapports peuvent présenter une géométrie historique sous le même identifiant, conserver le repère calculé dans ce cas, comme convenu. Le réglage de filtrage du capitaine humain (`95a1d2a`) reste sur `art/codex` et peut rejoindre le prochain lot.

### 2026-11-11 — Rendu du capitaine humain sur le plateau (ouvert)

`capitaine_humain_v001.png.import` active les mipmaps pour tirer parti du filtre déjà utilisé sur le plateau. Le PNG, le cadre et l’ancre approuvés sont identiques. Contrôle de la texture réimportée et comparaison à temps et positions identiques en vague 5 sur 91, 94, 98 et 100 côté Horde. Les suites visuels ennemis et Garnison passent (4 741 contrôles Godot et 17 tests Python). [Comparatif en jeu](design/Visuels_Garnison.md#lisibilité-du-capitaine-humain-sur-le-plateau).

### 2026-11-11 — Ordre de dessin des Éruptions et calques d’eau (ouvert)

**Éruptions.** Je garderais pour ce lot les fissures au sol sous les unités. À ×2 sur la mission 71, les extrémités de l’alerte restent visibles sur E1–E6 dans les deux factions. Si l’alerte se perd en partie libre, je peux renforcer les bords ou préparer une planche de quelques braises de premier plan à dessiner devant les bottes. [Captures des six emplacements](design/essais/volcan_variantes/Eruptions_x2_six_emplacements.jpg)

**Tronçons inondés.** Tu peux commencer l’intégration dès maintenant par Les Eaux Mortes (51, `marsh_stagnant`) et Le Carrefour des Eaux (58). Je propose des PNG transparents statiques dans `assets/decor/marais/`, décrits par identifiant de carte dans `decor.json` avec leur fichier et leur position `relative_xy` par rapport à l’origine isométrique. Ils remplacent le repère bleu provisoire et se dessinent après les joints de la chaussée, avant le surlignage des routes, les emplacements, les unités et les annonces. Laisser les règles de régénération suivre `flooded` et la route du modèle. Revenir au repère calculé si le PNG manque ou si les routes ou les intervalles inondés diffèrent, notamment pour un ancien rapport.

Les dix PNG ont été ouverts et les routes, intervalles inondés, dimensions et positions correspondent aux données actuelles de la v0.177. Après le premier essai, je vérifierai la transition sec/eau sur la 51 et le croisement de la 58 en combat dans les deux factions, puis on pourra étendre aux huit autres cartes. [Fiche](design/Visuels_Troncons_Inondes.md) · [Repères par carte](design/essais/eaux_inondees/Reperes.json)

**État Git.** `art/codex` a repris `origin/main`. Le tag `v0.177` contient le compte rendu `bdfced4`. Les lots citadelles (`9611f72`), variantes volcaniques (`ffe4309`) et remous renforcés (`f2faf23`) restent sur `art/codex`. Le lot remous renforcés est à prendre pour l’essai de la 51.

### 2026-11-11 — Remous de Gueule-de-Vase renforcés (ouvert)

`prototype/assets/animations/effect.regeneration/regen.png` reçoit un contour plus sombre et une écume plus claire. Le format, l’ancrage et la cadence de la planche restent identiques. Vague 2 de la 51 contrôlée dans les deux factions à ×1 et à ×2, au sec et en régénération. Le validateur et la régression ciblée animation et marais passent (4 768 contrôles Godot, 17 tests Python). [Comparatif avant et après](design/Visuel_Gueule_de_Vase.md#contraste-des-remous-en-combat).

Le porteur a donné un retour favorable sur les captures des variantes volcaniques (`ffe4309`).

### 2026-11-11 — Variantes des terres volcaniques (ouvert)

`prototype/assets/decor/volcan/basalte_eclate.png` et `ruine_angle.png` sont déclarés dans `decor.json`. Les vingt cartes de 61 à 80 utilisent des compositions renouvelées, six pièces par carte. Les PNG suivent le mécanisme existant de découverte des ressources de décor. Les quatre suites ciblées passent, avec 18 586 contrôles Godot et 17 tests Python.

Quarante scènes ont été contrôlées en combat. À ×2 sur le Cratère Fumant, l’alerte reste distincte du décor sur les six emplacements testés dans les deux factions. Les bottes recouvrent encore le centre du tracé. [Captures et périmètre des contrôles](design/Visuels_Biome_Volcanique.md#variantes-et-placements-des-missions-61-à-80).

### 2026-11-11 — Extension du décor des citadelles (ouvert)

`prototype/assets/decor/decor.json` contient les 91 placements des missions 83–86 et 88–100. Les deux factions ont été contrôlées en combat sur chaque carte. Les marges et la Garnison passent en régression ciblée, avec 15 779 contrôles Godot et 17 tests Python. [Fiche et captures](design/Visuels_Citadelles.md#extension-aux-chapitres-9-et-10).

Le Pont-levis (`citadel_drawbridge`, mission 82) reste le témoin sans placement dans `test_decor_art.gd`. Peux-tu déplacer cette assertion vers un identifiant sans décor ? Les [six placements du Pont-levis](design/essais/citadelles_extension/Pont_levis_placements.json) ont déjà été essayés dans les deux factions. Ils pourront alors rejoindre `citadel.placements`.

### 2026-11-11 — Contrôles visuels de la v0.176 (ouvert)

Contrôles réalisés sur `art/codex` à partir de `bf8c654`. Les [captures et résultats](design/Visuels_Controle_v0176.md) couvrent les deux factions pour les missions 51, 61, 71 et 87, ainsi que la Horde sur 91–100. Le validateur et les quatre tests ciblés passent.

- Le remous de `effect.regeneration` accompagne la remontée de PV en vague 2 sur la mission 51. Il gagnerait à mieux se détacher de la chaussée inondée à taille de jeu.
- La mission 61 sert de témoin sans affixe. La mission 71 vise la même case pendant l’alerte puis la désactivation. Durées mesurées de 3 s et 5 s à ×1, puis 1,5 s et 2,5 s à ×2. Les fissures de `effect.eruption` sont en partie masquées sous les bottes. La désactivation est visible grâce au nuage et à la case assombrie.
- Les trois entrées de la 87 et les deux décors adverses restent lisibles. Le capitaine humain `enemy.alliance.garrison` apparaît à la vague 5 de chacune des missions 91–100 côté Horde. Certains contours sont crénelés à taille de jeu. Je garde le traitement à petite échelle dans la file artistique.
- Conserver pour l’instant les trois anciens sprites du Grouillant, du Pillard et du Sprinter. Prévoir leur déplacement vers les archives avec la mise à jour des liens, dans un lot dédié.

## Traité

### 2026-11-15 — Fantassin squelette, frappe de mêlée (traité)

Animation de frappe archivée dans [la fiche](design/Visuels_Boutique_Fantassin_Squelette.md). Branchement annulé par la décision de retrait du type 46.

### 2026-11-15 — Tirailleur gnome validé (traité)

Visuel fixe documenté dans [la fiche](design/Visuels_Boutique_Tirailleur_Gnome.md). La demande est remplacée par le retrait du type 47.

### 2026-11-15 — Fantassin squelette validé (traité)

Visuel fixe documenté dans [la fiche](design/Visuels_Boutique_Fantassin_Squelette.md). La demande est remplacée par le retrait du type 46.
