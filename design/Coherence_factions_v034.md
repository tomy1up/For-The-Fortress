# Cohérence des factions — v0.34

24 octobre 2026. Correction après un retour du joueur sur une partie Alliance.

## Constats

Le joueur rapporte un bonus évoquant les chamans pendant une partie Alliance. Le nom du bonus et la version jouée ne sont pas confirmés. La revue a identifié une cause possible : R-02 Exercice de tir utilisait une description commune mentionnant l’exclusion du chaman, même en Alliance. L’effet réel de R-02 concernait déjà tous les défenseurs Alliance et uniquement le lanceur de haches et le sapeur en Horde.

D’autres descriptions communes évoquaient des effets absents du camp joué. Les aides de certaines synergies affichaient aussi une augmentation de malédiction sur des défenseurs sans cette attaque, à partir d’un coefficient générique de dégâts. Aucun achat inter-factions n’a été reproduit dans le parcours normal.

## Corrections réalisées

- Une fonction centrale choisit le texte d’un bonus selon la faction ; offres et récapitulatif acquis utilisent cette même fonction.
- Textes adaptés pour R-01, R-02, R-05, R-06 et R-12 ; R-04 conserve ses deux textes déjà distincts. Les autres bonus sont génériques et cohérents pour les deux camps.
- Alliance : archers, arbalétriers, mages et explosions. Horde : lanceurs de haches, sapeurs, chamans, rebonds, explosions et malédictions. Aucun texte de bonus affiché ne nomme les unités du camp adverse.
- Les synergies décrivent seulement les composantes d’attaque présentes dans l’archétype du bénéficiaire.
- Le refus d’achat et d’aperçu d’une unité adverse est conservé. Les améliorations, spécialisations et leurs aperçus refusent désormais aussi explicitement un défenseur adverse, même dans un état volontairement incohérent de test.

Les douze bonus existants sont communs aux deux factions ; aucun n’est un bonus exclusif à une unité adverse. Ils restent proposés avec leurs conditions réelles, y compris lorsqu’une future recrue pourra en bénéficier. Aucun bonus, règle, prix, dégât ou ordre de tirage n’est ajouté ou rééquilibré.

## Vérifications

729 contrôles ciblés : les douze descriptions pour chaque faction ; offres et récapitulatif ; projections chiffrées ; aides de recrutement et de synergie ; les deux branches de chaque défenseur ; refus d’achats adverses et d’améliorations sur états injectés ; trois offres distinctes sur 64 graines par faction ; effet réel de R-02 et cohérence des douze définitions de synergie.

12 303 contrôles au total. Les deux campagnes de référence conservent leurs résultats. Le paquet Windows est contrôlé sur 32 lancements ; les cartes R-02, R-04 et R-05 sont capturées séparément pour les deux camps. Les scènes à budget imposé sont explicitement identifiées.
