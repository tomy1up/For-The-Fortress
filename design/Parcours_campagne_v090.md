# Parcours de campagne — prototype v0.90

30 octobre 2026. For the Fortress! est un nom de travail, disponibilité juridique à confirmer.

## Décisions validées

Parcours et premières réussites indépendants par faction. Une mission peut constituer une session complète ; PO et XP sont versées définitivement à sa première victoire. Le rejeu et la défaite ne redonnent pas ce gain. Chaque mission repart à neuf : forteresse à son maximum, or initial, aucun défenseur et aucun bonus temporaire. Les talents sont préparés entre les missions puis fixés pendant le combat ; XP, PO et futurs déblocages restent persistants.

La cible reste 200 missions, vingt chapitres de dix missions, changement de thème tous les deux chapitres et nouveautés sur les blocs 11–20, 31–40, etc. L’infini demande les cent premières missions de la faction concernée. Ces règles de structure ne constituent pas 200 contenus déjà réalisés.

## Interface et chemin jouable

Le choix de faction ouvre son parcours : chapitres à gauche, dix positions au centre, mission sélectionnée et récompenses à droite. Le joueur peut consulter les positions futures, clairement signalées à venir, sans les lancer. L’écran permet de préparer ses talents avant de démarrer.

Le Gué reste **la seule mission jouable**, avec dix vagues et sa première récompense de prototype de **60 PO et 100 XP par faction**. Une mission déjà gagnée porte une marque de réussite et propose explicitement de rejouer sans nouveau gain. Les autres missions n’ont pas de récompenses ni de vagues inventées.

Après la victoire ou la défaite, le bilan propose le retour au parcours de la même faction. Une nouvelle tentative repart à neuf. Aucun accès au parcours ni aux talents permanents pendant la mission. Le parcours derrière les talents ne reçoit ni clics ni clavier. L’ouverture d’une mission exige l’enregistrement de la tentative ; un résultat ne peut pas être détruit par un retour tant que sa sauvegarde échoue.

## Persistance et compatibilité

Les réussites et compteurs de chapitre sont calculés depuis le registre de premières récompenses existant ; aucune duplication du stockage, aucun changement du schéma 6 et aucun crédit rétroactif. Les premières victoires déjà enregistrées restent reconnues après relancement. L’accès futur à l’infini exige précisément les missions 1–100 du même camp, pas n’importe quelles cent missions.

L’infini reste indiqué à venir, même si la condition est remplie dans un profil de contrôle. Les arbres de talents conservent les quatre colonnes et les flèches droites de v0.89. Aucun effet de combat n’est rééquilibré dans ce lot.

## Hypothèses et travail restant

La disposition de cet écran est une proposition de prototype. Les missions 2–200, leur contenu, leur courbe de difficulté et leur barème restent à concevoir. Le barème d’XP de référence reste à éprouver ; le Gué seul ne permet pas d’obtenir le premier point à 197 XP. La boutique, ses unités et le mode infini ne sont pas implémentés.

La prochaine étape consiste à construire un petit échantillon de missions réellement jouables, puis à tester la progression et la lisibilité avant toute extension massive du contenu.

## Validation

69 suites et **23 359 contrôles Godot**, 16 tests Python et contrats du GDD réussis. Les 452 contrôles de progression vérifient les frontières des chapitres, les cent premières missions précises, les reçus invalides et la relecture des gains protégés par faction. Les 912 contrôles de navigation couvrent les 200 positions, les missions futures non lançables, les talents superposés, le lancement refusé si la sauvegarde échoue, le résultat conservé en cas de crédit impossible, le rejeu sans gain et le départ à neuf.

Le paquet Windows passe **161 lancements et 160 captures**, avec 45 sources comparées. Douze scénarios de parcours couvrent les deux factions : neuf, déjà réussi, mission future, profil bloqué, talents et retour après victoire de contrôle. Les **40 scénarios historiques de combat** gardent exactement rapports, aléas, événements et dégâts de v0.89 ; aucun rééquilibrage ni nouvel essai humain de difficulté n’est revendiqué.

[Régression](essais/v090_regression.json), [comparaison de combat](essais/v090_comparaison_combat.json), [distribution](Distribution_Windows_v090.json). Exemples : [parcours Horde](essais/captures/QA-v090_horde_campaign_menu_fresh.png), [retour Alliance](essais/captures/QA-v090_alliance_campaign_menu_returned.png).
