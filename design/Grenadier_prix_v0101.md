# Grenadier — coût de recrutement v0.101

Le recrutement du grenadier passe de **90 à 75 or de combat**, comme celui du sapeur. Son déblocage permanent reste à **240 PO**. Ce réglage de prototype demeure une **hypothèse d’équilibrage**, pas une valeur définitive validée par des essais humains.

Le grenadier conserve ses dégâts, sa cadence, sa portée de 2,7, son rayon d’explosion et ses deux spécialisations. Son intérêt reste de toucher davantage de voisins avec des explosions fréquentes, contre un impact et une portée inférieurs à ceux du sapeur. Aucun point de talent ni PO n’est remboursé ou dépensé par cette mise à jour.

## Comparaison d’un paramètre à la fois

Trois copies isolées du jeu v0.100 ont été testées : référence, prix de recrutement à 75 uniquement, portée à 3 uniquement. Le projet publié n’a pas été modifié pendant les essais. Les données couvrent 7 776 simulations principales et 429 786 contrôles sans anomalie. La référence reproduit exactement les 1 296 paires du grenadier présentes dans les études antérieures, y compris le renfort prioritaire. Tous les défenseurs témoins restent identiques entre variantes.

| Réglage du grenadier | Ouverture : victoires / 432 | Renfort : victoires / 432 | Renfort prioritaire : victoires / 432 |
|---|---:|---:|---:|
| Référence : 90 or, portée 2,7 | 150 | 181 | 133 |
| Prix seul : 75 or, portée 2,7 | 298 | 176 | 160 |
| Portée seule : 90 or, portée 3 | 170 | 186 | 141 |
| Défenseur témoin : sapeur | 345 | 194 | 174 |

Ces colonnes décrivent des politiques fixes, pas le taux de victoire des joueurs. Le prix à 75 permet de recruter le grenadier dans davantage de cas de renfort : les achats manquants passent de 140 à 76 sur 432. En renfort prioritaire, ils passent de 154 à 76, et la spécialisation est atteinte dans 164 cas au lieu de 144.

Le recrutement moins cher ne donne pas une supériorité générale : dans le renfort ordinaire, il transforme 18 anciennes défaites en victoires, mais 23 anciennes victoires en défaites. L’argent dépensé plus tôt peut retarder les autres améliorations. Face au sapeur, la variante à 75 or conserve des résultats favorables et défavorables selon la situation.

Le fort gain en ouverture dépend notamment du calendrier d’investissement testé : une amélioration du premier défenseur n’est tentée qu’avant la vague 2, puis les améliorations générales reprennent à partir de la vague 5. Il ne démontre pas que le joueur serait incapable de réussir avec l’ancien prix en adaptant ses achats. Ce biais et les limites de placement interdisent de traiter les nombres comme un équilibrage final.

## Choix de prototype

Retenir uniquement la réduction de prix rend le rôle de renfort plus accessible, sans lui donner les dégâts ou la portée du sapeur. L’augmentation de portée n’est pas cumulée avec cette réduction. Le tarif permanent de 240 PO et la progression par XP sont indépendants de cet essai.

Les premiers essais réels devront confirmer la lecture du compromis, l’intérêt contre les groupes serrés et le coût d’opportunité des améliorations. La prochaine itération pourra aussi comparer un calendrier qui retente l’amélioration initiale avant les vagues 3 et 4.

## Rapports historiques

Les nouveaux rapports enregistrent le coût de base de l’alternative choisie. Le vérificateur de rapports utilise cette valeur avant les réductions de recrutement. Pour les premiers rapports sans ce champ, le prix de 90 or du grenadier est reconnu pour les versions 0.99, 0.99.1 et 0.100.

Deux rapports ont été capturés et rejoués avant le changement, dont un avec un recrutement réduit à 81 or. Ils servent de référence pour vérifier le paiement, la réduction et les résultats historiques après l’ajustement. Le réglage historique appartient au simulateur de diagnostic ; il n’est pas chargé depuis la progression du joueur.

## Reproduction des essais isolés

[Générateur](../prototype/tests/survey_grenadier_variants.gd), [copies et exécution](../prototype/tests/compare_grenadier_variants.py), [analyse](../prototype/tests/analyse_grenadier_variants.py). La source de référence et les changements exacts sont identifiés par leurs empreintes dans le [manifeste](essais/grenadier_variantes_v0100_manifest.json). Utiliser cette source expérimentale pour reproduire les chiffres ; le modèle publié à partir de v0.101 a volontairement un autre prix.

[Résumé](essais/grenadier_variantes_v0100_resume.json), [référence](essais/grenadier_reference_v0100_releves.json.gz), [prix à 75](essais/grenadier_prix_75_v0100_releves.json.gz), [portée à 3](essais/grenadier_portee_3_v0100_releves.json.gz).

Chaque copie passe aussi douze scénarios rapides avec comparaison à petits et grands pas et vérification des rapports. Les 7 776 parties principales ne sont pas toutes rejouées individuellement. Les sauvegardes joueur ne sont ni ouvertes ni modifiées par ces outils.

For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Validation de livraison

Les **85 suites** passent **33 103 contrôles Godot** et **16 tests Python**. Les 39 contrôles dédiés au prix couvrent notamment les rapports historiques, le tarif réduit, le remboursement et le rejet de paramètres invalides. Le paquet Windows passe les **243 cas**, produit **242 captures** et compare **56 sources**. Ces captures ne sont pas toutes inspectées visuellement.

Dix vues supplémentaires sont produites depuis les ressources du paquet avec le moteur complet, sur l’écran de droite. La boutique Horde, l’aperçu du grenadier et le mousquetaire sombre ont été examinés : recrutement à 75 or, déblocage à 240 PO et teinte sombre conservée. Les clics d’achat, de sélection et de recrutement des deux secondes unités de boutique passent 24 contrôles sur ces ressources ; ce test utilise le moteur complet, tandis que les 243 cas précédents exécutent le programme Windows exporté.

[Distribution et périmètre des vérifications](Distribution_Windows_v0101.json), [régression](essais/v0101_regression.json), [aperçu du grenadier](essais/captures/QA-v0101_preview_9.png).
