extends SceneTree
const M = preload("res://scripts/valley_model.gd")
func _initialize() -> void:
 var output: String = ""
 for argument in OS.get_cmdline_user_args():
  if argument.begins_with("--output="): output = argument.trim_prefix("--output=").simplify_path()
 if output.is_empty() or FileAccess.file_exists(output) or output.begins_with(ProjectSettings.globalize_path("user://")):
  printerr("Destination absente, existante ou réservée au joueur.");quit(2);return
 var results: Array = []
 for id in ["ford_woods","ford_heights"]:
  for positions in [[0,1,2],[1,2,4],[1,3,4],[0,2,4],[2,4,5],[2,3,5]]:
   for types in [[0,1,2],[0,2,1],[1,1,0],[0,0,2]]:
    for early in [1,2,3]:
     var m = M.new(true,M.Maps.for_id(id));m.configure_enemy_hp(101 if id == "ford_woods" else 102);m.select_faction(1);m.rng.seed = 42
     m.buy(positions[0],types[0]+3);m.buy(positions[1],types[1]+3)
     for wave in range(1,11):
      if wave == early: m.upgrade(positions[0])
      if wave >= 4 and m.defenders[positions[2]].is_empty(): m.buy(positions[2],types[2]+3)
      if wave >= 5:
       for slot in positions:
        if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
      m.start();m.advance(300)
      if m.phase == "defeat": break
      if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
      if wave < 10: m.prepare_next_wave()
     results.append({"id":id,"positions":positions,"types":types,"upgrade_attempt_wave":early,"hp":m.fortress_hp,"wave":m.wave,"result":m.phase})
 var file = FileAccess.open(output,FileAccess.WRITE)
 if file == null: printerr("Destination non accessible.");quit(1);return
 file.store_string(JSON.stringify({"schema":1,"game_version":ProjectSettings.get_setting("application/config/version"),"faction":"horde","seed":42,"points":0,"cases":results.size(),"human_balance_test":false,"scope":"Six triplets de positions, quatre compositions initiales et tentative de première amélioration aux vagues 1, 2 ou 3. Une demande peut être refusée faute d’or ; les règles normales s’appliquent.","results":results},"  ")+"\n");file.close();print("CAMPAIGN_EXPLORATION=",results.size());quit()
