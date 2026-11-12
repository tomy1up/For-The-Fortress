# Désert et ruines · habillage du chapitre 11

Première proposition visuelle, préparée sur les sources de la v0.180 le 12 novembre 2026. Le sable ocre et les rides basses structurent le sol. Les quatre silhouettes de grès (colonne brisée, mur et départ d’arche, rochers érodés, obélisque) existent dans les deux orientations. Les pièces proviennent d’une planche générée sur fond transparent, avec une lumière chaude et des silhouettes simples pour le rendu isométrique.

## Placements

Cinq pièces sur chacune des missions 101 à 110, avec une disposition par carte. Les Premières Dunes alternent rochers et vestiges isolés. Les Colonnes Brisées reprennent plusieurs fûts de grès. Les obélisques se retrouvent sur le site qui leur donne son nom et à la Nécropole Ancienne. La Mer de Sable utilise surtout des rochers bas pour garder un horizon ouvert.

Les ancres gardent au moins 1,16 unité de distance aux trajets et 1,45 aux emplacements. Les silhouettes projetées ont aussi été contrôlées contre les routes, les losanges d’emplacement et la forteresse. Les dix cartes ont été capturées sur la première vague avec deux défenseurs placés, dans les deux factions. Les suites décor, chapitre désert, chapitre tempête et bibliothèque d’animations passent (21 277 contrôles Godot, 17 tests Python). Le contrôle propre aux placements du désert a été réalisé pendant la capture.

- [Missions 101 à 105](essais/desert_ch11/Desert_101_105.jpg)
- [Missions 106 à 110](essais/desert_ch11/Desert_106_110.jpg)

La miniature reprend la palette du désert depuis la v0.181, qui intègre aussi les placements des missions 101–110.

## Chapitre 12 · la tempête de sable

Les dix cartes reçoivent cinq éléments de décor chacune. Quatre nouveaux éléments en grès reprennent la matière et l’angle des ruines du chapitre 11. La citerne, le sphinx ébréché, le sarcophage fermé et la pyramide servent de repères sur les cartes correspondantes. Les tracés de combat et les emplacements viennent des données de la v0.180.

La planche d’avertissement suit la progression des trois secondes d’annonce. Une poussière dorée monte le long des bords du plateau. Pendant la rafale, les traînées se déplacent en diagonale et traversent le plateau sous les unités. Le voile s’arrête au retour à la portée normale. Les cellules mesurent 384 × 192 px. L’avertissement compte 24 images en mode `progress`. La rafale boucle sur 36 images à 24 images/s en mode `time`. Depuis la v0.182, le jeu choisit ses états et la phase de la rafale selon le temps de combat.

Les dix cartes ont été contrôlées en combat avec chaque faction. Les missions 111, 114 et 120 ont été contrôlées à ×1 et ×2 pour chaque faction, soit 26 passages au total. L’annonce conserve la portée normale, la rafale applique le facteur 0,75 et la portée revient à 1 à sa fin. Le validateur signale zéro problème sur huit dossiers. Les cinq suites ciblées passent (21 353 contrôles Godot, 17 tests Python).

- [Quatre monuments sur le plateau](essais/desert_ch12/Desert_111_120_monuments.jpg)
- [Étapes d’une rafale aux Arches de Grès, Horde ×2](essais/desert_ch12/Tempete_etapes.jpg)
- [Annonce, rafale et retour au calme à la Pyramide Ensablée, Horde ×1](essais/desert_ch12/Tempete_en_combat.gif)
