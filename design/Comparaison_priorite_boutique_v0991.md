# Boutique : investissement prioritaire dans le quatrième défenseur

**3 744 simulations complémentaires vérifiées**, sur le jeu v0.99.1 : 1 872 paires et 245 933 contrôles sans anomalie. Elles complètent la [comparaison initiale](Comparaison_boutique_v0991.md), dont le renfort ne spécialisait jamais le quatrième défenseur. Les statistiques et les règles du jeu ne changent pas.

## Politique testée

Même grille de missions finançables, placements, graines, talents accessibles, branches et ordre de recrutement que le renfort initial. À partir de la vague 5, conserver l’or pour acheter le quatrième défenseur s’il manque, puis pour lui donner un niveau par préparation jusqu’à sa spécialisation. Si l’or manque, ne pas améliorer les trois autres à sa place. Une fois son niveau maximal atteint, reprendre l’ordre d’amélioration habituel. L’amélioration initiale du premier défenseur avant la vague 2 reste conservée.

Le témoin suit exactement la même politique avec un second exemplaire de la famille de base à la quatrième position. Cette comparaison sépare l’identité de l’unité de l’effet de la priorité d’investissement. Elle reste une politique fixe, sans adaptation au contenu de la prochaine vague.

## Victoires dans les politiques fixes

| Alternative | Cas | Témoin initial | Alternative initiale | Témoin prioritaire | Alternative prioritaire | Alternative spécialisée |
|---|---:|---:|---:|---:|---:|---:|
| Rôdeur elfe | 504 | 492 | 486 | 490 | 465 | 466 |
| Mousquetaire nain | 432 | 426 | 420 | 418 | 406 | 408 |
| Traqueur troll | 504 | 226 | 228 | 208 | 220 | 220 |
| Grenadier gobelin | 432 | 194 | 181 | 174 | 133 | 144 |

Les quatre colonnes de victoires comptent des cas simulés, pas des joueurs. Comparer témoin et alternative d’une même politique ; comparer ensuite les politiques pour mesurer l’effet de la priorité. Aucun gain supplémentaire ni taux de victoire humain n’est déduit de ce tableau.

L’épargne prioritaire **ne donne pas automatiquement une meilleure défense**. Avec le mousquetaire, 14 anciennes victoires deviennent des défaites et aucune défaite ne devient victoire. Avec le grenadier, 48 victoires deviennent des défaites et aucune défaite ne devient victoire. Le coût d’opportunité sur les trois autres défenseurs mérite donc autant d’attention que la puissance de la spécialisation.

Le traqueur prioritaire gagne davantage de cas que son témoin prioritaire, mais moins que dans sa propre politique de renfort initiale. Le rôdeur ne bénéficie pas globalement de cette priorité dans les situations couvertes. Cela n’exclut pas une priorité ponctuelle utile ni une autre politique plus performante.

## Branches réellement couvertes

| Alternative | Branche A effectivement atteinte | Branche B effectivement atteinte |
|---|---:|---:|
| Rôdeur elfe | 233 | 233 |
| Mousquetaire nain | 204 | 204 |
| Traqueur troll | 110 | 110 |
| Grenadier gobelin | 72 | 72 |

La présence du niveau 4 et de la branche choisie est vérifiée dans les unités réellement recrutées, même si la partie se termine ensuite par une défaite. Les deux spécialisations de chaque alternative sont donc atteintes dans cette étude. Il reste des parties terminées avant l’achat ou avant la spécialisation : les résumés détaillent ces cas.

## Portée de la conclusion

Le surcoût et la portée du grenadier restent des pistes à isoler ; un renforcement global de ses dégâts n’est pas déduit de ce relevé. De même, le bon comportement du traqueur en ouverture ne justifie pas à lui seul une réduction générale de ses caractéristiques. Il faut conserver des forces et faiblesses lisibles et comparer toute nouvelle hypothèse au même témoin avant adoption.

Les seuils de financement utilisent les premières victoires précédentes et les points d’XP réellement accessibles. Aucune sauvegarde joueur n’est ouverte. Les 56 sources du paquet v0.99.1 gardent leur empreinte pendant l’étude. Le contrôle de méthode passe 151 vérifications Godot et 16 tests Python ; les anciens scénarios témoins restent identiques et les rapports de priorité se rejouent à petits et grands pas. La suite complète du jeu n’a pas été réexécutée pour ces outils de simulation.

Sources : [politique](../prototype/tests/survey_shop_priority.gd), [méthode partagée](../prototype/tests/survey_shop.gd), [contrôle](../prototype/tests/test_shop_priority.gd), [analyse](../prototype/tests/analyse_shop_priority.py). [Données](essais/boutique_priorite_v0991_releves.json.gz), [résumé et empreintes](essais/boutique_priorite_v0991_resume.json), [contrôle de méthode](essais/boutique_priorite_v0991_controle_methode.json).

```powershell
godot --headless --path prototype --script res://tests/survey_shop_priority.gd -- --output=C:/chemin/priorite.json
python prototype/tests/run_regression.py --test test_shop_priority.gd --test test_shop_survey.gd --timeout 90 --report C:/chemin/controle.json
python prototype/tests/analyse_shop_priority.py C:/chemin/priorite.json --baseline design/essais/boutique_v0991_releves.json.gz --regression C:/chemin/controle.json --destination C:/chemin/resultats
```
