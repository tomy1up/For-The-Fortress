# Boutique · Arquebusière naine

Visuel approuvé par le porteur le 14 novembre 2026 (`6afb975`). Le type 12 (`alliance.arquebusier`) utilise actuellement le libellé « Arquebusier nain ». L’arquebusière porte deux tresses châtains, une brigandine framboise et une cape sur une épaule. Elle tient une arquebuse de fer et de bois en diagonale, avec les genoux fléchis.

[Comparaison avec l’arbalétrier et le mousquetaire](essais/boutique_guetteurs/Nains_arbaletrier_mousquetaire_arquebusiere.jpg) · [Carte de boutique en essai](essais/boutique_guetteurs/Boutique_Arquebusiere.jpg)

| Type | Fichier portrait et plateau | Cadre | Pied | Hauteur | Origine du tir |
| --- | --- | --- | --- | ---: | --- |
| 12 | `arquebusier_nain_v001.png` | `Rect2(0,0,1209,999)` | `(440,999)` | 55 | `(40.5,-41.25)` |

Les proportions compactes prennent pour référence l’arbalétrier nain. La carrure reste plus fine, avec un buste ajusté et des jambes courtes.

Sur une copie isolée v0.197, le portrait apparaît dans la boutique et l’unité se débloque, se recrute au Gué et tire. Comparaison au même emplacement avec l’arbalétrier de base et le mousquetaire nain. Le contrôle étendu des illustrations donne 45 réussites. Le projectile et le libellé de la copie sont ceux du prototype actuel. À l’intégration, proposer « Arquebusière naine » comme libellé et un rendu de projectile cohérent avec l’illustration.

## Tir et retour en joue

L’Arquebusière naine avance légèrement l’épaule, encaisse le recul puis reprend la pose de garde. Les bottes restent ancrées. Les deux mains et l’arme suivent la même transformation. La cape suit le mouvement avec un léger retard. L’attaque compte 12 poses sur 0,18 s. Le retour est identique à la garde pixel pour pixel. La planche de repos évite une seconde impulsion issue de l’ancien rendu.

[À taille native, ×1](essais/gestes_combat/arquebusiere_naine/Arquebusiere_tir_x1.gif) · [À taille native, ×2](essais/gestes_combat/arquebusiere_naine/Arquebusiere_tir_x2.gif) · [Vue agrandie](essais/gestes_combat/arquebusiere_naine/Arquebusiere_tir_agrandi.gif)

Sur une copie v0.216, l’Arquebusière a été achetée puis placée en E1 et E2 au Gué. Vérification du tir à gauche et à droite à ×1 et ×2, avec recadrage identique à temps figé. En E1, la séquence enchaîne trois tirs à ×1 et six à ×2. En E2, la première cible ne reste à portée que pour un tir dans chaque séquence de contrôle. Validateur : 27 dossiers, 0 problème. Bibliothèque : 168 contrôles.

La balle et le bref éclat de poudre partent à 0,045 s, sur la pose n° 4, depuis le bout du canon. Point de départ relatif au pied `(±43,687 ; −40,959)` en pixels de jeu. Le point est fourni par le champ `muzzle` de la description. Le délai et le bref éclat ont été essayés dans le rendu de la copie. La cadence et la résolution des dégâts sont celles du modèle actuel. La planche de repos et l’attaque restent en [revue artistique](essais/gestes_combat/arquebusiere_naine/defender.alliance.arquebusier/) avant branchement par Claude.
