# Consignes communes aux agents — For the Fortress!

Ce fichier est la source unique des consignes de développement. Codex le lit directement ; Claude Code le lit via `CLAUDE.md`. Toute nouvelle règle durable s'ajoute ici, pas dans un fichier propre à un agent.

Avant de commencer une mission, lire [PASSATION.md](PASSATION.md) : il décrit l'état laissé par l'agent précédent. Les rôles de chaque agent sont fixés plus bas (« Répartition des rôles ») ; la file des visuels est [TODO_VISUELS.md](TODO_VISUELS.md) et la mission d'ensemble animations, unités et effets est [TODO_ANIMATIONS_UNITES.md](TODO_ANIMATIONS_UNITES.md) (pilote : [PILOTE_CODEX.md](PILOTE_CODEX.md)).

## Le projet

Tower defense 2D isométrique, deux factions (Alliance des Royaumes, Horde des Cendres), campagne de missions de dix vagues. « For the Fortress! » reste un nom de travail.

- `For_the_Fortress_GDD.md` (et `.docx`) : GDD de référence, tenu à jour par Claude Code à chaque version (voir « Cycle d'une version »).
- `design/` : décisions, fiches de lot et comparaisons. Points d'entrée : `Cadrage_campagne_2026-10-29.md` (règles CAMP-xxx), `Biomes_cumul_2026-10-31.md` (biomes, chapitres, décisions récentes), `Choix_techniques_prototype.md`.
- `design/essais/` : notes de version `vXXXX_release_notes.md`, captures de QA, ateliers artistiques.
- `prototype/` : projet Godot (`project.godot`, `scripts/`, `scenes/`, `assets/`, `tests/`, `tools/`, `distribution/`).
- `README.md` : une ligne d'annonce par version, la plus récente en haut.
- `dist/` : exports Windows et journaux de vérification, hors Git.

## Règles de collaboration avec le porteur du projet

- Écrire au porteur en français, sans exception.
- Le porteur décide de la direction : périmètre, expérience visible, règles de jeu, équilibrage approuvé, priorités. Les choix purement techniques reviennent à l'agent, qui les explique brièvement.
- Ne jamais présenter une hypothèse de conception comme approuvée. Les valeurs et habillages non validés sont écrits « réglage/habillage de prototype à confirmer ». Les décisions validées sont datées et attribuées au porteur dans `design/`.
- Préserver la progression persistante (PO, XP, talents, missions réussies) et l'isolation des factions : chaque faction a son parcours, ses gains et ses talents.
- Les essais graphiques s'ouvrent sur l'écran de droite : Godot `--screen 1`, fenêtre minimisée quand c'est possible pour laisser la main au joueur.
- Ne pas affirmer qu'un test passe, qu'un fichier existe ou qu'une version est publiée sans l'avoir vérifié. Rapporter les nombres de contrôles réellement obtenus.

## Outillage (hors dépôt)

- Moteur : Godot 4.7.2 stable standard, `C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe` (version attendue `4.7.2.stable.official.ed1daf0bf`). Templates d'export dans `%APPDATA%/Godot/export_templates/4.7.2.stable`.
- `C:/Projet/.tools/` contient aussi des scripts ponctuels d'essais et de publication (`survey_*.gd`, `publish_v0XXX.py`). Ce ne sont pas des outils officiels du dépôt.
- Python 3 système (`python`). Sous Windows PowerShell, appeler les `.ps1` avec `-ExecutionPolicy Bypass` : la stratégie par défaut de la machine les bloque.
- Si l'outil PowerShell de l'agent est indisponible, lancer les scripts depuis Bash avec `powershell.exe -NoProfile -ExecutionPolicy Bypass -File …`, et arrêter un jeu bloqué avec `taskkill //F //IM For_the_Fortress.exe`.
- GitHub : dépôt privé `tomy1up/For-The-Fortress`, `gh` authentifié sur le compte `tomy1up`.

## Commandes

Jouer depuis les sources : `prototype/Lancer_le_prototype.cmd`, ou Godot avec `--path prototype --screen 1`. Atelier des routes : ajouter `-- --atelier-routes`.

Tests (Godot + Python + contrats du GDD) :

```
python prototype/tests/run_regression.py                                  # tout (105 suites, long)
python prototype/tests/run_regression.py --test test_marsh_campaign.gd    # suite ciblée, répétable
python prototype/tests/run_regression.py --report dist/vXXXX-regression/report.json --timeout 120
```

Chaque suite Godot imprime `TESTS checks=N failures=0` ; le rapport final est `REGRESSION ok=True ...`. Définir `PYTHONIOENCODING=utf-8` si la console déforme les accents.

Régression visuelle du combat (écran de droite, hors `run_regression.py`) : `python prototype/tests/visual_regression.py` compare 96 captures de défenseurs aux références de `design/essais/captures_reference/` ; `--update` après avoir regardé un changement voulu. Détails et parties aléatoires : `design/Regression_visuelle.md`.

Export Windows (la version doit correspondre à `project.godot`) :

```
powershell -NoProfile -ExecutionPolicy Bypass -File prototype/Exporter_Windows.ps1 -Version 0.XXX -OutputRoot "dist/v0XXX-validation"
python prototype/tests/verify_windows_export.py dist/v0XXX-validation/For_the_Fortress_v0.XXX_Windows_x64.zip --destination dist/v0XXX-verification --screen 1 --background --source-project prototype [--case NOM ...]
```

`verify_windows_export.py` contrôle le contenu du ZIP, les empreintes des sources et lance des captures ; inspecter les captures pertinentes avant de publier.

Captures avec défenseurs d'une mission (après export, depuis le dossier vérifié) : lancer `For_the_Fortress.exe --screen 1 -- "--capture=<png>" --capture-state=campaign_menu --capture-faction=<alliance|horde> --capture-campaign=marsh<N>play --capture-mountain-defence` (`mountain<N>play` pour les Ardoises). Sans `--minimized` : une fenêtre réduite peut ne jamais enregistrer l'image et rester bloquée.

## Cycle d'une version

Une version = un lot cohérent, testé, compilé et publié. Numérotation `0.XXX` (dernière publiée : voir `README.md` et `git tag`).

1. Changer la version partout où Codex l'a fait jusqu'ici : `prototype/project.godot` (`config/version`), `prototype/export_presets.cfg`, valeur par défaut de `prototype/Exporter_Windows.ps1`, constantes de version dans les scripts et tests qui la vérifient (rechercher l'ancien numéro avec `rg`), `prototype/distribution/LIRE_MOI.txt`.
2. Développer le lot et ses tests. Tout nouveau script ou asset d'exécution doit être déclaré dans trois listes : `prototype/export_presets.cfg` (`export_files`), `prototype/Exporter_Windows.ps1` (`$sourcePaths`) et `prototype/tests/export_sources.py` (`SOURCE_PATHS`). Les tests lancés depuis les sources ne voient pas un oubli : le jeu exporté ne démarre pas (erreur d'analyse au chargement). Seule la vérification du ZIP exporté le détecte.
3. Documenter : fiche `design/<Sujet>.md` (statut de conception, paramètres, essais, limites), notes `design/essais/vXXXX_release_notes.md`, ligne d'annonce en tête de `README.md`, mise à jour des documents de décision concernés.
   **GDD (décision du porteur, 12 novembre 2026) : à chaque version, Claude Code met à jour `For_the_Fortress_GDD.md` puis régénère `For_the_Fortress_GDD.docx`.** Le GDD est la référence pour retrouver une décision passée : y consigner les décisions prises (registre de la section 48, avec date et statut V/H), les décisions encore à prendre (section 49), l'état de la campagne et des affixes (sections 62 à 64) et le journal des versions (section 66), sans présenter une hypothèse comme validée. Lancer `python prototype/tests/run_regression.py` : les contrats du GDD y sont vérifiés.
4. Vérifier : suites ciblées puis régression complète, export, `verify_windows_export.py`, inspection des captures dans les deux factions.
5. Livrer, si la mission l'autorise : commit sur `main` (message court en anglais, par ex. `Add marsh missions 42 and 43 with map-specific basins`), tag annoté `v0.XXX` (`Prototype v0.XXX - <titre>`), push de `main` et du tag, puis publication GitHub en préversion avec le ZIP et son `.sha256` :

```
gh release create v0.XXX dist/v0XXX-validation/For_the_Fortress_v0.XXX_Windows_x64.zip dist/v0XXX-validation/For_the_Fortress_v0.XXX_Windows_x64.sha256 --prerelease --title "Prototype v0.XXX - <titre>" --notes-file design/essais/v0XXX_release_notes.md
```

Vérifier ensuite que la release liste les deux fichiers. Ne jamais forcer un push ni réécrire un tag publié.
6. Nettoyer `dist/` (décision du porteur, 14 novembre 2026 : le dossier dépassait 50 Go) : après chaque publication, supprimer les exports, vérifications, régressions et ZIP des versions antérieures aux deux dernières, sans toucher à rien hors de `dist/` ; les ZIP publiés restent sur GitHub.

## Répartition des rôles

Décision du porteur, 9 novembre 2026 :

- **Codex : visuels, animations et toute la production artistique.** Assets, dessins, sprites, animations (marche, attaque, impacts, morts), effets visuels, icônes, habillage des cartes, palettes, décor, direction graphique des écrans.
- **Claude Code : code.** Règles, campagne, missions, interface fonctionnelle, tests, export, publication.
- **Son** (décision du porteur, 16 novembre 2026) : **Claude Code** gère le son, par intégration de banques libres de droits uniquement (licence CC0 de préférence, aucune dépense). Il choisit, branche et règle les sons, consigne chaque source et licence dans `design/Credits_audio.md`, et ne présente jamais un choix sonore comme validé avant l'écoute du porteur. Codex ne produit pas de son.
- **Précision du porteur, 15 novembre 2026 :** Claude Code prend en charge, dans le code, les **effets dessinés par le jeu** (projectiles, impacts, anneaux, particules, traînées, avertissements d'affixes, lâchers et synchronisations d'effets) et le **contrôle visuel** des captures (lisibilité, cadrage, ancrage des pieds, couleurs), qu'il signale à Codex. Tous les sprites, poses, planches, icônes, décors et animations dessinées restent à Codex.
- Claude Code ne réalise pas le travail visuel : il l'ajoute à [TODO_VISUELS.md](TODO_VISUELS.md) avec le contexte utile, et peut poser un emplacement neutre ou réutiliser un visuel existant pour que le code fonctionne en attendant.
- Codex prend ses tâches dans `TODO_VISUELS.md` et les marque livrées. S'il doit toucher au code pour intégrer un visuel, il le demande d'abord dans sa boîte aux lettres, garde les tests au vert et le signale dans `PASSATION.md`.

## Équilibrage des talents

- Les trois arbres de chaque faction doivent se valoir pendant toute l'aventure (décision du porteur, 10 novembre 2026). Fiche et méthode : `design/Equilibrage_arbres_talents_v0168.md` ; test de parité : `prototype/tests/test_talent_balance.gd`.
- Les facteurs d'équilibrage sont dans `TREE_SCALE` (`meta_talents_expanded.gd`) ; les anciens jeux de valeurs restent dans `TREE_SCALE_V168` et `RULES_HISTORICAL`. Toute modification des effets de talents change le résultat des anciens rapports : garder l'ancien tableau, ajouter un jeu de règles (`RULES_*`) et un seuil de version dans `Replay.talent_rules_for`.
- Alliance et Horde doivent avoir la même puissance de talents (décision du porteur, 10 novembre 2026) : les cartes sont réglées pour la stratégie de référence de la Horde (deux haches et un chaman) ; la référence de l'Alliance est archer, arbalétrier, arbalétrier.
- Juger un arbre avec son armée naturelle (l'unité qu'il améliore achetée à l'ouverture) et mesurer sa puissance par recherche du PV ennemi maximal battu, pas avec des compositions fixes qui favorisent un arbre.

## Travail à deux : copies séparées, zones de fichiers, boîtes aux lettres

Décision du porteur, 11 novembre 2026 : Codex et Claude Code ne travaillent **plus dans le même dossier**.

**Copies séparées.** Claude Code travaille dans `C:\Projet\For the Fortress!` sur la branche `main`. Codex travaille dans son propre dossier, `C:\Projet\For the Fortress! - Codex`, qui est une copie de travail du même dépôt (`git worktree`) sur la branche `art/codex`. Le premier lancement de Godot dans ce dossier réimporte les ressources (plusieurs minutes).

**Qui fait quoi dans Git.**
- Codex commite sur `art/codex` et pousse cette branche. Il ne pousse jamais sur `main`, ne crée ni ne supprime de tag, ne publie aucune version.
- Avant chaque nouveau lot, Codex met sa branche à jour : `git fetch origin` puis `git merge origin/main` (ou `git rebase origin/main` s'il le préfère), et relance les tests ciblés qui concernent son lot.
- Claude Code fusionne `art/codex` dans `main` quand le lot de Codex passe ses contrôles (validateur, tests ciblés, régression), puis prévient le porteur. Le jugement artistique du porteur se fait sur la version publiée ; Claude Code ne publie jamais un visuel que Codex déclare non prêt. Claude Code est seul à construire l'export, taguer et publier.
- Les actions irréversibles ou réservées du porteur (push forcé, suppression de branche ou de tag, réécriture d'historique) restent soumises à sa demande explicite.

**Zones de fichiers.**
- Codex : `prototype/assets/**` (images, animations, décor, y compris `assets/decor/decor.json` et les fichiers `.import` générés), `design/essais/**`, ses fiches `design/Visuel*.md`, `design/Pilote_animations.md`, `design/Appuis_*.md` et `design/Avertissement_*.md`.
- Claude Code : `prototype/scripts/**`, `prototype/tests/**`, `prototype/tools/**`, les listes d'export, la version, `README.md`, `design/Format_*.md`, `design/Missions_*.md`.
- Fichiers partagés : `PASSATION.md` (chacun écrit dans sa section et ne modifie pas celle de l'autre), `TODO_VISUELS.md` et `TODO_ANIMATIONS_UNITES.md` (Claude Code ajoute les besoins ; Codex coche ce qu'il livre), `AGENTS.md` (changement de règle seulement avec l'accord du porteur).
- Si Codex doit modifier du code pour intégrer un visuel, il le demande d'abord dans sa boîte aux lettres : Claude Code le fait, ou accepte le changement à la fusion.

**Boîtes aux lettres** (à la racine du dépôt). Chacun écrit dans **son** fichier et lit celui de l'autre :
- `ECHANGES_CLAUDE_VERS_CODEX.md` : écrit par Claude Code (demandes de visuels, formats livrés, corrections).
- `ECHANGES_CODEX_VERS_CLAUDE.md` : écrit par Codex (livraisons, identifiants visés, besoins de code, questions).
- Chaque entrée porte la date, un titre et un état (`ouvert`, `traité`). L'auteur ne passe en `traité` que ses propres entrées une fois l'autre partie confirmée. Les entrées closes se déplacent en bas du fichier, section « Traité ».
- Le porteur garde le dernier mot sur les décisions de direction ; les directives qu'il doit relayer à l'autre agent sont proposées en fin de message par l'agent qui les identifie.

## Passation entre agents

- En début de mission : lire `PASSATION.md`, la boîte aux lettres de l'autre agent, puis `git status` et `git log -5` ; l'état réel du dépôt fait foi.
- En fin de mission, ou dès que le porteur annonce un changement d'agent : mettre à jour sa section de `PASSATION.md` (version en cours, ce qui est commité ou non, tests réellement lancés et résultats, prochaines étapes, questions ouvertes pour le porteur).
- Ne pas laisser de travail à moitié appliqué sans le signaler dans `PASSATION.md`.
