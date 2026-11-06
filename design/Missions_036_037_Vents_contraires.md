# Missions 36 et 37 — Trois Passages et Lacets sous le vent

## Périmètre livré en v0.158

Ces deux missions poursuivent le chapitre 4 avec le réglage d'essai validé de Vents contraires. Tous les défenseurs attaquent 10 % moins souvent. Les dégâts périodiques déjà appliqués gardent leur rythme.

| Mission | Carte | Tracé | PV ennemis | Points disponibles avant la première tentative |
| --- | --- | --- | --- | --- |
| 36 | Les Trois Passages des Ardoises | Trois entrées convergentes | 135 % de la référence | 17 |
| 37 | Les Lacets des Ardoises | Un chemin unique | 136 % de la référence | 18 |

Les terrains et les dix vagues reprennent les configurations du chapitre 3. Les Trois Passages répartissent les apparitions entre les trois entrées à tour de rôle. Les Lacets permettent de comparer les occasions de tir sur leur chemin sinueux. Chaque carte possède six emplacements et une forteresse.

Chaque première victoire donne 60 PO et 100 XP, une seule fois par faction. Réussir la mission précédente débloque la suivante dans la même faction. Les combats repartent avec une forteresse intacte, 150 or de combat, aucun défenseur et aucun bonus temporaire. Les acquis persistants sont conservés.

## Comparaisons reproductibles

Deux panels de 432 simulations comparent la répartition de talents par ordre d'accès et celle qui prépare prioritairement les prérequis des talents majeurs. Les autres paramètres sont identiques, avec trois graines, trois placements, quatre compositions de trois unités et trois arbres de talents pour chaque faction et mission. Tous les points gagnés avant la mission sont répartis et le premier bonus proposé est choisi.

| Mission | Alliance, ordre d'accès | Alliance, chemin majeur | Horde, ordre d'accès | Horde, chemin majeur |
| --- | --- | --- | --- | --- |
| 36 | 31 victoires sur 108 | 32 sur 108 | 10 sur 108 | 12 sur 108 |
| 37 | 24 victoires sur 108 | 27 sur 108 | 3 sur 108 | 10 sur 108 |

Les deux panels trouvent des victoires dans les deux factions. La répartition de talents reste particulièrement sensible côté Horde. Ces résultats décrivent les politiques automatiques essayées. Ils ne constituent pas des probabilités de réussite d'un joueur ni une validation de la difficulté en découverte.

Les relevés locaux `dist/slate-missions36-37-baseline.json` et `dist/slate-missions36-37-major.json` enregistrent les paramètres, les sources, les talents et la défense réellement recrutée. Leur protocole est décrit dans [la procédure de comparaison](essais/Protocole_vents_contraires.md).

## Vérification

Le contrôle d'intégration lance et remporte les missions 31–37 depuis le parcours normal dans les deux factions. Il utilise les points légalement acquis et les revenus de combat, vérifie les rapports rejouables ainsi que le crédit unique des gains, puis revient au parcours par le bilan. Le rejeu de la mission 21 vérifie ensuite la disparition du vent et le retour de la cadence d'origine.

10 517 contrôles Godot ciblés et quatorze essais Windows réussissent. Les essais Windows couvrent les aperçus et lancements des missions 35–37 et les spécialisations à trois entrées dans les deux factions. Les captures du paquet exporté ont été inspectées visuellement, y compris avec des défenseurs installés sur les nouvelles missions. Les profils utilisés sont isolés du profil joueur.

## Suite

Trente-sept missions sont jouables. Les missions 38–40 restent à produire. Le dosage du vent et la difficulté en découverte restent à évaluer en jeu. Le prochain biome des chapitres 5 et 6 reste à préciser. Les cumuls d'affixes et les autres difficultés de campagne restent des travaux ultérieurs.
