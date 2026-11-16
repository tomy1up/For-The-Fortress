# Horde : squelette jouable (piste O-021)

> **Archive (15 novembre 2026).** Le porteur a fixé la boutique à 20 unités par faction : le Fantassin squelette et le Tirailleur gnome sont retirés en v0.217 (MAJ-49 du GDD). Cette fiche garde l'historique de l'essai.


**Statut : cadrage de conception, rien n'est implémenté. Toutes les valeurs et propositions sont des réglages de prototype à confirmer.**

## Décisions du porteur (15 novembre 2026)

- Le squelette est une **unité de boutique** de la Horde (une alternative achetable, déblocage par mission), pas une unité de départ ni une mécanique de réanimation.
- On commence par **un seul squelette**, sans race complète, sans arbre de talents ni campagne dédiés.
- **Rôle retenu : option A, fantassin d'os** (défense très bon marché, portée courte, cadence élevée, sans règle nouvelle). Décision du porteur, 15 novembre 2026. Stats de départ proposées (prototype à confirmer) : prix 40, dégâts 6, intervalle 0,6 s, portée 2,0 ; à régler avec `prototype/tools/balance_shop.gd`.
- Rappel de la piste d'origine (14 novembre 2026) : un squelette dans l'esprit de l'infanterie attaquante morte-vivante ; le servant squelette de la Baliste de guerre en est un premier aperçu visuel.

> Mise à jour du 15 novembre 2026 : le porteur exige le même nombre d'unités des deux côtés ; l'Alliance reçoit un Tirailleur gnome (type 47) en v0.208, ce qui règle la question de la parité ci-dessous.

## Ce que cela implique (constats, pas décisions)

- Le catalogue de la Horde compte déjà 20 alternatives (types 8, 9, 16 à 21, 26 à 29, 33 à 36, 41 à 45 côté Horde). Un squelette serait la **21e** et le **type 46** : la parité de 20 unités par faction (décision du 13 novembre) serait rompue au profit de la Horde, sauf si l'Alliance reçoit une 21e unité ou si le squelette en remplace une.
- Le barème de prix ne prévoit pas de 21e palier (le dernier est 1 300 PO, mission 180). Un squelette placé au milieu de la liste décalerait les déblocages ; placé après la 180, il faudrait un palier à 1 350 PO et un déblocage à la mission 190 (à confirmer).
- Le visuel revient à Codex (voir `TODO_VISUELS.md`) ; le code et l'équilibrage reviennent à Claude Code, avec la méthode de `design/Equilibrage_*` (seuil du PV ennemi maximal battu).

## Trois rôles possibles pour le squelette (à choisir par le porteur)

Aucun n'est retenu. Les trois utilisent des règles déjà présentes dans le moteur ou une seule règle nouvelle.

| Option | Rôle | Compromis | Règle |
| --- | --- | --- | --- |
| A. Fantassin d'os | Défense très bon marché, portée courte, cadence élevée | Fragile et sans effet : portée 2,0 | Aucune nouvelle règle (stats seules) |
| B. Légion qui revient | Revient après la vague : ses dégâts augmentent chaque vague survivée, mais il démarre faible | Faible au début (voisin du Chef de guerre vétéran) | Réutilise l'effet « aguerri » du type 45 |
| C. Os brisés | Frappes qui laissent des éclats : chaque ennemi touché subit des dégâts supplémentaires de zone à sa mort | Dégâts propres très faibles | Réutilise l'effet « volatile » du type 44 |

Recommandation technique (hors direction) : **A** si l'on veut tester l'idée avec le moins de risque pour l'équilibre ; B et C ressemblent à des unités déjà présentes (45 et 44) et brouilleraient l'identité du squelette.

## Questions ouvertes pour le porteur

1. Option A, B ou C, ou autre rôle ?
2. Parité 20/20 : ajouter une 21e unité à l'Alliance, ou remplacer une alternative de la Horde ?
3. Nom : « Fantassin squelette » est un nom de travail, à confirmer.
4. Le squelette se débloque-t-il à la mission 190 (nouveau palier à 1 350 PO) ou plus tôt ?
