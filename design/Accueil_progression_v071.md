# Préparer sa faction à l’accueil — v0.71

28 octobre 2026. Complément du GDD principal v0.14 et des décisions de progression par faction. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Lecture de l’accueil

Chaque colonne indique les trois défenseurs du camp, ses ressources enregistrées, les points de talent actifs, les points déjà achetés restant à placer et les PV de départ de la forteresse. Le bouton des talents rappelle les points à placer lorsqu’il en reste.

Le conseil distingue quatre situations : affecter des points possédés, acheter un nombre de points permis par le solde et le plafond, collecter les ressources manquantes pour le prochain point ou constater que tous les points ont été achetés. Il ne réalise aucune transaction.

Les données se mettent à jour au retour des arbres. Une progression absente est indiquée comme indisponible. Un profil bloqué affiche une alerte et permet de consulter le détail dans les talents ; il n’affiche pas un zéro susceptible de faire croire que les gains ont disparu.

## Règles conservées

Ressources, points et arbres restent séparés entre les deux camps. Les montants, effets, prix et plafonds sont inchangés et restent des hypothèses d’équilibrage. Choisir sa faction applique les talents et ferme l’accès à leur édition jusqu’à la victoire finale ou la défaite. Les gains d’une tentative restent provisoires jusqu’à ce résultat global.

Le profil protégé, son format et sa persistance restent inchangés. Aucun nouveau contenu de combat, difficulté, monnaie, achat automatique, intégration Steam ou sauvegarde du combat en cours n’est ajouté.

## Validation

48 suites et 16 754 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 29 nouveaux contrôles vérifient profil absent, premier achat, séparation des camps, points disponibles, PV initiaux, absence de transaction à la lecture, retour des arbres, plafond d’achat, dimensions des textes et accès aux arbres fermé après le départ. Un profil bloqué n’affiche pas de solde fictif.

Le paquet Windows a passé 108 lancements avec 107 captures et 37 sources concordantes. Les captures utilisent des profils isolés, sans toucher aux gains réels. Le profil, le codec, les talents, leurs arbres, le modèle de combat, les vagues, les statistiques et les rapports ont les mêmes empreintes source que v0.70.

Captures inspectées : [profil neuf](essais/captures/QA-v071_selection.png), [points à placer et achat possible](essais/captures/QA-v071_home_prepared.png), [plafond atteint](essais/captures/QA-v071_home_maximum.png), [profil bloqué](essais/captures/QA-v071_home_blocked.png). [Régression](essais/v071_regression.json) et [distribution](Distribution_Windows_v071.json). Les montants restent provisoires et aucun nouveau retour humain d’équilibrage n’est revendiqué.
