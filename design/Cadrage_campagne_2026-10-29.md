# Cadrage de campagne — décisions du 29 octobre 2026

Complément à la [vision long terme](Feuille_de_route_long_terme.md), révisé à partir des dernières réponses explicites du porteur du projet. Les règles ci-dessous cadrent la future campagne ; le prototype v0.82 n’est pas modifié par ce document. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Règles actuellement retenues

| Identifiant | Décision | Conséquence |
| --- | --- | --- |
| CAMP-002 | Les nouveautés concernent les missions 11–20, 31–40, 51–60, etc. | Chaque nouveauté ou difficulté persiste durant les dix missions de son bloc, puis peut revenir ponctuellement. Il s’agit de missions, pas de vagues de combat. |
| CAMP-003 | Le joueur peut faire une seule mission et s’arrêter | Aucun enchaînement obligatoire de plusieurs missions avant d’obtenir les PO. Les chapitres organisent le contenu, sans imposer une session de dix missions. |
| CAMP-004 | Les PO sont versées à la fin de la première victoire de chaque mission | Crédit définitif lié à cette mission ; rejouer et gagner une mission déjà récompensée ne redonne pas son gain initial. Une défaite ne déclenche pas cette récompense. |
| CAMP-005 | Les gains déjà acquis sont persistants | Arrêter le jeu ou perdre une mission ultérieure ne retire pas les PO déjà versées pour les premières victoires antérieures. La future migration conserve les acquis existants. |
| CAMP-006 | Les récompenses des 100 premières missions doivent couvrir le maximum de points autorisés | Le plafond de points et son prix restent à confirmer ; ce maximum ne permet pas de remplir tous les talents des trois arbres enrichis. Voir l’[orientation des talents](Orientation_talents_2026-10-29.md). |

Les exemples explicites des paliers font foi sur le terme « impaires » de la formulation initiale. L’ancienne suggestion d’introduction aux missions 1–10, 21–30 et 41–50 est écartée. Avec dix missions par chapitre, les nouveaux paliers correspondraient aux chapitres 2, 4, 6, etc. ; le découpage en chapitres reste une cible de contenu.

## Décision remplacée, conservée pour traçabilité

**CAMP-001 — Remplacée par CAMP-003 et CAMP-004 :** plusieurs missions composaient initialement une partie complète, avec gains provisoires jusqu’à la fin globale et absence de retour à l’accueil ou aux talents entre elles. Après avoir relié la durée de session à l’acquisition des PO, le porteur du projet a précisé que le joueur peut s’arrêter après une mission et reçoit ses PO dès sa première victoire. L’ancien regroupement obligatoire ne doit donc plus servir de règle de campagne.

## Questions encore ouvertes

- Nombre de vagues et condition de victoire d’une mission ; présentation du retour au parcours et de la poursuite facultative.
- Réinitialisation ou conservation de l’or de combat, des défenseurs, des PV et des bonus lorsqu’on choisit une nouvelle mission.
- Registre des premières victoires et verrou du mode infini par faction ; les monnaies et talents restent séparés entre les camps.
- Montants des récompenses, coût maximal des points et budget garanti jusqu’à la mission 100 ; financement de la respécialisation après les récompenses uniques.
- Calcul du +1 %, contenu des missions 1–10 et des nouveautés introduites par blocs.

La question du nombre obligatoire de missions par partie est close par la liberté de n’en jouer qu’une. La question du sort des gains provisoires de missions déjà gagnées est remplacée par le crédit définitif à chaque première victoire. Aucun mode de farm supplémentaire, montant ou conversion de monnaies n’est déduit de ces réponses.

## État de réalisation et prochaine intégration

Le prototype v0.82 conserve une carte du Gué et ses dix vagues. Son versement de ressources de fin de partie et ses anciens verrous multi-cartes appartiennent à l’architecture précédente ; ils devront être adaptés à la nouvelle limite de victoire de mission. Il ne livre pas encore le parcours de campagne ni le registre de premières récompenses. La v0.83 ajoute ensuite la [fondation persistante du registre](Registre_missions_v083.md), sans raccorder la nouvelle économie à la mission jouable ; le parcours et ses montants restent à définir.

L’intégration devra enregistrer atomiquement le gain et le statut « récompense déjà versée » pour la mission et le compte concernés. Elle devra vérifier : premier succès crédité une fois, victoire rejouée sans second gain, défaite sans récompense de première victoire, relancement sans perte ni doublon, isolation des factions et conservation des acquis lors de la migration. Cette liste exprime des critères de réalisation à venir, pas des tests déjà exécutés.
