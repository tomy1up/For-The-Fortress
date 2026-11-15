# Boutique · Piquier humain

Visuel du type 14 (`alliance.pikeman`) validé par le porteur le 14 novembre 2026 (`51cda5e`). Le piquier porte un gambison bleu clair à bandes écrues et tient sa pique debout. Le long manche vertical et la silhouette d’un soldat en armure légère le distinguent du capitaine de garnison.

[Comparatif, plateau et boutique](essais/boutique_guetteurs/Piquier_humain_comparatif.jpg)

| Fichier portrait et plateau | Cadre | Pied | Hauteur |
| --- | --- | --- | ---: |
| `piquier_humain_v001.png` | `Rect2(0,0,678,1398)` | `(317,1398)` | 69 px, pique comprise |

Le portrait, le recrutement et la première attaque ont été vérifiés sur une copie v0.197. Les 55 contrôles d’illustrations passent. Le sprite est fixe et la copie affiche une flèche lors de l’attaque. L’intégration doit associer un rendu de coup de pique à courte portée en conservant les règles de combat.

## Premier essai animé

Trois poses à deux mains ont été dessinées d'après le Piquier existant avec le générateur d'images intégré. La planche aligne les appuis et joue l'extension, le retrait puis le retour à la garde verticale en 0,44 s. Le coup commence sur l'image d'extension, à l'événement d'attaque. Le dessin ne montre pas d'armé avant le contact. La pointe suit le côté de la cible et conserve un angle fixe. Sur les cibles décalées en hauteur, elle ne rejoint donc pas précisément le point d'impact.

Sur une copie v0.197, la flèche a été masquée pour le seul type 14. L'effet d'impact existant reste visible. Premières attaques vérifiées au Gué depuis E1 et E2, à ×1 et ×2. L'arrêt simulé conserve le même cadrage dans les quatre essais. Validateur : 25 dossiers, zéro problème. Bibliothèque : 157 contrôles réussis. Les fichiers restent dans les études, en attente d'avis du porteur.

[Comparaison en jeu](essais/gestes_combat/Piquier_essai_attaque.gif) · [Poses dessinées](essais/gestes_combat/Piquier_poses_attaque.png)

## Estoc avec prise à deux mains

Le Piquier part de la garde verticale validée. Il abaisse la pique, amène la main libre sur le manche, recule légèrement le buste puis pousse vers la jambe avant. Le manche reste rigide entre les mains jusqu’au retrait. Les semelles gardent leur point d’appui. La première et la dernière image de chaque cycle reprennent la garde à l’identique.

Trois angles (−12°, 0° et +12°), 20 poses chacun sur 0,64 s. Le contact visuel commence à 0,256 s. Le point de la pointe est donné par `contact.json` pour chaque angle. La copie d’essai utilise la pique de la planche et un bref éclat à sa pointe. Le moteur continue de résoudre les dégâts au déclenchement de l’attaque.

[À taille native ×1](essais/gestes_combat/piquier_estoc/Piquier_estoc_x1.gif) · [À taille native ×2](essais/gestes_combat/piquier_estoc/Piquier_estoc_x2.gif) · [Vue agrandie](essais/gestes_combat/piquier_estoc/Piquier_estoc_agrandi.gif)

Sur une copie v0.216, le Piquier a été acheté et recruté en E1 et E2 à La Grande Salle (mission 94). Premier estoc contrôlé sur un Capitaine orc placé sur la route haute, à droite vers un impact plus bas, à gauche vers un impact plus haut. Les deux cas passent à ×1, ×2 et à temps figé. Les 60 poses tiennent dans leur cadre. Validateur : 31 dossiers, 0 problème. Bibliothèque : 172 contrôles. Le porteur valide le geste le 15 novembre. [Planches retenues](essais/gestes_combat/piquier_estoc/). Le branchement des angles et de l’impact reste à faire.
