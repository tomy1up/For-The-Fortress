extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Data = preload("res://scripts/campaign_data.gd")
const Main = preload("res://scripts/main.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func close(a: float, b: float) -> bool:
	return absf(a-b) < 0.00000001
func fixture(faction: int = 0) -> RefCounted:
	var m = Model.new()
	m.select_faction(faction)
	m.gold = 10000 # Budget de vérification, jamais attribué par le parcours normal.
	return m
func n4(m: RefCounted, slot: int, type: int, branch: int) -> void:
	m.buy(slot,type); m.upgrade(slot); m.upgrade(slot); m.upgrade(slot,branch)
func enemy(id: int, type: int, progress: float, hp: float = 1000.0) -> Dictionary:
	var e: Dictionary = Model.make_enemy(id,type,0)
	e.spawn_time = -progress/e.speed
	e.distance = progress
	e.hp = hp
	return e
func finish_fixture(m: RefCounted, wave: int) -> void:
	m.wave = wave
	m.phase = "combat"
	m.spawn_schedule.clear()
	m.spawned = 0
	m.enemies.clear()
	m._resolve_instant()
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var counts: Array = [10,18,16,20,18,20,11,44,14,11]
	var hp: Array = [400,496,512,672,1152,1344,1480,1216,2160,1512]
	var income: Array = [30,38,48,44,88,82,96,108,132,104]
	var last: Array = [22.5,26.55,26.4,20.5,35.4,28.5,23.2,35.45,34.6,20.0]
	var accumulated: int = 0
	for wave in range(1,11):
		var schedule: Array[Dictionary] = Data.schedule(wave)
		check(schedule.size() == counts[wave-1],"Quantité vague %d" % wave)
		check(schedule[0].time == 0 and close(schedule[-1].time,last[wave-1]),"Bornes horaires vague %d" % wave)
		var total_hp: float = 0
		var total_gold: int = 0
		for entry in schedule:
			total_hp += Model.ENEMY_TYPES[entry.type].hp
			total_gold += Model.ENEMY_TYPES[entry.type].reward
		check(total_hp == hp[wave-1] and total_gold == income[wave-1],"PV et revenus vague %d" % wave)
		accumulated += total_gold
	check(accumulated == 770,"770 or au maximum, sans prime")
	# Offres uniformes sans remise : reproductibles avec une graine donnée.
	var a = fixture(); var b = fixture()
	a.rng.seed = 12345; b.rng.seed = 12345
	for wave in [3,6,9]:
		finish_fixture(a,wave); finish_fixture(b,wave)
		check(a.phase == "bonus" and a.bonus_offer == b.bonus_offer,"Tirage déterministe sous graine")
		var distinct: Dictionary = {}
		for code in a.bonus_offer:
			distinct[code] = true
			check(code not in a.bonuses,"Bonus choisi exclu du catalogue")
		check(distinct.size() == 3,"Trois offres distinctes")
		check(not a.buy(0,0) and not a.upgrade(0) and not a.sell(0) and not a.start() and not a.prepare_next_wave(),"Choix obligatoire avant préparation")
		var selected: int = a.bonus_offer[0]
		var rejected: int = a.bonus_offer[1]
		check(a.choose_bonus(selected) and b.choose_bonus(selected),"Choix valide")
		check(a.phase == "finished" and not a.choose_bonus(selected) and rejected not in a.bonuses,"Choix unique, offres refusées disponibles")
		check(a.bonuses.size() == wave/3 and 12-a.bonuses.size() == 12-wave/3,"Taille du catalogue restant")
	a.reset()
	check(a.bonuses.is_empty() and a.bonus_offer.is_empty() and a.max_hp == 20 and a.gold == 150 and a.wave == 1,"Nouvelle partie sans effet résiduel")
	var m = fixture()
	m.buy(0,2); m.bonuses.assign([0,5])
	check(close(m.get_stats(0).damage,33.75) and close(m.get_stats(0).secondary_damage,11.88),"R01+R06 additifs et composantes séparées")
	m.bonuses.assign([0,3])
	check(close(m.get_stats(0).damage,29.7) and close(m.get_stats(0).secondary_damage,14.04),"R01+R04 additifs")
	m.bonuses.assign([1,2,4])
	check(close(m.get_stats(0).interval,2.5/1.12) and m.get_stats(0).range == 4 and close(m.get_stats(0).radius,1.2) and m.get_stats(0).secondary_cap == 2,"Cadence, portée et rayon, plafond inchangé")
	for branch in [-1,0,1]:
		m = fixture(1)
		if branch == -1: m.buy(0,5)
		else: n4(m,0,5,branch)
		m.bonuses.assign([1,3,4])
		check(m.get_stats(0).interval == 2 and m.get_stats(0).radius == 1,"Chaman exclu cadence et propagation")
	m = fixture(); m.buy(0,0); m.bonuses.assign([6,7]); m.upgrade(0)
	check(close(m.get_stats(0).damage,13.8),"R07 au N2")
	m.upgrade(0)
	check(close(m.get_stats(0).damage,20.16),"N3 remplace R07 par R08")
	m.bonuses.assign([7,11])
	check(close(m.damage_for(m.get_stats(0),"direct",enemy(0,3,3)),23.76) and close(m.damage_for(m.get_stats(0),"direct",enemy(0,1,3)),20.16),"R12 par victime, addition au niveau")
	# Explosion mixte, R12 ne change ni priorité ni dégâts contre le Pillard.
	m = fixture(); m.buy(0,2); m.bonuses.assign([11]); m.phase = "combat"; m.spawned = 10
	m.enemies.assign([enemy(0,1,3),enemy(1,3,2.8)])
	m._resolve_instant()
	check(close(m.enemies[0].hp,973) and close(m.enemies[1].hp,987.04),"R12 secondaire évalué sur la victime")
	# Coûts réduits et historique réel ; absence d'effet rétroactif.
	m = fixture(); m.buy(0,1)
	var before: int = m.gold
	m.bonuses.assign([9,10])
	check(m.gold == before and m.defenders[0].paid == 75 and m.refund(0) == 52,"Aucun remboursement rétroactif")
	check(m.purchase_cost(0) == 45 and m.purchase_cost(1) == 68 and m.purchase_cost(2) == 90,"Prix réduits arrondis au supérieur")
	m.buy(1,1)
	check(m.upgrade_cost(1) == 45 and m.upgrade(1) and m.upgrade_cost(1) == 90 and m.upgrade(1) and m.upgrade_cost(1) == 135 and m.upgrade(1,0),"Trois coûts réduits")
	check(m.defenders[1].paid == 338 and m.refund(1) == 236,"338 investis, 236 remboursés")
	m = fixture(); m.fortress_hp = 10; m.phase = "bonus"; m.bonus_offer.assign([8,0,1])
	check(m.choose_bonus(8) and m.max_hp == 24 and m.fortress_hp == 14 and not m.choose_bonus(8),"Maçonnerie une seule fois")
	m.buy(0,0); m.sell(0)
	check(m.max_hp == 24 and m.fortress_hp == 14,"Vente sans retrait du bonus de forteresse")
	m.wave = 4; m.phase = "combat"; m.spawn_schedule.clear(); m.spawned = 0
	m.enemies.assign([enemy(0,1,28)])
	m._resolve_instant(); m.prepare_next_wave()
	check(m.max_hp == 24 and m.fortress_hp == 13,"Dégâts ultérieurs normaux, aucune guérison de transition")
	m = fixture(); m.buy(2,2); m.buy(4,1); m.bonuses.assign([2]); m._refresh_windows()
	check(m.synergy_effects(2).codes.is_empty() and m.synergy_effects(4).codes.is_empty(),"R03 ne crée pas de proximité E3/E5")
	m = fixture(1); m.buy(0,5); m.bonuses.assign([0,11]); m.phase = "combat"; m.spawned = 10
	m.enemies.assign([enemy(0,3,3)])
	m._resolve_instant(); m.defenders[0].ready_at = INF
	m.bonuses.clear() # Vérifier la valeur conservée par l'effet déjà appliqué.
	m.advance(2)
	check(close(m.enemies[0].hp,1000-12*1.3-2*4.8*1.3),"Malédiction bonifiée par victime, valeur figée pour ses deux ticks")
	# Les cinq liens logiques, exclusion du sixième au voisinage de 5.
	var links: Array = []
	for first in range(6):
		for second in range(first+1,6):
			if Model.SLOTS[first].distance_squared_to(Model.SLOTS[second]) <= 25: links.append([first,second])
	check(links == [[0,1],[0,2],[1,2],[2,3],[4,5]],"Cinq liens de proximité, E3/E5 exclu")
	for rule in Data.PROXIMITY:
		m = fixture(0 if rule.types[0] < 3 else 1)
		m.buy(0,rule.types[0]); m.buy(1,rule.types[1])
		for side in range(2):
			var effect: Dictionary = m.synergy_effects(side)
			check(effect.codes == [rule.code],"Code de proximité propre à chaque partenaire")
			for i in range(4):
				check(close(effect[["direct","secondary","curse","range"][i]],rule.effects[side][i]),"Effet de proximité")
		m.sell(1)
		check(m.synergy_effects(0).codes.is_empty(),"Vente retire immédiatement la synergie")
	for rule in Data.SPECIALISATIONS:
		m = fixture(0 if rule.types[0] < 3 else 1)
		n4(m,0,rule.types[0],rule.branches[0])
		m.buy(5,rule.types[1]); m.upgrade(5); m.upgrade(5)
		check(m.synergy_effects(0).codes.is_empty(),"N3 partenaire insuffisant pour association N4")
		m.upgrade(5,rule.branches[1])
		for slot in [0,5]:
			var effect: Dictionary = m.synergy_effects(slot)
			check(effect.codes == [rule.code],"Association N4 sans proximité")
			for i in range(4):
				check(close(effect[["direct","secondary","curse","range"][i]],rule.effects[0 if slot == 0 else 1][i]),"Effet de spécialisation")
	# Codes distincts additifs, copies sans double effet ni diversité raciale artificielle.
	m = fixture(); m.buy(0,0); m.buy(1,1); m.buy(2,2); m.upgrade(0); m.bonuses.assign([0])
	check(close(m.get_stats(0).damage,15.12),"Exemple GDD archer N2 + deux proximités + R01")
	m.bonuses.assign([3])
	check(close(m.get_stats(2).secondary_damage,13.824),"Exemple GDD mage secondaire")
	m = fixture(); m.buy(0,0); m.buy(1,0); m.buy(2,1)
	check(close(m.get_stats(0).damage,8.64) and close(m.get_stats(1).damage,8.64),"Chaque copie reçoit sa propre proximité, sans bonus racial")
	check(close(m.get_stats(2).damage,25.92) and m.synergy_effects(2).codes.size() == 1,"Deux partenaires ne doublent pas un code")
	m.sell(0)
	check(close(m.get_stats(2).damage,25.92),"Un partenaire maintient le code après vente")
	m.sell(1)
	check(m.get_stats(2).damage == 24,"Dernier partenaire vendu retire l'effet")
	m = fixture(1); n4(m,0,3,0); n4(m,1,5,0); m.bonuses.assign([0])
	check(close(m.get_stats(1).damage,69.03) and close(m.get_stats(1).curse_damage,11.505),"Exemple GDD chaman effets direct et périodique distincts")
	m = fixture(); n4(m,0,0,0); n4(m,1,1,1); m.buy(2,2); m.bonuses.assign([2]); m._refresh_windows()
	check(close(m.get_stats(1).range,7.5),"Exemple GDD Sentinelle portée 7,5")
	var snapshot: Dictionary = m.get_stats(1)
	for i in range(20): m._refresh_windows()
	check(m.get_stats(1) == snapshot,"Recalcul sans dérive")
	# Campagnes complètes de contrôle : six N4 financés par budget imposé.
	for faction in range(2):
		m = fixture(faction)
		m.rng.seed = 42
		for slot in range(6): n4(m,slot,faction*3+slot%3,slot/3)
		for wave in range(1,11):
			check(m.wave == wave and m.start(),"Lancement ordonné campagne de contrôle")
			m.advance(300)
			check(m.killed == counts[wave-1] and m.escaped == 0,"Tous les profils résolus sans arrivée en campagne de contrôle")
			if wave in [3,6,9]:
				check(m.phase == "bonus", "Choix uniquement après 3/6/9")
				m.choose_bonus(m.bonus_offer[0])
			if wave < 10:
				check(m.phase == "finished" and m.prepare_next_wave() and m.elapsed == 0 and m.enemies.is_empty() and m.curses.is_empty(),"Transition conserve défense, remet le temps à zéro")
		check(m.phase == "victory" and m.total_killed == 182 and m.total_income == 770 and m.bonuses.size() == 3,"Victoire, 182 éliminations et 770 or de récompenses")
		check(not m.start() and not m.prepare_next_wave() and not m.buy(0,faction*3),"Aucune préparation après victoire")
	# Chronologie complète avec synergies, bonus et densité de la vague 8.
	var runs: Array = []
	for step in [300.0,1.0/60.0,2.0/60.0]:
		m = fixture(1)
		n4(m,0,3,1); n4(m,1,4,1); n4(m,2,5,1)
		m.bonuses.assign([0,2,11]); m._refresh_windows()
		m.wave = 8; m.spawn_schedule = Data.schedule(8)
		m.start()
		while m.active: m.advance(step)
		runs.append(m)
	check(runs[0].event_log == runs[1].event_log and runs[1].event_log == runs[2].event_log,"Vague 8, bonus et synergies : même chronologie à grand pas, ×1 et ×2")
	check(runs[0].gold == runs[1].gold and runs[1].gold == runs[2].gold and runs[0].fortress_hp == runs[2].fortress_hp,"Vague 8 : mêmes gains et PV aux deux vitesses")
	# Références financées réellement : départ à 150, aucun achat ou niveau gratuit.
	for faction in range(2):
		m = Model.new(); m.select_faction(faction); m.rng.seed = 42
		m.buy(0,faction*3); m.buy(1,faction*3+1)
		for wave in range(1,11):
			if wave >= 4 and m.defenders[2].is_empty(): m.buy(2,faction*3+2)
			if wave >= 5:
				for slot in [0,1,2]:
					if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
			check(m.start(),"Référence financée : lancement de vague")
			m.advance(300)
			check(m.phase != "defeat" and m.killed+m.escaped == counts[wave-1],"Référence financée : survie et résolution complète")
			if m.phase == "bonus":
				print("FUNDED_OFFER faction=%d wave=%d indices=%s selected=%s" % [faction,wave,str(m.bonus_offer),Data.BONUSES[m.bonus_offer[0]].code])
				m.choose_bonus(m.bonus_offer[0])
			if wave < 10: check(m.prepare_next_wave(),"Référence financée : préparation suivante")
		var paid: int = 0
		for defender in m.defenders:
			if not defender.is_empty(): paid += defender.paid
		check(m.gold == 150+m.total_income-paid,"Référence financée : conservation de tout l'or")
		check(m.phase == "victory" and m.bonuses == [5,10,9] and m.fortress_hp == [14,12][faction] and m.gold == [192,189][faction] and m.total_income == [752,749][faction],"Deux victoires de référence au budget normal, graine 42")
		print("FUNDED_CAMPAIGN faction=%d hp=%d gold=%d income=%d kills=%d escapes=%d combat_seconds=%.9f" % [faction,m.fortress_hp,m.gold,m.total_income,m.total_killed,m.total_escaped,m.completed_time+m.elapsed])
	# Boss arrivé : 20 dégâts ; victoire possible avec maçonnerie mais défaite prioritaire à 0.
	for fortress in [20,24]:
		m = fixture(); m.wave = 10; m.phase = "combat"; m.fortress_hp = fortress; m.max_hp = fortress
		m.spawn_schedule.clear(); m.spawned = 0
		m.enemies.assign([enemy(0,7,28)])
		m._resolve_instant()
		check(m.phase == ("defeat" if fortress == 20 else "victory") and m.fortress_hp == fortress-20 and m.total_income == 0,"Arrivée du boss et priorité défaite")
	# L'interface suit les phases réelles et impose le choix avant la suite.
	var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(0)
	finish_fixture(scene.model,3); scene._update_interface()
	check(scene.bonus_panel.visible and scene.start_button.disabled and scene.bonus_close.visible == false,"Offre obligatoire affichée")
	var gold_before: int = scene.model.gold
	scene.selected = 0; scene._buy(0); scene._start(); scene._upgrade(); scene._sell()
	check(scene.model.phase == "bonus" and scene.model.gold == gold_before,"Commandes derrière l'offre sans effet")
	scene.bonus_buttons[0].pressed.emit()
	check(scene.model.bonuses.size() == 1 and not scene.bonus_panel.visible and not scene.start_button.disabled,"Choix rend la préparation disponible")
	check(scene.start_button.tooltip_text.contains("Ours sauvage") and scene.start_button.tooltip_text.contains("4 s"),"Aperçu des prochains groupes accessible au survol")
	check(scene.hint_label.mouse_filter != Control.MOUSE_FILTER_IGNORE,"Infobulles de synergies accessibles à la souris")
	scene._show_bonuses()
	check(scene.bonus_panel.visible and scene.bonus_close.visible and not scene.bonus_buttons[0].visible,"Récapitulatif sans nouveau choix")
	scene._close_bonuses(); scene._start()
	check(scene.model.wave == 4 and scene.model.active and scene.model.spawned == 1,"Vague suivante à t0 par le bouton")
	scene.set_process(false); scene.model.phase = "defeat"; scene._reset()
	check(scene.choosing_faction and scene.model.bonuses.is_empty() and scene.model.wave == 1,"Relance nettoie campagne et choix")
	scene.free()
	print("CAMPAIGN_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
