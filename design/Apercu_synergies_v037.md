# Aperçu des synergies — v0.37

25 octobre 2026. Amélioration de lecture des règles existantes, sans modification de mécanique ni de valeur d’équilibrage. GDD principal toujours v0.14.

## Comportement

Avant le recrutement, le survol ou le focus clavier montre les partenaires admissibles sur la carte avec des **liens bleus pointillés**. Le chemin bleu continue de représenter la portée d’attaque. La ligne d’aide indique le nombre d’associations prévues, indépendamment du nombre de partenaires.

L’infobulle du bouton identifie les partenaires par emplacement et nom, puis précise les gains du défenseur envisagé : tirs directs, rebonds, explosions, malédiction ou portée selon ses capacités. Les statistiques de l’aperçu incluent déjà ces effets. Un choix sans partenaire le signale.

Le même affichage accompagne les aperçus d’amélioration et les deux choix de spécialisation. Chaque bouton de branche possède son propre détail. Une branche ne crée une liaison de spécialisation que si le partenaire possède déjà la branche requise ; la proximité n’est pas requise pour ces associations.

Après confirmation, les liens prévus disparaissent et les liens actifs habituels prennent leur place : dorés pour la proximité, bleus pour les spécialisations. Annuler, quitter le survol, ouvrir le récapitulatif ou démarrer le combat retire la prévision. Les conditions et les limitations de paiement restent inchangées.

## Implémentation et limites

La vue utilise `synergy_partners` avec une unité candidate indépendante. Aucun placement temporaire dans le modèle, aucune dépense, aucun recalcul des partenaires réels et aucun tirage. Plusieurs partenaires d’une même association sont dessinés, mais l’effet n’est appliqué qu’une fois, conformément aux règles existantes.

Le détail concerne les gains du défenseur prévisualisé. Il ne prétend pas comparer toutes les statistiques de ses voisins. Les liens sont une projection, même lorsqu’un achat est actuellement impossible faute d’or ou à cause du quota ; la raison du refus reste affichée et la commande demeure désactivée.

Les factions utilisent uniquement leurs unités et leurs associations. Les synergies raciales restent hors du prototype actuel. Aucun contenu commercial, nouvelle unité ou nouveau bonus n’est ajouté.

## Validation

- **13 879 contrôles réussis**, dont 1 162 ciblés : chaque paire d’emplacements et chaque sens des associations de proximité ; spécialisations à longue distance ; mauvais choix de branche ; comparaison avec l’achat ou la spécialisation réellement exécutés ; absence de mutation et de tirage ; nombre unique malgré plusieurs partenaires ; cohérence des factions ; focus clavier et effacement des aperçus.
- **42 lancements du paquet Windows**, dont quatre vues spécifiques aux nouvelles prévisions. Images de recrutement et de spécialisation inspectées dans les deux factions. Les deux campagnes de référence et les exports de rapports restent contrôlés.
- Essai interactif agent sur le même paquet : Alliance avec arbalétrier E2, aperçu d’archer E1 à 8,64 dégâts puis confirmation à 8,64 dégâts, synergie active et 25 or restants. Horde avec sapeur E2, aperçu du lanceur de haches E1 : dégâts principaux 16, rebond 8,64 et détail de +8 % aux rebonds. Aucun texte d’unité Alliance dans cet aperçu Horde.
- Captures : [Alliance](essais/captures/QA-v037_alliance_synergie_prevue.jpg) et [Horde](essais/captures/QA-v037_horde_synergie_prevue.jpg). Ces essais vérifient l’interface ; ils ne constituent pas de nouvelles parties humaines ni une conclusion d’équilibrage.

Tous les lancements graphiques de cette session ont été dirigés vers le **second écran, à droite**, selon la demande du porteur du projet. Le vérificateur Windows accepte désormais `--screen 1` pour reproduire cette préférence locale ; elle ne change pas l’écran par défaut du jeu distribué. La fenêtre de l’essai interactif était entièrement à droite, à partir de x = 2879. Elle a été fermée à la fin du contrôle.
