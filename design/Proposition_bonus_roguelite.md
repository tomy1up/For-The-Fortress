# For the Fortress! — Bonus roguelite approuvés du prototype

Approuvés le 20 octobre 2026 et intégrés au GDD v0.11.

**Statut V — catalogue, tirage et règles de calcul approuvés.** Les douze noms sont provisoires ; toutes les valeurs sont des hypothèses H à tester. Le GDD approuvé est en version 0.11. Les quelque 60 bonus envisagés pour la version commerciale restent une cible, sans engagement de production.

## 1. Ce qui est déjà validé

Après les vagues 3, 6 et 9, choisir un bonus parmi trois propositions aléatoires. Les bonus sélectionnés restent actifs jusqu’à la fin de la partie. Cette fiche conserve ces trois choix et n’ajoute ni monnaie persistante, ni relance, ni rareté ou autre moment de sélection.

## 2. Catalogue approuvé

Les effets concernent la faction jouée, ses unités présentes et ses futurs recrutements, sauf précision. Les défenseurs des deux factions restent séparés. Un bonus ne crée aucune unité ni copie supplémentaire.

| Code | Nom provisoire | Effet de référence — H | Limite et contrepartie de choix |
| --- | --- | --- | --- |
| R-01 | Armes affûtées | +10 % à tous les dégâts des défenseurs | Dégâts directs, secondaires et périodiques ; aucun gain de portée ou de cadence |
| R-02 | Exercice de tir | +12 % de fréquence d’attaque à l’archer, l’arbalétrier, le mage, le troll et le sapeur | Exclut explicitement le chaman pour préserver ses deux échéances de malédiction |
| R-03 | Postes d’observation | +0,5 unité à la portée principale de chaque défenseur | Ne modifie pas les rayons, rebonds, plafonds de victimes ou dégâts |
| R-04 | Éclats meurtriers | +20 % aux dégâts des victimes secondaires des explosions et rebonds | Mage, troll et sapeur ; aucun effet sur le dégât principal ou la malédiction |
| R-05 | Propagation | +0,2 unité aux rayons d’explosion et à la distance de chaque rebond | Mage, troll et sapeur ; plafonds de victimes et dégâts inchangés |
| R-06 | Impacts appuyés | +15 % aux dégâts directs de la cible principale | Tous les défenseurs, y compris le tir initial du chaman ; aucun effet secondaire ou périodique |
| R-07 | Recrues aguerries | +15 % à tous les dégâts des défenseurs actuellement N1 ou N2 | Le bonus cesse de s’appliquer à une unité dès son passage au N3 |
| R-08 | Vétérans | +12 % à tous les dégâts des défenseurs actuellement N3 ou N4 | Aucun effet sur les unités N1 ou N2 ; s’applique aussi aux branches N4 |
| R-09 | Maçonnerie renforcée | +4 PV maximum de forteresse et +4 PV actuels à la sélection | Nouveau maximum conservé jusqu’à la fin ; aucun soin automatique ultérieur |
| R-10 | Ateliers efficaces | −10 % au prix des améliorations N1→N2, N2→N3 et N3→N4 futures | Aucun remboursement rétroactif et aucun effet sur le prix d’achat |
| R-11 | Recrutement organisé | −10 % au prix des achats futurs de défenseurs | Aucun remboursement rétroactif et aucun effet sur les améliorations |
| R-12 | Chasse aux colosses | +20 % aux dégâts infligés aux Brutes, Colosses, Élites et au Seigneur de siège | Aucun effet contre Grouillants, Pillards, Sprinters et Maraudeurs ; ne modifie pas le ciblage |

Un choix consomme une des trois sélections de la partie : les gains ne sont pas acquis simultanément. Les options de dégâts, de couverture, de survie et de prix ne sont pas considérées équivalentes avant les essais.

## 3. Tirage approuvé

- Les douze bonus sont accessibles dès le premier choix pour chacune des deux factions.
- Chaque bonus du catalogue possède au moins un bénéficiaire potentiel dans le roster de chaque faction. Aucune condition liée aux unités actuellement déployées, au niveau atteint ou à la branche choisie n’est ajoutée.
- Tirer trois codes distincts, avec poids égaux, sans remise à l’intérieur de cette offre.
- Après sélection, retirer uniquement le bonus choisi du catalogue de la partie. Il ne peut plus être offert ni sélectionné une seconde fois.
- Les deux offres non choisies retournent dans le catalogue disponible et peuvent réapparaître plus tard.
- Pas de relance, de rareté, de coût de sélection ou de cumul de plusieurs copies du même bonus pour ce prototype.
- Choisir un seul bonus avant de reprendre la préparation et de lancer la vague suivante. Ses effets commencent dès la sélection, y compris les réductions de prix utilisables pendant cette même préparation.
- Réinitialiser tous les choix et effets à la fin de la partie.

Le catalogue disponible compte donc 12 bonus après la vague 3, 11 après la vague 6 et 10 après la vague 9, avant chacun de ces tirages. Il contient toujours au moins trois offres possibles. Ces nombres supposent les douze entrées actives et la sélection d’un seul bonus à chaque étape.

Un bonus de niveau ou d’attaque de groupe peut être proposé avant qu’une unité bénéficiaire soit recrutée : son intérêt futur doit être lisible dans sa description. Aucune promesse de rareté, garantie de catégorie ou adaptation cachée du tirage n’est ajoutée.

## 4. Cumul des dégâts approuvé

Calculer d’abord les statistiques de référence de l’unité à son niveau et, au N4, de sa branche. Ces valeurs constituent le socle avant bonus. Ne pas appliquer à nouveau × 3,25 aux valeurs finales spécialisées.

Pour chaque victime et chaque composante de dégâts :

Dégât final = dégât de référence de la composante × (1 + somme des pourcentages applicables).

Les pourcentages de R-01, du bonus de niveau applicable R-07 ou R-08, de R-12 selon le type de victime et du bonus de composante R-04 ou R-06 s’additionnent. Ils ne se multiplient pas successivement.

| Composante | Pourcentages applicables dans ce catalogue |
| --- | --- |
| Dégât principal direct | R-01 + R-06 + R-07 ou R-08 selon le niveau + R-12 selon la victime |
| Dégât secondaire d’explosion ou rebond | R-01 + R-04 + R-07 ou R-08 selon le niveau + R-12 selon la victime |
| Chaque dégât périodique de malédiction | R-01 + R-07 ou R-08 selon le niveau + R-12 selon la victime |

Les dégâts secondaires de référence se calculent avec le coefficient du niveau ou de la branche avant les bonus. Ils ne sont pas recalculés à partir d’un dégât principal déjà bonifié : R-06 ne se transmet donc pas aux explosions, rebonds ou malédictions.

R-12 se vérifie séparément sur chaque victime : une explosion visant un Pillard peut toucher une Brute secondaire et bonifier uniquement cette dernière. Le ciblage principal sur le plus avancé reste inchangé.

Les effets liés au niveau sont recalculés lors d’une amélioration entre les vagues. R-07 reste sélectionné après le passage d’une unité au N3, mais cesse d’affecter cette unité ; il peut encore bénéficier à d’autres unités N1/N2. Sélectionner R-07 et R-08 couvre les deux groupes de niveaux, sans les additionner sur une même unité.

Lorsqu’une malédiction est appliquée, conserver sa valeur calculée pour ses deux échéances selon les règles du GDD. Les bonus ne créent pas de dégâts supplémentaires après la mort ou le retrait de la cible.

Ces formules couvrent ce catalogue, sans résistance pour le premier essai. Les interactions avec de futures résistances, bonus supplémentaires et synergies restent à définir ; elles ne sont pas déduites de cette proposition.

## 5. Portée cadence et rayons

R-03 ajoute 0,5 à la portée principale de référence, après la branche éventuelle. Exemples : sapeur 3 → 3,5 ; Veilleur 5 → 5,5 ; Sentinelle 6,5 → 7. Le calcul des distances et la règle d’acquisition inclusive restent ceux de la carte.

R-05 ajoute 0,2 au rayon d’explosion ou à la distance de chaque rebond, après la branche. Exemples : explosion de base 1 → 1,2 ; Artificier des foules 1,4 → 1,6 ; rebond du troll 1 → 1,2. La comparaison de rayon reste strictement inférieure ; les plafonds de victimes et exclusions des chaînes restent inchangés.

R-02 modifie la fréquence d’attaque, et non directement le pourcentage de réduction de l’intervalle :

Nouvel intervalle = intervalle de référence ÷ 1,12.

L’archer de base passe de 1 s à environ 0,892857 s ; l’arbalétrier de 2,5 s à environ 2,232143 s. Ne pas utiliser intervalle × 0,88 : ce serait un autre réglage. Conserver la valeur non arrondie dans les calculs.

Le chaman est exclu de R-02. Son tir toutes les 2 s renouvelle sa propre malédiction, dont le dernier dégât précède le renouvellement à +2 s. À intervalle plus court, le renouvellement peut supprimer cette deuxième échéance. Exemple théorique d’une application naïve de R-02 au chaman N1 sur une cible toujours vivante : intervalle 2 ÷ 1,12 ≈ 1,785714 s ; un seul tick de 4,8 survient avant chaque renouvellement, et le débit à long terme devient (12 + 4,8) ÷ (2 ÷ 1,12) = 9,408 DPS au lieu de 10,8. Le bonus ne doit pas dégrader silencieusement son rôle.

Cette exclusion donne à R-02 trois bénéficiaires potentiels dans l’Alliance et deux dans la Horde. Son intérêt relatif entre factions doit être testé. Les bonus R-01, R-06, R-07/R-08, R-03 et R-12 peuvent renforcer le chaman selon leur effet propre ; R-04 et R-05 ne le concernent pas.

## 6. Forteresse et économie

R-09 augmente le maximum de PV de 4 et les PV actuels de 4, sans dépasser le nouveau maximum. Exemple : 10/20 devient 14/24 ; 20/20 devient 24/24. Il ne ressuscite pas une forteresse détruite : le choix n’est accessible qu’après une vague terminée avec survie. À 24 PV actuels, la forteresse peut survivre à l’arrivée du boss infligeant 20 dégâts et rester à 4 PV, contrairement au cas initial à 20 PV. Cet effet sur la victoire est une conséquence approuvée à tester explicitement.

Pour R-10 et R-11, appliquer la réduction au prix de référence puis arrondir le prix à l’entier supérieur, avec un coût minimal de 1 or. Ce minimum ne change aucun prix actuel. Les deux bonus concernent des opérations différentes et ne se multiplient donc pas sur un même prix.

| Opération | Prix de référence H | Prix avec son bonus de réduction |
| --- | --- | --- |
| Achat du défenseur à 50 or | 50 | 45 |
| Achat du défenseur à 75 or | 75 | 68 |
| Achat du défenseur à 100 or | 100 | 90 |
| Amélioration N1 vers N2 | 50 | 45 |
| Amélioration N2 vers N3 | 100 | 90 |
| Amélioration N3 vers N4 et choix de branche | 150 | 135 |

Les dépenses déjà payées ne changent pas. La vente reste à 70 % du montant réellement payé pour cette unité, achats et améliorations compris. Aucun remboursement ne se calcule sur un prix plein non payé ; aucune différence n’est rendue lors de la sélection d’un bonus de prix. La règle générale d’arrondi des ventes reste ouverte, distincte de l’arrondi approuvé pour ces prix réduits.

Exemple si les deux bonus sont acquis avant l’achat et toutes les améliorations d’un arbalétrier : 68 + 45 + 90 + 135 = 338 or investis ; vente théorique 236,6 or avant l’arrondi restant à définir. Ce n’est pas le scénario de dépenses initial du GDD, où certains achats précèdent les choix roguelite.

Les revenus maximaux des vagues ne changent pas : R-10 et R-11 réduisent des dépenses et n’ajoutent aucune récompense. Les budgets et DPS sans bonus du GDD demeurent des références, pas les résultats d’une partie avec bonus.

## 7. Exemples de calcul

| Cas | Calcul et résultat attendu |
| --- | --- |
| Archer N4 avec R-01 et R-06 | 26 × (1 + 0,10 + 0,15) = 32,5 dégâts par tir ; cadence inchangée |
| Mage N1 avec R-01 et R-06 | Principal : 27 × 1,25 = 33,75 ; secondaire : 10,8 × 1,10 = 11,88 par victime |
| Mage N1 avec R-01 et R-04 | Principal : 29,7 ; secondaire : 10,8 × 1,30 = 14,04 par victime |
| Archer N4 avec R-01 et R-02 | 28,6 dégâts, intervalle 1 ÷ 1,12 ; DPS continu 32,032 |
| Chaman N1 avec R-01 | 13,2 directs et deux ticks de 5,28 ; DPS continu 11,88 si cycle complet |
| Archer N2 avec R-07, puis passage N3 | N2 : 12 × 1,15 = 13,8 ; N3 : 18, R-07 ne s’applique plus |
| Archer N3 avec R-08 et R-12 contre une Brute | 18 × (1 + 0,12 + 0,20) = 23,76 dégâts ; contre un Pillard : 20,16 |

Ces calculs ne démontrent pas l’équilibre des offres. Le placement, les seuils d’élimination, les dégâts excédentaires et l’économie peuvent modifier fortement leur intérêt.

## 8. Essais à mener et suites

Vérifications proposées :
- Trois codes distincts par offre ; un code choisi absent des offres suivantes ; offres non choisies à nouveau possibles.
- Trois choix seulement, après les vagues 3, 6 et 9 ; catalogue restant de 12, 11 et 10 avant tirage.
- R-02 inactif sur toutes les branches du chaman et sans effet sur les échéances de malédiction.
- R-04/R-06 séparés : aucun double calcul du bonus principal dans les dégâts secondaires.
- R-07/R-08 recalculés au changement de niveau ; aucun cumul des deux sur la même unité.
- R-12 évalué par victime, sans priorité de ciblage supplémentaire.
- R-09 augmente maximum et PV actuels une seule fois ; les dégâts futurs restent normaux.
- R-10/R-11 sur les dépenses futures seulement ; investissement réel conservé pour les ventes.
- Comparer les bonus à même carte, faction, budget et composition, puis avec des compositions adaptées à chaque choix.
- Mesurer les fuites, les PV de forteresse, l’accès aux spécialisations et la réussite, en plus du DPS théorique.

Aucun essai jouable n’a validé ces réglages. Il faudra surveiller la supériorité éventuelle des bonus de prix acquis tôt, les emplacements centraux avec portée accrue et le poids de R-12 contre les dernières vagues.

Sont approuvés : les douze entrées, leur éligibilité commune, le tirage uniforme sans doublon d’offre, l’exclusion des bonus déjà choisis, les additions de pourcentages et les règles spécifiques de cadence, forteresse et prix.

Le catalogue et les règles sont intégrés au GDD v0.11. Étape proposée suivante : définir les synergies du prototype, puis trancher les copies d’unités et l’arrondi des ventes pour terminer les règles nécessaires au premier prototype.
