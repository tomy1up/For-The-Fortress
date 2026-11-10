# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 10 novembre 2026 — Claude Code

**Version en cours de publication : v0.170** (chapitre 8, missions 71–80, affixe Éruptions). La dernière version déjà publiée avant elle est la v0.169 (tag `v0.169`). 80 missions jouables : les chapitres 1 à 8 sont complets. Si `git tag` ne montre pas `v0.170`, la publication n'a pas abouti : reprendre au commit, au tag, au push puis à `gh release create` (voir `AGENTS.md`).

**v0.170** : nouveauté du chapitre 8 décidée dans son principe par le porteur (10 novembre 2026) : un affixe qui désactive au hasard un emplacement de défense quelques secondes. Valeurs de prototype à confirmer : 5 s toutes les 14 s, 2 s d'avertissement (`{"id":"eruptions","interval":14,"warning":2,"duration":5}` dans `campaign_catalogue.gd`). Fiche : `design/Missions_071_080_Eruptions.md`. Points techniques :

- **Modèle** (`valley_model.gd`) : `configure_combat_affix` valide champ par champ `headwinds` et `eruptions` ; `eruption_status()`, `eruption_slot(n)` (tirage par hachage entier de graine, vague et numéro, indépendant du pas de temps), événement dans `_next_event_time` / `_resolve_instant` (journal `éruption n emplacement s`). Test : `tests/test_eruptions.gd` (213 contrôles). L'affixe est enregistré dans le rapport et le rejeu le refuse s'il est altéré ou retiré.
- **Piège de réglage** : l'éruption désigne le *n*-ième emplacement *occupé* ; le résultat dépend donc de la position physique des défenseurs. Ne pas permuter les emplacements pour faire coller l'ordre d'achat d'un test : l'ordre d'achat de référence (4, 2, 3 pour toutes les cartes) est inscrit dans `tests/test_eruption_chapter.gd`.
- **Cartes 71–80** dans `scripts/volcanic_maps.gd` (générées hors dépôt ; ne pas les déplacer à l'œil). Simulation de référence avec les talents réels, 48 parties par carte. **Les simulations lisent les tracés dans le dépôt** (`volcanic_maps.gd`) et ne remplacent que les emplacements : toujours régénérer le fichier avec le nouveau tracé avant de simuler, sinon les résultats sont ceux de l'ancien tracé (erreur commise pendant cette mission).
- Tests de capture : variantes `ash71`…`ash80` (`play`, `ash80completed`) dans `main.gd` et `verify_windows_export.py` (instantané `ERUPTIONS_SNAPSHOT`).
- Marge faible pour la Horde sur 73 et 76 (6 PV restants).
- **Visuel provisoire** : `valley_view.gd::_draw_eruption` ; l'habillage définitif (lave ou cendres) est confié à Codex, voir `TODO_VISUELS.md`. Les captures de vérification montrent la fiche et le libellé de l'affixe, pas l'animation de désactivation.

Rappel des versions précédentes de cette mission : v0.168 (chapitre 7 durci, arbres de talents équilibrés, fiche `design/Equilibrage_arbres_talents_v0168.md`) et v0.169 (Alliance abaissée au niveau de la Horde, décision du porteur).

Points techniques à connaître :

- **Trois jeux de règles de talents** : `RULES_HISTORICAL` (0, avant 0.168), `RULES_V168` (1, tableau `TREE_SCALE_V168`), `RULES_CURRENT` (2, `TREE_SCALE`). `Model.talent_rules` est choisi par `Replay.talent_rules_for(game_version)` pour rejouer chaque rapport avec les règles de sa version.
- **Compositions de référence des tests** : Horde « deux haches + chaman » (`[3,3,5]`) ; Alliance « archer, arbalétrier, arbalétrier » (`[0,1,1]`). Chapitre 4 (`test_headwinds.gd`) : compositions et renforts propres à certaines missions.
- **Relevés historiques** : `Survey.historical_talents = true` (`tests/survey_shop.gd`) rejoue le relevé validé de la boutique avec les valeurs de talents d'origine.
- **Outil d'essai** : `tools/survey_campaign_sample.gd` accepte `natural_armies = true` (chaque orientation de talents joue l'armée de son arbre). À préférer aux compositions fixes pour comparer des arbres.
- Les emplacements des cartes 52–80 sont choisis par simulation avec les talents réels (et la composition de référence de chaque faction) : refaire la simulation en cas de modification.
- Régression complète v0.170 : 105 suites, 66 556 contrôles Godot et 17 tests Python (la suite `test_slate_campaign.gd` dépasse parfois le délai par défaut de 180 s sur cette machine : la relancer seule avec `--timeout 400`, elle réussit avec 1 110 contrôles). 11 essais Windows ciblés (chapitre 8 et mission 70) et 87 empreintes de sources réussis.
- L'outil PowerShell de l'agent peut être indisponible : lancer `powershell.exe …` depuis Bash (voir `AGENTS.md`). Ne pas écrire de chemins `…` dans un script Python lancé en ligne : écrire un fichier.
- Tout nouveau fichier d'exécution doit être déclaré dans trois listes d'export (voir `AGENTS.md`).

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : chapitre 9 (missions 81–90), premier chapitre d'un nouveau biome : biome et règles à faire choisir au porteur avant de développer.
- Visuels (Codex) : voir `TODO_VISUELS.md`, en particulier tout l'habillage volcanique.

## Questions ouvertes pour le porteur

- **Éruptions** : valeurs (5 s toutes les 14 s, 2 s d'avertissement) à confirmer en jeu ; choix visuel lave ou cendres délégué à Codex avec recommandation (voir `TODO_VISUELS.md`).
- **Courbe de difficulté du chapitre 7** : le Pont d'Obsidienne (66) est la carte la plus dure des deux factions (7 et 12 victoires sur 108 avec l'armée de chaque arbre), alors que le Seuil des Cendres, les Coulées Figées et le Cœur du Volcan côté Horde sont presque toujours gagnés. À lisser ?
- **Unités chères** : les arbres du mage et du chaman supposent d'acheter cette unité (100 or) à l'ouverture. Si les joueurs achètent d'abord les unités peu chères, ces arbres seront moins rentables.
- Équilibrage à confirmer en jeu : talents des deux factions, chapitres 4 à 7. Les chapitres 1 à 3 n'ont pas été remesurés avec les talents abaissés de l'Alliance (leurs tests de campagne passent).
