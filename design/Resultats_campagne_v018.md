# Campagnes de référence — prototype v0.18

21 octobre 2026 · Godot 4.7.2.stable.official.ed1daf0bf · GDD v0.14.

Ces résultats vérifient l’intégration L5. Ils ne constituent ni une étude d’équilibrage, ni une mesure de durée avec des joueurs. Les règles approuvées sont implémentées ; les valeurs de dégâts, de prix, de vagues, de bonus et de synergies gardent leur statut H. Aucun réglage n’a été changé pour obtenir ces résultats.

## 1. Protocole financé au budget normal

Deux parties déterministes, une par faction, générateur de test avec graine 42. Départ normal : 150 or et 20 PV. Aucun or ajouté, aucune unité gratuite, aucune vente, aucun soin ou changement de statistique de contrôle. Toutes les opérations passent par les transactions du modèle. Les synergies sont actives.

- E1 : Archer elfe ou Lanceur de haches troll, acheté au départ.
- E2 : Arbalétrier nain ou Sapeur gobelin, acheté au départ.
- E3 : Mage humain ou Chaman orc, acheté avant la vague 4.
- À partir de la préparation de vague 5, tenter une amélioration de chaque unité dans l’ordre E1, E2, E3. Une tentative sans fonds ne change rien. Ne pas répéter la tentative sur la même unité pendant cette préparation.
- Au passage N4, sélectionner la branche A. Aucun déplacement de défenseur.
- Après chaque offre, choisir la première carte. Ce choix est un protocole de vérification, pas une recommandation stratégique ni une garantie de tirage dans le jeu normal.
- Lancer chaque vague et résoudre l’intégralité des événements. Les durées suivantes sont des secondes simulées à vitesse de référence ; préparations et sélections humaines sont exclues.

### Offres identiques pour les deux factions

| Après vague | Offre, dans l’ordre | Choix |
| --- | --- | --- |
| 3 | R-06 Impacts appuyés ; R-10 Ateliers efficaces ; R-01 Armes affûtées | R-06 |
| 6 | R-11 Recrutement organisé ; R-03 Postes d’observation ; R-01 Armes affûtées | R-11 |
| 9 | R-10 Ateliers efficaces ; R-02 Exercice de tir ; R-03 Postes d’observation | R-10 |

Les offres non choisies peuvent revenir : R-01 apparaît dans les deux premières et R-10 revient dans la troisième. Les choix déjà acquis ne reviennent pas. La graine n’est pas exposée dans l’interface du jeu.

### Niveaux au lancement et dépenses effectives

| Vague | E1 / E2 / E3 au lancement | Dépenses de cette préparation |
| --- | --- | --- |
| 1 | N1 / N1 / vide | 50 + 75 = 125 |
| 2 | N1 / N1 / vide | 0 |
| 3 | N1 / N1 / vide | 0 |
| 4 | N1 / N1 / N1 | 100 |
| 5 | N2 / N1 / N1 | 50 |
| 6 | N3 / N1 / N1 | 100 |
| 7 | N3 / N2 / N1 | 50 |
| 8 | N3 / N3 / N1 | 100 |
| 9 | N3 / N3 / N2 | 50 |
| 10 | N4 A / N3 / N2 | 135, après acquisition de R-10 |

Total investi : 710 or. E1 : 335 ; E2 : 225 ; E3 : 150. R-11 acquis après la vague 6 ne rembourse pas les recrutements antérieurs et n’apporte ici aucune économie : aucun nouvel achat n’est effectué après son acquisition.

Les synergies P-ALL-01 ou P-HOR-01 sont actives dès le départ. Après l’installation d’E3, les trois codes de proximité de la faction sont actifs pour leurs bénéficiaires respectifs, dans le triangle E1/E2/E3. Aucune association de spécialisations n’est activée : un seul N4 est atteint. Le volet racial reste inactif.

## 2. Résultats Alliance

Les soldes sont relevés après chaque combat, avant les achats de la préparation suivante. Les choix roguelite de cette référence n’ajoutent ni or ni PV.

| Vague | Éliminés | Arrivées | PV restants | Solde or | Revenus de combat cumulés | Combat cumulé (s) |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 10 | 0 | 20 | 55 | 30 | 23,500 |
| 2 | 18 | 0 | 20 | 93 | 68 | 58,500 |
| 3 | 14 | 2 | 18 | 135 | 110 | 100,470 |
| 4 | 20 | 0 | 18 | 79 | 154 | 128,938 |
| 5 | 18 | 0 | 18 | 117 | 242 | 165,938 |
| 6 | 20 | 0 | 18 | 99 | 324 | 203,438 |
| 7 | 10 | 1 | 16 | 139 | 414 | 249,971 |
| 8 | 43 | 1 | 14 | 141 | 516 | 308,755 |
| 9 | 14 | 0 | 14 | 223 | 648 | 348,755 |
| 10 | 11 | 0 | 14 | 192 | 752 | 372,755 |

**Victoire :** 178 éliminations, 4 arrivées, 14 PV et 192 or. Conservation de l’or : 150 + 752 − 710 = 192. Durée de combat seule : environ 6 min 13 s à ×1, hors préparations.

## 3. Résultats Horde

| Vague | Éliminés | Arrivées | PV restants | Solde or | Revenus de combat cumulés | Combat cumulé (s) |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 10 | 0 | 20 | 55 | 30 | 24,500 |
| 2 | 17 | 1 | 19 | 92 | 67 | 75,398 |
| 3 | 12 | 4 | 15 | 128 | 103 | 117,368 |
| 4 | 20 | 0 | 15 | 72 | 147 | 144,225 |
| 5 | 18 | 0 | 15 | 110 | 235 | 182,225 |
| 6 | 18 | 2 | 12 | 84 | 309 | 241,225 |
| 7 | 11 | 0 | 12 | 130 | 405 | 280,850 |
| 8 | 44 | 0 | 12 | 138 | 513 | 323,541 |
| 9 | 14 | 0 | 12 | 220 | 645 | 365,166 |
| 10 | 11 | 0 | 12 | 189 | 749 | 392,541 |

**Victoire :** 175 éliminations, 7 arrivées, 12 PV et 189 or. Conservation de l’or : 150 + 749 − 710 = 189. Durée de combat seule : environ 6 min 33 s à ×1, hors préparations.

## 4. Contrôles techniques distincts

969 contrôles réussis, dont 362 sur la campagne, les offres, bonus et synergies. Les références antérieures sans bonus ni synergies restent isolées pour conserver leurs résultats de comparaison. Le jeu normal active les synergies.

- Les dix calendriers respectent types, quantités, intervalles et séparation des groupes ; 182 ennemis, 10 944 PV bruts, 770 or maximal, 273,1 s de fenêtres d’émission.
- Deux campagnes avec six N4 financés par un **budget imposé de contrôle** éliminent les 182 ennemis et créditent 770 or. Ces scénarios valident les comptes et transitions ; ils ne sont pas des stratégies accessibles au départ normal.
- Les douze bonus et douze associations ont leurs effets vérifiés, dont R-12 par victime, chaman exclu de R-02, perte de R-07 au N3, arrondis économiques et absence de rétroactivité.
- Les cinq liens de proximité sont contrôlés, E3/E5 reste exclu, un même code ne se double pas avec plusieurs partenaires et un partenaire restant maintient l’effet après vente.
- La vague 8, avec bonus et synergies actifs, conserve le même journal de combat à grand pas, à ×1 et à ×2.
- Arrivée du boss à 20 PV : défaite ; à 24 PV : 4 PV restants et victoire si tous les autres ennemis sont résolus. Aucun or gagné pour cette arrivée.
- Les quatre pages du catalogue de bonus, le choix, le récapitulatif, les combats tardifs et victoires sont rendus et inspectés.

Reproduction : lancer les cinq scripts de test indiqués dans [le README du prototype](../prototype/README.md), avec la version de moteur précisée ci-dessus. test_campaign.gd fixe la graine des références ; une partie normale utilise des offres aléatoires.

## 5. Suite L6 et limites

Une politique identique et une graine commune ne couvrent ni toutes les compositions, ni tous les choix roguelite. Les différences observées ne suffisent pas à classer les factions. Les deux références n’activent pas de synergie N4 ; cet axe doit aussi être étudié avec un budget réellement disponible et des choix adaptés.

Les préparations, hésitations, lectures et choix humains ne sont pas mesurés. La cible de 8 à 12 minutes n’est donc pas confirmée par ces durées de combat. Restent à mener : essais humains, comparaison du triangle de gauche avec la défense finale E5/E6, répétition sur des offres différentes, stratégies économiques et signalement des erreurs de compréhension. Toute proposition de changement H devra distinguer règle, valeur précédente, valeur testée et résultat.

L0 reste partiel : le projet est lançable avec le moteur préparé localement ; l’export Windows autonome n’est pas encore produit. Les visuels sont temporaires. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.
