# Prototype v0.164 — Le Noyé et les Eaux Mortes

La mission 51 ouvre le chapitre 6 des marais avec le **Noyé**, la nouveauté choisie par le porteur : une créature des marais qui régénère ses PV dans l'eau. Elle apparaît sur Les Eaux Mortes, une carte à une entrée dont deux tronçons du chemin sont inondés, repérés en bleu. 51 missions sont maintenant jouables.

Valeurs d'essai du Noyé : 150 PV de base, vitesse 0,85, 2 PV de forteresse, 8 or, régénération de 5 % de ses PV maximum par seconde dans l'eau, sans jamais dépasser son maximum. Elle est annoncée dans la prévision des vagues, l'éclaireur de mission et la fiche de mission, et sa fiche en combat indique quand elle se trouve dans l'eau. Son visuel et l'habillage de l'eau sont provisoires.

Les essais automatiques trouvent des victoires dans les deux factions : 42 sur 108 côté Alliance et 14 sur 108 côté Horde, contre 70 et 32 pour les mêmes parties sans régénération. L'équilibrage humain reste à confirmer, particulièrement côté Horde. Voir design/Mission_051_Eaux_Mortes_Noye.md pour les règles, ajustements et limites.

La régression complète réussit : 100 suites, 54 048 contrôles Godot et 17 tests Python. Les 48 essais Windows réussissent et les 85 empreintes de sources du paquet correspondent au projet. La vérification a corrigé l'oubli d'un fichier dans la liste d'export. Les captures avec défenseurs ont été inspectées dans les deux factions ; le Noyé en combat n'a pas été inspecté visuellement.
