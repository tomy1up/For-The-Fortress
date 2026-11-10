# Prototype v0.168 — Chapitre 7 durci et arbres de talents équilibrés

Sur demande du porteur, deux changements :

**Les arbres de talents se valent.** Un banc de mesure donne la puissance de chaque arbre avec tous ses points, en jouant l'armée qu'un joueur de cet arbre constituerait (l'unité que l'arbre améliore est achetée dès l'ouverture). Les trois arbres de la Horde se valaient déjà ; ceux de l'Alliance ne se valaient pas : à 51 points, Arts arcaniques n'offrait que 43 % de la puissance de Maîtrise du tir, et Bastion 69 %. Les bonus de dégâts, de portée et de rebonds de Bastion, Arts arcaniques, et, plus légèrement, de la Voie des maléfices et de Démolition, sont renforcés. Maîtrise du tir et Fureur de guerre ne changent pas, donc le reste de la campagne garde sa difficulté. À chaque palier de 10, 20, 35 et 51 points, tous les arbres sont à moins de 12 % de l'arbre de référence de leur faction. Les PV de forteresse, la structure des arbres et les sauvegardes ne changent pas. Les anciens rapports de partie se rejouent avec les valeurs historiques. Les valeurs sont des réglages de prototype à confirmer en jeu. Voir design/Equilibrage_arbres_talents_v0168.md.

**Chapitre 7 plus difficile.** Les trajets de neuf cartes volcaniques sont raccourcis, avec une difficulté croissante jusqu'au Cœur du Volcan, dont le trajet passe de 29 à 25 unités. Avec les arbres de référence, les victoires des essais automatiques baissent de 8 % côté Alliance et de 16 % côté Horde ; la finale passe de 22 à 4 victoires sur 36 côté Horde. Voir design/Missions_061_070_Volcan.md.

Constat à décider : l'écart entre factions. À armées comparables, les talents de l'Alliance sont environ deux fois plus puissants que ceux de la Horde (+136 contre +67,5 à 51 points), et avec l'armée de chaque arbre l'Alliance gagne 97 % des parties du chapitre 7, la Horde 52 %.

La régression complète réussit : 103 suites, 62 490 contrôles Godot et 17 tests Python. Les 52 essais Windows ciblés réussissent et les 87 empreintes de sources du paquet correspondent au projet.
