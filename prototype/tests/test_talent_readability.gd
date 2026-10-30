extends SceneTree
const Screen = preload("res://scripts/meta_screen.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func highlights(menu: Control) -> int:
	var total: int = 0
	for node in menu.nodes:
		if node.highlighted: total += 1
	return total
func run_checks() -> void:
	for faction in range(2):
		var p = Profile.new("");var ui = Screen.new();root.add_child(ui);ui.open(p,faction)
		check(ui.balance.text.contains("Aucun point à placer") and ui.balance.text.contains("0/51") and not ui.balance.text.contains("PO"),"L’en-tête distingue les points des PO réservées à la boutique")
		check(ui.notice.text.contains("première victoire") and ui.notice.text.contains("Rejouer ne rapporte pas"),"Sans point, la prochaine action utile explique la règle de première victoire")
		var before: String = JSON.stringify(p.data)
		for index in range(Talents.NODE_COUNT):
			ui._inspect(index)
			check(ui.inspected == index and ui.nodes[index].highlighted and highlights(ui) == 1,"Un seul talent est repéré comme source de la description")
			var forbidden: Array = ["Chaman","Sapeur","Lanceur de haches"] if faction == 0 else ["Mage","Archer","Arbalétrier"]
			for word in forbidden: check(not ui.detail_text.text.contains(word),"Les 63 descriptions et aperçus de rang restent propres à leur faction")
		check(JSON.stringify(p.data) == before,"Lire les talents et leurs prochains rangs ne modifie aucun acquis")
		for tree in range(3):
			check(ui.point_labels[tree].text.contains(ui.TREE_ROLES[faction][tree]) and ui.point_labels[tree].text.contains("0 point"),"Le rôle de chaque arbre accompagne son investissement, sans nouvelle ligne dans le graphe")
			check(ui.point_labels[tree].get_theme_font("font").get_string_size(ui.point_labels[tree].text,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x < ui.point_labels[tree].size.x,"Le rôle et le nombre de points tiennent sur une ligne")
			check(ui.point_labels[tree].mouse_filter == Control.MOUSE_FILTER_STOP and ui.point_labels[tree].tooltip_text.contains("partagés"),"Le plafond partagé reste expliqué au survol")
		var id: int = p.begin_mission(faction,"test.first_point_readability",60,10,200)
		check(id > 0 and p.credit_mission(id,faction,10,true),"Le premier point de contrôle vient d’une vraie transaction de victoire")
		ui.refresh()
		check(ui.balance.text.begins_with("1 point à placer") and ui.balance.text.contains("1/51") and ui.balance.text.contains("200 XP"),"Le point gagné est affiché sans ambiguïté avec l’XP conservée")
		check(ui.balance.tooltip_text.contains("60") and ui.balance.tooltip_text.contains("ne servent pas à acheter des talents") and ui.balance.mouse_filter == Control.MOUSE_FILTER_STOP,"Le solde PO reste accessible sans être présenté comme moyen d’achat de talents")
		check(ui.notice.text.contains("marqué +") and ui.notice.text.contains("gratuite"),"Un point disponible propose une affectation et rappelle la gratuité du reset")
		ui._allocate(0)
		check(ui.balance.text.contains("Aucun point à placer") and ui.point_labels[0].text.begins_with("1 point") and p.data.banks[faction].resource == 60 and p.data.banks[faction].xp == 200,"Investir actualise les compteurs, sans dépenser de PO ni d’XP")
		ui._request_reset();ui.confirm.confirmed.emit()
		check(ui.balance.text.begins_with("1 point à placer") and ui.point_labels[0].text.begins_with("0 point") and p.data.banks[faction].resource == 60 and p.data.banks[faction].xp == 200,"Réinitialiser rend le point disponible et conserve les gains")
		check(p.data.banks[1-faction] == Profile.bank(),"La présentation et les actions restent isolées de l’autre faction")
		p.blocked = true;p.error = "Sauvegarde indisponible pour le contrôle."
		before = JSON.stringify(p.data);ui.refresh();ui._inspect(5);ui._allocate(0)
		check(ui.balance.text.begins_with("Progression à vérifier") and ui.notice.text == p.error,"L’erreur de sauvegarde reste prioritaire sur l’invitation à investir")
		check(ui.balance.text.contains("indisponibles") and not ui.balance.text.contains("/51") and ui.xp_label.text == "XP indisponible","Une progression indisponible n’est pas affichée comme un nouveau profil à zéro")
		check(ui.nodes[0].rank_text.begins_with("—/") and ui.point_labels[0].text.begins_with("Points indisponibles") and not ui.detail_text.text.contains("Prochain rang"),"Rangs, points investis et prévision ne prétendent pas lire les gains indisponibles")
		check(JSON.stringify(p.data) == before and highlights(ui) == 1,"Une progression bloquée reste consultable et inchangée")
		p.blocked = false;p.error = "";ui.open(p,1-faction)
		check(ui.inspected == 0 and ui.nodes[0].highlighted and highlights(ui) == 1,"Changer de faction ne conserve pas un ancien repère de sélection")
		ui.free()
	print("TALENT_READABILITY_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
