# For the Fortress! — Résolution du combat approuvée

Approuvée le 20 octobre 2026 et intégrée au GDD v0.10.

**Statut V — règles approuvées pour le prototype.** Cette fiche ferme O-009 et le traitement des arrivées simultanées. Elle est intégrée au GDD approuvé v0.10. Les dégâts, cadences, portées, ennemis, vagues et coûts H restent ceux du GDD.

## 1. Intention

Obtenir des résultats compréhensibles et reproductibles : à mêmes ennemis, placements et horaires, les mêmes dégâts et revenus doivent être produits. Les règles portent sur le combat de référence hors bonus non définis. Le catalogue roguelite, les synergies, les résistances futures et leur ordre de calcul restent ouverts.

Règle approuvée pour le premier prototype : dégâts instantanés au moment du tir. Les flèches, haches, explosifs et sorts peuvent être représentés par des animations, mais leur trajet visuel ne retarde pas les dégâts et ne déclenche pas un second impact. Leur vitesse visuelle n’est pas une statistique de combat. Ajouter ultérieurement de vrais projectiles en vol constituerait une révision de règle à documenter.

## 2. Premier tir et cadence

- Chaque défenseur est prêt à tirer au début d’une vague. Il ne tire que lorsqu’une cible admissible est présente à portée.
- Le premier tir a lieu dès que cette condition est remplie, sans délai initial supplémentaire.
- Après un tir à l’instant t, le prochain tir est autorisé au plus tôt à t + intervalle du défenseur. La cadence commence au tir réellement effectué.
- Si aucune cible n’est admissible lorsque ce délai se termine, l’unité reste prête. Elle tire dès l’acquisition suivante. Aucun tir, charge ou salve ne s’accumule pendant l’attente.
- Changer de cible ne remet pas le délai à zéro et ne permet pas un tir supplémentaire.
- Le début d’une nouvelle vague réinitialise la disponibilité. Construire, améliorer, choisir une branche et vendre restent interdits pendant les combats.
- Les horaires utilisent le temps de jeu. L’accélération doit accélérer aussi apparitions, déplacements, tirs et malédictions, sans changer leur ordre relatif. Ses multiplicateurs restent ouverts.

Exemple : archer prêt à t = 0, première cible admissible à t = 0,3 s. Il tire à 0,3 s, puis au plus tôt à 1,3 s. Si aucune cible n’est présente à 1,3 s et qu’une cible entre à 1,8 s, il tire à 1,8 s ; son prochain tir sera autorisé à 2,8 s. Il ne récupère pas le tir manqué.

Le pas de simulation du moteur n’est pas fixé par ces exemples. L’implémentation devra mesurer son erreur temporelle et préserver les règles ; aucun résultat ne doit dépendre de la fréquence d’affichage.

## 3. Acquisition et égalités

Recalculer la cible principale avant chaque tir. Une cible encore vivante n’est pas verrouillée si une autre devient prioritaire. Cette précision résout l’ambiguïté entre « conserver sa cible » et la priorité déjà validée de l’ennemi le plus avancé.

Une cible principale est admissible si elle est vivante, présente sur le trajet et à distance de centre à centre inférieure ou égale à la portée. Un ennemi qui atteint exactement H à cet instant reste admissible jusqu’à la phase d’arrivée décrite en section 6.

Ordre de priorité principal :
1. Plus grande distance parcourue de A vers H.
2. En cas d’égalité exacte, plus ancien ordre d’apparition dans la partie.

L’ordre d’apparition est unique et croissant, y compris pour des ennemis apparus au même instant. Il suit l’ordre des groupes puis l’ordre interne de la vague. Aucun choix aléatoire n’est ajouté.

Pour les victimes secondaires :
1. Plus courte distance au centre de l’explosion ou à la victime précédente du rebond.
2. En cas d’égalité, plus grande progression sur le chemin.
3. En cas d’égalité persistante, plus ancien ordre d’apparition.

La règle de distance strictement inférieure au rayon ou à la distance de rebond reste celle du GDD. La cible principale est exclue des victimes secondaires ; les victimes déjà touchées par une même chaîne sont exclues des rebonds suivants.

## 4. Résolution instantanée des attaques

La cible principale doit être à portée au moment du tir. Les dégâts sont appliqués à sa position actuelle dans ce même événement : il n’existe pas de seconde vérification de portée à un impact différé.

- Archer et arbalétrier : une cible, sans transfert des dégâts excédentaires.
- Mage et sapeur : explosion centrée sur la position actuelle de la cible principale ; choix des victimes secondaires à cet instant, selon rayon et plafond du défenseur ou de sa branche.
- Troll : première victime puis chaîne de rebonds résolue au même instant. Chaque étape utilise le centre de la dernière victime. Respecter le plafond et l’exclusion des victimes déjà visées.
- Chaman : dégâts directs immédiats et création ou renouvellement de sa malédiction si la cible survit à la phase de tirs.

Une victime secondaire peut être hors de la portée principale du défenseur : elle doit satisfaire le rayon de l’explosion ou la distance du rebond. La portée principale et le rayon secondaire ne sont pas additionnés pour l’acquisition.

Les morts provoquées dans une même phase ne déclenchent pas d’explosion ou d’effet supplémentaire non défini. Les dégâts excédentaires restent perdus ; ils ne se reportent pas sur une nouvelle cible.

## 5. Malédictions hors portée

Une malédiction déjà appliquée continue à infliger ses dégâts à +1 s puis +2 s même si la cible sort de la portée du chaman. La portée conditionne le tir initial, pas le maintien de l’effet.

Les règles déjà validées restent applicables :
- Deux applications périodiques, avec les valeurs du niveau et de la branche du chaman au moment de l’application.
- Un seul effet par couple chaman–cible : une nouvelle attaque du même chaman renouvelle cet effet, remplace ses échéances futures et programme de nouvelles échéances à +1 s et +2 s.
- Au même instant, le dernier dégât périodique précède le renouvellement.
- Les effets de chamans différents sont indépendants.

La mort de la cible ou son retrait à la forteresse annule ses échéances futures. Aucun dégât ne s’applique à un ennemi retiré et aucune récompense supplémentaire n’est versée. Une malédiction ne prolonge pas une vague lorsqu’il ne reste plus d’ennemis présents.

## 6. Événements au même instant

Appliquer les événements selon leur instant de jeu. Lorsqu’ils partagent exactement le même instant, ordre commun validé :

| Phase | Résolution |
| --- | --- |
| 1 | Faire apparaître les ennemis prévus et calculer les positions à cet instant. Marquer ceux qui ont atteint H, sans les retirer encore. |
| 2 | Additionner et appliquer les dégâts des malédictions déjà programmées à cet instant ; retirer les morts et attribuer une seule récompense par mort. |
| 3 | Pour tous les défenseurs prêts, choisir les cibles sur le même état des survivants. Préparer les dégâts directs, explosions et chaînes, puis additionner et appliquer ces dégâts. Retirer les morts, verser leurs récompenses uniques et appliquer ou renouveler les malédictions sur les survivants visés. |
| 4 | Additionner les dégâts de forteresse de tous les survivants ayant atteint H, puis les retirer sans récompense et annuler leurs effets. |
| 5 | Vérifier la défaite, puis la fin de vague et la victoire selon les règles existantes. |

Pour la phase 3, toutes les cibles et chaînes sont déterminées avant l’application des dégâts de cette phase. Plusieurs défenseurs peuvent donc tirer sur le même ennemi et gaspiller une partie de leurs dégâts. Aucun ne bénéficie d’un ordre arbitraire de traitement des emplacements. Chacun consomme normalement son délai de tir.

Un ennemi déjà éliminé en phase 2 n’est pas candidat en phase 3. Une victime prévue dans une chaîne en phase 3 peut recevoir aussi les tirs d’autres défenseurs de cette phase ; les dégâts sont simplement additionnés. La récompense n’est jamais multipliée.

À la frontière de la forteresse, les dégâts de combat de cet instant sont résolus avant les dégâts d’arrivée. Un ennemi tué à cet instant rapporte son or et n’inflige aucun dégât à la forteresse. Cette priorité complète les règles de la v0.9.

Les dégâts d’arrivée simultanés sont additionnés avant le contrôle de défaite ; les PV de forteresse affichés sont bornés à zéro. La défaite est prioritaire si les PV sont nuls, même si la dernière vague vient d’être entièrement résolue. Les récompenses des autres ennemis réellement éliminés dans les phases précédentes restent uniques ; elles ne permettent toujours aucun achat en combat.

## 7. Fractions et fin de vague

Conserver les fractions de dégâts et de PV pendant les calculs de référence, sans arrondi à chaque impact. Une cible meurt dès que ses PV deviennent inférieurs ou égaux à zéro. L’affichage peut être arrondi sans modifier le calcul ; son format reste à concevoir.

Exemple : quatre dégâts de rebond à 16,25 totalisent 65. Quatre valeurs arrondies à 16 ne seraient pas équivalentes. Le choix technique de représentation numérique et les tolérances de calcul sont à documenter lors de l’implémentation ; cette fiche définit les résultats mathématiques attendus.

La vague se termine quand toutes ses apparitions sont passées et que tous ses ennemis ont été éliminés ou retirés à la forteresse. Attendre la fin d’animations purement visuelles n’est pas nécessaire. La forteresse survivante passe à la préparation suivante ; après la vague 10, elle remporte la victoire. Les choix roguelite restent après les vagues 3, 6 et 9.

L’or reste attribué uniquement aux éliminations, une seule fois, y compris par malédiction. Aucun bonus de fin de vague, gain passif ou nouvelle monnaie n’est ajouté.

## 8. Cas de référence à vérifier lors du prototype

| Cas | Situation contrôlée | Résultat attendu |
| --- | --- | --- |
| C-01 | Archer prêt ; première cible à t = 0,3 s | Tir à 0,3 s ; prochain tir au plus tôt à 1,3 s |
| C-02 | Tir à t = 0,3 s ; aucune cible à 1,3 s ; acquisition à 1,8 s | Un tir à 1,8 s, aucun rattrapage ; prochain tir à 2,8 s |
| C-03 | Deux cibles à la même progression | Priorité à celle dont l’ordre d’apparition est le plus ancien |
| C-04 | Deux victimes secondaires à même distance | Départager par progression, puis ordre d’apparition |
| C-05 | Deux archers N1 prêts, un Pillard à 8 PV et un autre Pillard à portée moins avancé | Les deux visent le premier ; 16 dégâts cumulés, une récompense de 3 or ; aucun transfert vers le second |
| C-06 | Malédiction N1 déjà appliquée, cible vivante quittant la portée | 4,8 dégâts à chacune des deux échéances, tant qu’elle reste présente |
| C-07 | Chaman N1 tire à t = 0 puis à 2 s, cible toujours vivante | À 2 s : ancien tick de 4,8, puis tir direct de 12 ; nouvelle malédiction à 3 et 4 s |
| C-08 | Ennemi à 4,8 PV atteignant H au moment d’un tick de 4,8 | Mort par malédiction, récompense unique ; aucun dégât d’arrivée |
| C-09 | Forteresse à 3 PV ; deux survivants infligeant chacun 2 dégâts arrivent ensemble | 4 dégâts cumulés, PV bornés à 0, défaite |
| C-10 | Cible principale à la limite exacte de portée ; victime secondaire à la limite exacte du rayon | Cible principale admissible ; victime secondaire exclue par la règle stricte du rayon |
| C-11 | Dernier ennemi éliminé après la dernière apparition ; animations encore visibles | Fin de vague sans attendre les animations ; effets futurs annulés sur l’ennemi mort |
| C-12 | Plus aucun ennemi en vague 10 ; forteresse à 0 PV après les arrivées | Défaite, aucune victoire simultanée |

Ces cas décrivent des vérifications futures. Aucun prototype jouable ni test automatisé de combat n’est réputé avoir été exécuté par cette fiche.

## 9. Validation et suites

Sont approuvés : le premier tir immédiat lorsque prêt, l’absence de stockage de tirs, les priorités déterministes, la résolution instantanée, le maintien des malédictions hors portée et l’ordre des événements simultanés.

Les règles sont intégrées au GDD v0.10. Les paramètres H existants ne sont pas modifiés. Le format visuel des tirs, les performances et les détails de programmation restent ouverts.

Préparer ensuite le petit catalogue de bonus roguelite et les règles de leur tirage pour les trois choix du prototype. Les synergies, les copies d’unités et les arrondis de l’économie restent aussi à décider avant de considérer la conception du prototype comme complète.
