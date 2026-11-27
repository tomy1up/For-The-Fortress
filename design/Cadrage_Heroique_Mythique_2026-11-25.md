# Cadrage des difficultés Héroïque et Mythique (25 novembre 2026)

**Statut.** Ce document sépare les **décisions du porteur**, datées, des **propositions de Claude Code**, à confirmer. Aucune valeur n'est validée : toutes sont des réglages de prototype à confirmer. Il complète `Difficultes_campagne_2026-10-31.md`, `Infini_difficultes_2026-10-31.md` et les règles CAMP-018 à CAMP-020 de `Cadrage_campagne_2026-10-29.md`.

## Déjà décidé avant ce cadrage

- Trois difficultés de campagne : Normal (la campagne actuelle), Héroïque, Mythique (CAMP-020, 31 octobre 2026).
- Accès faction par faction : les 100 premières missions réussies en Normal ouvrent l'Héroïque, et les 100 premières en Héroïque ouvrent le Mythique. Dans chaque difficulté, les missions se débloquent une à une.
- Progression persistante commune : PO, XP et talents de la faction, limite de 51 points. Les acquis du Normal sont conservés et aucun point de talent n'est ajouté.
- Le cumul des attaquants et des affixes déjà rencontrés est réservé à l'Héroïque, au Mythique et à l'infini (CAMP-018, CAMP-019).

## Décisions du porteur du 25 novembre 2026

1. **L'Héroïque se joue sur les mêmes 200 missions que le Normal, durcies.** Mêmes cartes et mêmes vagues de base.
2. **Il faut aussi de la nouveauté rafraîchissante au fil des 200 missions.** Le porteur retient :
   - **les champions mutants** : quelques ennemis de chaque mission portent un trait tiré au hasard ;
   - **les bonus héroïques** : des bonus inédits, proposés seulement en Héroïque (et en Mythique).
3. **Le Mythique a sa propre identité : la course par chapitre.** Les dix missions d'un chapitre se jouent d'une traite ; les PV de la forteresse et les bonus se gardent d'une mission à l'autre ; une défaite fait recommencer le chapitre.

## Propositions de Claude Code, à confirmer

### Durcissement de l'Héroïque
- **Cumul des nouveautés** : à partir du chapitre 3, chaque mission reçoit en plus l'affixe ou l'attaquant d'un biome déjà traversé, différent d'une mission à l'autre ; à partir du chapitre 11, deux.
- **PV calibrés pour un joueur avisé** : la meilleure composition, jouée par un joueur qui choisit bien ses bonus et relance, doit finir entre 40 et 70 % de marge. En Normal, ce joueur finit vers 80 à 85 %. La cible du Normal ne change pas (MAJ-79).
- **Récompense** : à la première victoire de chaque mission, les PO du Normal majorées de moitié, une seule fois. Pas d'XP, la limite de 51 points restant atteinte.

### Champions mutants
- **Nombre** : un champion par vague à partir de la vague 3, soit huit par mission. Jamais le boss.
- **Repère visuel** : une aura colorée et une petite icône du trait, dessinées par le code. Codex pourra dessiner les icônes ensuite.
- **Introduction progressive**, pour que la nouveauté se renouvelle tout au long des 200 missions : deux traits au chapitre 1, puis un trait de plus par chapitre jusqu'au chapitre 12. Du chapitre 16 au chapitre 20, un champion peut porter deux traits.
- **Exemples de traits** :
  - Bouclier : absorbe une part de ses PV ;
  - Hâte : se déplace plus vite ;
  - Scission : se divise en deux petits ennemis à sa mort ;
  - Régénération ;
  - Aura de soin : soigne ses voisins ;
  - Insensible : ignore les ralentissements ;
  - Vengeur : renforce ses voisins à sa mort ;
  - Blindé : encaisse moins les tirs directs ;
  - Pillard : vole de l'or en atteignant la forteresse ;
  - Colosse : PV doublés, plus grand.

  La liste et les valeurs seront soumises au porteur avant le développement.

### Bonus héroïques
- Une quinzaine de bonus inédits, plus marqués que les 60 actuels et capables de définir une stratégie, ajoutés aux offres en Héroïque et en Mythique.
- Ils sont introduits progressivement, environ un par chapitre, pour garder de la nouveauté.
- **Exemples** :
  - Chasseur de champions : dégâts accrus contre les champions ;
  - Butin des champions : or à leur mort ;
  - Forge ardente : une amélioration gratuite par vague ;
  - Sacrifice : vendre une unité rapporte un bonus ;
  - Tour de guet : un emplacement de plus.

  La liste et les valeurs seront soumises au porteur avant le développement.

### Mythique : questions à trancher avant de le développer
- Ce qui se garde d'une mission à l'autre :
  - PV de forteresse et bonus (décidé) ;
  - et aussi l'armée et l'or ? Ou chaque mission repart avec une armée neuve ?
- Le nombre de choix de bonus par mission (quatre par mission feraient quarante bonus par chapitre) et la relance par chapitre.
- Les soins entre deux missions, et la récompense à la fin d'un chapitre.
- Ce que le Mythique reprend de l'Héroïque : champions, bonus héroïques, cumul.

### Interface
- Dans l'écran de campagne, des onglets Normal, Héroïque et Mythique au-dessus des chapitres. Une difficulté verrouillée affiche sa condition, par exemple « 100 missions réussies en Normal : 42/100 ».

## Découpage proposé du développement

| Lot | Contenu | Dépend de Codex |
| --- | --- | --- |
| 1. Socle des difficultés | **Livré en v0.257** (`Difficultes_socle_v0257.md`) : progression par faction et par difficulté (identifiants propres, sans migration), onglets, Héroïque jouable, rapports et rejeu, récompense | Non |
| 2. Champions mutants | **Livré en v0.258** (`Champions_mutants_v0258.md`) : douze traits validés le 25 novembre 2026, un par chapitre jusqu'au chapitre 11, aura et pastilles dessinées par le code | Non (icônes plus tard) |
| 3. Cumul des nouveautés | **Livré en v0.259** (`Cumul_nouveautes_v0259.md`) : règles validées le 26 novembre 2026, un rappel par mission à partir du chapitre 3, deux à partir du chapitre 11 | Non |
| 4. Bonus héroïques | **Livré en v0.260** (`Bonus_heroiques_v0260.md`) : quinze bonus validés le 27 novembre 2026, introduits du chapitre 1 au chapitre 14 ; **renforcé en v0.261** (`Bonus_heroiques_v0261.md`) : second choix héroïque aux vagues 4 et 8, valeurs relevées | Non |
| 5. Calibrage de l'Héroïque | Coefficients de PV par mission pour la cible du joueur avisé, garde des tests | Non |
| 6. Mythique | Questions ci-dessus tranchées, puis course par chapitre | Non |
