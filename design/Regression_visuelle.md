# Régression visuelle et parties aléatoires

**Statut : outils de contrôle ajoutés le 15 novembre 2026 par Claude Code (aucune règle de jeu modifiée).** Ils complètent la régression technique (`run_regression.py`), qui ne voit ni l'image ni les enchaînements imprévus.

## Parties aléatoires (`prototype/tests/test_fuzz_games.gd`)

Fait partie de `run_regression.py`. 120 parties complètes reproductibles (graine fixe) : mission, faction et alternative de boutique tirées au hasard, puis achats, améliorations, reventes, pas de temps (0,05 s, 0,5 s ou 300 s) et bonus aléatoires. Contrôles : or jamais négatif, PV de forteresse dans la limite, aucun ennemi vivant sans PV, conservation de l'or (or = départ + revenus − dépenses + reventes), chaque vague se termine, le rapport final se rejoue exactement. ~5 000 contrôles, une dizaine de secondes.

## Régression visuelle (`prototype/tests/visual_regression.py`)

Hors `run_regression.py` : elle ouvre le jeu sur l'écran de droite (`--screen 1`, pas de fenêtre minimisée).

```
python prototype/tests/visual_regression.py                      # compare les 96 captures aux références
python prototype/tests/visual_regression.py --types 40-47        # une plage de types
python prototype/tests/visual_regression.py --only unit46_pose   # une capture
python prototype/tests/visual_regression.py --update             # crée ou remplace les références
```

- **Captures** : pour chacun des 48 types de défenseurs (0 à 47), une image à la pose d'attaque (`unitNN_pose`) et une au milieu du vol du projectile (`unitNN_shot`), avec l'option `--capture-state=effects --capture-type=N` de `main.gd` (étendue aux types 6 à 47 le 15 novembre 2026).
- **Références** : vignettes 320 × 200 dans `design/essais/captures_reference/` (environ 3 Mo). Deux captures identiques donnent un écart de 0,00 ; les seuils sont donc serrés (moyenne 0,15 ; tuile de 20 × 20 px : 0,8), de façon à voir un projectile ou un effet déplacé.
- **En cas d'écart** : `dist/visual/<nom>_ecart.png` montre « courant | référence | écart » et `dist/visual/report.json` résume. **Si le changement est voulu** (nouveau sprite, nouvel effet), regarder l'image puis relancer avec `--update` sur les types concernés ; **s'il ne l'est pas**, c'est un défaut à corriger.
- **Limite** : l'outil dit qu'une image a changé, pas qu'elle est belle ; les références doivent être regardées avant d'être acceptées. Il ne couvre que le combat d'un défenseur seul sur une carte (le Gué) : pas les menus, ni les ennemis, ni les affixes.
- Les 96 références actuelles ont été regardées en planche-contact par l'agent : aucun défaut évident à cette échelle ; le jugement artistique reste au porteur.
