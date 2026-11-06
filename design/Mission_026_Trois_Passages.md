# Mission 26 — Les Trois Passages des Ardoises

La mission introduit une troisième entrée sur une carte du biome montagneux. Son nom, son tracé et ses chiffres restent des propositions de prototype.

Trois branches convergent vers une forteresse. Les routes haute et basse mesurent 28 unités logiques et la route centrale 24. Les 17 dernières unités sont communes. Les six emplacements permettent de défendre les approches ou de concentrer la défense sur la partie commune.

Les apparitions alternent entre les trois entrées à tour de rôle. La première vague répartit ses dix ennemis en 4, 3 et 3. Les vagues suivantes suivent la même règle. Le ciblage privilégie l’ennemi qui atteindra la forteresse le plus tôt, en tenant compte de sa vitesse et de la distance restante sur sa route.

| Réglage d’essai | Valeur |
| --- | --- |
| PV ennemis | 125 % de la référence |
| Vagues | Dix, calendrier de référence |
| Emplacements | Six |
| Première victoire | 60 PO et 100 XP |
| Déverrouillage | Mission 25 réussie dans la même faction |

## Lecture des trois entrées

Les repères et les aperçus utilisent trois couleurs distinctes. Les groupes de la prochaine vague affichent leur répartition par entrée. Le survol d’un repère montre son chemin.

L’aperçu avant achat et les spécialisations qui changent la portée prennent les trois routes en compte. Le compteur de combat, le bilan par vague et les rapports exportés incluent les arrivées par la troisième entrée.

Le terrain et la répartition sont éprouvés dans un atelier de capture isolé, avec l’argument de contrôle `--atelier-trois`. La mission du parcours applique les règles habituelles de progression.

## Validation et limites

Le relevé local `dist/slate-mission26.json` compare 144 politiques fixes avec les douze points de talents disponibles avant cette mission, trois graines, trois dispositions, quatre compositions et deux configurations de talents. L’Alliance remporte 71 cas sur 72 et la Horde 60 sur 72. Ce résultat décrit cet échantillon et laisse la difficulté en première découverte à évaluer en jeu.

Le contrôle d’intégration vérifie le parcours normal, une victoire avec les achats autorisés, la relecture du rapport, les gains uniques puis leur conservation après réouverture d’un profil temporaire dans les deux factions.

Les contrôles dédiés vérifient les trois compteurs, les couleurs, les limites de texte, les survols, les aperçus de portée et la séparation entre descriptions de spécialisation et boutons. Les captures Windows couvrent la préparation, l’achat, les spécialisations, le bilan et le lancement depuis le parcours.

Les missions 29 à 200 restent à développer. L’introduction d’un attaquant ou d’un affixe propre au biome reste prévue pour le chapitre 4.
