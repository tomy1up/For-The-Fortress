# Monnaies lisibles — prototype v0.86

29 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

Le nom demandé pour la monnaie de progression est désormais affiché : **PO**, pour pièces d’or. L’accueil, les arbres, le bilan et le rappel de gains utilisent PO Alliance ou PO Horde. La monnaie temporaire du plateau porte le libellé **Or de combat**.

Des aides courtes expliquent que les PO persistent après fermeture et achètent les points de talent de la faction, tandis que l’or de combat sert au recrutement, aux améliorations et aux ventes pendant la partie. Aucun transfert, conversion, nouveau prix ou nouveau gain n’est introduit. Le format des sauvegardes reste le schéma 4 : la clé interne `resource` est conservée pour la compatibilité.

Les arbres à 51 points et le reset gratuit restent en place. Le Gué conserve son économie de fin de partie ; ce changement de vocabulaire n’active ni les récompenses de première victoire de campagne ni la boutique. Le budget de 510 PO demeure une hypothèse au prix provisoire de 10 PO par point.

## Décision de campagne enregistrée pendant ce lot

Le porteur du projet a confirmé un **parcours indépendant par faction**, avec suivi distinct des missions réussies et du déblocage du mode infini. Cette décision est inscrite sous CAMP-010 ; elle ne prétend pas que le parcours de campagne ou le mode infini sont déjà jouables.

## Validation

63 suites et 19 538 contrôles Godot, 16 tests Python et contrats du GDD réussis. Le paquet Windows passe 146 lancements avec 145 captures et 41 sources comparées. Sept captures des écrans modifiés ont été inspectées : accueil, arbres, bilans et HUD des deux factions.

Les seize scénarios comparés à v0.85 gardent exactement les rapports, états aléatoires, événements et dégâts. Les données de combat, cartes, progression, profil et protection Windows ne changent pas. Aucune nouvelle migration de sauvegarde n’est requise.

[Régression](essais/v086_regression.json), [comparaison](essais/v086_comparaison_combat.json), [distribution](Distribution_Windows_v086.json). Exemples : [accueil](essais/captures/QA-v086_home_prepared.png), [bilan Horde](essais/captures/QA-v086_horde_progression_victory.png).
