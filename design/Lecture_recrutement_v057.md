# Lecture du recrutement et des améliorations — v0.57

26 octobre 2026. Quatrième lot de présentation, après les [projectiles et impacts](Presentation_attaques_v056.md), dans les [orientations validées](Orientation_presentation_2026-10-26.md).

## Vue simplifiée

La fiche du bas conserve les commandes d’achat, d’amélioration et de vente à leur emplacement. Le rôle et les valeurs utiles apparaissent sur deux lignes, avec une police de 16 px. Pour une recrue, la première ligne présente le rôle et le prix réel ; la seconde les dégâts directs et les éventuels dégâts d’explosion, de rebond ou de malédiction. Les explosions précisent qu’elles touchent des ennemis supplémentaires et leur plafond. Les malédictions indiquent les moments +1 s et +2 s.

Pour une unité déjà recrutée, le rôle précède les dégâts. Au niveau spécialisé, la phrase décrit la branche choisie plutôt que le rôle générique de la classe. Le badge, le niveau et le nom de spécialisation restent visibles. Au survol d’une amélioration simple, la fiche compare les dégâts principaux et secondaires et indique le prix ainsi que l’or restant si le paiement est possible.

Les boutons de recrutement et d’amélioration disponibles ne font plus apparaître une bulle redondante en vue simplifiée : la fiche et ses gains restent lisibles pendant le survol. Les motifs de blocage restent consultables. Le choix de spécialisation rappelle qu’aucun paiement n’a lieu avant confirmation. Les longues règles de ciblage et de partenaires restent dans la vue complète.

## Chiffres et règles complètes

Le bouton **Voir les chiffres**, en haut à droite de la fiche, bascule le mode de lecture. **Vue simplifiée** revient au résumé. Le choix s’applique aux fiches et aux aides de recrutement jusqu’au prochain changement ou au nouvel essai. Ce bouton ne sélectionne pas de recrue et ne confirme aucun achat.

Pour examiner une recrue, le joueur choisit le mode puis survole son bouton, ou le rejoint au clavier. La sortie du survol continue de supprimer l’aperçu comme auparavant ; aucune recrue ne reste implicitement sélectionnée. La vue complète conserve la cadence, la portée, les règles secondaires, la priorité de ciblage, les renouvellements de malédiction et les partenaires prévus. Les valeurs viennent des mêmes aperçus du modèle, avec bonus et synergies inclus.

Pour une unité achetée, la vue complète retrouve les statistiques et l’investissement. Pour une amélioration, elle retrouve la comparaison exacte des dégâts, intervalle et portée, ainsi que les effets secondaires prévus. En vue complète, l’aide d’amélioration conserve le solde et l’investissement. L’aide de vente conserve ses remboursements historiques dans les deux vues. Les spécialisations gardent leur panneau et leur commande de chiffres propres, livrés en v0.54.

## Navigation et simulation

La portée réelle ou prévue et les liens de partenaires restent visibles sur la carte dans les deux modes. La commande est verrouillée derrière les choix de faction, bonus, spécialisations et bilans ; un signal forcé ne change pas son état. Elle ne crée aucune règle de pause. Le combat et les préparations gardent leur déroulement habituel. Un nouvel essai repart en vue simplifiée.

Le titre de fiche dispose d’une largeur réservée pour le bouton afin d’éviter les superpositions. Les données de jeu ne changent pas quand le joueur alterne les vues.

## Vérification

**33 suites, 14 819 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **138 contrôles nouveaux** couvrent les six types de défenseurs avec des bonus actifs : résumé, règles complètes, prix et gains, bascule sans achat, aperçu de portée inchangé, lecture sur deux lignes, amélioration réelle conforme à l’aperçu, verrouillage modal et remise à zéro au nouvel essai.

Les tests existants de recrutement, de comptabilité et de synergies continuent de vérifier leurs valeurs exactes en vue complète. Le test des commandes modales inclut le nouveau bouton. Les captures Windows ajoutent les vues chiffrées des deux factions et une amélioration Horde simplifiée.

Les résultats Windows et le contrôle natif sont consignés dans Distribution_Windows_v057.json.

## Périmètre

Cette version traite la lecture des fiches et des aides existantes. Aucun prix, dégât, cadence, portée, ciblage, bonus, synergie, vague ou délai n’est modifié. Aucune progression permanente. La compréhension des deux modes reste à confronter au joueur ; la prochaine passe pourra travailler le résumé de fin de partie.

GDD principal v0.14. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Contrôle final du paquet

**71 lancements, 70 captures et dix empreintes locales concordantes.** Les vues de recrutement chiffré Alliance et d’amélioration simplifiée Horde ont été inspectées dans le paquet final.

Un contrôle natif séparé du même exécutable a été effectué sur l’écran de droite, avec le budget normal de 150 or : Horde, E4, comparaison du chaman en [vue simple](essais/captures/QA-v057_recrutement_simple.jpg) puis [vue chiffrée](essais/captures/QA-v057_recrutement_chiffres.jpg), sans achat lors des bascules. Le recrutement coûte ensuite 100 or. En vue simple, le [survol prolongé de l’amélioration](essais/captures/QA-v057_amelioration_simple.jpg) laisse les gains visibles sans bulle superposée : dégâts 12 → 18 et malédiction 4,8 → 7,2, pour 50 or. Après confirmation, le [niveau 2 réel](essais/captures/QA-v057_achat_confirme.jpg) affiche ces valeurs et un solde de 0 or. Le journal ne contient aucune erreur et le jeu a été fermé.

Ce contrôle de préparation est opéré par l’agent ; aucune vague n’y est lancée. Il ne constitue ni un nouveau retour joueur ni une validation générale d’équilibrage.
