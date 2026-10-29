# XP pour les talents, PO pour la boutique — 29 octobre 2026

For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Décisions du porteur du projet

- Les points de talent sont obtenus grâce à l’expérience gagnée à la première victoire des missions. Rejouer ou perdre ne donne pas cette XP. L’achat de points contre des PO est remplacé.
- Les cent premières missions doivent permettre d’obtenir les 51 points de talent autorisés.
- Les missions 1 à 200 continuent de donner des PO pour acheter des éléments de boutique, dont de nouvelles unités. Les unités ouvrent des styles avec des forces et des faiblesses.
- Chaque faction a son propre parcours, son XP, ses points, ses PO et son déblocage de l’infini. Le reset reste gratuit ; les talents sont fixés pendant la mission.

Cela remplace la contrainte précédente de financement des talents par les PO des cent premières missions. Une dépense de boutique ne doit désormais plus retarder directement l’acquisition d’un point de talent. Les prix de boutique et le barème de PO restent à définir ; aucun remboursement d’achat, conversion libre entre monnaies ou nouveau type d’objet n’est déduit de ce changement.

## Courbe de prototype proposée

Hypothèse simple : **100 XP par mission de référence**, donc **10 000 XP** pour cent missions. Le nombre de points débloqués est `min(51, plancher(51 × XP / 10 000))`. Le seuil exact du point k est `plafond(10 000 × k / 51)` XP ; le calcul entier évite les arrondis anticipés.

| Missions de référence réussies | XP | Points débloqués |
| --- | --- | --- |
| 0 | 0 | 0 |
| 1 | 100 | 0 |
| 2 | 200 | 1 |
| 10 | 1 000 | 5 |
| 25 | 2 500 | 12 |
| 50 | 5 000 | 25 |
| 75 | 7 500 | 38 |
| 99 | 9 900 | 50 |
| 100 | 10 000 | 51 |
| 200 | 20 000 | 51 |

Les nombres 100 XP et 10 000 XP constituent une proposition d’échelle, pas un montant approuvé comme définitif. Aucun niveau de personnage, point au-delà de 51 ou dépense d’XP n’est ajouté. Les points sont débloqués, puis répartis gratuitement entre les trois arbres de leur faction.

## Règle de répétition validée

Le porteur du projet a retenu **l’XP uniquement à la première victoire de la mission**, séparément par faction. Rejouer une mission déjà gagnée ne donne pas son XP une deuxième fois ; une défaite ne déclenche pas le gain. La même règle de première victoire s’applique aux PO de mission.

## Réalisation v0.87

Le module de calcul est testé sur tous les seuils de points et les deux cents missions de référence. La fondation de transaction peut lier une récompense XP à la mission, enregistrer PO, XP et points dans la même écriture, et garder les gains séparés entre factions. La seule mission jouable reste le Gué, identifié `campaign.001` : 60 PO et 100 XP à sa première victoire par faction, zéro à la défaite et aux victoires suivantes. Le montant 60 PO conserve l’ancien total d’une victoire du prototype comme hypothèse pour cette seule mission ; il ne fixe pas les prix ni les récompenses des 199 missions restantes.

Le profil au schéma 5 conserve les anciens points, talents et PO. L’XP de compatibilité correspond au seuil des points déjà acquis ; elle ne fait pas perdre les investissements précédents. Une archive chiffrée du profil v0.86 précède la conversion. Le raccordement au Gué et le bilan de gains sont réalisés. Le prochain seuil, l’XP cumulée et les points à placer sont affichés ; le bouton d’achat de point en PO est retiré et l’ancien service d’achat refuse l’opération sans débit. Le contenu des autres missions, le parcours et la boutique restent à développer.

Le premier point demande 197 XP dans cette courbe, donc deux missions distinctes à 100 XP. Avec le seul Gué disponible, un nouveau profil peut gagner 100 XP mais ne peut pas farmer les 97 XP restantes en le rejouant : il faudra la mission suivante. Ce plafond temporaire du contenu de prototype ne signifie pas que le mode campagne complet est livré.

## Validation v0.87

65 suites et **21 477 contrôles Godot**, 16 tests Python et contrats du GDD réussis. Les 306 contrôles de courbe vérifient tous les seuils des 51 points et la progression sur 200 missions de référence. Les 1 631 contrôles de transaction et d’intégration couvrent les deux factions, le versement unique, les missions à zéro PO, la défaite, le plafond, la migration chiffrée, le relancement et les vrais bilans du Gué.

Le paquet Windows passe **148 lancements et 147 captures**, avec 42 sources comparées. Les deux répétitions de mission dans le binaire compilé confirment zéro gain supplémentaire, après un premier gain de 60 PO et 100 XP. L’XP est également retrouvée dans le profil protégé après réouverture. Les captures des écrans XP et des résultats ont été inspectées sur l’écran de droite avec des profils isolés.

Les seize scénarios historiques de combat restent identiques à v0.86 pour les mêmes configurations de talents. Aucun nouvel essai humain d’équilibrage de la courbe ou de la future campagne.

[Régression](essais/v087_regression.json), [comparaison](essais/v087_comparaison_combat.json), [distribution](Distribution_Windows_v087.json). Exemples : [arbres XP](essais/captures/QA-v087_alliance_talents.png), [première victoire](essais/captures/QA-v087_horde_progression_victory.png), [mission rejouée](essais/captures/QA-v087_horde_progression_repeat.png).
