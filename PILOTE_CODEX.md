# Pilote animations — consigne prête à lancer pour Codex

Préparé par Claude Code le 11 novembre 2026, à partir de la v0.174. À lire avec [TODO_ANIMATIONS_UNITES.md](TODO_ANIMATIONS_UNITES.md) (vue d'ensemble) et [design/Format_animations.md](design/Format_animations.md) (format technique). Le travail artistique est celui de Codex ; Claude Code n'y touche pas.

## Objectif

Livrer **deux unités animées** pour valider la méthode avec le porteur avant la série :

1. **Archer elfe** (défenseur de l'Alliance) : repos, tir, désactivation.
2. **Guerrier orc** (ennemi de la Horde, face à l'Alliance) : marche.

Aucune autre unité dans ce pilote. Le porteur valide en jeu avant toute extension (décision du 1er novembre 2026, rappelée dans `design/Validation_visuelle_animations.md`).

## Livrables

### A. Archer elfe — `prototype/assets/animations/defender.alliance.archer/`

| Animation | Mode | Contenu attendu |
| --- | --- | --- |
| `idle` | `time`, 6 à 10 images/s, 6 à 8 images | Respiration légère, l'arc tenu, boucle fermée |
| `attack` | `event`, durée de 0,4 à 1,0 s, 6 à 10 images | Encochage, traction, lâcher, retour. Le tir réel part au début de l'événement ; garder le lâcher dans la première moitié |
| `disabled` | `event`, durée 5 s (ou `time` en boucle), 4 à 8 images | Unité étouffée par la désactivation (affixe Éruptions) : voir « Éruptions » ci-dessous |

- Taille d'image conseillée : 192 × 192 px à 256 × 256 px par image, identique pour les trois animations (obligatoire).
- `display_height` : **66** (hauteur actuelle de l'illustration, `scripts/alliance_art.gd`). `foot` : le point d'appui au sol dans l'image. `muzzle` : point de départ de la flèche, aujourd'hui à (26, −34) pixels de jeu du pied dans le sens du tir à droite ; à convertir en pixels de planche.
- Le dessin regarde à droite (`facing: "right"`) ; le jeu le retourne pour tirer à gauche. Pas besoin de livrer la version gauche.
- Référence visuelle à respecter : `assets/units/alliance/archer_v001.png` et ses poses `archer_encochage_v001.png`, `archer_lacher_v001.png`, `archer_rearmement_v001.png` (mêmes proportions, mêmes couleurs, style cartoon retenu, `design/Assets_Alliance_v061.md`).

### B. Guerrier orc — `prototype/assets/animations/enemy.horde.warrior/`

| Animation | Mode | Contenu attendu |
| --- | --- | --- |
| `walk` | `distance`, `stride` à calibrer, 12 à 16 images | Cycle de marche fermé, pied d'appui presque fixe par rapport au sol pendant la poussée |

- Taille d'image conseillée : 128 × 128 px à 192 × 192 px. `display_height` : **34** (hauteur actuelle, `scripts/enemy_art.gd`).
- `stride` : distance parcourue en pixels de jeu pour un cycle complet à l'échelle d'affichage. Point de départ : environ une fois et demie la largeur affichée du personnage ; **à ajuster en jeu** jusqu'à ce que le pied d'appui ne glisse pas. Le jeu règle le cycle sur la distance réellement parcourue : il suit la vitesse, la pause et le ralentissement.
- Le dessin regarde à droite ; le jeu le retourne selon le sens du chemin (diagonales isométriques). Pas de vue de face dans ce pilote.
- Référence visuelle : le guerrier orc de l'atlas `assets/enemies/rosters/horde_v003.png` (cadre `Rect2(51,275,302,324)`), proportions et couleurs conservées.

### C. Descriptions

Un `animation.json` par dossier, au format de `design/Format_animations.md`. Exemple pour le guerrier :

```json
{
  "version": 1,
  "id": "enemy.horde.warrior",
  "display_height": 34,
  "foot": [96, 180],
  "facing": "right",
  "animations": {
    "walk": {"file": "walk.png", "frames": 12, "frame_size": [192, 192], "mode": "distance", "stride": 40}
  }
}
```

Chaque planche est une bande horizontale : largeur `frames × frame_size[0]`, hauteur `frame_size[1]`, fond transparent.

## Éruptions : ce que `disabled` doit montrer

Toutes les 14 s de combat, un défenseur tiré au hasard est désactivé 5 s, avec 3 s d'avertissement (missions 71 à 80). L'animation `disabled` joue pendant les 5 s de désactivation, depuis leur début. **L'avertissement (3 s avant) n'est pas une animation d'unité** : il reste un effet de carte, traité dans une tâche séparée (`TODO_VISUELS.md`).

Choix visuel à trancher par le porteur, lave ou cendres. Recommandation de Claude Code : nuage de cendres sur l'unité, qui reste lisible et reconnaissable dessous (l'unité paraît étouffée, pas détruite). Livrer cette version dans le pilote ; une variante lave peut être ajoutée pour comparaison si Codex le juge utile, dans un dossier à part nommé clairement, non branché.

## Intégration et contrôle

1. Déposer les dossiers dans `prototype/assets/animations/`. Aucun code, aucune liste d'export à modifier : les `.png` et `.json` sont inclus et leurs empreintes contrôlées automatiquement.
2. Contrôle formel : `Godot --headless --path prototype --script res://tools/validate_animations.gd` doit se terminer par `problemes=0`.
3. Contrôle en jeu (obligatoire avant de présenter) : `Lancer_le_prototype.cmd` ou Godot avec `--path prototype --screen 1`, mission avec un archer placé et des guerriers orcs, vitesses ×1 et accélérée, pause. Pour l'archer : repos, tir à droite et à gauche, désactivation (missions 71 à 80 de l'Alliance, ou une partie de contrôle avec l'affixe). Pour le guerrier : marche sur chemin à diagonales, pas qui ne glisse pas, boucle sans à-coup, taille cohérente à côté des autres ennemis.
4. Tableau de contrôle visuel de `design/Validation_visuelle_animations.md` (silhouette, raccords, appuis, accord du pas et de la vitesse, fluidité) : l'agent fait son propre contrôle avant de présenter.
5. Lancer la régression ciblée : `python prototype/tests/run_regression.py --test test_animation_library.gd`. Si un test échoue à cause d'une livraison, le signaler dans `PASSATION.md`.
6. Captures de contrôle dans `design/essais/` (images avant / après, ou courte séquence) et courte fiche `design/Pilote_animations.md` : choix de taille, de cadence, de `stride`, difficultés rencontrées, temps passé par unité (utile au porteur pour estimer la série).

## Limites à connaître

- Seules `walk` (ennemis) et `idle`, `attack`, `disabled` (défenseurs) sont branchées. Mort, coup reçu, apparition, achat, revente et niveau sont acceptés par le format mais pas déclenchés : ne pas en livrer avant d'en avoir demandé le branchement à Claude Code.
- Pas encore de variantes par niveau (1 à 4) ni par spécialisation : un seul jeu d'animations par unité.
- Les valeurs de cadence et de durée sont des réglages de prototype à confirmer avec le porteur.
- Le jeu garde l'illustration fixe si la description ou une planche est invalide : un échec silencieux possible, d'où l'importance du contrôle formel (étape 2).

## Rendu attendu pour le porteur

Après le pilote, le porteur doit pouvoir répondre à ces questions (à poser dans le message de fin de mission) :

- L'animation donne-t-elle une impression naturelle de marche et de tir, à la taille de jeu ?
- La technique (planches d'images) convient-elle pour la série, ou faut-il tester les couches séparées ou la déformation de maillage pour certaines unités ?
- Les délais de production par unité sont-ils acceptables pour les 27 identités à animer (10 défenseurs, 12 ennemis de camp, 5 neutres) ?

## Passation

À la fin du pilote : mettre à jour `PASSATION.md` (ce qui est livré, validé ou non, contrôles lancés) et cocher la case correspondante dans `TODO_VISUELS.md` (section « Livré »). Ne pas étendre aux autres unités avant la validation du porteur.
