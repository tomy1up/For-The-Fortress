# Forteresses des deux factions — v0.76

28 octobre 2026. Lot de présentation cartoon et de cohérence entre les factions. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Identités visuelles

L’Alliance conserve une architecture de pierre claire, désormais soulignée de contours, avec tours pointues bleues et garnitures dorées. La Horde reçoit du bois renforcé de métal, des toits rouges plus bas et deux défenses ivoire de part et d’autre de la porte. Chaque bannière porte la couleur du camp et ondule légèrement.

Le dessin est réalisé dans la vue existante, sans nouvelle image ni ressource externe. Ce sont des éléments de présentation du prototype, encore amenés à évoluer avec les retours artistiques.

## Géométrie conservée

La cour, le décalage du bâtiment et le point d’arrivée logique restent identiques pour les deux factions. E6 reste dégagé et constructible. Aucun mur ou drapeau n’ajoute de collision ou de cible. PV, trajets, vagues, talents, sauvegarde et récompenses ne changent pas.

L’animation décorative utilise le temps de la vue, sans consommer le générateur aléatoire du jeu ni modifier le modèle. Les silhouettes restent dans une emprise commune réservée au bâtiment, hors cour et libellé.

## Validation

53 suites et 17 138 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 26 nouveaux contrôles couvrent palettes distinctes, valeur par défaut, absence de palette partagée mutable, position, dégagement d’E6, phase d’animation bornée, modèle et aléatoire inchangés, sélection puis construction réelle sur E6.

Le ZIP Windows passe 120 lancements, produit 119 captures et correspond à 37 sources locales. Le modèle, les vagues, les statistiques, les talents, le profil et les rapports ont les mêmes empreintes source que v0.75. Captures inspectées : [Alliance](essais/captures/QA-v076_alliance_fortress.png) et [Horde](essais/captures/QA-v076_horde_fortress.png). [Régression](essais/v076_regression.json) et [distribution](Distribution_Windows_v076.json). Profils isolés ; aucun nouvel essai humain d’équilibrage.
