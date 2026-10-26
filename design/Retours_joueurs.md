# Retours joueurs

Les observations ci-dessous proviennent du joueur. Elles sont séparées des simulations et des hypothèses de correction. Une donnée absente reste à confirmer.

## RJ-001 — Horde, 22 octobre 2026

Source : retour du porteur du projet dans le chat, après son essai. Version exacte à confirmer ; la version distribuée au moment du retour est v0.21.

| Sujet | Retour rapporté |
| --- | --- |
| Équilibre général | Plutôt équilibré avec les améliorations choisies pendant cet essai |
| Dernière vague / boss | Ressentie comme plus simple que les vagues précédentes |
| Clarté générale | Assez claire |
| Améliorations | Après relecture de la liste, les descriptions sont jugées bonnes ; reformulation reportée à plus tard |

Composition, niveaux, branches, bonus, placements, PV, résultat final et durée non relevés. Aucun chiffre ni choix n’est reconstitué comme un fait.

### Pistes à examiner

- Vérifier la difficulté relative de la vague 10 avec les défenses et bonus de fin de partie. Le retour concerne la dernière vague autant que le boss ; il ne suffit pas à isoler ses PV comme cause.
- Conserver les descriptions actuelles, conformément à la clarification du joueur.

Aucun réglage ni texte du jeu modifié sur la base de ce seul retour. Aucun nouveau test lancé ; la demande précédente de ne pas reprendre le contrôle du jeu reste respectée. L6 dispose désormais d’un premier retour humain, à compléter.

## RJ-002 — Victoire Horde, 23 octobre 2026

Source : deux captures de fin de partie envoyées par le porteur du projet dans le chat, puis précision de son ressenti. Version exacte non affichée ; les textes et le délai correspondent à la v0.23 distribuée au moment du retour.

### Résultats visibles

| Indicateur | Valeur relevée |
| --- | --- |
| Résultat | Victoire, dix vagues terminées |
| Forteresse | 14 / 20 PV |
| Or restant | 104 |
| Campagne | 178 éliminés, 4 arrivés, 754 or gagnés au combat |
| Vague 10 | 11 apparus, 11 éliminés, aucun arrivé |
| Combat cumulé affiché | 396,7 secondes, soit environ 6 min 37 s de simulation |
| Vitesse affichée à la fin | ×2 ; historique des changements de vitesse inconnu |
| Préparation affichée | 30 secondes |
| Bonus acquis, dans l’ordre affiché | R-04 Éclats meurtriers ; R-08 Vétérans ; R-06 Impacts appuyés |

Le temps de combat affiché ne mesure pas la durée réelle de la session, ni les préparations et les choix. Le ×2 visible en fin de partie ne prouve pas qu’il a été utilisé pendant toute la run.

### Composition finale

- E2 : lanceur de haches troll, niveau 4, Maître des ricochets. Identification explicite dans le panneau : 62,1 dégâts principaux, intervalle 2 s, portée 3,5 ; trois rebonds de 30,36 dégâts chacun, distance strictement inférieure à 1 ; 350 or investis.
- E3 : chaman niveau 3, identifié visuellement par son apparence et son insigne.
- E4 : lanceur de haches niveau 3, identifié visuellement par son apparence et son insigne.
- E1, E5 et E6 sont libres sur la capture finale ; aucun sapeur visible à cet instant.

Les coûts de référence de ces trois unités totalisent 800 or (350 + 250 + 200), cohérents avec 150 or initiaux + 754 gagnés − 104 restants. Cette cohérence ne reconstitue pas l’historique des achats et ventes ni leur ordre. Les placements et dépenses intermédiaires ne sont pas documentés.

### Interprétation à vérifier

Cette run montre qu’une composition finale à trois défenseurs peut gagner avec ces bonus et placements. La dernière vague ne provoque aucune fuite sur cet essai. Les captures seules ne mesurent ni la tension ressentie ni le temps nécessaire pour éliminer le boss et ne suffisent pas à conclure à un déséquilibre général.

Précision du joueur après discussion de la finale : « c’est mieux et à la fin tout dépend des améliorations que j’ai choisi aussi ». La finale est donc mieux appréciée sur cette run ; le joueur souligne l’influence des améliorations choisies. Cela ne valide pas tous les ensembles de bonus ni un changement des statistiques du boss. Conserver les réglages actuels et comparer d’autres compositions avant d’en déduire une correction. La proposition antérieure de boss à 900 PV n’est pas appliquée.

Captures conservées : [victoire](essais/captures/RJ-002_victoire_horde.png) et [bonus](essais/captures/RJ-002_bonus_horde.png). Aucun paramètre du jeu modifié à partir de ce relevé.

## RJ-003 — Référence au chaman en Alliance, retour du 24 octobre 2026

Le joueur rapporte une partie Alliance jouée la veille et un bonus évoquant les chamans. Nom et version non précisés. Il demande une vérification de la cohérence des unités, bonus et améliorations dans les deux sens. La revue identifie notamment la mention du chaman dans le texte commun de R-02 et des effets sans bénéficiaire dans certaines aides de synergie. [Correction et vérifications v0.34](Coherence_factions_v034.md). Aucun achat adverse n’est rapporté comme constaté par le joueur.

## RJ-004 — Lisibilité et orientation, 26 octobre 2026

Après la livraison v0.53, le porteur du projet choisit d’améliorer la présentation du prototype : visuels, animations et sensations de combat. Il précise que certains encarts contiennent trop d’informations et doivent être condensés ou mieux expliqués pour éviter de perdre les joueurs. Il ne désigne pas d’encart précis dans ce message ; les écrans prioritaires proposés ensuite relèvent de l’analyse de l’agent.

Il retient une direction cartoon s’appuyant sur les codes reconnaissables des unités, avec World of Warcraft comme exemple visuel ; aucune progression permanente pour l’instant, chaque partie repartant à égalité ; et une difficulté exigeante où plusieurs défaites avant la première victoire sont normales.

Ce retour exprime des choix d’orientation. Il ne rapporte pas une nouvelle partie, ne valide pas un taux de victoire mesuré et ne demande aucune valeur numérique particulière. [Décisions et proposition du prochain lot](Orientation_presentation_2026-10-26.md).
