extends SceneTree
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.next_instance_id,scene.countdown_remaining])
func run_checks() -> void:
	var identities: Dictionary = {}
	for faction in range(2):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
		for hp in [1,25]:
			for wave in range(1,11):
				scene.model.fortress_hp = hp;scene.model.wave = wave;scene.model.phase = "preparation"
				var before: String = signature(scene)
				scene._update_interface()
				for index in range(4):
					var portrait: TextureRect = scene.forecast_portraits[index]
					if index >= scene.forecast_data.groups.size():
						check(portrait.texture == null and not scene.forecast_rows[index].visible,"Ancien portrait retiré des lignes inutilisées")
						continue
					var group: Dictionary = scene.forecast_data.groups[index]
					var identity: Dictionary = scene.model.Enemies.for_profile(group.type,faction)
					var id: String = identity.id;identities[id] = true
					check(portrait.texture is AtlasTexture and portrait.texture.atlas == View.EnemyArt.TEXTURES[id] and portrait.texture.region == View.EnemyArt.FRAMES[id].source,"Illustration exacte du neutre ou du camp adverse, même source que l’ennemi en combat")
					check(portrait.texture.filter_clip and portrait.modulate == Color.WHITE and portrait.self_modulate == Color.WHITE,"Couleurs originales conservées, atlas isolé sans débordement du voisin")
					check(portrait.mouse_filter == Control.MOUSE_FILTER_IGNORE and portrait.focus_mode == Control.FOCUS_NONE and portrait.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Portrait non interactif, sans bloquer l’infobulle et sans déformer la silhouette")
					check(portrait.position.x >= scene.forecast_marks[index].get_rect().end.x and portrait.get_rect().end.x < scene.forecast_names[index].position.x,"Portrait séparé du repère et du texte")
					for label in [scene.forecast_names[index],scene.forecast_details[index]]:
						check(label.get_theme_font("font").get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,label.get_theme_font_size("font_size")).x <= label.size.x,"Nom complet, PV et avertissement de défaite tiennent dans la ligne")
					var texture: Texture2D = portrait.texture;scene._update_wave_forecast()
					check(portrait.texture == texture,"Rafraîchir la prévision réutilise la même ressource graphique")
				check(before == signature(scene),"Prévision sans changement du modèle, du temps, de l’aléatoire ou du décompte")
				check(scene.forecast_textures.size() <= 8,"Cache limité aux huit identités du camp courant")
				check(scene.forecast_panel.size.y == 112+44*scene.forecast_data.groups.size(),"Hauteur inchangée pour ne pas recouvrir davantage la carte")
		check(scene._forecast_portrait(-1) == null and scene._forecast_portrait(12) == null,"Profil invalide sans illustration inventée")
		scene.model.phase = "defeat";scene._update_interface();scene._reset();scene._choose_faction(1-faction)
		var enemy: Dictionary = scene.model.Enemies.for_profile(1,1-faction)
		check(scene.forecast_portraits[0].texture.region == View.EnemyArt.FRAMES[enemy.id].source and scene.forecast_portraits[0].texture.atlas == View.EnemyArt.TEXTURES[enemy.id],"Nouvelle partie dans l’autre faction : aucun portrait de l’ancien adversaire")
		scene.model.phase = "combat";scene._update_interface();check(not scene.forecast_panel.visible,"Portraits retirés avec la prévision pendant le combat")
		scene.free()
	check(identities.size() == 13,"Treize silhouettes vérifiées : trois neutres et cinq adversaires de chaque camp")
	print("FORECAST_PORTRAITS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
