# Rapports multitrajets historiques v0.106

Produits le 1 novembre 2026 avec le paquet publié v0.106 (commit 39646e60ec5fde560a12fe7b6b38f90023051ba3, EXE SHA256 4444704fe447c9747a6c386dc7ac50d1fda8d4f20ab02b4ebdf58c8f9cf12cf6), puis rejoués avec le vérificateur du tag v0.106. Aucun modèle v0.107 utilisé pour leur production.

Carte : `Maps.converging_workshop()`. Graine 106, sélection de faction, achat de deux défenseurs de base aux emplacements 2 et 3 (indices depuis zéro). Avant chaque vague, tentative d’amélioration de chaque défenseur non spécialisé si au moins 50 or disponibles ; branche zéro au passage au niveau 4. Premier bonus proposé choisi, vagues résolues jusqu’à la défaite. Alliance : vague 7, 31 actions, 78 or ; Horde : vague 9, 38 actions, 211 or. Les vagues contiennent plusieurs vitesses d’ennemis et les achats produisent de vrais tirs.

Le champ `route_target_policy` est absent, conformément au format historique. Les tests vérifient que ces deux rapports sont rejouables et que l’imposition de `arrival_time` les rend divergents. Leur contenu ne doit pas être régénéré avec le modèle actuel pour rendre un test vert.

Empreintes des fixtures :

- `alliance.json` : `96e54ed98d06fcdc18c7be7828607a466a4a4e33ea0f0062fd258d7b510d6684`.
- `horde.json` : `f2c52820161a38106a4d58bf214f791ad9870cc48de307e608092dbc0e919537`.
