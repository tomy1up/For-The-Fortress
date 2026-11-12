# Éclaireur gobelin · course

Proposition du 12 novembre 2026, essayée sur les sources de la v0.181. L’éclaireur reprend le dessin du roster de la Horde et ses deux dagues. Le buste penche en avant, les bras alternent et la poussée se prolonge par un bref temps de suspension. Les bottes suivent le déplacement sur les deux pentes, avec une troisième planche de repli pour les trajets plats.

Les trois planches ont 20 poses de 340 × 330 px, une foulée de 25,5 px projetés et une ancre commune (161, 286). Mesure sur les semelles isolées pendant l’appui, après compensation du mouvement projeté, de 0,10 à 0,27 px selon la botte et la pente.

## Contrôles et intégration

Les vingt poses et les quatre diagonales ont été observées à chaque vitesse (×1 et ×2), vague 5 des Coulées Figées en Alliance. À distance égale, l’index de pose est le même dans les trois variantes. La zone du gobelin est identique au cours d’une pause de contrôle de 0,65 s. Le validateur a accepté les planches.

Le porteur a donné un avis favorable à l’aperçu. Le test de la bibliothèque utilise désormais l’identifiant sans planche `enemy.horde.inconnu` pour le cas négatif (`47eefa5`). Les quatre fichiers ont été copiés dans `prototype/assets/animations/enemy.horde.scout/`, avec vérification de leurs empreintes. La copie d’étude sert de référence. Après import Godot, le validateur passe sur 11 dossiers. Les trois suites ciblées passent (1 616 contrôles Godot et 17 tests Python). Les deux essais en combat confirment les quatre diagonales et les vingt poses à chaque vitesse.

[Course en combat](essais/eclaireur_gobelin/Course_eclaireur_en_combat.gif) · [Quatre diagonales à ×1 et ×2](essais/eclaireur_gobelin/Eclaireur_quatre_diagonales.jpg)
