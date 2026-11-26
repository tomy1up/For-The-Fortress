# Champions mutants de l'Héroïque (v0.258)

**Statut.** Lot 2 du cadrage du 25 novembre 2026 (`Cadrage_Heroique_Mythique_2026-11-25.md`). La liste des douze traits et leurs valeurs ont été validées par le porteur le 25 novembre 2026 (« Tout valider », sur la proposition de Claude Code). Ce sont des réglages de prototype à confirmer en jeu. L'aura et les pastilles des traits sont dessinées par le code, en attendant les icônes de Codex (`TODO_VISUELS.md`).

## Règles

- **En Héroïque seulement** (et plus tard en Mythique). Le Normal ne change pas.
- **Un champion par vague à partir de la vague 3**, soit huit par mission. C'est un ennemi ordinaire de la vague (loup, fantassin ou guerrier, sanglier, ours, éclaireur, brise-remparts ou colosse troll : profils 0 à 5), jamais le boss, un garde, un capitaine ou un attaquant de biome.
- Le champion a **50 % de PV en plus** et rapporte **le double d'or**. Il porte un trait tiré au hasard parmi ceux que le chapitre a débloqués.
- **Du chapitre 16 au chapitre 20**, les champions des vagues 7 à 10 portent **deux traits** différents.

### Les douze traits, un nouveau par chapitre

| Chapitre | Trait | Effet |
| --- | --- | --- |
| 1 | **Hâte** | se déplace 35 % plus vite |
| 1 | **Bouclier** | bouclier de 30 % de ses PV, qui absorbe les dégâts en premier |
| 2 | **Régénération** | regagne 3 % de ses PV par seconde s'il n'est pas touché pendant 2 s |
| 3 | **Colosse** | PV doublés au lieu de +50 %, 30 % plus grand, 15 % plus lent |
| 4 | **Scission** | à sa mort, se divise en deux petits ennemis qui ont chacun 25 % de ses PV |
| 5 | **Blindé** | subit 30 % de dégâts en moins des tirs directs ; les dégâts secondaires (éclats, zones) et les malédictions passent normalement |
| 6 | **Soigneur** | soigne les ennemis proches (1,5 case) de 2 % de leurs PV par seconde |
| 7 | **Vengeur** | à sa mort, les ennemis proches (2 cases) gagnent 25 % de vitesse pendant 3 s |
| 8 | **Insensible** | ignore les ralentissements et les marques |
| 9 | **Galvanisant** | les ennemis proches (1,5 case) avancent 15 % plus vite tant qu'il vit |
| 10 | **Pillard** | double les dégâts qu'il inflige à la forteresse |
| 11 | **Revenant** | se relève une fois avec 40 % de ses PV |

Du chapitre 11 au chapitre 15, les douze traits peuvent sortir. Le cadrage parlait de « jusqu'au chapitre 12 » ; la liste validée en compte douze, deux au chapitre 1 puis un par chapitre, donc tous sont là au chapitre 11.

## Dans le jeu

- **Repère** : une ellipse colorée au sol, qui pulse, de la couleur du premier trait (liseré de la couleur du second s'il y en a deux), et une pastille par trait à gauche de la jauge de PV, avec sa lettre (H, B, R, C, S, A, +, V, I, G, P, †). Le Colosse est dessiné 30 % plus grand. La jauge du bouclier se lit sur 30 % des PV.
- **Inspection** : le nom de l'ennemi porte « · CHAMPION », la ligne d'état liste ses traits, et la règle de chaque trait s'affiche au survol.
- **Écran de campagne** : en Héroïque, l'infobulle de la mission rappelle la règle des champions et les traits possibles dans ce chapitre.

## Technique

- `prototype/scripts/champions.gd` : catalogue des traits (`TRAITS`, `NAMES`, `RULES`, `COLORS`, `GLYPHS`), valeurs, `traits_for(chapter)`, `trait_count(chapter, wave)` et `plan(schedule, wave, chapter, seed)`.
- **Tirage** : `plan` utilise son propre générateur, initialisé par la graine de la partie, la vague et le chapitre. Le champion ne consomme donc aucun tirage du générateur de la partie : les offres de bonus d'une partie héroïque sont les mêmes qu'avec des PV seuls.
- **Combat** (`valley_model.gd`) : `configure_champions(chapter)` (0 à 20, 0 hors Héroïque), `champion_plan_for_wave()`, `_make_champion` à l'apparition, `_champion_pulses` pour la régénération, le soin et l'élan (une impulsion par seconde, intégrée au moteur à événements), `_champion_death` pour la scission et le Vengeur, relève du Revenant. Le bouclier reprend celui du Cor d'alarme, la scission celle du Golem de magma, l'élan celui de la Charge.
- **Rapport** : champ `champion_chapter` (rejeu refusé avant la v0.258). Retirer ou changer ce champ rend le rapport incohérent au rejeu.
- **Captures** : option `--capture-seed=N` (graine fixe de la partie) pour retrouver un champion au même moment.
- **Outil d'étude** : `tools/faction_study.gd` accepte `HEROIC=hp` (PV de l'Héroïque seuls) et `HEROIC=1` (PV et champions), avec les 51 points de talent d'un joueur qui a fini les 100 premières missions.
- Tests : `prototype/tests/test_champions.gd` (catalogue, tirage, douze traits, impulsions, mort, partie complète à petits et grands pas, rejeu).

## Mesure : effet sur la difficulté de l'Héroïque

Meilleure des 30 compositions, 40 missions (une sur cinq), tirages 7, 8 et 9, 51 points de talent. Marge = PV de forteresse restants en fin de mission. Cible du Normal : 40 à 70 %. Fichiers : `design/essais/equilibre_bonus/v258/`.

Les trois premières colonnes suivent la règle de mesure du Normal : chaque composition prend toujours la première offre de bonus. La dernière colonne joue en joueur avisé : bonus choisis d'après leur valeur mesurée, avec relance (`POLICY=refwise`). C'est la cible prévue pour l'Héroïque au cadrage (40 à 70 %), qui reste à confirmer au lot 5.

**Alliance** (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Normal (v0.256) | Héroïque, PV seuls | Héroïque, PV et champions | Idem, joueur avisé |
| --- | --- | --- | --- | --- |
| 1 | 64 % | 98 % | 93 % | 99 % |
| 2 | 45 % | 92 % | 85 % | 94 % |
| 3 | 56 % | 87 % | 77 % | 90 % |
| 4 | 69 % | 81 % | 61 % | 78 % |
| 5 | 60 % | 46 % | 39 % | 73 % |
| 6 | 67 % | 37 % | 29 % | 57 % |
| 7 | 54 % | 10 % | 11 % | 12 % |
| 8 | 54 % | 0 % | 0 % | 5 % |
| 9 | 62 % | 0 % | 0 % | 0 % |
| 10 | 60 % | 0 % | 0 % | 5 % |
| 11 à 15 | 59 % | 0 % | 0 % | 1 % |
| 16 à 20 | 59 % | 0 % | 0 % | 0 % |

**Horde** (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Normal (v0.256) | Héroïque, PV seuls | Héroïque, PV et champions | Idem, joueur avisé |
| --- | --- | --- | --- | --- |
| 1 | 71 % | 100 % | 100 % | 100 % |
| 2 | 57 % | 100 % | 95 % | 100 % |
| 3 | 57 % | 98 % | 91 % | 98 % |
| 4 | 62 % | 99 % | 90 % | 99 % |
| 5 | 46 % | 70 % | 61 % | 92 % |
| 6 | 49 % | 78 % | 69 % | 94 % |
| 7 | 57 % | 60 % | 51 % | 81 % |
| 8 | 60 % | 28 % | 25 % | 62 % |
| 9 | 53 % | 5 % | 2 % | 45 % |
| 10 | 52 % | 18 % | 13 % | 42 % |
| 11 à 15 | 50 % | 0 % | 0 % | 5 % |
| 16 à 20 | 50 % | 0 % | 0 % | 1 % |

**Ce qu'on en retient :**
- **Les champions coûtent de 3 à 20 points de marge, environ 8 en moyenne**, là où la mission reste jouable (première offre ; 20 points au chapitre 4 de l'Alliance). Ils n'ajoutent aucune défaite totale côté Alliance et une seule côté Horde sur les 40 missions.
- **La hausse uniforme de 30 % des PV ne convient pas.** Au début de la campagne, l'Héroïque est plus facile que le Normal (77 à 100 % de marge avec les champions aux chapitres 1 à 3 de l'Alliance et 1 à 4 de la Horde), parce que le joueur y arrive avec ses 51 points de talent. À partir du chapitre 7 pour l'Alliance et du chapitre 11 pour la Horde, la marge tombe presque à zéro, même en joueur avisé : la plupart de ces missions sont perdues par toutes les compositions.
- En joueur avisé, 3 missions sur 40 sont dans la cible côté Alliance et 4 sur 40 côté Horde ; 23 et 15 missions sont perdues par toutes les compositions.
- Le calibrage mission par mission (lot 5) doit donc relever les PV du début de campagne et baisser fortement ceux de la seconde moitié.

## Limites

- **L'Héroïque n'est pas encore calibré.** La hausse provisoire de 30 % des PV (v0.257) rend une grande partie de la campagne impossible à finir, même pour un joueur avisé (voir la mesure). Le calibrage mission par mission est le lot 5.
- Les traits n'ont pas été essayés en jeu par le porteur : leurs valeurs restent à confirmer.
- Les pastilles et l'aura sont provisoires ; dans une meute serrée, l'aura d'un champion peut se perdre.
- Le Mythique n'est pas encore jouable ; il reprendra les champions (à confirmer au lot 6).
