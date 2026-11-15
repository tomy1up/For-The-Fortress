# Sapeur gobelin · lancer

L’essai conserve les lunettes jaunes, le foulard et la sacoche du Sapeur. La charge repose dans sa main dans l’illustration de garde. Le lancer commence sur la paume ouverte au déclenchement du tir, puis le bras accompagne le geste, redescend et reprend la pose de garde. Le projectile est dessiné par le jeu dès le lâcher. La planche utilise trois poses de geste, dessinées avec le générateur intégré d’après le sprite de départ, puis le dessin de garde existant. Les huit images comprennent des poses tenues.

[Voir la boucle à taille native au Gué](essais/gestes_combat/Sapeur_lancer_en_jeu.gif)

| Contrôle | Résultat sur la copie v0.208 |
| --- | --- |
| Main et projectile | Paume ouverte au départ, projectile dans le prolongement de la main dans les deux directions. |
| Appuis et palette | Pieds alignés sur un pivot commun. Lunettes, foulard et sacoche lisibles à l’échelle du jeu. |
| Vitesses | Lancer réel à gauche depuis E1 et à droite depuis E2, contrôlé à ×1 et ×2. |
| Temps figé | Le temps simulé et les pixels du recadrage restent identiques pour les quatre cas. |
| Technique | 24 dossiers, 0 problème au validateur. Bibliothèque d’animations : 156 contrôles réussis. |

La planche dure 0,32 seconde. Au premier tir vers la gauche, le personnage se retourne quand le jeu choisit sa cible. Une pose dédiée à la reprise d’une charge dans la sacoche pourrait adoucir le retour à la garde. Cette proposition attend un avis artistique dans `design/essais/gestes_combat/defender.horde.sapper/`. Pour l’intégrer après validation, déposer la planche et sa description dans `prototype/assets/animations/defender.horde.sapper/`. Le geste exploite le déclenchement et le projectile de la version actuelle.

## Lancer retravaillé après retour du 15 novembre

Le porteur a signalé que la charge semblait s’envoler d’elle-même. Le nouvel essai ajoute quatre poses dessinées d’après l’illustration du Sapeur : recul de l’épaule avec charge en main, passage devant le visage avec charge en main, extension et lâcher, accompagnement vers le bas. Les appuis restent ancrés. Les images intermédiaires de la planche retiennent les poses clés. Le cycle d’essai dure 0,36 s.

[Voir la boucle du nouveau lancer](essais/gestes_combat/sapeur_arme/Sapeur_lancer_retravaille.gif)

Pour vérifier le geste, la copie v0.208 diffère le projectile et l’effet de tir de 0,12 s à partir de l’événement de combat. Origine du projectile par rapport au pied `(±34, -27)`. Le projectile devient visible sur la première pose à main vide. Les dégâts restent résolus à l’instant du tir. Le marqueur de l’impact apparaît encore dès le départ du projectile dans cet essai. À revoir avec Claude pour que l’impact visuel coïncide avec l’arrivée sans changer les règles. La planche et ce réglage sont en étude. Contrôles rejoués à ×1 et ×2 dans les deux sens, temps figé, validateur (24 dossiers, 0 problème) et bibliothèque (156 contrôles réussis).
