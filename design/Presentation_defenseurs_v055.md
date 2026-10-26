# Présentation des défenseurs — v0.55

26 octobre 2026. Deuxième lot de présentation après la [lecture progressive des choix](Lecture_progressive_v054.md), dans les [orientations validées](Orientation_presentation_2026-10-26.md).

## Direction réalisée

Les six défenseurs sont redessinés dans un style cartoon : têtes et mains accentuées, silhouettes plus différenciées, contours sombres, touches claires sur les équipements et ombre elliptique au sol. Les dessins restent des formes produites par le code du projet, sans asset externe. Ils constituent une étape de prototype, pas des personnages définitifs. La référence de fantasy cartoon donnée par le porteur du projet guide les archétypes ; aucun personnage ou asset de World of Warcraft n’est repris.

| Défenseur | Signes distinctifs |
| --- | --- |
| Archer elfe | Longues oreilles, chevelure blonde, cape verte, carquois et arc courbe |
| Arbalétrier nain | Corps large et bas, barbe cuivrée, casque métallique, épaulières et arbalète horizontale |
| Mage humain | Robe bleue évasée, haut chapeau, barbe claire et bâton à cristal |
| Lanceur de haches troll | Corps élancé, peau turquoise, longues oreilles, crête, défenses et grande lame de hache |
| Sapeur gobelin | Petite taille, grandes oreilles, lunettes, sac de cuir et bombe ronde avec mèche |
| Chaman orc | Corps massif, peau verte, défenses, fourrure aux épaules, robe violette et totem en os |

Les niveaux et branches restent indiqués par les badges existants. Le niveau spécialisé reçoit aussi un petit emblème doré sur le torse. Ces accessoires ne créent ni équipement à acheter, ni nouvelle aptitude. Les noms et statistiques du défenseur sélectionné continuent d’apparaître dans l’interface.

## Mouvement d’attaque

Le rendu lit le dernier tir récent du même emplacement dans `model.shots`. Un mouvement de recul et de levée du corps, accompagné d’un mouvement de l’arme, revient à la pose de repos en **0,26 seconde simulée**. Le côté du recul vient du point d’impact réellement enregistré. Aucun mouvement n’est déclenché par un tir d’un autre emplacement ou par un événement futur. La fin d’une vague rétablit immédiatement le repos.

Le rendu n’ajoute ni anticipation retardant les dégâts, ni projectile avec collision, ni nouveau calcul de combat. Les marques d’impact existantes restent liées aux victimes réelles. Le mouvement suit la vitesse de combat : il est plus bref à ×2 et au ×10 temporaire de débogage. Aucun clignotement ou animation d’attente permanente n’est ajouté.

La route, les six emplacements, leurs points de sélection, les portées, les liens de synergie et l’ordre de dessin par profondeur restent identiques. La silhouette n’agrandit pas la portée et ne déplace pas le point de tir. Les ennemis conservent leurs dessins actuels.

## Vérification

**31 suites, 14 621 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **63 contrôles nouveaux** vérifient les bornes du mouvement, l’absence d’animation avant combat, les vrais tirs des six défenseurs, l’indépendance des emplacements, le sens du recul, les événements simultanés ou futurs et le retour au repos. Des redessins répétés des six silhouettes, niveaux et branches ne modifient ni rapport, ni générateur aléatoire, ni états des unités ou tirs.

La vérification du paquet Windows conserve les vues existantes et ajoute une capture pendant une vraie attaque pour chacun des six défenseurs. Les catalogues utilisent un budget imposé pour montrer les niveaux ; ce sont des contrôles graphiques, pas des parties d’équilibrage. Les résultats de distribution et de contrôle natif sont consignés dans Distribution_Windows_v055.json.

## Périmètre et suite

Cette version travaille les défenseurs existants et leur mouvement de tir. L’équilibrage, les dix vagues, le boss à 600 PV et la préparation de 30 secondes restent identiques. Aucune progression permanente introduite. Les projectiles et impacts pourront être approfondis dans une prochaine passe, ainsi que la hiérarchie des aides de recrutement. La compréhension et la reconnaissance immédiate restent à confronter à un essai joueur.

GDD principal v0.14. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Contrôle final du paquet

**60 lancements, 59 captures, dix empreintes locales concordantes.** Les catalogues des deux factions et les six captures pendant les attaques ont été inspectés : équipements, badges, route et portées restent visibles.

[Alliance — catalogue à budget imposé](essais/captures/QA-v055_alliance.png) · [Horde — catalogue à budget imposé](essais/captures/QA-v055_horde.png).

Un contrôle natif séparé du même exécutable a été opéré par l’agent sur l’écran de droite, sans changer le budget : Horde avec 150 or initiaux, achat d’un troll en E1 et d’un sapeur en E2, première vague à vitesse ×1. La [capture en combat](essais/captures/QA-v055_combat_natif.jpg), à 10,4 secondes simulées, montre 4 ennemis éliminés, aucun passé, 37 or et 20 PV. Le journal dédié ne contient aucune erreur et le jeu a été fermé. Ce contrôle partiel ne constitue ni une campagne complète ni un nouveau retour joueur ni une validation générale d’équilibrage.
