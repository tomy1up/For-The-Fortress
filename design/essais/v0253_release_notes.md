# Prototype v0.253 — Offres de bonus utiles

Décisions du porteur du 24 novembre 2026. Critère et coefficients : réglages de prototype à confirmer en partie réelle.

## Offres utiles

- Une carte de bonus qui ne servirait à **aucun défenseur déployé** est remplacée par le bonus utile suivant de même rareté. Par exemple, Soutien efficace sans unité de soutien, ou Sortilèges durables sans dégâts sur la durée. Chaque offre propose donc trois vrais choix.
- Les offres déjà utiles ne changent pas, et la valeur des bonus non plus. La relance suit la même règle.

## Recalage de l'Alliance

- Les armées de l'Alliance tiraient le plus de cartes sans effet : avec les offres utiles, elles devenaient nettement plus fortes. **57 missions de l'Alliance** ont 1 à 7 % de PV ennemis en plus pour revenir dans la cible de difficulté. La Horde ne change pas.
- Sur toute la campagne, **386 réglages sur 398** sont dans la cible, aucun en dessous. Restent au-dessus :
  - Alliance 2, 3, 12, 13, 33, 137, 164 et 178 ;
  - Horde 2, 3, 23 et 39.

Fiche : `design/Offres_utiles_v0253.md`.

## Contrôles

- Régression complète : 148 suites sur 148, 249 807 contrôles Godot, 17 tests Python (nouvelle suite `test_useful_offers.gd`).
- Campagne remesurée sur les 398 réglages (30 compositions, tirages 7, 8 et 9), et garde des 28 suites de campagne avec les coefficients recalés : l'armée de référence gagne partout.
- Paquet Windows vérifié : 1 050 cas et 670 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur) ; offres de bonus inspectées dans les deux factions.
