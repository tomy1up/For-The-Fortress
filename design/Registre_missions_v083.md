# Registre des premières récompenses de mission — v0.83

29 octobre 2026. Fondation technique de la [campagne révisée](Cadrage_campagne_2026-10-29.md), sans fixation des prix, du plafond de points ou du contenu des arbres. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Périmètre livré et limite de raccordement

Le profil contient désormais un registre des missions déjà récompensées dans chaque banque de faction. Le service sait lier à une tentative un identifiant de mission, une récompense configurée et un nombre de vagues, puis enregistrer sa première victoire. Ces paramètres viennent du futur catalogue de missions ; aucun montant de campagne n’est choisi par ce service.

**La mission du Gué jouable utilise encore le versement historique du prototype.** Le registre est prêt et vérifié, mais la campagne, ses montants et son écran de résultat ne sont pas encore raccordés à cette nouvelle voie. La mise à jour ne prétend donc pas supprimer déjà le farm dans la partie actuelle. La voie historique est refusée pour une tentative créée comme mission afin d’éviter de mélanger les deux mécanismes lors du raccordement.

## Transactions et protection

- Commencer une mission ne donne aucune PO.
- La première victoire complète ajoute le montant lié à la tentative et son reçu dans une même sauvegarde.
- Répéter ce résultat ou gagner à nouveau la mission, même après relancement ou changement de barème, n’ajoute rien.
- Une défaite ne donne rien et ne marque pas la mission comme déjà récompensée.
- La même mission peut être suivie indépendamment dans les deux banques, sans transfert de ressources ni points entre factions. La règle de déverrouillage commercial du parcours reste à définir.
- Un résultat définitivement enregistré est immuable ; les tentatives périmées, mauvais camps ou victoires incomplètes sont refusés.
- Une écriture impossible ou un solde hors limites n’ajoute ni reçu ni ressources en mémoire ; la transaction peut être retentée.

Le chiffrement et l’intégrité Windows CurrentUser restent ceux du profil existant. Le format évolue vers le schéma 3. Un ancien schéma 2 est archivé, chiffré, dans une copie `.v082.bak`, puis migré en gardant ressources, points, rangs, compteurs et ancien reçu de partie. Le registre commence vide : les anciennes parties n’identifiaient pas les missions et ne prouvent donc pas une récompense déjà reçue pour une mission donnée. La migration historique du schéma 1 reste prise en charge, avec son archive et restitution des points selon sa règle existante. Aucun ancien JSON non protégé n’est importé automatiquement.

## Budget des talents, sans barème figé

Un calcul pur répartit un budget fourni entre un nombre de missions, par défaut cent, en entiers et sans perte d’arrondi. Cette répartition régulière est une possibilité de calcul, pas une courbe de récompenses approuvée. Aucun lien avec les cinq talents par arbre, les 36 points ou le prix de 10 n’est figé dans ce calcul.

La contrainte de conception est de couvrir le coût du maximum de points autorisés avec les premières victoires des cent premières missions. Ce maximum ne doit pas permettre de remplir les trois arbres enrichis. [Orientation des talents](Orientation_talents_2026-10-29.md). Le financement des respécialisations reste ouvert ; aucune source de farm ou gratuité n’est ajoutée.

## Validation

60 suites et 18 671 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 56 nouveaux contrôles vérifient budgets entiers, identifiants, premier crédit, tentative rejouée, résultat immuable, défaite, deux factions, autre nombre de vagues configuré, migration chiffrée sans perte, reprise dans un autre processus, échec d’écriture, secours cohérent et dépassement de capacité. Les montants utilisés sont des fixtures de test, pas le barème du jeu.

Le paquet Windows passe 136 lancements et produit 135 captures ; ses 39 sources sont comparées au projet. Le contrôle natif migre un profil chiffré de schéma 2, le rouvre sans cache, crédite une mission de test et vérifie qu’une nouvelle tentative ne redonne pas sa récompense. Le profil réel n’est jamais chargé pendant ces tests. [Régression](essais/v083_regression.json), [distribution](Distribution_Windows_v083.json) et [capture du profil de contrôle](essais/captures/QA-v083_profile_protection.png).

Les sources du combat, des talents, des vagues, des illustrations et du chiffrement conservent les empreintes v0.82. Seuls le profil, les paramètres de version/export, l’interface de contrôle et le nouveau service de préparation des missions évoluent. Essais graphiques sur l’écran de droite ; aucun nouvel essai humain d’équilibrage. L’économie jouable conserve encore ses versements historiques jusqu’au raccordement de la campagne.
