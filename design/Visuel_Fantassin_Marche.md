# Fantassin humain · cycle de marche

Proposition du 12 novembre 2026 sur les sources de la v0.180. Le cycle reprend le fantassin de l’atlas de l’Alliance, vu quand on joue la Horde. Il conserve le casque, l’épée et la hauteur de 34 px du sprite de référence. Le poids passe d’une botte à l’autre, le bassin accompagne le pas et le bras libre contrebalance l’épée.

Trois planches de 20 images de 316 × 380 px utilisent la même ancre (150, 320) et une foulée de 23 px projetés. En montée et en descente, les bottes suivent la pente. Le jeu conserve la pose au passage d’une variante à l’autre et retourne le sprite au virage selon le sens du trajet.

## Contrôles

| Point | Résultat |
| --- | --- |
| Appuis | Déplacement mesuré de 0,09 à 0,31 px sur les semelles isolées pendant les poses d’appui, après compensation du déplacement projeté. La mesure porte sur les images de la planche. |
| Cadence et sens | Vingt poses et quatre diagonales observées sur Les Coulées Figées (62) à ×1 puis ×2. L’index de pose concorde entre les trois variantes à distance égale. |
| Pause de contrôle | À ×1, temps de combat et pixels de la zone du fantassin identiques sur deux captures prises à 0,65 s d’intervalle. |
| Format et régression | Validateur à zéro problème sur neuf dossiers. Trois suites ciblées passent (1 614 contrôles Godot, 17 tests Python). |

[Marche en combat à ×1](essais/fantassin/Marche_fantassin_en_combat.gif) · [Quatre diagonales à ×1 et ×2](essais/fantassin/Fantassin_quatre_diagonales.jpg)
