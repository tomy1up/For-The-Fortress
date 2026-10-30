# États de mission et navigation du parcours — v0.94

30 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Correction de présentation

Dans la v0.93, les missions sans contenu jouable conservaient l’apparence générale des missions existantes. Le parcours distingue désormais les contenus à venir par un cercle en pointillés et un badge de trois points. Les chapitres sans mission jouable portent « À venir ». Ils restent consultables pour comprendre la structure cible ; ils ne deviennent pas jouables et ne reçoivent ni carte ni récompense inventée.

Une mission existante en attente du succès précédent garde son cadenas ; une mission disponible conserve sa mise en évidence, et une réussite sa coche. Une courte légende explicite ces repères. En cas de progression indisponible, un avertissement et le bouton « Progression indisponible » remplacent le faux message de mission verrouillée. Les gains existants ne sont pas effacés.

## Chapitre sélectionné visible

La liste défile pour maintenir le chapitre sélectionné dans son champ, après la mise en page. Le focus reste sur la mission ou l’action choisie. Les demandes rapides sont regroupées sur la sélection la plus récente ; fermer le parcours ou ouvrir les talents empêche un déplacement différé derrière la fenêtre.

Les aperçus des trois terrains, les actions et les récompenses de v0.93 sont conservés. Le combat, les tracés, les PV ennemis, l’économie, les sauvegardes et les arbres de talents ne changent pas. La disposition et les repères graphiques restent des propositions de présentation à confronter aux essais humains.

## Validation

73 suites et **24 724 contrôles Godot**, 16 tests Python et contrats numériques du GDD réussis. Les 576 contrôles dédiés vérifient les états des missions, le défilement des vingt chapitres dans les deux factions, la conservation du focus, la navigation rapide, la fermeture et le recouvrement par les talents. Ils couvrent aussi la distinction entre progression indisponible et verrou, la consultation sans changement des acquis et l’absence de transfert entre camps. Les 256 contrôles d’aperçu et les 914 contrôles de navigation restent réussis.

Le paquet Windows passe **181 lancements et 180 captures**, avec 45 sources comparées. Les états des dix nœuds et la visibilité du chapitre sélectionné sont également contrôlés dans les captures du binaire pour les deux factions. Les vues neuves, réussies, verrouillées, futures et à progression indisponible ont été inspectées sur l’écran de droite. Quatre rapports exportés par le binaire se rejouent intégralement. Les 40 scénarios du Gué gardent rapports, tirages, événements et dégâts identiques à v0.93 ; cartes, combat, profil et talents restent strictement inchangés.

[Régression](essais/v094_regression.json), [comparaison](essais/v094_comparaison_combat.json), [rejeux natifs](essais/v094_rejeux_natifs.json), [distribution](Distribution_Windows_v094.json). Exemples : [parcours neuf](essais/captures/QA-v094_alliance_campaign_menu_fresh.png), [chapitre 20](essais/captures/QA-v094_horde_campaign_menu_future.png), [progression indisponible](essais/captures/QA-v094_alliance_campaign_menu_blocked.png). Ces contrôles de fonctionnement ne remplacent pas les essais humains de compréhension.
