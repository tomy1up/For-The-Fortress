# Prototype v0.220 — Incantation du Pyromancien et mode d'essai de la boutique

- **Pyromancien humain** (type 15, lot `788c066`, version au buste plus stable validée par le porteur le 16 novembre 2026) : garde et trois planches d'incantation (−12°, 0°, +12°, 20 poses sur 0,64 s) dans `assets/animations/defender.alliance.pyromancer/`. La boule de feu part à 0,288 s depuis la main, au point donné par angle (`lachers.json`), du même angle que la pose.
- **Mode d'essai de la boutique** (demande du porteur : tester les effets sans refaire toute la campagne) : lancer `Lancer_essai_boutique.cmd` (dossier du jeu publié, ou racine `prototype/` depuis les sources), ou `For_the_Fortress.exe -- --essai-boutique`. Toutes les unités de boutique des deux factions sont déjà possédées et se choisissent comme renfort ; la progression habituelle n'est pas touchée (profil séparé `progression_essai_boutique_v1.json`). Le nouveau fichier est déclaré dans les listes d'export et dans la vérification du ZIP.
- **Outillage** : options de capture `--capture-after` et `--capture-hp-percent` pour contrôler les marqueurs d'effet ; sons coupés par défaut (voir `design/Credits_audio.md`).
- **Contrôles** : `test_shop_trial.gd` (47) et `test_marksman_aim.gd` étendu au type 15.
- Aucune règle de combat modifiée.
