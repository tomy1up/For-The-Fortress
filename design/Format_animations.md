# Format des animations par planches — version 1 (v0.174)

Cadre technique livré par Claude Code (v0.174, étendu en v0.175 aux animations d'événements) pour que Codex dépose des animations **sans modifier le code**. Les valeurs et choix ci-dessous sont des réglages de prototype à confirmer après le pilote validé par le porteur (voir `TODO_ANIMATIONS_UNITES.md`).

## Principe

Chaque unité a un dossier `prototype/assets/animations/<id>/` contenant :

- `animation.json` : la description (ci-dessous) ;
- une ou plusieurs **planches PNG** : bande horizontale d'images de même taille, fond transparent.

Au démarrage de l'affichage d'une unité, le jeu cherche sa description. Si elle est absente, invalide, ou si une planche manque ou n'a pas la taille attendue, **l'illustration fixe actuelle est utilisée** : rien ne casse. Aucun code par unité, aucune déclaration dans les listes d'export : les fichiers `.png` et `.json` du dossier sont inclus tels quels dans le paquet et leurs empreintes sont contrôlées automatiquement.

Code : `prototype/scripts/animation_library.gd` (format, validation, calcul des images), intégration dans `valley_view.gd` (`_draw_sheet_walker`, `_draw_sheet_defender`).

## Identifiants (`<id>`)

- **Effets de jeu** : `effect.eruption` (avertissement des Éruptions : `foot` = centre de l'emplacement, planche à l'échelle du jeu, `display_height` = hauteur d'une image en pixels de jeu).
- **Ennemis** : l'identifiant d'identité de `scripts/enemy_catalogue.gd`, par exemple `enemy.horde.warrior`, `enemy.alliance.infantry`, `enemy.horde.garrison`, `enemy.neutral.drowned`. Une animation par identité (donc une par camp pour les profils de camp).
- **Défenseurs** : `defender.alliance.archer`, `defender.alliance.crossbow`, `defender.alliance.mage`, `defender.horde.axe`, `defender.horde.sapper`, `defender.horde.shaman`, puis la boutique : `defender.alliance.ranger`, `defender.alliance.musketeer`, `defender.horde.stalker`, `defender.horde.grenadier`.

## Description `animation.json`

```json
{
  "version": 1,
  "id": "enemy.horde.warrior",
  "display_height": 34,
  "foot": [32, 60],
  "facing": "right",
  "muzzle": [50, 20],
  "animations": {
    "walk": {"file": "walk.png", "frames": 12, "frame_size": [64, 64], "mode": "distance", "stride": 40}
  }
}
```

| Champ | Rôle |
| --- | --- |
| `version` | Toujours `1`. |
| `id` | Identique au nom du dossier. |
| `display_height` | Hauteur affichée **dans le jeu** d'une image entière, en pixels de jeu (un ennemi standard : environ 34). Le jeu applique ensuite son échelle propre à chaque type d'ennemi. |
| `foot` | Point d'appui au sol dans l'image (x, y en pixels de la planche) : il est placé sur la position de l'unité. |
| `facing` | Côté regardé par la planche : `right` (défaut) ou `left`. Le jeu retourne l'image selon le sens du déplacement ou du tir. |
| `muzzle` | Facultatif : point de départ des projectiles dans l'image (pixels de la planche). |
| `animations` | Au moins une animation parmi les noms ci-dessous. **Toutes les animations d'une unité ont la même taille d'image** (le point d'appui en dépend). |

Champs d'une animation : `file` (nom d'un PNG du dossier), `frames` (1 à 64), `frame_size` (largeur, hauteur en pixels, 1 à 1024), `mode`, et selon le mode :

| Mode | Champ requis | Comportement |
| --- | --- | --- |
| `distance` | `stride` : distance parcourue (en pixels de jeu, à l'échelle de `display_height`) pour un cycle complet | Boucle réglée sur le chemin parcouru : le pas suit la vitesse du jeu, la pause et le ralentissement. Cycle fermé obligatoire (la dernière image se raccorde à la première). Un décalage individuel évite que tous les ennemis marchent en phase. |
| `time` | `fps` : images par seconde (0 à 60) | Boucle réglée sur le temps. Pour les états de repos. |
| `event` | `duration` : durée en secondes | Joué une fois depuis le début de l'événement, puis maintenue sur la dernière image. Ne boucle pas. |
| `progress` | aucun (ni durée, ni foulée, ni cadence) | Réservé à l'animation `warning` : l'image est choisie par la **progression de 0 à 1 fournie par le jeu** (par exemple `1 - remaining / warning` pour l'avertissement des Éruptions). Suit donc la vitesse du jeu et la pause, sans durée à recopier. |

`loop` est facultatif (`true` pour distance et temps, `false` pour événement et progression ; toute autre valeur est refusée).

## Noms d'animations

Toutes sont pilotées par le jeu depuis la v0.175.

| Nom | Pour | Déclenchement | Mode |
| --- | --- | --- | --- |
| `walk` | Ennemis | En marche. **Obligatoire pour qu'un ennemi soit animé** (sans `walk`, l'illustration fixe est dessinée et les autres animations de l'ennemi sont ignorées). | `distance` (ou `time`) |
| `walk_up`, `walk_down` | Ennemis | Variantes facultatives de `walk` selon la pente du trajet **à l'écran** : `walk_up` quand le trajet monte, `walk_down` quand il descend. Mêmes `mode`, `frames` et `stride` (ou `fps`) que `walk`, vérifiés : la phase du pas se conserve au virage. `walk` reste obligatoire (repli quand la pente est nulle ou la variante absente). Le miroir gauche/droite s'applique comme pour `walk`. | comme `walk` |
| `hurt` | Ennemis | Après une perte de PV, pendant sa durée | `event` |
| `spawn` | Ennemis | À l'apparition à l'entrée, pendant sa durée | `event` |
| `death` | Ennemis | À l'élimination : jouée une fois à l'endroit de la mort, dans le sens du chemin (remplace les particules génériques) | `event` |
| `idle` | Défenseurs | Au repos | `time` conseillé |
| `attack` | Défenseurs | Tir en cours ; côté de tir par miroir | `event` jusqu'au bout de sa durée, ou `time` pendant l'impulsion de tir (0,26 s) |
| `disabled` | Défenseurs | Désactivés par l'affixe Éruptions, depuis le début de la désactivation | `event` (5 s aujourd'hui) ou `time` |
| `buy` | Défenseurs | À l'achat (préparation) | `event` |
| `level_up` | Défenseurs | À l'amélioration d'un niveau | `event` |
| `sell` | Défenseurs | À la revente : joue à l'ancien emplacement | `event` |
| `warning` | Effets de jeu (id `effect.eruption`) | Avertissement des Éruptions, au sol sous les unités, centré sur l'emplacement visé, pendant l'état `warning` | `progress` |

Les animations `death`, `hurt`, `spawn`, `buy`, `sell` et `level_up` ne se jouent qu'une fois par événement : mode `event` obligatoire, durée de 3 s au plus (validé). Les achats, niveaux et reventes sont repérés par le rendu en temps réel (le modèle ne bouge pas en préparation) ; ils ne sont pas animés au chargement d'une partie.

Un défenseur choisit son animation dans cet ordre : `sell` (fantôme à l'ancien emplacement), `disabled`, `attack`, `buy`, `level_up`, `idle`. Si un état manque, le suivant est utilisé ; s'il n'y a ni `idle` ni état applicable, l'illustration fixe est dessinée. Un ennemi choisit : `hurt`, `spawn`, sinon `walk_up` ou `walk_down` (selon la pente du trajet à l'écran, si elles existent), sinon `walk`.

## Contrôle

```
Godot --headless --path prototype --script res://tools/validate_animations.gd
```

Imprime une ligne par animation (`ok`) ou l'erreur exacte (champ invalide, planche introuvable, taille de planche incorrecte, PNG non décrit) et se termine en échec s'il y a un problème. La régression (`test_animation_library.gd`) refait le même contrôle sur tous les dossiers livrés. Largeur attendue d'une planche : `frames × frame_size[0]` ; hauteur : `frame_size[1]`.

## Choix techniques

- Les PNG sont lus bruts s'ils n'ont pas été importés par l'éditeur Godot (import automatique sinon) : pas besoin d'ouvrir l'éditeur pour qu'une livraison fonctionne.
- `export_presets.cfg` inclut `assets/animations/*` ; `Exporter_Windows.ps1` et `tests/export_sources.py` découvrent les fichiers `.png` et `.json` du dossier pour le contrôle des empreintes du paquet.
- Le rendu animé ne modifie jamais le combat (test dédié : l'état du modèle est identique avant et après dessin).
- Le point de départ des projectiles (`muzzle`) n'est pas branché : les flèches et autres tirs partent toujours de l'ancrage historique de la classe (`MUZZLES` dans les scripts d'art), qui correspond aux planches livrées. À brancher seulement si une planche s'en écarte.
- Les cycles de marche des ennemis à l'écran sont réglés sur la distance parcourue à l'échelle d'affichage ; le loup conserve son rendu dédié (maillage) tant qu'il n'est pas migré.

## Limites connues

- Pas de véritable vue frontale : le miroir gauche/droite couvre les diagonales isométriques actuelles.
- Pas encore de variantes par niveau (1 à 4) ni par spécialisation : un seul jeu d'animations par défenseur.
- Pas de variante de mort selon la cause (tir, forteresse atteinte) : une seule animation de mort par unité.
- Aucune planche réelle n'est livrée : le cadre a été éprouvé avec des planches synthétiques (rectangles de couleur), pas avec de l'art.
