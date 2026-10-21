# Premiers essais comparatifs — v0.19

22 octobre 2026 · GDD v0.14 · Godot 4.7.2.stable.official.ed1daf0bf.

**Résultat principal :** dans la matrice testée, la politique « renforts » gagne 576 parties sur 576. La politique qui conserve uniquement les deux unités initiales pour les spécialiser gagne 82 parties sur 576. Cela justifie des essais plus ciblés sur la diversité et la couverture avant tout changement de prix ou de dégâts. Aucun réglage du jeu n’a été modifié.

## Périmètre et méthode

1 728 parties complètes ou arrêtées à la défaite, financées uniquement par les 150 or initiaux et les éliminations. Synergies actives, aucune vente ni unité gratuite, aucune modification des PV, des ennemis ou des bonus. Tous les achats et améliorations passent par les transactions normales.

La matrice croise : 2 factions × 4 placements × 3 politiques de dépenses × 3 priorités de bonus × 2 choix de branches × 12 graines. Chaque faction compte 864 parties. Les graines sont 1 à 11 et 42 ; les résultats sont reproductibles avec le moteur indiqué. Il ne s’agit pas d’un échantillon de joueurs.

### Placements initiaux

Les deux premiers types sont Archer/Arbalétrier pour l’Alliance et Troll/Sapeur pour la Horde. Le troisième type, quand la politique le recrute, est Mage/Chaman. Les emplacements ci-dessous suivent cet ordre.

| Identifiant | Premier / deuxième / troisième type | Intention de comparaison |
| --- | --- | --- |
| triangle | E1 / E2 / E3 | Trois liens de proximité possibles |
| milieu | E2 / E3 / E4 | Deux liens autour d’E3, couverture différente du trajet |
| reparti | E1 / E2 / E6 | Couple initial à gauche, troisième défenseur en fin de chemin |
| aval | E5 / E6 / E3 | Couple initial près de la forteresse, troisième défenseur au centre |

Ces placements n’ont pas une couverture d’attaque identique. Ils ne permettent donc pas d’isoler le gain des seules synergies. Pour la politique renforts, les copies supplémentaires occupent les emplacements libres dans l’ordre E1 à E6 ; le plateau final peut différer du placement initial.

### Politiques de dépenses

| Politique | Règle automatique |
| --- | --- |
| reference | Recruter le troisième type dès la préparation de vague 4 si possible. Dès la vague 5, tenter une amélioration par unité dans l’ordre des trois emplacements initiaux. Choix analogue à la référence v0.18. |
| renforts | Recruter le troisième type dès que possible, puis un second exemplaire de chaque type dans l’ordre du roster. Attendre six unités avant d’essayer une amélioration par emplacement et par préparation. |
| specialisation | Ne conserver que les deux unités initiales. Dès la vague 2, améliorer autant que possible la première, puis essayer la seconde avec le solde, même si la première n’a pas encore atteint N4. Répéter à chaque préparation. |

Un achat ou une amélioration sans fonds échoue sans dépense. Les politiques ne prévoient pas les vagues et ne cherchent pas une solution optimale. Le nombre d’unités, leurs types et leurs niveaux varient entre politiques : le contraste n’est pas une mesure isolée de la rentabilité des améliorations. La politique specialisation de l’Alliance n’a notamment aucun mage ni dégât de zone.

### Choix de bonus et de branches

Chaque politique choisit le premier bonus disponible dans sa liste de priorité :

| Identifiant | Codes, du plus au moins prioritaire |
| --- | --- |
| degats | R-01, R-06, R-12, R-08, R-07, R-04, R-02, R-03, R-05, R-09, R-10, R-11 |
| economie | R-10, R-11, R-09, R-01, R-06, R-12, R-08, R-07, R-02, R-03, R-04, R-05 |
| couverture | R-03, R-05, R-04, R-02, R-01, R-06, R-12, R-09, R-07, R-08, R-10, R-11 |

Les branches testées sont soit A pour tous, soit une association prévue pour le couple initial : Veilleur + Sentinelle dans l’Alliance, Maître des ricochets + Artificier des foules dans la Horde. Les autres types restent en branche A s’ils atteignent le N4. Ce choix ne couvre pas toutes les branches possibles.

Les graines sont communes entre scénarios. Les offres ultérieures peuvent diverger si les bonus choisis diffèrent, puisque seul le bonus acquis est retiré du catalogue. Certains scénarios restent identiques tant qu’aucun N4 n’est atteint : les 1 728 lignes ne sont donc pas 1 728 observations indépendantes.

## Résultats observés

| Politique | Victoires / parties | Part de victoires dans cette matrice |
| --- | --- | --- |
| reference | 399 / 576 | 69,271 % |
| renforts | 576 / 576 | 100 % |
| specialisation | 82 / 576 | 14,236 % |

La politique renforts termine ses victoires avec au moins 9 PV dans ces essais. Elle utilise simultanément davantage d’unités, de types, de couverture et de liens possibles. Ce résultat est un signal de robustesse de cette politique sur la matrice, pas une preuve qu’elle domine toute autre stratégie.

| Placement initial | Victoires / parties, toutes politiques regroupées |
| --- | --- |
| triangle | 288 / 432 |
| milieu | 334 / 432 |
| reparti | 155 / 432 |
| aval | 280 / 432 |

Le triangle n’est pas le meilleur résultat agrégé : la couverture du chemin compte aussi. En politique reference, il gagne néanmoins les 72 essais de chaque faction. Le placement milieu donne 72/72 à l’Alliance et 50/72 à la Horde pour cette même politique. À l’inverse, la Horde conserve quelques victoires de specialisation en aval, absentes pour l’Alliance dans cette cellule. Les tableaux complets évitent de réduire ces différences à un seul classement.

Sur les 671 défaites, 332 surviennent en vague 6 et 240 en vague 7 : 572 au total dans ces deux vagues. Ce pic dépend fortement des politiques conservant seulement deux unités ; il ne suffit pas à déclarer ces vagues trop difficiles pour toute composition.

Les priorités degats, couverture et economie totalisent respectivement 378, 359 et 320 victoires sur 576. Ce sont des résultats de listes de priorités entières, avec des offres et des défenseurs différents selon la trajectoire. Ils ne mesurent pas la valeur individuelle d’un bonus et ne justifient pas une modification automatique de R-10 ou R-11.

### Comparaison des factions

Alliance : 552/864 victoires. Horde : 505/864. Sur les 864 paires de scénarios de mêmes paramètres : 476 doubles victoires, 283 doubles défaites, 76 victoires Alliance seules et 29 victoires Horde seules.

Ces chiffres décrivent ces politiques et ces branches. Ils ne mesurent ni un taux de victoire commercial, ni un niveau humain équivalent, ni l’équilibre complet des factions.

## Accès réel aux associations N4

54 parties activent au moins une association N4 au lancement d’un combat, vague 10 incluse : 31 dans l’Alliance et 23 dans la Horde. Parmi elles, 53 gagnent. Ce sous-ensemble sélectionne déjà des parties ayant survécu et financé leurs N4 ; son résultat ne prouve pas que la synergie a causé la victoire.

Exemple reproductible `0-triangle-reference-economie-association-1` :

- R-10 après vague 3, R-12 après vague 6, R-06 après vague 9.
- Avant la vague 10 : Veilleur E1, Sentinelle E2, Mage N2 E3 ; S-ALL-01 active.
- Investissements : 320 + 345 + 145 = 810 or. Revenus avant vague 10 : 660 ; capital initial : 150. Le solde au lancement est donc exactement zéro.
- Victoire : 18 PV, 104 or, 764 or gagnés sur la partie. Le compte reste 150 + 764 − 810 = 104.

L’association est donc finançable avec une trajectoire réelle et un bonus de prix acquis à temps. Aucun niveau, partenaire ou or supplémentaire n’a été attribué pour ce résultat.

## Vérifications et traçabilité

109 111 vérifications d’intégrité pendant la matrice, sans échec : dépenses réellement payées, conservation de l’or, fonds non négatifs, quotas et factions, transitions et choix autorisés. Ces vérifications répétées sont distinctes des **969 contrôles de régression**, qui passent toujours. Elles ne remplacent pas la vérification indépendante de toutes les règles de combat.

Les [tableaux générés](essais/v019_tableaux.md), la [synthèse structurée](essais/v019_synthese.json) et les [relevés complets compressés](essais/v019_releves.json.gz) sont versionnés. Les relevés contiennent chaque vague résolue, les unités et investissements au lancement, les effets actifs, les offres et le choix, puis le bilan. La synthèse conserve les empreintes des sources de gameplay, du GDD et des outils d’essai. Le [protocole de reproduction](essais/README.md) précise la commande et les identifiants.

## Décisions et prochaines vérifications

**Décision de cette livraison : conserver tous les réglages actuels.** Aucun coût, dégât, seuil de synergie ou calendrier de vague n’est changé. Les nombres d’équilibrage conservent leur statut H ; les règles restent celles du GDD v0.14.

Propositions d’essai, sans changement approuvé :

1. Comparer les améliorations avec les mêmes trois types déjà présents et les mêmes emplacements, pour ne pas confondre prix, nombre d’unités et absence de dégâts de zone.
2. Comparer les branches rapides et les branches de groupe à budget réellement identique, plutôt que de déduire la valeur du N4 d’une politique à deux types fixes.
3. Mesurer auprès de joueurs la compréhension du recrutement, du choix N4, des synergies et des bonus avec la [fiche d’essai](Fiche_essai_joueur.md).
4. Mesurer temps de préparation et durée réelle, en relevant les usages de ×2. Les durées simulées n’incluent aucune hésitation humaine : la cible de 8 à 12 minutes reste ouverte.

L6 est donc **partiellement réalisé** : comparaison automatisée et traçabilité obtenues, essais humains encore à mener. L0 reste partiel sans export Windows autonome. Aucune étude de disponibilité juridique du nom de travail n’est réalisée ici.
