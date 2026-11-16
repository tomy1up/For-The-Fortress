# Prototype v0.223 — Lisibilité : bandeau d'affixe et marqueurs d'effets

Réglages de lisibilité dessinés par le code (habillage de prototype à confirmer par le porteur) :

- **Bandeau d'affixe** (`valley_view.gd::affix_banner`) : pendant un combat, un bandeau au-dessus du plateau annonce l'événement de la mission avec un compte à rebours et son effet. Annonce (orange, pulsé) puis événement en cours (rouge), avec une barre de temps restant : « Éruption dans 2 s · E4 sera désactivé », « Tempête de sable · encore 4 s · portée −25 % », « Brume marine dans N s · or −30 % », « Éboulement · entrée 2 bloquée ». Les Vents contraires affichent un rappel permanent (bleu) « cadence −10 % ». Les repères au sol existants (planches de Codex, losange, cendres) sont conservés.
- **Marqueurs d'effets de boutique plus lisibles** : pastilles de marque, de pillage et de volatilité de 16 à 22 px sur un disque sombre cerclé de leur couleur (rose, or, orange) ; anneau de ralentissement et marque d'aura agrandis d'environ un tiers.
- **Contrôles** : `test_affix_banner.gd` (19 contrôles : texte, état et temps de chaque affixe, dessin sans erreur) ; captures contrôlées sur Éruptions et Tempête de sable, et sur les marqueurs de marque, de pillage, de volatilité et de ralentissement.
- Aucune règle de jeu modifiée.
