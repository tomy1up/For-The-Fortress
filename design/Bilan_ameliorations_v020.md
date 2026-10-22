# Améliorations à composition constante — v0.20

22 octobre 2026 · Godot 4.7.2.stable.official.ed1daf0bf · GDD v0.14.

**Conclusion de cette livraison : conserver les coûts et statistiques actuels.** Une amélioration de 50 or a un effet mesurable dans les essais isolés de vague 5. Les continuations montrent des compromis de placement et de répartition, sans avantage général suffisant pour justifier un changement de prix. Les tests ne remplacent pas les retours de joueurs.

## 1. Pourquoi compléter la matrice v0.19

La matrice précédente comparait notamment six défenseurs avec deux défenseurs spécialisés. Elle faisait varier en même temps couverture du chemin, diversité, dégâts de groupe et niveaux. Elle ne permettait pas d’attribuer les échecs au seul coût des améliorations.

Ce nouvel essai conserve les mêmes trois types et les mêmes positions dans chaque comparaison. Il distingue deux questions :

1. Avec exactement le même état de départ et une dépense identique, quelle unité bénéficie le plus d’un passage N2 pour la vague suivante ?
2. À partir de cet état commun, comment différentes politiques d’amélioration se comportent-elles jusqu’au boss, sans nouveau recrutement ?

Les règles, prix et valeurs de combat restent ceux du jeu. Aucun capital, niveau, soin, bonus ou ennemi n’est ajouté pour les expériences.

## 2. Préparations communes et contrôles

96 états sont produits en jouant réellement les vagues 1 à 4 : 2 factions × 4 placements × 12 graines (1 à 11 et 42). Les deux premiers types sont recrutés au départ pour 125 or ; le troisième est acheté avant la vague 4, sans amélioration préalable. Le bonus après vague 3 est choisi selon la priorité dégâts de v0.19.

Les quatre placements et les types sont ceux décrits dans [le bilan précédent](Bilan_equilibrage_v019.md). Tous les préfixes survivent, disposent des trois N1 et peuvent payer une amélioration de 50 or avant la vague 5. Leurs PV, soldes, bonus et états du générateur peuvent différer d’un préfixe à l’autre, mais sont strictement identiques entre les variantes d’un même préfixe.

Chaque variante reçoit une copie profonde de l’état et de la position du générateur aléatoire. Le moteur vérifie l’identité initiale et l’absence de mutation du préfixe après chaque essai. Les trois unités gardent leurs types et leurs emplacements ; aucune vente ou copie supplémentaire n’est autorisée par ces politiques.

## 3. Essai isolé de vague 5 : trois dépenses égales

Pour chaque état, quatre variantes jouent seulement la vague 5 : épargner ; améliorer le premier type ; améliorer le deuxième ; améliorer le troisième. Les trois traitements N2 paient exactement 50 or chacun. Le contrôle épargne ne paie rien : il compare l’effet immédiat d’une dépense avec celui de la conservation de cet or, sans prétendre comparer leur intérêt sur toute la campagne.

384 essais isolés sont donc exécutés, dont 288 traitements N2. La vague contient 18 ennemis. Les moyennes ci-dessous donnent le même poids aux 96 états de départ.

| Dépense avant la vague 5 | Éliminations moyennes / 18 | États avec moins d’arrivées que l’épargne | États avec autant d’arrivées | États avec plus d’arrivées |
| --- | --- | --- | --- | --- |
| Épargne | 16,510 | Référence | Référence | Référence |
| N2 premier type : Archer / Troll | 17,563 | 53 / 96 | 43 / 96 | 0 / 96 |
| N2 deuxième type : Arbalétrier / Sapeur | 17,573 | 55 / 96 | 41 / 96 | 0 / 96 |
| N2 troisième type : Mage / Chaman | 17,760 | 53 / 96 | 43 / 96 | 0 / 96 |

Deux contrôles épargne perdent cette vague ; aucune variante N2 ne la perd. Le plafond de 18 éliminations masque une partie des différences : beaucoup d’états gagnent déjà sans amélioration. Le solde de l’épargne conserve 50 or de plus avant les récompenses ; aucun essai ne prouve qu’il faut toujours dépenser immédiatement.

Les résultats dépendent de la position. Exemple Alliance, placement milieu : améliorer Archer ou Arbalétrier atteint 18 éliminations en moyenne, contre 17,833 pour Mage. Sur le placement réparti : Mage atteint 17 contre 16,833 pour Arbalétrier et 16,333 pour Archer. La moyenne globale du troisième type n’en fait donc pas une priorité universelle. Dans la Horde, le troisième type est le Chaman, avec dégâts périodiques ; ce n’est pas une comparaison uniforme de trois spécialistes de zone.

## 4. Continuations jusqu’au boss

Depuis chacun des mêmes 96 états, quatre politiques et deux ensembles de branches sont testés, soit 768 suites de campagne. Les offres après vagues 6 et 9 et le bonus choisi sont identiques entre les variantes qui atteignent ces choix : la priorité dégâts ne dépend pas de la composition et l’état initial du générateur est copié.

### Politiques

| Code | Règle à chaque préparation, de vague 5 à 10 |
| --- | --- |
| reference | Tenter une amélioration par unité, dans l’ordre premier, deuxième, troisième type. |
| equilibre | Améliorer le plus bas niveau ; à égalité, privilégier l’ordre du roster. Répéter tant que le prochain passage est finançable. |
| priorite_0 | Améliorer autant que possible le premier type, puis le deuxième, puis le troisième avec le solde. |
| priorite_groupe | Alliance : priorité Mage, puis Archer, puis Arbalétrier. Horde : priorité Sapeur, puis Troll, puis Chaman. Améliorer autant que possible dans cet ordre. |

Les branches sont soit toutes A, soit toutes B. Les deux ensembles ne couvrent pas toutes les associations ou choix mixtes. Ils n’affectent un essai que lorsqu’une unité atteint réellement le N4.

Le capital, les ressources et les unités sont égaux **au départ de chaque comparaison**. Les revenus et donc les dépenses futures peuvent ensuite diverger à cause des éliminations : aucun or n’est ajouté pour les égaliser. Les résultats ne sont pas ceux d’un budget terminal artificiellement identique.

### Résultats des 768 suites

| Politique | Victoires / 192 | PV finaux moyens, défaites comptées à 0 |
| --- | --- | --- |
| reference | 150 | 8,927 |
| equilibre | 152 | 10,667 |
| priorite_0 | 150 | 8,927 |
| priorite_groupe | 146 | 8,365 |

La politique equilibre gagne quatre scénarios où reference perd, et en perd deux où reference gagne. Le gain net est donc de deux victoires sur 192 comparaisons appariées ; il ne démontre pas une domination générale.

Dans les ressources rencontrées ici, reference et priorite_0 produisent exactement les mêmes 192 trajectoires, offres et résultats. Elles ne constituent pas deux observations indépendantes de leur succès. De même, des branches sans N4 et certaines graines produisent des parcours identiques.

La priorité aux dégâts de groupe varie fortement avec les placements : elle gagne 24/24 essais Alliance dans le triangle, mais 17/24 au milieu, où les trois autres politiques gagnent 24/24. Dans la Horde au milieu, elle gagne 24/24 contre 23/24 pour reference et 22/24 pour equilibre. Les tableaux détaillés sont nécessaires pour lire ces interactions.

Le placement réparti reste difficile même avec les trois types présents : dans l’Alliance, 2 à 4 victoires sur 24 selon la politique ; dans la Horde, 5 à 7 sur 24. Investir ne compense donc pas automatiquement une répartition de couverture peu favorable dans ces essais.

### Branches A et B

En politique reference, les branches A gagnent deux scénarios où B perd ; aucune victoire B seule n’est observée. Pour equilibre, les résultats victoire/défaite sont identiques entre A et B. Pour priorite_groupe, B gagne quatre scénarios où A perd ; aucune victoire A seule n’est observée.

Ces écarts portent sur l’ensemble des branches déployées, les niveaux atteints et leurs effets de groupe. Ils ne suffisent pas à modifier une branche particulière ni à classer toutes les spécialisations.

## 5. Traçabilité et résultats techniques

51 801 vérifications d’intégrité réussies dans ce protocole : préfixes financés, copies d’état et de générateur identiques, état d’origine préservé, trois types aux positions conservées, conservation de l’or et transitions autorisées. L’analyse indépendante vérifie les tailles, l’unicité des variantes, les dépenses et niveaux N2, la conservation terminale des continuations et les offres identiques aux choix communs.

Les **969 contrôles de régression** restent une vérification distincte. Le jeu, le GDD et les réglages de v0.19 sont inchangés. Les états et trajectoires sont versionnés dans les [relevés compressés](essais/v020_releves.json.gz), la [synthèse](essais/v020_synthese.json) et les [tableaux](essais/v020_tableaux.md). Le [protocole de reproduction](essais/README.md) indique les commandes.

Les archives décrivent des simulations, pas des parties de joueurs. Aucun temps de préparation, ressenti ou taux de victoire humain n’est déduit de ces résultats.

## 6. Décision et suite

- Conserver les coûts 50 / 100 / 150 et les statistiques actuelles. Leur statut reste H ; ce maintien n’est pas une validation définitive de l’équilibrage.
- Éviter une recommandation universelle d’améliorer un type en premier : le placement et les ennemis changent son intérêt.
- Utiliser la [fiche d’essai joueur](Fiche_essai_joueur.md) pour observer si les prix, le choix N4 et les effets des placements sont compris.
- Préparer une distribution Windows autonome pour faciliter ces essais. L0 et les essais humains de L6 restent à terminer ; aucun retour humain n’est présenté comme acquis.

For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.
