# Choix techniques du premier essai

20 octobre 2026 — référence GDD v0.14.

Le porteur du projet a approuvé le cahier de réalisation puis demandé quel choix technique convenait le mieux. Godot avec GDScript, en 2D isométrique, a été recommandé et retenu pour cette réalisation initiale. Ce choix est révisable ; il ne constitue pas une nouvelle mécanique approuvée ou une direction artistique finale.

| Élément | Choix utilisé | Motif |
| --- | --- | --- |
| Moteur | Godot 4.7.2 stable standard, Windows x86_64 | Version stable proposée au téléchargement officiel lors de la vérification |
| Langage | GDScript | Intégration native au moteur et simplicité du premier prototype |
| Présentation | 2D projetée en isométrique | Conserver la géométrie logique approuvée et séparer les visuels des règles |
| Rendu | Compatibility | Adapté aux besoins simples de cette scène 2D |
| Visuels | Dessin temporaire par le projet | Carte, arbre, forteresse et Pillard visibles sans dépendance à des assets externes |
| Géométrie | Coordonnées logiques en unités du GDD | Distance du chemin 28 ; positions E1–E6 conservées |

## État vérifié au repère v0.14

La scène démarre avec le moteur officiel 4.7.2.stable.official.ed1daf0bf. Les 21 contrôles du modèle et les 15 contrôles d’interface passent. Un lancement avec rendu OpenGL a produit une capture vérifiée. Ces résultats concernent uniquement le trajet, l’arrivée, les PV, l’absence de récompense, les vitesses, la relance et l’inspection ; aucun combat de défenseur n’est encore implémenté.

L0 est partiellement réalisé : projet ouvrable et démarrable ; l’export d’un exécutable autonome reste à produire. L1 est réalisé pour les fonctions demandées. La prochaine étape est L2.

Le bâtiment de forteresse est décalé graphiquement dans sa cour pour laisser E6 lisible ; l’arrivée logique reste H (17 ; 6). Les visuels ne modifient pas les distances. Les calculs actuels de déplacement utilisent les nombres flottants du moteur avec une tolérance de 10⁻⁹ unité au seuil d’arrivée. Cette tolérance est un choix d’implémentation, pas un changement de longueur. Le futur ordonnanceur de combat et ses égalités de temps feront l’objet de contrôles distincts avant L3.

## Références officielles consultées

- [Godot 4.7.2 stable](https://godotengine.org/article/maintenance-release-godot-4-7-2/) et [téléchargement Windows](https://godotengine.org/download/windows/), vérifiés le 20 octobre 2026.
- [FAQ sur GDScript](https://docs.godotengine.org/en/stable/about/faq.html) : langage intégré recommandé pour débuter avec Godot.
- [Présentation des moteurs de rendu](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html) : Compatibility convient généralement à la 2D.

Le choix de ces outils découle des besoins du prototype ; les sources ne garantissent ni sa performance future ni son équilibre.

## Mise à jour au repère v0.15

L2 est réalisé avec une boucle Alliance N1 et dix Pillards. Le modèle utilise désormais un calendrier d’événements pour les apparitions, les entrées de portée, les tirs et les arrivées, afin de conserver les mêmes résultats à ×1 et ×2. Les bornes de couverture et les instants restent des float 64 bits. Voir le [suivi du prototype](Suivi_prototype.md) pour les 117 contrôles réussis et les limites du lot. Le moteur, le langage et le rendu restent inchangés.

## Mise à jour au repère v0.16

Le choix de faction, les trois défenseurs Horde et les huit profils ennemis sont intégrés au même modèle. Les malédictions sont indexées par instance de chaman et par cible ; les ticks sont agrégés avant les tirs, puis les arrivées sont résolues. Les positions de séparation sont calculées en float 64 bits pour conserver les seuils stricts des attaques secondaires. Les deux factions et leurs effets sont affichés avec des visuels temporaires. Le moteur, le langage et le rendu restent inchangés.

## Implémentation L4 — v0.17, 21 octobre 2026

Les données de progression sont isolées dans prototype/scripts/progression_data.gd : coûts par passage, multiplicateurs depuis N1 et douze fiches de spécialisation. Le modèle calcule les statistiques effectives depuis la base à chaque consultation, puis remplace les champs de branche au N4. Les tirs, délais, effets et portées utilisent cette même fiche effective, comme l’interface.

Chaque défenseur mémorise level, branch et paid, en plus de son instance_id. La transaction upgrade valide phase, emplacement, plafond, fonds et branche avant toute mutation ; le N4 sans branche n’est pas un état accessible par cette transaction. Les fenêtres de couverture sont recalculées après le changement de portée. La vente utilise les dépenses cumulées réelles, sans arrondi intermédiaire.

Les ricochets spécialisés recherchent leur prochaine victime depuis la précédente et excluent toutes les victimes déjà touchées. Les explosions recherchent autour de la cible principale. Les sélections simultanées conservent la convention de photographie avant dégâts. La malédiction conserve le montant calculé à son application ; ses échéances existantes ne consultent pas à nouveau les statistiques de la source.

Le dialogue retient emplacement et identité d’exemplaire. Il n’engage aucun paiement avant confirmation ; une identité remplacée annule la confirmation. Les commandes d’achat, vente, lancement et relance sont aussi gardées côté gestionnaire pendant le choix. Les captures de progression utilisent uniquement des arguments de contrôle et un budget imposé explicitement signalé, sans modifier le budget normal.

Validation : 607 contrôles réussis sous Godot 4.7.2, dont 408 pour L4 ; huit vues de progression rendues et inspectées. Les documents de conception restent en v0.14. L5 doit intégrer les règles de campagne, de bonus et de synergies avant les essais d’équilibrage complets.

## Implémentation L5 — v0.18, 21 octobre 2026

Les dix compositions, douze fiches de bonus et douze associations sont regroupées dans prototype/scripts/campaign_data.gd. Le calendrier développe les groupes à partir de leur type, quantité et intervalle ; le suivant commence 4 s après la dernière apparition. Le modèle distingue fin de vague, choix roguelite, préparation, victoire et défaite. La commande prepare_next_wave ne répète jamais la vague précédente et conserve l’état de partie ; le lancement reste manuel.

Le tirage utilise RandomNumberGenerator avec trois prélèvements uniformes dans le catalogue restant, sans remise au sein de l’offre. Seul le code choisi rejoint les bonus acquis et disparaît des prochains catalogues. La graine fixe 42 sert aux références de test et de capture ; la partie normale utilise un générateur initialisé aléatoirement. Aucune commande de graine ou de relance n’est ajoutée à l’interface.

Les synergies sont calculées par bénéficiaire depuis les partenaires actuels, avec un arrêt après le premier partenaire admissible pour chaque code. Les portées de toutes les unités sont recalculées après achat, vente, amélioration ou bonus. Les références propres aux composantes restent séparées des pourcentages pour additionner R-12 au moment de chaque impact, sans multiplier les effets entre eux ni transmettre R-06 aux secondaires. Une malédiction conserve les dégâts calculés à l’application.

La construction historique Model.new(false) sert uniquement aux anciens scénarios sans synergies du GDD ; le jeu et les nouveaux tests de campagne utilisent Model.new(), avec synergies actives. Cette option n’est pas exposée au joueur. Les réductions de prix concernent les opérations futures et ne modifient jamais paid.

L’interface affiche vague, PV maximum effectifs, durée de combat cumulée, offres, bonus acquis, statistiques effectives et synergies au survol. Le bouton de lancement décrit les prochains groupes. Le récapitulatif des bonus ne suspend pas un combat. Les textes multilignes utilisent des séquences explicites pour éviter l’effet des fins de ligne Windows sur la mise en page.

Validation : 969 contrôles réussis, dont 362 pour L5. Même chronologie à grand pas, ×1 et ×2 sur la vague 8 avec bonus et synergies. Deux campagnes maximales de contrôle et deux campagnes financées normalement réussies. L6 doit élargir les essais ; aucune conclusion d’équilibrage général ou de durée humaine n’est tirée de ces références.

## Outillage L6 — v0.19, 22 octobre 2026

Le lanceur headless prototype/tests/survey_balance.gd joue 1 728 combinaisons déterministes sur le modèle normal. Il n’attribue aucun budget de contrôle et ne modifie aucune règle ; les seules décisions automatiques concernent les transactions, les branches et les offres. Chaque vague conserve la défense au lancement, l’investissement, les synergies, le résultat et les décisions roguelite. Les audits répétés vérifient transactions et conservation ; ils restent distincts des contrôles de régression.

prototype/tests/analyse_balance.py utilise uniquement la bibliothèque standard Python : validation des 1 728 identifiants, lecture des offres et soldes, agrégation et compression JSON déterministe. Les sources du modèle, des données, du GDD et des outils sont identifiées par SHA-256. L’archive JSON compressée et la synthèse sont versionnées ; le protocole de reproduction écrit dans un dossier séparé.

Résultats : 109 111 vérifications d’intégrité sans échec et 969 contrôles de régression réussis. Les statistiques sont descriptives d’une matrice de politiques fixes ; les graines communes et les branches parfois inactives rendent certaines lignes dépendantes. Les préparations humaines et le ressenti ne sont pas mesurés. Aucune modification de gameplay ni de GDD n’est effectuée pour cette livraison.

## Comparaisons appariées — v0.20, 22 octobre 2026

survey_upgrades.gd produit 96 préfixes normaux jusqu’à la fin de la vague 4, puis copie toutes les variables d’état et la graine/position du générateur. Chaque copie est comparée à sa source ; l’original est revérifié après chaque traitement. Les 384 essais isolés ne font qu’une dépense N2 ; les 768 suites testent quatre politiques et deux ensembles de branches, sans recrutement, vente ou modification de prix. Les trois unités restent aux mêmes emplacements.

analyse_upgrades.py valide les variantes, les types et positions, les niveaux et prix identiques des traitements N2, les soldes terminaux et les offres communes. Il produit relevés JSON compressés déterministes, synthèse, tableaux et empreintes de sources. Les données v0.19 sont conservées séparément.

51 801 vérifications d’intégrité sans échec et 969 contrôles de régression réussis. Les politiques reference et priorite_0 donnent ici exactement les mêmes trajectoires : le rapport signale cette dépendance. Les ressources sont identiques au départ, mais les revenus futurs ne sont pas forcés à l’égalité. Aucun fichier de gameplay, GDD ou réglage n’est changé. Les essais humains et l’export autonome restent à réaliser.

## Distribution Windows — v0.21, 22 octobre 2026

Export Windows Desktop x86_64 release avec Godot 4.7.2 exact. Le preset sélectionne explicitement main.tscn et les cinq scripts runtime ; la sélection de scène seule ne retenait pas tous les preloads et a été rejetée au premier démarrage isolé. Les données sont intégrées au PE pour éviter un PCK externe. La console d’accompagnement, la signature et la modification des ressources PE sont désactivées ; aucun outil rcedit ou certificat ajouté.

Exporter_Windows.ps1 vérifie version du projet, moteur et templates, génère les notices depuis Engine, produit l’EXE puis le ZIP avec notice, fiche et manifeste de hashes. Les templates sont installés dans le profil Godot standard après vérification SHA-512 du TPZ officiel. Les notices issues du moteur d’édition peuvent inclure des composants supplémentaires ; elles sont jointes au paquet.

verify_windows_export.py extrait le ZIP en contrôlant les chemins, vérifie cinq fichiers, le hash EXE et l’architecture PE AMD64, puis lance ce binaire depuis le dossier extrait. Il rejette les erreurs de scripts même si le processus rend zéro et vérifie la présence des captures 1280×800. Les captures ont aussi été vues séparément. Les tests de développement ne sont pas inclus dans le paquet runtime.

L0 réalisé pour Windows x86_64 : archive de 39 336 231 octets, cinq lancements vérifiés et 969 contrôles de régression conservés. Pas de modification du combat ou des nombres H. La signature, d’autres architectures et la qualification matérielle étendue ne font pas partie de cette livraison de test. Le GDD reste en v0.14.

## Contrôleur de décompte — v0.22, 23 octobre 2026

La scène Main gère autoplay_started, countdown_wave et countdown_remaining, avec une durée fixe de 60 secondes. Le modèle de combat conserve son API explicite, utilisée par le bouton et le départ automatique. Seul le premier départ réussi arme le flux ; les fins de partie et Nouvel essai le désarment. Le temps de préparation utilise delta non multiplié par speed.

Une fin de combat arme les 60 secondes sans consommer le reste d’une image longue. Le choix roguelite désarme le décompte jusqu’à sa résolution, puis arme un délai entier ; les fenêtres N4 et récapitulatif gèlent le reste disponible. L’expiration appelle le même chemin de lancement que le bouton, qui permet aussi un départ anticipé.

106 vérifications ciblées et 1 075 au total. Les scénarios contrôlés comparent économie, résultat et absence de vague 11 ; la version Windows exportée est contrôlée hors du projet avec une capture de préparation chronométrée supplémentaire. La décision complète le GDD principal sans changer les données de combat.

## Inspection des synergies — v0.24, 23 octobre 2026

La v0.23 a ramené la constante de préparation à 30 secondes. La v0.24 conserve ce délai et ajoute une recherche commune `synergy_partners(slot, rule, branch_override)` aux effets et à la vue. La recherche renvoie tous les partenaires admissibles pour dessiner leurs liens ; les gains ne sont appliqués qu’une fois par règle, comme auparavant. L’aperçu de branche conserve son calcul sans confirmer ni facturer la spécialisation.

La vue dessine uniquement les liens du défenseur sélectionné, avant les personnages ; les liens de spécialisation sont décalés de quatre pixels pour distinguer deux associations sur une même paire. Le contrôleur produit l’aide à partir des mêmes règles : noms de la faction, emplacements, gains propres au bénéficiaire et conditions. Un thème d’infobulle opaque améliore la lecture, sans nouvelle fenêtre modale ni changement des horloges.

1 198 contrôles réussis, dont 123 couvrant les partenaires, leurs retraits, le non-cumul et les descriptions. Huit lancements de la distribution Windows vérifiés ; captures de proximité, spécialisations et aide inspectées. Les données numériques, compositions de vagues et références des campagnes restent identiques.

## Aperçu de recrutement — v0.25, 23 octobre 2026

`purchase_preview_stats` valide la faction et l’emplacement libre puis utilise `get_stats` avec un candidat virtuel de niveau 1. Ce candidat est transmis à la recherche des partenaires sans être inséré dans les défenseurs. Les statistiques sont calculées avec les bonus actuels ; les fenêtres des défenseurs réels, l’or, les identités et le générateur restent inchangés.

Le contrôleur distingue survol et focus, rafraîchit l’aperçu avec l’interface et le retire lorsque le recrutement n’est plus pertinent. La vue projette le cercle avec le même outil que pour un défenseur déployé. Le chemin surligné suit les limites des fenêtres de couverture et leurs virages. Les captures d’export ajoutent l’état `purchase`, financé au budget initial normal.

408 nouveaux contrôles, 1 606 au total. Le paquet Windows est vérifié avec dix lancements ; le délai reste 30 secondes et les résultats des campagnes sont conservés.

## Comparaison des améliorations — v0.26, 23 octobre 2026

`upgrade_preview_stats` duplique le défenseur en candidat virtuel, avance son niveau et applique la branche éventuelle avant de consulter le calcul effectif existant. Le modèle réel n’est pas modifié. Le contrôleur distingue survol et focus de l’amélioration ou d’une branche, rafraîchit les valeurs avant/après et retire les aperçus hors préparation. La vue réutilise le cercle et les fenêtres de chemin de l’aperçu d’achat.

Le panneau des spécialisations devient latéral avec un fond modal moins opaque pour garder la carte lisible. Les commandes derrière le panneau restent bloquées et le délai reste suspendu par `pending_slot`, sans changement des conditions de paiement ou d’annulation.

357 contrôles supplémentaires, 1 963 au total. Les captures d’export couvrent aussi l’amélioration ordinaire et la spécialisation ; douze lancements de l’archive extraite sont vérifiés. Les valeurs de référence et les campagnes restent inchangées.

## Inspection ennemie — v0.27, 23 octobre 2026

La vue expose les zones de survol projetées des huit profils et recherche l’ennemi au premier plan. Le tri de dessin est déterministe en cas d’égalité de profondeur. Le contrôleur conserve la dernière position du pointeur et réévalue le survol avec les ennemis actuels à chaque mise à jour ; aucun identifiant n’est verrouillé entre vagues.

La fiche en haut à droite lit directement les PV, dégâts d’arrivée, récompenses et malédictions existantes. Sa jauge conserve les PV réels ; seul le texte arrondit au supérieur. Le thème de jauge est appliqué avant son dimensionnement final pour éviter le recouvrement du texte. Les fenêtres modales et les phases hors combat masquent fiche et repère.

78 contrôles supplémentaires, 2 041 au total. Les captures d’export ajoutent une inspection ordinaire et le boss de la vague 10 au budget normal : quatorze lancements vérifiés. Le modèle de combat et ses données ne sont pas modifiés.

## Relevés de partie — v0.28, 23 octobre 2026

Le modèle copie un contexte compact au départ de chaque vague : PV, revenus déjà acquis, composition, investissements et bonus actifs. À la résolution, une ligne immuable par rapport au reste du modèle rejoint `wave_history`, avec comptes, revenus propres à la vague et durée simulée. Le contexte en cours est alors vidé pour empêcher les doublons ; reset efface tous les relevés. La résolution du combat et le tirage des bonus ne changent pas.

Le contrôleur construit le bilan uniquement sur demande après victoire ou défaite. Le panneau reprend les données copiées et les cumuls réels ; les lignes ont une aide décrivant leur contexte. Les commandes derrière le panneau sont bloquées. Le bouton de fermeture reçoit le focus, puis le rend à Bilan. Les copies de l’outil d’essais appariés incluent aussi l’historique et le contexte en cours, sans alias entre tableaux.

196 contrôles supplémentaires, 2 237 au total. Les captures d’export couvrent deux bilans au budget normal ; seize lancements du paquet extrait sont vérifiés. Aucune persistance sur disque n’est ajoutée au jeu.

## Prévision des vagues — v0.29, 23 octobre 2026

La requête statique `wave_forecast` construit des groupes indépendants depuis les compositions, définitions ennemies et calendrier de combat existants. Elle ne touche ni au générateur ni au modèle de la partie. Le contrôleur met en cache les données par vague et conserve un recalcul dynamique du délai et de l’avertissement d’arrivée fatale. Les marqueurs utilisent la même palette que les ennemis dessinés.

La carte de préparation partage la zone en haut à droite avec l’inspection de combat, avec des conditions d’affichage exclusives. Le panneau s’adapte aux un à quatre groupes du prototype. Les deux nouvelles captures arrêtent des parcours au budget normal avant les vagues 9 et 10, puis arment le même délai de 30 secondes que le jeu normal.

402 contrôles supplémentaires, 2 639 au total. Dix-huit lancements du paquet extrait vérifiés ; contenu, horaires et rendu des prévisions inspectés. Les apparitions réelles et les règles économiques restent inchangées.
