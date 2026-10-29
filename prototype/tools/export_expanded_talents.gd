extends SceneTree
## Export de conception, sans profil ni configuration de jeu modifiés.
const Expanded = preload("res://scripts/meta_talents_expanded.gd")
func _initialize() -> void:
	var output: String = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=").simplify_path()
	if output.is_empty() or FileAccess.file_exists(output) or output.begins_with(ProjectSettings.globalize_path("user://")):
		printerr("Destination absente, existante ou réservée aux données du joueur.");quit(2);return
	var lines: Array[String] = ["# Proposition de talents enrichis — 29 octobre 2026","", "**Proposition de contenu et d’équilibrage, non raccordée à l’interface ni au combat jouable.** Les noms, rangs et valeurs restent des hypothèses. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.","", "18 talents par arbre, 3 arbres par faction, 54 talents par faction. Six lignes avec seuils de 0, 5, 10, 15, 20 et 25 points investis dans les lignes précédentes du même arbre. Les identifiants des quinze talents historiques restent stables ; leurs effets sont conservés.","", "Le plafond actuel de 36 points est gardé uniquement pour éprouver les arbitrages, sans validation comme plafond définitif. La capacité légale de chaque arbre avant ce plafond commun est de 40 rangs, soit 120 pour les trois : cette proposition ne permet donc pas de tout remplir. Deux choix intermédiaires restent exclusifs ; trois spécialités profondes par arbre sont également exclusives.","", "Les premières victoires des missions 1–100 doivent financer le plafond de points sans autres dépenses. Les achats de boutique peuvent retarder cet objectif ; les missions suivantes continuent de donner leurs PO de première victoire. Voir le [cadre économique](Economie_campagne_2026-10-29.md).","", "Les effets proposés utilisent seulement les dégâts directs, explosions/rebonds/malédictions, portée et PV déjà présents. Aucun nouveau sort actif, ennemi, contrôle ou ressource n’est approuvé par ce catalogue. Les valeurs nécessitent une évaluation en combat et des essais joueurs avant de prétendre être équilibrées."]
	for faction in range(2):
		lines.append("\n## "+("Alliance" if faction == 0 else "Horde"))
		for tree in range(3):
			lines.append("\n### "+Expanded.Previous.TREES[faction][tree][0]+"\n")
			lines.append("| Ligne | Talent | Rangs max. | Effet proposé par rang |")
			lines.append("| --- | --- | --- | --- |")
			for row in range(6):
				for local in range(18):
					if Expanded.ROWS[local] != row: continue
					var node: Dictionary = Expanded.node(faction,Expanded.index_for(tree,local))
					lines.append("| %d | %s%s | %d | %s |" % [row+1,node.name," — choix exclusif" if local in [3,4,15,16,17] else "",node.maximum,node.description.replace("\n","<br>")])
	lines.append("\n## État technique et suite\n")
	lines.append("Le module de calcul vérifie paliers, plafond, exclusions, types d’unités et normalisation des anciens rangs. Il n’est pas appelé par le jeu v0.83. L’intégration de l’interface, des sauvegardes et des rapports reste à réaliser et vérifier avant activation. Aucune donnée du joueur n’est lue ni modifiée par cet export.")
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: printerr("Destination non accessible.");quit(1);return
	file.store_string("\n".join(lines)+"\n");file.close()
	print("EXPANDED_TALENTS_EXPORTED=",output);quit()
