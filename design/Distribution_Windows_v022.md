# Distribution Windows autonome — v0.22

23 octobre 2026 · Godot 4.7.2.stable.official.ed1daf0bf · GDD v0.14.

Le prototype dispose d’un export release Windows x86_64, lançable sans installation de Godot ni connexion réseau. Le dossier local est `dist/For_the_Fortress_v0.22_Windows_x64` à la racine du dépôt. Le [ZIP de test et son empreinte](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.22) accompagnent la version GitHub du dépôt privé.

## Jouer

Extraire tout le ZIP, puis ouvrir le dossier et lancer **For_the_Fortress.exe**. La notice LIRE_MOI.txt et la fiche d’essai accompagnent le jeu. Le prototype est non signé ; il ne s’agit pas d’un installateur. Cette livraison cible Windows 64 bits sur processeur Intel/AMD et conserve les visuels temporaires.

L’exécutable contient les données du jeu ; aucun fichier PCK séparé n’est requis. La distribution comporte exactement cinq fichiers :

| Fichier | Utilité |
| --- | --- |
| For_the_Fortress.exe | Jeu et données intégrées |
| LIRE_MOI.txt | Démarrage et commandes |
| Fiche_essai_joueur.md | Relevé facultatif des retours |
| LICENCES_GODOT.txt | Licence du moteur et notices de composants |
| VERSION.json | Version, architecture et empreintes de sources/EXE |

La v0.22 ajoute le décompte de 60 secondes après le premier départ manuel, conformément à la [décision validée](Decision_enchainement_v022.md). Les choix d’amélioration attendent le joueur ; les nombres de combat sont conservés. Le GDD principal reste en v0.14, complété par cette décision.

## Production

Les [templates officiels Godot 4.7.2 standard](https://godotengine.org/download/archive/4.7.2-stable/) ont été téléchargés. Le SHA-512 du TPZ complet a été vérifié contre SHA512-SUMS.txt de la même publication officielle, puis les fichiers Windows x86_64 ont été installés dans le profil Godot local.

Le preset Windows sélectionne explicitement la scène principale et les cinq scripts runtime. Un premier export avec sélection de scène seule a été rejeté au lancement isolé, car les scripts préchargés n’étaient pas tous présents. Le paquet livré utilise la sélection explicite corrigée. Les tests, scripts d’analyse et documents de développement restent exclus du paquet runtime.

Le [script de reconstruction](../prototype/Exporter_Windows.ps1) exige le moteur exact, les templates correspondants et une version cohérente avec project.godot. Il génère les notices depuis les méthodes Engine, exporte en release, intègre le PCK dans l’EXE, copie les documents et produit le ZIP et son SHA-256. Une archive existante n’est pas remplacée silencieusement.

Les notices jointes proviennent du moteur de cette version et peuvent contenir des composants supplémentaires propres à l’éditeur. Cette méthode suit les possibilités décrites dans la [documentation Godot sur les licences](https://docs.godotengine.org/en/4.7/about/complying_with_licenses.html). Le choix d’un binaire optimisé avec données intégrées utilise le [système d’export Windows](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_windows.html).

## Vérification du paquet livré

Le ZIP a été extrait dans un dossier de contrôle distinct du projet, sans project.godot ni moteur d’édition à côté de l’exécutable. Le vérificateur contrôle les chemins ZIP, les cinq fichiers, le manifeste, le SHA-256 de l’EXE et son architecture PE AMD64, puis lance le binaire extrait.

| Contrôle | Résultat |
| --- | --- |
| Démarrage headless, trois images puis fermeture | Code 0, aucune erreur de script |
| Choix de faction | Capture 1280×800 produite et inspectée |
| Décompte après vague 1 | 60 s affichées, capture produite et inspectée |
| Offre roguelite après vague 3 | Capture produite et inspectée |
| Campagne Alliance de référence, graine 42 | Victoire, 14 PV, 192 or, 178 éliminations et 4 arrivées |
| Campagne Horde de référence, graine 42 | Victoire, 12 PV, 189 or, 175 éliminations et 7 arrivées |
| Contrôles de régression du projet | 1 075 réussis (dont 106 sur le décompte) |

Les cinq captures proviennent du binaire exporté ; elles ont été vues séparément du contrôle automatique de présence et de dimensions. Les six lancements rendent zéro sans message ERROR ni SCRIPT ERROR. Un code de sortie nul seul ne suffit pas : le premier export incomplet rendait aussi zéro mais ses erreurs ont été détectées et le paquet rejeté.

L’essai a été fait sur le PC Windows actuel avec rendu OpenGL Compatibility, GPU NVIDIA GeForce RTX 3080. Il ne qualifie pas les performances ou la compatibilité d’autres machines. Les campagnes de référence sont des parcours automatiques, pas des observations de joueurs humains.

## Empreintes du paquet vérifié

ZIP : **39 337 600 octets**, environ 39 Mo.

SHA-256 du ZIP :

~~~text
fdb2e9b97f474a381939d11119f469e116253ec9d64e2078db25bbe215421ed5
~~~

SHA-256 de l’EXE :

~~~text
e48aa145b6cae8f313b3ca8b5ef7cd6920c47b1bbdee04b872d45ef46022f8d8
~~~

Le [relevé structuré](Distribution_Windows_v022.json) conserve aussi les sources et l’empreinte officielle des templates. VERSION.json permet de vérifier l’EXE extrait. Les fichiers générés de dist sont exclus de Git ; les paramètres, outils, notices et résultats sont versionnés. Le ZIP et son fichier SHA-256 sont joints à la version de test GitHub.

## Reproduction et suite

Depuis la racine du dépôt, avec Godot et ses templates installés :

~~~powershell
& ./prototype/Exporter_Windows.ps1
python prototype/tests/verify_windows_export.py dist/For_the_Fortress_v0.22_Windows_x64.zip --destination C:/Projet/.tools/controle_export
~~~

Exporter_Windows.ps1 accepte -EnginePath et -OutputRoot. Pour répéter un export sans remplacer une archive, choisir un autre OutputRoot. Le vérificateur exige Windows et un environnement graphique pour les captures. Les empreintes des sources supposent les mêmes octets, notamment les fins de ligne ; le ZIP n’est pas présenté comme un build bit à bit reproductible.

L0 est réalisé pour ce prototype Windows x86_64. L6 reste partiel : il faut recueillir compréhension, choix et durées réelles avec la fiche d’essai. Aucune signature, autre architecture ou publication Steam n’est engagée. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.
