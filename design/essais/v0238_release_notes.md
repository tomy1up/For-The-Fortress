# Prototype v0.238 — Poseur de mines et Gobelin des braises animés

Valeurs de prototype à confirmer en partie réelle.

## Animations (lots de Codex validés par le porteur)

- **Poseur de mines (type 42)** : lancer du disque runique (60 images sur 0,96 s). Le disque part de la main ouverte à 0,40 s (image 25), depuis le repère retourné avec la pose, et fait un tour complet sur l'arc existant de 15 px. Si la cible est derrière le repère à l'écran, seul l'impact est joué.
- Les dégâts et leurs multiplicateurs (×1,8 dans le premier tiers du trajet, ×0,4 dans le dernier) ne changent pas.
- **Gobelin des braises (type 44)** : incantation (60 images sur 0,96 s). La braise part de la main à 0,40 s (image 25), depuis le repère retourné avec la pose, et file en ligne droite, pointe dirigée vers la cible. Si la cible est derrière le repère, seul l'impact est joué.
- **Badge de volatilité à l'impact** (demande du porteur) : quand le Gobelin rend volatile une cible qui ne l'était pas, le badge apparaît à l'arrivée de la braise (0,52 s), ou à 0,40 s quand l'impact se joue sans vol. Un badge déjà visible reste affiché au renouvellement. Celui de l'Alchimiste gnome s'affiche toujours dès le tir. L'explosion à la mort (80 dégâts, fenêtre de 4 s) ne change pas.

## Contrôles

- Régression complète : 144 suites sur 144, 197 425 contrôles Godot et 17 tests Python.
- Validateur des animations : 59 dossiers, aucun problème.
- Nouveaux contrôles dans `test_shop_effects.gd` (135 contrôles) : instants de départ, repères retournés, arc de 15 px du disque, vol rectiligne et orientation de la braise, impact seul derrière le repère, badge de volatilité à l'impact.
- Paquet Windows vérifié : 1 050 cas, 586 sources comparées.
- Contrôle visuel : 36 captures des deux gestes (six emplacements de la Vallée du Gué, avant le départ, en vol et à l'impact) ; badge de volatilité à l'arrivée de la braise.
