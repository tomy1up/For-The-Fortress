# Reset gratuit des talents — v0.84

29 octobre 2026. Réalisation de la décision explicite du porteur du projet, qui remplace le coût croissant puis plafonné. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Comportement livré

Depuis l’accueil, le joueur peut réinitialiser gratuitement les trois arbres de la faction choisie, même avec zéro PO. La confirmation présente les points rendus, conserve les points achetés et précise qu’aucune PO n’est débitée. L’autre faction et les reçus de première victoire restent intacts. Un arbre déjà vide ne déclenche pas de transaction inutile.

Le profil garde ses ressources, points et anciens compteurs. Ceux-ci n’influencent plus le prix ; le compteur historique sature à sa borne technique sans empêcher les resets suivants. Le format de sauvegarde reste le schéma 3 et la protection Windows existante. Annuler, confirmer deux fois ou rencontrer une erreur d’écriture ne retire aucune PO ; les vérifications de confirmation périmée restent en place.

Les arbres restent inaccessibles pendant une tentative. Dans le Gué actuel, le joueur revient à l’accueil après le résultat, prépare ses talents puis lance la partie suivante. Le reset ne modifie pas le cliché de talents utilisé dans une tentative ou son bilan.

## Conception économique actualisée

Chaque mission donne des PO à sa première victoire, également après la mission 100. Le financement du maximum de points par les 100 premières missions suppose de consacrer leurs gains aux points ; acheter en boutique peut retarder ce maximum. La boutique ouvre des stratégies avec des unités ayant forces et faiblesses. [Cadre économique](Economie_campagne_2026-10-29.md).

Le reset gratuit retire la nécessité de prévoir du farm pour expérimenter les arbres. Il ne valide aucun revenu répétable ni prix de boutique. La [proposition de talents enrichis](Proposition_talents_enrichis_2026-10-29.md) dispose d’un module de calcul séparé : 18 talents par arbre, six lignes, plafond provisoire partagé. Elle n’est pas encore raccordée à l’interface, au profil ni au combat du jeu. Les effets historiques sont comparés exactement, mais les nouveaux effets nécessitent encore leurs essais de combat et de lisibilité.

## Validation

62 suites et 19 324 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 164 contrôles dédiés à la gratuité vérifient zéro PO, plusieurs resets, un compteur historique saturé, restitution et réinvestissement des points, intégrité des reçus et de l’autre faction, absence de transaction sur un arbre vide, profil bloqué, verrou pendant la mission et configuration de combat inchangée après un reset de préparation. Les contrôles historiques de confirmation, d’écriture, de relancement dans un autre processus et de sauvegarde sont également adaptés et réussis.

Les 489 contrôles du catalogue enrichi vérifient ses identifiants, paliers, exclusions et plafond, ainsi que la conservation exacte des effets des quinze talents historiques. Ce catalogue reste hors jeu et ne constitue pas un essai d’équilibrage du contenu futur.

Les 16 scénarios de combat comparés à v0.83 gardent exactement les rapports, états aléatoires, événements, dégâts et éliminations pour les mêmes configurations : deux factions, zéro ou 33 points, deux graines et deux pas de simulation. [Comparaison](essais/v084_comparaison_combat.json).

Le paquet Windows passe 138 lancements et produit 137 captures, avec 39 sources comparées au projet. [Régression](essais/v084_regression.json) et [distribution](Distribution_Windows_v084.json). Le profil réel n’est pas chargé pendant les tests et les lancements graphiques utilisent l’écran de droite. Aucun nouvel essai humain d’équilibrage.

Captures : [Alliance](essais/captures/QA-v084_alliance_talents_reset.png), [Horde](essais/captures/QA-v084_horde_talents_reset.png), [ancien compteur Alliance](essais/captures/QA-v084_alliance_reset_cap.png), [ancien compteur Horde](essais/captures/QA-v084_horde_reset_cap.png), [Alliance sans PO](essais/captures/QA-v084_alliance_zero_reset.png) et [Horde sans PO](essais/captures/QA-v084_horde_zero_reset.png).
