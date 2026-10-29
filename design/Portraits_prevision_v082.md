# Portraits dans la prévision des vagues — v0.82

29 octobre 2026. Suite du travail de présentation et de lisibilité. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

La prévision présente désormais la silhouette de chaque groupe avant le départ. Les trois espèces neutres sont communes aux factions ; les cinq attaquants propres à un camp apparaissent quand on défend le camp opposé. Les images reprennent exactement l’atlas et la région utilisés par les ennemis en combat, avec les couleurs originales et les proportions conservées.

Les noms complets, quantités, PV, dégâts à la forteresse et avertissement de défaite restent visibles. Le panneau garde ses dimensions et la hauteur de ses lignes pour préserver la place de la carte. Les portraits ne capturent ni les clics ni le focus : les infobulles des groupes restent disponibles.

Les régions d’atlas sont mises en cache par identité plutôt que recréées à chaque image. Un changement de vague efface les images des lignes inutilisées ; changer de faction après une partie actualise l’adversaire. Aucun nouvel asset ni fichier de profil. Le combat, l’économie, les pauses et la progression sont inchangés.

## Validation

59 suites et 18 615 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 911 nouveaux contrôles parcourent les dix vagues des deux factions avec deux états de PV, vérifient les treize identités, les régions d’atlas et couleurs, la lisibilité des textes, les infobulles, les proportions, le cache, les lignes inutilisées et le changement de faction après une partie. Aucune modification du modèle, de l’aléatoire ou du décompte.

Le paquet Windows passe 136 lancements et produit 135 captures, avec 38 sources comparées au projet. [Régression](essais/v082_regression.json) et [distribution](Distribution_Windows_v082.json). Toutes les sources du paquet sauf la version, la liste d’export et l’interface principale conservent leurs empreintes v0.81 ; notamment modèle, atlas, statistiques, progression et profil. Profils isolés ; essais graphiques sur l’écran de droite. Aucun nouvel essai humain d’équilibrage.

Captures : [vague 9 Alliance](essais/captures/QA-v082_wave_forecast.png), [vague 9 Horde](essais/captures/QA-v082_horde_wave_forecast.png), [boss attaquant l’Alliance](essais/captures/QA-v082_alliance_boss_forecast.png), [boss attaquant la Horde](essais/captures/QA-v082_boss_forecast.png), [vague 1 Alliance](essais/captures/QA-v082_alliance_fortress.png) et [vague 1 Horde](essais/captures/QA-v082_horde_fortress.png).
