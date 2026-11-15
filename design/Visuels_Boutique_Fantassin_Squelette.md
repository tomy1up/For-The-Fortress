# Boutique · Fantassin squelette

Visuel fixe du type 46 (`horde.skeleton`), validé par le porteur le 15 novembre 2026. Le générateur a repris les aplats d’os ivoire et les contours du servant de la Baliste de guerre pour un nouveau fantassin. Crâne dégagé, foulard rouge, épaulière unique et épée courte distinguent le défenseur. Les jambes fléchies et la main libre donnent une pose de garde à faible portée.

[Capture à taille native au Gué](essais/boutique_guetteurs/Fantassin_squelette_plateau.png)

Cadre `Rect2(0,0,1290,1116)`, pied `Vector2(470,1116)`, hauteur 59 px. PNG `fantassin_squelette_v001.png` dans la boutique, import avec mipmaps. Point d’essai à la lame `Vector2(38,-35)`. Les 206 contrôles d’illustrations passent sur une copie v0.208. Portrait sur la dernière page, achat après 190 missions sur profil d’essai, sélection, recrutement en E1 et première attaque vérifiés.

Le rendu de combat de la v0.208 hérite encore de la hache lancée et du libellé de rebond. Prévoir un coup d’épée court, puis l’animation du bras et de l’épaule. La portée du modèle reste celle de l’unité de mêlée.

**Archive.** Le 15 novembre 2026, le porteur a demandé le retrait de cette unité et fixé la boutique à 20 unités par faction. Cette fiche conserve les essais artistiques.

## Frappe à l’épée

Le type 46 utilise un coup de mêlée dessiné par le jeu depuis la v0.209. L’essai y ajoute une planche d’attaque tirée du même sprite. Les bottes gardent leurs appuis. L’épaule arme le geste, le buste accompagne la coupe et la lame reste dans la main. La première et la dernière image de la planche sont identiques pixel pour pixel. L’attaque dure 0,50 s et compte 24 poses.

[Premières attaques à ×1](essais/gestes_combat/fantassin_squelette/Fantassin_frappe_x1.gif) · [Premières attaques à ×2](essais/gestes_combat/fantassin_squelette/Fantassin_frappe_x2.gif) · [Vue agrandie](essais/gestes_combat/fantassin_squelette/Fantassin_frappe_agrandie.gif)

Captures en mission 1 sur copie v0.208, après achat et équipement du Fantassin sur un profil d’essai. Capture du premier coup à gauche depuis E1 et à droite depuis E2, à ×1 et ×2. Le temps et les pixels restent identiques lors du contrôle à temps figé. Les 24 cadres contiennent la silhouette et la lame. Validateur : 26 dossiers, 0 problème. Bibliothèque d’animations : 158 contrôles réussis.

L’essai cale la traînée sur la pointe de la lame pendant la coupe, de 0,188 à 0,292 s après le déclenchement. Repères à droite, en pixels de jeu depuis l’appui : (37,9 ; −58,9) à 0,188 s, (50,1 ; −38,8) à 0,208 s, (49,8 ; −26,4) à 0,229 s, (43 ; −9,7) à 0,250 s, (40,6 ; −6,6) à 0,271 s. Symétrie horizontale à gauche. Le marqueur visuel d’impact démarre à 0,23 s dans cet essai. Le jeu continue de résoudre les dégâts au déclenchement de l’attaque.

La planche et sa description sont [dans le dossier de revue](essais/gestes_combat/fantassin_squelette/defender.horde.skeleton/). Le visuel attend le retour du porteur. Claude prend en charge le branchement de l’effet lors de l’intégration.
