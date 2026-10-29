# Arbres enrichis — prototype v0.85

29 octobre 2026. For the Fortress! est un nom de travail, disponibilité juridique à confirmer.

## Décisions et hypothèses

Le porteur du projet demande un plafond de prototype de **51 points par faction**, répartis entre trois arbres, et deux talents majeurs facultatifs par arbre après 15 et 30 points investis. Le reset est gratuit entre les missions ; les talents restent fixés pendant une mission. Les réserves, points et effets restent séparés entre factions.

Le prototype propose 21 talents par arbre (63 par faction), sept lignes et des seuils de 0, 5, 10, 15, 20, 25 et 30 points dans les lignes précédentes de cet arbre. Le talent majeur final peut recevoir le 31e point ; une répartition 31/20 conserve un appui dans un autre arbre. Un hybride 19/16/16 est également possible. Les deux majeurs de chaque arbre sont signalés par une étoile. Le majeur intermédiaire n’est pas un prérequis du majeur final.

Les noms, effets, valeurs, exclusions et 21 talents sont des **hypothèses de contenu et d’équilibrage**, intégrées pour les éprouver. Chaque arbre offre 43 rangs légalement investissables avant plafond commun, soit 129 sur les trois : 51 points ne permettent pas de tout remplir. Les trois choix des lignes 6 et 7 sont exclusifs dans leur ligne ; les alternatives à trois rangs peuvent être améliorées jusqu’au troisième rang.

## Présentation et consultation

Trois colonnes indépendantes avec défilement vertical, noms, rangs acquis/maximaux, paliers ouverts ou verrouillés, états d’achat et étoiles des majeurs. La sélection affiche les effets et le gain du prochain rang dans un encart commun. Le clavier peut atteindre les talents profonds ; icône et nom sont ramenés dans la zone visible. Le bilan propose aussi un défilement pour consulter tous les talents actifs d’un arbre.

La référence World of Warcraft guide l’organisation générale. Les symboles du prototype sont dessinés dans le projet ; aucune illustration ni icône de la capture n’est réutilisée. Il n’y a pas de prérequis individuel entre deux talents au-delà des seuils de ligne et exclusions explicitement indiqués.

## Progression et compatibilité

Le profil passe au schéma 4. Les profils publiés v0.84 (schéma 3, quinze talents) gardent leurs PO, points achetés, investissements, compteurs historiques, reçu de tentative et registre des missions déjà récompensées. Les quinze identifiants historiques restent stables ; leurs effets sont conservés. Une archive chiffrée `.v084.bak` précède la migration. Les migrations des schémas 1 et 2 restent prises en charge. Le format inédit de brouillon à 54 talents n’a jamais été publié dans un profil jouable.

Les rapports des formats historiques restent lisibles et rejouables. Les rapports enrichis conservent la configuration complète de 63 talents. Le plafond de 51 points s’applique même si un profil possède davantage de ressources. La protection locale et le dossier de sauvegarde du joueur restent ceux des versions précédentes.

## Économie à préparer

Le prix de 10 PO par point reste provisoire : à prix constant, 51 points demandent **510 PO**. Exemple de répartition à valider : 5 PO par première victoire des missions 1–100, plus 1 aux dix missions multiples de 10. Les achats de boutique sont exclus de la référence de financement à 100 missions. Les premières victoires suivantes continuent à apporter des PO. Le reset gratuit ne consomme pas cette réserve.

**Ce barème n’est pas activé.** Le Gué conserve son économie historique de fin de partie ; les missions de campagne et la boutique restent à développer. Les montants et la difficulté doivent être évalués ensemble avant de prétendre éviter les impasses ou garantir l’équilibrage.

Le [catalogue détaillé](Proposition_talents_enrichis_2026-10-29.md) liste les effets par rang pour les deux factions.

## Validation

63 suites, **19 538 contrôles Godot**, 16 tests Python et contrats du GDD réussis. Les 557 contrôles de définition couvrent les seuils, 31/20 et 19/16/16, le caractère facultatif des majeurs et les exclusions à plusieurs rangs. Les 146 contrôles d’intégration éprouvent dix-huit parties et leurs rejeux, la migration chiffrée réelle du schéma 3, les reçus conservés, le relancement, la navigation profonde au clavier et tous les talents actifs du bilan.

Les seize scénarios historiques comparés à v0.84 gardent exactement rapports, états aléatoires, événements et dégâts pour les mêmes configurations. Ces contrôles de compatibilité ne prouvent pas l’équilibrage humain des nouveaux builds à 51 points.

Le paquet Windows passe **146 lancements et 145 captures**, avec 41 sources comparées. Les six arbres profonds et les deux bilans ont été inspectés visuellement. Profils de test isolés, lancements sur l’écran de droite. [Régression](essais/v085_regression.json), [comparaison](essais/v085_comparaison_combat.json), [distribution](Distribution_Windows_v085.json).

Exemples : [Alliance — Maîtrise du tir](essais/captures/QA-v085_alliance_expanded_tree_1.png), [Horde — Voie des maléfices](essais/captures/QA-v085_horde_expanded_tree_1.png), [bilan Alliance](essais/captures/QA-v085_alliance_expanded_summary.png).
