# Visuels à réaliser — file de Codex

Tâches artistiques confiées à Codex : visuels, animations, effets visuels, icônes, habillage et décor. Claude Code ajoute ici les besoins visuels qu'il rencontre en codant et ne les réalise pas lui-même. Codex coche ou retire une tâche quand il l'a livrée, et note la version concernée.

Format : une case par tâche, avec le contexte (mission, unité, écran), ce qui existe déjà et les contraintes (fichiers, taille, intégration attendue).

## À faire

- [ ] **Habillage des marais, missions 41–45** : palette, chaussées, bassins, roseaux, saules et piliers brisés sont encore des formes de prototype à affiner (`prototype/scripts/marsh_art.gd`, `scenery_for` dans `valley_view.gd`). Les bassins restent décoratifs : ne pas recouvrir routes ni emplacements. Références : `design/Mission_041_Seuil_des_Marais.md`, `design/Missions_042_043_Marais.md`, `design/Missions_044_045_Marais.md`.
- [ ] **Bassins des missions 46–50 (v0.163)** : Chaussée des Roseaux, Trois Gués Noyés, Îlots du Chœur, Nef Effondrée et Sanctuaire Englouti utilisent des bassins posés par Claude Code comme emplacements neutres (`water_areas` dans `map_definition.gd`). Revoir leur forme, leur nombre et leur placement, sans toucher aux routes ni aux emplacements de défense (`test_marsh_campaign.gd` vérifie ces marges). La Nef (mission 49) est très encombrée : le décor automatique n'y trouve place que pour quatre éléments.
- [ ] **Ruine compacte du Cloître Submergé (mission 45)** : en v0.162, une ruine remplace un saule quand les marges écartent toutes les ruines. Prévoir un visuel de ruine adapté à cette emprise réduite, inclus dans les limites d'un saule.
- [ ] **Animations des unités** : seul le loup a une marche approuvée (`design/Marche_loup_v0108.md`, `design/Orientation_loup_v0109.md`). Les autres unités et ennemis restent à animer.
- [ ] **Sanglier** : étude non intégrée et non approuvée (`design/essais/sanglier_peau_continue/README.md`, `design/essais/sanglier_virages/README.md`).

## Livré

(vide)
