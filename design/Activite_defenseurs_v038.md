# Activité des défenseurs — v0.38

25 octobre 2026. Mesures de diagnostic et nouvelle vue du bilan, dans le périmètre des essais du prototype. Aucun changement de règle, de récompense, de priorité des tirs ou de statistique d’équilibrage.

## Lecture du bilan

Après victoire ou défaite, **Bilan → Défenseurs** affiche les recrues qui ont participé à au moins une vague : emplacement, type, dernier niveau utilisé, présence finale ou vente, nombre de vagues, attaques, PV retirés aux ennemis et part contre le boss. Les recrues sont conservées dans l’ordre de leur première participation, sans classement de puissance.

Le survol détaille les coups directs, les explosions ou rebonds et les déclenchements de malédiction selon les capacités de l’unité. Une spécialisation est nommée si la recrue l’a atteinte. Une longue liste défile ; le cas sans défenseur est explicitement indiqué. L’onglet **Vagues** conserve le bilan antérieur.

Les recrues vendues restent identifiables. Une nouvelle recrue au même emplacement possède son propre relevé ; les améliorations successives d’un même exemplaire cumulent son activité sans créer une nouvelle unité. Le détail par vague conserve le niveau, la branche et les dépenses de cette vague. Une unité présente sans avoir de cible affiche zéro activité.

## Convention de mesure

Les **PV retirés** sont limités à la vie restante de chaque ennemi au moment de la transaction. Les dégâts au-delà de sa mort sont exclus. Plusieurs impacts simultanés partagent les PV retirés proportionnellement à leurs dégâts ; leur ordre dans la boucle ne favorise aucun défenseur.

Les anciens déclenchements de malédiction sont mesurés avant les nouveaux tirs, conformément à la résolution existante. Les nouvelles malédictions ne créditent rien à leur application : seuls leurs déclenchements effectivement résolus comptent. Les explosions et rebonds créditent uniquement les victimes réellement sélectionnées par le combat.

Une attaque désigne un tir principal ; ses impacts secondaires et ses déclenchements périodiques sont comptés séparément dans le détail. La colonne **Dont boss** est une partie du total, à ne pas lui ajouter. Les valeurs complètes restent dans le JSON ; l’écran arrondit à deux décimales au maximum, ce qui peut produire un écart de 0,01 dans une somme affichée.

Aucune élimination individuelle n’est attribuée. Les mesures ne représentent pas à elles seules l’utilité d’une portée, d’un placement ou d’une synergie accordée à un partenaire ; elles ne justifient pas un rééquilibrage automatique. Les statistiques et cibles commerciales conservent leur statut antérieur.

## Rapports et architecture

Le rapport JSON passe au **schéma 2**, avec `performance` par vague et pour la partie. Il conserve la version du jeu, le journal, les offres de bonus et les états aléatoires existants. Le Markdown ajoute un tableau des contributions. Un historique sans mesures reste accepté par la fonction d’agrégation et donne une liste vide. Aucun import ou chargement de partie n’est ajouté.

Le module `combat_metrics.gd` observe les mêmes impacts et les PV avant leur application. Il n’écrit dans aucun ennemi ni dans aucune statistique de défenseur. Le dictionnaire de dégâts et la transaction de combat d’origine restent la référence. Les mesures sont profondément copiées avec l’historique et remises à zéro au nouvel essai.

## Vérifications

**13 952 contrôles réussis**, dont 73 ciblés. Scénarios de partage équitable et inégal, excédents létaux, malédictions, explosions, rebonds, boss à 600 PV, absence de cible, vente/rachat, schéma JSON/Markdown, copies indépendantes, interface et défilement d’un historique imposé de 60 recrues. Des simulations à grands et petits pas donnent la même chronologie et les mêmes mesures.

Les deux campagnes de référence restent victorieuses : Alliance à 14 PV et 192 or ; Horde à 12 PV et 189 or. Pour chacune, les contributions non arrondies au boss totalisent 600 PV. **45 lancements Windows** contrôlent notamment les deux onglets, le tableau vide et l’export des mesures.

Captures des trois nouvelles vues inspectées à 1280 × 800. Les essais graphiques sont dirigés vers le second écran, à droite, selon la préférence du porteur du projet. Les résultats interactifs éventuels sont consignés séparément ci-dessous ; ils ne constituent pas des retours joueurs humains ni des conclusions d’équilibrage.

## Essai interactif agent

Sur le paquet v0.38 : Horde, lanceur de haches E1 et sapeur E2, tous deux au niveau 1, sans achat ni amélioration après les 125 or initiaux. Bonus R-05 Propagation choisi après la vague 3. Défaite en vague 5 à 0 PV, 150 or restants, 50 éliminés et 16 passés ; combat cumulé de 191,7 secondes simulées, accéléré en ×10. Le scénario vise le bilan et ne sert pas à conclure sur la difficulté.

Le tableau affiche cinq vagues par recrue : 70 attaques et 1 107,84 PV retirés pour le lanceur ; 55 attaques et 1 165,38 PV retirés pour le sapeur. Le survol du lanceur distingue 1 030,08 PV directs et 77,76 PV de rebonds. Le boss n’a pas été rencontré : ses contributions restent à zéro.

L’export lancé depuis cet onglet a été relu sur disque : schéma 2, mêmes attaques et composantes non arrondies, deux recrues et issue conformes à l’écran. [Capture de l’infobulle](essais/captures/QA-v038_bilan_defenseurs_horde.jpg). La fenêtre a été fermée après l’essai.
