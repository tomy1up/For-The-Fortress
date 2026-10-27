# Origine des ennemis — règle et proposition de répartition

27 octobre 2026. Référence jouable examinée : v0.64. Le porteur du projet rappelle la règle d’origine des attaquants, puis demande une proposition de répartition à valider.

## Décision validée : trois origines, deux catalogues distincts

- Les ennemis neutres peuvent apparaître contre les deux factions jouables. La faune, notamment ours et sangliers, est un exemple de contenu possible ; chaque espèce et son affectation restent à valider individuellement.
- Quand le joueur défend avec la **Horde**, les attaquants spécifiques appartiennent à l’**Alliance**.
- Quand le joueur défend avec l’**Alliance**, les attaquants spécifiques appartiennent à la **Horde**.
- Les attaquants de faction forment un catalogue distinct des défenseurs que le joueur construit : noms, identifiants, rôles et apparences propres. Il ne s’agit pas de reprendre automatiquement les six unités à placer sur le plateau.
- Un attaquant de l’Alliance ne doit pas apparaître comme ennemi spécifique d’un joueur Alliance ; même règle pour la Horde. Un ennemi neutre reste disponible dans les deux cas.

Cette règle est confirmée par le message du porteur du projet, même si sa répartition précise n’a pas été retrouvée dans les documents locaux consultés. Elle prime sur l’interprétation du lot artistique v0.64 qui présentait tous les attaquants comme communs aux deux camps.

## Proposition à valider — aucune affectation implémentée

Conserver les huit profils de combat actuels comme références de statistiques, puis leur associer trois identités neutres et cinq identités par camp adverse.

| Profil de combat actuel | Origine proposée | Attaquants contre un joueur **Horde** | Attaquants contre un joueur **Alliance** |
| --- | --- | --- | --- |
| Grouillant | Neutre | Loup de meute | Loup de meute |
| Pillard | Camp adverse | Fantassin humain — Alliance | Guerrier orc — Horde |
| Sprinter | Neutre | Sanglier sauvage | Sanglier sauvage |
| Brute | Neutre | Ours sauvage | Ours sauvage |
| Maraudeur | Camp adverse | Éclaireur elfe — Alliance | Éclaireur gobelin — Horde |
| Colosse | Camp adverse | Brise-remparts nain — Alliance | Colosse troll — Horde |
| Élite | Camp adverse | Garde royal humain — Alliance | Garde noir mort-vivant — Horde |
| Seigneur de siège — boss | Camp adverse | Maréchal de l’Alliance | Chef de guerre orc de la Horde |

**Tous les noms et toutes les affectations de ce tableau sont proposés, pas encore approuvés.** Les trois origines et l’exclusion des attaquants de sa propre faction sont, elles, validées.

Cette proposition représente treize identités au total : trois communes et cinq propres à chaque camp, dont un boss par camp. Chaque campagne en verrait huit, avec les mêmes huit profils de combat de référence. Les loups représentent la menace en groupes, les sangliers la vitesse et les ours l’endurance. Les attaquants spécifiques rendent le conflit entre factions visible dès la première vague.

Les éclaireurs sont ici des combattants de contact munis de lames, pas des archers. Le nain lourd porte un marteau et le troll lourd une masse, pour les distinguer des défenseurs arbalétrier et lanceur de haches. Le mort-vivant ne reçoit aucune immunité, résurrection ou régénération ; son identité reste visuelle. Ces équipements et distinctions font partie de la proposition artistique, sans nouvelle mécanique.

## Proposition d’intégration, après validation

Pour la première adaptation, conserver PV, vitesse, dégâts à la forteresse, or, quantités et espacements des vagues existantes. Les trois animaux utiliseraient les valeurs de leur profil, sans capacité de charge, poison ou autre comportement supplémentaire. Les valeurs demeurent des hypothèses d’équilibrage du prototype.

Exemple : la première vague actuelle de dix Pillards deviendrait dix Fantassins humains face à la Horde, ou dix Guerriers orcs face à l’Alliance. Les dix ennemis, leur espacement de 2,5 secondes et les récompenses resteraient identiques. Ce serait une substitution d’identité, pas l’ajout d’un groupe supplémentaire.

Séparer l’identité et l’origine de l’attaquant de son profil statistique. Le choix de faction doit déterminer le catalogue des ennemis autorisés avant leur apparition. Les vagues, prévisions, noms d’inspection, illustrations, bilan et rapport devront utiliser cette identité cohérente. Les bonus qui citent des profils, notamment R-12 Chasse aux colosses, devront rester compréhensibles avec les noms effectivement visibles, sans changer leurs bénéficiaires ou effets.

Vérifier les deux campagnes : neutres acceptés dans les deux, attaquants du camp adverse seulement, aucun défenseur construit substitué comme ennemi, correspondance entre prévision et apparition, règles et revenus conservés. Les boss restent des attaquants du camp adverse dans cette proposition ; leur profil initial reste à 600 PV.

## État réel du jeu et des images v0.64

Le paquet v0.64 utilise encore les mêmes huit profils et le même habillage d’ennemis pour les deux factions. Il ne possède pas encore le filtrage neutre/Alliance/Horde décrit ci-dessus. La correction documentaire ne doit pas être présentée comme un correctif déjà livré dans l’exécutable.

Les trois PNG humanoïdes Grouillant, Pillard et Sprinter restent des **assets provisoires sans affectation d’origine validée**. Ils ne valident pas l’existence de trois bandits neutres communs. La répartition proposée demanderait d’autres apparences, notamment pour la faune ; ne pas poursuivre automatiquement les illustrations des cinq autres profils sur l’hypothèse d’un catalogue commun.

Les GDD Word et Markdown v0.14 restent le socle historique des profils et chiffres. Ce complément consigne la règle d’origine rappelée et la proposition demandée. For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.
