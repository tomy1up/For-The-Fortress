# Présentation des attaques — v0.56

26 octobre 2026. Troisième lot de présentation après les [silhouettes des défenseurs](Presentation_defenseurs_v055.md), dans les [orientations validées](Orientation_presentation_2026-10-26.md).

## Attaques reconnaissables

Les attaques utilisent des formes originales dessinées par le jeu. La forme accompagne la couleur pour distinguer les six classes, sans ajouter de particules permanentes ni masquer les ennemis avec des aplats opaques.

| Défenseur | Projectile et trajectoire | Impact |
| --- | --- | --- |
| Archer elfe | Flèche longue et fine, pointe claire et empennage, liaison directe depuis l’arc | Anneau doré et quatre traits brefs |
| Arbalétrier nain | Carreau plus court et épais, pointe claire, liaison directe depuis l’arbalète | Anneau clair et traits brefs |
| Mage humain | Orbe bleu avec centre lumineux, depuis le cristal du bâton | Marque bleue, contour exact du rayon et onde intérieure discrète |
| Lanceur de haches troll | Petite hache tournoyante suivant une cloche légère depuis la main armée | Marque verte et liens fléchés entre les véritables rebonds successifs |
| Sapeur gobelin | Bombe ronde avec mèche lumineuse, cloche plus haute depuis la bombe tenue | Marque orange, contour exact du rayon et onde intérieure discrète |
| Chaman orc | Losange violet depuis le totem, accompagné d’un éclair anguleux | Losange violet ; les marques existantes de malédiction continuent de suivre les effets réels |

Les marques principales sont plus fortes que celles des victimes secondaires. Les effets d’explosion partent du premier impact ; les rebonds relient chaque victime à la suivante. Aucun marqueur n’est créé sur un ennemi seulement présent dans le rayon. L’onde intérieure ne dépasse jamais le rayon enregistré par le modèle. Le remplissage est réduit pour préserver la lecture de la route et des corps.

## Animation et simulation

Le déplacement du projectile dure **0,12 seconde simulée** ; les marques et traînées disparaissent sur la durée existante de **0,32 seconde simulée**. Le trajet est un habillage d’un tir déjà résolu : **la marque d’impact apparaît immédiatement et aucun dégât n’attend l’arrivée du dessin**. Aucun projectile logique, collision, poursuite de cible ou nouvel aléatoire n’est ajouté.

Les coordonnées viennent exclusivement du défenseur et du point d’impact enregistrés dans le tir. Le départ visuel correspond à l’équipement, avec un décalage en pixels ; le centre logique de portée et la géométrie de combat restent identiques. Les victimes secondaires proviennent de la liste existante. Le rendu ne recalcule pas les cibles.

Les mouvements des silhouettes de la v0.55 restent actifs. Les animations suivent les vitesses ×1, ×2 et le ×10 temporaire ; elles sont donc très brèves en débogage accéléré. Une fin de combat supprime les effets de tir comme auparavant. Aucun tremblement d’écran, flash plein écran ou son supplémentaire n’est introduit.

## Vérification

**32 suites, 14 681 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **60 contrôles nouveaux** vérifient les points de départ et d’arrivée, l’absence d’extrapolation, les trajectoires directes ou en cloche, les coordonnées finies pour des positions logiques identiques et la lecture sans mutation des tirs. Les six classes produisent de vrais tirs dont le rendu répété ne réécrit ni rapport, ni état du générateur, ni unités, ni effets enregistrés.

Les tests existants continuent de vérifier les véritables victimes secondaires, les rebonds successifs, les rayons exacts et les références de simulation. Le paquet ajoute six captures au milieu du déplacement visuel, en complément des six poses d’attaque et des effets existants. Les scènes à budget imposé servent au contrôle graphique et ne représentent pas des campagnes d’équilibrage.

Les résultats Windows et du contrôle natif sont consignés dans Distribution_Windows_v056.json.

## Périmètre et suite

Cette version habille les attaques existantes. Dégâts, cadence, ciblage, portée, prix, dix vagues, boss à 600 PV et préparation de 30 secondes restent identiques. Aucune progression permanente. Les aides de recrutement et d’amélioration restent un chantier de lisibilité possible ; la reconnaissance immédiate de ces nouveaux effets reste à évaluer avec le joueur.

GDD principal v0.14. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Contrôle final du paquet

**66 lancements, 65 captures et dix empreintes locales concordantes.** Les six nouveaux projectiles ont été inspectés dans les captures du paquet, avec leurs marques principales et secondaires.

[Mage — budget imposé](essais/captures/QA-v056_mage.png) · [Troll — budget imposé](essais/captures/QA-v056_troll.png) · [Chaman — budget imposé](essais/captures/QA-v056_shaman.png).

Un contrôle natif séparé du même exécutable a été opéré par l’agent sur l’écran de droite, avec le budget normal de 150 or : Alliance, archer E1 et mage E2, première vague à ×1. La [capture du combat](essais/captures/QA-v056_combat_natif.jpg), à 10,9 secondes simulées, montre 4 éliminés, aucun passé, 12 or et 20 PV. Le journal dédié ne contient aucune erreur et le jeu a été fermé. Ce contrôle partiel de lancement et de combat ne constitue ni une campagne complète, ni un nouveau retour joueur, ni une validation générale d’équilibrage. Les captures dédiées figent les projectiles, trop brefs pour être garantis sur une capture native ponctuelle.
