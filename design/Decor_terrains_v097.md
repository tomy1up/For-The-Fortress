# Décor des nouveaux terrains — v0.97

30 octobre 2026. **For the Fortress!** reste un nom de travail ; disponibilité juridique à confirmer.

## Intention et statut

Ce lot poursuit l’orientation de présentation validée : une fantasy cartoon simple et des écrans lisibles. Les missions 4–10 livrées en v0.96 avaient un terrain nu. Une végétation légère, quelques rochers et des sapins complètent désormais leur plateau, dans le thème du Gué.

Les formes, couleurs et placements constituent une proposition artistique de prototype. Aucun nouvel obstacle, effet de terrain, bonus ou malus n’est ajouté.

## Lisibilité du plateau

Les décors laissent libres le chemin et une marge autour de celui-ci. Les six emplacements réservent aussi une zone pour la silhouette des défenseurs et leurs indications. La forteresse et l’annonce d’entrée ont leur propre marge. Le décor tient à l’intérieur du plateau et évite de superposer ses éléments.

Les buissons et les pierres restent bas. Les sapins utilisent le dessin simple à deux tons déjà présent dans le prototype. Le nombre d’éléments est limité : l’objectif est de donner un peu de relief à la carte tout en conservant les positions tactiques au premier plan. Les aperçus de campagne restent schématiques pour montrer directement le tracé et les six emplacements.

## Déterminisme et périmètre conservé

La répartition est calculée lors du changement de terrain puis conservée pendant la mission. Elle reste identique entre les deux factions et entre deux tentatives sur le même terrain. Elle ne fait appel à aucun tirage du générateur de combat.

Les données des dix cartes, emplacements, distances, vagues, PV ennemis et récompenses ne changent pas. Les trois premières cartes gardent leur présentation existante. Les sauvegardes et les règles de progression restent au schéma 6. La seule modification du jeu concerne l’affichage ; le relevé de contrôle des captures indique aussi le nombre d’éléments décoratifs.

## Validation attendue

- Vérifier les silhouettes décoratives par rapport au chemin, au plateau, aux six défenseurs possibles et à la forteresse.
- Vérifier leur stabilité, leur remplacement lors d’un changement de mission et leur absence d’effet sur les données et tirages de combat.
- Inspecter les sept nouveaux terrains dans les deux factions depuis le paquet Windows.
- Comparer les rapports de combat avec v0.96 et conserver les tests de progression persistante.

La difficulté des missions reste celle du prototype v0.96, à éprouver lors d’essais humains.

## Résultats de validation

76 suites et **31 875 contrôles Godot**, ainsi que 16 tests Python réussis. Les 5 169 contrôles du décor vérifient les marges autour des chemins, six silhouettes de défenseurs, emplacements et forteresse, le maintien dans le plateau, la variété, le déterminisme et le changement de cache lors du lancement réel d’une mission.

Le paquet Windows passe **233 lancements et 232 captures**, avec 45 sources comparées. Les sept terrains ont été examinés en préparation dans les deux factions, ainsi que les bilans après la mission 10. Les contrôles natifs vérifient aussi la présence du décor sur les nouvelles cartes et son absence sur les trois premières.

Les sources des cartes, du modèle de combat, des talents et du profil sont inchangées. Quarante scénarios sur les dix terrains donnent les mêmes rapports, états aléatoires, événements et dégâts qu’en v0.96. Les 18 rapports natifs des missions 2–10 restent identiques après normalisation du seul numéro de version, et se rejouent tous avec la version actuelle.

[Régression](essais/v097_regression.json), [comparaison des combats](essais/v097_comparaison_combat.json), [comparaison et rejeux natifs](essais/v097_rejeux_natifs.json), [distribution](Distribution_Windows_v097.json). Exemples : [Détours Horde](essais/captures/QA-v097_horde_sample_4_preparation.png), [Remparts Alliance](essais/captures/QA-v097_alliance_sample_10_preparation.png). Le choix artistique reste à confirmer en essai humain ; aucun nouvel équilibrage n’est déduit de ce lot.
