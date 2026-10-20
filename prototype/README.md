# Première vague jouable de La Vallée du Gué

**Prototype v0.15 — 20 octobre 2026.** Référence de conception : GDD v0.14. For the Fortress! reste un nom de travail.

Cette version réalise le lot L2 du cahier : préparer une défense Alliance au niveau 1, lancer la première vague et en observer le résultat. Les règles et valeurs de conception sont celles déjà documentées ; aucune nouvelle mécanique n’est ajoutée.

## Jouer localement


Sur ce PC, double-cliquer sur **Lancer_le_prototype.cmd** dans ce dossier. Le moteur officiel portable a été préparé dans C:/Projet/.tools/Godot-4.7.2, en dehors du dépôt Git.

Autre possibilité : ouvrir project.godot dans Godot 4.7.2 standard, puis lancer la scène principale avec F6 ou le projet avec F5. Aucun module externe n’est nécessaire. Sur un autre PC, récupérer [Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/) et ouvrir ce projet. Le lanceur PowerShell accepte aussi -EnginePath avec le chemin du moteur.

## Prise en main

1. Cliquer sur E1 à E6 pour choisir un emplacement.
2. Acheter un Archer elfe (50 or), un Arbalétrier nain (75) ou un Mage humain (100), selon l’or disponible. Deux exemplaires maximum par type.
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

La cible principale est l’ennemi à portée le plus avancé ; à égalité, priorité à l’apparition la plus ancienne. Le mage choisit ses victimes secondaires par distance à l’impact, puis progression et ordre d’apparition. Les impacts sont instantanés ; les traits dessinés ne retardent pas les dégâts.

Les tirs simultanés prennent leurs décisions sur le même état et leurs dégâts sont additionnés. Un mort ne rapporte qu’une seule récompense. Chaque Pillard éliminé donne immédiatement 3 or ; une arrivée retire 1 PV et ne donne aucun or. Il n’y a pas de prime de fin de vague.

La vente rend la partie entière inférieure de 70 % du montant payé pour cet exemplaire : 35, 52 ou 70 or au N1 sans réduction. Elle libère l’emplacement et une place dans le quota. Un nouvel achat crée un nouvel exemplaire N1. Les prix et statistiques conservent leur statut H.

Cet essai N1 exclut les bonus et les synergies, comme le premier test de combat prévu par le GDD. La Horde, les autres ennemis, les niveaux, spécialisations, bonus et synergies seront intégrés dans les lots suivants. La fin de la vague 1 n’est pas la victoire de la partie complète, prévue après la vague 10.

## Vérifications effectuées

Godot 4.7.2.stable.official.ed1daf0bf, GDScript, rendu Compatibility ; 20 octobre 2026.

| Contrôle | Résultat |
| --- | --- |
| Modèle : transactions, quota, ventes, vagues, ciblage, mage, simultanéité et cadence | 87 contrôles réussis, dont 30 comparaisons des couvertures au GDD |
| Interface : achats, remboursements, nombres, inspection, verrouillages, vitesse et relance | 30 contrôles réussis |
| Lancements graphiques et captures | Boutique, combat et fin de vague inspectés |
| Comparaison de chronologie | Identique avec un grand pas de temps, avec des pas à ×1 et avec des pas à ×2 |

Référence reproductible : Archer en E1 + Arbalétrier en E2, sans autre dépense. Départ après achats : 25 or ; dix éliminations, aucune arrivée ; fin à 23,5 s de jeu, 20 PV et 55 or. Ce résultat vérifie ce scénario ; il ne démontre pas l’équilibre de la partie ou des factions.

Les tests peuvent être relancés depuis ce dossier avec le moteur :

~~~powershell
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_valley.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --quit-after 3 --script res://tests/test_interface.gd
~~~

Vérifier le résumé failures=0 et l’absence de messages ERROR, même si le processus rend un code de sortie nul. Les fichiers .godot sont un cache local exclu de Git ; les fichiers .gd.uid sont suivis.

## État et suite

L1 et L2 sont réalisés. L0 reste partiellement réalisé : le projet démarre avec le moteur portable préparé localement, mais l’export Windows autonome reste à produire. Les documents de conception restent en v0.14 ; v0.15 désigne la révision du prototype et du dépôt.

Prochain lot L3 : trois défenseurs de la Horde, autres archétypes et boss, puis vérifications des malédictions et de l’ordre complet des événements. Les dix vagues complètes appartiennent au lot L5. Voir le [cahier de réalisation](../design/Proposition_realisation_prototype.md), le [suivi du prototype](../design/Suivi_prototype.md) et les [choix techniques](../design/Choix_techniques_prototype.md).
