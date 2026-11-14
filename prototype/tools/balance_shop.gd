extends SceneTree
## Puissance d'une alternative de boutique : PV ennemis maximaux battus (en % de la référence) quand elle remplace la troisième unité
## de l'armée de référence de sa faction (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches, chaman), sans talents.
## Usage : BAL_UNIT=<id de carte | base> BAL_FACTION=<0|1 pour base> godot --headless --path prototype --script res://tools/balance_shop.gd
## Sortie : lignes « SHOP <id> map=<carte> order=<ordre> thr=<seuil> ». Le rapport entre le seuil d'une unité et celui de `base` mesure sa puissance relative.
const Model = preload("res://scripts/valley_model.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const MAPS: Array[String] = ["valley_ford","slate_crossing","marsh_basins","mine_entrance","coast_jetty"]
const ORDERS: Array = [[3,4,2],[2,3,4]]
const REFERENCE: Array = [[0,1,1],[3,3,5]]

func wins(map_id: String, faction: int, order: Array, types: Array, auxiliary: int, hp: int) -> bool:
	var m := Model.new(true,Model.Maps.for_id(map_id))
	if auxiliary >= 0 and not m.configure_auxiliary(auxiliary): return false
	m.enemy_hp_percent = hp
	m.select_faction(faction)
	m.rng.seed = 7
	m.buy(order[0],types[0]);m.buy(order[1],types[1])
	for wave in range(1,11):
		if wave == 2: m.upgrade(order[0])
		if wave >= 2 and m.defenders[order[2]].is_empty(): m.buy(order[2],types[2])
		if wave >= 5:
			for slot in order:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		m.start();m.advance(10000)
		if m.phase == "defeat": return false
		if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
		if wave < 10: m.prepare_next_wave()
	return m.phase == "victory"

func threshold(map_id: String, faction: int, order: Array, types: Array, auxiliary: int) -> int:
	var lo := 80
	var hi := 900
	if not wins(map_id,faction,order,types,auxiliary,lo): return lo
	if wins(map_id,faction,order,types,auxiliary,hi): return hi
	while hi-lo > 2:
		var mid: int = (lo+hi)/2
		if wins(map_id,faction,order,types,auxiliary,mid): lo = mid
		else: hi = mid
	return lo

func _initialize() -> void:
	var unit: String = OS.get_environment("BAL_UNIT")
	var faction: int = int(OS.get_environment("BAL_FACTION"))
	var types: Array = []
	var auxiliary := -1
	if unit != "base":
		var card: Dictionary = Shop.card(unit)
		if card.is_empty(): push_error("Carte inconnue : "+unit);quit(1);return
		faction = card.faction
		types = REFERENCE[faction].duplicate()
		types[2] = card.type
		auxiliary = card.type
	else:
		types = REFERENCE[faction].duplicate()
	for map_id in MAPS:
		for order in ORDERS:
			print("SHOP ",unit if unit != "base" else "base%d" % faction," map=",map_id," order=",order," thr=",threshold(map_id,faction,order,types,auxiliary))
	quit()
