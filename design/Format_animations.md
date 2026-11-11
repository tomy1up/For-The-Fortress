# Format des animations par planches — version 1 (v0.174)

Cadre technique livré par Claude Code le 11 novembre 2026 pour que Codex dépose des animations **sans modifier le code**. Les valeurs et choix ci-dessous sont des réglages de prototype à confirmer après le pilote validé par le porteur (voir `TODO_ANIMATIONS_UNITES.md`).

## Principe

Chaque unité a un dossier `prototype/assets/animations/<id>/` contenant :

- `animation.json` : la description (ci-dessous) ;
- une ou plusieurs **planches PNG** : bande horizontale d'images de même taille, fond transparent.

Au démarrage de l'affichage d'une unité, le jeu cherche sa description. Si elle est absente, invalide, ou si une planche manque ou n'a pas la taille attendue, **l'illustration fixe actuelle est utilisée** : rien ne casse. Aucun code par unité, aucune déclaration dans les listes d'export : les fichiers `.png` et `.json` du dossier sont inclus tels quels dans le paquet et leurs empreintes sont contrôlées automatiquement.

Code : `prototype/scripts/animation_library.gd` (format, validation, calcul des images), intégration dans `valley_view.gd` (`_draw_sheet_walker`, `_draw_sheet_defender`).

## Identifiants (`<id>`)

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

`loop` est facultatif (`true` pour distance et temps, `false` pour événement ; toute autre valeur est refusée).

## Noms d'animations

| Nom | Pour | Déclenché en v0.174 ? |
| --- | --- | --- |
| `walk` | Ennemis | **Oui** (mode `distance`, ou `time`) |
| `idle` | Défenseurs au repos | **Oui** (mode `time` conseillé) |
| `attack` | Défenseurs qui tirent | **Oui** : en mode `event`, jusqu'au bout de sa durée depuis le dernier tir ; en mode `time`, pendant l'impulsion de tir (0,26 s). Côté de tir par miroir. |
| `disabled` | Défenseur désactivé par l'affixe Éruptions | **Oui** : joué depuis le début de la désactivation (mode `event` conseillé, durée 5 s aujourd'hui, ou `time`) |
| `death`, `hurt`, `spawn`, `buy`, `sell`, `level_up` | Réservés | Acceptés et validés, **pas encore déclenchés** : leur branchement fera l'objet d'une version dédiée, à demander à Claude Code quand les planches existent |

Un défenseur choisit son animation dans cet ordre : `disabled` si désactivé, `attack` si un tir est en cours, sinon `idle`. Si un état manque, le suivant est utilisé ; s'il n'y a ni `idle` ni état applicable, l'illustration fixe est dessinée.

## Contrôle

```
Godot --headless --path prototype --script res://tools/validate_animations.gd
```

Imprime une ligne par animation (`ok`) ou l'erreur exacte (champ invalide, planche introuvable, taille de planche incorrecte, PNG non décrit) et se termine en échec s'il y a un problème. La régression (`test_animation_library.gd`) refait le même contrôle sur tous les dossiers livrés. Largeur attendue d'une planche : `frames × frame_size[0]` ; hauteur : `frame_size[1]`.

## Choix techniques

- Les PNG sont lus bruts s'ils n'ont pas été importés par l'éditeur Godot (import automatique sinon) : pas besoin d'ouvrir l'éditeur pour qu'une livraison fonctionne.
- `export_presets.cfg` inclut `assets/animations/*` ; `Exporter_Windows.ps1` et `tests/export_sources.py` découvrent les fichiers `.png` et `.json` du dossier pour le contrôle des empreintes du paquet.
- Le rendu animé ne modifie jamais le combat (test dédié : l'état du modèle est identique avant et après dessin).
- Les cycles de marche des ennemis à l'écran sont réglés sur la distance parcourue à l'échelle d'affichage ; le loup conserve son rendu dédié (maillage) tant qu'il n'est pas migré.

## Limites connues

- Pas de véritable vue frontale : le miroir gauche/droite couvre les diagonales isométriques actuelles.
- Pas encore de variantes par niveau (1 à 4) ni par spécialisation : un seul jeu d'animations par défenseur.
- Pas de branchement de `death`, `hurt`, `spawn`, `buy`, `sell`, `level_up`.
- Aucune planche réelle n'est livrée : le cadre a été éprouvé avec des planches synthétiques (rectangles de couleur), pas avec de l'art.
