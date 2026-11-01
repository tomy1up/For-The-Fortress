extends "res://scripts/main.gd"
const CandidateView = preload("C:/Projet/For the Fortress!/design/essais/animation_loup_24_poses/candidate_view.gd")
func _ready() -> void:
	map_view.free()
	map_view = CandidateView.new()
	mission_definition = {}
	meta_profile = MetaProfile.new("")
	super._ready()
	assert(meta_profile!=null and meta_profile.path.is_empty(),"L'essai du loup doit utiliser uniquement un profil éphémère.")
	version_label.text = "ESSAI LOUP · 24 POSES · Profil temporaire non enregistré"
	get_window().title = "For the Fortress! — Essai du loup à 24 poses"
	print("WOLF24_PLAYABLE=",JSON.stringify({"poses":24,"player_profile_loaded":not meta_profile.path.is_empty(),"temporary_profile":true,"base_version":ProjectSettings.get_setting("application/config/version"),"candidate_texture":map_view.candidate!=null}))

func _choose_faction(choice: int,replacement: RefCounted=null) -> void:
	super._choose_faction(choice,replacement)
	if not choosing_faction: get_window().title = "For the Fortress! — Essai du loup à 24 poses — "+model.map_definition.title
