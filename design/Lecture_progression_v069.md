# Comprendre les gains et le prochain talent — v0.69

27 octobre 2026. Suite du développement de la progression permanente : rendre lisible le passage d’une partie complètement terminée à la préparation de la suivante. Le porteur du projet a précisé que ni les gains permanents, ni les arbres, ni le retour à l’accueil ne sont accessibles pendant un parcours, y compris entre ses cartes. Les [arbres verticaux v0.68](Arbres_verticaux_v068.md), les coûts, les effets, les paliers et les conditions de respécialisation sont conservés.

## Bilan de progression

Après la victoire finale ou la défaite, l’onglet Essentiel du bilan présente une quatrième carte indiquant les ressources de faction réellement enregistrées. Les trois mesures de combat restent visibles : PV de la forteresse, ennemis passés et or gagné. Une ligne distincte présente les gains des vagues, la prime de victoire, le solde de la faction et le nombre de points actuellement achetables. Lorsque le contenu est déjà entièrement acheté, le bilan l’indique au lieu de proposer des points inutiles.

Les gains permanents restent distincts de l’or de recrutement. Une victoire vaut toujours 55 ressources de vagues et 5 de prime. Une défaite conserve les récompenses des vagues terminées, sans rémunérer la vague perdue. Le nombre de points achetables tient compte à la fois du prix actuel et du plafond de contenu.

Le bouton **Préparer mes talents** revient au choix de faction et ouvre les arbres du camp qui vient de jouer. Il prépare un nouvel essai : consulter ou exporter le bilan avant de l’utiliser si l’on souhaite conserver le détail de la tentative. Les points choisis seront appliqués au prochain choix de faction, conformément à la règle existante.

## Fin de partie globale et progression conservée

Les ressources des vagues et cartes sont provisoires pendant le parcours. Aucun versement ni retour à l’accueil n’a lieu entre les vagues ou après une carte intermédiaire. Les arbres restent inaccessibles une fois la faction choisie. Les achats et améliorations d’unités ainsi que les bonus de la partie restent utilisables selon leurs règles habituelles.

La liquidation se fait une seule fois à la victoire finale ou à la défaite globale. Le reçu du parcours empêche un double versement et ne peut pas être augmenté après paiement. Une victoire sur une carte non finale ne donne pas la prime de victoire finale.

Le prototype a toujours une seule carte réelle. Une frontière de fin de parcours et un cumul provisoire par carte préparent un futur enchaînement : son pilote devra conserver l’identifiant du parcours, incrémenter l’index de carte et indiquer correctement si la carte est finale. Les tests simulent deux étapes avec la carte existante ; aucune nouvelle carte, transition jouable ou campagne à plusieurs cartes n’est ajoutée dans ce lot.

Les gains acquis et enregistrés restent sur le PC après fermeture : ressources des deux factions, points achetés, rangs et compteurs de resets. Ils sont chargés à la relance, hors du dossier des exports. Les anciens gains des profils précédents sont conservés ; aucune reprise ni soustraction rétroactive n’est effectuée. Fermer une nouvelle partie non terminée ne remet pas cette progression permanente à zéro.

Les gains encore provisoires ne sont pas acquis. Cette version ne sauvegarde ni ne reprend le combat en cours : le fermer avant son résultat ne verse pas ces gains provisoires. Une future reprise de parcours reste un chantier distinct.

## Gain en attente et échec de sauvegarde

Le bilan distingue explicitement les gains attendus des gains enregistrés. En cas d’échec, la carte peut afficher « 0 / 60 » et « Enregistrement en attente » ; elle n’annonce pas ces ressources comme sauvegardées. Le détail permet de consulter le message d’erreur.

Le raccourci devient **Réessayer la sauvegarde**. Si la reprise réussit, ce premier clic actualise le bilan ; un second clic permet de préparer les talents. Tant que l’écriture échoue, ce raccourci ne réinitialise pas la tentative. Si le profil est protégé parce qu’il est illisible, cette action reste désactivée.

Après le résultat global, les reprises automatiques sont espacées d’au moins deux secondes réelles après un échec, indépendamment de la vitesse de combat. Une création initiale de parcours qui avait échoué peut aussi être retentée. Les récompenses sont toujours créditées par le suivi existant des vagues et de la victoire, sans double gain après une reprise. Les contrôles ne promettent pas une sauvegarde réussie si le disque reste indisponible ; quitter le jeu peut perdre les gains encore en attente.

## Aperçu du prochain rang

Le survol ou le focus clavier d’un talent présente son effet, le rang actuel et l’évolution de ses **bonus permanents** au rang suivant. Les bénéficiaires correspondent au camp affiché. Les évolutions identiques de l’archer et de l’arbalétrier peuvent être regroupées pour réduire la lecture.

La comparaison reprend tous les bonus permanents actifs concernant les composantes qui changent : tirs, explosions, rebonds, malédictions, portée ou PV supplémentaires. Elle ne prétend pas afficher le DPS d’une défense en cours ni les bonus aléatoires d’une tentative. Les valeurs viennent des mêmes calculs que l’affectation réelle du point.

L’aperçu ne dépense rien et ne modifie ni le profil, ni les rangs, ni le modèle. Il reste consultable lorsqu’il manque seulement un point disponible. Un rang maximum, un palier fermé ou une spécialité incompatible conserve son explication sans proposer un rang illégal.

## Compatibilité et périmètre

Le profil conserve son schéma 2 et son chemin ; le reçu de parcours ajoute des champs facultatifs de liquidation et de cumul des cartes précédentes. Aucune nouvelle restitution de points n’est effectuée. Le format de fichier est désormais protégé : un ancien JSON non protégé nécessite la conversion contrôlée décrite ci-dessous. Les rapports, les règles de combat, les vagues, la ressource par vague, les prix et la puissance des talents sont conservés. La difficulté et la durée de progression restent à mesurer auprès de joueurs.

For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Protection contre la retouche des fichiers

Le contenu du profil est chiffré et protégé en intégrité par Windows DPAPI, dans le contexte CurrentUser. Aucune clé de chiffrement n’est embarquée dans le jeu ou écrite dans un fichier de configuration. Le format commence par `FTF-DPAPI-1` puis contient des données binaires protégées ; l’extension `.json` du chemin historique n’indique plus un document JSON éditable.

Le pont vers l’API Windows utilise Windows PowerShell en mode caché et non interactif. Les données passent par un tube d’entrée/sortie, jamais par les arguments de commande ni par un fichier temporaire en clair. Une limite de cinq secondes arrête le processus auxiliaire si nécessaire. Les opérations de profil restent transactionnelles ; le temporaire et les copies de secours contiennent également des données protégées.

Une modification du contenu chiffré ne produit pas un nouveau solde valide. Le principal est refusé et un secours protégé valide peut être chargé. Si aucun profil protégé valide n’est disponible, les fichiers sont préservés et la progression est bloquée ; elle n’est pas silencieusement remplacée par un profil neuf.

La protection est liée au contexte Windows de l’utilisateur. La sauvegarde n’est donc pas un simple fichier portable en clair entre comptes ou installations Windows. Le jeu reste hors ligne ; aucune progression en ligne ni dépense de service n’est introduite.

### Anciennes sauvegardes en clair

Le jeu n’importe jamais automatiquement un JSON non protégé : un joueur pourrait sinon écrire des valeurs arbitraires puis les présenter comme une ancienne sauvegarde. Un tel fichier est conservé et signalé, sans remise à zéro ni écrasement.

Pour le développeur, `prototype/tools/protect_legacy_profile.gd` convertit explicitement un ancien profil validé vers un fichier protégé distinct. Il refuse d’écraser une destination existante, préserve l’entrée et vérifie le contenu après déchiffrement. Cet outil de confiance n’est pas inclus dans le paquet exporté. Il ne peut pas prouver rétrospectivement qu’un ancien JSON n’avait jamais été modifié ; son utilisation relève donc d’une conversion contrôlée, pas d’une preuve anti-triche.

### Limites assumées

Cette mesure bloque la retouche directe des montants dans un éditeur de texte et détecte une modification du fichier protégé. Ce n’est pas une garantie anti-triche absolue sur un PC contrôlé par son propriétaire : modification du programme, invocation de l’API sous le même compte ou restauration d’une ancienne copie valide restent hors du périmètre. Une progression faisant autorité côté serveur serait nécessaire pour un contrôle plus fort ; ce changement de produit n’est pas réalisé ici.

Références techniques : [Microsoft — CryptProtectData et contexte utilisateur](https://learn.microsoft.com/en-us/windows/win32/api/dpapi/nf-dpapi-cryptprotectdata) ; [Godot — processus à entrées/sorties redirigées](https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-execute-with-pipe).

## Évolution Steam envisagée

Le porteur du projet a demandé si la progression pourrait être sauvegardée en ligne sur Steam. [Le cadrage Steam Cloud](Steam_Cloud_perspectives_2026-10-27.md) distingue synchronisation, protection et contrôle des gains. La protection DPAPI du prototype n’est pas directement portable vers un autre PC ; une évolution du format et une conversion seront nécessaires avant une intégration Steam Cloud. Aucun accès Steam ou serveur n’est ajouté dans ce lot.

## Validation

46 suites et 16 610 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 255 contrôles de lecture couvrent l’aperçu de rang, son absence de dépense, son accord avec une affectation réelle, les gains de victoire/défaite, le retour aux talents et la réouverture d’un profil pour la partie suivante. Les 33 contrôles de frontière vérifient l’absence de versement et d’accueil entre vagues/cartes, le cumul provisoire de deux étapes simulées et une liquidation finale unique.

Les 10 contrôles de relance utilisent quatre processus de jeu distincts : création d’une progression, relecture, début d’un nouveau parcours puis nouvelle relecture. Ressources, points, rangs et compteurs restent conservés. Les 13 contrôles d’intégrité couvrent le fichier protégé, son déchiffrement sans cache, les octets altérés, le secours, le refus d’un faux JSON éditable, la protection contre l’écrasement et la conversion contrôlée avec entrée préservée et destination non écrasable.

Les tests de nettoyage d’interface précédents sont désormais exécutés après une défaite simulée, conformément à la nouvelle frontière de partie ; leurs assertions de nettoyage restent actives. La nouvelle suite de frontière vérifie séparément les appels de relance forcés pendant un parcours réel simulé.

Le paquet final a passé 101 lancements et produit 100 captures, avec 37 sources locales concordantes. Contrôles visuels : [victoire finale](essais/captures/QA-v069_horde_progression_victory.png), [défaite](essais/captures/QA-v069_alliance_progression_defeat.png), [carte intermédiaire sans versement](essais/captures/QA-v069_horde_progression_intermediate.png), [écriture en attente](essais/captures/QA-v069_progression_pending.png), prochains rangs [Alliance](essais/captures/QA-v069_alliance_rank_preview.png) et [Horde](essais/captures/QA-v069_horde_rank_preview.png), [profil chiffré relu depuis le paquet](essais/captures/QA-v069_profile_protection.png).

Un chargement du paquet dans un projet vide confirme la présence du codec et l’absence de l’outil de conversion et du scénario de relance, qui restent réservés au développement. [Preuve d’isolation](essais/v069_package_isolation.json), [régression](essais/v069_regression.json) et [distribution](Distribution_Windows_v069.json). Les scénarios de cartes successives sont des simulations de frontière avec la carte existante, sans nouvelle carte jouable. Aucun nouveau retour humain, anti-triche absolu ou intégration Steam n’est revendiqué.
