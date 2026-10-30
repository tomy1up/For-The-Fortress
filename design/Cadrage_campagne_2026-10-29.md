# Cadrage de campagne — décisions du 29 octobre 2026

Complément à la [vision long terme](Feuille_de_route_long_terme.md), révisé à partir des dernières réponses explicites du porteur du projet. Les règles ci-dessous cadrent la future campagne ; le prototype v0.82 n’est pas modifié par ce document. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Règles actuellement retenues

| Identifiant | Décision | Conséquence |
| --- | --- | --- |
| CAMP-002 | Les nouveautés concernent les missions 11–20, 31–40, 51–60, etc. | Chaque nouveauté ou difficulté persiste durant les dix missions de son bloc, puis peut revenir ponctuellement. Il s’agit de missions, pas de vagues de combat. |
| CAMP-003 | Le joueur peut faire une seule mission et s’arrêter | Aucun enchaînement obligatoire de plusieurs missions avant d’obtenir les PO. Les chapitres organisent le contenu, sans imposer une session de dix missions. |
| CAMP-004 | Les PO sont versées à la fin de la première victoire de chaque mission | Crédit définitif lié à cette mission ; rejouer et gagner une mission déjà récompensée ne redonne pas son gain initial. Une défaite ne déclenche pas cette récompense. |
| CAMP-005 | Les gains déjà acquis sont persistants | Arrêter le jeu ou perdre une mission ultérieure ne retire pas les PO déjà versées pour les premières victoires antérieures. La future migration conserve les acquis existants. |
| CAMP-006 | Remplacée par CAMP-011 | L’ancien financement des points de talent par les PO est abandonné au profit de l’XP de mission. |
| CAMP-007 | Chaque mission après la 100e donne aussi des PO à sa première victoire | La mission 100 est un repère budgétaire, pas la fin des gains de campagne. |
| CAMP-008 | La boutique ouvre des stratégies grâce à des unités ayant forces et faiblesses | Aucune nouvelle unité ne doit être une remplaçante systématiquement supérieure. Catalogue et tarifs à définir. |
| CAMP-009 | Reset gratuit des talents entre les missions | Tous les points sont rendus sans débit de PO ; la configuration reste fixée pendant la mission. Cette décision remplace la respécialisation payante. |
| CAMP-010 | Un parcours indépendant par faction | Missions réussies et accès au mode infini suivis séparément pour l’Alliance et la Horde. Les 100 premières missions doivent être réussies dans la faction concernée pour y ouvrir l’infini. |
| CAMP-011 | L’XP des missions débloque les points de talent | Les 100 premières missions doivent donner accès aux 51 points maximum. XP versée uniquement à la première victoire de chaque mission, séparément par faction. Les PO ne financent plus les talents. |
| CAMP-012 | Les PO des missions 1–200 servent à la boutique | Dépenses pour les nouvelles unités et autres contenus à définir ; acquisition des points découplée des achats de boutique. |
| CAMP-013 | Chaque mission repart à neuf | Forteresse intacte à son maximum, or initial, aucun défenseur ni bonus temporaire ; XP, PO, talents et futurs déblocages de boutique restent persistants. Réponse explicite du porteur du projet. |
| CAMP-014 | Premier échantillon de trois missions de dix vagues, dans le même thème | Configurations différentes pour comparer les situations ; récompenses et difficulté restent des valeurs de prototype à équilibrer. Choix explicite du 30 octobre 2026. |
| CAMP-015 | Tester une hausse de PV ennemis de 1 % par mission sur cet échantillon | Missions 1/2/3 à 100/101/102 % de PV, mêmes vitesses, dégâts et récompenses de combat. Choix explicite du 30 octobre 2026 ; l’équilibrage et l’extension au parcours complet restent à éprouver. |
| CAMP-016 | Étendre l’essai aux missions 4–10 dans le prochain lot de contenu | Choix explicite du porteur du projet le 30 octobre 2026, après le lot de lisibilité des talents. Les nouvelles valeurs restent des réglages de prototype ; ne pas présenter les sept missions comme livrées avant leur réalisation et leurs essais. |

Les exemples explicites des paliers font foi sur le terme « impaires » de la formulation initiale. L’ancienne suggestion d’introduction aux missions 1–10, 21–30 et 41–50 est écartée. Avec dix missions par chapitre, les nouveaux paliers correspondraient aux chapitres 2, 4, 6, etc. ; le découpage en chapitres reste une cible de contenu.

## Décision remplacée, conservée pour traçabilité

**CAMP-001 — Remplacée par CAMP-003 et CAMP-004 :** plusieurs missions composaient initialement une partie complète, avec gains provisoires jusqu’à la fin globale et absence de retour à l’accueil ou aux talents entre elles. Après avoir relié la durée de session à l’acquisition des PO, le porteur du projet a précisé que le joueur peut s’arrêter après une mission et reçoit ses PO dès sa première victoire. L’ancien regroupement obligatoire ne doit donc plus servir de règle de campagne.

## Questions encore ouvertes

- Nombre de vagues et condition de victoire d’une mission ; présentation du retour au parcours et de la poursuite facultative.
- Réinitialisation acquise par CAMP-013 ; valeurs initiales et difficulté de chaque future mission encore à concevoir.
- Présentation du parcours et des missions verrouillées ; le suivi des réussites et le déblocage du mode infini sont désormais fixés comme indépendants par faction (CAMP-010).
- Montants des récompenses, coût maximal des points et repère de financement jusqu’à la mission 100 hors dépenses facultatives ; équilibre des achats sur toute la campagne.
- Calcul du +1 %, contenu des missions 1–10 et des nouveautés introduites par blocs.

La question du nombre obligatoire de missions par partie est close par la liberté de n’en jouer qu’une. La question du sort des gains provisoires de missions déjà gagnées est remplacée par le crédit définitif à chaque première victoire. Aucun mode de farm supplémentaire, montant ou conversion de monnaies n’est déduit de ces réponses.

## État de réalisation et prochaine intégration

Le prototype v0.82 conserve une carte du Gué et ses dix vagues. Son versement de ressources de fin de partie et ses anciens verrous multi-cartes appartiennent à l’architecture précédente ; ils devront être adaptés à la nouvelle limite de victoire de mission. Il ne livre pas encore le parcours de campagne ni le registre de premières récompenses. La v0.83 ajoute ensuite la [fondation persistante du registre](Registre_missions_v083.md), sans raccorder la nouvelle économie à la mission jouable ; le parcours et ses montants restent à définir.

L’intégration devra enregistrer atomiquement le gain et le statut « récompense déjà versée » pour la mission et le compte concernés. Elle devra vérifier : premier succès crédité une fois, victoire rejouée sans second gain, défaite sans récompense de première victoire, relancement sans perte ni doublon, isolation des factions et conservation des acquis lors de la migration. Cette liste exprime des critères de réalisation à venir, pas des tests déjà exécutés.

## Révision économique : XP et talents

La décision du 29 octobre remplace le financement de 51 points par 510 PO : les points viennent désormais de l’XP. Le barème précis reste provisoire ; l’XP de première victoire uniquement est validée. Voir la [courbe de prototype et les règles acquises](Experience_talents_2026-10-29.md).

## Réalisation du parcours — 30 octobre 2026

La [v0.90](Parcours_campagne_v090.md) raccorde le choix de faction au parcours et la fin de mission au retour facultatif. Les succès sont dérivés du registre existant, sans nouveau schéma de sauvegarde. Seul le Gué est jouable ; les autres positions restent indiquées à venir. Le détail des vagues et des montants futurs reste à définir.
