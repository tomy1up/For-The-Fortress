# Sources de compilation — v0.45

25 octobre 2026. Travail sur la fabrication des versions Windows ; comportement de jeu conservé.

## Risque traité

L’export précédent calculait les empreintes sources après compilation. Une modification persistante pendant cette compilation pouvait donc être attribuée à un exécutable produit auparavant. Aucun incident joueur de ce type n’est rapporté ; il s’agit d’un défaut de traçabilité identifié dans l’outil.

## Vérifications ajoutées

L’export relève les empreintes SHA-256 de dix fichiers avant de lancer Godot : projet, préréglage d’export, scène et sept scripts de jeu. Il confirme aussi la version demandée juste avant compilation. Le relevé est comparé après export, puis avant compression ; une différence ou un fichier manquant interrompt la fabrication, sans annoncer de ZIP prêt. Le manifeste contient le relevé initial. Relancer dans un dossier de sortie neuf après correction.

Les chemins fournis au relevé doivent rester dans le projet et être distincts. Les tests couvrent les fichiers stables, les modifications, la disparition, un chemin sortant et un doublon. Les échecs attendus vérifient leur cause précise, et pas seulement un code d’erreur.

Le vérificateur Windows contrôle la liste de dix sources et le format des empreintes. Avec `--source-project`, il compare aussi ces fichiers à une copie locale, avant de lancer le paquet. Sans cette option, il contrôle la structure du manifeste sans prétendre avoir comparé des fichiers absents. La validation de sources utilise des exceptions explicites, y compris avec Python optimisé.

Exemple depuis la racine du dépôt :

```powershell
python prototype/tests/verify_windows_export.py dist/For_the_Fortress_v0.45_Windows_x64.zip --destination C:/Projet/.tools/controle_v045 --source-project prototype --screen 1
```

## Limites et résultats

Les comparaisons portent sur ces dix fichiers et sur leur état aux points de contrôle. Elles ne verrouillent pas l’éditeur et ne peuvent détecter une modification puis restauration complète entre deux relevés. Elles ne constituent ni une signature d’éditeur ni une preuve d’authenticité du manifeste. Les autres ressources et documents ne sont pas couverts par cette liste.

25 suites et **14 171 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les six tests Python ajoutés vérifient les relevés PowerShell utilisés par l’exporteur et la comparaison des sources du paquet, avec copies stables, modifiées, manquantes ou manifestes invalides. Le lanceur de régression surveille désormais aussi les scripts de fabrication et le préréglage d’export. Les essais sont lancés avec le PowerShell disponible, sans changer la politique d’exécution du PC.

Le compte rendu du paquet figure dans Distribution_Windows_v045.json. Les règles, statistiques, factions et bonus restent ceux de la v0.44. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

46 lancements Windows réussis sur l’écran de droite, dix empreintes locales concordantes. Capture du décompte inspectée, version v0.45 lisible. Aucun nouveau résultat humain d’équilibrage.
