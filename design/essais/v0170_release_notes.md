# Prototype v0.170 — Chapitre 8 : les éruptions

Le chapitre 8 (missions 71 à 80) ouvre la nouveauté du biome volcanique, validée dans son principe par le porteur le 10 novembre 2026 : un affixe qui désactive au hasard l'un des emplacements de défense pendant quelques secondes.

- **Affixe « Éruptions »** (réglage de prototype à confirmer) : toutes les 14 s de combat, un défenseur en place tiré au hasard est désactivé pendant 5 s, avec 2 s d'avertissement. Le tirage est déterministe (graine, vague, numéro d'éruption), indépendant du pas de temps, enregistré dans le rapport et rejouable ; un rapport dont l'affixe est retiré ou altéré est refusé.
- **Dix nouvelles cartes volcaniques** (71 à 80) à une, deux ou trois entrées, avec les rencontres standard, 60 PO et 100 XP à la première victoire et des PV ennemis de 171 % à 179 %. Emplacements choisis par simulation avec les talents réellement accumulés ; les deux factions gagnent chaque carte avec leur armée de référence (la Horde avec 6 PV d'avance seulement sur les missions 73 et 76).
- **Interface** : l'affixe est annoncé dans la fiche de mission (avec une infobulle) et pendant le combat. Le code pose un repère visuel provisoire (losange orange pulsant, puis losange sombre et cendres grises) ; l'habillage définitif, lave ou cendres, est confié à Codex (`TODO_VISUELS.md`).
- Les affixes sont désormais validés champ par champ (Vents contraires et Éruptions) ; la borne des PV ennemis passe à 179 %.

Documentation : `design/Missions_071_080_Eruptions.md`, `design/Biomes_cumul_2026-10-31.md`.

La régression complète réussit : 105 suites, 66 556 contrôles Godot et 17 tests Python (une suite, `test_slate_campaign.gd`, dépasse le délai par défaut sur cette machine et réussit seule avec 1 110 contrôles). 11 essais Windows ciblés et 87 empreintes de sources du paquet réussissent. Non vérifié : l’animation de désactivation en combat (les captures montrent la fiche et le libellé de l’affixe).
