# Réaction des ennemis aux dégâts — v0.63

27 octobre 2026. Suite de la présentation des [attaques orientées](Animations_attaque_v062.md).

## Lecture pendant le combat

Un ennemi qui perd des PV s’éclaircit brièvement : ses couleurs de peau, de métal et de vêtement se rapprochent du blanc, puis reviennent à leur teinte habituelle en **0,16 seconde simulée**. Les contours, marques de malédiction, jauges et informations d’inspection conservent leur présentation. Aucun déplacement ni recul de l’ennemi n’est ajouté.

La portion perdue de sa jauge reste visible en ivoire puis s’efface sur **0,40 seconde simulée**. Le remplissage vert continue d’indiquer immédiatement ses vrais PV actuels. Deux coups rapprochés produisent des portions adjacentes, correspondant à leurs pertes propres. La jauge n’est pas artificiellement ralentie et sa valeur n’est jamais interpolée à la place des PV réels.

Les dégâts périodiques, dont ceux du chaman, déclenchent la même réaction même sans nouveau projectile. L’effet correspond à une perte effective de PV : un tir qui n’a pas touché cet ennemi, un voisin ou un événement futur ne produit pas de réaction sur lui. Un ennemi qui atteint la forteresse sans être touché n’en produit pas non plus.

Les réglages de durée et d’intensité sont des choix de présentation ajustables après retour joueur. Aucun nombre flottant, texte supplémentaire, son, secousse d’écran ou flash plein écran n’est ajouté.

## Observation des pertes

Le modèle conserve pour la vague des observations `damage_events` : instant simulé, identifiant de l’ennemi, PV avant et PV après coup. Elles sont écrites après la soustraction existante des dégâts, sans changer son calcul ou l’ordre de résolution. Les PV après coup de l’observation sont bornés à zéro pour éviter d’afficher le surplus d’un coup létal comme des PV supplémentaires perdus.

Cette liste est réservée à la présentation ; elle n’ajoute pas d’action à rejouer ni de champ obligatoire au rapport de partie. Elle est vidée à la nouvelle vague et à la nouvelle partie pour éviter de réutiliser les coups d’un ancien ennemi. Le rendu la consulte sans modifier le modèle, les cibles, l’économie, les événements de combat ou le RNG.

## Limites du lot

Les ennemis éliminés sont retirés immédiatement comme auparavant et ne restent pas comme cibles visuelles ou cliquables. Cette version ne crée pas d’animation de mort ou de cadavre. Les réactions concernent les ennemis encore présents pendant le combat et s’arrêtent à sa fin ; aucun éclaircissement ne reste figé pendant les panneaux ou entre les vagues.

Les durées suivent les vitesses ×1, ×2 et ×10 de la simulation. À ×10 de débogage, elles sont donc très brèves. Les barres de vie gardent leur largeur, leur position et leurs valeurs actuelles ; les zones de survol restent identiques. Les six PNG des défenseurs sont conservés.

Dégâts, cadence, ciblage, déplacements, résistances, effets, récompenses, vagues, boss à 600 PV et préparation de 30 secondes restent identiques. Aucune progression permanente. GDD principal v0.14 ; For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Vérification

38 suites, **15 138 contrôles Godot** dont 63 nouveaux, **16 tests Python** et contrats du GDD réussis. Les contrôles dédiés couvrent les vrais coups des six classes, les pertes fractionnaires et létales, deux dégâts au même instant, les événements futurs ou voisins, les ennemis passés sans dommage, les ticks du chaman, les bornes d’extinction et les changements de vague et de partie. Les rendus répétés n’altèrent ni le rapport, le RNG, les ennemis ni les observations.

Le [rapport de régression](essais/v063_regression.json) et le [contrôle du paquet Windows](Distribution_Windows_v063.json) conservent les résultats. Une scène complémentaire observe un véritable dégât périodique de chaman non létal, distinct d’un nouveau tir, à budget imposé. Ces contrôles ne constituent ni un retour humain ni une nouvelle validation générale d’équilibrage.

## Paquet Windows vérifié

87 lancements, 86 captures et 24 empreintes locales concordantes. Les [pertes après une flèche](essais/captures/QA-v063_impact_archer.png), une [explosion de sapeur](essais/captures/QA-v063_explosion_sapeur.png) et un [dégât périodique du chaman](essais/captures/QA-v063_degats_periodiques.png) ont été inspectées dans l’exécutable exporté. Le contrôle périodique exige un ennemi non éliminé, une perte récente et l’absence de nouveau tir depuis plus d’une demi-seconde ; il produit le marqueur de contrôle dédié. Les catalogues et interfaces des deux factions restent lisibles. Les contrôles graphiques se déroulent sur l’écran de droite et se ferment après capture.
