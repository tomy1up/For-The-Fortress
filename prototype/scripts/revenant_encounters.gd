extends RefCounted
## Chapitre 20 : le revenant, attaquant neutre de la nécropole, qui se relève une fois avec la moitié de ses PV.
## Nom, statistiques, part de PV rendue et composition sont des réglages de prototype à confirmer. Visuel provisoire (silhouette de l'ours) en attendant Codex.
const ID := "necro_revenants"
const TYPE := 12
const DEFINITION := {"name":"Revenant","hp":30.0,"speed":0.9,"fortress_damage":1,"reward":5}
## Part des PV maximum retrouvée à la relève (une seule fois par revenant).
const RISE_FRACTION := 0.5
## Rencontres du Gué ; les revenants s'ajoutent en petits groupes à partir de la vague 4.
const WAVES: Array = [
	[[1,10,2.5]],
	[[1,10,2.0],[0,8,0.65]],
	[[1,8,1.8],[2,8,1.4]],
	[[3,4,3.0],[0,16,0.5],[12,2,3.0]],
	[[3,2,4.0],[4,6,2.0],[12,3,2.5]],
	[[5,2,4.0],[3,6,2.2],[0,12,0.5],[12,3,2.2]],
	[[6,1,0.0],[5,2,4.0],[4,8,1.6],[12,3,2.0]],
	[[0,24,0.35],[12,4,1.8],[4,8,1.2]],
	[[6,2,5.0],[5,2,4.0],[3,4,2.2],[12,4,1.8]],
	[[7,1,0.0],[6,2,5.0],[12,4,1.8],[2,6,1.0]]
]
