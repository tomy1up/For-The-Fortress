# Missions 38–40 — fin du quatrième chapitre

## Périmètre livré en v0.159

Les trois dernières missions du chapitre 4 reprennent le Cirque, les Hauts Passages et le Bastion des Ardoises avec le réglage d'essai validé de Vents contraires. Tous les défenseurs attaquent 10 % moins souvent. Les dégâts périodiques déjà appliqués gardent leur rythme.

| Mission | Carte | Entrées | PV ennemis | Points accessibles avant la première tentative |
| --- | --- | --- | --- | --- |
| 38 | Le Cirque des Ardoises | 2 | 137 % de la référence | 18 |
| 39 | Les Hauts Passages des Ardoises | 3 | 138 % de la référence | 19 |
| 40 | Le Bastion des Ardoises | 2 | 139 % de la référence | 19 |

Chaque mission comporte dix vagues, six emplacements et une forteresse. Les tracés, les statistiques des défenseurs et le dosage du vent sont conservés. La réussite de la mission précédente dans la faction débloque la suivante.

Chaque première victoire donne 60 PO et 100 XP. Quarante premières victoires distinctes dans une faction représentent donc 2 400 PO avant dépenses, 4 000 XP et 20 points de talents débloqués. Le rejeu ne redonne ni PO ni XP. Le mode infini reste soumis aux cent premières missions réussies de la difficulté concernée et n'est pas débloqué à ce palier du prototype.

## Comparaisons et difficulté

Deux panels de 648 simulations comparent l'ordre d'accès habituel des talents et la préparation prioritaire des prérequis des talents majeurs. Ils utilisent les mêmes trois graines, trois placements, quatre compositions de trois unités et trois arbres de talents, avec les points gagnés avant chaque mission. Le premier bonus proposé est choisi.

| Mission | Alliance, ordre d'accès | Alliance, chemin majeur | Horde, ordre d'accès | Horde, chemin majeur |
| --- | --- | --- | --- | --- |
| 38 | 38 victoires sur 108 | 45 sur 108 | 5 sur 108 | 12 sur 108 |
| 39 | 19 victoires sur 108 | 33 sur 108 | 0 sur 108 | 4 sur 108 |
| 40 | 10 victoires sur 108 | 25 sur 108 | 0 sur 108 | 0 sur 108 |

Ces résultats signalent une difficulté importante côté Horde sur les dernières cartes. La seconde spécialisation et un renfort de sapeur sur le dernier emplacement n'ont pas fourni de victoire Horde au Bastion dans les panels essayés. Un autre ordre de préférence entre les bonus proposés améliore certains résultats aux Hauts Passages, sans résoudre à lui seul le Bastion dans ce panel de trois unités.

Une exploration distincte de 648 politiques Horde au Bastion trouve huit victoires avec une tentative de quatrième recrutement. Ce panel comprend des achats refusés par le budget ou la limite de deux exemplaires et ne représente pas 648 défenses constituées de quatre unités. La défense réellement recrutée est enregistrée.

La composition retenue pour le contrôle utilise un lanceur de haches, un chaman et un sapeur, puis un second lanceur de haches, avec dix-neuf points préparant le talent majeur de Fureur de guerre. Elle remporte la mission sur la graine 7 avec 5 PV, mais perd sur les graines 42 et 2026. Elle utilise uniquement les unités de départ, les revenus normaux et les bonus effectivement proposés.

Cette confirmation établit une possibilité accessible. Elle ne valide pas l'équilibrage de découverte, la variété des solutions ou la tolérance aux différents tirages. **Le Bastion Horde reste un point d'équilibrage prioritaire avant de considérer cette fin de chapitre stabilisée.** Les résultats des politiques automatiques ne sont pas des probabilités de réussite d'un joueur.

Les relevés locaux principaux sont `dist/slate-missions38-40-baseline.json`, `dist/slate-missions38-40-major.json`, `dist/slate-mission40-four-units.json` et `dist/slate-mission40-confirmation.json`. Les essais complémentaires conservent séparément leur protocole et leurs paramètres.

## Vérification de la progression

Le contrôle d'intégration remporte les missions 31–40 par le parcours normal dans chaque faction. Il vérifie les points légalement acquis, les dépenses, le rejeu des rapports et le crédit unique des gains. Les vingt combats sont exécutés sans ressource de combat ajoutée.

Après la première victoire de la mission 40, le parcours affiche les quatre chapitres accomplis. Le chapitre 5 reste à venir. La mission 40 est remportée une seconde fois, puis les banques sont vérifiées à 2 400 PO, 4 000 XP et 20 points. Après vidage du cache, une nouvelle instance du profil relit la sauvegarde isolée pour vérifier la conservation de ce palier et l'indépendance de l'autre faction. Le retour à la mission 21 vérifie aussi la disparition du vent.

11 040 contrôles Godot ciblés et seize essais Windows réussissent. Les captures du paquet exporté ont été inspectées visuellement, y compris les deux parcours après quarante victoires. Vingt-quatre rapports supplémentaires ont été rejoués pour vérifier l'ordre de préférence des bonus dans l'outil de comparaison. Les profils du joueur ne sont pas utilisés par ces essais.

## Suite

Quarante missions sont disponibles, soit quatre chapitres. Le porteur a retenu les marais et les ruines englouties pour les chapitres 5 et 6, aux missions 41–60. Cette ambiance est une décision de conception. Les terrains et les nouvelles mécaniques restent à produire et à préciser séparément.
