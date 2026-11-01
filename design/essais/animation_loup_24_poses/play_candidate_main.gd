extends "res://scripts/main.gd"
const CandidateView = preload("C:/Projet/For the Fortress!/design/essais/animation_loup_24_poses/candidate_view.gd")
func _ready() -> void:
	map_view.free()
	map_view = CandidateView.new()
	mission_definition = {}
	super._ready()
	assert(meta_profile==null,"L'essai du loup ne doit charger aucun profil joueur.")
	version_label.text = "ESSAI LOUP · 24 POSES · Aucun gain de progression"
	get_window().title = "For the Fortress! — Essai du loup à 24 poses"
	print("WOLF24_PLAYABLE=",JSON.stringify({"poses":24,"profile_loaded":meta_profile!=null,"base_version":ProjectSettings.get_setting("application/config/version"),"candidate_texture":map_view.candidate!=null}))
