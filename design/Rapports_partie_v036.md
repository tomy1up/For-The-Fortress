# Rapports de partie — prototype v0.36

24 octobre 2026. Outil de débogage dans le périmètre des essais du prototype. Les valeurs de combat et les décisions du GDD v0.14 restent inchangées.

## Utilisation

Après une victoire ou une défaite, ouvrir **Bilan**, puis **Exporter le rapport**. Le jeu écrit `rapport.md` et `rapport.json` dans un nouveau sous-dossier de son répertoire utilisateur Godot, sous `rapports`. Le bouton devient **Ouvrir le dossier du rapport**. Le chemin complet est aussi disponible au survol du message de succès. Une erreur d’écriture est signalée sans annoncer de succès.

L’export est volontaire et local. Aucun envoi réseau. Les rapports ne sont pas intégrés aux archives distribuées ni au dépôt. Les fichiers restent sur le PC après fermeture du jeu ; un nouvel essai efface le journal en mémoire et rétablit le bouton d’export.

## Contenu

- Version du jeu, version du moteur, faction, issue, ressources et défense finale.
- Bilan de chaque vague réellement jouée, avec composition et bonus au départ.
- Ordre des achats, améliorations, spécialisations, ventes et lancements ; coûts effectifs et ressources après l’action.
- Trois bonus proposés à chaque choix, bonus retenu et descriptions adaptées à la faction pour les bonus acquis.
- État initial du générateur aléatoire et états avant/après les offres. Ces entiers de 64 bits sont sérialisés comme textes pour éviter la perte de précision JSON.
- Temps de combat simulé ; les délais réels de préparation, déplacements du curseur et variations de vitesse ne sont pas enregistrés.

Le fichier Markdown sert à la lecture ; le JSON conserve les détails de diagnostic. Les identifiants d’unités distinguent une recrue revendue d’une nouvelle recrue au même emplacement. Seules les commandes acceptées par le modèle sont inscrites.

## Limites

Il ne s’agit pas d’une sauvegarde rechargeable. Aucune interface de reprise ou d’import n’est ajoutée. Le rejeu est vérifié dans les tests du modèle sur les deux factions après un aller-retour JSON ; il ne garantit pas une reproduction de l’affichage ou du temps réel. Des versions différentes du moteur ou des règles peuvent modifier les résultats. Les offres et la composition sont conservées pour pouvoir examiner un problème sans cette garantie.

Un problème de disque peut laisser un dossier incomplet ; l’interface le signale. Les rapports n’ajoutent ni information de compte, ni adresse réseau, ni nom d’utilisateur. Le chemin local est affiché uniquement dans l’interface pour retrouver les fichiers.

## Vérification

12 717 contrôles automatisés réussis, dont 139 ciblés sur le journal et les rapports. Ils couvrent notamment le rejeu des décisions, les offres, l’économie, les entiers de 64 bits, l’absence de mutation et de tirage pendant l’export, la séparation des factions, les exports distincts, le refus avant la fin et un chemin occupé par un fichier.

38 lancements du paquet Windows contrôlés, dont deux exports de campagnes victorieuses financées normalement. Les rapports générés sont relus depuis le disque et leurs dix vagues, faction et trois choix sont vérifiés. Les résultats de référence restent Alliance 14 PV / 192 or et Horde 12 PV / 189 or.

Les statistiques sont toujours des hypothèses d’équilibrage. Ce travail ne valide pas de changement commercial ni de nouvelle mécanique de combat. Le ×10 reste temporaire et les préparations durent toujours 30 secondes réelles.

## Contrôle interactif sur PC

Essai agent sur le paquet intermédiaire v0.36 : Horde sans défense, défaite en vague 2 à 0 PV, 150 or, 20 ennemis passés et 96,5 secondes simulées. Ce scénario contrôle l’interface ; ce n’est pas une mesure d’équilibrage. Le bouton du bilan a créé les deux fichiers, puis ouvert leur dossier dans l’Explorateur. [Capture du succès](essais/captures/QA-v036_export_defaite.jpg). Le paquet final ajoute la traduction complète du journal et les aides au survol du message et du bouton. Les fenêtres de contrôle ont été fermées.
