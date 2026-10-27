extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const Survey = preload("res://tests/survey_upgrades.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func signature(m: RefCounted) -> String:
	var fields: Array = []
	for key in Survey.COPY_FIELDS: fields.append(m.get(key))
	fields.append(m.rng.state)
	return JSON.stringify(fields)
func clone(m: RefCounted) -> RefCounted:
	var result = Model.new()
	for key in Survey.COPY_FIELDS:
		var value: Variant = m.get(key)
		result.set(key,value.duplicate(true) if value is Array or value is Dictionary else value)
	result.rng.state = m.rng.state
	return result
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	# Budget et nombre de bonus imposés uniquement pour couvrir toutes les interactions.
	for faction in range(2):
		for branch in range(2):
			for boosted in [false,true]:
				for code in range(12):
					var m = Model.new(); m.select_faction(faction); m.gold = 10000
					for slot in range(6):
						m.buy(slot,faction*3+slot%3)
						var level: int = [1,2,3,4,4,3][slot]
						for upgrade in range(level-1): m.upgrade(slot,branch if upgrade == 2 else -1)
					if boosted:
						for existing in range(12):
							if existing != code: m.bonuses.append(existing)
					m._refresh_windows(); m.fortress_hp = 13; m.phase = "bonus"; m.bonus_offer.assign([code])
					var original: String = signature(m)
					var preview: Dictionary = m.bonus_preview(code)
					check(preview.units.size() == 6 and signature(m) == original,"Aperçu complet sans mutation, paiement ou tirage")
					var actual = clone(m)
					check(actual.choose_bonus(code),"Choix réel du bonus de contrôle")
					check(preview.hp_after == actual.fortress_hp and preview.max_after == actual.max_hp,"Gain de PV et maximum identiques au vrai choix")
					for unit in preview.units:
						check(unit.before == m.get_stats(unit.slot) and unit.after == actual.get_stats(unit.slot),"Toutes les statistiques prévues égales à l'état réellement choisi")
						check(unit.upgrade_before == m.upgrade_cost(unit.slot) and unit.upgrade_after == actual.upgrade_cost(unit.slot),"Prix d'amélioration réduit et niveau maximum fidèles")
						for component in ["direct","secondary","curse"]:
							for type in [3,5,6,7]:
								check(is_equal_approx(unit.large_before[component],m.damage_for(m.get_stats(unit.slot),component,{"type":type})) and is_equal_approx(unit.large_after[component],actual.damage_for(actual.get_stats(unit.slot),component,{"type":type})),"Dégâts conditionnels de chaque composante fidèles contre les quatre familles")
					for purchase in preview.purchases:
						check(purchase.before == m.purchase_cost(purchase.type) and purchase.after == actual.purchase_cost(purchase.type),"Prix de recrutement et arrondis identiques au jeu")
					preview.units[0].after.damage = -100
					check(signature(m) == original and m.bonus_preview(code).units[0].after.damage > 0,"Résultat modifiable sans alias avec la partie ou un autre aperçu")
	var m = Model.new()
	check(m.bonus_preview(-1).is_empty() and m.bonus_preview(12).is_empty(),"Codes invalides refusés")
	m.bonuses.assign([0])
	check(m.bonus_preview(0).is_empty(),"Bonus acquis non proposé comme nouveau gain")
	for faction in range(2):
		var scene = Main.new(); root.add_child(scene); scene.set_process(false); scene._choose_faction(faction)
		scene.model.buy(0,faction*3); scene.model.phase = "bonus"; scene.model.wave = 3; scene.model.bonus_offer.assign([7,8,11])
		var original: String = signature(scene.model)
		scene._update_interface()
		check(scene.bonus_impacts[0].text.contains("Aucun défenseur actuel concerné"),"Vétérans ne promet pas de gain à une recrue niveau 1")
		check(scene.bonus_impacts[1].text.contains("20 → 24") and scene.bonus_impacts[2].text.contains("uniquement"),"PV et condition des colosses explicites")
		check(not scene.bonus_impact_scrollers[0].visible and scene.bonus_detail_buttons[0].visible and not scene.bonus_close.visible,"Choix condensé, comparaisons accessibles à la demande, choix toujours obligatoire")
		scene._process(100)
		check(scene.model.phase == "bonus" and scene.countdown_remaining < 0 and signature(scene.model) == original,"Lecture sans choix automatique, paiement, soin ou tirage")
		scene.bonus_buttons[1].pressed.emit()
		check(scene.model.bonuses == [8] and scene.model.max_hp == 24 and scene.countdown_remaining == -1,"Un seul bonus réellement acquis au clic ; premier départ reste manuel dans cette fixture")
		scene._show_bonuses()
		check(scene.bonus_close.visible and not scene.bonus_impact_scrollers[0].visible and scene.bonus_body.size.y == 468,"Récapitulatif compact sans nouvelle projection d'un bonus déjà actif")
		scene._close_bonuses(); scene.model.phase = "defeat"; scene._reset()
		check(not scene.bonus_panel.visible,"Nouvel essai sans ancienne comparaison")
		scene.free()
	print("BONUS_PREVIEW_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
