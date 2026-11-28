# Bonus héroïques renforcés (v0.261)

**Statut.** Suite du lot 4 du cadrage (`Bonus_heroiques_v0260.md`). Le renforcement a été validé par le porteur le 27 novembre 2026 (« Tout valider », sur la proposition de Claude Code). Il répond à la mesure de la v0.260 : avec une carte héroïque qui en remplaçait une ordinaire, ces bonus ne changeaient presque rien à la difficulté. Ce sont des réglages de prototype à confirmer en jeu.

## Ce qui change

### Un choix héroïque en plus

- Aux **vagues 4 et 8**, après le choix ordinaire habituel (trois cartes ordinaires), vient un **second choix entre deux cartes héroïques**.
- Ces cartes sont tirées parmi les bonus héroïques débloqués par le chapitre, pas encore pris et utiles. S'il n'en reste qu'un, une seule carte est proposée ; s'il n'en reste aucun, il n'y a pas de second choix.
- Une partie héroïque compte donc **jusqu'à six bonus** : quatre ordinaires et deux héroïques.
- La relance unique de la partie peut servir à l'un ou l'autre choix. Pendant le second choix, elle tire deux autres cartes héroïques.
- En v0.260, la troisième carte des choix des vagues 4 et 8 devenait héroïque. Cette règle reste en place pour rejouer les rapports de la v0.260.

### Valeurs renforcées

| Bonus | v0.260 | v0.261 |
| --- | --- | --- |
| Chasseur de champions | +60 % contre champions et boss | **+100 %** |
| Prime des champions | +30 or par champion | **+50 or** |
| Forge ardente | +1 niveau par vague gagnée, jusqu'au niveau 3 | inchangé |
| Sceau des anciens | affixe rappelé annulé, rappelés −40 % de PV | **rappelés −60 % de PV, et +15 % à tous les dégâts** |
| Hiver éternel | ennemis −20 % de vitesse | **−30 %** |
| Charges en chaîne | 25 % des PV max, rayon 1,2 | **40 %, rayon 1,5** |
| Héros du rempart | +60 % et +1 de portée au plus avancé | inchangé |
| Doctrine unique | +50 % avec une seule famille | **+80 %** |
| Supériorité numérique | +10 % par défenseur | **+15 % (jusqu'à +90 %)** |
| Perce-armures | +25 % contre les lourds | **+50 %** |
| Muraille vivante | 3 arrivées sans dégâts par vague | **5** |
| Pacte de sang | +60 %, −1 PV max par vague | **+100 %**, même contrepartie |
| Arsenal royal | améliorations −40 % | **−60 %** |
| Fléau | malédictions +50 %, contagion | **+100 %**, contagion |
| Dernier carré | +100 % au-delà de 80 % de la route | **+150 % au-delà de 75 %** |

## Dans le jeu

- Le second choix s'ouvre aussitôt après le choix ordinaire, sous le titre « Choisissez un bonus héroïque », avec deux cartes.
- « Bonus acquis » compte six bonus en Héroïque (« 0/6 ») et quatre en Normal.
- Le récapitulatif des bonus de la partie affiche cinq ou six cartes sur deux rangées de trois. Le bouton « Fermer » passe alors en haut à droite.

## Technique

- **Combat** (`valley_model.gd`) :
  - `rules_v261` ; valeurs `HEROIC_VALUES` (v0.261) et `HEROIC_VALUES_V260`, lues par `hv(clé)` ;
  - `heroic_choice` : second choix ouvert par `choose_bonus` et journalisé comme une offre (`"heroic": true`) ;
  - `_heroic_candidates`, `_draw_heroic_offer` ; relance du second choix dans `reroll_bonus` ;
  - `max_bonuses()`.
- **Rejeu** (`tests/report_replay.gd`) :
  - `rules_v261_for` ;
  - textes de la v0.260 pour les treize bonus renforcés (`BONUS_TEXTS_V260`).
- **Interface** (`main.gd`) : six emplacements de cartes, deux rangées au-delà de quatre bonus, titre du second choix, compteur `max_bonuses()`.
- **Outil d'étude** : la boucle de choix traite le second choix ; les essais simulés (`look`, `wise`) prennent la première carte héroïque.
- **Notes du joueur avisé** (`tests/reference_army.gd`) : quinze notes remesurées avec les valeurs renforcées. Elles ne servent plus qu'à départager deux cartes héroïques, puisque celles-ci ne sont plus en concurrence avec les cartes ordinaires.
- **Tests** : `test_heroic_bonuses.gd` réécrit. Il couvre le second choix, la relance, les nouvelles valeurs, la règle et les valeurs de la v0.260 au rejeu, ainsi que les six cartes et le titre du second choix.

## Mesures

### Notes des bonus héroïques renforcés

Même méthode qu'en v0.260 : bonus imposé au premier choix, en contexte héroïque aux PV du Normal, 40 missions, tirages 7, 8 et 9, ramené à l'échelle des autres bonus par trois repères. Le contexte compte désormais le second choix héroïque des vagues 4 et 8. Ces notes servent au joueur avisé des mesures pour départager les deux cartes du second choix.

| Bonus | Alliance | Horde |
| --- | --- | --- |
| Chasseur de champions | 54 | 38 |
| Prime des champions | 66 | 54 |
| Forge ardente | 66 | 68 |
| Sceau des anciens | 84 | 76 |
| Hiver éternel | 90 | 89 |
| Charges en chaîne | 84 | 79 |
| Héros du rempart | 89 | 71 |
| Doctrine unique | 50 | 47 |
| Supériorité numérique | 88 | 73 |
| Perce-armures | 66 | 57 |
| Muraille vivante | 84 | 84 |
| Pacte de sang | 53 | 58 |
| Arsenal royal | 61 | 53 |
| Fléau | 50 | 37 |
| Dernier carré | 82 | 68 |

La Muraille vivante, l'Hiver éternel, les Charges en chaîne et le Héros du rempart sont désormais les mieux notés. Le Pacte de sang est noté bas parce que la mesure compte les PV de forteresse restants, que sa contrepartie réduit ; c'est pourtant le plus fort en dégâts.

### Effet sur la difficulté de l'Héroïque

Meilleure des 30 compositions, 40 missions (une sur cinq), tirages 7, 8 et 9, 51 points de talent, joueur avisé (`POLICY=refwise`). Héroïque complet : PV × 1,3, champions, rappels et bonus héroïques. Fichiers : `design/essais/equilibre_bonus/v261/`.

**Alliance**, joueur avisé (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Sans bonus héroïques (v0.259) | Carte de remplacement (v0.260) | Second choix renforcé (v0.261) |
| --- | --- | --- | --- |
| 1 | 99 % | 95 % | 98 % |
| 2 | 94 % | 93 % | 98 % |
| 3 | 90 % | 86 % | 96 % |
| 4 | 64 % | 61 % | 88 % |
| 5 | 39 % | 33 % | 68 % |
| 6 | 46 % | 45 % | 68 % |
| 7 | 25 % | 33 % | 43 % |
| 8 | 0 % | 2 % | 26 % |
| 9 | 0 % | 0 % | 5 % |
| 10 | 0 % | 10 % | 18 % |
| 11 à 15 | 0 % | 0 % | 2 % |
| 16 à 20 | 0 % | 0 % | 1 % |

**Horde**, joueur avisé (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Sans bonus héroïques (v0.259) | Carte de remplacement (v0.260) | Second choix renforcé (v0.261) |
| --- | --- | --- | --- |
| 1 | 100 % | 100 % | 100 % |
| 2 | 100 % | 100 % | 100 % |
| 3 | 95 % | 98 % | 95 % |
| 4 | 98 % | 95 % | 92 % |
| 5 | 69 % | 56 % | 72 % |
| 6 | 87 % | 87 % | 85 % |
| 7 | 71 % | 64 % | 60 % |
| 8 | 50 % | 55 % | 57 % |
| 9 | 22 % | 13 % | 38 % |
| 10 | 29 % | 30 % | 67 % |
| 11 à 15 | 0 % | 0 % | 7 % |
| 16 à 20 | 0 % | 0 % | 1 % |

**Ce qu'on en retient :**
- **Le renforcement change nettement la difficulté.** Marge moyenne : 31 % pour l'Alliance (23 % en v0.260) et 41 % pour la Horde (35 %). Missions perdues par toutes les compositions, sur 40 : 20 pour l'Alliance (25) et 12 pour la Horde (21).
- Le gain se concentre aux chapitres 4 à 10, de 20 à 38 points, là où les missions restaient jouables.
- À partir du chapitre 11, l'Héroïque reste presque toujours perdu : la hausse uniforme de 30 % des PV l'emporte encore. Le calibrage (lot 5) reste nécessaire, et il se fera avec ces bonus.
- Les premiers chapitres, déjà faciles, le deviennent davantage (Alliance : 88 à 98 % de marge aux chapitres 1 à 4).

## Limites

- Les valeurs n'ont pas été essayées en jeu par le porteur.
- L'Héroïque n'est pas encore calibré dans cette version : il l'est en v0.262 (lot 5, `Calibrage_Heroique_v0262.md`).
- Le récapitulatif à six cartes réduit un peu leur hauteur : leurs textes sont plus serrés.
