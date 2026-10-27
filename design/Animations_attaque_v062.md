# Orientation et mouvements d’attaque — v0.62

27 octobre 2026. Suite de la présentation des [six défenseurs illustrés](Assets_Alliance_v061.md), dans le style cartoon retenu.

## Comportement visible

Pendant le combat, chaque défenseur se tourne à gauche ou à droite selon le côté de la cible de son dernier vrai tir. L’orientation est conservée entre ses attaques ; le tir d’un voisin ne la change pas. Un événement futur est ignoré. Avant son premier tir, pendant la préparation et après la fin de vague, il retrouve l’orientation de repos de son illustration, vers la droite.

Le mouvement dure toujours **0,26 seconde simulée**, selon l’impulsion déjà utilisée depuis la v0.55 : zéro aux deux bornes, maximum au milieu. Les six classes utilisent maintenant des mouvements distincts de l’illustration entière. Le personnage tourne et se déplace autour de son ancrage au sol, sans écrasement ni étirement. L’ombre et les badges ne sont pas retournés avec lui.

| Classe | Lecture visuelle | Recul maximal | Inclinaison maximale | Élévation maximale |
| --- | --- | --- | --- | --- |
| Archer elfe | Traction et petit recul | 2,8 px | −0,035 rad | 0 px |
| Arbalétrier nain | Recul plus marqué | 4 px | −0,025 rad | 0 px |
| Mage humain | Légère élévation d’incantation | 0,8 px | +0,015 rad | 2,5 px |
| Lanceur de haches troll | Engagement du corps dans le lancer | 2 px | +0,070 rad | 1 px |
| Sapeur gobelin | Lancer avec petit bond | 1,6 px | +0,055 rad | 2 px |
| Chaman orc | Élévation et bascule du totem | 0,8 px | −0,025 rad | 2,5 px |

Ces valeurs sont des réglages de présentation ajustables après retour joueur, sans portée mécanique. Le signe de l’inclinaison est donné pour un tir à droite ; le mouvement est réfléchi pour un tir à gauche.

## Cohérence des tirs

Le départ du projectile utilise le point d’équipement de la classe, réfléchi selon le côté du tir. Il ne part plus de l’ancien côté lorsque l’image est retournée. Le côté est déterminé dans l’espace projeté de la carte, à partir des véritables points de départ et de cible du tir. En cas d’égalité horizontale, la droite est choisie de manière déterministe.

La trajectoire reste un habillage de l’événement déjà résolu. Les dégâts, malédictions, rebonds, explosions et récompenses ne sont pas retardés par cette animation. La trajectoire continue de finir sur le véritable point d’impact, même si le personnage tire ensuite ailleurs. Aucun tirage aléatoire n’est ajouté.

## Périmètre et limites

Les six PNG et leurs paramètres d’import sont conservés. Il s’agit encore d’une pose illustrée par classe, retournée et animée globalement : les bras, cordes, armes et jambes ne sont pas articulés indépendamment. Deux orientations horizontales sont disponibles ; il n’y a pas de rotation complète en huit directions. Les badges restent la distinction entre les niveaux et branches.

L’orientation est calculée à la lecture du journal de tirs de la vague, sans état d’animation persistant dans le modèle. Le rendu ne déplace pas les emplacements logiques, les cercles de portée, les zones cliquables ni les cibles.

Coûts, dégâts, cadences, portées, vagues, PV du boss, revenus, synergies, progression et enchaînement automatique restent identiques. Aucune progression permanente. GDD principal v0.14 ; For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Vérification

37 suites, **15 075 contrôles Godot** dont 174 nouveaux, **16 tests Python** et contrats du GDD réussis. Les contrôles dédiés couvrent les six classes, les deux côtés, l’égalité horizontale, le miroir des départs, la conservation des impacts, les bornes temporelles, l’absence d’étirement, la stabilité entre les tirs, les événements voisins ou futurs, la fin de vague et la nouvelle partie. Les tests de présentation existants continuent à vérifier les vrais tirs et l’absence de mutation du modèle ou du RNG lors des rendus répétés.

Le [rapport de régression](essais/v062_regression.json) et le [contrôle du paquet Windows](Distribution_Windows_v062.json) consignent les résultats. Les captures complémentaires de gauche utilisent le même scénario de combat réel à budget imposé, en plaçant cette fois le défenseur sur E1. Le vérificateur refuse ces captures si le tir observé n’est pas effectivement orienté vers la gauche. Ce sont des contrôles de présentation, sans nouvelle validation générale d’équilibrage ni retour humain.

## Paquet Windows vérifié

86 lancements, 85 captures et 24 empreintes locales concordantes. Les six classes sont vérifiées dans les deux sens, en pleine impulsion et pendant le vol du projectile. Le contrôle de gauche exige `ATTACK_FACING=-1` dans le journal du véritable tir. Les captures ont été inspectées, avec des exemples archivés pour l’[archer vers la gauche](essais/captures/QA-v062_archer_gauche.png), l’[arbalétrier vers la droite](essais/captures/QA-v062_arbaletrier_droite.png), le [troll vers la gauche](essais/captures/QA-v062_troll_gauche.png) et le [projectile du chaman retourné](essais/captures/QA-v062_chaman_gauche.png). Les catalogues et les écrans des deux factions restent lisibles. Les contrôles graphiques ont été exécutés sur l’écran de droite et les jeux de contrôle se ferment après capture.
