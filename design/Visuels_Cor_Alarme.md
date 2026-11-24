# Cor d’alarme · Citadelle

Proposition du 24 novembre 2026 sur la v0.248 pour les missions 81 à 100. Un pictogramme de cor en laiton s’anime dans le bandeau. À l’impulsion, chaque ennemi protégé reçoit un bref éclat doré et un bouclier translucide à facettes. Le contour s’allège quand les corps se rapprochent. Une barre dorée juste au-dessus des PV garde la quantité de protection visible. À la rupture du bouclier, quelques éclats se dissipent.

- [GIF du Siège à taille de jeu et en agrandi](essais/alarme_v0248/Cor_alarme_en_combat.gif)
- [Comparatif avec le repère provisoire](essais/alarme_v0248/Cor_alarme_comparatif.jpg)

## Planches et branchement proposé

`prototype/assets/animations/effect.alarm/` contient cinq planches transparentes, cadre 104 × 96, ancre (52 ; 66), hauteur affichée 96 px à l’échelle 1.

| État | Planche | Utilisation essayée |
| --- | --- | --- |
| `warning` | 24 images en progression | Cor dans le bandeau pendant les 3 s d’annonce. Échelle 0,44, décalage (−1 ; +1) depuis l’icône existante. |
| `spawn` | 33 images sur 0,55 s | Trois ondes autour du cor à l’impulsion. Dernière pose tenue jusqu’à la fin du bandeau. |
| `level_up` | 20 images sur 0,40 s | Éclat d’activation attaché à l’ennemi, avec la position de l’événement en repli. |
| `idle` | 24 images, 18 IPS | Bouclier tant que la réserve reste positive, indépendant des 2 s d’affichage du bandeau. |
| `death` | 16 images sur 0,27 s | Rupture dès que l’absorption épuise la réserve, y compris après un dégât de zone. |

À taille de jeu, la barre de protection mesure jusqu’à 24 × 2 px. Dans l’essai, elle est placée 4 px au-dessus des PV. Le contour s’atténue progressivement quand le voisin projeté le plus proche se trouve entre 46 et 15 px. Il passe de 0,94 à 0,42 d’opacité et d’une échelle relative de 1 à 0,80 pour rester lisible à côté des autres unités. L’éclat suit le même principe. Le code d’essai trace les événements d’application et de rupture avec l’identifiant de l’unité pour pouvoir la suivre au rendu. Les données du combat et les valeurs de bouclier sont celles du moteur. Jouer les planches en temps de combat et conserver le repère provisoire en repli.

## Contrôles

159 captures v0.248 sur les missions 81, 84, 92 et 94, Alliance et Horde. Deux impulsions contrôlées, à 15 et 30 s. En mission 92 Horde, sept ennemis ont simultanément leur réserve à 15,14 s, dont deux à 15,6 px d’écart. Deux boucliers sont encore présents après disparition du bandeau à 17,2 s. Des ruptures ont été observées sous des tirs des défenseurs sur les quatre missions. Validateur à zéro problème sur 70 dossiers. Bibliothèque d’animations, affixes de biome et bandeaux passent, soit 6 669 contrôles ciblés. Branchement essayé dans une copie isolée, en attente de l’avis du porteur et de l’intégration par Claude Code.
