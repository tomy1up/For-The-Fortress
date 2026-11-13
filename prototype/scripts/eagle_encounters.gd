extends RefCounted
## Chapitre 16 : l'aigle des cimes, attaquant neutre des îles flottantes, rapide et fragile, en groupes serrés.
## Nom, statistiques et composition sont des réglages de prototype à confirmer. Visuel provisoire (silhouette du loup) en attendant Codex.
const ID := "sky_eagles"
const TYPE := 11
const DEFINITION := {"name":"Aigle des cimes","hp":14.0,"speed":1.5,"fortress_damage":1,"reward":4}
## Rencontres du Gué ; les aigles remplacent la plupart des sprinters et s'ajoutent en groupes serrés.
const WAVES: Array = [
	[[1,10,2.5]],
	[[1,10,2.0],[0,8,0.65]],
	[[1,8,1.8],[11,6,0.6]],
	[[3,4,3.0],[0,16,0.5]],
	[[3,2,4.0],[4,6,2.0],[11,6,0.6]],
	[[5,2,4.0],[3,6,2.2],[0,12,0.5]],
	[[6,1,0.0],[5,2,4.0],[4,8,1.6],[11,4,0.7]],
	[[0,24,0.35],[11,8,0.6],[4,8,1.2]],
	[[6,2,5.0],[5,2,4.0],[3,4,2.2],[11,6,0.55]],
	[[7,1,0.0],[6,2,5.0],[11,6,0.6],[2,6,1.0]]
]
