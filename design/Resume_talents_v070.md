# Talents actifs de la partie — v0.70

28 octobre 2026. Complément du GDD principal v0.14 et des décisions de progression persistante. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Résultat visible

Un rappel discret en haut à droite indique les points permanents actifs pour la faction choisie. Son survol donne les points par arbre, les PV initiaux et les bonus de chaque type de défenseur. Une configuration sans talent est explicitement indiquée.

Le bilan de victoire globale ou de défaite propose un quatrième onglet « Talents ». Trois cartes présentent les arbres, les noms des talents retenus et leurs rangs. Une zone distincte donne les PV de départ et les effets permanents par défenseur. Le rapport Markdown conserve ce résumé lisible en complément des rangs bruts du JSON.

## Règles conservées

- La lecture porte sur les rangs copiés dans le modèle au départ, y compris pour les anciens rapports à neuf rangs. Elle ne dépend pas des affectations ultérieures du profil.
- Aucun achat, remboursement, changement de rang ni accès aux arbres pendant la partie. Le nouvel onglet est absent d’un bilan de carte intermédiaire.
- Les bonus gagnés dans la tentative, niveaux, spécialisations et synergies s’ajoutent séparément ; le résumé ne les présente pas comme des talents permanents.
- Ressources provisoires jusqu’au résultat global, versement unique, progression acquise conservée après relance. Le chiffrement Windows et les copies de secours restent ceux de v0.69.
- Le catalogue, les prix, les effets et la difficulté ne changent pas. Les montants restent des hypothèses d’équilibrage.

## Évolutions et questions ouvertes

La présentation pourra évoluer avec les retours de lecture. L’équilibrage des arbres, le parcours à plusieurs cartes et la synchronisation Steam restent des chantiers distincts ; ils ne sont pas ajoutés par cette version. Le format JSON du rapport et sa relecture restent compatibles.

## Validation

47 suites et 16 725 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 115 nouveaux contrôles couvrent les deux factions, les configurations sans talent, actuelles et historiques, la lecture sans modification du combat ou du générateur aléatoire, la cohérence des bénéficiaires, le rejeu des rapports et le cliché indépendant des modifications ultérieures du profil. Le bilan intermédiaire refuse l’onglet Talents.

Le ZIP Windows a passé 105 lancements avec 104 captures et 37 sources concordantes. Les résumés sont vérifiés dans le véritable exécutable : profils éphémères isolés, 33 points de contrôle, bilan global, rapport JSON rejouable et section Markdown lisible. Le codec, le profil, le modèle de combat, les vagues, les statistiques et les règles historiques ont les mêmes empreintes source que v0.69.

Contrôle visuel : avant le départ [Alliance](essais/captures/QA-v070_alliance_loadout_preparation.png) et [Horde](essais/captures/QA-v070_horde_loadout_preparation.png), bilan Talents [Alliance](essais/captures/QA-v070_alliance_loadout_summary.png) et [Horde](essais/captures/QA-v070_horde_loadout_summary.png). [Régression complète](essais/v070_regression.json) et [relevé de distribution](Distribution_Windows_v070.json). Aucun nouvel essai humain d’équilibrage n’est revendiqué.
