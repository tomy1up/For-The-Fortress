# Relecture des vagues — v0.98

31 octobre 2026. **For the Fortress!** reste un nom de travail, disponibilité juridique à confirmer.

## Intention

Le bilan doit aider à comprendre le déroulement d’une mission sans demander de lire toutes les données au survol. Ce lot poursuit l’orientation validée de lisibilité des écrans et d’explication des défaites. Il présente les relevés existants ; il n’attribue pas automatiquement une défaite à une unité ou à un choix de talent.

## Comportement

Dans **Vagues**, cliquer une ligne ou l’atteindre au clavier affiche durablement la défense présente au départ de cette vague et ses bonus actifs. La ligne est repérée, les deux listes nomment la vague concernée. Les niveaux et spécialisations sont ceux enregistrés à ce moment, même si une unité a ensuite été améliorée ou vendue.

**Voir la défense finale** retrouve les unités de fin de mission et les bonus finalement choisis. Changer d’onglet préserve la vague consultée. Réouvrir le bilan revient à sa présentation initiale.

Le résumé des pertes propose un accès direct à la vague ayant causé la plus forte perte de PV. En cas d’égalité, les vagues restent toutes citées dans le texte ; le raccourci ouvre la première chronologiquement. Les autres restent sélectionnables. Une partie sans perte ne propose pas de vague problématique. Un relevé absent est annoncé comme indisponible et non comme une absence de pertes.

Les vagues non jouées restent visibles dans le tableau et ne peuvent pas être sélectionnées. Les infobulles conservent le détail des apparitions, PV, défense et bonus. Le bouton ne modifie ni défense, bonus, récompense ou progression : il permet uniquement de relire la mission.

## Périmètre conservé et validation

Dix missions, géométries, décors, combats, statistiques, talents, ressources et profil au schéma 6 conservés. Les données viennent des relevés de vague existants. La nouvelle interaction d’analyse est une proposition d’interface à éprouver en jeu.

Les contrôles doivent couvrir les deux factions, la composition historique et finale, les bonus avant et après les choix, la sélection au clavier, les égalités de pertes, les relevés manquants et l’absence d’écriture dans les données. Les captures Windows montrent les différentes sélections et les bilans de victoire et de défaite sur l’écran de droite.

## Résultats de validation

77 suites et **32 196 contrôles Godot**, ainsi que 16 tests Python réussis. Les 321 contrôles de relecture couvrent les deux factions, dix sélections historiques, unités et niveaux, bonus antérieurs, retour à la défense finale, maintien de sélection entre onglets, clavier, égalités et absences de relevés. La lecture ne modifie ni rapport, tirages ou profil.

Le paquet Windows passe **243 lancements et 242 captures**, avec 45 sources comparées. Dix nouveaux cas montrent les vagues 1 et 4, la composition finale et les liens de pertes après victoire et défaite dans les deux factions. Ces dix vues sont inspectées visuellement ; les listes historiques et la ligne sélectionnée restent lisibles.

Les sources des cartes, du modèle de combat, des talents et du profil sont inchangées depuis v0.97. Quarante scénarios sur les dix terrains donnent les mêmes rapports, états aléatoires, événements et dégâts que v0.97. Les 18 rapports natifs des missions 2–10 conservent les relevés de v0.96 après normalisation du seul numéro de version et se rejouent avec v0.98.

[Régression](essais/v098_regression.json), [comparaison des combats](essais/v098_comparaison_combat.json), [comparaison et rejeux natifs](essais/v098_rejeux_natifs.json), [distribution](Distribution_Windows_v098.json). Exemples : [vague 4 Horde](essais/captures/QA-v098_horde_wave_context_4.png), [pertes Alliance](essais/captures/QA-v098_alliance_wave_context_defeat.png).

Un contrôle graphique complémentaire du projet source traite de vrais événements de clic et de clavier dans le viewport Godot, sur l’écran de droite : clic de la vague 1, flèche bas vers la vague 2 et clic de retour à la défense finale. Les deux factions passent sans modification du rapport, du générateur ou du profil isolé. [Relevé des événements](essais/v098_clics_clavier.json).
