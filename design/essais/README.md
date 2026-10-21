# Données des essais v0.19

22 octobre 2026. Sources de gameplay et GDD inchangés depuis la v0.18.

- `v019_tableaux.md` : lecture des résultats par faction, placement et politique.
- `v019_synthese.json` : agrégations, graines et empreintes SHA-256 des sources et des relevés.
- `v019_releves.json.gz` : JSON UTF-8 compressé, 1 728 parties avec toutes les vagues résolues et les choix. La compression supprime l’horodatage variable pour permettre une reproduction déterministe.

Les descriptions et limites sont dans [le bilan](../Bilan_equilibrage_v019.md). Les pourcentages sont ceux de politiques automatiques sur une matrice, pas ceux de joueurs.

## Lecture des relevés

Un identifiant combine faction, placement, politique, priorité, branches et graine. Faction `0` = Alliance, `1` = Horde. Les emplacements enregistrés vont de 1 à 6 ; les types vont de 0 à 5 dans l’ordre du roster du modèle. Le champ `branch` vaut −1 sans spécialisation, 0 pour A, 1 pour B.

Les indices de bonus vont de 0 à 11 : indice 0 = R-01, indice 11 = R-12. `decisions` conserve chaque offre et le bonus choisi. `deployed`, `paid` et `specialised_links` décrivent la défense au lancement de cette vague. Les champs `hp`, `gold`, `income`, `kills` et `escapes` dans une ligne de vague décrivent sa résolution ; les décisions roguelite interviennent ensuite. Une vague fatale peut se terminer avant l’apparition de tous ses ennemis.

`seconds` est la durée simulée de cette vague. `combat_seconds` est la somme des combats joués, hors préparations et sélections. Le solde terminal vérifie 150 + revenus réels − dépenses historiques, sans vente dans ces politiques.

## Reproduction locale

Depuis le dossier du dépôt, utiliser le moteur et Python disponibles sur ce PC :

~~~powershell
$fortressEngine = 'C:\Projet\.tools\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
$fortressPython = 'C:\Users\Tomy\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $fortressEngine --headless --path prototype --script res://tests/survey_balance.gd -- --output=C:/Projet/.tools/balance_replay.json
& $fortressPython prototype/tests/analyse_balance.py C:/Projet/.tools/balance_replay.json --destination C:/Projet/.tools/balance_replay
~~~

Le relevé initial peut prendre plusieurs minutes. Vérifier le résumé `runs=1728`, `failures=0` et l’absence d’erreur du moteur. L’analyse exige les 1 728 identifiants uniques, les douze graines prévues, des fins de partie valides, des offres distinctes et la conservation terminale de l’or. Aucun paquet Python externe n’est requis.

Pour relire l’archive existante sans rejouer les parties :

~~~powershell
& $fortressPython prototype/tests/analyse_balance.py design/essais/v019_releves.json.gz --destination C:/Projet/.tools/balance_relecture
~~~

Les empreintes supposent les mêmes octets des sources : une conversion locale des fins de ligne peut les modifier sans changer le comportement. Les résultats déterministes supposent la même version de Godot et le même algorithme de tirage. Les commandes écrivent dans des dossiers de travail séparés, pour permettre une comparaison avant remplacement des données versionnées.
