# Prototype v0.212 — Courbe de la Horde revue

- **Décision du porteur (15 novembre 2026)** : « la Horde doit être revue », option retenue : PV d'ennemis −10 % pour la Horde à partir de la mission 150. `Catalogue.faction_hp_percent(numéro, faction)` ; appliqué au lancement des missions (`main.gd`) et au texte « PV ennemis » du menu de campagne. L'Alliance et les 149 premières missions sont inchangées (mission 200 : 238 % pour la Horde, 264 % pour l'Alliance).
- **Mesure** : `design/Mesure_boutique_finales_O016.md` (outil `survey_shop_campaign.gd`, six défenseurs, huit missions) : à PV égaux 16 victoires sur 48 pour la Horde contre 33 pour l'Alliance ; 31 avec ×0,9. La mission 200 reste mince (1 victoire sur 6 à ×0,9).
- Tests : `test_horde_curve.gd` (401 contrôles) ; les suites des chapitres 15 à 20 comparent désormais les PV joués par faction. Les rapports déjà enregistrés se rejouent avec leurs propres PV.
- Réglage de prototype à confirmer en jeu.
