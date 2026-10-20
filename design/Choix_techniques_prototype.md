# Choix techniques du premier essai

20 octobre 2026 — référence GDD v0.14.

Le porteur du projet a approuvé le cahier de réalisation puis demandé quel choix technique convenait le mieux. Godot avec GDScript, en 2D isométrique, a été recommandé et retenu pour cette réalisation initiale. Ce choix est révisable ; il ne constitue pas une nouvelle mécanique approuvée ou une direction artistique finale.

| Élément | Choix utilisé | Motif |
| --- | --- | --- |
| Moteur | Godot 4.7.2 stable standard, Windows x86_64 | Version stable proposée au téléchargement officiel lors de la vérification |
| Langage | GDScript | Intégration native au moteur et simplicité du premier prototype |
| Présentation | 2D projetée en isométrique | Conserver la géométrie logique approuvée et séparer les visuels des règles |
| Rendu | Compatibility | Adapté aux besoins simples de cette scène 2D |
| Visuels | Dessin temporaire par le projet | Carte, arbre, forteresse et Pillard visibles sans dépendance à des assets externes |
| Géométrie | Coordonnées logiques en unités du GDD | Distance du chemin 28 ; positions E1–E6 conservées |

## État vérifié au repère v0.14

La scène démarre avec le moteur officiel 4.7.2.stable.official.ed1daf0bf. Les 21 contrôles du modèle et les 15 contrôles d’interface passent. Un lancement avec rendu OpenGL a produit une capture vérifiée. Ces résultats concernent uniquement le trajet, l’arrivée, les PV, l’absence de récompense, les vitesses, la relance et l’inspection ; aucun combat de défenseur n’est encore implémenté.

L0 est partiellement réalisé : projet ouvrable et démarrable ; l’export d’un exécutable autonome reste à produire. L1 est réalisé pour les fonctions demandées. La prochaine étape est L2.

Le bâtiment de forteresse est décalé graphiquement dans sa cour pour laisser E6 lisible ; l’arrivée logique reste H (17 ; 6). Les visuels ne modifient pas les distances. Les calculs actuels de déplacement utilisent les nombres flottants du moteur avec une tolérance de 10⁻⁹ unité au seuil d’arrivée. Cette tolérance est un choix d’implémentation, pas un changement de longueur. Le futur ordonnanceur de combat et ses égalités de temps feront l’objet de contrôles distincts avant L3.

## Références officielles consultées

- [Godot 4.7.2 stable](https://godotengine.org/article/maintenance-release-godot-4-7-2/) et [téléchargement Windows](https://godotengine.org/download/windows/), vérifiés le 20 octobre 2026.
- [FAQ sur GDScript](https://docs.godotengine.org/en/stable/about/faq.html) : langage intégré recommandé pour débuter avec Godot.
- [Présentation des moteurs de rendu](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html) : Compatibility convient généralement à la 2D.

Le choix de ces outils découle des besoins du prototype ; les sources ne garantissent ni sa performance future ni son équilibre.

## Mise à jour au repère v0.15

L2 est réalisé avec une boucle Alliance N1 et dix Pillards. Le modèle utilise désormais un calendrier d’événements pour les apparitions, les entrées de portée, les tirs et les arrivées, afin de conserver les mêmes résultats à ×1 et ×2. Les bornes de couverture et les instants restent des float 64 bits. Voir le [suivi du prototype](Suivi_prototype.md) pour les 117 contrôles réussis et les limites du lot. Le moteur, le langage et le rendu restent inchangés.
