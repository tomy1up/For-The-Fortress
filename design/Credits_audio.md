# Crédits audio

Décision du porteur, 16 novembre 2026 : le son vient de banques libres de droits, sans dépense ; Claude Code l'intègre (`AGENTS.md`). Les choix ci-dessous sont des **réglages de prototype à confirmer à l'écoute du porteur** : certains sons sont des substituts (aucun pack ne fournit de vrai son d'arc, d'arme à feu ou de magie).

## Source

[Kenney](https://kenney.nl) — licence **Creative Commons CC0 1.0** (domaine public, aucune obligation de crédit ; crédit donné par courtoisie). Packs téléchargés le 16 novembre 2026 depuis les pages officielles (seuls `down_1`, `down_2`, `click_1` et `buy_1` en proviennent encore) :

- [Impact Sounds](https://kenney.nl/assets/impact-sounds) (v1.0, 2019)
- [RPG Audio](https://kenney.nl/assets/rpg-audio) (v1.0, 2014)
- [Interface Sounds](https://kenney.nl/assets/interface-sounds) (v1.0, 2020)

Les archives d'origine sont dans `C:/Projet/.tools/audio/` (hors dépôt) avec leur `License.txt`. Seuls les 20 fichiers utilisés sont copiés dans `prototype/assets/audio/sfx/`.

[150 Combat Sound Effects](https://opengameart.org/content/150-combat-sound-effects) (OpenGameArt, untamedpixels) — licence **CC0** (compilation de plusieurs auteurs, détail dans `LICENSES.txt` de l'archive). Téléchargé le 16 novembre 2026 ; archive dans `C:/Projet/.tools/audio/oga_150-combat-sound-effects.zip`. Les premiers choix Kenney (sons d'interface utilisés comme tirs) ont été jugés inappropriés par le porteur le 16 novembre 2026 et remplacés. Les fichiers sont recoupés (durée maximale indiquée, fondu de 60 ms), ramenés en mono et normalisés.

## Fichiers utilisés

| Fichier du jeu | Événement | Pack | Fichier d'origine | Durée max. |
| --- | --- | --- | --- | --- |
| `bow_1.wav` | tir d'arc (souffle de lame) | 150 Combat Sound Effects | `knife_slice_48kHz_16bit_0.51s_9438a1db_s03.wav` | 0.35 s |
| `bow_2.wav` | tir d'arc (souffle de lame) | 150 Combat Sound Effects | `knife_slice2_48kHz_16bit_0.56s_d1b73212_s03.wav` | 0.35 s |
| `crossbow_1.wav` | tir d'arbalète | 150 Combat Sound Effects | `draw_knife3_48kHz_16bit_0.48s_4353b697_s03.wav` | 0.3 s |
| `crossbow_2.wav` | tir d'arbalète | 150 Combat Sound Effects | `knife_slice2_48kHz_16bit_0.56s_d1b73212_s03.wav` | 0.22 s |
| `magic_1.wav` | tir magique | 150 Combat Sound Effects | `Fire Spell Impact 4_s06.wav` | 1.0 s |
| `magic_2.wav` | tir magique | 150 Combat Sound Effects | `Lightning Spell Impact 3_s06.wav` | 1.0 s |
| `throw_1.wav` | lancer (souffle) | 150 Combat Sound Effects | `Wind Spell Impact 2_s07.wav` | 0.6 s |
| `throw_2.wav` | lancer (souffle) | 150 Combat Sound Effects | `Wind Spell Impact 5_s07.wav` | 0.6 s |
| `gun_1.wav` | arme à feu | 150 Combat Sound Effects | `explosion_crunch_000_48kHz_16bit_0.78s_e875be4e_s04.wav` | 0.35 s |
| `cannon_1.wav` | canon | 150 Combat Sound Effects | `low_frequency_explosion_001_48kHz_16bit_1s_a63b8c61_s04.wav` | 1.0 s |
| `melee_1.wav` | coup de mêlée | 150 Combat Sound Effects | `impact_punch_heavy_001_48kHz_16bit_0.54s_fb104b0a_s02.wav` | 0.5 s |
| `melee_2.wav` | coup de mêlée | 150 Combat Sound Effects | `impact_punch_heavy_002_48kHz_16bit_0.46s_565485a1_s02.wav` | 0.5 s |
| `hit_1.wav` | impact | 150 Combat Sound Effects | `impact_punch_medium_001_48kHz_16bit_0.35s_bfeb7339_s02.wav` | 0.4 s |
| `hit_2.wav` | impact | 150 Combat Sound Effects | `impact_punch_medium_003_48kHz_16bit_0.36s_a434f34d_s02.wav` | 0.4 s |
| `hit_3.wav` | impact | 150 Combat Sound Effects | `impact_punch_medium_004_48kHz_16bit_0.44s_0fa50bbe_s02.wav` | 0.4 s |
| `blast_1.wav` | explosion | 150 Combat Sound Effects | `explosion_crunch_002_48kHz_16bit_1.26s_e0852ce0_s04.wav` | 0.9 s |
| `down_1.ogg`, `down_2.ogg` | élimination d'un ennemi | Kenney Impact Sounds | `impactSoft_medium_000/001.ogg` | — |
| `click_1.ogg`, `buy_1.ogg` | interface (non déclenchés) | Kenney | `click_001.ogg`, `handleCoins.ogg` | — |

## Reste à décider

- Aucun vrai son d'arc (corde) dans les packs : le tir d'arc utilise un souffle de lame.
- Musique : aucune source retenue.
- Sons d'interface et emplacement du réglage de volume (à soumettre au porteur).
