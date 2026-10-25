# Finale et activité — nouvelle lecture de la matrice v0.19

25 octobre 2026 · prototype v0.38 · GDD v0.14 · Godot 4.7.2.stable.official.ed1daf0bf.

**Les 1 728 scénarios retrouvent les résultats historiques**, avec les mêmes fins de partie, ressources, unités, offres, choix et durées, à une tolérance numérique de 10⁻⁷ pour les nombres flottants. Les mesures ajoutées en v0.38 n’ont donc pas déplacé les résultats de cette matrice. Les 356 868 audits d’intégrité et de mesure passent sans anomalie ; ils sont distincts des 13 952 contrôles de régression du prototype.

## Méthode

Reprise des douze graines et du croisement complet du [bilan v0.19](Bilan_equilibrage_v019.md) : deux factions, quatre placements, trois politiques de dépenses, trois priorités de bonus et deux stratégies de branches. Aucun or ajouté, aucune statistique changée. Les politiques passent par les transactions normales du modèle.

Un observateur optionnel du banc d’essai relève désormais les contributions de chaque recrue, vague par vague, et l’issue du boss. Le lancement historique sans observateur conserve son fonctionnement. L’analyse compare tous les champs des anciens relevés, contrôle les sommes des contributions par vague et par instance, puis produit des données et tableaux séparés des fichiers historiques.

Ces scénarios ne représentent pas des joueurs. Certains partagent les mêmes décisions tant qu’aucune spécialisation n’est atteinte : les 1 728 lignes ne sont pas des observations indépendantes. Le nombre de victoires d’une politique ne mesure pas la rentabilité isolée d’une unité ou d’un bonus.

## Finale observée

| Indicateur de cette matrice | Résultat |
| --- | --- |
| Parties testées | 1 728 |
| Victoires | 1 057 |
| Parties ayant atteint la vague 10 | 1 060 |
| Boss éliminé | 1 059 |
| Boss encore présent lors de la défaite | 1 |
| Boss arrivé à la forteresse | 0 |
| Temps médian d’élimination, parmi les boss éliminés | 10 secondes simulées |
| Défaites en vague 10 malgré l’élimination du boss | 2 |

La disparition du boss n’implique donc pas toujours la victoire : les autres ennemis peuvent encore détruire la forteresse. Son temps d’élimination ne doit pas être confondu avec la durée totale de la vague ou la durée réelle à ×2 ou ×10.

Les temps médians varient selon les groupes : de 7,5 s pour les cas Alliance de la politique spécialisation qui parviennent à la finale, à 16,5 s pour Alliance en politique référence. Ces groupes sont sélectionnés par leur survie aux vagues précédentes et disposent de défenses différentes. Ce contraste ne classe pas les factions ni les branches.

## Vagues 9 et 10 sur les mêmes parties

Parmi les 1 060 scénarios atteignant la vague 10, les pertes de PV de forteresse sont plus faibles en vague 10 dans 75 cas, égales dans 980 et plus fortes dans 5. La hausse de quatre PV lorsque R-09 est choisi après la vague 9 est prise en compte séparément ; elle n’est pas confondue avec une perte négative.

Cette comparaison porte exclusivement sur les survivants jusqu’à la finale. Un troisième bonus a pu être choisi après la vague 9. Elle ne neutralise ni les achats et améliorations entre les deux vagues, ni les effets de ce bonus, ni la sélection des compositions déjà efficaces. Elle ne mesure pas la tension ressentie.

Ces résultats apportent du contexte au retour initial du joueur sur une finale parfois plus simple et à sa précision sur l’influence des améliorations. Ils n’établissent pas une cause unique et ne valident aucune augmentation des PV du boss. **Les réglages actuels sont conservés.**

## Données et suite de L6

- [Tableaux par faction et politique](essais/v038_metrics_tableaux.md).
- [Synthèse et empreintes des sources](essais/v038_metrics_synthese.json).
- [Relevés complets compressés](essais/v038_metrics_releves.json.gz).
- [Procédure de reproduction](essais/README.md).

Le nouvel onglet **Bilan → Défenseurs** et le rapport local permettent maintenant de recueillir ces informations sur des parties humaines, avec leurs bonus et décisions réels. Le prochain retour utile est le ressenti de tension sur les vagues 9 et 10, accompagné du rapport exporté. Les règles ouvertes du GDD, les hypothèses d’équilibrage et les objectifs commerciaux gardent leur statut antérieur.
