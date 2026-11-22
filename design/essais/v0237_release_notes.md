# Prototype v0.237 — Vétéran royal et Pillard gobelin animés

Valeurs de prototype à confirmer en partie réelle.

## Animations (lots de Codex validés par le porteur)

- **Vétéran royal (type 40)** : tir et réarmement (48 images sur 0,96 s). Le carreau part de la glissière de l'arbalète à 0,36 s (image 18), en ligne droite ; le repère se retourne avec la pose. Si la cible est derrière la glissière à l'écran, seul l'impact est joué. Le bonus par vague et son plafond ne changent pas.
- **Pillard gobelin (type 41)** : lancer du jeton (48 images sur 0,96 s). Le jeton part de la main ouverte à 0,36 s (image 18), fait un tour complet sur l'arc existant de 8 px, et se retourne avec la pose. Impact seul si la cible est derrière la main.
- **Badge de pillage à l'impact** (demande du porteur) : quand le Pillard pille une cible qui ne l'était pas, le badge apparaît à l'arrivée du jeton, à 0,48 s, ou à 0,36 s quand l'impact se joue sans vol. Un badge déjà visible reste affiché quand le pillage est renouvelé. Le pillage du Marchand mercenaire s'affiche toujours dès le tir. Le bonus de +120 % et sa fenêtre de 4 s s'appliquent toujours dès le tir dans la simulation.

## Contrôles

- Régression complète : 144 suites sur 144, 197 401 contrôles Godot et 17 tests Python.
- Validateur des animations : 57 dossiers, aucun problème.
- Nouveaux contrôles dans `test_shop_effects.gd` (113 contrôles) : instants de départ, repères retournés, impact seul derrière la glissière ou la main, arc du jeton, badge de pillage à l'impact, renouvellement et pillage du Marchand.
- Paquet Windows vérifié : 1 050 cas, 576 sources comparées.
- Contrôle visuel : 36 captures des deux gestes (six emplacements de la Vallée du Gué, avant et après le départ, puis à l'impact) ; badge du Pillard à l'arrivée du jeton, ou dès 0,36 s quand l'impact se joue sans vol.
