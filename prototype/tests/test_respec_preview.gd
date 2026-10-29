extends SceneTree
const Screen = preload("res://scripts/meta_screen.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents.gd")
class FailingProfile extends "res://scripts/meta_profile.gd":
	func respec(_faction: int) -> bool:
		error = "Écriture indisponible pour le contrôle."
		return false
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func prepare(p: RefCounted, faction: int, resets: int = 0) -> void:
	p.data.banks[faction].resource = 40;p.data.banks[faction].points = 9;p.data.banks[faction].resets = resets
	p.data.banks[faction].ranks[0] = 5;p.data.banks[faction].ranks[1] = 1
	p.data.banks[1-faction].resource = 77;p.data.banks[1-faction].resets = 9
func run_checks() -> void:
	for faction in range(2):
		for resets in [0,1,2,3,4,20]:
			var p = Profile.new("");prepare(p,faction,resets)
			var ui = Screen.new();root.add_child(ui);ui.open(p,faction)
			var before: String = JSON.stringify(p.data)
			var other: Dictionary = p.data.banks[1-faction].duplicate(true)
			var quote: Dictionary = ui._respec_preview()
			check(quote.price == 0 and quote.next_price == 0,"Gratuité indépendante du compteur historique")
			check(quote.balance_after == 40-quote.price and quote.active == 6 and quote.free_before == 3 and quote.free_after == 9,"Aperçu du solde et des points réellement récupérés")
			ui._request_reset()
			check(ui.confirm.visible and ui.confirm.dialog_text.contains("3 → 9 (+6 rendus)") and ui.confirm.dialog_text.contains("Réinitialisation gratuite") and ui.confirm.ok_button_text == "Réinitialiser gratuitement","Confirmation présente les conséquences sans perdre les points achetés")
			check(before == JSON.stringify(p.data),"Ouvrir et relire l'aperçu ne réalise aucune transaction")
			ui.confirm.canceled.emit()
			check(before == JSON.stringify(p.data) and ui.reset_quote.is_empty() and not ui.confirm.visible,"Annulation sans coût ni compteur et aperçu effacé")
			ui._request_reset();ui.confirm.confirmed.emit()
			check(p.data.banks[faction].resource == quote.balance_after and p.data.banks[faction].points == 9 and Talents.spent(p.data.banks[faction].ranks) == 0,"Confirmation sans débit et restitution de tous les rangs")
			check(p.data.banks[faction].resets == resets+1 and p.reset_price(faction) == quote.next_price,"Compteur et prochain prix conformes à l'aperçu")
			check(p.data.banks[1-faction] == other,"Progression et compteur adverses intacts")
			var after: String = JSON.stringify(p.data);ui.confirm.confirmed.emit()
			check(after == JSON.stringify(p.data),"Double confirmation sans seconde dépense")
			ui.free()
		var p = Profile.new("");prepare(p,faction)
		var ui = Screen.new();root.add_child(ui);ui.open(p,faction);ui._request_reset()
		p.data.banks[faction].resource += 1
		var before: String = JSON.stringify(p.data);ui.confirm.confirmed.emit()
		check(before == JSON.stringify(p.data) and ui.notice.text.contains("préparation a changé"),"Aperçu périmé refusé sans prix de remplacement silencieux")
		ui._request_reset();ui.close();ui.confirm.confirmed.emit()
		check(before == JSON.stringify(p.data) and ui.reset_quote.is_empty(),"Quitter les arbres annule la confirmation en attente")
		ui.open(p,faction);ui._request_reset();ui.open(p,1-faction)
		check(ui.reset_quote.is_empty() and not ui.confirm.visible,"Changer de faction ne réutilise pas un ancien devis")
		ui.open(p,faction);p.blocked = true;ui._request_reset()
		check(not ui.confirm.visible and ui.reset_quote.is_empty(),"Profil bloqué sans confirmation de dépense")
		p.blocked = false;p.data.banks[faction].resource = 1;ui._request_reset()
		check(ui.confirm.visible and ui.reset_quote.price == 0,"Petit solde ne bloque pas le reset gratuit")
		ui.free()
		var failed = FailingProfile.new("");prepare(failed,faction)
		ui = Screen.new();root.add_child(ui);ui.open(failed,faction);ui._request_reset();before = JSON.stringify(failed.data);ui.confirm.confirmed.emit()
		check(before == JSON.stringify(failed.data) and ui.notice.text == failed.error,"Échec d'enregistrement signalé sans prélèvement")
		ui.free()
		var path: String = "user://test_respec_preview_%d_%d.json" % [Time.get_ticks_usec(),faction]
		var stored = Profile.new(path);prepare(stored,faction)
		ui = Screen.new();root.add_child(ui);ui.open(stored,faction);ui._request_reset();ui.confirm.confirmed.emit();ui.free()
		var reopened = Profile.new(path)
		check(not reopened.blocked and reopened.data.banks[faction].resource == 40 and reopened.data.banks[faction].points == 9 and reopened.data.banks[faction].resets == 1 and Talents.spent(reopened.data.banks[faction].ranks) == 0,"Résultat confirmé conservé après relecture du profil protégé")
		for suffix in ["",".bak",".tmp"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	print("RESPEC_PREVIEW_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
