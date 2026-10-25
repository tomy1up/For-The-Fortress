# Relevé du boss — v0.50

26 octobre 2026. Observation du combat pour les essais d’équilibrage ; aucun paramètre de combat modifié.

## Lecture

Dans le bilan, survoler la ligne de vague 10 pour consulter le sort du boss et ses temps. Le rapport Markdown exporté comporte une section Boss final. Le JSON conserve un champ boss_encounter.

Les états distinguent : vague 10 non atteinte, boss prévu mais pas encore apparu, élimination, arrivée à la forteresse, présence en chemin à la fin de partie, ou issue indéterminée si les observations sont insuffisantes. Une victoire n’est pas utilisée comme preuve d’élimination du boss.

Une résolution indique son instant depuis le début de la vague et le délai depuis l’apparition du boss. Pour une élimination, les PV retirés sont indiqués ; en cas d’arrivée ou de présence, les PV restants sont conservés. Ces temps sont des secondes de simulation, indépendantes de la vitesse d’affichage et hors préparation. Ils ne mesurent pas la tension ressentie.

## Source des observations

Le lecteur identifie le boss dans le programme d’apparition de la vague 10, sans supposer que son identifiant vaut zéro. Il consulte le journal de morts/arrivées, les ennemis encore présents et les contributions de dégâts déjà mesurées. Il ne modifie aucun ennemi, statistique, journal ou état aléatoire. Le modèle de combat n’est pas modifié.

L’observation est effectuée à la lecture du rapport et du bilan. Le journal de la dernière vague doit encore être disponible ; c’est le cas des fins de partie normales, la vague 10 étant la dernière. Un relevé incomplet produit un état indéterminé plutôt qu’un temps supposé. Un boss non apparu n’a pas de PV restants présentés comme observés.

## Compatibilité

Le format JSON reste en version 2 avec un champ supplémentaire optionnel. Le rejeu contrôle ce champ lorsqu’il est présent. Les rapports antérieurs sans ce champ restent compatibles et ne reçoivent pas artificiellement une observation historique. Le numéro de version source reste distinct de celui du modèle employé pour le rejeu.

## Vérification

**29 suites, 14 339 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **26 contrôles dédiés** couvrent les deux campagnes financées normalement, les 600 PV mesurés, les temps cohérents, le Markdown, le survol du bilan, l’absence de mutation, la détection d’un temps altéré et les rapports historiques.

Des vagues isolées à budget ou paramètres imposés vérifient aussi l’arrivée fatale, une victoire malgré un boss arrivé, la défaite avant apparition ou avec boss encore en chemin, un identifiant non nul et un journal incomplet. Ces fixtures ne remplacent aucune vague de la campagne et ne constituent pas des essais d’équilibrage.

Deux anciens rapports Windows v0.45 ont été rejoués par le modèle v0.50 sans modification des fichiers ni divergence des données historiques. [Relevé de compatibilité](essais/v050_legacy_replay.json).

Le paquet Windows et la lecture visuelle sont consignés dans Distribution_Windows_v050.json. Le boss reste à 600 PV ; aucune conclusion générale de difficulté ni modification d’équilibrage. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

## Contrôle final

46 lancements du paquet Windows réussis sur l’écran de droite, dix empreintes locales concordantes. Les deux rapports du paquet se rejouent avec le champ boss, sans modification des fichiers : [relevé](essais/v050_current_replay.json). La politique normale de référence élimine le boss à 7,5 s en Alliance et 10 s en Horde ; 600 PV retirés dans les deux cas. Cela décrit ces deux scénarios et ne généralise pas la difficulté.

L’infobulle de la vague 10 a été inspectée dans une fenêtre du projet source, avec Godot 4.7.2 et la même campagne de contrôle Horde : texte intégral visible, 10 s de vague et 600 PV. Ce contrôle de lecture est distinct des lancements du paquet. [Capture](essais/captures/QA-v050_boss_bilan.jpg). Fenêtre fermée après vérification.
