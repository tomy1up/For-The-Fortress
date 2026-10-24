# Lisibilité et débogage — v0.35

24 octobre 2026. Corrections et réalisation visuelle dans le périmètre du prototype.

## Changements réalisés

| Sujet | Comportement |
| --- | --- |
| Dégâts ennemis | « S’il atteint la forteresse, elle perd X PV » ; alerte « Défaite » si cette arrivée suffit |
| Récompense | « Éliminé : vous gagnez X or » |
| Prévision | Les PV perdus sont attribués explicitement à la forteresse ; l’aide du boss indique « ennemi unique » au lieu d’un intervalle nul |
| Compteurs | « Passés » désigne les ennemis ayant franchi la défense, en cohérence avec le bilan |
| Nombres | Deux décimales au maximum, sans zéros inutiles ; aucune modification des nombres de simulation |
| Économie | Aide d’amélioration : prix, investissement et solde futur ; aide de vente : investissement passé, remboursement, perte et solde futur |
| Portée | Route couverte en doré pour l’unité sélectionnée ; les aperçus d’achat et d’amélioration gardent le bleu |
| Ennemis | Huit silhouettes temporaires différenciées par taille, équipement et accessoires ; mouvement des jambes lié au temps de combat |
| Défenseurs | Oreilles, barbe, teintes et proportions renforcent la distinction des races ; aucune nouvelle statistique d’équipement |
| Listes de bonus | Lecture stable pendant le choix ; retour en haut pour un nouveau contexte ou une nouvelle partie |

La fiche ennemie dispose de deux lignes pour expliquer la perte de PV, séparées de la récompense. Les choix économiques gardent leurs verrous ; le contenu informatif de l’aide ne désactive jamais une commande disponible.

## Décision temporaire de vitesse

Demande explicite du porteur du projet dans le chat : « pour les bienfaits du debuggage, tu peux mettre une vitesse x10 que l’on retirera plus tard ». Le bouton suit temporairement ×1 → ×2 → ×10 → ×1. Le ×10 est signalé « debug ». Cette décision complète les vitesses d’essai du cahier et ne constitue pas un engagement pour la version commerciale.

Seul le delta de combat est multiplié. Les 30 secondes entre vagues restent réelles ; les choix obligatoires attendent le joueur, les suspensions de préparation sont conservées, les signaux de percée gardent 2,5 secondes réelles. Nouvel essai revient en ×1. Le retrait se concentre sur COMBAT_SPEEDS, l’aide du bouton et la documentation.

## Statut

Textes et interface réalisés ; art toujours provisoire. Équipement et animations sont visuels et n’ajoutent ni armure, ni résistance, ni pouvoir. Les règles, coûts, vagues, dégâts et états juridiques conservent leur statut précédent. Le modèle de combat n’est pas modifié par cette livraison.

## Vérification

12 578 contrôles automatisés : 203 sur les nombres et transactions, 10 sur le défilement, 53 sur le ×10, les contrôles antérieurs et les extensions de lisibilité ennemie. Les scénarios ×1/×2/×10 conservent journal, revenus, pertes et durée simulée identiques. Les campagnes de référence restent inchangées.

36 lancements du paquet Windows contrôlent démarrage, captures de combat, choix, aperçus, bilans, catalogues des défenseurs et ennemis et signal ×10. Les captures imposées sont identifiées et ne servent pas à conclure sur l’équilibrage. Voir le [compte rendu d’essais interactifs](Essais_interactifs_v035.md) pour les vérifications au PC.

## Infobulles actualisées

Un contrôle interactif a montré que l’infobulle native du bouton de départ pouvait rester sur l’ancienne vague tant que le pointeur ne bougeait pas. Les boutons utilisent désormais un contenu qui suit le texte courant et se redimensionne. Le contenu est recréé et libéré par Godot ; la référence au bouton est faible. Cette correction suit le mécanisme documenté de [personnalisation des infobulles de Control](https://docs.godotengine.org/en/4.6/classes/class_control.html#class-control-private-method-make-custom-tooltip).
