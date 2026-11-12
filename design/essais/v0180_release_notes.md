# Prototype v0.180 — Chapitre 12 : la tempête de sable

Seconde moitié du biome désert et ruines : la nouveauté du biome (CAMP-017), validée dans son principe par le porteur le 11 novembre 2026.

- **Affixe « Tempête de sable »** (réglage de prototype à confirmer) : toutes les 15 s de combat, une rafale de 5 s réduit de 25 % la portée de tous les défenseurs, annoncée 3 s avant. Déterministe, indépendante du pas de temps, enregistrée dans le rapport et rejouable.
- **Dix nouvelles cartes du désert** (missions 111 à 120) à une, deux ou trois entrées, PV ennemis de 210 % à 219 %, 70 PO à la première victoire, aucune XP. Emplacements choisis par simulation avec la tempête active et 51 points de talent ; les deux factions gagnent chaque carte avec leur armée de référence (8 à 29 PV d'avance). Les trajets sont plus longs que ceux du chapitre 11 : la tempête rendait 6 cartes sur 10 impossibles à gagner pour les deux factions avec les trajets courts.
- **Interface** : libellé et infobulle de l'affixe, fiche de mission, anneau de portée réduit pendant la rafale, repère visuel provisoire (liséré d'annonce, voile et traînées de sable) ; format prêt pour l'habillage de Codex (`effect.sandstorm`, animations `warning` et `storm`).
- La borne des PV acceptés passe à 219 %.

Vérification : régression complète 113 suites, 96 856 contrôles Godot, 17 tests Python ; export Windows, 6 essais ciblés et 140 empreintes de sources réussis ; capture du jeu exporté examinée à 17 s de la mission 111 (rafale active : voile et traînées de sable, anneau de portée du défenseur réduit, libellé de l'affixe, 70 PO). Non vérifié en jeu : le ressenti de la tempête à vitesse ×2, l'équilibrage en partie libre, l'habillage (provisoire).
