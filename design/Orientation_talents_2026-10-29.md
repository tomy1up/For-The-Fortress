# Talents et financement — orientation du 29 octobre 2026

Complément à la [feuille de route](Feuille_de_route_long_terme.md). Les principes ci-dessous sont explicitement demandés par le porteur du projet ; le plafond de prototype demandé est désormais de 51 points ; le contenu commercial détaillé reste ouvert. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Décisions acquises

- Trois arbres par faction, chacun nettement plus fourni que dans le prototype.
- Une réserve de points de la faction à répartir entre ces trois arbres, avec un plafond qui ne permet pas de remplir l’ensemble de leurs talents.
- Des choix stratégiques pour construire son style : le maximum de points achetés ne doit pas effacer ces choix.
- Progression verticale par paliers investis dans l’arbre concerné ; séparation Alliance/Horde conservée. Le reset est désormais gratuit entre les missions, décision validée à la fin de cet échange ; il ne débite pas les PO et ne permet pas de changer de talents pendant la mission.
- Le cumul des PO des premières victoires des missions 1 à 100 doit permettre d’acheter le maximum de points autorisés lorsque ces gains sont consacrés aux points. Les dépenses en boutique ou autres achats peuvent retarder cet objectif. Chaque mission ultérieure continue de donner des PO à sa première victoire. Le maximum de prototype est fixé à 51 ; le prix d’acquisition reste à confirmer.

« Tous les points achetables » et « tous les talents de tous les arbres » désignent donc deux ensembles différents. Atteindre la mission 100 avec le capital prévu et sans autres dépenses permet d’acheter le plafond de points, sans rendre tous les talents actifs simultanément. Dépenser en boutique peut repousser cet achat maximal après la mission 100.

## Constat vérifié du prototype v0.82

Chaque arbre comporte cinq talents : rangs maximum 5, 3, 3, 1, 1, avec les deux derniers exclusifs. La capacité légale est donc de 12 points par arbre, soit 36 pour les trois. Le plafond actuel de 36 permet de saturer les trois arbres en choisissant une des deux fins dans chacun. Ce contenu ne répond pas encore au besoin d’arbitrages durables désormais exprimé.

Il ne suffit donc pas de conserver ce plafond et ce contenu en changeant les textes de présentation. Il faudra enrichir les arbres, puis choisir un budget de points qui laisse des talents accessibles à abandonner dans chaque configuration. Les valeurs 36 points, 10 ressources par point et 360 au total décrivent seulement l’état actuel, sans engagement sur la version cible.

## Cadre de conception proposé, à détailler

| Travail | Résultat attendu |
| --- | --- |
| Définir la promesse des trois arbres | Plusieurs styles cohérents dans chaque faction, avec des combinaisons hybrides compréhensibles |
| Dessiner les lignes et talents | Davantage de choix que le budget de points disponible, pas seulement davantage de rangs du même bonus |
| Distinguer profondeur et répartition | Donner un intérêt aux investissements profonds et aux compromis entre plusieurs arbres |
| Fixer le plafond | Un plafond partagé entre les trois arbres, inférieur à leur capacité légale cumulée et vérifié sur des configurations réelles |
| Définir effets et coûts | Effets lisibles, cohérents avec la faction ; valeurs chiffrées traitées comme hypothèses d’équilibrage |
| Éprouver plusieurs configurations | Vérifier qu’un arbre n’est pas incontournable et qu’une configuration ne domine pas tous les contextes |

Les noms, effets nouveaux, prérequis précis et quantités de talents seront des propositions à examiner avant leur intégration. Aucun nouvel ennemi, défenseur, sort actif ou type de ressource n’est déduit automatiquement de cet enrichissement.

## Budget paramétrable des cent premières missions

Notations : P est le plafond de points autorisés ; c(k) est le prix du k-ième point ; r(m) est la récompense de première victoire de la mission m.

**Contrainte acquise, sans dépenses autres que les points : somme de r(1) à r(100) ≥ somme de c(1) à c(P).** Si le prix est fixe, le coût total devient P × prix. Le plafond de prototype est désormais P = 51 ; le prix et les récompenses restent des hypothèses.

La répartition du total entre missions peut ensuite être calculée sans perte d’arrondi. Une répartition régulière entière est une possibilité technique, sans adoption d’une courbe de récompense. Les montants déjà versés devront être conservés si les paramètres sont révisés.

La boutique peut aussi consommer des PO ; la respécialisation est gratuite. Le repère de la mission 100 n’impose pas de garantir l’achat maximal après ces dépenses : le porteur du projet les exclut explicitement de cette référence. Les premières victoires suivantes apportent encore des PO. Aucun arrêt des gains à la mission 100, réserve obligatoire de monnaie pour les talents ou remboursement automatique n’est approuvé.

Le vrai critère d’équilibrage est la viabilité des chemins d’achat : un retard dans les points peut être un choix, une impasse irréversible ne doit pas l’être. Cette viabilité doit être éprouvée avec la difficulté des missions et les stratégies ouvertes par les unités de boutique, sans considérer qu’un budget global suffit à prouver l’absence de blocage. Voir le [cadre économique](Economie_campagne_2026-10-29.md).

## Réalisation et vérification futures

Les tests devront vérifier le plafond commun, les paliers, les incompatibilités, l’absence de configuration remplissant tout, les styles hybrides et les migrations des profils. L’enrichissement des arbres ne doit ni effacer les ressources ni perdre les points déjà acquis ; les modalités de conversion devront être définies avant le changement de format des rangs.

## Prototype v0.85 et proposition économique

Le [catalogue enrichi](Proposition_talents_enrichis_2026-10-29.md) est raccordé au jeu : **21 talents par arbre, sept lignes, 51 points partagés**. Les seuils sont 0/5/10/15/20/25/30 points dans les lignes précédentes du même arbre. Deux talents majeurs facultatifs sont accessibles après 15 et 30 points investis : ils peuvent recevoir respectivement le 16e et le 31e point. La dernière ligne ne demande donc pas 35 points pour son premier achat. Une répartition 31/20 ou 19/16/16 est possible. Voir la [réalisation v0.85](Arbres_enrichis_v085.md).

La capture de World of Warcraft sert de référence d’organisation : trois colonnes, progression descendante, compteurs de rang, états visuels et talents majeurs identifiables. Les illustrations et icônes du jeu de référence ne sont pas utilisées comme ressources du projet. Les flèches de notre prototype indiquent le franchissement des paliers ; aucun prérequis individuel supplémentaire n’est déduit de la capture.

**Hypothèse économique, non activée :** avec le prix provisoire constant de 10 PO par point, les 51 points coûtent 510 PO. Un exemple de barème serait 5 PO par première victoire et 1 PO supplémentaire aux missions 10, 20, ..., 100 : 100 × 5 + 10 × 1 = 510 PO. Ce n’est pas un barème final approuvé ; la campagne n’est pas encore réalisée. Le joueur qui dépense en boutique peut atteindre le maximum plus tard, grâce aux premières victoires suivantes.
