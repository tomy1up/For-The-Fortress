# Vents contraires — premier essai du chapitre 4

## Décisions du porteur

Les missions 31–40 introduiront l'affixe montagneux **Vents contraires**. Le premier réglage d'essai réduit la cadence de tous les défenseurs de 10 %. Les dégâts périodiques déjà appliqués gardent leur rythme.

## Périmètre livré en v0.155

La mission 31 est jouable au Col des Ardoises après la réussite de la mission 30 dans la même faction. Elle reprend les deux routes du Col avec dix vagues, six emplacements et une forteresse. Les PV ennemis atteignent 130 % de la référence, suivant la courbe d'essai existante. Les missions 32–40 restent à produire.

L'affixe est annoncé sur la fiche de mission et reste visible sous le nom de la carte pendant le combat. Le survol explique les bénéficiaires et l'exception concernant les dégâts périodiques.

## Règles de calcul

La cadence effective est multipliée par 0,9. L'intervalle entre deux attaques est donc divisé par 0,9. Une attaque chaque seconde devient une attaque toutes les 1,111… secondes. Le bonus temporaire de cadence conserve son calcul habituel avant l'application du vent.

Toutes les attaques des défenseurs sont concernées, y compris celles des unités de boutique et du chaman. Les malédictions déjà posées conservent leurs dégâts, leurs deux échéances et leur intervalle d'une seconde. Le vent peut réduire la fréquence des nouvelles applications par le chaman.

Les aperçus d'achat et d'amélioration utilisent les statistiques affectées. Dégâts par attaque, portée, limites des explosions et rebonds restent identiques. La configuration est fixée avant le lancement et ne change pas au cours d'une mission.

Chaque première victoire rapporte les 60 PO et 100 XP habituels. Les acquis et le parcours restent indépendants par faction. Les nouvelles données de combat ne changent pas le format des sauvegardes de progression.

Les rapports des missions affectées enregistrent l'identifiant de l'affixe et son pourcentage effectif. Le rejeu les restaure avant toute action. Les rapports antérieurs sans ce champ conservent leur cadence historique.

## Comparaison contrôlée

Le relevé local `dist/slate-mission31-paired.json` compare les mêmes 144 stratégies avec et sans vent. Il conserve le terrain, les PV à 130 %, quinze points de talents acquis avant la mission, trois graines, trois dispositions, quatre compositions et deux choix d'arbre. Chaque stratégie est automatique et choisit le premier bonus proposé.

| Faction | Sans vent | Avec −10 % de cadence |
| --- | --- | --- |
| Alliance | 70 victoires sur 72 | 36 sur 72 |
| Horde | 36 sur 72 | 7 sur 72 |

Le changement est sensible dans ce panel, particulièrement côté Horde. Ces résultats décrivent uniquement les stratégies essayées. Ils ne valident pas l'équilibrage humain. Deux combats gagnants par le parcours réel sont contrôlés avec les dépenses normales et les points légalement acquis, puis leurs rapports sont rejoués et le crédit unique est vérifié.

## Validation et suite

9 611 contrôles Godot ciblés et neuf essais du paquet Windows réussissent. Les captures du parcours et du plateau ont été inspectées visuellement. Les profils réels du joueur ne sont pas utilisés dans ces essais.

Le dosage reste à évaluer en jeu avant extension aux missions suivantes. L'introduction des autres affixes, les combinaisons au-delà de la mission 100 et les cumuls du mode infini restent des travaux ultérieurs.
