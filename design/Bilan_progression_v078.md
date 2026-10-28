# Audit de progression — prototype v0.78

28 octobre 2026. Mesures automatisées de politiques fixes ; aucun joueur humain, aucune modification de profil et aucun changement de règles.

## Protocole

512 scénarios : deux factions, quatre configurations de talents, deux placements et 32 graines (1 à 32). Capital normal de 150 or. Deux premières recrues au départ, troisième type à partir de la vague 4 si le budget le permet ; amélioration d’un niveau par défenseur et par préparation à partir de la vague 5, spécialité finale de branche 0. Chaque choix de bonus prend la première offre. Les 512 bilans économiques sont contrôlés.

Les configurations sont injectées uniquement dans le modèle de contrôle : zéro point ; cinq points dans la première base ; quinze points dans les trois bases ; trente-six points, spécialités finales orientées impact. Il ne s’agit pas de la simulation d’un joueur achetant progressivement ces points.

Placement référence : E1, E2, E3. Placement réparti : E2, E4, E6. Les trois classes gardent le même ordre. Les durées ci-dessous supposent le combat à ×1 et les trente secondes complètes avant chaque vague suivante ; elles excluent les temps humains de choix. Un lancement manuel anticipé ou une vitesse différente change ces durées.

## Résultats

| Faction | Points | Placement | Victoires / 32 | Ressources moyennes | PV finaux médians | Durée médiane ×1, min |
| --- | --- | --- | --- | --- | --- | --- |
| Alliance | 0 | Référence | 32 | 60,00 | 18 | 10,21 |
| Alliance | 0 | Réparti | 0 | 15,38 | 0 | 7,36 |
| Alliance | 5 | Référence | 32 | 60,00 | 23 | 10,21 |
| Alliance | 5 | Réparti | 1 | 21,94 | 0 | 8,63 |
| Alliance | 15 | Référence | 32 | 60,00 | 23 | 9,89 |
| Alliance | 15 | Réparti | 24 | 52,50 | 6 | 12,88 |
| Alliance | 36 | Référence | 32 | 60,00 | 31 | 9,54 |
| Alliance | 36 | Réparti | 32 | 60,00 | 23 | 12,58 |
| Horde | 0 | Référence | 32 | 60,00 | 12 | 10,89 |
| Horde | 0 | Réparti | 0 | 15,38 | 0 | 7,38 |
| Horde | 5 | Référence | 32 | 60,00 | 15 | 10,56 |
| Horde | 5 | Réparti | 0 | 17,50 | 0 | 7,43 |
| Horde | 15 | Référence | 32 | 60,00 | 15 | 10,41 |
| Horde | 15 | Réparti | 19 | 44,59 | 5 | 12,76 |
| Horde | 36 | Référence | 32 | 60,00 | 17 | 9,78 |
| Horde | 36 | Réparti | 31 | 59,53 | 10 | 12,46 |

## Lecture et limites

La stratégie de référence gagne sans talent dans 64/64 essais. Le placement réparti n’obtient que 0/64 victoires sans talent. Les talents améliorent fortement ce second placement dans les configurations testées, mais ne remplacent pas une bonne composition spatiale. Ces taux décrivent ces politiques et ces graines ; ils ne sont pas des taux de réussite de nouveaux joueurs.

L’intention d’une première victoire très difficile n’est donc pas garantie par un verrou de puissance dans le prototype actuel. La politique connue atteint la victoire sans progression permanente. Cela ne suffit pas à conclure que les premières parties humaines sont faciles, ni à justifier une hausse immédiate des PV ennemis ou du temps de collecte.

Le plafond actuel représente 360 ressources par faction (36 points à 10 ressources). Une victoire complète verse 60 ressources : six victoires parfaites suffisent arithmétiquement à financer ce plafond sans frais de respécialisation. Ce n’est ni une prévision de durée humaine, ni une simulation d’acquisition progressive. Deux monnaies séparées ne créent pas deux fois plus de contenu.

Une seule carte, deux placements, une politique économique et les finales de branche 0 sont couverts. Les autres placements, décisions, arbres, joueurs, difficultés futures et cartes restent hors échantillon. Les choix d’interface, la fermeture en cours de partie et la persistance ne sont pas simulés ici ; leurs contrôles restent dans les suites du jeu.

## Suites à cadrer

Confronter ces résultats à des premières parties humaines sans talent, puis à des configurations modestes. Fixer ensuite le rythme visé de ressources et le périmètre des difficultés/cartes avant de modifier les chiffres. Les coûts, talents et récompenses restent provisoires. Aucun nouveau système, difficulté ou contenu n’est approuvé par cet audit.

## Reproduire

Depuis la racine du dépôt, lancer Godot 4.7.2 en mode headless avec le projet prototype, le script res://tools/survey_meta_progression.gd et un argument utilisateur --output=<nouveau fichier JSON hors des données du joueur>. Le script refuse une destination existante ou située dans le répertoire utilisateur du jeu.

Exécuter ensuite prototype/tools/analyse_meta_progression.py <rapport.json> --markdown <synthese.md>. Les scripts ne sont pas inclus dans le jeu distribué. [Données](essais/v078_meta_progression.json).
