# Biomes et cumul de difficulté — 31 octobre 2026

Décisions de conception formulées par le porteur du projet dans le tchat. **For the Fortress!** reste un nom de travail ; disponibilité juridique à confirmer.

## Règles validées

**Un biome couvre deux chapitres consécutifs.** Les chapitres 1–2 partagent un premier biome, les chapitres 3–4 un deuxième, les chapitres 5–6 un troisième, et ainsi de suite. Avec dix missions par chapitre, un biome couvre vingt missions. Les noms, décors et caractéristiques de ces biomes restent à concevoir.

**Le second chapitre du biome introduit une nouveauté.** Les exemples donnés désignent les chapitres pairs 2, 4, 6, etc., et non les missions portant un numéro pair à l’intérieur d’un chapitre. Cela correspond aux blocs 11–20, 31–40, 51–60, etc., déjà retenus pour introduire des nouveautés.

La nouveauté peut être **de nouvelles unités attaquantes liées au biome**, ou **un affixe de biome** qui affaiblit les unités de défense ou renforce les unités attaquantes. Une unité attaquante n’est pas pour autant une nouvelle unité à recruter dans la boutique. Les règles existantes d’origine des attaquants restent applicables : faune neutre commune ou adversaires du camp opposé.

**Après la mission 100, la campagne combine progressivement les nouveautés précédentes tout en continuant d’en introduire.** Elle peut ainsi associer des attaquants déjà rencontrés et des affixes de biome. Le passage à la campagne avancée ne met pas fin au renouvellement du contenu.

**Le mode infini permet également cette accumulation au fil de sa progression.** Les unités attaquantes et les affixes créés pour les biomes constituent une base de défis pouvant se combiner pendant une progression en infini. L’intention validée est d’accroître la difficulté par ces combinaisons ; leur équilibrage reste à démontrer en jeu.

## Repères du parcours cible

| Biome à concevoir | Chapitres | Missions | Second chapitre : introduction |
| --- | --- | --- | --- |
| 1 | 1–2 | 1–20 | 11–20 |
| 2 | 3–4 | 21–40 | 31–40 |
| 3 | 5–6 | 41–60 | 51–60 |
| 4 | 7–8 | 61–80 | 71–80 |
| 5 | 9–10 | 81–100 | 91–100 |
| 6 | 11–12 | 101–120 | 111–120 |
| 7 | 13–14 | 121–140 | 131–140 |
| 8 | 15–16 | 141–160 | 151–160 |
| 9 | 17–18 | 161–180 | 171–180 |
| 10 | 19–20 | 181–200 | 191–200 |

À partir de la mission 101, les combinaisons de contenu antérieur peuvent donc déjà enrichir le premier chapitre d’un nouveau biome ; l’introduction propre à ce biome reste située dans son second chapitre. La répartition précise mission par mission n’est pas encore définie.

## Modalités encore ouvertes

- Liste et identité des biomes, des nouveaux attaquants et des affixes.
- Choix, pour chaque biome, entre nouveaux attaquants et affixe ; rythme détaillé d’introduction au sein du second chapitre.
- Paramètres affectés par les affixes, valeurs, durée et règles d’application.
- Réapparition du contenu antérieur avant la mission 101 et composition exacte des cumuls après ce palier.
- Nombre d’effets simultanés, incompatibilités éventuelles et règles de calcul quand plusieurs affixes touchent une même statistique. Aucun plafond ni règle d’addition ou de multiplication n’est encore validé.
- Paliers d’ajout, sélection des biomes, attaquants et affixes pendant le mode infini, ainsi que sa génération de terrain et ses objectifs de score.
- Présentation préalable des affixes pour que le joueur puisse préparer sa défense et comprendre leurs effets.

Le déblocage de l’infini reste lié aux cent premières missions réussies dans la faction concernée. Ces décisions n’ajoutent pas de récompense répétable en PO ou en XP : l’économie et les récompenses de l’infini restent à définir séparément.

## État de réalisation au 31 octobre 2026 et feuille de route

La version publiée v0.98 contient dix missions dans le thème du Gué. Elle ne livre ni second chapitre, ni affixe de biome, ni mode infini. Les éléments décrits ici sont des décisions de conception long terme, pas des fonctionnalités déjà réalisées.

1. Terminer le lot de boutique retenu : trois types habituels et une alternative acquise choisie pour la mission.
2. Concevoir le premier biome complet et son second chapitre, avec une première nouveauté et une interface d’explication.
3. Étendre les biomes par couples de chapitres et comparer les situations introduites avec plusieurs compositions et configurations de talents.
4. Concevoir la campagne 101–200 autour des cumuls tout en poursuivant les introductions.
5. Réutiliser ce contenu dans un mode infini à accumulation progressive, puis mesurer ses limites et sa difficulté.

Cet ordre des travaux est une proposition de réalisation. Les principes de biome, d’introduction et de cumul ci-dessus sont les décisions validées.

## Décision du 6 novembre 2026 — second chapitre des Ardoises

Le porteur retient un affixe pour les missions 31 à 40 du biome montagneux. Il choisit **Vents contraires**, qui réduit la cadence de tir des défenseurs.

Le porteur valide un premier essai à −10 % de cadence pour tous les défenseurs, sans ralentir les dégâts périodiques déjà appliqués. Ce dosage reste un réglage de prototype à équilibrer. À cadence égale par ailleurs, l’intervalle entre deux attaques sera divisé par 0,9. Les règles de cumul à long terme restent à préciser.

La v0.159 termine les deux chapitres des Ardoises, aux missions 21–40. Vents contraires est annoncé avant le lancement et reste visible pendant les missions 31–40. Le dosage et la difficulté de découverte restent à évaluer en jeu, particulièrement au Bastion côté Horde. Les cumuls à long terme restent régis par les principes ci-dessus. Voir [le premier essai](Vents_contraires_v0155.md), [les comparaisons des Crêtes et des Éboulis](Missions_032_033_Vents_contraires.md), [celles du Ravin et des Portes](Missions_034_035_Vents_contraires.md), [celles des Trois Passages et des Lacets](Missions_036_037_Vents_contraires.md) et [le bilan de fin de chapitre](Missions_038_040_Vents_contraires.md).

## Décision du 6 novembre 2026 — chapitres 5 et 6

Le porteur retient **des marais et des ruines englouties** pour le prochain biome, aux missions 41–60. Cette décision porte sur l'ambiance des deux chapitres.

La v0.160 ouvre ce biome avec [le Seuil des Marais, mission 41](Mission_041_Seuil_des_Marais.md). Le tracé, la palette, les bassins et les piliers sont un premier habillage de prototype à affiner. La mission n'applique pas Vents contraires. Les missions 42–60 restent à développer.

Les nouvelles mécaniques seront proposées séparément. Les attaquants propres au biome, l'éventuel affixe et leurs valeurs restent ouverts. Selon le rythme de progression retenu, le second chapitre du biome, aux missions 51–60, doit introduire sa nouveauté. Les missions 41–50 préparent sa découverte par les terrains et les configurations de chemins.

L'ambiance n'implique à elle seule aucun effet de poison, de soin, de ralentissement ou d'eau sur les règles du combat. Ces possibilités restent des idées à concevoir et à valider.
