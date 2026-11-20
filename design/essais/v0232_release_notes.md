# Prototype v0.232 — 36 bonus, quatre choix par partie, rééquilibrage des PV d'ennemis

Les noms, valeurs, le rythme des choix et les coefficients de PV sont des réglages de prototype à confirmer en partie réelle.

## Bonus

- **36 bonus au lieu de 12** : 24 nouveaux bonus (R-13 à R-36) de trois familles, demandées par le porteur :
  - **rôle** : unités rapides, lentes, de longue ou courte portée, à effets de groupe, à dégâts sur la durée ou de soutien (R-13 à R-19) ;
  - **contrepartie** : un gain fort payé par une perte (Pari risqué, Cadence effrénée, Tir tendu, Marché noir, Forteresse blindée, Élite sacrifiée ; R-20 à R-25) ;
  - **situation et synergie** : disposition, diversité de l'armée, moment de la route, type ou état de l'ennemi, butin (R-26 à R-36).
- **Quatre choix par partie**, après les vagues 2, 4, 6 et 8 (au lieu de trois, après les vagues 3, 6 et 9). Le panneau affiche « Bonus acquis · n/4 ».
- Les rôles se lisent sur les valeurs de base de chaque unité : une unité de boutique en bénéficie selon ses propres valeurs.
- Les rapports des versions antérieures se rejouent avec l'ancien tirage (douze bonus, trois choix).
- Fiche : `design/Bonus_catalogue_v0232.md`.

## Rééquilibrage des PV d'ennemis

- **Cible du porteur (20 novembre 2026)** : la meilleure composition d'une mission doit finir avec 40 à 70 % de ses PV de forteresse.
- Les PV d'ennemis de chaque mission sont multipliés par un coefficient propre à la mission et à la faction (100 à 150 %), mesuré sur les 200 missions. Aucun coefficient n'allège une mission. La fiche de mission affiche les PV réellement joués.
- Vérification sur 36 000 parties (200 missions, deux factions, 30 compositions, trois tirages de bonus) :
  - meilleure marge moyenne : 64 % pour l'Alliance, 66 % pour la Horde (avant : 100 % sur presque toutes les missions) ;
  - plus aucune mission gagnée à 100 % par l'Alliance, deux pour la Horde ;
  - la meilleure marge varie de 37 points en moyenne selon le tirage des bonus : le choix des bonus pèse sur l'issue ;
  - toutes compositions confondues, 17 % de victoires pour l'Alliance et 14 % pour la Horde : une armée mal choisie perd plus souvent.
- Écarts restants : le chapitre 13 de la Horde reste facile (93 % de marge), le chapitre 4 de la Horde difficile (42 %).
- La limite de validité des PV d'ennemis passe de 264 à 400 %.
- Fiche : `design/Rebalancage_bonus_v0232.md`.

## Contrôles

- Régression complète : 143 suites sur 143, 179 190 contrôles Godot et 17 tests Python.
- Les suites de campagne jouent avec le choix de bonus de référence (première offre sans contrepartie) au lieu de la première offre.
- Outil d'étude `tools/faction_study.gd` : graine (`SEED`), anciennes règles (`LEGACY`), politique de choix (`POLICY`), liste de missions (`MISSIONS`), multiplicateur de PV (`HPMUL`) et composition de référence seule (`REFONLY`).

## GDD

GDD 0.69 : sections 8, 26, 27 et 62, registre (MAJ-68, MAJ-69, DEC-008), questions ouvertes (O-027 mis à jour, O-028 ouvert), journal des versions.
