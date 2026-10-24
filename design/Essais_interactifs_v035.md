# Essais interactifs au PC — session du 24 octobre 2026

Essais réalisés par l’agent, avec l’autorisation explicite du porteur du projet de lancer et tester le jeu sur son PC. Ces observations ne sont pas des retours d’un joueur humain. Les parties utilisent le budget normal et des achats réellement payés. L’heure de session, les décisions et les temps d’attente dus au développement rendent ces essais impropres à mesurer une durée humaine de 8 à 12 minutes.

## Itération A — Alliance

Version de travail locale : dev_v035_setup, antérieure aux dernières retouches de silhouettes et de libellés. Départ avec archer E1 et arbalétrier E2, puis mage E3, archer E4 et arbalétrier E5. Les vagues s’enchaînent automatiquement après le premier lancement ; vitesse ×2 utilisée après le début de partie.

| Indicateur | Relevé du bilan |
| --- | --- |
| Résultat | Victoire, dix vagues terminées |
| Forteresse | 8 / 20 PV |
| Or restant | 252 |
| Éliminés / passés | 175 / 7 |
| PV perdus au combat | 12 |
| Or gagné au combat | 730 |
| Combat simulé cumulé | 446,1 s affichées |
| Dernière vague | 11 éliminés, aucun passé |
| Bonus, dans l’ordre | Recrutement organisé ; Postes d’observation ; Exercice de tir |

Défense finale : archer E1 niveau 1, arbalétrier E2 niveau 1, mage E3 niveau 4 Arcaniste de concentration, archer E4 niveau 1, arbalétrier E5 niveau 1. Investissement final total de 628 or, cohérent avec 150 + 730 − 252. Des commandes tentées trop tard dans la préparation ont été refusées pendant le combat ; aucune dépense indue observée.

Vérifiés en interaction : sélection de faction, recrutement, prix réduit, attente aux bonus, défilement d’une liste longue sans perte des boutons, lecture des nouvelles valeurs arrondies, passage niveau 3, ouverture/annulation/réouverture de spécialisation sans débit anticipé, confirmation à 150 or, état de victoire et bilan. Fenêtre agrandie sur le moniteur 2560 × 1440 puis restaurée : le panneau des bonus est resté lisible.

[Capture du bilan Alliance](essais/captures/QA-v035_Alliance_bilan.jpg).

## Itération B — Horde

Version de travail locale : dev_v035_horde, incluant les nouveaux profils ennemis et la route couverte dorée, avant l’ajout demandé du ×10. Trois défenseurs seulement : lanceur de haches E1, sapeur E2 et chaman E3, tous niveau 1. Bonus choisi après vague 3 : Ateliers efficaces. Aucune amélioration payée lors de cet essai.

| Indicateur | Relevé du bilan |
| --- | --- |
| Résultat | Défaite en vague 6 |
| Forteresse | 0 / 20 PV |
| Or restant non dépensé | 199 |
| Éliminés / passés | 86 / 16 |
| PV perdus au combat | 20 |
| Or gagné au combat | 274 |
| Combat simulé cumulé | 284,2 s affichées |

Les trois achats totalisent 225 or, cohérents avec 150 + 274 − 199. La partie a continué pendant d’autres travaux de développement, sans profiter de toutes les préparations. La défaite ne suffit donc pas à proposer un rééquilibrage de la Horde. Elle valide ici l’affichage de défaite, les vagues non jouées du bilan et la cohérence des ressources.

[Capture du bilan Horde](essais/captures/QA-v035_Horde_defaite.jpg).

## Limites et suites

Les instantanés intermédiaires précèdent certains derniers changements de la livraison. Les contrôles automatisés et le contrôle du paquet final couvrent la source finale. L’équilibre des factions ne se déduit pas de ces deux parties ; les observations humaines restent nécessaires. Aucun réglage de combat n’est changé sur cette base.

## Contrôle C — ×10 dans le paquet Windows

Le bouton a été activé au PC en suivant ×1 → ×2 → ×10 debug. Une vague 1 Horde avec lanceur de haches E1 et sapeur E2 a conservé ses dix éliminations, zéro fuite, 20 PV, 55 or et 24,5 secondes simulées. Le décompte de préparation a continué en secondes réelles. [Capture du bouton ×10 et de son aide](essais/captures/QA-v035_x10.jpg). Ce contrôle n’est pas présenté comme une troisième campagne complète. L’infobulle de départ restée sur l’ancienne vague a conduit à la correction supplémentaire décrite dans le relevé de livraison.

## Contrôle D — infobulle de départ actualisée

Dans le binaire reconstruit après correction, le pointeur a été laissé sur le bouton de départ pendant le passage de vague 1 à vague 2 à ×10, sans défenseurs. Le texte est passé à la composition de la vague 2 et le panneau a conservé une taille lisible. Ce scénario volontaire sans défenseurs s’est terminé en défaite et sert uniquement à vérifier l’interface, pas l’équilibrage. [Capture du texte actualisé](essais/captures/QA-v035_infobulle_actualisee.jpg). Le jeu a été fermé après le contrôle.
