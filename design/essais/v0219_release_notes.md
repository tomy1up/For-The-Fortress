# Prototype v0.219 — Premiers sons de combat

- **Attribution du son** (décision du porteur, 16 novembre 2026) : Claude Code gère le son, par banques libres de droits uniquement et sans dépense (`AGENTS.md`).
- **Système sonore** : `sound_bank.gd` (catalogue des événements et des fichiers), `sound_player.gd` (voix réutilisées, volume 0,8, coupure), `sound_director.gd` (déclenche d'après les événements du modèle, sans rien écrire dedans). Le tir sonne au lâcher visuel (0,27 s, 0,16 s…), l'impact à l'arrivée du projectile, les éliminations simultanées ne font qu'un son, un son très en retard est abandonné.
- **Sons** : 20 fichiers Kenney (CC0) dans `assets/audio/sfx/` (Impact Sounds, RPG Audio, Interface Sounds). Aucun pack ne fournit de vrai son d'arc, d'arme à feu ou de magie : ces événements utilisent des substituts, **réglages de prototype à confirmer à l'écoute du porteur**. Sources et fichiers : `design/Credits_audio.md`.
- **Pas encore fait** : aucun son d'interface câblé (clic, achat sont au catalogue mais non déclenchés), pas de musique, pas de réglage de volume dans l'interface (à soumettre au porteur).
- **Contrôles** : `test_sound_director.gd` (75 contrôles : instants, regroupement, rejeu après nouvelle vague, fichiers présents). Lecture réelle désactivée en mode sans écran. Les sons n'ont pas été écoutés par l'agent.
- Aucune règle de jeu modifiée.
