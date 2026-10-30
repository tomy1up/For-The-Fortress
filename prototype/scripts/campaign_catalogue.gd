extends RefCounted
## Structure cible du parcours. Seul le contenu marqué disponible est jouable.
const TOTAL_MISSIONS: int = 200
const CHAPTER_SIZE: int = 10
const CHAPTER_COUNT: int = TOTAL_MISSIONS/CHAPTER_SIZE
const INFINITE_REQUIREMENT: int = 100

static func id_for(number: int) -> String:
	return "campaign.%03d" % number if number >= 1 and number <= TOTAL_MISSIONS else ""

static func number_for(id: Variant) -> int:
	if not id is String or not id.begins_with("campaign."): return 0
	var suffix: String = id.trim_prefix("campaign.")
	if not suffix.is_valid_int(): return 0
	var number: int = int(suffix)
	return number if id_for(number) == id else 0

static func definition(number: int) -> Dictionary:
	if number < 1 or number > TOTAL_MISSIONS: return {}
	var chapter: int = (number-1)/CHAPTER_SIZE+1
	var result: Dictionary = {"id":id_for(number),"number":number,"chapter":chapter,"theme_pair":(chapter-1)/2+1,"introduces_rule":chapter%2 == 0,"title":"Mission %d" % number,"available":false}
	if number == 1:
		result.merge({"title":"La Vallée du Gué","available":true,"map_id":"valley_ford","po":60,"xp":100,"waves":10},true)
	return result

static func runtime(id: String) -> Dictionary:
	var data: Dictionary = definition(number_for(id))
	if data.is_empty() or not data.available: return {}
	return {"id":data.id,"po":data.po,"xp":data.xp,"waves":data.waves}

static func available_count() -> int:
	var total: int = 0
	for number in range(1,TOTAL_MISSIONS+1):
		if definition(number).available: total += 1
	return total
