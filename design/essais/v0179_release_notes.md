# Prototype v0.179 — Chapitre 11 : désert et ruines

Suite du cadrage des missions 101 à 200 (`design/Cadrage_missions_101_200.md`), décisions du porteur du 11 novembre 2026 : un biome couvre deux chapitres, avec une seule nouveauté dans le second ; le sixième biome est **désert et ruines**.

- **Chapitre 11 (missions 101 à 110)** : dix cartes du désert à une, deux ou trois entrées, rencontres standard du Gué, sans règle propre (la tempête de sable arrive au chapitre 12). PV ennemis de 200 % à 209 %. Emplacements choisis par simulation avec 51 points de talent ; les deux factions gagnent chaque carte avec leur armée de référence (8 à 29 PV d'avance). Les tracés des chapitres précédents, repris tels quels, étaient trop faciles à ce niveau de talents : les trajets sont plus courts.
- **Gains après la mission 100** : 65 PO à la première victoire et aucune XP (les points de talent s'arrêtent à la mission 100). Les fiches de mission et le bilan n'affichent plus d'XP quand elle est nulle.
- **Décor `desert`** : palette d'essai de sable ; habillage à produire par Codex.
- **Livraisons de Codex fusionnées** : animations du mage humain, de l'arbalétrier nain, lancer de hache du troll avec rebond, filtrage du capitaine humain.
- Nouveau fichier d'exécution `scripts/desert_maps.gd`, déclaré dans les trois listes d'export. La borne des PV acceptés passe à 209 %.

Vérification : régression complète 111 suites, 91 737 contrôles Godot, 17 tests Python ; export Windows, 6 essais ciblés et 140 empreintes de sources réussis ; capture de la mission 101 examinée (palette de sable, « Première victoire : 65 PO » sans XP). Non vérifié en jeu : l'équilibrage ressenti, l'habillage (provisoire).
