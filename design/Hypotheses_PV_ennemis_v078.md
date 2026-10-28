# Hypothèses de PV ennemis — atelier v0.78

28 octobre 2026. Expérience de développement uniquement. Aucun coefficient de cette note n’est appliqué au jeu distribué et aucun nouveau palier de difficulté n’est approuvé.

## Méthode

Quatre copies temporaires du modèle testent les PV ennemis à ×1, ×1,15, ×1,30 et ×1,45. Les huit profils sont multipliés, boss inclus. Vitesse, dégâts à la forteresse, récompenses, vagues et défenseurs restent identiques. Chaque copie exécute les 512 scénarios de l’audit de progression : quatre configurations de talents, deux placements, deux factions et 32 graines. Les 2 048 budgets sont vérifiés. La copie ×1 reproduit les 512 résultats précédents à l’identique.

Le script refuse de travailler dans le projet ou dans un dossier déjà présent. Il conserve les sources du projet intactes et produit les résultats dans de nouveaux dossiers. Aucun profil joueur n’est chargé ou crédité.

## Victoires dans les configurations extrêmes

Chaque cellule contient le nombre de victoires sur 32 graines. Les configurations à 5 et 15 points figurent dans la synthèse JSON. Les 36 points représentent une orientation de finales, pas la meilleure configuration possible prouvée.

| PV ennemis | Faction | Référence, 0 pt | Référence, 36 pts | Réparti, 0 pt | Réparti, 36 pts |
| --- | --- | --- | --- | --- | --- |
| ×1,0 | Alliance | 32 | 32 | 0 | 32 |
| ×1,0 | Horde | 32 | 32 | 0 | 31 |
| ×1,15 | Alliance | 8 | 32 | 0 | 24 |
| ×1,15 | Horde | 0 | 32 | 0 | 11 |
| ×1,3 | Alliance | 0 | 32 | 0 | 0 |
| ×1,3 | Horde | 0 | 0 | 0 | 0 |
| ×1,45 | Alliance | 0 | 32 | 0 | 0 |
| ×1,45 | Horde | 0 | 0 | 0 | 0 |

## Ce que ces essais permettent de conclure

Dans ces politiques fixes, une augmentation uniforme n’a pas un effet uniforme entre les camps. À ×1,30, la référence à 36 points réussit encore 32/32 fois pour l’Alliance et 0/32 pour la Horde. L’expérience ne permet pas d’attribuer cet écart à un seul talent : composition, couverture, spécialités et survie interagissent.

À ×1,15, la référence sans talent obtient 8/32 victoires pour l’Alliance et 0/32 pour la Horde, puis 32/32 dans les deux camps avec l’orientation à 36 points. Ce résultat est une piste de test, pas un réglage validé. Les nouveaux joueurs, autres placements, autres politiques et choix de talents ne sont pas représentés.

Ces données déconseillent un renforcement global important sans essais complémentaires par faction. La suite utile consiste à tester davantage de configurations et des premières parties humaines avant d’ajuster les chiffres ou de choisir un rythme de progression. Le tarif des points, la récompense et les capacités restent inchangés.

## Reproduire et retrouver les données

Exécuter prototype/tools/probe_enemy_hp.py avec --project prototype, --engine <Godot console 4.7.2> et --destination <nouveau dossier hors du projet>. Le script exige les données de référence design/essais/v078_meta_progression.json, produit quatre projets temporaires et un probe.json complet. Son empreinte est conservée dans la [synthèse de 64 groupes](essais/v078_hp_hypotheses.json). Les fichiers temporaires d’origine restent sur ce PC dans C:/Projet/.tools/hp_probe_v078.

Le jeu de référence reste [la v0.78](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.78). Aucun nouvel exécutable n’est créé pour cet atelier. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.
