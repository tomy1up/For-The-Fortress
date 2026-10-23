# Comparaison des améliorations — v0.26

23 octobre 2026. Suite de la lisibilité du prototype : permettre de comparer les améliorations et les spécialisations avant de payer, en conservant les règles existantes.

## Comportement livré

Survoler le bouton Niveau 2 ou Niveau 3, ou lui donner le focus clavier, affiche les dégâts, l’intervalle et la portée sous la forme **valeur actuelle → valeur prévue**. Les effets secondaires prévus restent décrits. Le cercle et les portions de chemin en bleu montrent la portée principale après amélioration. Quitter le bouton rend la fiche actuelle. Le clic valide et paie selon les règles habituelles ; un manque d’or permet la comparaison mais empêche toujours l’amélioration.

Le choix de spécialisation est placé dans un panneau latéral à gauche pour laisser la carte visible. Les deux branches comparent leurs statistiques au défenseur de niveau 3, dont dégâts secondaires, cibles, rayons, rebonds ou malédiction selon le type. Survoler le bouton d’une branche, ou lui donner le focus, affiche sa portée future. Les statistiques intègrent les bonus acquis et les synergies applicables après validation. Les liens actifs des voisins restent ceux de la défense réelle tant que le choix n’est pas confirmé.

La portée bleue correspond à la sélection de la cible principale ; elle ne représente pas l’extension supplémentaire d’une explosion ou des rebonds. Les limites strictes de ces effets restent indiquées dans les comparaisons.

## Transactions et horloges conservées

Aucun paiement, changement de niveau, instance ou tirage n’a lieu pendant la comparaison. Confirmer une branche paie une seule fois et applique ses statistiques ; Annuler conserve le niveau 3 et l’or. Les comparaisons ordinaires ne suspendent pas les 30 secondes de préparation. Le choix modal de spécialisation continue de suspendre le délai restant, puis le reprend après résolution. Aucun aperçu d’amélioration n’est montré en combat, au niveau maximum ou à travers le récapitulatif des bonus.

Le calcul utilise un candidat virtuel et le même calcul de statistiques effectives que le défenseur réel. Cela prend notamment en compte l’arrêt de Recrues aguerries au niveau 3, l’activation de Vétérans et les associations propres à la branche envisagée.

## Vérifications

**1 963 contrôles réussis**, dont 357 nouveaux : aperçus de tous les niveaux et branches, avec et sans bonus, partenaires spécialisés, conformité après validation, absence de mutation, survol et focus, financement insuffisant, annulation, paiement unique et horloges. Les deux campagnes de référence conservent leurs résultats.

L’archive Windows extraite est vérifiée avec douze lancements, dont une comparaison d’amélioration et une spécialisation. Les vues des six défenseurs ont été rendues et inspectées ; les captures de spécialisations utilisent un budget de contrôle identifié, sans constituer des essais d’équilibrage. Empreintes et protocole d’export : `Distribution_Windows_v026.json`.

Aucune valeur de combat ni de coût n’est modifiée. Le GDD principal Word et Markdown reste en v0.14 avec ses compléments existants ; cette fiche décrit une évolution de l’interface du prototype.
