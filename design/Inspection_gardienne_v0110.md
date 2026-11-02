# Inspection de la protection — prototype v0.110

## Comportement

Pendant le combat, survoler une Gardienne montre des liens vers les voisins éligibles à sa protection et indique leur nombre. Survoler un voisin affiche « À portée d’une Gardienne » et son lien vers la Gardienne choisie. Les liens sont retirés dès que la cible sort du rayon, meurt ou que le combat se termine. Ils restent limités à l’ennemi inspecté afin de garder le plateau lisible.

La Gardienne conserve aussi l’indication « Malédiction active » lorsqu’elle est maudite. L’ancienne description de son rôle masquait ce statut. Un voisin peut indiquer simultanément protection à proximité et malédiction.

## Règle conservée

L’inspection et la répartition des dégâts utilisent désormais la même fonction de choix : Gardienne vivante la plus proche dans un rayon logique de deux, limite comprise ; égalité départagée par identifiant d’apparition. Boss et autres tortues ne sont pas protégés. Pendant un coup, une Gardienne déjà tuée par ses dégâts directs est exclue. L’inspection observe la situation actuelle, sans prédire ce futur coup.

Les liens de survol désignent les bénéficiaires possibles. Ils ne garantissent pas le transfert intégral de 25 % si les PV de la Gardienne deviennent insuffisants ; les traits brefs de transfert continuent de représenter les dégâts réellement absorbés. Aucun PV, prix, gain, talent ou règle de combat n’est modifié. Le profil persistant n’est pas migré. Le sanglier expérimental reste hors production et le cycle du loup est conservé.

## Vérification

La suite dédiée examine la borne du rayon, les égalités, l’exclusion des morts, la sortie de portée, les deux factions, les malédictions et l’absence de mutation du combat pendant l’observation. Les contrôles Windows présentent une Gardienne, un voisin et une Gardienne maudite dans chaque faction. Résultat : 93 suites Godot, 39 572 contrôles et 17 tests Python réussis. Le paquet Windows passe 16 cas ciblés sur 267, avec comparaison de 74 sources et examen des 15 captures produites. Voir `essais/v0110_regression.json`, `Distribution_Windows_v0110.json` et `essais/v0110_fidelite_sources.json`.

Ces scènes contrôlées ne sont pas des parties humaines complètes. La lisibilité en situation de foule reste à éprouver avec le porteur.

For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.
