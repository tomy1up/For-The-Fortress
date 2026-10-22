# Dernière vague — analyse initiale du retour RJ-001

22 octobre 2026 · Prototype v0.21, réglages du GDD v0.14.

Le joueur rapporte une Horde globalement équilibrée avec sa composition, mais une dernière vague plus facile que les précédentes. Après clarification, les descriptions sont conservées ; leur reformulation est reportée.

## Constats de conception

| Indicateur | Vague 8 | Vague 9 | Vague 10 |
| --- | --- | --- | --- |
| Ennemis | 44 | 14 | 11 |
| PV cumulés de référence | 1 216 | 2 160 | 1 512 |
| Dernière apparition | 35,45 s | 34,6 s | 20 s |

La vague 10 a 30 % de PV bruts de moins que la vague 9, moins d’ennemis et une émission plus courte. Ces indicateurs ne mesurent pas seuls la difficulté. La défense reçoit aussi une préparation et un troisième bonus après la vague 9.

Le boss a 600 PV et une vitesse de 0,45 : sans combat, il traverse les 28 unités en environ 62,22 s. Une Élite à 0,75 traverse en 37,33 s. La lenteur du boss laisse donc une longue exposition aux tirs ; sa menace de 20 dégâts à l’arrivée ne s’exprime que s’il survit. Augmenter uniquement ses dégâts d’arrivée ne corrigerait pas une élimination trop facile.

## Relecture des essais existants, sans nouvelle partie

Source : design/essais/v019_releves.json.gz. Filtre : faction Horde et last_wave = 10, soit 508 scénarios ayant franchi les vagues précédentes. Les PV perdus en vague 10 tiennent compte de l’éventuel soin de 4 PV de R-09 sélectionné après vague 9. Les pertes restent bornées par les PV disponibles.

| Mesure sur ces mêmes 508 scénarios | Vague 9 | Vague 10 |
| --- | --- | --- |
| Scénarios sans arrivée | 470 | 502 |
| Arrivées cumulées | 46 | 7 |
| Pertes de PV observées cumulées | 94 | 15 |

505 de ces 508 scénarios gagnent. Ce résultat soutient la piste d’une finale peu menaçante pour les défenses qui l’atteignent. Il ne reproduit pas la composition inconnue du joueur, exclut les défaites avant vague 10 et contient les dépendances de la matrice v0.19. Les unités et bonus peuvent aussi être plus forts en vague 10 : il ne s’agit pas d’une comparaison à défense fixe.

## Proposition d’essai P-BOSS-01 — non appliquée

Premier candidat : boss à **900 PV au lieu de 600**, soit +50 %, en conservant vitesse, récompense, dégâts d’arrivée et accompagnateurs. Le total brut de vague 10 deviendrait 1 812 PV, encore inférieur aux 2 160 de vague 9. Cette valeur est une proposition de test, pas une décision d’équilibrage validée.

Comparer ensuite les deux valeurs sur les mêmes états de défense avant la vague 10, avec PV, unités, placements, investissements et bonus identiques. Relever survie du boss, durée d’exposition, éliminations, arrivées et victoire ; inclure des défenses fortes et des défenses ayant déjà perdu des PV. Ne pas modifier simultanément sa vitesse ou les groupes, afin de pouvoir interpréter le résultat.

Aucun nouveau test lancé dans cette analyse, aucun contrôle de la fenêtre repris et aucun paramètre du jeu ou du GDD changé. Les descriptions actuelles sont maintenues. La prochaine décision devra s’appuyer sur cet essai comparatif et un retour joueur, sans promettre qu’un simple gain de PV suffira.
