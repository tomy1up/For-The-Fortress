# Boutique · Pyromancien humain

Visuel du type 15 (`alliance.pyromancer`) approuvé par le porteur le 14 novembre 2026. Le personnage porte une tunique vermillon à col safran et conjure une flamme au-dessus de sa paume. La pose et la flamme se distinguent sur le plateau des bâtons du Mage humain et du Chaman orc.

[Comparatif avec les deux lanceurs de sorts de base](essais/boutique_guetteurs/Pyromancien_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur | Origine du tir |
| --- | --- | --- | ---: | --- |
| `pyromancien_humain_v001.png` | `Rect2(0,0,1076,1195)` | `(430,1195)` | 60 px | `(24.5,-47.0)` |

Portrait en boutique, déblocage, recrutement et premier tir vérifiés sur la copie v0.197. Les 60 contrôles du test d’illustrations passent. Le sprite est fixe. La copie reprend le projectile du Mage humain. Le branchement doit prévoir un projectile de feu et conserver les règles actuelles de brûlure.

## Incantation et départ de la flamme

Le Pyromancien ramène sa main pour faire monter la flamme, la resserre puis pousse de la paume avec l’épaule. La boule se détache pendant que le bras accompagne le lancer. Le col safran et les proportions du personnage sont conservés. Les semelles restent ancrées. La première et la dernière image de chaque planche sont identiques à la garde.

Trois inclinaisons, 20 poses sur 0,64 s. Le projectile prend le relais à 0,288 s, sur la première image à paume vide. Les centres de départ par rapport aux pieds sont dans `lachers.json`. Dans l’essai, le projectile suit d’abord l’inclinaison choisie puis rejoint la cible. Le décalage concerne le rendu du projectile, de l’impact et de la brûlure. Le modèle continue de résoudre les dégâts et les tics aux instants actuels.

[À taille native ×1](essais/gestes_combat/pyromancien_incantation/Pyromancien_tir_x1.gif) · [À taille native ×2](essais/gestes_combat/pyromancien_incantation/Pyromancien_tir_x2.gif) · [Vue agrandie](essais/gestes_combat/pyromancien_incantation/Pyromancien_tir_agrandi.gif)

Essai sur copie v0.216 à La Grande Salle (mission 94) avec un Capitaine orc placé sur la route haute. Lancer descendant vers la droite en E1 et lancer horizontal vers la gauche en E2, à ×1, ×2 et à temps figé. Les 60 poses tiennent dans leurs cadres. Validateur : 32 dossiers, 0 problème. Bibliothèque : 173 contrôles. [Planches en revue](essais/gestes_combat/pyromancien_incantation/). Le raccord des angles et du projectile reste à intégrer dans la version publiée.

## Buste plus stable

Le 16 novembre, le porteur juge le pivot du buste excessif. La reprise réduit l’inclinaison maximale d’environ 16° à 5° et atténue l’avance du buste. L’impulsion reste lisible dans l’épaule, l’avant-bras et la paume. Les centres du projectile, le lâcher à 0,288 s et les appuis sont conservés. Quelques pixels isolés près du gant ont été retirés.

[Comparatif à ×1](essais/gestes_combat/pyromancien_incantation/buste_stable/Pyromancien_buste_comparatif.gif) · [Version corrigée à ×2](essais/gestes_combat/pyromancien_incantation/buste_stable/Pyromancien_buste_x2.gif)

Comparaison de l’essai v0.216 avec la reprise sur une copie v0.219, sur la mission 94 dans les mêmes conditions. Départ dans les deux sens contrôlé à ×1, ×2 et à temps figé. Les trois planches sont au format `attack`, `attack_up12`, `attack_down12` de la bibliothèque actuelle. Les 60 poses sont cadrées et chaque cycle se raccorde à la garde. Validateur : 32 dossiers, 0 problème. Bibliothèque : 173 contrôles. La reprise attend l’avis du porteur.
