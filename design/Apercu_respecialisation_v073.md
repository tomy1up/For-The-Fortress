# Aperçu de la respécialisation — v0.73

28 octobre 2026. Complément du GDD principal v0.14 et de la décision de respécialisation payante par faction. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Avant de payer

La confirmation existante présente le coût actuel et le solde restant, les points disponibles avant et après récupération des rangs, puis le prix de la prochaine réinitialisation et son plafond. Elle précise que les trois arbres seront vidés, que les points restent achetés et que l’autre faction conserve sa progression.

Exemple du profil de contrôle : 36 ressources, 14 points achetés dont 12 actifs, deux réinitialisations déjà effectuées. Le paiement coûte 6 ressources, laisse un solde de 30 et rend 14 points disponibles au lieu de 2. La prochaine réinitialisation coûtera 8 ressources. Au-delà des paliers, le prix reste 10.

## Cohérence de la confirmation

Ouvrir l’aperçu ne modifie rien. Annuler, quitter les arbres ou changer de camp invalide la demande. Si les données du camp ont changé depuis l’aperçu, la confirmation ne réalise pas de transaction et invite à vérifier le nouvel aperçu. Une seconde confirmation ne prélève pas une deuxième fois. Un échec d’enregistrement est signalé sans publier une progression non sauvegardée.

## Règles conservées

Barème d’essai inchangé : 2, 4, 6, 8 puis 10 ressources, compteur propre à chaque camp. Les rangs sont rendus en points disponibles ; la ressource dépensée pour acheter ces points n’est pas remboursée. Aucun nouvel achat, talent, frais ou format de profil. Accès aux arbres hors parcours et versement des gains au résultat global conservés. Les montants restent à équilibrer.

## Validation

50 suites et 16 982 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 122 nouveaux contrôles couvrent les deux factions et les six situations de compteur 0, 1, 2, 3, 4 et 20 : prix actuel/suivant, solde, points récupérés, lecture sans dépense, annulation, confirmation exacte, autre camp intact et double confirmation. S’ajoutent devis périmé, fermeture, changement de camp, solde insuffisant, profil bloqué, écriture en échec et relecture d’un profil protégé après une vraie confirmation.

Le paquet Windows a passé 112 lancements avec 111 captures et 37 sources concordantes. Les profils sont isolés. Le codec, le profil, les barèmes de talents, le modèle de combat, les vagues, les statistiques et les rapports ont les mêmes empreintes source que v0.72.

Confirmations inspectées : [Alliance](essais/captures/QA-v073_alliance_talents_reset.png), [Horde](essais/captures/QA-v073_horde_talents_reset.png), au plafond [Alliance](essais/captures/QA-v073_alliance_reset_cap.png) et [Horde](essais/captures/QA-v073_horde_reset_cap.png). [Régression](essais/v073_regression.json) et [distribution](Distribution_Windows_v073.json). Aucun nouvel essai humain d’équilibrage n’est revendiqué.
