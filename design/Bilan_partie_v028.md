# Bilan de partie — v0.28

23 octobre 2026. Suite du développement du prototype et des essais : détailler les résultats réels des vagues en fin de partie, sans modifier les règles de combat ou l’équilibrage.

## Consultation

Après victoire ou défaite, le bouton **Bilan** apparaît à côté de **Rejouer**. Le tableau présente les dix vagues : ennemis éliminés, ennemis passés, PV perdus, or gagné et temps de combat simulé. Une vague achevée est indiquée « Terminée », la vague perdue « Défaite » et les suivantes « Non jouée ». Une absence de relevé ne devient pas une vague inventée.

Le survol d’une ligne rappelle les PV avant/après, les ennemis prévus et apparus, les éventuels survivants à la défaite, la défense au départ de la vague et les bonus alors actifs. La composition finale et les trois bonus choisis sont rappelés sous le tableau. Fermer puis rouvrir ne crée pas de nouvelles données.

Les totaux sont ceux réellement obtenus. L’or gagné exclut le capital initial et ne représente pas l’or restant après achats. Les PV perdus mesurent la baisse effective pendant le combat ; un soin de Maçonnerie entre deux vagues ne réécrit pas la vague précédente. Le temps est celui de la simulation, hors préparation et choix ; il ne mesure pas la durée réelle d’une session jouée en ×2.

## Relevé en mémoire

Un contexte est copié au lancement de chaque vague, avant le premier événement de combat. Une seule ligne est enregistrée lorsque la vague se résout ou provoque la défaite. La composition et les bonus sont copiés pour rester indépendants des améliorations et choix ultérieurs. Les données de la vague perdue ne transforment pas ses ennemis encore en chemin en éliminations ou en arrivées.

Le relevé reste en mémoire pour cet essai et est effacé au suivant. Aucun fichier de sauvegarde, progression permanente, export ou collecte distante n’est ajouté. L’outil existant de comparaison des essais copie aussi ces nouvelles données sans partager les tableaux de sa source.

## Vérification

**2 237 contrôles réussis**, dont 196 nouveaux : une ligne par vague, conformité des PV et revenus, cumul des temps, indépendance des contextes, choix de bonus, deux campagnes au budget normal, bilan de défaite partielle, vagues non jouées, lecture sans mutation, relance et copie des états d’essai. Les résultats de référence restent Alliance 14 PV / 192 or et Horde 12 PV / 189 or.

L’archive Windows extraite est vérifiée par seize lancements, dont les bilans d’une victoire Horde et d’une défaite Alliance. Les deux bilans et l’accès depuis l’écran de victoire sont inspectés visuellement dans l’exécutable final. Empreintes et résultats : `Distribution_Windows_v028.json`.

Les statistiques, coûts, compositions de vagues et délai de 30 secondes restent inchangés. Les GDD principaux Word et Markdown restent en v0.14 avec les compléments déjà établis ; cette fiche décrit la présentation et les relevés du prototype.
