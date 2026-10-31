# Forteresses et souverains — prototype v0.104

## Demande et statut

**V :** une forteresse dans le style cartoon des unités, avec un roi au sommet, chacun propre à sa faction ; animations du souverain, notamment lorsqu’une perte de PV survient. **H :** silhouettes, costumes, choix artistiques et durées proposés dans ce lot. Ces propositions originales ne deviennent pas des choix artistiques définitivement approuvés par leur seule intégration au prototype.

Alliance : pierre claire, toitures bleues, détails dorés ; souverain à couronne d’or, barbe grise et manteau bleu. Horde : bois, ferrures, toitures rouges et défenses d’ivoire ; souverain orc à couronne de métal, manteau sombre et cape rouge. Les deux bâtiments et les deux souverains sont des illustrations distinctes, avec vrais fonds transparents, dans la direction des personnages existants. Aucun emblème ou personnage d’une licence tierce n’est repris.

## Animations réalisées

Chaque souverain dispose de quatre poses dessinées : repos, encouragement, blessure et défaite. De légers mouvements de l’illustration entière accompagnent ces poses ; les membres ne disposent pas encore d’une animation squelettique ou image par image complète.

| Événement | Présentation |
| --- | --- |
| Attente ou préparation | Roi au repos, léger mouvement de respiration |
| Départ réel d’une vague | Poing levé et encouragement pendant 1,1 seconde |
| Arrivée d’ennemis avec perte réelle de PV | Réaction corporelle et visage crispé pendant 0,65 seconde ; bref tremblement et éclaircissement du bâtiment |
| Impact fatal | Réaction au dernier choc, puis roi tête baissée ; bâtiment assombri et état « Forteresse détruite » |
| Soin ou renforcement de la forteresse | L’état du bâtiment suit les PV ; aucun faux signal de blessure |
| Nouvelle mission ou nouvelle tentative | Retour au repos, sans réaction héritée de l’ancienne partie |

La blessure est prioritaire sur l’encouragement, y compris lors du dernier impact. Une arrivée supplémentaire relance la réaction, sans cumuler les amplitudes. Le roi reste vivant et debout dans la pose de défaite : aucune animation d’effondrement ou de mort n’est annoncée ici.

Les durées royales utilisent le temps réel de présentation, afin de laisser la réaction lisible en vitesse ×2 ou ×10 de débogage. Elles ne ralentissent ni ne suspendent le combat. Les conditions de dommages déjà présentes suivent toujours les proportions de PV : normal, endommagé, en danger et détruit. Fissures, fumée et légende accompagnent les illustrations ; elles ne créent aucun effet de gameplay.

## Implantation et lisibilité

Le bâtiment et le roi sont séparés pour animer le souverain sans déformer l’architecture. Les quatre poses partagent une échelle commune et un ancrage sur les bottes ; une pose recroquevillée ne se retrouve pas artificiellement agrandie. La bannière est décalée sur le côté et ne traverse pas sa couronne.

La cour de présentation est allongée de 16 pixels vers la droite pour dégager les emplacements proches des nouveaux bâtiments. Le centre visuel est désormais à `(68 ; 26)` par rapport à la projection de la fin de route, contre `(52 ; 26)` pour les anciennes formes géométriques. C’est un ajustement de dessin : le point d’arrivée logique, les distances de route, les emplacements et les portées restent inchangés. L’alerte de perte de PV se place au-dessus de la nouvelle silhouette, sans masquer le visage du roi.

Les six centres de placement sont vérifiés hors de la silhouette réservée sur les vingt missions. La végétation tient compte de l’encombrement agrandi ; sa disposition peut donc évoluer. Les souverains sont décoratifs : ils ne sont ni des défenseurs recrutables, ni des cibles supplémentaires, et n’accordent aucun bonus.

## Origine des illustrations et sources

Création avec **ImageGen intégré**, à partir des illustrations du projet comme références de style. Les PNG originaux et leur transparence sont conservés dans `prototype/assets/fortresses/` :

- `forteresse_alliance_v001.png` et `forteresse_horde_v001.png` : bâtiments sans personnage intégré ;
- `roi_alliance_v001.png` et `roi_horde_v001.png` : atlas de quatre poses chacun.

Les [prompts finaux](concepts/Forteresses_souverains_v001_prompts.json) sont conservés. Les régions et points d’ancrage de rendu sont décrits dans `fortress_art.gd`, sans retouche des pixels des PNG. Les nouveaux assets sont explicitement sélectionnés dans l’export et couverts par les empreintes de sources.

## Travail restant

Affiner ces propositions après retour du porteur du projet ; enrichir les transitions et les membres si nécessaire. Le chantier des cycles de marche des attaquants et des gestes d’attaque des défenseurs reste distinct. Les cartes à plusieurs forteresses restent à concevoir, notamment leurs PV et conditions de défaite : cette version ne les implémente pas.

## Vérifications de livraison

**88 suites, 36 772 contrôles Godot et 17 tests Python** passent. Le nombre de contrôles de décor varie avec la nouvelle silhouette : il ne représente pas une régression fonctionnelle. La suite royale ajoute 438 contrôles : fonds transparents, atlas et poses, ancrages, géométrie, vingt missions et liens avec les vrais événements. Les empreintes des sources de la régression concordent encore après la compilation. [Rapport complet](essais/v0104_regression.json).

Le programme Windows passe **21 cas ciblés sur 255 disponibles**, produit 20 captures et compare 68 sources. Les quatre poses royales sont contrôlées dans les deux factions, ainsi que les quatre états des forteresses, l’alerte de brèche, les rapports et le profil protégé. Ce n’est pas une vérification native exhaustive. [Rapport Windows](Distribution_Windows_v0104.json), [contrôles complémentaires](essais/v0104_validation_complementaire.json).

L’[atelier animé agrandi](essais/captures/QA-v0104_forteresses_souverains.gif) utilise le moteur complet chargé sur les ressources du paquet : 150 échantillons à 30 images/s, deux factions, quatre poses. Les pertes de PV proviennent des arrivées du modèle, avec une séquence de vagues abrégée pour présenter les états ; cet atelier n’est pas une partie jouée. Les poses d’encouragement, blessure et défaite ont été inspectées. Les vues de plateau Alliance au repos et Horde après dégâts ont également été examinées depuis le projet. [Encouragement Alliance du paquet](essais/captures/QA-v0104_Alliance_encouragement.png), [Dégâts Horde du paquet](essais/captures/QA-v0104_Horde_degats.png).

Le manifeste garde les mêmes empreintes pour le modèle de combat, les rencontres, les talents, l’économie, la sauvegarde et les textures d’unités déjà livrées. Les nouvelles illustrations et leur module ajoutent neuf sources à l’export. Aucune remise à zéro de progression ni changement de point d’arrivée logique.
