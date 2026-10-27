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

## v0.30 — Repères de combat

Explosions projetées au sol, palette distincte mage/sapeur, ricochets fléchés et marque de malédiction. Le modèle de combat reste identique. 2 685 contrôles réussis, dont 46 ciblés, et 22 démarrages du paquet Windows. Voir [le relevé détaillé](Lisibilite_combats_v030.md).

## v0.31 — Aide au recrutement, 24 octobre 2026

Le survol et le focus des recrues affichent attaques, rôle, effets et prix effectifs. Les infobulles complètent le ciblage et les limites des effets ; le refus d’achat reste distinct du contenu informatif. 2 781 contrôles réussis, dont 96 nouveaux ; 26 lancements du paquet Windows contrôlés. [Détail de la réalisation](Aide_recrutement_v031.md).

## v0.32 — Signal des percées, 24 octobre 2026

Le contrôleur compare les arrivées et PV avant/après l’avance du modèle. La vue affiche les pertes réelles pendant 2,5 secondes réelles, sans modifier le combat ou le délai. 2 822 contrôles réussis, dont 41 ciblés ; 27 lancements Windows contrôlés. [Détail de la réalisation](Signal_percees_v032.md).

## v0.33 — Comparaison des bonus, 24 octobre 2026

Projection sans mutation des douze bonus : valeurs avant/après sur la défense, PV, prix et conditions de grande cible. Calculs communs au jeu réel ; listes défilantes et récapitulatif acquis compact. 11 574 contrôles réussis, dont 8 752 ciblés ; 30 lancements Windows contrôlés. [Relevé détaillé](Comparaison_bonus_v033.md).

## v0.34 — Cohérence des factions, 24 octobre 2026

Descriptions de bonus centralisées par camp, synergies limitées aux attaques du bénéficiaire et garde explicite des améliorations adverses. 12 303 contrôles réussis, dont 729 ciblés ; 32 lancements Windows contrôlés. [Relevé détaillé](Coherence_factions_v034.md).

## v0.35 — Lisibilité, essais PC et ×10 temporaire

Dégâts à la forteresse explicités, nombres lisibles, montants économiques détaillés, routes couvertes et silhouettes renforcées. Défilement remis à zéro au bon contexte. ×10 debug ajouté sur demande explicite, sans accélérer les préparations. 12 578 contrôles et 36 lancements Windows. [Détail](Lisibilite_et_debug_v035.md) · [Essais interactifs agent](Essais_interactifs_v035.md).

## v0.36 — Journal et rapports locaux, 24 octobre 2026

Décisions acceptées, achats, améliorations, ventes, offres et choix roguelite conservés en mémoire. Export Markdown et JSON depuis le bilan, sans tirage supplémentaire ni reprise de partie. 12 717 contrôles réussis et 38 lancements Windows. [Détail et limites](Rapports_partie_v036.md).

## v0.37 — Anticiper les synergies, 25 octobre 2026

Liens bleus pointillés et détail des partenaires/gains avant recrutement et spécialisation, fondés sur les associations existantes et une unité candidate sans mutation. 13 879 contrôles réussis, dont 1 162 ciblés ; 42 lancements Windows et vérification interactive des deux factions sur l’écran de droite. [Détail](Apercu_synergies_v037.md).

## v0.38 — Mesurer l’activité, 25 octobre 2026

Observation des impacts et des PV retirés, répartition proportionnelle des coups simultanés et suivi par recrue et par vague. Onglet Défenseurs dans le bilan, avec conservation des unités vendues et export JSON schéma 2/Markdown. Aucun changement de transaction de combat ou de statistique. 13 952 contrôles réussis, dont 73 ciblés ; 45 lancements Windows vérifiés sur l’écran de droite. [Détail](Activite_defenseurs_v038.md).

## v0.39 — Jauge du boss, 25 octobre 2026

Vie et dégâts à la forteresse visibles sans survol, avec signal de défaite conditionnel et masquage hors combat ou derrière les écrans de choix. 14 004 contrôles réussis, dont 52 ciblés, et 46 lancements Windows vérifiés sur l’écran de droite. [Détail](Suivi_boss_v039.md). Aucun réglage modifié.

## v0.40 — Vérification complète versionnée, 25 octobre 2026

Lanceur sans fenêtre, découverte des suites, contrôle des résumés/erreurs, journaux JSON, empreintes des sources et contrats du GDD inclus dans le dépôt. 23 suites et 14 004 contrôles Godot, 9 tests Python ; filtres, appel depuis un autre répertoire et mauvais moteur vérifiés. 46 lancements Windows. [Instructions et preuve](Verification_reproductible_v040.md). Comportements du jeu conservés.

## v0.41 — Sélection au clavier, 25 octobre 2026

Sélection E1–E6 commune au clic et aux touches, prise en compte AZERTY/pavé numérique, garde des panneaux et conservation des ressources et délais. 14 072 contrôles Godot dont 68 ciblés, 9 tests Python et 46 lancements Windows. Test interactif sur le second écran. [Détail](Selection_clavier_v041.md).

## v0.42 — Protection des commandes de fond, 25 octobre 2026

Défaut reproduit de redémarrage derrière un choix. Focus et activation des commandes de fond bloqués pendant les panneaux ; boutons du panneau et reprise des commandes vérifiés. 14 156 contrôles Godot, dont 76 dédiés et huit extensions de contrôles existants, 9 tests Python et 46 lancements Windows. [Détail](Commandes_modales_v042.md).

## v0.43 — Identification de la version, 25 octobre 2026

Version embarquée affichée dans le titre et le pied de fenêtre, conservée après redémarrage. Vérification de concordance entre dossier, notice, version du programme capturé et rapports. 25 suites, 14 159 contrôles Godot et 9 tests Python réussis. [Détail](Identification_version_v043.md).

## v0.44 — Focus pendant les changements de phase, 25 octobre 2026

Défaut reproduit : le bouton de lancement désactivé gardait le focus pendant le combat. Le focus est désormais rendu à une commande disponible, sans déplacer une sélection encore valide. 25 suites, 14 171 contrôles Godot, dont 12 ajouts dédiés aux deux factions, et 9 tests Python réussis. [Détail](Focus_combat_v044.md).

## v0.45 — Sources de compilation, 25 octobre 2026

Empreintes des dix sources de distribution relevées avant export et comparées après compilation puis avant archivage. Le manifeste conserve ce relevé initial. Vérification locale du paquet par --source-project. 25 suites, 14 171 contrôles Godot et 15 tests Python réussis, dont six tests de sources. [Détail](Sources_compilation_v045.md).

## v0.46 — Rejeu des rapports, 25 octobre 2026

Outil de rejeu en lecture seule pour rapports au format 2, non embarqué dans le jeu distribué. Vérifie le journal et le résultat contre les règles actuelles, et signale les différences de version. 26 suites, 14 213 contrôles Godot, dont 42 dédiés, et 15 tests Python réussis. Deux rapports issus du paquet Windows v0.45 rejoués sans modification. [Détail](Rejeu_rapports_v046.md).

## v0.47 — Calcul des comparaisons de bonus, 25 octobre 2026

Trois comparaisons réutilisées pendant la lecture, invalidées quand faction, vague, offres, bonus, défense, budget, PV ou activation des synergies changent. 27 suites, 14 283 contrôles Godot dont 70 dédiés, 15 tests Python réussis. Mesure locale sans rendu : mise à jour du panneau environ 1,35–1,40 ms avant, 0,23–0,25 ms après sur six N4 à budget imposé. [Limites et protocole](Calcul_bonus_v047.md).

## v0.48 — Échap dans les panneaux, 25 octobre 2026

Fermeture du récapitulatif et du bilan, annulation sans dépense de la spécialisation. Choix obligatoires conservés. 28 suites, 14 313 contrôles Godot dont 30 dédiés, 15 tests Python réussis. [Détail](Echap_panneaux_v048.md).

## v0.49 — Consignes contextuelles, 26 octobre 2026

Le texte de gauche suit les étapes de partie, sans instruction de première vague en combat ou en fin de partie. Compteur renommé Combat simulé et expliqué au survol. Douze textes vérifiés à 60 px de haut sur 76 et 213 px de largeur maximale sur 238. 28 suites, 14 313 contrôles Godot et 15 tests Python réussis. [Détail](Consignes_contextuelles_v049.md).

## v0.50 — Relevé du boss, 26 octobre 2026

Observation de l’issue du boss, de son temps de résolution et des PV retirés. Lecture dans le rapport et au survol de la vague 10 ; aucun changement du modèle de combat. Champ optionnel ajouté au format 2, anciens rapports acceptés par le rejeu. 29 suites, 14 339 contrôles Godot dont 26 dédiés, 15 tests Python réussis. [Détail](Releve_boss_v050.md).

## v0.51 — Barre de préparation, 26 octobre 2026

Barre proportionnelle au délai réel restant, sous le bouton de lancement. Lecture seule, sans clic ni focus ; teinte de pause et accent dans les cinq dernières secondes. 29 suites, 14 350 contrôles Godot, dont onze ajouts à la suite d’enchaînement, 15 tests Python réussis. [Détail](Barre_preparation_v051.md).

## v0.52 — Présentation de la carte, 26 octobre 2026

Relief du plateau, contraste des berges et de l’eau, garde-corps du pont, étages de feuillage et détails de la porte. Dessin seul, sans collision ni nouvelle ressource externe. 29 suites, 14 350 contrôles Godot et 15 tests Python réussis. [Détail](Presentation_carte_v052.md).

## v0.53 — Infobulle après lancement, 26 octobre 2026

Comportement observé dans la partie native v0.52 : l’aide réapparaissait sous la souris après le départ et recouvrait l’interface. Lancement sous le pointeur : aide masquée jusqu’à sa sortie, puis consultable au retour. 29 suites, 14 350 contrôles Godot et 15 tests Python réussis. [Détail](Infobulle_lancement_v053.md).

## v0.54 — Lecture progressive des choix, 26 octobre 2026

Réalisation du premier lot demandé : trois cartes de bonus condensées et détails facultatifs, y compris pour les bonus acquis ; rôles des spécialisations et chiffres sur demande. 30 suites, 14 558 contrôles Godot dont 208 nouveaux, et 15 tests Python réussis. Règles, statistiques et pauses conservées. [Détail](Lecture_progressive_v054.md).

## v0.55 — Silhouettes et attaques des défenseurs, 26 octobre 2026

Les six défenseurs possèdent des proportions et équipements distinctifs, avec contours, ombres et accents de spécialisation. Leur mouvement bref lit uniquement les tirs réellement résolus. 31 suites, 14 621 contrôles Godot dont 63 nouveaux, 15 tests Python et contrats du GDD réussis. Statistiques, portées, ciblage et progression inchangés. [Détail](Presentation_defenseurs_v055.md).

## v0.56 — Projectiles et impacts, 26 octobre 2026

Formes distinctes pour les six attaques, points de départ sur les équipements, explosions discrètes et marques sur les véritables victimes. Habillage de 0,12 seconde simulée, impacts immédiats et extinction en 0,32 seconde. 32 suites, 14 681 contrôles Godot dont 60 nouveaux, 15 tests Python et contrats du GDD réussis. Aucun changement de simulation. [Détail](Presentation_attaques_v056.md).

## v0.57 — Lecture du recrutement et des améliorations, 26 octobre 2026

Fiches par défaut centrées sur le rôle et les dégâts ; aperçus d’amélioration centrés sur les gains et le prix ; aides de recrutement condensées. Voir les chiffres conserve les valeurs et règles exactes. 33 suites, 14 819 contrôles Godot dont 138 nouveaux, 15 tests Python et contrats du GDD réussis. Aucune modification de simulation ou de pause. [Détail](Lecture_recrutement_v057.md).

## v0.58 — Bilan essentiel, 26 octobre 2026

Une première vue courte présente résultat, PV, passés, or gagné, premières pertes, plus fortes pertes et statut du boss. Les tableaux de vagues et de contributions restent disponibles dans leurs onglets. 34 suites, 14 855 contrôles Godot dont 36 nouveaux, 15 tests Python et contrats du GDD réussis. Aucun changement des rapports ou de la simulation. [Détail](Bilan_essentiel_v058.md).

## v0.59 — Silhouettes des ennemis, 26 octobre 2026

Les huit profils reçoivent des corps et équipements cartoon plus distincts. Les jauges sont légèrement relevées pour dégager les casques. Échelles, ordre de dessin, détection au survol, déplacements et caractéristiques conservés. 34 suites, 14 855 contrôles Godot, 15 tests Python et contrats du GDD réussis. [Détail](Presentation_ennemis_v059.md).

## v0.60 — Assets Horde transparents, 27 octobre 2026

Trois PNG individuels intégrés au plateau dans le style validé, proportions conservées, ancrage des pieds, mipmaps et badges existants. Une pose par classe avec recul au tir ; armes non animées indépendamment. 35 suites, 14 876 contrôles Godot et 16 tests Python réussis. Les 17 sources contrôlées incluent désormais les images et leurs paramètres d’import. [Détail et prompts](Assets_Horde_v060.md).

## v0.61 — Assets Alliance transparents, 27 octobre 2026

Archer elfe, arbalétrier nain et mage humain illustrés dans le style cartoon retenu. Rendu commun aux six défenseurs, cadres et équipements propres à chaque faction, filtrage avec mipmaps et badges conservés. Une pose par classe avec recul au tir, sans animation indépendante des armes. 36 suites, 14 901 contrôles Godot dont 25 nouveaux, 16 tests Python et contrats du GDD réussis. Les 24 sources de distribution incluent désormais les trois images Alliance et leurs imports. [Détail et prompts](Assets_Alliance_v061.md).

## v0.62 — Orientation et mouvements d’attaque, 27 octobre 2026

Les six défenseurs regardent vers le côté de leur dernier vrai tir, conservé entre deux attaques pendant le combat. Mouvement propre à chaque classe, miroir des points de départ des projectiles, badges et ombres stables. 37 suites, 15 075 contrôles Godot dont 174 nouveaux, 16 tests Python et contrats du GDD réussis. Aucun changement de combat ou d’équilibrage. [Détail](Animations_attaque_v062.md).
