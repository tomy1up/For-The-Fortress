# Comparer les missions avec Vents contraires

L'outil `prototype/tools/survey_headwinds_campaign.gd` lance des politiques fixes sans charger le profil du joueur. Il produit des résultats de simulation destinés à guider les essais humains.

## Protocole de référence

Une comparaison complète utilise les deux factions, trois graines, trois placements, quatre compositions et trois arbres de talents. Elle tente une amélioration à la deuxième vague et une troisième recrue à partir de cette vague. Les améliorations suivantes commencent à la vague 5. Tous les points issus des premières victoires précédentes sont répartis. Le premier bonus proposé est choisi.

Une défaite est un résultat valide du relevé. Une erreur de règles, de configuration, de conservation de l'or ou de rejeu lorsqu'il est activé interrompt le relevé. Une mission encore indisponible ou sans Vents contraires est refusée avant tout combat.

Le JSON contient les paramètres de comparaison, la version du jeu, les empreintes des sources, les rangs de talents, l'affixe appliqué et la défense réellement recrutée, avec ses emplacements, types, niveaux et spécialisations. Une tentative de renfort peut être refusée faute d'or ou à cause de la limite de deux exemplaires. La défense enregistrée permet de le constater.

## Exemples PowerShell

Depuis le dossier du projet, cette commande compare intégralement les missions 34 et 35 avec la première branche de spécialisation.

```powershell
& 'C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe' --headless --path prototype --script res://tools/survey_headwinds_campaign.gd -- --missions=34,35 '--output=C:/Projet/For the Fortress!/dist/vents-34-35.json'
```

Ajouter `--major-path` donne la priorité aux prérequis et aux talents majeurs dès qu'ils sont accessibles. Les paliers, rangs maximum, exclusions et budget de points restent ceux du jeu. Sans cette option, la répartition suit l'ordre d'accès utilisé dans les premiers panels. `--branch=1` compare la seconde branche de spécialisation des défenseurs.

L'option `--bonus-priority=R-02,R-01,R-08` essaie une préférence fixe entre les bonus. Le premier bonus de cette liste réellement présent dans l'offre est choisi. Si aucun ne figure dans l'offre, le premier bonus proposé est retenu. Les offres et leurs probabilités restent celles du jeu. Le JSON enregistre l'ordre utilisé. Les codes inconnus et les doublons sont refusés. Sans cette option, le premier bonus proposé reste le choix de référence.

Le mode `--smoke` limite la comparaison à une graine, un placement et deux compositions, en conservant les trois arbres et les deux factions. Chaque rapport de ce mode est rejoué et vérifié. Il valide le fonctionnement du protocole, sans remplacer le panel complet d'équilibrage.

```powershell
& 'C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe' --headless --path prototype --script res://tools/survey_headwinds_campaign.gd -- --missions=35 '--output=C:/Projet/For the Fortress!/dist/vents-35-renfort.json' --smoke --major-path --recruit-slot=5 --recruit-family=0 --recruit-wave=3
```

Le renfort de cet exemple tente une recrue supplémentaire de la famille des tireurs de base. La famille 0 correspond à l'archer Alliance ou au lanceur de haches Horde, la famille 1 à l'arbalétrier ou au sapeur, et la famille 2 au mage ou au chaman. Les indices de renfort 0, 1 et 5 sont les emplacements laissés libres par les placements comparés. Ces limites appartiennent à cet outil d'étude.

Utiliser un dossier de destination existant, un chemin absolu et un nouveau nom de fichier permet de conserver les relevés précédents. L'outil remplace le fichier indiqué s'il existe déjà.

## Interprétation

Comparer les résultats à protocole identique. Un panel qui change de recrutement, d'arbre ou de spécialisation répond à une question différente. Une stratégie choisie après exploration peut confirmer la faisabilité, mais son taux de réussite ne décrit pas celui de l'ensemble des joueurs. L'équilibrage de découverte nécessite des parties humaines.
