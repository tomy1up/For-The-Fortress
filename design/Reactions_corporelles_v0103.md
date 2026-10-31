# Réactions corporelles aux dégâts — v0.103

## Demande et périmètre

**V :** animer les attaquants lorsqu’ils subissent des dégâts, au-delà du seul clignotement. Ce lot réalise une première réaction de l’illustration entière : légère inclinaison, recul visuel puis retour au repos. Les membres ne sont pas encore animés séparément. Les cycles de marche, gestes détaillés des défenseurs, nouvelles forteresses et souverains restent dans la [feuille de route](Feuille_de_route_long_terme.md).

**H :** durée, amplitude et différences de poids ci-dessous. Aucun changement de statistiques, de placement, de ciblage ou d’équilibrage n’accompagne ce lot.

## Présentation et règles

Une perte réelle de PV déclenche la réaction sur un attaquant survivant, avec un maximum après 45 ms simulées et un retour complet au repos en 0,28 seconde simulée. L’amplitude tient compte de la part des PV perdus. Les ours, colosses, élites, boss et tortues bougent moins que les petits attaquants. La tortue peut réagir aussi aux dégâts qu’elle absorbe réellement pour ses voisins. Un coup létal conserve la dissipation déjà présente ; l’animation corporelle de mort reste à développer.

Le corps s’incline jusqu’à environ 6° et se décale brièvement de 3,5 pixels de référence, avant les facteurs d’amplitude et de poids. Il garde ses proportions, sa texture et ses couleurs de base. La réaction se retourne avec l’orientation du personnage. L’ombre, les jauges de vie et le trajet gardent leur ancrage de lecture.

Les coups simultanés ne cumulent pas le recul ; seule la plus forte réaction encore visible est utilisée. Aucun mouvement n’est déclenché par un coup futur, une autre cible ou une absence de perte de PV. Les dégâts périodiques suivent la même règle que les impacts. Après la vague ou la partie, aucune pose de douleur n’est figée sur un survivant.

Ce mouvement est purement visuel : aucun repoussement de l’ennemi sur la route, ralentissement, étourdissement, déplacement de collision ou délai supplémentaire de dégâts. Les projectiles restent l’habillage des coups déjà résolus. Leur synchronisation détaillée avec les gestes des défenseurs est un autre chantier.

La zone de survol reçoit une marge fixe de 8 pixels pour couvrir les poses sans trembler avec le corps. Les vitesses ×1, ×2 et ×10 utilisent le temps simulé, comme les effets existants : la réaction est plus brève en temps réel lorsque le combat accélère. ×10 reste un outil de débogage et ne garantit pas la lecture de chaque impact individuel.

## Vérifications à joindre à la livraison

Le test dédié couvre les neuf profils statistiques dans les deux factions, les deux orientations, les virages, les bornes temporelles, les coups simultanés, la conservation des proportions et la couverture de toutes les poses par le survol. Il applique de vrais dégâts du modèle et vérifie que dessiner n’altère ni les ennemis, ni le générateur aléatoire, ni le rapport de partie.

Un atelier visuel agrandi utilise les quatorze silhouettes, les observations de dégâts réelles et les fonctions de pose du paquet exporté. Cet atelier sert à comparer les poses : il n’est pas une capture d’une partie jouée ni un nouvel écran du jeu.

## Résultats de livraison

**87 suites, 37 155 contrôles Godot et 17 tests Python** passent. [Rapport complet](essais/v0103_regression.json). Le test de réaction couvre 3 318 contrôles de pose, géométrie et invariance.

Le programme Windows passe **16 cas ciblés sur 247 disponibles**, produit 15 captures et compare 59 sources locales. Les cas ciblés couvrent notamment les deux nouveaux contrôles de mouvement, la tortue, les silhouettes des deux camps, l’inspection, le boss, les quatre familles d’effets, les dégâts périodiques et les rapports. [Rapport natif](Distribution_Windows_v0103.json). Après la régression, l’unique ajustement du vérificateur ajoute les noms des deux nouveaux cas à sa table des types ; les deux cas sont ensuite exécutés avec succès. [Contrôles complémentaires](essais/v0103_validation_complementaire.json).

L’atelier de poses est calculé à partir des ressources du paquet avec le moteur complet, en 45 échantillons à 30 images/s. Le GIF regroupe les images successives identiques ; il conserve le rythme des échantillons. Repos et impact ont été inspectés sur les quatorze silhouettes. [Aperçu animé agrandi](essais/captures/QA-v0103_reactions_atelier.gif). Les vues d’impact Alliance du projet et Horde du programme exporté ont également été examinées. [Impact Horde](essais/captures/QA-v0103_impact_Horde.png).

Par rapport au paquet v0.102, seuls les sources de présentation `main.gd`, `valley_view.gd`, la version du projet et la destination d’export diffèrent dans le manifeste. Modèle, rencontres, talents, économie, sauvegarde et textures conservent leurs empreintes. La progression du joueur n’est pas remise à zéro. Aucune nouvelle animation de marche, de membre ou de souverain n’est annoncée comme achevée par cette version.
