extends RefCounted
## Préparation de test uniquement : passe par une vraie transaction de mission isolée.
static func unlock(profile: RefCounted, faction: int, target: int) -> bool:
	var reward: int = profile.Experience.xp_for_points(target)-int(profile.data.banks[faction].xp)
	if reward <= 0: return profile.data.banks[faction].points >= target
	var id: int = profile.begin_mission(faction,"test.xp_fixture.%d" % (int(profile.data.serial)+1),0,10,reward)
	return id > 0 and profile.credit_mission(id,faction,10,true)
