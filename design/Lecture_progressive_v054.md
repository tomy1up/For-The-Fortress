# Choisir sans tout lire — v0.54

26 octobre 2026. Premier lot de présentation demandé après les [orientations validées](Orientation_presentation_2026-10-26.md).

## Bonus : décision puis détails

La vue initiale présente trois cartes. Chacune montre son nom, l’effet principal en grand, les unités ou cibles concernées, puis les conditions utiles et le nombre de défenseurs actuels concernés. Les codes de diagnostic R-xx restent dans les données et rapports ; les cartes utilisent le nom du bonus. Les phrases sont adaptées à la faction.

Voir les détails remplace les cartes par la règle complète et une comparaison chiffrée plus large, avec une police de 15 px pour les valeurs, au lieu de trois petites listes simultanées. Le bouton Retour ou Échap revient aux cartes. Ouvrir les détails ne valide rien. Le bonus peut être choisi depuis sa carte ou depuis ses propres détails. Les autres offres sont masquées dans cette vue et leur validation forcée est refusée.

Le récapitulatif des bonus acquis reprend les cartes condensées. Ses détails rappellent les bénéficiaires et la règle, sans simuler un deuxième gain d’un bonus déjà acquis. Il ne propose aucune nouvelle attribution.

Les bénéficiaires sont comptés à partir de la défense réelle, selon faction, type et niveau. Les bonus de forteresse ou de coût indiquent leur portée immédiate ou future, sans faux décompte de défenseurs. Les valeurs complètes proviennent toujours des mêmes aperçus du modèle et des descriptions de faction. Aucun calcul de dégâts, prix ou récompense n’a été modifié.

## Spécialisations : rôle puis chiffres

Les deux branches sont présentées dans des cartes : nom, rôle en une courte phrase et bouton de confirmation indiquant le prix réel. Le texte évite de suggérer qu’une statistique reste identique au niveau actuel lorsque la phrase historique décrivait surtout la spécialité de la branche.

Voir les chiffres affiche les deux comparaisons existantes : dégâts, intervalle, portée, effets secondaires et investissement. Masquer les chiffres revient à la vue des rôles. Le survol et le focus des choix conservent l’aperçu de portée et des partenaires sur la carte. Annuler garde le niveau 3 et son or ; confirmer applique une seule branche et un seul paiement.

## Navigation et durée

Les vues détaillées appartiennent aux panneaux existants. Elles n’ajoutent aucune règle de pause : choix roguelite obligatoire sans limite de temps ; préparation suspendue pendant le récapitulatif ou la spécialisation ; combat poursuivi pendant une simple consultation des bonus acquis. Le décompte entier de 30 secondes démarre après le choix obligatoire.

Échap dans le détail d’un bonus revient à la liste, y compris pendant un choix obligatoire. Échap sur cette liste ne supprime pas le choix obligatoire. Le retour rend le focus au bouton de détails consulté. Une nouvelle offre ou un nouvel essai efface la vue détaillée précédente. Les commandes de jeu restent bloquées derrière les panneaux.

## Vérification

**30 suites, 14 558 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **208 contrôles nouveaux** couvrent les 12 bonus dans les deux factions, la taille des textes, les bénéficiaires de six recrues de niveaux différents, les règles et valeurs exactes, la lecture sans mutation, le retour par Échap, la validation unique depuis les détails et les transitions entre offres. Ils couvrent aussi les six défenseurs, les deux comparaisons de spécialisation, la consultation sans débit, l’annulation, la réouverture et la confirmation unique.

Les tests existants de défilement et de navigation ont été adaptés à la consultation volontaire et aux nouveaux boutons. Les calculs et invariants qu’ils contrôlaient sont conservés. Le cache des comparaisons reste actif. La validation Windows ajoute des captures de cartes complémentaires, des détails de bonus et des chiffres de spécialisation.

Le compte rendu de distribution et les contrôles visuels sont consignés dans Distribution_Windows_v054.json.

## Périmètre

Cette livraison traite la lecture et la hiérarchie des deux écrans de choix. Les personnages et animations cartoon pourront être travaillés dans une passe visuelle ultérieure. Aucune progression permanente introduite. Le niveau d’exigence reste à évaluer avec des joueurs ; les statistiques et vagues conservent leurs valeurs. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

## Contrôle visuel final

Le paquet Windows a réussi 54 lancements, produit 53 captures et confirmé les dix empreintes des sources locales. Les captures de cartes Alliance, de spécialisations chiffrées et des vues complémentaires ont été inspectées.

Un contrôle natif séparé des mêmes sources a été effectué sur l’écran de droite : ouverture des détails d’un bonus Horde, retour par Échap sans choix, affichage puis masquage des chiffres de spécialisation d’un Archer Alliance, annulation avec niveau 3 et 800 or conservés. Le scénario de spécialisation utilisait un budget de contrôle de 1000 or ; il ne constitue pas un essai d’équilibrage. Les journaux dédiés ne contiennent aucune erreur et les fenêtres ont été fermées.

[Cartes condensées](essais/captures/QA-v054_bonus_compacts.jpg) · [Détails](essais/captures/QA-v054_bonus_details.jpg) · [Rôles des spécialisations](essais/captures/QA-v054_specialisation_roles.jpg) · [Chiffres sur demande](essais/captures/QA-v054_specialisation_chiffres.jpg).
