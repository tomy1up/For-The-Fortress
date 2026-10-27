extends SceneTree
const Screen = preload("res://scripts/meta_screen.gd")
const Talents = preload("res://scripts/meta_talents.gd")
const Profile = preload("res://scripts/meta_profile.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	for faction in range(2):
		var p = Profile.new("");p.data.banks[faction].points = 14;p.data.banks[faction].resource = 36
		p.data.banks[faction].ranks = [5,3,2,1,0,1,0,0,0,0,0,0,0,0,0]
		var ui = Screen.new();root.add_child(ui);ui.open(p,faction)
		var before: String = JSON.stringify(p.data)
		check(ui.nodes[0].state == "maximum" and ui.nodes[2].state == "available" and ui.nodes[4].state == "exclusive" and ui.nodes[6].state == "locked","Quatre états de talent distincts dans la même configuration")
		for index in range(15):
			check((ui.nodes[index].state == "available") == Talents.can_allocate(p.data.banks[faction].ranks,index,14),"Le repère plus suit exactement le droit d'affectation")
			ui._inspect(index)
			check(not ui.nodes[index].disabled and ui.detail_title.text.contains("Rang"),"Même un talent inaccessible reste inspectable au clavier")
		for tree in range(3):
			for row in range(3):
				check(ui.boards[tree].progress[row] == mini(Talents.THRESHOLDS[row],Talents.lower_spent(p.data.banks[faction].ranks,tree,row)),"Jauge de palier fondée sur les seules lignes précédentes du même arbre")
		check(ui.boards[0].progress == [0,5,10] and ui.boards[1].progress == [0,1,1],"Seuils atteints ou partiels explicités sans dépasser le maximum")
		ui._inspect(4);check(ui.detail_title.text.contains("Autre spécialité choisie") and ui.detail_text.text.contains("exclusif"),"Exclusion de spécialité expliquée sans confondre manque de point et palier fermé")
		check(before == JSON.stringify(p.data),"Parcourir les états et jauges ne modifie pas le profil")
		p.data.banks[faction].points = 12;ui.refresh()
		check(ui.nodes[2].state == "unfunded" and ui.nodes[5].state == "unfunded" and ui.nodes[6].state == "locked","Absence de point séparée des prérequis de ligne")
		before = JSON.stringify(p.data);ui._allocate(2)
		check(before == JSON.stringify(p.data),"Clic sans point disponible ne dépense rien")
		ui._inspect(2);check(ui.detail_title.text.contains("Point à acheter") and ui.detail_text.text.contains("Prochain rang"),"Prochain effet consultable malgré l'absence de point")
		ui._buy();check(ui.nodes[2].state == "available" and p.data.banks[faction].resource == 26,"Achat réel actualise immédiatement les états")
		ui._allocate(2);check(ui.nodes[2].state == "maximum" and p.data.banks[faction].ranks[2] == 3,"Dernier rang investi marqué comme maximum")
		check(p.data.banks[1-faction] == Profile.bank(),"Achat et affectation limités au camp choisi")
		p.blocked = true;ui.refresh()
		var all_blocked: bool = true
		for button in ui.nodes: all_blocked = all_blocked and button.state == "blocked"
		check(all_blocked and ui.detail_title.text.contains("Sauvegarde à vérifier"),"Profil bloqué sans faux repère d'affectation possible")
		before = JSON.stringify(p.data);ui._allocate(5);check(before == JSON.stringify(p.data),"Profil protégé : états consultables sans affectation")
		p.blocked = false;ui.refresh();ui._inspect(13)
		check(not ui.detail_text.text.to_lower().contains("chaman") if faction == 0 else not ui.detail_text.text.to_lower().contains("mage"),"Explication du talent propre à la faction")
		check(ui.detail_title.get_theme_font("font").get_string_size(ui.detail_title.text,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x < ui.detail_title.size.x,"Titre et statut restent dans l'encart")
		ui.queue_redraw();await process_frame;ui.free()
	print("TALENT_STATES_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
