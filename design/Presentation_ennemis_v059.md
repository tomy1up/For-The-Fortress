# Présentation des ennemis — v0.59

26 octobre 2026. Sixième lot de présentation, dans les [orientations validées](Orientation_presentation_2026-10-26.md), après le [bilan essentiel](Bilan_essentiel_v058.md).

## Silhouettes réalisées

Les huit profils existants sont redessinés avec des contours sombres, des visages plus lisibles et des équipements reconnaissables. Les formes sont produites par le code du projet, sans asset externe. Cette passe poursuit la direction cartoon des défenseurs ; les personnages restent des visuels de prototype.

| Profil | Signes distinctifs |
| --- | --- |
| Grouillant | Petite silhouette sous une capuche pointue, petit couteau |
| Pillard | Tunique rouge, ceinture, calotte métallique et épée droite |
| Sprinter | Corps penché, foulard flottant et lame courte |
| Brute | Torse massif, bras nus et grosse massue de bois |
| Maraudeur | Harnais croisé et deux haches latérales |
| Colosse | Corps très large, plaques carrées, casque fermé et marteau lourd |
| Élite | Casque à crête, bouclier pointu violet à emblème et lance |
| Seigneur de siège | Couronne, cape écarlate, grandes épaulières et épée |

Les équipements sont décoratifs et ne créent aucune résistance, protection ou capacité. Les couleurs de référence sont conservées, y compris dans la prévision des vagues. Les proportions et les armes complètent la couleur pour distinguer les profils.

## Intégration sur la carte

Les échelles relatives des huit types restent identiques. La marche conserve son mouvement de jambes et son temps de simulation existants. Aucun déplacement de route, collision, nouvelle animation de comportement ou tirage aléatoire n’est ajouté. Les acteurs gardent leur ordre de profondeur.

Les jauges de vie sont relevées de trois pixels avant application de l’échelle du profil, afin de dégager les casques et la couronne. Le rectangle de détection au survol reste identique. Les marqueurs de malédiction, l’anneau de sélection, le suivi du boss et les impacts continuent de refléter les effets réels.

## Vérification

**34 suites, 14 855 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les contrôles existants d’inspection couvrent les huit types, les PV fractionnaires, le boss, les malédictions, les ennemis superposés et l’absence de pause pendant la lecture. Les tests de prévision continuent de comparer les couleurs aux profils en combat.

Aucun test permanent supplémentaire n’est ajouté pour ce dessin statique. La validation graphique réutilise le catalogue des huit ennemis, les inspections du boss, les effets, les captures de combat et les campagnes de référence. La distribution Windows et le contrôle natif sont consignés dans Distribution_Windows_v059.json.

## Périmètre

Cette passe travaille exclusivement l’apparence des profils existants. PV, vitesse, dégâts à la forteresse, récompenses, compositions des vagues, effets et ciblage sont identiques. Aucune progression permanente. La reconnaissance immédiate de ces silhouettes reste à confronter au joueur.

GDD principal v0.14. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Contrôle final du paquet

**74 lancements, 73 captures et dix empreintes locales concordantes.** Le [catalogue des huit profils](essais/captures/QA-v059_catalogue.png) et l’[inspection du boss](essais/captures/QA-v059_boss.png) ont été inspectés. Le catalogue juxtapose les profils à des fins de contrôle ; il ne représente pas une composition de vague approuvée.

Un contrôle natif séparé du même exécutable a été effectué sur l’écran de droite : Alliance, budget normal de 150 or, première vague sans défense à vitesse ×1. L’[inspection d’un Pillard](essais/captures/QA-v059_inspection_native.jpg) à la souris affiche 40/40 PV, une menace de 1 PV pour la forteresse et une récompense de 3 or, conformes au modèle. Le journal dédié ne contient aucune erreur et le jeu a été fermé. Ce contrôle partiel opéré par l’agent ne constitue ni un nouveau retour joueur ni une validation générale d’équilibrage.
