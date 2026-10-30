# Aperçus des cartes avant mission — v0.93

30 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Présentation proposée

Le parcours affiche le terrain de la mission sélectionnée : tracé, entrée, forteresse et six emplacements, dans une vue isométrique simplifiée. Le dessin lit les mêmes données géométriques que le combat. Aucun défenseur, rayon de portée ou élément de décor fictif n’est ajouté à cette prévision.

L’aperçu change pour le Gué, le Bois du Gué et les Hauts du Gué. Le joueur peut examiner une carte verrouillée ; le succès précédent reste nécessaire pour la lancer. Les contenus à venir affichent « Carte à venir », sans reprendre par défaut le terrain d’une autre mission.

Le panneau réunit l’image, les vagues et PV de l’essai, la récompense ou l’absence de nouveau gain, puis les actions de lancement et de préparation des talents. Le statut du mode infini reste indiqué. L’aperçu ne capte ni clic ni navigation clavier et ne crée aucun gain, tentative ou changement de faction.

## Limites

Cette version améliore la lecture du terrain, sans carte interactive ni simulation anticipée des dégâts. Les tracés, emplacements, vagues, ennemis, gains et règles de talents de v0.92 sont conservés. L’[audit de 2 592 configurations](Comparaison_trois_missions_v092.md) souligne le poids du placement et des compositions ; il ne sert pas à déduire une modification d’équilibrage ou un taux de victoire humain.

La disposition de l’aperçu est une proposition de présentation à confronter aux essais du porteur du projet. Les trois missions constituent toujours le seul contenu jouable ; la boutique et l’infini restent à réaliser.

## Validation

72 suites et **24 148 contrôles Godot**, 16 tests Python et contrats numériques du GDD réussis. Les 256 contrôles dédiés couvrent la géométrie réelle des trois cartes, les deux factions, les emplacements et marqueurs contenus dans le panneau, les zones de texte et d’action sans chevauchement, la consultation sans écriture de progression, le maintien du verrou et l’absence d’aperçu inventé pour les missions futures. Les 914 contrôles de navigation restent réussis.

Le paquet Windows passe **181 lancements et 180 captures**, avec 45 sources comparées. Les états d’aperçu des trois cartes et d’une carte verrouillée sont contrôlés dans le binaire pour les deux factions. Les captures des terrains, contenus futurs, rejeux et erreurs de sauvegarde ont été inspectées sur l’écran de droite. Quatre rapports des nouvelles missions exportés par le binaire se rejouent intégralement. Les 40 scénarios de combat du Gué gardent rapports, tirages, événements et dégâts identiques à v0.92 ; cartes, combat, profil au schéma 6 et talents restent strictement inchangés.

[Régression](essais/v093_regression.json), [comparaison](essais/v093_comparaison_combat.json), [rejeux natifs](essais/v093_rejeux_natifs.json), [distribution](Distribution_Windows_v093.json). Exemples : [Gué](essais/captures/QA-v093_alliance_campaign_menu_fresh.png), [Bois du Gué](essais/captures/QA-v093_horde_campaign_menu_terrain2.png), [Hauts du Gué](essais/captures/QA-v093_alliance_campaign_menu_terrain3.png). Ces contrôles de fonctionnement ne remplacent pas les essais humains de compréhension et d’équilibrage.
