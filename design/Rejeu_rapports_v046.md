# Rejeu des rapports — v0.46

25 octobre 2026. Outil de débogage réservé au projet source ; aucune fonction de sauvegarde ni nouvelle mécanique de jeu.

## Utilisation

Exporter un rapport depuis le bilan d’une partie terminée, puis utiliser son fichier rapport.json avec Godot console :

```powershell
& 'C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe' --headless --path prototype --script res://tests/replay_run.gd -- '--report=C:/chemin/rapport.json'
```

L’outil ne lance aucune fenêtre et ne réécrit pas le rapport. Il affiche une ligne REPLAY_RESULT au format JSON : succès, version source et actuelle, faction, résultat, vague, or, PV et nombre d’actions. Code de sortie 0 si concordance, 1 si rapport illisible ou divergence, 2 si arguments incorrects.

## Contrôles

Le modèle repart de la graine et de l’état aléatoire exacts, conservés sous forme de textes entiers signés 64 bits. Il applique les seuls types d’action reconnus : faction, achat, amélioration, vente, préparation, lancement et choix de bonus. Fins de vagues et offres sont produites par le modèle puis comparées au journal fourni. Les décisions refusées par les règles actuelles interrompent le rejeu. Aucune instruction ou chemin inscrit dans une action n’est exécuté.

Les dépenses, remboursements, identités de recrues, offres, choix, compositions, relevés des vagues, contributions et résultat sont comparés. Les nombres tolèrent un écart absolu maximal de 10⁻⁷ pour le passage JSON ; les textes et valeurs structurelles doivent concorder. La première divergence identifiée est indiquée par son chemin de champ.

Rapports terminés au format 2 uniquement ; fichier limité à 8 Mio et journal à 4096 actions. Les entrées invalides, fichiers absents et états aléatoires mal formés produisent une erreur explicite. Les métadonnées de version et de moteur ne sont pas des résultats de simulation : elles ne sont pas utilisées comme preuve de concordance.

## Portée et limites

La concordance prouve que ces décisions produisent ces données avec le modèle actuel. Si la version source diffère, l’outil le signale : il ne charge pas l’ancien programme. Il n’authentifie ni le rapport ni son auteur. Il ne rejoue pas les clics, la vitesse, le temps réel ou les préparations ; ces éléments ne figurent pas dans le journal de simulation. Aucun ressenti d’équilibrage ne peut en être déduit. Le rapport n’est pas une sauvegarde reprenable.

Les scripts restent dans tests/ et sont exclus du paquet Windows. Les scénarios de contrôle continuent de pouvoir être exécutés sans l’outil.

## Vérification

**26 suites, 14 213 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **42 contrôles dédiés** couvrent victoires et défaites des deux factions, ventes, branches et bonus, graine 64 bits, lecture sans réécriture, données altérées, achat adverse, action inconnue, champs manquants, JSON invalide et limites d’entrée.

Deux rapports réellement exportés par les scénarios de contrôle du paquet v0.45 ont été relus en ligne de commande : Alliance 14 PV / 192 or, Horde 12 PV / 189 or ; 45 actions chacun. Les empreintes avant/après sont identiques. La différence de version 0.45 vers 0.46 est signalée. Ce sont des essais automatisés et non de nouveaux retours humains. [Relevé](essais/v046_replay_cli.json).

46 lancements du paquet v0.46 réussis sur l’écran de droite, dix sources locales concordantes et capture du bilan Horde inspectée. GDD principal v0.14 ; règles et statistiques conservées. Nom de travail dont la disponibilité juridique reste à confirmer.
