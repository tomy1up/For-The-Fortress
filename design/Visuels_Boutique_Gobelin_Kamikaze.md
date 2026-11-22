# Boutique · Gobelin des braises

Le type 44 s’affiche comme « Gobelin des braises » en v0.236. Son identifiant est `horde.kamikaze`. Le gobelin projette une braise magique qui rend l’ennemi touché volatil pendant quatre secondes. Si l’ennemi meurt pendant ce délai, il explose et blesse les ennemis voisins. Le gobelin reste à son poste.

Le manteau rouille, la coiffe cuivrée et la main ouverte distinguent cette proposition du Sapeur, du Pillard et du Poseur de mines. Le porteur a validé le visuel fixe le 14 novembre 2026.

![Portrait et première application en combat](essais/boutique_guetteurs/Gobelin_kamikaze_volatilite.jpg)

| PNG | Cadre | Pied | Hauteur | Départ du lancer d’essai |
| --- | --- | --- | ---: | --- |
| `gobelin_kamikaze_v001.png` | `Rect2(0, 0, 1115, 1113)` | `(401, 1113)` | 53 px | `(28, -40)` |

Sur une copie de la v0.202, le projectile d’essai prend la forme d’une braise facettée. Le repère `volatile.png` est partagé avec l’Alchimiste. Portrait, déblocage, recrutement et première application en combat ont été vérifiés. Le comparatif montre le repère à ×1 et ×2. Les 181 contrôles d’illustration et les 49 contrôles du quatrième lot passent.

La braise du sprite fixe reste visible dans la main pendant le vol du projectile. L’animation devra synchroniser son départ avec la poussée de la paume. Le visuel de l’explosion et l’enchaînement restent à brancher et à vérifier. Le repère d’étude `volatile_burst.png` peut servir aux deux factions si le jeu expose le lieu et l’instant du déclenchement.

## Formation et lancer de la braise

Le Gobelin retourne sa paume, concentre la lumière et pousse la braise vers l’avant à 0,40 s. Elle quitte le dessin à l’image 25 à partir de zéro. Le bras accompagne la projection avant de revenir en garde. Seize poses dessinées, 60 images sur 0,96 s. Appuis calés à la hauteur de garde de 58 px.

[Essai en jeu](essais/gestes_combat/gobelin_braises/Gobelin_braises_en_jeu.gif) · [Planche des seize poses](essais/gestes_combat/gobelin_braises/Planche_gobelin_braises.png)

La même braise facettée se forme dans la main puis file en ligne droite, avec le repère indiqué dans lacher.json et retourné avec le sprite. L’étoile de volatilité est synchronisée à l’impact dans l’essai, à 0,52 s avec vol ou à 0,40 s à bout portant, si la cible est déjà derrière la main. Le badge reste visible lors d’un renouvellement. Les paramètres de la volatilité et des dégâts sont conservés dans le modèle. Six tirs en mission 94 sur copie v0.236, dans les deux sens à ×1 et ×2 avec pause, raccourci de vol et renouvellement contrôlés. Validateur à zéro problème sur 56 dossiers, 197 contrôles d’animation, 77 des effets d’unités et 93 de boutique réussis. L’essai attend l’avis du porteur.

Consignes au générateur intégré. Conserver le turban orange, les longues oreilles, la veste rouille, l’appui des bottes et la main à la taille. Dessiner la rotation de la paume, la poussée de l’avant-bras et le retour. La braise est dessinée séparément puis assemblée avec la charge.
