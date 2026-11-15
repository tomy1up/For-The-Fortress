# Prototype v0.218 — Estoc du Piquier humain

- **Piquier humain** (type 14, lot `9a7d3d8`, estoc validé par le porteur le 15 novembre 2026) : garde et trois planches d'estoc à deux mains (−12°, 0°, +12°, 20 poses sur 0,64 s) dans `assets/animations/defender.alliance.pikeman/`. La pique est dessinée dans les planches : le jeu ne redessine plus la pointe procédurale pour le type 14 et n'affiche qu'un bref éclat de contact à 0,256 s, à la pointe donnée par angle (`contact.json`). Le lance-épieu orc (type 20) garde son rendu.
- **Choix de l'angle** : une seule inclinaison, d'après la cible vue depuis la main du piquier, sert à la planche, à l'origine du contact et à sa direction (même mécanisme que le Tireur d'élite, le Javelinier et la pointe en `TILTED_TYPES`).
- **Contrôles** : `test_marksman_aim.gd` étendu (pointe par angle, délai, planches chargées) ; références de la régression visuelle du type 14 mises à jour.
- Aucune règle de combat modifiée : les dégâts restent résolus à l'instant du tir.
