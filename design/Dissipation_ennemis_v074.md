# Dissipation des ennemis éliminés — v0.74

28 octobre 2026. Lot de sensations de combat dans la direction cartoon retenue. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Effet visuel

Une élimination produit cinq petites bouffées de poussière au dernier emplacement réel de l’ennemi, pendant 0,45 seconde de simulation. Le boss utilise le même effet avec une échelle légèrement supérieure. Les ennemis arrivés à la forteresse ne déclenchent pas cet effet.

Après la fin d’une vague, les dernières bouffées terminent leur extinction pendant au plus 0,45 seconde réelle, sans bloquer le compte à rebours, les choix ou le bilan. Nouvelle vague et nouvelle partie effacent les anciennes observations. Le rendu affiche au plus 24 dissipations simultanées pour limiter la charge visuelle.

## Séparation du combat et du dessin

Le modèle consigne le moment, l’identité, le profil et le lieu des éliminations dans une observation réservée au rendu. La cible est retirée et sa récompense attribuée immédiatement, comme auparavant. Aucun cadavre ciblable, délai de tir ou de récompense supplémentaire. Les malédictions létales passent par la même observation.

La trajectoire des bouffées est déterministe et n’utilise pas le générateur aléatoire du jeu. Le temps de fin d’effet appartient à la vue. Prix, talents, vagues, statistiques et progression restent inchangés ; les valeurs d’équilibrage demeurent provisoires.

## Validation

51 suites et 17 034 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 52 nouveaux contrôles couvrent position réelle, récompense unique et retrait immédiat, absence de dissipation sur simple coup ou arrivée, bornes des particules, extinction après vague, nettoyage, limite de rendu, déterminisme, six classes, dessin sans mutation et tick létal sans nouveau tir.

Une comparaison de seize scénarios avec le code v0.73 vérifie les rapports, états aléatoires, événements et pertes réelles identiques : deux factions, zéro ou 33 points de talent, deux graines, pas de simulation de 0,05 ou 300 secondes. La seule métadonnée normalisée est la version du projet, fixée à 0.74 des deux côtés. [Preuve](essais/v074_comparison.json).

Le paquet Windows passe 114 lancements, produit 113 captures et correspond à 37 sources locales. Captures inspectées de véritables éliminations [Alliance](essais/captures/QA-v074_alliance_elimination.png) et [Horde](essais/captures/QA-v074_horde_elimination.png). [Régression](essais/v074_regression.json) et [distribution](Distribution_Windows_v074.json). Profils isolés, aucun nouvel essai humain d’équilibrage.
