# Repères dans les arbres de talents — v0.72

28 octobre 2026. Complément du GDD principal v0.14 et des arbres verticaux v0.68. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Lecture des choix

Les quinze icônes de chaque faction affichent désormais un petit repère en complément de leur rang et de leur couleur :

| Repère | Signification |
| --- | --- |
| + | Un point possédé permet d’investir le prochain rang |
| Coche | Talent au rang maximum |
| Cadenas | Palier non ouvert ; le détail indique les points requis |
| × | L’autre spécialité finale de cet arbre est choisie |
| ! | Les prérequis sont satisfaits mais il faut acheter un point |

Un profil bloqué affiche un cadenas et le détail « Sauvegarde à vérifier », sans annoncer une affectation possible. Les icônes restent inspectables au clavier et au survol. Le titre de l’encart précise l’état du talent sélectionné.

## Progression verticale

Les lignes deux et trois présentent une jauge et les points déjà dépensés dans les lignes précédentes du même arbre, plafonnés au seuil requis. Les seuils 5 et 10 restent ceux des règles existantes. Dépenser dans une autre colonne ou dans la ligne à débloquer ne contribue pas au prérequis. Un palier ouvert ne garantit pas un point disponible ni une spécialité encore accessible.

## Périmètre

Présentation uniquement : aucun talent, prix, rang, effet, seuil ou mode de progression supplémentaire. Les arbres restent accessibles hors parcours ; la ressource est versée au résultat global. Profil protégé et format de sauvegarde inchangés. Les valeurs restent provisoires et l’équilibrage humain demeure à poursuivre.

## Validation

49 suites et 16 860 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 106 nouveaux contrôles couvrent les deux factions, l’accord exact du repère plus avec le droit d’affectation, l’inspection des talents fermés, les jauges par colonne, l’exclusion finale, le manque de point, l’actualisation après achat et dernier rang, le profil bloqué et l’absence de dépense lors de la lecture.

Le ZIP Windows a passé 110 lancements avec 109 captures et 37 sources concordantes. Les captures utilisent des profils isolés. Le profil, le codec, les talents et leurs effets, le modèle de combat, les vagues, les statistiques et les rapports ont les mêmes empreintes source que v0.71.

Captures inspectées : arbres [Alliance](essais/captures/QA-v072_alliance_talents.png) et [Horde](essais/captures/QA-v072_horde_talents.png), sans point disponible [Alliance](essais/captures/QA-v072_alliance_talents_no_points.png) et [Horde](essais/captures/QA-v072_horde_talents_no_points.png). [Régression](essais/v072_regression.json) et [distribution](Distribution_Windows_v072.json). Aucun nouvel essai humain d’équilibrage n’est revendiqué.
