extends RefCounted
## Observation only: damage allocation never changes the combat transaction.
const COUNTERS: Array[String] = ["attacks","secondary_hits","curse_ticks","direct_hp","secondary_hp","curse_hp","boss_hp"]

static func create(army: Array) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for unit in army:
		var row: Dictionary = unit.duplicate(true)
		for field in COUNTERS: row[field] = 0.0 if field.ends_with("_hp") else 0
		rows.append(row)
	return rows

static func credit(rows: Array, enemies: Array, damage: Dictionary, hits: Array) -> void:
	if rows.is_empty() or hits.is_empty(): return
	var units: Dictionary = {}
	for row in rows: units[int(row.instance_id)] = row
	var victims: Dictionary = {}
	for enemy in enemies: victims[enemy.id] = enemy
	for hit in hits:
		if not units.has(hit.source_id) or not victims.has(hit.enemy_id) or hit.amount < 0.0: continue
		var enemy: Dictionary = victims[hit.enemy_id]
		var total: float = damage.get(hit.enemy_id,0.0)
		if total <= 0.0: continue
		# Simultaneous hits share the actual HP removed in proportion to their damage.
		var removed: float = hit.amount * minf(maxf(enemy.hp,0.0),total) / total
		var row: Dictionary = units[hit.source_id]
		row[hit.component+"_hp"] += removed
		row[{"direct":"attacks","secondary":"secondary_hits","curse":"curse_ticks"}[hit.component]] += 1
		if enemy.get("type",-1) == 7: row.boss_hp += removed

static func summarize(history: Array) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var by_id: Dictionary = {}
	for wave in history:
		for unit in wave.get("performance",[]):
			var id: int = int(unit.instance_id)
			if not by_id.has(id):
				var row: Dictionary = unit.duplicate(true)
				for field in COUNTERS: row[field] = 0.0 if field.ends_with("_hp") else 0
				row["waves"] = []
				by_id[id] = row; rows.append(row)
			var row: Dictionary = by_id[id]
			for field in COUNTERS: row[field] += unit[field]
			for field in ["level","branch","paid"]: row[field] = unit[field]
			row.waves.append(wave.wave)
	return rows
