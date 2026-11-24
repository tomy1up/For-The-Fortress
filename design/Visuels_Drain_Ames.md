# Drain d’âmes · La Nécropole

Proposition du 24 novembre 2026 sur la v0.247 pour les missions 181 à 200. Un éclat marque la chute de l’ennemi. Une âme violette quitte ce point et suit une courte courbe vers chaque ennemi soigné. Un anneau bas et quelques étincelles signalent l’absorption. Si plusieurs ennemis reçoivent un soin, ils partagent l’éclat de départ. Les âmes suivent chacune leur cible.

Pendant l’annonce, le liseré s’éclaire et des volutes apparaissent près des bords internes du plateau. En phase active, les volutes continuent de monter et le plateau prend une teinte violette à faible opacité. Le ruban d’état du jeu donne le temps restant. Les volutes s’atténuent avant la fin de la fenêtre active.

- [GIF à taille native, une et trois cibles, avec agrandissement](essais/souldrain_v0247/Drain_ames_en_combat.gif)
- [Annonce, activité, dissipation et comparaison du transfert](essais/souldrain_v0247/Drain_ames_comparatif.jpg)

## Planches et branchement proposé

`prototype/assets/animations/effect.souldrain/` contient cinq planches transparentes de cadre 104 × 72, ancre (52 ; 36), hauteur affichée de 72 px.

| État | Planche | Utilisation essayée |
| --- | --- | --- |
| `warning` | 16 images, progression | Progression pendant les 3 s d’annonce. Huit points à l’intérieur du pourtour du plateau. |
| `mist` | 24 images, 18 IPS | Volutes en temps de combat, phases légèrement décalées. Montée en 0,26 s, dissipation en 0,34 s. Teinte de plateau à 0,052 d’opacité. |
| `spawn` | 10 images, 0,17 s | Éclat à la source, à 9 px au-dessus du point au sol. Partagé entre les soins du même événement. |
| `idle` | 16 images, 36 IPS | Tête de l’âme orientée vers le prochain point, de 0,10 à 0,33 s après le soin. Courbe de 4 à 11 px de hauteur. Taille de 0,32 à 1 selon la longueur du trajet. |
| `death` | 12 images, 0,20 s | Éclat d’absorption à partir de 0,30 s, à 12 px au-dessus de l’appui de la cible. |

Les ancrages utilisent les coordonnées projetées du plateau. Positions des volutes en fractions de carte utilisées dans l’essai (0,17 ; 0,08), (0,53 ; 0,09), (0,88 ; 0,10), (0,91 ; 0,49), (0,89 ; 0,84), (0,58 ; 0,91), (0,25 ; 0,89), (0,11 ; 0,48). Échelle 0,83. L’avertissement reprend le liseré à 2 px. La traîne du transfert est un trait fin en six segments derrière la tête.

Le branchement est essayé dans une copie du jeu. Chaque événement `soul` y transporte l’identifiant du destinataire, pour que l’absorption reste accrochée à l’ennemi pendant sa marche. Sa position enregistrée sert de repli s’il disparaît. Toutes les phases visuelles utilisent `model.elapsed`. Le soin reste appliqué lors de l’élimination. Claude Code peut conserver le rendu provisoire si les planches sont absentes.

## Contrôles

95 captures sur une copie v0.247. Les missions 181 Alliance et 191 Horde couvrent respectivement un et trois bénéficiaires dans une mise en scène contrôlée. L’élimination passe par le moteur du jeu et les bénéficiaires passent de 55 % à 65 % de leurs PV dans les deux mises en scène. Un soin déclenché par les défenseurs a également été observé à 12,572 s sur la mission 191 Alliance. Les tests de la bibliothèque d’animations, des affixes de biome et du chapitre de la Nécropole totalisent 7 753 contrôles réussis. Le validateur des planches signale zéro problème sur 67 dossiers. Visuel proposé au porteur avant intégration.
