# Feuille de route — vision long terme

**Dernière orientation économique :** l’XP des missions doit débloquer les 51 points de talent sur les cent premières missions ; les PO des missions 1–200 servent à la boutique. Cette décision remplace le financement des talents par les PO. [Détail et hypothèses](Experience_talents_2026-10-29.md).

Vision du 28 octobre 2026, clarifiée puis révisée le 29 octobre 2026. Référence de conception évolutive liée au [suivi du prototype](Suivi_prototype.md). Aucun calendrier ni engagement commercial n’est déduit des cibles. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Sources et statuts

Le porteur du projet a fourni le texte de sa vision, une capture de parcours Duolingo et l’ancienne réponse de l’assistant, issus du [tchat de référence](https://chatgpt.com/s/t_6ae259b3fce88191bd6dcebbf0384277). Le lien seul n’était pas consultable ; le texte recopié dans le présent tchat fait foi. La capture inspire l’organisation du parcours, sans reprise de ses illustrations, monnaies, mécaniques ou éléments d’interface non demandés.

**V :** orientation explicitement demandée. **C :** cible de contenu ou de progression, non engagement de production. **H :** valeur ou règle d’équilibrage à tester. **P :** proposition de l’ancienne réponse, non approuvée par sa seule citation. **O :** question ouverte.

## Vision fournie par le porteur du projet

| Sujet | Orientation | Statut et limites |
| --- | --- | --- |
| Monnaie de progression | Pièces d’Or, PO ou Gold, pour acheter les points de talents | V pour le nom et l’usage ; conserver les comptes propres aux deux factions, sauf nouvelle décision |
| Campagne | 200 missions ou niveaux | C ; une seule carte jouable actuellement |
| Missions 1–100 | Difficulté graduelle, référence de +1 % par carte | V pour la progression ; H pour la valeur et O pour son calcul et les paramètres concernés |
| Récompense de mission | Chaque mission donne des PO lors de sa première victoire, y compris les missions après la 100e. Les victoires répétées sur cette mission ne redonnent pas ce gain ; une défaite ne le déclenche pas | V, précision du 29 octobre ; montants et granularité du suivi par faction à définir |
| Liberté d’arrêt | Le joueur peut ne faire qu’une mission et s’arrêter après son résultat ; aucun regroupement obligatoire de missions avant de recevoir les PO | V, révision explicite du 29 octobre ; poursuivre d’autres missions reste facultatif |
| Parcours | Présentation par chapitres et missions, inspirée du parcours Duolingo | V pour l’orientation visuelle ; interface détaillée à concevoir |
| Chapitres | Première idée : 10 missions par chapitre | C/H, découpage à confirmer avant production du contenu |
| Environnements | Changement de thème tous les deux chapitres | C ; identité et quantité d’assets non définies |
| Introduction des mécaniques | Une nouveauté ou difficulté persiste aux missions 11–20, puis une autre aux missions 31–40, 51–60, etc. ; chacune peut ensuite réapparaître ponctuellement | V, précision explicite du 29 octobre ; contenu des nouveautés et fréquence des réapparitions à définir |
| Mission 100 | Le cumul des premières victoires des missions 1–100 doit suffire pour acheter le maximum de points autorisés si ces PO sont consacrées aux points. Les achats en boutique ou autres dépenses peuvent retarder cet objectif | V, précision du 29 octobre ; plafond, prix et montants à confirmer, aucun arrêt des gains après 100 |
| Boutique | Nouvelles unités et possibilités stratégiques, avec forces et faiblesses, plutôt que remplaçantes systématiquement plus puissantes | V pour cette orientation ; catalogue, tarifs et conditions à concevoir |
| Choix de talents | Trois arbres nettement plus fournis que le prototype ; le plafond de points commun aux trois arbres doit empêcher d’en acheter ou remplir tous les talents | V, précision du 29 octobre ; contenu, rangs et plafond à concevoir |
| Mode infini | Débloqué après avoir terminé les 100 premières missions ; vagues sans fin | V pour le principe et le verrou ; réalisation après validation de la campagne |
| Génération en infini | Carte complexe potentiellement générée aléatoirement | P du porteur du projet, formulée comme question ; méthode non arrêtée |
| Finalité de l’infini | À déterminer | O ; aucun score, classement ou service en ligne implicitement approuvé |
| Mode évènement | Peut-être un format permettant d’innover | P ; pas un mode confirmé |

Si le découpage est retenu sur les 200 missions, il implique arithmétiquement 20 chapitres et 10 blocs thématiques de 20 missions ; les 100 premières missions correspondraient à 10 chapitres et 5 blocs. Ces nombres sont dérivés de la proposition, sans choix des thèmes ni promesse de 200 cartes géométriquement uniques.

## Règles actuelles après la révision du 29 octobre 2026

- Le joueur peut effectuer **une seule mission** et s’arrêter. Les PO de première réussite sont versées **à la victoire de cette mission**, sans attendre d’en réussir plusieurs. Cette précision remplace le regroupement obligatoire précédemment retenu.
- Les PO déjà acquises restent persistantes ; une défaite sur une mission suivante ne reprend pas les récompenses des missions déjà gagnées. Une mission perdue ne déclenche pas sa récompense de première victoire.
- Les nouveaux paliers portent sur les **missions**, et non sur les vagues de combat. Les exemples explicites sont **11–20, 31–40, 51–60, etc.** ; ils remplacent l’interprétation antérieure 1–10, 21–30, etc.
- La nouveauté reste présente durant les dix missions de son bloc, puis peut revenir de façon éparse sur des cartes ultérieures. Le contenu des blocs intermédiaires et les règles de retour restent ouverts.

Avec le découpage proposé de dix missions par chapitre, ces paliers correspondraient aux chapitres 2, 4, 6, etc. Cette correspondance est un calcul de repérage, pas une redéfinition des exemples du porteur du projet. Les missions 1–10 restent à cadrer comme début de campagne ; aucune mécanique supplémentaire n’est déduite de leur absence dans cette liste.

| Bloc de missions | Règle confirmée ou limite |
| --- | --- |
| 1–10 | Début de campagne, contenu à définir |
| 11–20 | Nouvelle difficulté ou mécanique persistante durant ces dix missions |
| 21–30 | Pas d’introduction systématique fixée ; retour ponctuel ultérieur possible selon le contenu |
| 31–40 | Nouvelle difficulté ou mécanique persistante durant ces dix missions |
| 41–50 | Même limite : contenu et réapparitions à définir |
| 51–60, puis 71–80, etc. | Même rythme d’introduction par blocs de dix missions |

Ces blocs fixent un rythme de contenu, pas une obligation d’enchaîner leurs dix missions en une session. Le découpage en chapitres ne retarde pas le versement des PO. Voir les [décisions de cadrage datées et leur révision](Cadrage_campagne_2026-10-29.md).

## Propositions de l’ancienne réponse à conserver pour discussion

| Proposition citée | Statut actuel |
| --- | --- |
| Missions 1–100 pour découvrir les mécaniques et développer les talents ; 101–200 comme campagne avancée avec le maximum de points | P ; rôle précis de la seconde moitié à confirmer |
| Chapitres impairs de découverte, pairs de combinaison ; introduction aux missions 1–10, 21–30, 41–50, etc. | Interprétation écartée par la précision du 29 octobre : les nouvelles introductions visées sont 11–20, 31–40, 51–60, etc. ; aucun rôle de « combinaison » systématique n’est approuvé pour les blocs intermédiaires |
| Réserver d’abord les PO aux talents | Pas de réserve imposée approuvée : le joueur peut privilégier la boutique et retarder ses points. La référence de financement à la mission 100 exclut ces dépenses facultatives |
| Réattribution gratuite des talents | D’abord écartée, puis explicitement retenue par le porteur du projet le 29 octobre : reset gratuit entre les missions, talents fixés pendant la mission |
| Maximum de points achetables distinct du total des rangs de talents ; choix de builds conservés | Principe désormais V : le porteur du projet exige des arbres bien plus fournis et des choix stratégiques entre les trois ; nombres et contenu restent à définir |
| Apparences, titres ou personnalisation de forteresse pour les missions 101–200 | P uniquement pour ces récompenses supplémentaires ; les PO de première victoire continuent bien après la mission 100, conformément à la précision du porteur du projet |
| Records personnels de vagues ou score ; records par configuration ; défi hebdomadaire commun | P ; aucune infrastructure réseau ou calendrier d’évènement engagé |
| Structures de cartes validées avec variations aléatoires plutôt que génération entièrement libre | P ; méthode à comparer et valider |

## Cohérence avec les décisions déjà acquises

- **Factions séparées :** monnaies, points, arbres et compteurs de respécialisation distincts Alliance/Horde. Un point dépensé dans un camp n’incrémente pas l’autre.
- **Talents :** trois arbres par faction, progression verticale avec seuils de points investis dans le même arbre. Ils devront être nettement enrichis et partager un plafond d’investissement suffisamment inférieur à leur capacité totale pour imposer des choix de style. La v0.85 propose désormais 21 talents par arbre et un plafond de prototype de 51 points ; effets et prix de 10 PO restent provisoires. Voir l’[orientation des talents](Orientation_talents_2026-10-29.md).
- **Respécialisation :** gratuite entre les missions, talents fixés pendant la mission. Cette décision du 29 octobre remplace le tarif progressif plafonné. Les anciens compteurs restent des données historiques du profil, sans effet sur le coût nul.
- **Limite de récompense révisée :** les PO de première victoire sont versées à la fin de la mission gagnée, avec possibilité de s’arrêter après une seule mission. L’ancien verrou imposant plusieurs missions avant le versement est remplacé pour la future campagne. Les talents ne se modifient pas pendant un combat ; aucun achat de talents en pleine mission n’est ajouté.
- **Persistance :** conserver les acquis après fermeture et protéger la progression locale. La sauvegarde en ligne Steam reste une piste, sans service en ligne livré.

La nouvelle récompense de première victoire diffère du prototype, qui attribue encore des ressources selon les vagues et l’issue de la partie. Elle n’est pas encore appliquée au jeu. La dernière précision du 29 octobre remplace l’attente d’une fin globale multi-missions : chaque première victoire de mission déclenche son propre versement définitif. Les montants, le suivi des premières victoires par faction et la transition vers ce nouveau régime restent à définir. Les acquis déjà sauvegardés ne doivent pas être effacés lors de cette évolution.

Le nom PO pour la progression peut prêter à confusion avec l’or temporaire servant au recrutement pendant le combat. **La fusion de ces deux économies n’est pas demandée.** Les libellés et leur présentation devront les distinguer clairement sans inventer une nouvelle règle de conversion.

## Questions de cadrage avant implémentation

1. Comment présenter le résultat, le retour au parcours et la poursuite facultative après une mission ? La possibilité de s’arrêter après une seule mission et le versement des PO à sa première victoire sont fixés.
2. Décision acquise (CAMP-010) : parcours, missions réussies et mode infini sont indépendants par faction. Les gains reviennent au compte de la faction jouée. Leur présentation dans le parcours reste à réaliser.
3. Combien de vagues de combat comporte une mission ? CAMP-013 fixe la remise à neuf de l’or temporaire, des défenseurs, des PV et des bonus à chaque mission. Le rythme des nouveautés 11–20, 31–40, etc. est fixé ; les dix vagues actuelles ne deviennent pas automatiquement dix missions.
4. Le +1 % est-il additif ou composé, avec quelle mission de référence, et agit-il sur les PV, quantités, vitesses ou un autre budget de difficulté ? Comment intégrer les sauts dus aux nouvelles mécaniques ?
5. Le plafond de prototype est de 51 points partagés ; la v0.85 propose 21 talents par arbre et des majeurs aux seuils 15 et 30. Prix et équilibre restent à éprouver.
6. Quel barème d’XP débloque les 51 points sur les cent premières missions ? La première victoire seule est désormais retenue pour l’XP. Comment équilibrer les PO et achats de boutique, désormais séparés des points de talent ?
7. Les premières victoires des missions suivantes continuent de donner des PO : comment tarifer les dépenses durables et quelles sources de gains retenir après toutes les missions récompensées ? Aucun gain de mission à la défaite ni farm répétable supplémentaire n’est supposé.
8. Quel rôle pour les missions 101–200 et quelles récompenses éventuelles en plus de leurs PO de première victoire ? Quel objectif et quelle économie pour l’infini ?
9. Rejouer une mission déjà achevée reste-t-il possible pour s’entraîner, sans sa récompense initiale ? Comment distinguer missions disponibles, terminées et verrouillées à l’écran ?

Ces questions sont des points à instruire, pas une demande de tout trancher immédiatement.

## Ordre de réalisation proposé

| Lot | Travail | Condition de passage |
| --- | --- | --- |
| A — Stabiliser le socle | Terminer les améliorations du prototype, isoler la géométrie des cartes et conserver les résultats de combat du Gué | Version testée, compilée et publiée ; progression existante préservée |
| B — Cadrer la campagne et l’économie | Préciser le contenu d’une mission, la poursuite facultative, la progression par faction, le coût maximal des points, les récompenses uniques et la respécialisation | Décisions consignées ; budget jusqu’à la mission 100 vérifiable |
| C — Tester un parcours réduit | Concevoir un petit échantillon de missions et un écran de parcours lisible | Quantité à proposer ; validation avant déclinaison en 200 missions |
| D — Première réussite persistante | Enregistrer identifiant de mission, faction concernée et récompense déjà reçue ; versement unique à la première victoire de la mission ; migration du profil existant | Pas de double gain après répétition ou relancement, pas de perte d’acquis ni de crédit anticipé |
| E — Éprouver les chapitres | Tester la difficulté graduelle, les introductions de mécaniques et les transitions de thème sur l’échantillon | Tests humains et charge de contenu évalués ; ajuster le découpage |
| F — Étendre la campagne | Produire les missions par lots, vers 100 puis 200 selon la validation du périmètre | Rôle des missions avancées et récompenses confirmé |
| G — Mode infini | Mettre en œuvre le déverrouillage, puis l’objectif durable et le mode de génération retenus | Règles et critères d’intérêt validés avant production |
| H — Évènements éventuels | Évaluer les formats proposés | Confirmation explicite du mode et de sa charge |

Aucune valeur de difficulté, récompense, génération ou quantité commerciale n’est ajoutée au jeu par ce document. Les anciennes cibles du GDD, notamment six cartes, seront réexaminées avec cette architecture ; elles ne sont pas transformées silencieusement en engagement de produire 200 cartes uniques.

## Précisions économiques — 29 octobre 2026

Chaque mission réussie une première fois donne des PO, également après la mission 100. Le repère de financement des talents à 100 missions suppose de ne pas avoir dépensé ces gains en boutique ou ailleurs ; aucune compensation ni réserve forcée n’est approuvée. La boutique ouvre des stratégies avec des unités ayant forces et faiblesses, sans remplaçantes systématiquement supérieures. L’équilibrage doit éviter à la fois l’impasse après des achats et l’effacement de la difficulté. [Cadre économique](Economie_campagne_2026-10-29.md).

## Actualisation du 29 octobre — plafond et arbres

Prototype de 51 points par faction, deux talents majeurs facultatifs aux seuils 15 et 30, sept lignes : [v0.85](Arbres_enrichis_v085.md). Les noms et valeurs du catalogue enrichi sont des hypothèses. Le budget de première victoire des missions 1–100 doit couvrir les 51 points hors boutique ; à prix provisoire de 10 PO, cela représente 510 PO. Le barème exact reste à valider et ne change pas encore les gains du Gué.

## Parcours indépendants — décision complémentaire

CAMP-010 : l’Alliance et la Horde ont chacune leurs missions réussies et leur propre ouverture du mode infini après leurs 100 premières missions. Aucun succès d’un camp ne valide celui de l’autre. Les PO et les talents restent eux aussi séparés.

## Architecture des talents liés — nouvelle précision

Le porteur du projet demande des positions vides et une répartition irrégulière des talents, avec des flèches de dépendance. Un talent enfant lié à un parent exige le rang maximal du parent en plus du seuil de points de son arbre. Cette règle s’ajoute à la progression par paliers. La [v0.88](Arbres_lies_v088.md) propose cette disposition et ces liens ; leurs choix précis restent des hypothèses à éprouver.

Correction de présentation livrée en [v0.89](Fleches_droites_v089.md) : flèches de prérequis verticales et droites, avec des cases libres entre les talents concernés.

## Parcours de prototype — v0.90

Le parcours par faction est raccordé au Gué : choix d’une mission, première récompense, état déjà réussi, retour facultatif et préparation des talents. Vingt chapitres et 200 positions rendent visible l’organisation cible, avec 199 contenus à venir et non lançables. CAMP-013 confirme le départ à neuf de chaque mission. La prochaine étape du lot C reste la conception puis l’essai d’un échantillon de missions supplémentaires ; cet écran ne remplace pas leur production. [Réalisation et limites](Parcours_campagne_v090.md).

### Échantillon retenu — 30 octobre 2026

Le porteur du projet choisit **trois missions de dix vagues dans le même thème**, avec des configurations différentes, pour comparer plusieurs situations avant l’extension de la campagne. Le Gué en constitue la première ; les deux suivantes restent à produire après la validation du parcours v0.90. Leurs récompenses et leur difficulté seront des valeurs de prototype à éprouver, pas un barème commercial approuvé.

Pour cet essai, le porteur du projet retient **100 %, 101 % puis 102 % de PV ennemis**, sans modifier leur vitesse, leurs dégâts ni leurs récompenses de combat (CAMP-015). Ce réglage sera évalué sur les trois missions avant toute projection à la campagne complète.

### Réalisation de l’échantillon — v0.91

Les [trois missions de dix vagues](Echantillon_campagne_v091.md) raccordent désormais nouvelles géométries, réglage de PV, parcours, gains et premier point de talent. Les noms, tracés, déblocages séquentiels et montants sont proposés pour ce prototype ; les trois missions et la hausse de PV sont les orientations retenues. Le lot C doit encore être éprouvé par des joueurs avant toute extension de contenu.

### Lisibilité du premier point — v0.92

Le [bilan et la reprise du parcours](Lisibilite_progression_v092.md) explicitent le premier point disponible et proposent la prochaine mission jouable, sans lancement automatique. Cette amélioration de présentation accompagne l’essai des trois missions ; elle n’étend pas le contenu ni son équilibrage.
