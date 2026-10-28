# Feuille de route — vision long terme

28 octobre 2026. Référence de conception évolutive liée au [suivi du prototype](Suivi_prototype.md). Aucun calendrier ni engagement commercial n’est déduit des cibles. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Sources et statuts

Le porteur du projet a fourni le texte de sa vision, une capture de parcours Duolingo et l’ancienne réponse de l’assistant, issus du [tchat de référence](https://chatgpt.com/s/t_6ae259b3fce88191bd6dcebbf0384277). Le lien seul n’était pas consultable ; le texte recopié dans le présent tchat fait foi. La capture inspire l’organisation du parcours, sans reprise de ses illustrations, monnaies, mécaniques ou éléments d’interface non demandés.

**V :** orientation explicitement demandée. **C :** cible de contenu ou de progression, non engagement de production. **H :** valeur ou règle d’équilibrage à tester. **P :** proposition de l’ancienne réponse, non approuvée par sa seule citation. **O :** question ouverte.

## Vision fournie par le porteur du projet

| Sujet | Orientation | Statut et limites |
| --- | --- | --- |
| Monnaie de progression | Pièces d’Or, PO ou Gold, pour acheter les points de talents | V pour le nom et l’usage ; conserver les comptes propres aux deux factions, sauf nouvelle décision |
| Campagne | 200 missions ou niveaux | C ; une seule carte jouable actuellement |
| Missions 1–100 | Difficulté graduelle, référence de +1 % par carte | V pour la progression ; H pour la valeur et O pour son calcul et les paramètres concernés |
| Récompense de mission | Achever une mission donne des PO une seule fois ; rejouer cette mission ne permet pas de récupérer à nouveau ce gain | V ; granularité par faction et articulation avec la fin globale de partie à préciser |
| Parcours | Présentation par chapitres et missions, inspirée du parcours Duolingo | V pour l’orientation visuelle ; interface détaillée à concevoir |
| Chapitres | Première idée : 10 missions par chapitre | C/H, découpage à confirmer avant production du contenu |
| Environnements | Changement de thème tous les deux chapitres | C ; identité et quantité d’assets non définies |
| Introduction des mécaniques | « Chaque palier de 10 vagues impaires » apporte une nouveauté ou difficulté persistante sur les dix unités du palier, qui réapparaît ensuite ponctuellement | V pour l’intention ; O pour le sens exact de « vagues impaires » : missions, chapitres ou vagues de combat |
| Mission 100 | Avoir obtenu assez de PO pour acheter le maximum de points de talents disponibles | C ; maximum, prix cumulés et budget hors talents à définir |
| Mode infini | Débloqué après avoir terminé les 100 premières missions ; vagues sans fin | V pour le principe et le verrou ; réalisation après validation de la campagne |
| Génération en infini | Carte complexe potentiellement générée aléatoirement | P du porteur du projet, formulée comme question ; méthode non arrêtée |
| Finalité de l’infini | À déterminer | O ; aucun score, classement ou service en ligne implicitement approuvé |
| Mode évènement | Peut-être un format permettant d’innover | P ; pas un mode confirmé |

Si le découpage est retenu sur les 200 missions, il implique arithmétiquement 20 chapitres et 10 blocs thématiques de 20 missions ; les 100 premières missions correspondraient à 10 chapitres et 5 blocs. Ces nombres sont dérivés de la proposition, sans choix des thèmes ni promesse de 200 cartes géométriquement uniques.

## Propositions de l’ancienne réponse à conserver pour discussion

| Proposition citée | Statut actuel |
| --- | --- |
| Missions 1–100 pour découvrir les mécaniques et développer les talents ; 101–200 comme campagne avancée avec le maximum de points | P ; rôle précis de la seconde moitié à confirmer |
| Chapitres impairs de découverte, pairs de combinaison ; introduction aux missions 1–10, 21–30, 41–50, etc. | P ; interprétation de la phrase sur les paliers, pas une clarification obtenue du porteur du projet |
| Réserver d’abord les PO aux talents | P ; autres dépenses à décider, avec maintien de la respécialisation payante déjà demandée |
| Réattribution gratuite des talents | Non retenue : contredit la décision explicite de respécialisation payante, croissante puis plafonnée, compteur séparé par faction |
| Maximum de points achetables distinct du total des rangs de talents ; choix de builds conservés | P à confirmer pour la cible commerciale ; conserver les règles du prototype tant qu’elles ne sont pas révisées |
| Apparences, titres ou personnalisation de forteresse pour les missions 101–200 | P ; aucun cosmétique ni récompense supplémentaire implémenté ou approuvé |
| Records personnels de vagues ou score ; records par configuration ; défi hebdomadaire commun | P ; aucune infrastructure réseau ou calendrier d’évènement engagé |
| Structures de cartes validées avec variations aléatoires plutôt que génération entièrement libre | P ; méthode à comparer et valider |

## Cohérence avec les décisions déjà acquises

- **Factions séparées :** monnaies, points, arbres et compteurs de respécialisation distincts Alliance/Horde. Un point dépensé dans un camp n’incrémente pas l’autre.
- **Talents :** trois arbres par faction, progression verticale avec seuils de points investis dans le même arbre. Le contenu et les valeurs actuels sont un prototype d’équilibrage.
- **Respécialisation :** coût légèrement croissant pendant quelques réinitialisations, puis fixe au plafond ; compteur propre à chaque faction. Cette règle reste en vigueur.
- **Fin globale :** aucun accès à l’accueil ou aux arbres tant que la partie complète n’est pas gagnée ou perdue ; les gains sont versés à cette limite. Une victoire sur une carte intermédiaire ne suffit pas.
- **Persistance :** conserver les acquis après fermeture et protéger la progression locale. La sauvegarde en ligne Steam reste une piste, sans service en ligne livré.

La nouvelle récompense de première réussite diffère du prototype, qui attribue des ressources selon les vagues et l’issue de chaque partie. Elle n’est pas encore appliquée au jeu. Il faut définir si une mission représente une partie complète ou une étape de celle-ci. Si elle est intermédiaire, son gain doit rester provisoire jusqu’à la fin globale selon la décision existante ; son sort en cas de défaite ultérieure reste à décider.

Le nom PO pour la progression peut prêter à confusion avec l’or temporaire servant au recrutement pendant le combat. **La fusion de ces deux économies n’est pas demandée.** Les libellés et leur présentation devront les distinguer clairement sans inventer une nouvelle règle de conversion.

## Questions de cadrage avant implémentation

1. Une mission correspond-elle à une carte et une partie complète, ou plusieurs missions composent-elles une partie ? Quand revient-on au parcours et quand les PO deviennent-ils définitivement acquis ?
2. Les 200 missions, les premières réussites et le verrou des 100 missions sont-ils suivis séparément par faction ? À quelle faction revient chaque récompense ?
3. Que signifie précisément le palier de « 10 vagues impaires » ? Combien de vagues de combat comporte une mission ? Les dix vagues actuelles ne deviennent pas automatiquement dix missions.
4. Le +1 % est-il additif ou composé, avec quelle mission de référence, et agit-il sur les PV, quantités, vitesses ou un autre budget de difficulté ? Comment intégrer les sauts dus aux nouvelles mécaniques ?
5. Combien de points peut-on acheter et combien peut-on investir simultanément ? Coûts fixes ou progressifs ? Quelles limites de répartition entre les trois arbres ?
6. Pour chaque faction concernée, quelles récompenses garanties jusqu’à la mission 100 couvrent le coût cumulé des points ? Comment éviter qu’une dépense en respécialisation rende cet objectif inaccessible ?
7. Que rapporte une défaite ? Les récompenses de mission étant non répétables, quelle source éventuelle finance les respécialisations après les premières victoires ? Aucun farm supplémentaire n’est supposé.
8. Quel rôle et quelles récompenses pour les missions 101–200 et l’infini une fois le maximum de points acheté ?
9. Rejouer une mission déjà achevée reste-t-il possible pour s’entraîner, sans sa récompense initiale ? Comment distinguer missions disponibles, terminées et verrouillées à l’écran ?

Ces questions sont des points à instruire, pas une demande de tout trancher immédiatement.

## Ordre de réalisation proposé

| Lot | Travail | Condition de passage |
| --- | --- | --- |
| A — Stabiliser le socle | Terminer les améliorations du prototype, isoler la géométrie des cartes et conserver les résultats de combat du Gué | Version testée, compilée et publiée ; progression existante préservée |
| B — Cadrer la campagne et l’économie | Clarifier mission/partie, progression par faction, coût maximal des points, récompenses uniques et respécialisation | Décisions consignées ; budget jusqu’à la mission 100 vérifiable |
| C — Tester un parcours réduit | Concevoir un petit échantillon de missions et un écran de parcours lisible | Quantité à proposer ; validation avant déclinaison en 200 missions |
| D — Première réussite persistante | Enregistrer identifiant de mission, faction concernée et récompense déjà reçue ; versement unique à la limite approuvée ; migration du profil existant | Pas de double gain après répétition ou relancement, pas de perte d’acquis ni de crédit anticipé |
| E — Éprouver les chapitres | Tester la difficulté graduelle, les introductions de mécaniques et les transitions de thème sur l’échantillon | Tests humains et charge de contenu évalués ; ajuster le découpage |
| F — Étendre la campagne | Produire les missions par lots, vers 100 puis 200 selon la validation du périmètre | Rôle des missions avancées et récompenses confirmé |
| G — Mode infini | Mettre en œuvre le déverrouillage, puis l’objectif durable et le mode de génération retenus | Règles et critères d’intérêt validés avant production |
| H — Évènements éventuels | Évaluer les formats proposés | Confirmation explicite du mode et de sa charge |

Aucune valeur de difficulté, récompense, génération ou quantité commerciale n’est ajoutée au jeu par ce document. Les anciennes cibles du GDD, notamment six cartes, seront réexaminées avec cette architecture ; elles ne sont pas transformées silencieusement en engagement de produire 200 cartes uniques.
