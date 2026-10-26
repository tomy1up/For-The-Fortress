# Bilan essentiel — v0.58

26 octobre 2026. Cinquième lot de présentation après la [lecture du recrutement](Lecture_recrutement_v057.md), dans les [orientations validées](Orientation_presentation_2026-10-26.md).

## Une première lecture courte

À la première ouverture du bilan, l’onglet **Essentiel** présente le résultat et la faction, la vague de défaite ou les dix vagues terminées, le solde restant et le temps de combat simulé. Trois cartes mettent en avant les PV actuels et maximum de la forteresse, le nombre total d’ennemis passés et l’or gagné au combat. Les ennemis encore en chemin ne sont pas comptés comme passés.

La section des pertes indique le total de PV perdus au combat, la première vague ayant coûté des PV et la plus forte perte par vague. En cas d’égalité, toutes les vagues concernées sont citées. L’absence de relevé est distincte d’un relevé sans perte. Ces chiffres sont additionnés à partir de l’historique ; ils ne sont pas calculés en soustrayant les PV restants au maximum, afin de respecter les effets de Maçonnerie renforcée.

Le boss reçoit un statut court issu du relevé existant : vague non atteinte, pas encore apparu, éliminé, arrivé à la forteresse, encore en chemin ou issue indéterminée. Le bilan ne déduit pas qu’un boss a été affronté si sa vague n’a pas été atteinte. Il n’attribue aucune défaite à une cause stratégique supposée.

## Détails conservés

L’onglet **Vagues** conserve les dix lignes, les PV perdus, récompenses, temps et résultats. Le survol d’une ligne rappelle la défense et les bonus au départ. La ligne 10 conserve les détails mesurés de la rencontre du boss. L’onglet **Défenseurs** conserve les contributions réelles, y compris les unités vendues, et les limites d’interprétation des statistiques.

Les trois onglets sont dans l’en-tête ; une seule vue est visible à la fois. Le dernier onglet consulté reste sélectionné si le joueur ferme puis rouvre le même bilan. Un nouvel essai rétablit Essentiel pour le prochain bilan. Fermer, Échap et l’export local conservent leur fonctionnement. Aucun nouveau format de rapport ou de sauvegarde n’est ajouté.

## Vérification

**34 suites, 14 855 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **36 contrôles nouveaux** couvrent les deux factions, les défaites réellement simulées sans défense, les victoires des campagnes de référence, les chiffres clés, les pertes ex æquo, les relevés absents, le cas sans perte, les changements d’onglets et la lecture sans mutation du rapport ou du générateur aléatoire. Le contrôle d’agrégation distingue l’augmentation du maximum de PV des pertes historiques.

Les tests existants de contributions ont été adaptés à l’ouverture sur Essentiel. Leurs contrôles numériques sont conservés. La vérification Windows ajoute trois captures du tableau des vagues, puisque les captures générales du bilan montrent désormais Essentiel. Les détails de distribution et du contrôle natif figurent dans Distribution_Windows_v058.json.

## Périmètre

Cette version réorganise la présentation de données déjà enregistrées. Aucun changement des combats, récompenses, coûts, bonus, synergies, vagues ou pauses. Aucune progression permanente. Le bilan propose des faits utiles à la relecture ; leur compréhension reste à évaluer avec le joueur.

GDD principal v0.14. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Contrôle final du paquet

**74 lancements, 73 captures et dix empreintes locales concordantes.** Les vues essentielles de victoire Horde et de défaite Alliance ont été inspectées. La [victoire de référence](essais/captures/QA-v058_victoire.png) est une campagne automatisée avec budget normal, pas un nouveau retour humain.

Un contrôle natif séparé du même exécutable a été opéré sur l’écran de droite : Alliance sans défenseurs, avec les 150 or initiaux et le ×10 temporaire. La vague 2 a été lancée manuellement après la première. La défaite réelle à la vague 2 affiche 0/20 PV, 20 ennemis passés, 0 or gagné au combat et 150 or restants. Les deux vagues ont chacune coûté 10 PV, et le boss est indiqué non rencontré. Les trois onglets ont été consultés, puis le bilan fermé par Échap. Le journal ne contient aucune erreur et le jeu a été fermé. Ce contrôle opéré par l’agent vérifie l’interface ; il ne valide pas l’équilibrage.

[Essentiel natif](essais/captures/QA-v058_essentiel_natif.jpg) · [Vagues natives](essais/captures/QA-v058_vagues_natives.jpg).
