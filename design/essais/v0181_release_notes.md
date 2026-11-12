# Prototype v0.181 — Désert et ruines habillé, miniature de campagne

- **Désert et ruines, missions 101 à 110** : habillage de Codex (palette de grès ocre, rides de sable, colonnes, murs, grès et obélisques, deux orientations par pièce) intégré dans `assets/decor/decor.json` ; placements des dix cartes contrôlés par test contre les marges des routes et des emplacements. Les chapitres 11 et 12 partagent le biome : les cartes 111 à 120 gardent la palette de sable en attendant leurs pièces.
- **Miniature de campagne** : l'aperçu de mission reprend la palette du décor (sable pour le désert, cendre pour le volcan, pierre du camp adverse pour la citadelle) au lieu du fond vert par défaut.
- Les retouches du lancer de hache du troll de Codex (commits `cdad330`, `4c121ba`, `48c4775`) restent sur `art/codex` : le porteur ne les a pas encore validées pour une version.

Vérification : régression complète 113 suites, 96 856 contrôles Godot, 17 tests Python ; export Windows, 4 essais ciblés et 149 empreintes de sources réussis ; capture de la mission 101 examinée (sol de grès et pièces de ruines).
