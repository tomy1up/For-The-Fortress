# Bonus héroïques (v0.260)

**Statut.** Lot 4 du cadrage du 25 novembre 2026 (`Cadrage_Heroique_Mythique_2026-11-25.md`). La liste, les valeurs et la règle d'apparition ont été validées par le porteur le 27 novembre 2026 (« Tout valider », sur la proposition de Claude Code). Ce sont des réglages de prototype à confirmer en jeu.

## Règles

- **En Héroïque seulement**, et plus tard en Mythique. Le Normal ne change pas.
- **Quand ils apparaissent** : aux choix des **vagues 4 et 8**, la troisième carte de l'offre devient un bonus héroïque. On en prend donc **au plus deux par mission**. Les choix des vagues 2 et 6 restent ordinaires.
- **Quels bonus sont proposés** : la carte est tirée parmi les bonus héroïques déjà débloqués par le chapitre, pas encore pris et utiles à l'armée déployée. La relance en tire un autre, si possible.
- Ils ont leur propre rareté, **« héroïque »**. Le nom et l'étiquette de la carte sont en ambre ; c'est un habillage de prototype.
- **Introduction** : deux au chapitre 1, puis un par chapitre ; les quinze sont disponibles à partir du chapitre 14.

| Chapitre | Code | Bonus | Effet |
| --- | --- | --- | --- |
| 1 | H-01 | **Chasseur de champions** | +60 % à tous les dégâts contre les champions mutants et le boss |
| 1 | H-02 | **Prime des champions** | Chaque champion éliminé rapporte 30 or de plus |
| 2 | H-03 | **Forge ardente** | À la fin de chaque vague gagnée, le défenseur de plus bas niveau gagne un niveau gratuit, jusqu'au niveau 3 (premier emplacement à égalité) |
| 3 | H-04 | **Sceau des anciens** | L'affixe rappelé n'a plus d'effet ; les attaquants rappelés ont 40 % de PV en moins |
| 4 | H-05 | **Hiver éternel** | Tous les ennemis avancent 20 % moins vite |
| 5 | H-06 | **Charges en chaîne** | Chaque ennemi éliminé explose : 25 % de ses PV maximum aux ennemis à 1,2 case ou moins ; les explosions peuvent s'enchaîner, chaque ennemi n'explose qu'une fois |
| 6 | H-07 | **Héros du rempart** | Le défenseur le plus avancé (niveau, puis or investi, puis premier emplacement) gagne +60 % de dégâts et +1 de portée |
| 7 | H-08 | **Doctrine unique** | +50 % à tous les dégâts si tous les défenseurs sont de la même famille, spécialisations comprises |
| 8 | H-09 | **Supériorité numérique** | +10 % à tous les dégâts par défenseur déployé, jusqu'à +60 % |
| 9 | H-10 | **Perce-armures** | Vos dégâts ignorent les boucliers (Cor d'alarme, champions Bouclier) et le trait Blindé ; +25 % contre les ennemis lourds |
| 10 | H-11 | **Muraille vivante** | Les trois premiers ennemis qui atteignent la forteresse à chaque vague ne lui infligent aucun dégât ; s'ajoute à la Herse |
| 11 | H-12 | **Pacte de sang** | +60 % à tous les dégâts ; −1 PV maximum de forteresse à la fin de chaque vague gagnée, jamais sous 1 |
| 12 | H-13 | **Arsenal royal** | −40 % au prix des améliorations et des spécialisations |
| 13 | H-14 | **Fléau** | Malédictions +50 % ; à la mort d'un ennemi maudit, sa malédiction passe entière à l'ennemi le plus proche, à 2 cases ou moins |
| 14 | H-15 | **Dernier carré** | +100 % à tous les dégâts contre les ennemis qui ont parcouru plus de 80 % de leur route |

**Précisions de mise en œuvre** (choix techniques de Claude Code) :
- **Utilité** :
  - le Sceau n'est proposé que si la mission a des rappels ;
  - la Doctrine, que si l'armée déployée n'a qu'une famille ;
  - le Fléau, que si un défenseur maudit.
- **Hiver éternel** s'applique aussi aux Braises du golem et aux morceaux d'un champion Scission.
- **Sceau des anciens** : la baisse de PV ne touche que les attaquants rappelés du calendrier de vague, pas les Braises de leurs golems.

## Technique

- **Catalogue** (`campaign_data.gd`) :
  - les quinze bonus sont ajoutés à la suite des soixante autres (codes 60 à 74, `rarity: "heroic"`, champ `chapter`) ;
  - fonctions `HEROIC_FIRST`, `HEROIC_COUNT`, `HEROIC_OFFER_WAVES`, `is_heroic_bonus` et `heroic_bonuses_for(chapter)`.
  - Les tirages ordinaires ne parcourent que les codes 0 à 59 : les offres du Normal et des anciens rapports sont inchangées.
- **Combat** (`valley_model.gd`) :
  - constantes `H_*` et valeurs `HUNTER_BONUS`, `WINTER_SPEED`… ;
  - `configure_heroic_bonuses(chapter)` ;
  - carte héroïque dans `_draw_offers` ;
  - héros (`hero_slot`), `deployed_count`, `deployed_families` ;
  - apparitions (`_heroic_spawn`) et contagion (`_spread_plague`) ;
  - Muraille, Forge et Pacte en fin de vague ; Arsenal dans `_discounted_cost`.
- **Interface** : rareté « Héroïque » en ambre sur les cartes d'offre. La ligne d'affixe signale un affixe rappelé « scellé ».
- **Rapport** : champ `heroic_bonus_chapter`, refusé au rejeu avant la v0.260 (« Bonus héroïques invalides. »).
- **Joueur avisé des mesures** (`tests/reference_army.gd`, `BONUS_VALUES`) : quinze notes de plus (voir ci-dessous).
- **Outil d'étude** : `HEROIC=1` comprend les bonus héroïques ; `HEROIC_HP=normal` garde les PV du Normal en contexte héroïque.
- **Tests** :
  - nouvelle suite `prototype/tests/test_heroic_bonuses.gd` : catalogue, offres, quinze effets, parties jouées et rejouées, lancement ;
  - suites des bonus adaptées : 75 bonus, rareté héroïque, médiane des 60 bonus ordinaires, aperçu du Chasseur contre le boss.

## Notes des bonus héroïques

Méthode : chaque bonus héroïque est imposé au premier choix de l'armée de référence, sur 40 missions, dans les deux factions, avec les tirages 7, 8 et 9.
- **Contexte** : héroïque (champions, rappels), mais aux PV du Normal pour éviter les défaites systématiques.
- **Échelle** : la note est ramenée à celle des 60 autres bonus grâce à trois repères mesurés dans le même contexte (Armes affûtées, Lames runiques, Armée d'élite).
- **Fichiers** : `design/essais/equilibre_bonus/v260/`.

| Bonus | Alliance | Horde |
| --- | --- | --- |
| Chasseur de champions | 52 | 36 |
| Prime des champions | 60 | 43 |
| Forge ardente | 68 | 58 |
| Sceau des anciens | 57 | 43 |
| Hiver éternel | 72 | 60 |
| Charges en chaîne | 69 | 48 |
| Héros du rempart | 83 | 58 |
| Doctrine unique | 50 | 37 |
| Supériorité numérique | 75 | 50 |
| Perce-armures | 61 | 44 |
| Muraille vivante | 69 | 52 |
| Pacte de sang | 69 | 60 |
| Arsenal royal | 59 | 42 |
| Fléau | 50 | 36 |
| Dernier carré | 66 | 41 |
| *Repères : médiane des 60 bonus ordinaires* | *50* | *30* |
| *Lames runiques (rare)* | *82* | *59* |
| *Armée d'élite (épique)* | *93* | *93* |

**Lecture :**
- Les bonus héroïques valent en moyenne un bon bonus rare. Aucun n'atteint Armée d'élite, Ascension ou Forteresse imprenable.
- Doctrine unique et Fléau sont mal notés parce que l'armée de référence ne remplit pas leur condition (deux familles, peu de malédictions). Ils servent d'autres stratégies.
- La note mesure un bonus imposé dès la vague 2, à la place du premier choix naturel. En jeu, ils arrivent aux vagues 4 et 8.

## Mesure : effet sur la difficulté de l'Héroïque

Méthode : meilleure des 30 compositions, 40 missions (une sur cinq), tirages 7, 8 et 9, 51 points de talent. Héroïque complet : PV × 1,3, champions, rappels et, en v0.260, bonus héroïques. Le joueur avisé choisit ses bonus d'après leurs notes et relance (`POLICY=refwise`) ; il prend donc une carte héroïque quand elle vaut mieux que les deux autres. Fichiers : `design/essais/equilibre_bonus/v260/`.

**Alliance**, joueur avisé (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Sans bonus héroïques (v0.259) | Avec bonus héroïques (v0.260) |
| --- | --- | --- |
| 1 | 99 % | 95 % |
| 2 | 94 % | 93 % |
| 3 | 90 % | 86 % |
| 4 | 64 % | 61 % |
| 5 | 39 % | 33 % |
| 6 | 46 % | 45 % |
| 7 | 25 % | 33 % |
| 8 | 0 % | 2 % |
| 9 | 0 % | 0 % |
| 10 | 0 % | 10 % |
| 11 à 15 | 0 % | 0 % |
| 16 à 20 | 0 % | 0 % |

**Horde**, joueur avisé (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Sans bonus héroïques (v0.259) | Avec bonus héroïques (v0.260) |
| --- | --- | --- |
| 1 | 100 % | 100 % |
| 2 | 100 % | 100 % |
| 3 | 95 % | 98 % |
| 4 | 98 % | 95 % |
| 5 | 69 % | 56 % |
| 6 | 87 % | 87 % |
| 7 | 71 % | 64 % |
| 8 | 50 % | 55 % |
| 9 | 22 % | 13 % |
| 10 | 29 % | 30 % |
| 11 à 15 | 0 % | 0 % |
| 16 à 20 | 0 % | 0 % |

**Ce qu'on en retient :**
- **Pour le joueur avisé, les bonus héroïques ne changent presque rien à la difficulté.** Marge moyenne de 23 % pour l'Alliance (23 % en v0.259), de 35 % pour la Horde (36 %). Les missions perdues par toutes les compositions, sur 40, passent de 27 à 25 (Alliance) et de 19 à 21 (Horde). Ces écarts restent dans le bruit de la mesure : les tirages d'offres changent d'une version à l'autre.
- **Raison** : la carte héroïque remplace la troisième carte ordinaire, et elle vaut en moyenne un bon bonus rare. Le gain est donc faible face à la carte qu'elle remplace.
- Pour que ces bonus soient « plus marqués » comme le voulait le cadrage, il faudrait renforcer leurs valeurs ou en proposer davantage. C'est à décider par le porteur.

## Limites

- Les valeurs n'ont pas été essayées en jeu par le porteur.
- Mesurés, ces bonus sont moins marqués que prévu au cadrage (« plus marqués que les 60 actuels »). Les renforcer est une décision de direction, à soumettre au porteur.
- L'Héroïque n'est toujours pas calibré (lot 5).
- La carte héroïque n'a pas d'habillage propre : seuls son nom et son étiquette changent de couleur.
