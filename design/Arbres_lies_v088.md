# Arbres irréguliers et talents liés — prototype v0.88

29 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Règles demandées et contenu proposé

La disposition suit la référence d’architecture fournie par le porteur du projet : positions vides, nombres de talents variables selon les lignes et flèches reliant certains talents. **Un enfant exige le rang maximum de son parent et le seuil de points de sa ligne dans le même arbre.** Un palier ouvert ne permet pas de contourner le parent. Le service de sauvegarde applique la même règle que l’interface.

Le plafond partagé reste de 51 points par faction, obtenus par l’XP de première victoire. Le reset reste gratuit et les talents restent fixés pendant une mission. Les deux majeurs de chaque arbre sont aux seuils 15 et 30. Le majeur intermédiaire reste facultatif pour atteindre le final.

Le prototype conserve les 21 talents et leurs identifiants stables, sur quatre colonnes et sept lignes à **3/3/3/4/4/3/1 talents**. Deux chaînes sont proposées par arbre : les talents locaux 5 → 7 → 9 et 11 → 16 → 18. Les positions et les liens précis sont des **hypothèses de conception**, ainsi que les effets chiffrés existants ; la règle de parent maximal et la disposition irrégulière sont les demandes explicites.

Les talents locaux 19 et 20 remontent aux seuils 20 et 15, laissant le majeur final seul sur sa dernière ligne. Les anciennes exclusions entre les trois options des lignes 6 et 7 sont retirées dans cette proposition ; le choix historique entre les talents locaux 3 et 4 reste exclusif. La capacité de contenu avant plafond commun est de 53 rangs par arbre, soit 159 pour les trois, contre 51 points disponibles. Il est donc impossible de tout remplir. Les répartitions 31/20 et l’accès au final sans le majeur intermédiaire sont éprouvés par les tests.

## Présentation et compréhension

Les sept lignes sont visibles simultanément. Les noms et effets apparaissent dans l’encart commun quand on survole ou sélectionne une icône, avec le parent requis et son rang maximal. Cela évite de répéter les descriptions sous toutes les cases.

Les nombres à gauche indiquent les seuils 0/5/10/15/20/25/30, avec le détail du palier au survol. Les flèches grises signalent un parent à terminer ; elles deviennent dorées quand ce parent est au maximum. Le statut « Parent à terminer » distingue ce verrou d’un palier fermé, du manque d’XP et du plafond de points. Le clavier peut inspecter tous les talents, y compris verrouillés.

Les tracés contournent les autres icônes. Les symboles sont dessinés dans le projet ; aucune icône ni illustration de World of Warcraft n’est importée. Les [effets, positions et prérequis détaillés](Catalogue_talents_lies_v088.md) sont exportés depuis les données du prototype.

## Sauvegarde et rapports historiques

Le profil passe au schéma 6. Avant conversion, une archive chiffrée `.v087.bak` du schéma 5 est conservée. **PO, XP, nombre de points débloqués, compteurs, résultat et registre de missions déjà récompensées restent intacts.** Une banque dont la répartition respecte déjà les nouveaux liens garde ses investissements.

Si une ancienne répartition enfreint un nouveau lien, ses talents sont réinitialisés gratuitement et tous ses points restent disponibles pour les répartir à nouveau. Le joueur en est informé ; aucune PO, XP ou mission récompensée n’est perdue, et la migration ne crée pas un second gain. La banque de l’autre faction est traitée indépendamment et gardée si elle est compatible.

Le module historique des arbres enrichis reste disponible pour relire et rejouer les anciennes configurations. Les nouveaux builds utilisent la validation des liens et les mêmes formules d’effets. Les rapports gardent la configuration fixée au début de leur partie.

## Périmètre conservé

Une seule mission est jouable : le Gué, première victoire à 60 PO et 100 XP par faction. Les victoires suivantes et les défaites ne donnent pas cette récompense. La courbe de référence de 10 000 XP pour 51 points sur cent missions reste provisoire. Le parcours au-delà du Gué, la boutique et l’infini restent à réaliser.

## Validation v0.88

67 suites et **21 838 contrôles Godot**, 16 tests Python et contrats du GDD réussis. Les 177 contrôles de structure vérifient les cellules vides, les dépendances descendantes, les parents maximaux et l’accès 31/20. Les 184 contrôles d’intégration éprouvent les flèches sans traversée d’icône, la visibilité des sept lignes, les verrous au clavier, l’allocation réelle, la migration chiffrée avec restitution et les rejeux anciens/nouveaux.

Le paquet Windows passe **149 lancements et 148 captures**, avec 43 sources comparées. Les deux contrôles de protection, Alliance et Horde, essayent réellement un enfant alors que le palier est ouvert et le parent partiel : refus sans dépense ; ils terminent ensuite le parent, investissent dans l’enfant et retrouvent les rangs après réouverture du profil protégé. Les six arbres et les deux contrôles ont été inspectés visuellement.

Les **40 scénarios historiques** comparés à v0.87 gardent exactement rapports, aléas, événements et dégâts : deux factions, configurations sans talent, à 33 points et trois anciennes répartitions à 51 points, deux graines et deux pas de simulation. Les nouveaux builds sont également joués et leurs rapports rejoués. Cela ne constitue pas un essai humain d’équilibrage du nouveau contenu.

[Régression](essais/v088_regression.json), [comparaison](essais/v088_comparaison_combat.json), [distribution](Distribution_Windows_v088.json). Exemples : [Horde](essais/captures/QA-v088_horde_expanded_tree_0.png), [Alliance](essais/captures/QA-v088_alliance_expanded_tree_1.png), [parent et enfant](essais/captures/QA-v088_alliance_profile_protection.png).
