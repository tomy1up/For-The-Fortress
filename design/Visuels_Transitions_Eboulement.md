# Éboulement · chute et dégagement

Proposition du 24 novembre 2026 sur la v0.247. Cinq chutes successives forment l’amas. Les gros blocs du fond se posent d’abord, puis les pierres plus basses complètent le premier plan. Les contacts les plus marqués soulèvent un peu de poussière. Le porteur a retenu le dégagement du premier essai, où le tas descend dans la galerie et laisse quelques gravillons se disperser. Le dessin du tas, son empreinte au sol et l’avertissement existant servent de raccords.

- [GIF en combat sur la mission 121, taille de jeu et agrandissement](essais/eboulement_transitions/Eboulement_amas_en_combat.gif)
- [Comparatif des deux entrées de la mission 134](essais/eboulement_transitions/Eboulement_deux_entrees.jpg)

## Planches et synchronisation proposée

Les deux planches sont déclarées dans `prototype/assets/animations/effect.rockfall/animation.json`. Elles partagent le cadre de 150 × 112, l’ancre (75 ; 78,5) et la hauteur de jeu de 67,2 px de `blocked`. Les raccords avec le tas reprennent exactement la première image de `blocked`.

| Phase | État de la planche | Durée | Fenêtre du premier cycle |
| --- | --- | ---: | --- |
| Chute | `spawn`, 41 images dans `arrival.png` | 0,68 s | 12,00 à 12,68 s |
| Tas au sol | `blocked`, boucle existante | 3,78 s | 12,68 à 16,46 s |
| Dégagement | `death`, 32 images dans `clearance.png` | 0,54 s | 16,46 à 17,00 s |

Dans l’essai, `valley_view.gd::_draw_rockfall` sélectionne ces états avec l’âge du blocage et le temps restant, en l’ancrant sur la route désignée par le modèle. Entre les transitions, la boucle du tas effectue un nombre entier de cycles pour raccorder sa première image aux deux planches. La réouverture reste à 17 s, puis à 29 s sur le deuxième cycle. Si une planche de transition manque, le rendu peut conserver le tas existant. Le branchement a été essayé dans une copie de jeu et reste à intégrer par Claude Code après avis du porteur.

## Contrôles

272 captures de la version de travail sur les missions 121 et 134, dans les deux factions. Deux cycles contrôlés par mission. En 134, l’effet change d’entrée entre les deux cycles. En 121, les deux premiers ours apparaissent toujours à 17,0 s et 17,3 s. Le GIF rapproche les deux transitions en écourtant le temps d’attente intermédiaire. Validateur des animations à zéro problème sur 66 dossiers. Régressions ciblées de la bibliothèque d’animations et de l’Éboulement réussies (230 et 2 039 contrôles).
