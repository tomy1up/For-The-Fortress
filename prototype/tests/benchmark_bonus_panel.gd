extends SceneTree
const Main=preload("res://scripts/main.gd")
func _initialize():call_deferred("run")
func run():
	var results:Array=[]
	for faction in range(2):
		var scene=Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		scene.model.gold=10000
		for slot in range(6):
			scene.model.buy(slot,faction*3+slot%3)
			for branch in [-1,-1,0]:scene.model.upgrade(slot,branch)
		scene.selected=0;scene.model.wave=9;scene.model.phase="bonus";scene.model.bonuses.assign([3,7]);scene.model.bonus_offer.assign([0,1,2]);scene._update_interface()
		var samples:Array=[]
		for sample in range(3):
			var start:int=Time.get_ticks_usec()
			for iteration in range(300):scene._update_interface()
			samples.append((Time.get_ticks_usec()-start)/300.0)
		results.append({"faction":faction,"microseconds_per_update":samples})
		scene.free()
	print("PROFILE_UI="+JSON.stringify(results));quit()
