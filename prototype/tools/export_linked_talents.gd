extends SceneTree
## Export de conception uniquement : aucune lecture ni écriture de profil joueur.
const Linked = preload("res://scripts/meta_talents_linked.gd")
func _initialize() -> void:
	var output: String = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=").simplify_path()
	if output.is_empty() or FileAccess.file_exists(output) or output.begins_with(ProjectSettings.globalize_path("user://")):
		printerr("Destination absente, existante ou réservée aux données du joueur.");quit(2);return
	var lines: Array[String] = ["# Catalogue des arbres liés — prototype v0.89","","Les liens, positions, valeurs et exclusions ci-dessous sont des hypothèses de prototype. Les règles demandées sont : disposition irrégulière, parent au rang maximum, seuil de ligne dans le même arbre, 51 points partagés et deux majeurs aux seuils 15 et 30. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.","","21 talents par arbre ; sept paliers sur huit rangées visuelles à 3/3/3/4/3/1/3/1 talents, exactement quatre colonnes, avec des couloirs vides pour les flèches verticales. Le palier 20 occupe deux rangées regroupées. Deux chaînes proposées par arbre : talents locaux 5 → 7 → 9 (majeur intermédiaire) et 11 → 16 → 18 (majeur final). Le majeur intermédiaire ne conditionne pas le final. Les quinze identifiants historiques restent stables."]
	for faction in range(2):
		lines.append("\n## "+("Alliance" if faction == 0 else "Horde"))
		for tree in range(3):
			lines.append("\n### "+Linked.Base.Previous.TREES[faction][tree][0]+"\n")
			lines.append("| Ligne / seuil | Colonne | Talent | Rangs max. | Parent requis au maximum | Effet par rang |")
			lines.append("| --- | --- | --- | --- | --- | --- |")
			for row in range(8):
				for column in range(Linked.COLUMN_COUNT):
					for local in range(21):
						var index: int = Linked.index_for(tree,local);var cell: Vector2i = Linked.layout(index)
						if cell != Vector2i(column,row): continue
						var node: Dictionary = Linked.node(faction,index)
						var parent: Dictionary = Linked.node(faction,node.parent) if node.parent >= 0 else {}
						lines.append("| %d / %d pts | %d | %s%s | %d | %s | %s |" % [node.row+1,Linked.THRESHOLDS[node.row],column+1,node.name," ★ majeur" if node.major else "",node.maximum,"—" if parent.is_empty() else "%s (%d/%d)" % [parent.name,parent.maximum,parent.maximum],node.description.replace("\n","<br>")])
	lines.append("\n## Choix et compatibilité\n")
	lines.append("Les deux talents historiques locaux 3 et 4 restent exclusifs. Les anciennes exclusions entre les trois choix des lignes 6 et 7 sont retirées dans cette proposition : les talents locaux 19 et 20 remontent aux seuils 20 et 15, et le majeur final reste seul sur sa dernière ligne. La capacité de contenu atteint 53 rangs par arbre avant le plafond commun, soit 159 sur les trois ; 51 points ne permettent pas de tout remplir. Les règles et l’équilibre sont à éprouver en partie.")
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: printerr("Destination non accessible.");quit(1);return
	file.store_string("\n".join(lines)+"\n");file.close()
	print("LINKED_TALENTS_EXPORTED=",output);quit()
