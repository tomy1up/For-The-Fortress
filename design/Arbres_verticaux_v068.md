# Arbres de talents verticaux — prototype v0.68

27 octobre 2026. Le porteur du projet fournit une référence visuelle de talents à la manière de World of Warcraft : progression du haut vers le bas, avec une dépense propre à chaque arbre pour accéder à la ligne suivante.

## Décision et barème de réalisation

La lecture verticale et les conditions de dépense par arbre viennent de la demande du joueur. Les seuils de **0, 5 et 10 points** reprennent son exemple comme hypothèse de prototype. Le nombre final de lignes, de talents, de rangs et les effets restent à équilibrer ; cette version ne prétend pas reproduire tout le contenu de la référence.

La v0.68 remplace le prérequis unique de trois rangs de la v0.67 par trois lignes et cinq talents dans chacun des trois arbres d’une faction :

| Ligne | Talents | Rangs maximum | Condition d’accès |
| --- | --- | --- | --- |
| 1 | Un talent de base | 5 | Immédiatement |
| 2 | Deux talents intermédiaires | 3 chacun | 5 points dans la première ligne du même arbre |
| 3 | Deux spécialités exclusives | 1 chacune | 10 points dans les lignes précédentes du même arbre |

Les points investis dans une autre colonne ou dans l’autre faction ne débloquent aucune ligne. Les points achetés mais non affectés ne comptent pas non plus. Les talents d’une ligne ne peuvent pas financer leur propre prérequis dans une sauvegarde modifiée. Une respécialisation referme les lignes et rend les points disponibles selon les règles payantes déjà retenues.

Le contenu actuel peut recevoir **12 points par arbre, soit 36 par faction** : cinq dans la première ligne, six dans les deux talents intermédiaires et un dans une spécialité finale. Le plafond d’achat suit ce contenu ; il ne constitue pas un plafond de progression définitif.

## Présentation

Trois colonnes colorées présentent le nom de l’arbre, ses points investis et les trois lignes descendantes. Une flèche relie les états de ligne sur le côté : elle exprime l’ouverture du palier, sans créer de prérequis direct supplémentaire entre deux talents particuliers.

Les talents sont des boutons carrés avec une icône et un compteur de rangs. Une bordure dorée signale les points acquis ; les talents disponibles ou verrouillés ont des états distincts. Les talents verrouillés restent consultables au clavier ou à la souris. L’encart inférieur montre le nom, l’effet, le coût ou la condition manquante exacte, sans imposer toutes les descriptions simultanément.

Les icônes sont des pictogrammes provisoires dessinés dans le jeu : bouclier, lame, éclat, hache, rune et bombe. Aucune illustration ni aucun élément graphique de la capture de référence n’est extrait ou intégré. Les trois colonnes et les paliers constituent la direction de présentation ; les illustrations finales restent un chantier distinct.

## Effets provisoires

Les bases et les spécialités finales reprennent les effets v0.67 ; les bases peuvent désormais atteindre cinq rangs. Deux effets intermédiaires sont ajoutés à chaque arbre pour rendre les paliers jouables :

| Faction | Arbre | Talent intermédiaire A, par rang | Talent intermédiaire B, par rang |
| --- | --- | --- | --- |
| Alliance | Bastion | Fondations : +1 PV maximum | Veille : +0,05 de portée de tous les défenseurs |
| Alliance | Maîtrise du tir | Pointes affûtées : +2 % aux tirs de l’archer et de l’arbalétrier | Ligne de mire : +0,1 de portée de ces deux défenseurs |
| Alliance | Arts arcaniques | Concentration : +2 % au tir du mage | Étincelles : +3 % aux explosions du mage |
| Horde | Fureur de guerre | Haches affûtées : +2 % au tir du lanceur de haches | Rebonds précis : +3 % à ses rebonds |
| Horde | Voie des maléfices | Focalisation : +2 % au tir du chaman | Mauvais présage : +3 % à ses malédictions |
| Horde | Démolition | Charge concentrée : +2 % au tir du sapeur | Éclats renforcés : +3 % à ses explosions |

Ces nouveaux noms, valeurs et effets sont des hypothèses de réalisation, non une liste de talents définitivement approuvée. Les additions de dégâts et de portée gardent les règles de calcul du [premier lot](Progression_factions_v067.md). L’économie de ressource, le prix d’un point et le prix croissant puis plafonné des resets ne changent pas. Aucun changement de vague ou de difficulté sans talent.

## Profils existants

Le profil garde son chemin `user://progression_factions_v1.json` et passe au schéma interne 2. Un profil v0.67 valide est migré automatiquement : ressources, points achetés, compteurs de resets, identifiant et progression des gains restent conservés. Les anciennes affectations sont rendues disponibles, sans coût ni incrément de compteur, pour redistribuer les points dans la nouvelle structure.

Le profil original est copié dans `.v067.bak` avant la migration ; la copie n’est pas écrasée ensuite par les sauvegardes ordinaires. La migration est enregistrée avant de publier le nouvel état en mémoire. Si son écriture échoue, le profil est protégé et l’original n’est pas remplacé. Un profil déjà migré n’est pas réinitialisé à chaque lancement. Ne pas utiliser une ancienne version du jeu pour modifier directement le nouveau profil.

Les tests utilisent des profils dédiés ; aucun profil réel n’est migré lors des tests ou captures. Les rapports historiques à neuf rangs restent rejouables avec les calculs v0.67 conservés dans un module distinct. Les nouveaux rapports contiennent quinze rangs et utilisent les nouveaux calculs. Leur format de rapport reste 2 ; la longueur de la configuration distingue les règles de talents.

For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Validation

42 suites et 16 295 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 148 nouveaux contrôles couvrent les seuils avant/après 5 et 10 points dans les six arbres, l’indépendance des colonnes et factions, l’exclusion finale, le verrouillage après reset, le refus de prérequis autofinancés, une migration réelle sur disque, les valeurs conservées, la copie du profil d’origine, l’absence de second remboursement, la protection en cas de copie incomplète, les nouveaux effets, le rejeu des rapports, les descriptions au clavier et les limites des colonnes. Les 173 contrôles de progression restent actifs.

Le module de calcul v0.67 conservé est comparé au fichier du tag v0.67 et reste identique après normalisation des fins de ligne. Les campagnes sans talent gardent leurs résultats de référence.

Le paquet final a passé 92 lancements et produit 91 captures, avec 36 sources locales concordantes. [Alliance](essais/captures/QA-v068_alliance_talents.png), [Horde](essais/captures/QA-v068_horde_talents.png), confirmations [Alliance](essais/captures/QA-v068_alliance_talents_reset.png) et [Horde](essais/captures/QA-v068_horde_talents_reset.png) inspectées. Profils de capture éphémères ; aucun profil réel migré par ces contrôles. Aucun nouveau retour humain ou équilibrage final revendiqué. [Régression](essais/v068_regression.json) et [distribution](Distribution_Windows_v068.json).
