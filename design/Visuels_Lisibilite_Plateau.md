# Lisibilité des unités sur le plateau

Contrôle au Gué sur une copie de la v0.202 avec les derniers sprites de la branche artistique. Les captures sont recadrées sans rééchantillonnage, à 1 280 × 800. Les 46 défenseurs (6 de base et 40 de boutique) occupent tour à tour E2. Les 19 identités d’attaquants (6 Alliance, 6 Horde, 7 neutres) sont placées sur le même tronçon. La revue isole volontairement les unités et mesure leur lisibilité à la taille du plateau. Une seconde vérification en vagues denses et dans plusieurs biomes reste à faire.

- [Comparatif défenseurs, avant / filtrage / taille](essais/lisibilite_plateau/Comparatif.png)
- [Défenseurs Alliance](essais/lisibilite_plateau/Alliance.png) et [défenseurs Horde](essais/lisibilite_plateau/Horde.png)
- [Attaquants](essais/lisibilite_plateau/Attaquants.png) et [comparatif du filtrage](essais/lisibilite_plateau/Comparatif_attaquants.png)
- [33 cadrages testés et départs des tirs](essais/lisibilite_plateau/Cadrages_essai.csv)

## Défenseurs

Le Troll de base (type 03) est la référence. Sa hauteur est de 66 px et son PNG est importé avec des mipmaps. Le Lanceur de masse (28) et le Chef de guerre vétéran (45) étaient à 57 px, sans mipmaps. L’activation des mipmaps réduit l’aliasing et permet de lire les aplats. À 66 px, l’arme et le visage gagnent en présence. Le même défaut de filtrage est visible sur l’Arbalète lourde (24) et le Vétéran royal (40) de l’Alliance.

La copie d’essai active les mipmaps pour les textures de défenseurs utilisées sur le plateau et augmente 33 hauteurs en gardant le pivot au pied et les bornes horizontales de ±44 px. Les machines larges et les profils bas gardent des proportions distinctes. Deux unités reprennent un départ de tir partagé avec l’Archer (23 et 31, cellules de départ vides dans le CSV) : ce point reste à vérifier en mouvement. Tous les autres départs redimensionnés sont dérivés du point d’origine, puis arrondis au quart de pixel. La texture de repli de pose de l’Archer reste à vérifier en mouvement avec sa planche.

## Attaquants

Les sprites fixes et les planches des attaquants ont été testés séparément. Sur Gueule-de-Vase, le Revenant, le Fantassin et l’Éclaireur gobelin animés, ce sont les mipmaps des planches qui lissent la silhouette en jeu. Le loup garde son maillage et ses réglages. Les gabarits des attaquants restent les mêmes pendant cet essai pour préserver la lecture éclaireur, infanterie, élite et boss. Le Capitaine orc réutilise le dessin du Chef de guerre et reste trop proche à l’échelle native. Cette distinction demande une silhouette et une arme propres, puis une comparaison en mouvement.

## Intégration

Le lot contient les preuves et les valeurs d’essai. Le réglage de l’import Godot et les hauteurs sont à intégrer ensemble avec Claude, car le test actuel de la boutique attend explicitement des sprites sans mipmaps. Vérifier aussi le chemin de chargement des planches PNG dans l’export, qui peut différer de l’import de l’éditeur. Les 201 contrôles ciblés d’illustrations passent sur la copie après adaptation de l’assertion de filtrage, ainsi que les 49 du lot 4 et les 156 de la bibliothèque d’animations. Le validateur couvre 24 dossiers sans erreur sur cette copie, dont l’essai du Sapeur. Le lancer du Sapeur reste une étude, avec la tenue de la charge et le mouvement à affiner après cette revue.
