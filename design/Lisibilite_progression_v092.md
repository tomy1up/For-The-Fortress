# Parcours et gains plus lisibles — v0.92

30 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Présentation proposée

La demande de lisibilité vise des écrans moins chargés et une progression compréhensible. Cette version propose la prochaine mission jouable et rend le premier point de talent plus facile à repérer, sans ajouter de règle de combat ou de récompense.

À l’ouverture du parcours et au retour d’un résultat, la sélection se place sur la première mission disponible encore à réussir. Après les trois réussites, elle reste sur la dernière mission jouable, proposée en rejeu sans nouveau gain. Le joueur conserve son choix : il clique pour lancer, peut sélectionner une autre mission ou s’arrêter. Une sélection manuelle n’est pas remplacée lorsqu’il consulte puis ferme les talents.

Le nom et le numéro de mission restent visibles dans les quatre onglets du bilan. Le texte de progression est condensé autour de l’XP gagnée, de son total et de la prochaine action utile. Avant le premier point, il indique l’XP restante ; lorsqu’un point est disponible, il annonce « 1 point de talent à placer » et propose « Placer mon point de talent ». Le bouton ouvre les arbres du bon camp ; le joueur choisit le talent. Après investissement, le bilan indique le prochain seuil plutôt qu’un point supplémentaire.

Le détail des PO disponibles, du plafond et des points investis reste au survol du texte de progression. Un résultat non enregistré conserve son avertissement et son action de reprise, y compris s’il s’agit d’un rejeu sans récompense. Le premier clic de reprise confirme l’enregistrement ; l’accès aux talents reste une action explicite.

## Règles conservées

Trois missions de dix vagues, PV ennemis à 100/101/102 %, gains uniques de prototype à 60 PO et 100 XP, premier point à 197 XP et plafond de 51 points par faction. Talents préparés entre les missions, reset gratuit, acquis persistants et séparés par faction. Le schéma 6 du profil, les cartes, les statistiques, les rapports et les arbres à quatre colonnes ne changent pas dans ce lot.

L’échantillon de v0.91 reste à éprouver par des joueurs pour son équilibre. Cette proposition de présentation n’étend pas la campagne au-delà des trois missions existantes.

## Validation

71 suites et **23 892 contrôles Godot**, 16 tests Python et contrats du GDD réussis. Les 68 contrôles dédiés vérifient la suggestion sans écriture ni transfert de faction, le maintien d’une sélection manuelle, les quatre onglets du bilan, le premier point et son investissement, le prochain seuil et la reprise d’un résultat non enregistré lors d’un rejeu. Les 914 contrôles de navigation restent réussis.

Le paquet Windows passe **175 lancements et 174 captures**, avec 45 sources comparées. Les scénarios de première progression des deux factions vérifient aussi le nom de mission, le point disponible, l’action associée et la sélection finale. Les quatre rapports des nouvelles missions exportés par le binaire se rejouent intégralement. Les 40 scénarios historiques du Gué gardent rapports, aléas, événements et dégâts identiques à v0.91 ; les sources du combat, des cartes, du profil et des talents restent strictement inchangées.

[Régression](essais/v092_regression.json), [comparaison](essais/v092_comparaison_combat.json), [rejeux natifs](essais/v092_rejeux_natifs.json), [distribution](Distribution_Windows_v092.json). Exemple : [premier point Horde](essais/captures/QA-v092_horde_sample_2_summary.png), [parcours Alliance](essais/captures/QA-v092_alliance_campaign_menu_returned.png).
