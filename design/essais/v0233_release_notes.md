# Prototype v0.233 — Bonus rares et épiques, rareté des offres, relance

Second lot du catalogue de bonus, décidé par le porteur le 21 novembre 2026. Noms, valeurs et pondérations sont des réglages de prototype à confirmer ; l'équilibrage suivra.

## Bonus

- **60 bonus** : les 36 de la v0.232 (communs) et 24 nouveaux, **16 rares et 8 épiques**, aux effets uniques :
  - **or** : Trésor de guerre (+100 or), Intérêts (+10 % de l'or à chaque vague gagnée), Prime de guerre (+2 or par élimination), Fortune royale (+150 or et prix −20 %) ;
  - **forteresse** : Réparations (+2 PV par vague gagnée), Herse (premier passage de chaque vague sans dégât), Dernier souffle (évite une défaite une fois par partie), Forteresse imprenable (+12 PV et soin complet) ;
  - **armée** : Promotion (niveau 1 → 2 gratuit), Ascension (niveaux 1-2 → 3 gratuit), Lames runiques, Armée d'élite, Tir de couverture, Écho des ricochets, Pluie de feu, Malédiction tenace ;
  - **combat** : Chausse-trappes et Temps suspendu (ennemis ralentis à l'entrée), Exécution (achève sous 10 % des PV), Tueur de géants, Marque du chasseur, Rage du désespoir, Frénésie sanguinaire, Levée en masse (prix −30 %).
- **Rareté des offres** : chaque carte tire sa rareté, puis un bonus. Environ 70 % de communs, 25 % de rares et 5 % d'épiques, avec plus de rares et d'épiques en fin de partie (2 % d'épiques au premier choix, 10 % au quatrième).
- Les cartes rares et épiques portent une étiquette et un nom colorés (rare en bleu, épique en violet).
- **Relance** : une fois par partie, gratuitement, le bouton « Relancer les offres » remplace les trois offres par trois autres. Elle est inscrite au journal et au rapport de partie.
- Les rapports des versions antérieures se rejouent avec leur ancien tirage.
- Fiche : `design/Bonus_rarete_relance_v0233.md`.

## Ce que le second lot change à la difficulté

Mesure sur 36 000 parties (200 missions, deux factions, 30 compositions, trois tirages, choix de la première offre) :
- meilleure marge moyenne de l'Alliance : 68,5 % (63,6 % en v0.232) ;
- **meilleure marge moyenne de la Horde : 85,5 % (66,3 % en v0.232)**, 19 missions de nouveau gagnées à 100 % ;
- plusieurs rares et épiques renforcent surtout les unités à effet de zone et à dégâts sur la durée, majoritaires dans l'armée de base de la Horde.

L'équilibrage avec les nouveaux bonus est la prochaine étape (O-028). En attendant, trois coefficients de PV d'ennemis ont été abaissés pour que les suites de campagne passent : mission 3 de l'Alliance (116 %), missions 23 et 177 de la Horde (103 et 128 %).

## Corrections

- Libellés d'effet raccourcis pour tenir sur deux lignes dans les cartes (dont « Sortilèges durables », « Cadence effrénée » et « Prime de butin »).
- L'aperçu « Voir les détails » montre l'or gagné, les niveaux promus, les nouveaux prix et la forteresse après le choix ; il reste exact quand un bonus de forteresse change le gain de « Rage du désespoir ».

## Contrôles

- Nouvelle suite `test_bonus_rarity.gd` (402 contrôles) : raretés, fréquences du tirage par rang, anciennes règles, relance, effets des 24 bonus, partie complète avec relance rejouée.
- Outil d'étude : `V232=1` rejoue avec les règles de la v0.232.
