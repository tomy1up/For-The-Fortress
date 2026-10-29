# Talents et financement — orientation du 29 octobre 2026

Complément à la [feuille de route](Feuille_de_route_long_terme.md). Les principes ci-dessous sont explicitement demandés par le porteur du projet ; aucun plafond ni contenu commercial détaillé n’est réputé approuvé. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Décisions acquises

- Trois arbres par faction, chacun nettement plus fourni que dans le prototype.
- Une réserve de points de la faction à répartir entre ces trois arbres, avec un plafond qui ne permet pas de remplir l’ensemble de leurs talents.
- Des choix stratégiques pour construire son style : le maximum de points achetés ne doit pas effacer ces choix.
- Progression verticale par paliers investis dans l’arbre concerné et respécialisation payante, croissante puis plafonnée ; séparation Alliance/Horde conservée.
- Le cumul des PO des premières victoires des missions 1 à 100 doit financer l’achat du maximum de points autorisés. Nombre maximal et prix d’acquisition des points restent à confirmer.

« Tous les points achetables » et « tous les talents de tous les arbres » désignent donc deux ensembles différents. Atteindre la mission 100 avec le capital prévu permet d’achever la progression du nombre de points, pas de rendre toutes les configurations actives simultanément.

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

**Contrainte acquise : somme de r(1) à r(100) ≥ somme de c(1) à c(P).** Si le prix est fixe, le coût total devient P × prix. Aucun de ces paramètres n’est fixé par le présent document.

La répartition du total entre missions peut ensuite être calculée sans perte d’arrondi. Une répartition régulière entière est une possibilité technique, sans adoption d’une courbe de récompense. Les montants déjà versés devront être conservés si les paramètres sont révisés.

La respécialisation payante consomme aussi des PO. Un budget couvrant exactement les points ne garantit plus leur financement si une partie est dépensée ailleurs. Il faut donc préciser sa source de financement, une marge de récompenses ou une autre règle validée. Une quantité finie de PO ne peut pas financer un nombre illimité de respécialisations payantes ; aucun nouveau farm ni reset gratuit n’est supposé pour résoudre ce point.

## Réalisation et vérification futures

Les tests devront vérifier le plafond commun, les paliers, les incompatibilités, l’absence de configuration remplissant tout, les styles hybrides et les migrations des profils. L’enrichissement des arbres ne doit ni effacer les ressources ni perdre les points déjà acquis ; les modalités de conversion devront être définies avant le changement de format des rangs.
