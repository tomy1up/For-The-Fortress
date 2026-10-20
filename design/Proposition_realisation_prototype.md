# For the Fortress! — Cahier de réalisation du premier prototype

Proposition du 20 octobre 2026, fondée sur le **GDD v0.13**.

**Statut P — organisation, interface et choix de réalisation à valider.** Les règles V et les réglages H du GDD restent la référence. Ce cahier prépare la réalisation ; aucun prototype jouable ni résultat d’équilibrage n’est encore livré. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## 1. Résultat attendu

Obtenir une version locale jouable sur PC, de la sélection d’une faction jusqu’à la victoire ou la défaite sur La Vallée du Gué. Le premier livrable doit permettre de vérifier les règles et de comparer les deux factions avant d’étendre le contenu commercial.

Le périmètre reprend le GDD : une carte, six emplacements, trois types de défenseurs par faction, deux exemplaires maximum par type (H), quatre niveaux, douze branches au total, dix vagues, sept archétypes ordinaires et un boss, douze bonus roguelite et les associations de synergies approuvées. La diversité raciale reste inactive avec ce roster.

Le capital de départ est 150 or, la forteresse commence à 20 PV, les choix de bonus surviennent après les vagues 3, 6 et 9. Toutes ces valeurs conservent leur statut dans le GDD. La cible de 8 à 12 minutes sera mesurée ; elle ne conditionne pas à elle seule la conformité des règles.

Priorité de réalisation proposée : représentation simple et lisible, contrôles fiables, puis amélioration visuelle. Des formes et couleurs temporaires peuvent identifier les unités et ennemis. Aucun achat d’assets ni style graphique final n’est décidé ici.

## 2. Parcours et écrans proposés

| Vue ou panneau — P | Informations et actions | Critère de lecture |
| --- | --- | --- |
| Départ de partie | Choisir Alliance ou Horde ; afficher La Vallée du Gué comme carte du prototype ; lancer la partie | Le joueur comprend qu’il recrute uniquement dans le roster choisi |
| Carte en préparation | Route, pont, forteresse, six emplacements ; or, PV actuels/maximaux, numéro de la prochaine vague et bouton de lancement | La phase active et les emplacements libres sont identifiables |
| Emplacement libre sélectionné | Trois types de la faction, prix courant, nombre déployé / limite ; achat sur cet emplacement | Un achat impossible indique manque d’or ou limite atteinte et ne débite rien |
| Défenseur sélectionné | Type, niveau, branche, dégâts et intervalle, portée, synergies actives, prochain coût et remboursement exact | Le prix réduit et la perte lors d’une vente sont visibles avant l’action |
| Choix de branche N4 | Deux descriptions avec statistiques finales et coût total du passage | Une seule branche est choisie ; aucune branche n’est attribuée silencieusement |
| Carte en combat | Vague en cours, or et PV actualisés ; inspection des unités ; commande d’accélération | Les commandes d’achat, d’amélioration et de vente sont indisponibles |
| Choix roguelite | Trois offres distinctes, description et effet ; sélection d’un seul bonus | Le bonus sélectionné est identifiable et reste consultable pendant la partie |
| Résultat de partie | Victoire ou défaite, vague atteinte et PV restants ; recommencer ou revenir au choix de faction | Une nouvelle partie repart de l’état initial, sans progression persistante |

Ces vues peuvent être des panneaux sur une même scène ; leur nombre ne prescrit pas une architecture. Les informations chiffrées sont reliées aux valeurs réellement utilisées par la simulation. L’affichage peut arrondir les dégâts, mais ne doit pas modifier les calculs.

Proposition pour le N4 : ouvrir le choix après demande d’amélioration, puis confirmer branche et paiement ensemble. Fermer sans choisir conserve l’unité au N3 et ne débite rien. Cette transaction d’interface reste P ; le choix exclusif et son coût inclus sont déjà V.

Proposition pour l’accélération : deux vitesses, ×1 et ×2, fondées sur le même temps de jeu. Le principe d’accélération est V ; ces multiplicateurs sont P/H. La pause, les raccourcis et la sauvegarde restent ouverts. Aucune reprise de partie enregistrée n’est requise par ce cahier.

## 3. Enchaînement des phases

Départ → sélection de faction → préparation de la vague 1 → combat → préparation de la vague suivante.

Après les vagues 3, 6 et 9 entièrement résolues, insérer le choix roguelite avant le lancement suivant. Proposition d’interface : empêcher le lancement tant que ce choix n’est pas fait ; laisser ensuite le joueur préparer sa défense avec le bonus actif.

Pendant un combat, aucune construction, amélioration, vente, modification de branche ou permutation de position. Changer d’emplacement exige une vente et un nouvel achat au N1 entre les vagues. Les inspections restent disponibles.

La vague se termine seulement quand toutes les apparitions ont eu lieu et que tous ses ennemis ont été éliminés ou retirés à l’arrivée. La forteresse à zéro PV provoque la défaite ; la défaite est prioritaire si plusieurs événements de fin surviennent ensemble. La victoire exige la résolution de la vague 10 avec une forteresse survivante.

Un nouvel essai réinitialise or, PV, unités, investissements, branches, bonus, synergies, vague et événements de combat. Aucun gain permanent n’est introduit.

## 4. Contrats de réalisation proposés

| Domaine | Référence à respecter | Vérification attendue |
| --- | --- | --- |
| Carte | Coordonnées et trajet des sections 18 à 20 | Longueur 28 ; six positions exactes ; distances avant projection isométrique |
| Temps et attaques | Sections 21 à 24 | Premier tir prêt, priorités déterministes, ticks puis tirs puis arrivées |
| Défenseurs | Sections 5, 6 et 12 à 17 | Six fiches N1, progression, douze branches et effets secondaires conformes |
| Vagues | Sections 9 à 11 | Dix séquences, quantités, espacements internes et délais entre groupes |
| Économie | Sections 7, 28 et 35 à 39 | Investissement par exemplaire, prix réduits au plafond et vente au plancher |
| Bonus | Sections 25 à 29 | Trois choix distincts, un seul acquis ; choix acquis exclus des offres futures |
| Synergies | Sections 30 à 36 | Conditions, code appliqué une seule fois par bénéficiaire et recalcul sans accumulation |

Conserver une fiche de réglages identifiable pour chaque essai : version du GDD, prix, dégâts, cadences, portées, ennemis et vagues. Séparer autant que possible ces valeurs H de la logique de résolution pour ajuster l’équilibrage sans changer les règles.

Prévoir des contrôles internes permettant de reproduire les cas du GDD : positions et PV imposés, instant de tir et liste des événements. Ces moyens servent à vérifier le prototype ; ils ne constituent pas de nouveaux pouvoirs pour le joueur.

L’affichage et les animations suivent les dégâts instantanés approuvés. Un projectile visuel ne décale pas l’impact. Les curseurs de vitesse doivent accélérer tous les événements de simulation de façon cohérente, sans modifier leur ordre.

## 5. Ordre de construction proposé

| Lot — P | Travail | Livrable vérifiable avant la suite |
| --- | --- | --- |
| L0 — Préparer | Confirmer moteur, version, langage et cible locale ; créer une base minimale dans le dépôt existant | Projet qui s’ouvre, démarre et produit un exécutable de test |
| L1 — Faire traverser la carte | Tracé logique, projection, six emplacements ; Pillards en déplacement ; arrivées et PV | Un Pillard non attaqué traverse 28 unités à vitesse 1 en 28 s et retire 1 PV sans donner d’or |
| L2 — Installer la boucle minimale | Une faction, achats N1, tirs automatiques, récompenses, vague 1 et préparation suivante | Départ à 150 or ; achats et ventes entre vagues ; aucune transaction en combat |
| L3 — Couvrir le combat | Six défenseurs, sept archétypes et boss ; groupe, rebonds, malédictions et résolution simultanée | Les douze cas de combat de la section 24 passent avant d’évaluer la difficulté |
| L4 — Étendre la progression | Niveaux, branches N4, limite de copies et historique des dépenses | Statistiques conformes ; troisième copie bloquée ; vente et rachat au N1 vérifiés |
| L5 — Jouer une partie complète | Dix vagues, défaite, victoire, choix roguelite et synergies | Les deux factions peuvent lancer les dix vagues ; les fins de partie et réinitialisations sont correctes |
| L6 — Vérifier et observer | Cas économiques, tirages, synergies, vitesses et essais des deux factions | Résultats consignés, anomalies triées, propositions d’équilibrage séparées des règles |

« Une faction » au lot L2 est un ordre de réalisation temporaire ; le prototype final conserve les deux factions. Le lancement des dix vagues ne garantit pas qu’une composition quelconque puisse les gagner. La présence d’une stratégie de victoire sera recherchée et mesurée lors des essais.

Pas d’estimation calendaire ou budgétaire ferme avant le choix technique et les premiers lots. Une anomalie de règle doit être corrigée avant d’interpréter un échec comme un problème d’équilibrage.

## 6. Critères d’acceptation proposés

### Conformité des règles

- Chaque achat exige emplacement libre, quota disponible et or suffisant ; en cas d’échec, aucun débit ni unité partiellement créée.
- N4 exige une seule branche, incluse dans le passage de niveau. Deux copies peuvent avoir des branches différentes sans contourner le quota du type de base.
- Un ennemi mort rapporte une seule récompense, y compris sous plusieurs tirs ou malédictions ; une arrivée ne rapporte rien.
- Les douze cas de combat de la section 24 et les douze cas de recrutement/vente de la section 39 sont exécutés et leurs résultats consignés.
- Un arbalétrier payé 75 rend 52 ; deux ventes rendent 104. Un exemplaire payé 68 + 45 + 90 + 135 rend 236. R-11 acquis plus tard ne modifie pas les dépenses passées.
- Les bonus choisis sont exclus des tirages suivants ; chaque offre contient trois codes distincts. Tester les conditions par niveau, l’exclusion du chaman de R-02 et les 4 PV supplémentaires de R-09.
- Une même synergie ne double pas avec deux partenaires identiques ; un partenaire restant peut maintenir l’effet. Le recalcul répété sans changement ne modifie pas les valeurs.
- À ×1 et ×2, une situation contrôlée identique conserve mêmes éliminations, récompenses et PV aux mêmes instants de jeu ; la durée réelle change.

### Séquence et budgets

Exécuter aussi un scénario contrôlé où chaque ennemi est éliminé, pour vérifier les comptes sans prétendre démontrer une stratégie gagnante. Les dix vagues représentent 182 ennemis, 10 944 PV bruts et 770 or de récompenses. Avec les 150 or initiaux, le revenu brut atteint 920 avant dépenses, dont 816 avant la vague 10. La somme de 273,1 s couvre les fenêtres d’apparition des dix vagues ; elle exclut les fins de combat et les préparations.

Dans une partie réelle, consigner les éliminations et arrivées : le revenu peut être inférieur à ces plafonds. Deux exemplaires N1 de chaque type coûtent 450 or ; trois unités distinctes N4/N3/N2 coûtent 725 sans bonus. Ces références ne définissent pas une composition obligatoire.

### Lisibilité et essais de jeu

Vérifier qu’un joueur peut identifier sa phase, son or, ses PV, le niveau d’une unité, le prix de sa prochaine amélioration et le remboursement avant vente. Relever les erreurs de compréhension et les actions impossibles mal expliquées.

Pour chaque essai : faction, placements E1–E6, achats et niveaux par vague, branches, bonus, synergies, fuites, PV restants, or restant, durée de combat et durée de préparation. Conserver également l’ordre des offres roguelite pour expliquer les différences entre parties.

Comparer des essais avec les mêmes réglages et, quand possible, les mêmes offres. Une proposition de modification H doit préciser la valeur précédente, la valeur testée et le résultat observé. Ni une victoire isolée ni le DPS théorique ne suffisent à conclure à l’équilibre des factions.

## 7. Décisions techniques à prendre

| Sujet | État actuel | Proposition de traitement |
| --- | --- | --- |
| Moteur | Godot envisagé, non confirmé | Confirmer ce choix avant L0 ; ne pas créer une dépendance technique comme si elle était déjà approuvée |
| Version et langage | O | Fixer une version exacte et un langage après confirmation du moteur, puis les documenter dans le README |
| Représentation numérique | O | Choisir une méthode qui reproduit les fractions et les égalités de temps du GDD ; documenter les tolérances |
| Organisation des fichiers | O | Définir scènes, données et contrôles dans le projet retenu ; garder les documents actuels dans le même dépôt |
| Vitesse | Accélération V, facteurs O | Essayer ×1 / ×2 — P/H ; vérifier la cohérence des événements |
| Affichage | Inspection V, présentation O | Examiner les panneaux proposés en section 2 avant intégration au GDD |
| Distribution de test | Cible PC ; Steam commercial envisagé | Commencer par une version locale ; aucune publication Steam engagée par cette proposition |

## 8. Passage à la réalisation

Ce cahier propose de valider le parcours d’interface, les lots L0–L6 et les critères d’acceptation comme cadre du premier prototype. Les choix techniques ouverts doivent être consignés explicitement. La validation du cahier ne confirme pas à elle seule une version de moteur ou un langage encore absents de la décision.

La prochaine action concrète après examen est de fixer le socle technique de L0, puis de réaliser L1 : une carte traversable, six emplacements et une forteresse qui perd correctement ses PV. Les autres lots suivent les critères ci-dessus ; le contenu commercial reste une étape ultérieure.
