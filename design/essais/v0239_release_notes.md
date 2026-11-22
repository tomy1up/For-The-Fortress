# Prototype v0.239 — Chef de guerre vétéran et balistes animés, décor des chapitres 11 à 14

Valeurs de prototype à confirmer en partie réelle.

## Animations (lots de Codex validés par le porteur)

- **Chef de guerre vétéran (type 45)** : lancer de hache (64 images à 60 images par seconde). La hache de 16 px de haut part de la main à 0,40 s (image 24), depuis le repère retourné avec la pose. Elle part inclinée à 48° et fait un tour complet sur un vol rectiligne. Si la cible est derrière la main à l'écran, seul l'impact est joué. Le bonus par vague survivée et son plafond ne changent pas.
- **Balliste royale (type 38)** et **Baliste de guerre (type 43)** : tir et réarmement (36 et 60 images sur 0,96 s), châssis et servant sur un dessin fixe. Le carreau de siège existant part du rail vide à 0,32 s (images 12 et 20), depuis le repère retourné avec la pose, en ligne droite. La Baliste de guerre ne décrit plus l'arc de sa famille. Si la cible est derrière la glissière, seul l'impact est joué. Les multiplicateurs selon l'avancée de la cible (×0,4 dans le premier tiers du trajet, ×1,8 dans le dernier) ne changent pas.

## Décor

- **Décor refait des chapitres 11 à 14** (missions 101 à 140) : les placements de Codex, adaptés aux routes refondues, sont activés pour le désert (101 à 110), la Tempête de sable (111 à 120), les mines (121 à 130) et l'Éboulement (131 à 140). Lots a317885, f438dd5, 23713fc et f2a2d99, validés par le porteur le 22 novembre 2026.
- Le décor refait du chapitre 10 (garnison, missions 91 à 100) est intégré au fichier mais reste inactif en attendant l'avis du porteur. Celui des îles flottantes n'est pas encore intégré.

## Interface

- **Bandeau d'affixe écarté des étiquettes d'entrée** (signalé par le porteur via Codex) : le bandeau garde sa place habituelle, en haut et centré. S'il devait recouvrir une étiquette « Entrée », il glisse d'abord sur le côté, sans passer sous le bloc d'informations en haut à droite (faction, talents, fiche d'ennemi au survol). S'il ne trouve pas de place à sa hauteur, il se met juste au-dessus ou juste au-dessous de l'étiquette. Sur la Tempête de sable (missions 116, 117 et 120) et l'Éboulement (134 et 140), il passe ainsi juste au-dessus de « Entrée 1 ». Le contrôle porte sur toutes les missions à affixe : le bandeau se déplace sur 35 d'entre elles.

## Mesure pour O-028 (aucune décision prise)

- Un joueur avisé, qui juge chaque offre de bonus sans connaître les suivantes, finit vers **84 % de marge (Alliance) et 80 % (Horde)**. Avec la première offre, c'est 55 et 57 %. Avec la voyance, c'est 89 et 91 %.
- Bien juger l'offre du moment donne donc l'essentiel du gain. La Horde dépend davantage du tirage. Détails : `design/Joueur_avise_v0239.md`.

## Contrôles

- Régression complète : 144 suites sur 144, 202 666 contrôles Godot, 17 tests Python. Dont `test_shop_effects.gd` (157 contrôles : hache du Chef de guerre, carreaux des deux balistes) et `test_affix_banner.gd` (325 contrôles : bandeau écarté des étiquettes et du bloc d'informations à droite, sur toutes les missions à affixe).
- Validateur d'animations : 62 dossiers, aucun problème.
- Paquet Windows vérifié : 1 050 cas, 597 sources comparées, empreinte `b30c6c3b…87ce0`.
- Captures inspectées : 54 gestes (types 45, 38 et 43, six emplacements, avant le départ, en vol et à l'impact) ; bandeau d'affixe des missions 116, 120, 134 et 140 dans les deux factions (annonce et rafale) ; décor des 40 cartes des chapitres 11 à 14 dans les deux factions.
- Défaut antérieur relevé, non corrigé dans cette version : en préparation, quand les nombres d'ennemis s'affichent, des étiquettes d'entrée voisines se chevauchent (46 cas sur 38 missions, chapitres 6 à 20).
