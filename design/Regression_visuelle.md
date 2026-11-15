# Régression visuelle et parties aléatoires

**Statut : outils de contrôle ajoutés le 15 novembre 2026 par Claude Code (aucune règle de jeu modifiée).** Ils complètent la régression technique (`run_regression.py`), qui ne voit ni l'image ni les enchaînements imprévus.

## Parties aléatoires (`prototype/tests/test_fuzz_games.gd`)

Fait partie de `run_regression.py`. 120 parties complètes reproductibles (graine fixe) : mission, faction et alternative de boutique tirées au hasard, puis achats, améliorations, reventes, pas de temps (0,05 s, 0,5 s ou 300 s) et bonus aléatoires. Contrôles : or jamais négatif, PV de forteresse dans la limite, aucun ennemi vivant sans PV, conservation de l'or (or = départ + revenus − dépenses + reventes), chaque vague se termine, le rapport final se rejoue exactement. ~5 000 contrôles, une dizaine de secondes.

## Régression visuelle (`prototype/tests/visual_regression.py`)

Hors `run_regression.py` : elle ouvre le jeu sur l'écran de droite (`--screen 1`, pas de fenêtre minimisée). 218 captures en tout, environ vingt-cinq minutes.

```
python prototype/tests/visual_regression.py                      # compare tout aux références
python prototype/tests/visual_regression.py --group menus        # un groupe : units, menus, missions, effects, affixes, armies
python prototype/tests/visual_regression.py --types 40-47        # une plage de types (groupe units)
python prototype/tests/visual_regression.py --only unit46_pose   # une capture, ou un préfixe (mission_horde_marsh51)
python prototype/tests/visual_regression.py --update             # crée ou remplace les références
```

| Groupe | Contenu | Captures |
| --- | --- | --- |
| `units` | Les 48 défenseurs (types 0 à 47) à la pose d'attaque (`unitNN_pose`) et en plein vol du projectile (`unitNN_shot`), seuls sur le Gué | 96 |
| `menus` | Menu de campagne (neuf, terminé, talents, chapitre 20, sauvegarde bloquée) et boutique, pour chaque faction | 12 |
| `missions` | Une mission par chapitre (3, 6, 7, 8, 9, 10, 11, 13, 15, 17, 20), deux défenseurs posés, vagues 1, 5 et 10, pour chaque faction | 66 |
| `affixes` | Éruptions (mission 71, instants 3 à 17 s), tempête de sable (115), éboulement (135) et brume marine (175), à des instants de combat choisis, pour chaque faction | 28 |
| `armies` | Armée complète (six défenseurs de niveaux 1 à 3, option `--capture-full-army`) face aux vagues 5 et 10 des missions 31, 94 et 195, pour chaque faction | 12 |
| `effects` | Élimination (une par faction), tic de dégâts, malédiction | 4 |

- **Références** : vignettes 320 × 200 dans `design/essais/captures_reference/` (environ 7 Mo). Deux captures identiques donnent un écart de 0,00 ; les seuils sont donc serrés (moyenne 0,15 ; tuile de 20 × 20 px : 0,8), de façon à voir un projectile ou un effet déplacé. Exceptions : les traits de vent des Vents contraires (mission 31) suivent l'horloge réelle (tolérance de 2,0), et les éruptions (mission 71) varient légèrement avec la cadence d'images de la machine (tolérance de 12 sur une tuile, 0,4 en moyenne : seuls les écarts nets comptent). Un écart est toujours confirmé par une seconde capture avant d'être signalé ; le pied de page (numéro de version) est ignoré.
- **En cas d'écart** : `dist/visual/<nom>_ecart.png` montre « courant | référence | écart » et `dist/visual/report.json` résume. **Si le changement est voulu** (nouveau sprite, nouvel effet), regarder l'image puis relancer avec `--update` sur les captures concernées ; **s'il ne l'est pas**, c'est un défaut à corriger.
- **Limites** : l'outil dit qu'une image a changé, pas qu'elle est belle ; les références doivent être regardées avant d'être acceptées. Les missions du groupe `missions` ne montrent qu'une armée de deux défenseurs ; le groupe `armies` en montre six, mais les vagues sont sautées (la capture de la vague 10 affiche donc « Défaite » : l'armée est seule face au boss). Les ennemis ne sont pas isolés (ils apparaissent dans les vagues des missions) et les instants des affixes ont été choisis approximativement : à cette échelle (vignettes 320 × 200) seul l'avertissement et l'état actif des éruptions sont nets ; la tempête de sable, l'éboulement et la brume marine y sont peu visibles. À affiner si un effet doit être surveillé de près.
- Les références actuelles ont été regardées en planche-contact par l'agent : aucun défaut évident à cette échelle ; le jugement artistique reste au porteur.
