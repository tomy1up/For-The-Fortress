# Missions 34 et 35 — Ravin et Portes sous le vent

## Périmètre livré en v0.157

Ces deux missions poursuivent le chapitre 4 avec le réglage d'essai de Vents contraires validé par le porteur. Les défenseurs attaquent 10 % moins souvent. Les dégâts périodiques déjà appliqués gardent leur rythme.

| Mission | Carte | Tracé | PV ennemis | Points disponibles avant la première tentative |
| --- | --- | --- | --- | --- |
| 34 | Le Ravin des Ardoises | Un chemin unique | 133 % de la référence | 16 |
| 35 | Les Portes des Ardoises | Deux routes convergentes | 134 % de la référence | 17 |

Les terrains, emplacements et dix vagues reprennent les configurations déjà proposées au chapitre 3. Chaque mission exige la réussite de sa précédente dans la même faction. La forteresse, les 150 or de combat, les défenseurs et les bonus temporaires repartent à neuf.

Chaque première victoire accorde 60 PO et 100 XP. Le rejeu ne redonne pas ces récompenses. PO, XP, talents et parcours restent indépendants par faction. Les statistiques des défenseurs et le dosage du vent restent identiques à la version précédente.

## Comparaisons

Le premier panel utilise trois graines, trois placements, quatre compositions de trois unités et trois arbres de talents, avec la première branche de spécialisation. Tous les points légalement acquis avant la mission sont répartis par ordre d'accès. Le premier bonus proposé est choisi.

| Mission | Alliance | Horde |
| --- | --- | --- |
| 34 | 48 victoires sur 108 | 30 sur 108 |
| 35 | 27 victoires sur 108 | 0 sur 108 |

Les Portes demandent d'examiner d'autres répartitions de talents et compositions. Un panel de la mission 35 qui prépare prioritairement le chemin du talent majeur de chaque arbre obtient 32 victoires Alliance et 4 victoires Horde sur 108 stratégies par faction. La composition Horde avec deux lanceurs de haches et un chaman, dix-sept points dans Fureur de guerre et le talent **Furie des Cendres** réussit les trois graines avec le même placement. Elle termine avec 10, 15 et 12 PV.

Une exploration distincte avec une tentative de quatrième recrutement trouve également huit victoires Horde parmi 648 politiques. Ce panel comprend des recrutements refusés par les règles normales. Les résultats enregistrent désormais la défense réellement présente pour distinguer les intentions des achats effectivement réalisés.

Ces résultats établissent des possibilités avec les ressources accessibles, sans unité de boutique imposée. Ils ne mesurent pas la probabilité de réussite d'un joueur. La difficulté de découverte et la diversité des compositions restent à évaluer en jeu, particulièrement aux Portes côté Horde.

Relevés locaux utilisés dans cette étude

- `dist/slate-missions34-35.json`
- `dist/slate-mission35-major-path.json`
- `dist/slate-mission35-four-units.json`

## Vérification

Le contrôle d'intégration lance et remporte les missions 31–35 dans les deux factions par le parcours normal. Il vérifie les points légaux, les dépenses de combat, les rapports rejouables et le crédit unique des gains. Après chaque victoire, il revient au parcours par le bilan et rejoue la mission 21 pour vérifier la disparition du vent et le retour de la cadence d'origine.

10 207 contrôles Godot ciblés et treize essais Windows réussissent. Les aperçus et les lancements des missions 33–35 sont vérifiés dans le paquet exporté. Les captures ont été inspectées visuellement. Les profils de test sont isolés de celui du joueur.

Un [protocole reproductible](essais/Protocole_vents_contraires.md) complète les essais. Il enregistre paramètres, sources, talents et défense réelle. Trente-six combats supplémentaires ont été produits avec rejeu vérifié des rapports pour valider cet outil, avec et sans tentative de renfort.

## Suite

Trente-cinq missions sont jouables. Les missions 36–40 restent à produire. Le dosage des affixes, leur cumul à long terme et les autres difficultés restent des travaux d'équilibrage et de conception ultérieurs.
