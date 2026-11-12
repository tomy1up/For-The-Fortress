# Prototype v0.182 — Désert complet, tempête animée, cendres des éruptions

- **Chapitre 12 habillé** (missions 111 à 120) : pièces du désert de Codex (dont le sphinx) sur les dix cartes, placements contrôlés par test (marges des routes et des emplacements, désormais pour le désert aussi).
- **Tempête de sable animée** : planches `warning` (progression pendant les 3 s d'annonce) et `storm` (boucle pendant la rafale) de `effect.sandstorm`, étirées sur le plateau. **Le mouvement suit le temps de combat** (au lieu de l'horloge réelle) : il accompagne la vitesse du jeu et la pause et se reproduit à l'identique ; le repère provisoire de repli fait de même.
- **Éruptions** : avertissement renforcé et **cendres de désactivation** (`effect.eruption`, animation `disabled`, 5 s) dessinées au-dessus des pieds du défenseur frappé, avec l'âge `durée − temps restant` ; le repère provisoire reste en repli.
- Les retouches du lancer de hache du troll (commits `cdad330`, `4c121ba`, `48c4775` de `art/codex`) ne sont toujours pas fusionnées.

Vérification : régression complète 113 suites, 101 990 contrôles Godot, 17 tests Python ; export Windows, 4 essais ciblés et 159 empreintes de sources réussis ; captures du jeu exporté examinées : mission 111 à 17 s (décor de grès, libellé de l'affixe, anneau de portée réduit ; le voile de la planche de tempête est très discret sur la capture : à juger en jeu) et mission 71 à 16 s (défenseur désactivé sur sa case assombrie).
