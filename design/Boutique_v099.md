# Boutique et familles de talents — prototype v0.99

État : intégration vérifiée, prototype à éprouver en jeu. Les noms, prix, statistiques et spécialisations ci-dessous sont des **hypothèses d’équilibrage**, pas des décisions définitives.

## Décisions validées

- Trois types habituels plus **un seul type supplémentaire**, choisi parmi les alternatives achetées avant le départ. Ce choix reste fixe pendant toute la mission.
- Déblocages permanents payés en PO de la faction ; recrutement et améliorations payés en or de combat.
- Talents partagés par famille, bénéficiaires nommés dans la description et l’aperçu du prochain rang. Aucun transfert entre factions.
- XP et points de talents indépendants des achats en boutique. Réinitialisation des talents gratuite entre missions.

## Premier catalogue proposé

| Faction | Alternative | Famille | Déblocage PO | Recrutement | Dégâts directs | Intervalle | Portée |
|---|---|---|---:|---:|---:|---:|---:|
| Alliance | Rôdeur elfe | Archer elfe | 180 | 60 | 6 | 0,7 s | 3,5 |
| Alliance | Mousquetaire nain | Arbalétrier nain | 240 | 90 | 38 | 4 s | 6 |
| Horde | Traqueur troll | Lanceur de haches troll | 180 | 65 | 10 | 1,25 s | 4 |
| Horde | Grenadier gobelin | Sapeur gobelin | 240 | 90 | 18 | 2 s | 2,7 |

Traqueur : un rebond de 4 dégâts, distance inférieure à 1. Grenadier : explosion de 6 dégâts, jusqu’à quatre autres ennemis, rayon 1,15. Les limites et distances suivent les règles de résolution existantes. Le rôdeur se distingue de l’attaquant « Éclaireur elfe », qui conserve son identité.

Le rôdeur tire plus vite mais moins loin ; le mousquetaire gagne en portée avec un rechargement lent ; le traqueur gagne en cadence avec un rebond plus faible ; le grenadier couvre davantage de voisins avec une portée et des dégâts réduits. Ces compromis demandent des essais en mission avant validation de l’équilibrage.

Les multiplicateurs de niveaux, les coûts d’amélioration et le remboursement à la vente suivent les règles générales. Le nombre d’emplacements reste inchangé. Chaque type garde sa propre limite de deux exemplaires.

### Spécialisations proposées au niveau 4

Valeurs avant bonus et talents ; les paramètres absents restent ceux du niveau 4 non spécialisé.

| Alternative | Branche | Modification |
|---|---|---|
| Rôdeur | Tir fulgurant | Dégâts 29,25 ; intervalle 1 s ; portée 4,5 |
| Rôdeur | Éclaireur de volée | Dégâts 14,625 ; intervalle 0,42 s ; portée 3 |
| Mousquetaire | Tireur de précision | Dégâts 180 ; intervalle 4,8 s ; portée 6 |
| Mousquetaire | Guetteur des crêtes | Dégâts 123,5 ; intervalle 4 s ; portée 7,5 |
| Traqueur | Chasseur de têtes | Impact 42,5 ; rebond 6,5 |
| Traqueur | Pisteur des ricochets | Impact 30 ; rebonds 9,2 ; trois rebonds |
| Grenadier | Bombardier de siège | Impact 78 ; explosion 16,9 |
| Grenadier | Éclats dispersés | Impact 48,75 ; explosion 19,5 ; six voisins ; rayon 1,4 |

Les bonus et synergies de famille concernent aussi l’alternative. Les branches de même indice héritent des conditions de synergies de spécialisation existantes : ce raccord est une proposition de prototype, à tester avec les nouveaux rôles. Une unité et son alternative ne créent pas entre elles une nouvelle synergie de famille.

## Sauvegarde et accès

Le schéma 7 ajoute les déblocages et le choix de chaque faction. Une sauvegarde de schéma 6 est archivée avant conversion ; ses PO, XP, talents et premières victoires sont conservés. Un ancien profil ne reçoit aucun déblocage gratuit. Le format protégé et l’identité du dossier utilisateur restent les mêmes.

L’achat et la sélection doivent être enregistrés avant confirmation à l’écran. Achat en double, fonds insuffisants, mauvais camp, profil indisponible ou mission commencée refusent la transaction. Consulter la boutique ne dépense rien. Acheter ne sélectionne pas automatiquement. « Sans unité supplémentaire » retire le choix sans rembourser le déblocage.

## Questions ouvertes

Prix et statistiques définitifs ; effets des prochaines alternatives ; remboursement éventuel des déblocages ; ergonomie d’un catalogue dépassant deux fiches par faction ; équilibre à long terme avec 51 points. La boutique ne promet pas une victoire ni une unité systématiquement supérieure aux unités de départ.

## Illustrations et provenance

Quatre PNG originaux générés avec l’outil intégré `image_gen`, dans `prototype/assets/units/shop/` : `rodeur_v001.png`, `mousquetaire_v001.png`, `traqueur_v001.png`, `grenadier_v001.png`. Fichiers transparents, cadres et points d’ancrage mesurés ; aucune modification des sprites de base. Références de style : archer et troll déjà présents dans le projet.

Consigne commune : « Single full-body original fantasy tower-defense character sprite. Bold cartoon, thick dark outlines, simple bright cel shading, oversized head, compact chunky silhouette readable at 60px, limited details. Three-quarter front view facing screen right; whole character including boots and weapon inside canvas with clear margins. One character only, no text, no scenery, no ground shadow, actual transparent background. Do not copy any existing branded game character. »

Consignes par sujet : rôdeur elfe aux cheveux auburn, cape turquoise et arc court ; mousquetaire nain barbu en bleu et laiton avec tricorne à plume et mousquet ; traqueur troll turquoise aux cheveux bleu sombre, armure de cuir et deux hachettes ; grenadier gobelin vert à lunettes ambrées, foulard orange, ceinture de grenades et grenade prête à lancer. Une seconde passe a demandé de supprimer le halo du mousquetaire en conservant le personnage.

For the Fortress! est un nom de travail ; disponibilité juridique à confirmer.

## Validation de livraison

82 suites et **32 913 contrôles Godot**, 16 tests Python. Les cinq nouvelles suites couvrent 653 contrôles : transactions et sauvegarde protégée, migration du schéma 6, quatrième type et rapports rejouables, bénéficiaires de talents et bonus, interface et visuels distincts. Les coûts d’équilibrage restent provisoires.

Le paquet Windows passe **243 lancements et 242 captures**, avec **56 sources comparées**. Dix vues supplémentaires sont produites depuis les ressources compilées du paquet : boutiques Alliance/Horde, aperçu avant achat et recrutement de chaque alternative. Les dix vues ont été examinées ; textes, boutons, portée et silhouettes restent lisibles. Un contrôle de vrais clics et de la touche Échap sur ces ressources compilées passe 24 vérifications dans les deux factions, avec profils isolés.

Quarante scénarios sur les dix cartes sans alternative gardent les rapports, états aléatoires, événements et dégâts de v0.98. Dix-huit rapports natifs des missions 2–10 se rejouent et conservent les relevés historiques après normalisation du numéro de version. Ces contrôles ne mesurent pas le taux de victoire humain des alternatives.

[Régression](essais/v099_regression.json), [distribution](Distribution_Windows_v099.json), [combats de référence](essais/v099_comparaison_combat.json), [rejeux](essais/v099_rejeux_natifs.json), [clics sur ressources compilées](essais/v099_clics_ressources_compilees.json). [Boutique Horde](essais/captures/QA-v099_shop_1.png).
