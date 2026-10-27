# Progression et Steam Cloud — perspective du 27 octobre 2026

Statut : option discutée à la demande du porteur du projet ; aucune intégration Steam ni aucun service en ligne n’est réalisé dans le prototype v0.69.

## Ce que Steam Cloud peut apporter

La documentation Steamworks décrit la synchronisation des fichiers de sauvegarde sur les serveurs Steam après une session et leur téléchargement avant le lancement sur un autre ordinateur. Cela peut conserver les ressources, points, affectations et compteurs du joueur au-delà d’un seul PC. La configuration et l’intégration du jeu restent nécessaires ; Steam Cloud n’est pas activé automatiquement par la seule présence du jeu sur Steam.

Référence primaire : [Steamworks — Steam Cloud](https://partner.steamgames.com/doc/features/cloud?l=english).

## Synchronisation et autorité de progression

La synchronisation de fichiers n’est pas une validation des résultats de combat ou des gains. Puisque le jeu lit et écrit ses fichiers locaux avant leur synchronisation, nous ne pouvons pas en déduire que Steam Cloud empêche leur modification. Une protection locale contre la retouche directe et un stockage faisant autorité côté serveur répondent à des besoins différents.

Une progression fortement contrôlée demanderait que des services de confiance vérifient les gains et les dépenses. Cela impliquerait une décision produit concernant le jeu hors ligne, la connexion, l’exploitation d’un service et les coûts. Aucun de ces choix n’est présumé approuvé.

## Conséquence pour le prototype protégé

Le profil local v0.69 utilise DPAPI CurrentUser. Cette protection dépend des informations d’identification Windows et, généralement, de l’ordinateur. Synchroniser ce fichier tel quel ne constitue donc pas une sauvegarde portable fiable vers un autre compte Windows ou PC. Cette limite est connue ; la protection Windows n’est pas présentée comme une intégration Steam Cloud déjà prête.

Le codec et les règles de progression sont séparés dans le code pour permettre une future évolution du stockage et une conversion contrôlée du profil sans perdre les banques ou les points. La version du format protégé identifie le mécanisme actuel. Aucun secret de chiffrement portable ni aucune clé dérivée d’un Steam ID public n’est supposé fournir une garantie anti-triche.

Référence primaire : [Microsoft — CryptProtectData, contexte utilisateur et exceptions](https://learn.microsoft.com/en-us/windows/win32/api/dpapi/nf-dpapi-cryptprotectdata).

## Cadrage avant une intégration Steam

- Définir le niveau de protection attendu : dissuasion locale ou progression validée en ligne.
- Choisir un format portable et une stratégie de migration depuis les profils locaux protégés.
- Isoler les profils par compte Steam, conformément à la recommandation Steamworks sur les chemins de sauvegarde.
- Prévoir les conflits de versions entre deux machines et ne jamais fusionner des monnaies par simple addition des soldes.
- Tester une fermeture, une synchronisation puis une relance sur une seconde machine avec un autre compte Windows.
- Conserver la règle métier : les gains de la partie restent provisoires jusqu’à la victoire finale ou la défaite, même si une future sauvegarde d’un parcours en cours est synchronisée.

Le prototype ne sauvegarde pas le combat en cours et n’implémente pas de reprise de parcours. Cette éventuelle fonction reste distincte de la progression permanente et de Steam Cloud.

For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.
