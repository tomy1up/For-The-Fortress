# Captures en séquence pendant un combat

Outil ajouté par Claude Code le 11 novembre 2026 pour contrôler en images ce qui se passe à des instants précis d'un combat (avertissement des Éruptions, désactivation, remous, apparition, mort…) sans lancer la partie à la main. Le temps est celui de la simulation : le résultat est identique sur toute machine et ne dépend pas de la vitesse du jeu.

## Commande

Depuis les sources (ou le jeu exporté, mêmes arguments), sur l'écran de droite :

```
Godot --path prototype --screen 1 -- "--capture=<dossier>/ash71.png" --capture-state=campaign_menu --capture-faction=<alliance|horde> --capture-campaign=<variante>play --capture-mountain-defence --capture-timeline=3,12,13.5,15,17
```

- `<variante>play` : la mission lancée avec deux défenseurs posés, comme pour les autres captures de mission (`ash71play`, `volcano61play`, `citadel87play`, `garrison94play`, `marsh51play`, `mountain31play`…).
- `--capture-timeline=` : instants de combat en secondes simulées, croissants, séparés par des virgules. Une image `<nom>_tNN.NN.png` est enregistrée à chacun (par exemple `ash71_t13.50.png`), plus l'image finale habituelle `ash71.png`.
- La sortie imprime une ligne `TIMELINE_FRAME={...}` par image (instant, phase, fichier et, pour les Éruptions, l'état exact : `warning` ou `active`, emplacement visé, temps restant).
- Ne pas utiliser `--minimized` ni `--background` : une fenêtre réduite peut ne jamais enregistrer l'image.

## Repères d'instants utiles

| Contrôle | Instants (s) | Mission de départ |
| --- | --- | --- |
| Éruptions : avant, début d'avertissement, fin d'avertissement, désactivation, fin | 3, 11, 13.5, 15, 19.5 | `ash71play` (Cratère Fumant), toutes les 14 s ensuite |
| Apparition et marche des ennemis | 1, 4, 8 | n'importe quelle mission |
| Régénération de Gueule-de-Vase | à régler selon la vague 2 de la mission 51 | `marsh51play` |
| Capitaine de garnison | vagues 5 et suivantes (au-delà de la première vague : voir limites) | `garrison91play` |

## Limites

- Seule la première vague est jouée. Pour voir une vague ultérieure, il faudrait enchaîner les vagues dans la commande, ce qui n'est pas encore prévu.
- Les deux défenseurs posés sont les deux premiers de la faction ; leur emplacement et leur type ne sont pas réglables.
- Les animations en temps réel (repos des défenseurs, vent) prennent l'horloge de la machine : leur phase peut varier d'une capture à l'autre.
