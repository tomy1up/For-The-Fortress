# Signal des percées ennemies — v0.32

24 octobre 2026. Présentation des arrivées existantes, complément du GDD v0.14.

## Réalisé

Quand une avance du combat augmente le nombre total d’ennemis passés et réduit les PV de la forteresse, le contrôleur affiche un cadre autour du bâtiment et un message avec les deltas réels. Le compteur de PV prend la même couleur d’avertissement. L’alerte ne repose pas sur une nouvelle règle d’arrivée.

Le signal reste visible 2,5 secondes réelles, sans accélération par ×2 ni pause du jeu. Une nouvelle avance avec des arrivées dommageables remplace le signal et redonne la durée entière. Des arrivées traitées dans la même image sont agrégées, même si une image longue couvre plusieurs instants du modèle. Les PV perdus sont plafonnés naturellement par les PV réellement restants : deux Brutes arrivant contre 3 PV affichent 3 PV perdus et deux ennemis passés.

Une fin de vague ou une défaite conserve la durée de lecture restante. L’expiration rend au compteur sa couleur normale ; un départ réussi de vague ou un nouvel essai efface le signal. Les fenêtres modales peuvent masquer la carte, sans suspendre cette indication temporaire. Une élimination, une apparition ou un gain de PV ne déclenche pas d’alerte.

## Statut et limites

Affichage réalisé sans modification du modèle, des dégâts d’arrivée, des primes ou de l’enchaînement automatique. Les valeurs d’équilibrage conservent leur statut précédent. Couleur et durée sont des choix visuels provisoires à ajuster après retour humain. Aucun nouveau pouvoir, bouclier ou seuil de difficulté n’est introduit.

Le signal décrit les dernières arrivées observées par l’affichage, pas l’historique complet. Le bilan de fin de partie conserve ses propres compteurs par vague. Aucun nouvel historique persistant n’est créé.

## Vérifications

41 contrôles ciblés : deux factions et vitesses, durée réelle, remplacement, dégâts réels plafonnés, groupe simultané fatal, longue image, expiration, nouvelle vague, nouvel essai et absence d’alerte sans fuite. 2 822 contrôles au total ; résultats des campagnes de référence identiques. Le paquet Windows est contrôlé sur 27 lancements. La capture de percée utilise la première arrivée de la vague 1, sans défenseurs et avec le budget initial normal ; elle ne simule pas de dégâts fictifs. La compréhension et la discrétion du signal restent à évaluer lors des prochains essais humains.
