extends RefCounted
## Chapitre 10 : la Garnison, ennemi d'élite propre à la citadelle de la faction adverse.
## Noms, statistiques et composition sont des réglages de prototype à confirmer.
const ID := "citadel_garrison"
const TYPE := 10
const DEFINITION := {"name":"Capitaine de garnison","hp":520.0,"speed":0.6,"fortress_damage":4,"reward":26}
## Mêmes rencontres que le Gué ; la Garnison remplace les brutes et l'élite aux vagues 5, 7, 9 et 10.
const WAVES: Array = [
	[[1,10,2.5]],
	[[1,10,2.0],[0,8,0.65]],
	[[1,8,1.8],[2,8,1.4]],
	[[3,4,3.0],[0,16,0.5]],
	[[10,1,0.0],[4,6,2.0],[2,8,1.2]],
	[[5,2,4.0],[3,6,2.2],[0,12,0.5]],
	[[10,1,0.0],[5,2,4.0],[4,8,1.6]],
	[[0,24,0.35],[2,12,1.0],[4,8,1.2]],
	[[10,2,5.0],[5,2,4.0],[3,4,2.2],[4,6,1.4]],
	[[7,1,0.0],[10,2,5.0],[2,8,1.0]]
]
