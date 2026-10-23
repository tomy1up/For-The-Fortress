# Prévision des vagues — v0.29

23 octobre 2026. Évolution de la préparation : rendre la composition de la prochaine vague directement visible à partir des données existantes, pour guider les achats et améliorations pendant le délai.

## Présentation

Pendant la préparation, la fiche en haut à droite indique la prochaine vague, son effectif total et le délai restant. La première vague indique un départ manuel sans attente imposée. Les groupes sont présentés dans l’ordre de leur apparition, avec quantité, nom, couleur du profil de combat, PV par ennemi et dégâts individuels à la forteresse s’ils passent.

Le boss est identifié ; une arrivée individuellement fatale au regard des PV actuels est signalée en couleur. Ce signal est recalculé après une modification des PV, notamment Maçonnerie. Il ne prédit ni la survie d’un ennemi aux tirs ni le résultat de la vague.

Le survol d’un groupe donne les horaires de première et dernière apparition, son intervalle et ses récompenses individuelles. Ces horaires correspondent à la vitesse ×1 ; la fiche précise qu’ils sont divisés par deux en ×2. Un groupe d’un seul ennemi est décrit comme tel, sans annoncer un intervalle nul.

Le gain annoncé est la somme maximale des récompenses si tous les ennemis sont éliminés. Ces récompenses restent attribuées à chaque élimination ; aucune prime de fin de vague ou garantie de revenu n’est ajoutée.

## Phases et interactions

Après la fin d’une vague, la fiche présente la suivante et suit le même décompte que le bouton de lancement. La lecture ne suspend pas les 30 secondes réelles et ne change pas la vitesse. Le panneau se masque pendant le combat, les choix roguelite, les spécialisations, le récapitulatif des bonus, le bilan et les fins de partie. Il ne présente jamais une vague 11. L’inspection ennemie reprend son emplacement pendant le combat.

Les groupes, quantités, intervalles, PV, dégâts, récompenses et couleurs proviennent des données utilisées par le jeu. Le calendrier de la prévision est celui des apparitions réelles. Les couleurs du panneau et des ennemis partagent la même définition. Les données de composition sont mises en cache par numéro de vague ; les PV de la forteresse et le délai sont réévalués à chaque actualisation.

## Vérification

**2 639 contrôles réussis**, dont 402 nouveaux : dix compositions, 182 apparitions, 26 groupes, horaires, intervalles, revenus maximaux, copie sans mutation, affichage des phases, passage au groupe suivant, danger du boss avant/après soin, nouveau départ et interactions modales. Les résultats des campagnes restent inchangés.

L’archive Windows extraite est vérifiée avec dix-huit lancements, dont la préparation de la vague 9 et celle du boss. Les fiches et l’aide des horaires ont été inspectées visuellement ; les deux vues finales sont aussi inspectées dans l’exécutable. Rapport et empreintes : `Distribution_Windows_v029.json`.

Aucun paramètre de combat ou de coût n’est modifié. Les GDD principaux Word et Markdown restent en v0.14 avec leurs compléments existants ; cette fiche documente la présentation du prototype.
