# Prototype v0.258 — Héroïque : les champions mutants

Lot 2 du cadrage des difficultés. Liste des traits et valeurs validées par le porteur le 25 novembre 2026 ; réglages de prototype à confirmer en jeu.

## Ce qui change

- En **Héroïque**, chaque vague a **un champion à partir de la vague 3** : un ennemi ordinaire avec 50 % de PV en plus, qui rapporte le double d'or et porte un **trait**.
- **Douze traits**, introduits au fil de la campagne : Hâte et Bouclier au chapitre 1, puis un nouveau par chapitre (Régénération, Colosse, Scission, Blindé, Soigneur, Vengeur, Insensible, Galvanisant, Pillard, Revenant). Du chapitre 16 au chapitre 20, les champions des vagues 7 à 10 en portent deux.
- **Repère** : une aura colorée au sol et une pastille par trait à côté de la jauge de PV (dessins provisoires, en attendant les icônes de Codex). Le Colosse est plus grand.
- **Inspection** : cliquer un champion affiche ses traits, et leur règle au survol. En Héroïque, l'infobulle d'une mission liste les traits possibles du chapitre.
- Le Normal ne change pas.

**Attention :** l'Héroïque n'est pas encore calibré. Avec la hausse provisoire et uniforme de 30 % des PV ennemis, il est plus facile que le Normal aux premiers chapitres (vos 51 points de talent comptent), puis presque impossible à partir du chapitre 7 pour l'Alliance et du chapitre 11 pour la Horde. Le calibrage mission par mission est un prochain lot.

Fiche : `design/Champions_mutants_v0258.md`.

## Contrôles

- Régression complète : 152 suites sur 152, 250 120 contrôles Godot, 17 tests Python (nouvelle suite `test_champions.gd`, 190 contrôles).
- Paquet Windows vérifié : 1 050 cas et 671 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures inspectées, depuis les sources et le jeu exporté : champions en Héroïque dans les deux factions (Bouclier, Hâte), aura, pastille et anneau de bouclier visibles.
- Mesure de l'Héroïque (PV seuls, PV et champions, joueur avisé) : voir la fiche.
