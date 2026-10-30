# Lecture des points et des arbres de talents — v0.95

30 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Présentation proposée

L’en-tête met au premier plan le nombre de points à placer, le total débloqué sur les 51 autorisés et l’XP conservée. Le solde de PO reste accessible au survol, avec le rappel de son usage pour la future boutique ; il n’est plus affiché au même niveau que les points de talent.

Le compteur de chaque arbre indique son orientation dominante : forteresse et portée, tirs à distance ou magie et explosions pour l’Alliance ; haches et rebonds, malédictions ou explosifs pour la Horde. Ces indications décrivent les effets existants, sans ajouter de talent ni modifier ses bénéficiaires.

Des coins clairs repèrent le talent dont l’effet est affiché, indépendamment de son état, au survol comme au clavier. Un seul talent porte ce repère. La légende est raccourcie ; les explications des cadenas, exclusions et flèches restent au survol et dans le détail sélectionné.

L’aide du bas suit la situation : chercher une première victoire en l’absence de point, investir un rang lorsqu’un point est disponible, ou réinitialiser gratuitement pour essayer une autre répartition lorsque les 51 points sont investis. Une erreur de sauvegarde ou un message de migration garde la priorité.

Si la progression est indisponible, les compteurs indiquent leur indisponibilité et les rangs sont inconnus : ils ne sont pas présentés comme des gains remis à zéro. L’effet général d’un talent reste consultable, sans prévision chiffrée fondée sur une répartition non confirmée.

## Règles conservées

Les trois arbres restent sur quatre colonnes, avec sept paliers, des cases vides et des liens verticaux. Les 63 talents par faction, leurs rangs, valeurs, prérequis, exclusions et plafond de 51 points ne changent pas. Les talents restent fixes pendant une mission ; le reset reste gratuit entre missions. Aucun achat de point en PO ni nouvelle conversion n’est introduit.

Les trois missions, leur XP, leurs PO, les sauvegardes et le combat sont conservés. Cette disposition est une proposition de présentation à confronter aux essais humains, pas une nouvelle décision d’équilibrage.

## Validation

74 suites et **25 276 contrôles Godot**, 16 tests Python et contrats numériques du GDD réussis. Les 552 contrôles dédiés vérifient le repère unique sur les 63 talents de chaque faction, la cohérence des bénéficiaires, la lecture sans écriture, les rôles et compteurs, le premier gain d’XP, l’investissement et le reset sans débit de PO, puis le changement de faction et les erreurs prioritaires. Les 108 contrôles des états de talents restent réussis.

Le paquet Windows passe **189 lancements et 188 captures**, avec 45 sources comparées. Huit cas supplémentaires contrôlent les deux factions avant le premier point, au premier point disponible, après investissement et à progression indisponible. Les huit vues ont été inspectées, ainsi que les six répartitions complètes à 51 points. Les quatre colonnes, les paliers et les flèches restent visibles. Quatre rapports du binaire se rejouent intégralement ; 40 scénarios de combat restent identiques à v0.94. Les sources des règles de talents, du profil, du combat et des cartes sont inchangées.

[Régression](essais/v095_regression.json), [comparaison](essais/v095_comparaison_combat.json), [rejeux natifs](essais/v095_rejeux_natifs.json), [distribution](Distribution_Windows_v095.json). Exemples : [premier point Alliance](essais/captures/QA-v095_alliance_talent_start_first.png), [avant le premier point Horde](essais/captures/QA-v095_horde_talent_start_fresh.png), [répartition Horde](essais/captures/QA-v095_horde_expanded_tree_0.png). La lisibilité reste à confirmer lors des essais humains.
