# Sanglier — étude de peau continue

2 novembre 2026. **Essai non approuvé, hors du jeu distribué.** La v0.109 demeure la version jouable ; ce dossier ne modifie aucun script de production, profil, talent, récompense ou valeur de combat.

## Intention

Préparer une animation du sanglier neutre, commun aux deux factions, avec un dessin continu aux épaules et aux hanches. La démarche du loup reste sa propre référence approuvée ; elle n’est pas simplement appliquée à cette silhouette plus compacte.

La base `sanglier_proche_source_v001.png` a été produite avec l’outil ImageGen intégré, à partir de l’identité du sanglier de `prototype/assets/enemies/rosters/neutres_v001.png`. [Consigne et provenance](PROMPTS.md). Elle contient le tronc, la tête, la queue et les deux membres proches sur une seule couche. Les membres éloignés sont reconstruits derrière cette couche pendant le rendu ; le personnage animé possède bien quatre membres.

L’allure est une proposition chorégraphiée, pas un mouvement échantillonné d’un sanglier réel. Les appuis alternent par paires diagonales. La foulée de 700 pixels source, les amplitudes et les phases sont des réglages d’essai. Le rendu respecte la vitesse actuelle du profil Sprinter : 1,65 unité de carte/s, soit environ 49,81 pixels/s sur une diagonale du plateau. À la taille actuelle, le cycle dure environ 0,462 seconde. Il n’y a pas de modification de cette vitesse dans le jeu.

## Construction et limites

La peau est déformée par un calcul ARAP à contraintes de surface, avec ancrages du corps et des sabots. Les repères internes de coude et de jarret enrichissent la topologie mais ne sont pas des points imposés à la peau : leur première utilisation comme contraintes rigides retournait le raccord du membre. Le résultat n’est donc pas une garantie de respect des longueurs des os sous le dessin. L’anatomie apparente doit encore être jugée visuellement.

Les sommets libres sont interpolés par courbes cubiques à tangentes communes ; les ancrages suivent des trajectoires linéaires par morceaux. Le début et la fin des appuis sont placés sur la grille temporelle d’export, afin de ne pas mélanger un morceau de phase d’appui avec le début du retour du sabot. Une première durée d’appui de 60 % produisait une erreur de contact de 0,226 pixel source à la frontière des phases ; la durée actuelle de 38/64 du cycle aligne ces frontières. Ce choix est une hypothèse d’animation, pas une règle de gameplay.

La couche éloignée utilise un masque propre au sanglier et un assombrissement modéré. Les textures sont filtrées avec des niveaux de détail dans le rendu réduit. Les vidéos montrent un atelier horizontal isolé, avec repères défilants ; elles ne constituent pas un essai en mission. Le placement sur les diagonales du plateau et les réactions aux dégâts restent à contrôler avant toute intégration. Aucune validation artistique du porteur n’est déduite des contrôles mathématiques.

## Livrables à examiner

- `sanglier_allure_rapide_essai.mp4` : 144 images, 60 images/s, 2,4 secondes, deux sens et aperçu à la taille du plateau.
- `sanglier_proche_source_v001.png` : source transparente, conservée sans modification après génération.
- `smooth_walk.json` et `smooth_walk_far.json` : courbes finales expérimentales ; elles ne sont pas exportées dans le programme du jeu.
- `controle_pipeline.json`, `controle_interpolation_lissee.json` et `controle_appuis_rendu.json` : périmètres et résultats techniques exacts.

Les aperçus retenus et les observations d’autocontrôle sont consignés dans `QA_etude.json`. Les contrôles de maillage, d’appui et de cadence servent à éliminer des défauts ; ils ne prouvent pas à eux seuls le naturel de la démarche.

Le candidat courant comporte 1 309 sommets et 2 280 triangles par couche, sur 128 intervalles cubiques. Le certificat indépendant ne relève ni aire négative ni intervalle indéterminé. La lecture native compare 41 888 coordonnées de sommets sur seize phases par couche, avec un écart maximal d’environ 0,000069 pixel source. Le contrôle des appuis compare 78 016 positions de sabots sur deux cycles ; aucun écart n’est mesuré sur ces échantillons. Ces chiffres décrivent le contrôle géométrique, pas l’anatomie.

## Reproduire l’étude

Depuis la racine du dépôt, exécuter avec Python et NumPy disponibles :

```powershell
python design/essais/sanglier_peau_continue/build_study.py
```

Le script accepte `--engine` et `--ffmpeg` si les outils sont ailleurs. Il utilise Godot 4.7.2 standard et lance les fenêtres graphiques minimisées sur `--screen 1`. Aucun appel à un service de génération d’image n’est effectué pendant cette reconstruction. Le dessin source déjà enregistré est réutilisé.

Le calcul reprend les outils géométriques de l’étude du loup sans les modifier. Les entrées et fichiers intermédiaires volumineux sont régénérés dans `captures/` ou à côté des courbes, puis ignorés par Git ; les courbes finales et leurs rapports sont conservés. Le script arrête le traitement si un journal Godot contient une erreur, même lorsque le moteur renvoie le code de sortie zéro.

For the Fortress! est un nom de travail dont la disponibilité juridique reste à confirmer.
