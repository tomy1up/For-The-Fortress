# Préparer les rencontres — prototype v0.112

3 novembre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Présentation

Le bouton « Voir les ennemis », dans la fiche de mission du parcours, ouvre une consultation facultative. Chaque rencontre dispose de son portrait, de son origine, de ses PV pour cette mission, de sa première vague d’apparition et de la perte de PV de forteresse si cet ennemi passe. Le parcours principal conserve sa carte et ses actions sans ajouter une liste permanente.

L’ordre suit les premières apparitions réelles dans les dix vagues. Un ennemi est présenté une seule fois. Les types absents de la mission restent absents de la fenêtre : par exemple, l’ours du chapitre 1 n’est pas ajouté aux rencontres du chapitre 2. La tortue y remplace certaines rencontres et sa protection est expliquée sous les fiches. Les portraits réutilisent les illustrations existantes ; aucune nouvelle direction artistique ou animation n’est intégrée.

Les missions verrouillées mais déjà produites sont consultables pour préparer sa défense. Les missions futures ne proposent pas de faux catalogue. Les PV proviennent du modèle avec le pourcentage de la mission sélectionnée ; les noms et les images proviennent de la même identité. Un joueur Alliance voit la faune neutre et les attaquants Horde, et inversement. Ces attaquants ne sont pas les défenseurs à recruter.

## Commandes et sauvegarde

La fenêtre bloque les actions et le focus du parcours situé derrière. Échap revient au bouton qui l’a ouverte ; un second Échap peut quitter le parcours. Fermer le parcours, le rouvrir ou changer de faction ne conserve aucune consultation précédente. Une mission inconnue ne réutilise pas des données périmées.

Cette vue ne débloque, ne lance et ne récompense aucune mission. Elle ne dépense aucune monnaie, ne modifie aucun talent et n’écrit pas dans le profil. Les essais utilisent des profils isolés. Les vagues, coûts, récompenses, statistiques, animations et schéma de sauvegarde restent inchangés.

## Validation

La suite dédiée parcourt les vingt missions dans les deux factions : présence exacte, première apparition, PV, portraits, origine, clavier, absence d’action derrière et absence de mutation de la progression. Le paquet Windows fait l’objet de captures ciblées et d’une comparaison des sources. Résultat final : **95 suites Godot, 43 698 contrôles et 17 tests Python réussis** ; **22 cas Windows ciblés sur 281**, **75 sources comparées** et **21 captures examinées**. Rapports : `essais/v0112_regression.json`, `Distribution_Windows_v0112.json` et `essais/v0112_fidelite_sources.json`. Ces essais automatisés ne constituent pas une campagne jouée par une personne.

Le premier export omettait le nouveau script dans la sélection de ressources : son lancement a été rejeté par le contrôle Windows et le test Python de sélection. Le script est inclus dans le paquet final. L’exporteur refuse désormais de compiler lorsqu’une ressource déclarée manque à cette sélection ; le passage complet et le paquet final ont été revérifiés après cette correction.

La consultation n’est pas un simulateur de composition et ne prédit pas la victoire du joueur. Les informations de vitesse, de résistances éventuelles et les outils de préparation supplémentaires ne sont pas annoncés comme livrés.
