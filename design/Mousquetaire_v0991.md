# Mousquetaire — correction visuelle v0.99.1

Le 31 octobre 2026, le porteur du projet retient la **version sombre** du mousquetaire, plus cohérente avec la teinte des autres unités. Ce choix remplace la version claire intégrée en v0.99.

`prototype/assets/units/shop/mousquetaire_v002.png` est une copie exacte de la première illustration générée, sans nouvelle génération ni retouche des couleurs. La version claire `mousquetaire_v001.png` est conservée dans l’historique ; le jeu référence uniquement la v002 pour le mousquetaire. Le catalogue contient toujours une seule unité « Mousquetaire nain », identifiant `alliance.musketeer`, type 7.

La silhouette, la transparence et le cadre mesuré sont identiques : l’ancrage des pieds, la taille affichée et le départ des projectiles restent compatibles. Aucune statistique, règle de combat, sauvegarde ou dépense de PO n’est modifiée.

For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Vérification

L’empreinte de la v002 correspond exactement à l’illustration sombre choisie : `ef4c91bf02d002aa5d55361d3ca4cded41e8d2ef504e2901fb0e537e23906b30`. Les références embarquées pointent uniquement sur la v002.

Deux suites ciblées passent **84 contrôles Godot**, plus **16 tests Python**. La vérification Windows couvre quatre cas sélectionnés sur les 243 disponibles : démarrage, accueil et parcours terminés des deux factions ; trois captures sont produites par ces cas, avec 56 sources comparées. Trois vues du mousquetaire depuis les ressources compilées sont examinées sur l’écran de droite. Il ne s’agit pas d’une nouvelle exécution des 82 suites ni des 243 cas.

51 sources embarquées gardent exactement leur empreinte de v0.99, dont le modèle de combat, les statistiques, les talents et le profil. Les différences portent sur la version, les références graphiques et le PNG/import du mousquetaire. Le vérificateur permet désormais de sélectionner des cas nommés et refuse les noms inconnus.

[Régression ciblée](essais/v0991_regression.json), [distribution](Distribution_Windows_v0991.json), [boutique](essais/captures/QA-v0991_shop_0.png), [combat](essais/captures/QA-v0991_unit_7.png).
