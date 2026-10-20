# Premier essai de La Vallée du Gué

Prototype initial de **For the Fortress!**, nom de travail. Référence : GDD v0.14, lots L0–L1.

## Jouer localement

Sur ce PC, double-cliquer sur **Lancer_le_prototype.cmd** dans ce dossier. Le moteur officiel portable a été préparé dans C:/Projet/.tools/Godot-4.7.2, en dehors du dépôt Git.

Autre possibilité : ouvrir project.godot dans Godot 4.7.2 standard, puis lancer la scène principale avec F6 ou le projet avec F5. Aucun module externe n’est nécessaire. Sur un autre PC, récupérer [Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/) et ouvrir ce projet. Le lanceur PowerShell accepte aussi -EnginePath avec le chemin du moteur.

## Ce que contient cet essai

- Carte 2D isométrique avec route, pont et forteresse ; géométrie logique du GDD conservée.
- Six emplacements E1–E6 sélectionnables pour consulter leurs coordonnées.
- Un Pillard sans défenseurs, lancé à t = 0, se déplaçant à 1 unité par seconde.
- Vitesses ×1 / ×2, compteur de temps et distance parcourue.
- Arrivée après 28 secondes de jeu : forteresse de 20 à 19 PV, aucun gain d’or.
- Bouton Recommencer réinitialisant cet essai ; or conservé à 150 pendant la traversée.

Il s’agit d’une scène de vérification de L1. Elle ne contient pas encore la sélection de faction, les achats, les défenseurs, les attaques ou les dix vagues. Le bouton de relance sert à répéter l’essai ; il ne constitue pas une commande de remise à zéro en combat dans le jeu final.

## Vérifications effectuées le 20 octobre 2026

Godot 4.7.2.stable.official.ed1daf0bf ; GDScript ; rendu Compatibility.

| Contrôle | Résultat |
| --- | --- |
| Modèle : géométrie, virages, arrivée unique, or, vitesses et réinitialisation | 21 contrôles réussis |
| Interface : lancement, vitesse, boucle, inspection E1–E6 et relance | 15 contrôles réussis |
| Lancement graphique et capture à t = 12 s | Réussis ; disposition inspectée |

Les tests peuvent être relancés depuis ce dossier avec le moteur :

~~~powershell
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --script res://tests/test_valley.gd
& 'CHEMIN_DU_MOTEUR_CONSOLE.exe' --headless --path . --script res://tests/test_interface.gd
~~~

Les contrôles ne démontrent pas encore une partie gagnable ou l’équilibre des factions. L’export Windows autonome reste à produire pour terminer L0. Les fichiers .godot sont un cache local exclu de Git ; les fichiers .gd.uid sont suivis.

## Suite

L2 : achats N1 d’une faction, attaques automatiques, récompenses et première vague, avec achats et ventes bloqués pendant le combat. Voir le [cahier de réalisation](../design/Proposition_realisation_prototype.md) et les [choix techniques](../design/Choix_techniques_prototype.md).
