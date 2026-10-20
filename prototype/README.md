# Deux factions jouables sur La Vallée du Gué

**Prototype v0.16 — 20 octobre 2026.** Référence de conception : GDD v0.14. For the Fortress! reste un nom de travail.

Cette version réalise le combat N1 du lot L3 : choisir Alliance ou Horde, préparer sa défense et jouer la première vague. Les huit profils ennemis sont également intégrés au modèle et vérifiés en situations contrôlées. Les règles et valeurs de conception sont celles déjà documentées ; aucune nouvelle mécanique n’est ajoutée.

## Jouer localement


Sur ce PC, double-cliquer sur **Lancer_le_prototype.cmd** dans ce dossier. Le moteur officiel portable a été préparé dans C:/Projet/.tools/Godot-4.7.2, en dehors du dépôt Git.

Autre possibilité : ouvrir project.godot dans Godot 4.7.2 standard, puis lancer la scène principale avec F6 ou le projet avec F5. Aucun module externe n’est nécessaire. Sur un autre PC, récupérer [Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/) et ouvrir ce projet. Le lanceur PowerShell accepte aussi -EnginePath avec le chemin du moteur.

## Prise en main

1. Choisir Alliance des Royaumes ou Horde des Cendres. La faction reste fixe pendant cet essai.
2. Cliquer sur E1 à E6, puis acheter un défenseur de sa faction : 50, 75 ou 100 or. Deux exemplaires maximum par type.
3. Cliquer sur une unité pour lire ses statistiques, afficher sa portée et consulter son remboursement avant une vente.
4. Lancer la vague 1 : dix Pillards de 40 PV, apparitions à t = 0 puis toutes les 2,5 s. Les tirs sont automatiques.
5. Observer les éliminations, l’or et les arrivées ; changer la vitesse entre ×1 et ×2 si souhaité.
6. Après la fin, revoir sa défense ou utiliser Nouvel essai pour repartir avec 150 or et 20 PV.

Les achats, ventes et la relance d’un essai sont bloqués pendant le combat. Le bouton de lancement ne répète pas la vague une fois terminée. La vague 2 n’est pas encore disponible.

## Règles implémentées

| Défenseur N1 | Achat | Dégâts principaux | Intervalle | Portée | Effet secondaire |
| --- | --- | --- | --- | --- | --- |
| Archer elfe | 50 | 8 | 1 s | 4 | Aucun |
| Arbalétrier nain | 75 | 24 | 2,5 s | 5 | Aucun |
| Mage humain | 100 | 27 | 2,5 s | 3,5 | 10,8 dégâts à deux autres ennemis au maximum, à moins de 1 unité de l’impact |
| Lanceur de haches troll | 50 | 16 | 2 s | 3,5 | Un rebond de 8 dégâts sur une autre victime à moins de 1 unité |
| Sapeur gobelin | 75 | 24 | 2,5 s | 3 | 9,6 dégâts à trois autres ennemis au maximum, à moins de 1 unité de l’impact |
| Chaman orc | 100 | 12 | 2 s | 4,5 | Malédiction de 4,8 dégâts à +1 s puis +2 s |

La cible principale est l’ennemi à portée le plus avancé ; à égalité, priorité à l’apparition la plus ancienne. Le mage, le troll et le sapeur choisissent leurs victimes secondaires par distance à l’impact, puis progression et ordre d’apparition. Les impacts sont instantanés ; les traits dessinés ne retardent pas les dégâts.

Les tirs simultanés prennent leurs décisions sur le même état et leurs dégâts sont additionnés. Un mort ne rapporte qu’une seule récompense. Chaque Pillard éliminé donne immédiatement 3 or ; une arrivée retire 1 PV et ne donne aucun or. Il n’y a pas de prime de fin de vague.

La vente rend la partie entière inférieure de 70 % du montant payé pour cet exemplaire : 35, 52 ou 70 or au N1 sans réduction. Elle libère l’emplacement et une place dans le quota. Un nouvel achat crée un nouvel exemplaire N1. Les prix et statistiques conservent leur statut H.

Les malédictions continuent hors portée, restent indépendantes entre chamans et se renouvellent sans se cumuler pour un même couple source–cible. Les anciens ticks sont résolus avant les nouveaux tirs, puis viennent les dégâts d’arrivée. Mort et arrivée annulent les ticks futurs.

Cet essai N1 exclut les bonus et les synergies, comme le premier test de combat prévu par le GDD. Les niveaux, spécialisations et vagues suivantes seront intégrés dans les lots suivants. La fin de la vague 1 n’est pas la victoire de la partie complète, prévue après la vague 10.

## Profils ennemis intégrés

Grouillant, Pillard, Sprinter, Brute, Maraudeur, Colosse, Élite et Seigneur de siège utilisent les PV, vitesses, dégâts et récompenses du GDD. Chacun est vérifié par des essais de traversée, d’arrivée et d’élimination. Le boss inflige 20 dégâts à l’arrivée et donne 40 or s’il est éliminé.

La partie accessible depuis les boutons reste la vague 1 de dix Pillards. Les sept autres profils sont prêts pour les vagues suivantes ; les scénarios de vérification ne sont pas des nouvelles compositions de vagues approuvées.

## Vérifications effectuées

Godot 4.7.2.stable.official.ed1daf0bf, GDScript, rendu Compatibility ; 20 octobre 2026.

| Contrôle | Résultat |
| --- | --- |
| Modèle : transactions, quota, ventes, vagues, ciblage, mage, simultanéité et cadence | 87 contrôles réussis, dont 30 comparaisons des couvertures au GDD |
| Interface : faction, boutique, descriptions, verrouillages, vitesse et relance | 37 contrôles réussis |
| Horde et ennemis : effets, huit profils, chronologie et cas du GDD | 75 contrôles réussis |
| Lancements graphiques et captures | Choix de faction, boutiques, combat, chaman et catalogue ennemi inspectés |
| Comparaison de chronologie | Identique avec un grand pas, à ×1 et à ×2, y compris dans un essai mêlant huit profils et les trois défenseurs Horde |

Références reproductibles, sans bonus ni synergies : Archer en E1 + Arbalétrier en E2, fin à 23,5 s ; Troll en E1 + Sapeur en E2, fin à 24,5 s. Dans chaque essai : départ après achats à 25 or, dix éliminations, aucune arrivée, 20 PV et 55 or restants. Ce résultat vérifie ce scénario ; il ne démontre pas l’équilibre de la partie ou des factions.

Les tests peuvent être relancés depuis ce dossier avec le moteur :

~~~powershell
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_valley.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_interface.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_horde.gd
~~~

Vérifier le résumé failures=0 et l’absence de messages ERROR, même si le processus rend un code de sortie nul. Les fichiers .godot sont un cache local exclu de Git ; les fichiers .gd.uid sont suivis.

## État et suite

L1, L2 et le combat N1 de L3 sont réalisés. L0 reste partiellement réalisé : le projet démarre avec le moteur portable préparé localement, mais l’export Windows autonome reste à produire. Les documents de conception restent en v0.14 ; v0.16 désigne la révision du prototype et du dépôt.

Prochain lot L4 : progression N1 à N4 et douze spécialisations, avec leurs coûts et remboursements. Les dix vagues complètes appartiennent au lot L5. Voir le [cahier de réalisation](../design/Proposition_realisation_prototype.md), le [suivi du prototype](../design/Suivi_prototype.md) et les [choix techniques](../design/Choix_techniques_prototype.md).
