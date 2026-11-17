extends RefCounted
## Séquence approuvée, valeurs d'équilibrage H. Type, quantité, intervalle.
const WAVES: Array = [
	[[1,10,2.5]],
	[[1,10,2.0],[0,8,0.65]],
	[[1,8,1.8],[2,8,1.4]],
	[[3,4,3.0],[0,16,0.5]],
	[[4,6,2.0],[3,4,3.0],[2,8,1.2]],
	[[5,2,4.0],[3,6,2.2],[0,12,0.5]],
	[[6,1,0.0],[5,2,4.0],[4,8,1.6]],
	[[0,24,0.35],[2,12,1.0],[4,8,1.2]],
	[[6,2,5.0],[5,2,4.0],[3,4,2.2],[4,6,1.4]],
	[[7,1,0.0],[6,2,5.0],[2,8,1.0]]
]
const BONUSES: Array[Dictionary] = [
	{"code":"R-01","name":"Armes affûtées","description":"+10 % à tous les dégâts, directs, secondaires et périodiques.","faction_descriptions":["+10 % aux dégâts des tirs et des explosions.","+10 % aux dégâts des impacts, rebonds, explosions et malédictions."]},
	{"code":"R-02","name":"Exercice de tir","description":"+12 % de fréquence d’attaque. Exclut le chaman orc de base et ses spécialisations ; ses alternatives de boutique en profitent.","faction_descriptions":["+12 % de fréquence d’attaque : archer elfe, rôdeur elfe, arbalétrier nain, mousquetaire nain et mage humain. Spécialisations incluses.","+12 % de fréquence d’attaque : lanceur de haches troll, traqueur troll, sapeur gobelin, grenadier gobelin, Brûleur de cendres et Chaman des marais. Le chaman orc de base et ses spécialisations sont exclus."]},
	{"code":"R-03","name":"Postes d’observation","description":"Tous les défenseurs attaquent plus loin. Leur portée augmente de 0,5 : par exemple, de 4 à 4,5 (+12,5 %)."},
	{"code":"R-04","name":"Éclats meurtriers","description":"+20 % aux dégâts des explosions du mage et du sapeur, et des rebonds du lanceur de haches.","faction_descriptions":["+20 % aux dégâts des explosions du mage.","+20 % aux dégâts des rebonds du lanceur de haches et du traqueur troll, et des explosions du sapeur et du grenadier gobelin."]},
	{"code":"R-05","name":"Propagation","description":"+0,2 au rayon des explosions et à la portée de chaque rebond. Le nombre maximal d’ennemis touchés reste inchangé.","faction_descriptions":["+0,2 au rayon des explosions du mage. Le nombre maximal d’ennemis touchés reste inchangé.","+0,2 au rayon d’explosion du sapeur et du grenadier gobelin, et à la distance des rebonds du lanceur de haches et du traqueur troll. Nombre de cibles inchangé."]},
	{"code":"R-06","name":"Impacts appuyés","description":"+15 % aux dégâts principaux directs. Aucun gain secondaire ou périodique.","faction_descriptions":["+15 % aux dégâts directs des tirs. Les explosions restent inchangées.","+15 % aux dégâts directs. Les rebonds, explosions et malédictions restent inchangés."]},
	{"code":"R-07","name":"Recrues aguerries","description":"+15 % à tous les dégâts des défenseurs de niveaux 1 et 2, actuels et futurs. Le bonus cesse au niveau 3."},
	{"code":"R-08","name":"Vétérans","description":"+12 % à tous les dégâts des défenseurs de niveau 3 ou spécialisés (niveau 4), actuels et futurs."},
	{"code":"R-09","name":"Maçonnerie renforcée","description":"+4 PV actuels et maximum de forteresse. Aucun soin automatique ultérieur."},
	{"code":"R-10","name":"Ateliers efficaces","description":"Réduit de 10 % le coût des prochaines améliorations et spécialisations. Le prix final est arrondi à la pièce d’or supérieure."},
	{"code":"R-11","name":"Recrutement organisé","description":"−10 % au prix des achats futurs. Aucun effet rétroactif. Arrondi supérieur."},
	{"code":"R-12","name":"Chasse aux colosses","description":"+20 % à tous les dégâts contre ours, unités lourdes, gardes d’élite et boss : coups directs, explosions, rebonds et malédictions. Priorité des cibles inchangée.","faction_descriptions":["+20 % aux dégâts des tirs et explosions contre ours, unités lourdes, gardes d’élite et boss. Priorité des cibles inchangée.","+20 % aux dégâts des impacts, explosions, rebonds et malédictions contre ours, unités lourdes, gardes d’élite et boss. Priorité des cibles inchangée."]},
	# Bonus 13 à 36 (règles v0.232 ; valeurs et noms de prototype à confirmer). `audience` : « all » (tous les défenseurs, effet selon la cible), « units » (calculé sur la défense actuelle), « immediate », « purchases » ou « upgrades ».
	{"code":"R-13","name":"Salves rapprochées","description":"+25 % à tous les dégâts des défenseurs rapides (intervalle d’attaque de 1,3 s ou moins), actuels et futurs.","effect":"Dégâts +25 %","scope":"Défenseurs à tir rapide.","note":"Intervalle de 1,3 s ou moins.","audience":"units"},
	{"code":"R-14","name":"Coups de maître","description":"+25 % à tous les dégâts des défenseurs lents (intervalle d’attaque de 2,4 s ou plus), actuels et futurs.","effect":"Dégâts +25 %","scope":"Défenseurs à tir lent.","note":"Intervalle de 2,4 s ou plus.","audience":"units"},
	{"code":"R-15","name":"Tir de barrage","description":"+1 victime secondaire maximale pour les défenseurs qui touchent plusieurs ennemis.","faction_descriptions":["+1 victime secondaire maximale des explosions du mage humain.","+1 victime secondaire maximale des rebonds et des explosions de vos trolls et gobelins."],"effect":"+1 cible secondaire","scope":"Défenseurs à effet de zone.","note":"Dégâts inchangés.","audience":"units"},
	{"code":"R-16","name":"Sortilèges durables","description":"+35 % aux dégâts sur la durée.","faction_descriptions":["+35 % aux dégâts de brûlure du Pyromancien humain et de vos autres unités à dégâts sur la durée.","+35 % aux dégâts des malédictions du chaman orc, du Brûleur de cendres et de vos autres unités à dégâts sur la durée."],"effect":"Dégâts sur la durée +35 %","scope":"Défenseurs à dégâts sur la durée.","note":"Tirs directs inchangés.","audience":"units"},
	{"code":"R-17","name":"Vue dégagée","description":"+20 % à tous les dégâts des défenseurs à longue portée (portée de base de 4,5 ou plus), actuels et futurs.","effect":"Dégâts +20 %","scope":"Défenseurs à longue portée.","note":"Portée de base de 4,5 ou plus.","audience":"units"},
	{"code":"R-18","name":"Mêlée acharnée","description":"+25 % à tous les dégâts des défenseurs à courte portée (portée de base de 3,6 ou moins), actuels et futurs.","effect":"Dégâts +25 %","scope":"Défenseurs à courte portée.","note":"Portée de base de 3,6 ou moins.","audience":"units"},
	{"code":"R-19","name":"Soutien efficace","description":"+30 % à la force des effets de soutien : marque, aura des gardiens, ralentissement, pillage et charge volatile.","effect":"Soutiens +30 %","scope":"Défenseurs de soutien.","note":"Dégâts directs inchangés.","audience":"units"},
	{"code":"R-20","name":"Pari risqué","description":"+30 % à tous les dégâts, mais −4 PV maximum de forteresse (PV actuels réduits d’autant, jamais sous 1).","effect":"Dégâts +30 %\nPV −4","scope":"Tous vos défenseurs.","note":"Effet immédiat sur la forteresse.","audience":"all"},
	{"code":"R-21","name":"Cadence effrénée","description":"+25 % de fréquence d’attaque pour tous les défenseurs, mais −0,5 de portée.","effect":"Tirs 25 % plus rapides\nPortée −0,5","scope":"Tous vos défenseurs.","note":"Actuels et futurs.","audience":"units"},
	{"code":"R-22","name":"Tir tendu","description":"+1 de portée pour tous les défenseurs, mais −10 % à tous les dégâts.","effect":"Portée +1\nDégâts −10 %","scope":"Tous vos défenseurs.","note":"Actuels et futurs.","audience":"units"},
	{"code":"R-23","name":"Marché noir","description":"−25 % au prix des achats futurs, mais +15 % au prix des améliorations et spécialisations futures. Arrondi supérieur.","effect":"Recrues −25 %\nAméliorations +15 %","scope":"Vos prochains achats.","note":"Achats passés inchangés.","audience":"purchases"},
	{"code":"R-24","name":"Forteresse blindée","description":"+8 PV actuels et maximum de forteresse, mais −10 % à tous les dégâts.","effect":"PV +8\nDégâts −10 %","scope":"Votre forteresse et vos défenseurs.","note":"Sans régénération automatique.","audience":"all"},
	{"code":"R-25","name":"Élite sacrifiée","description":"+30 % aux dégâts des défenseurs de niveau 3 ou 4, mais −10 % à ceux des défenseurs de niveau 1 ou 2.","effect":"Niveau 3-4 : +30 %\nNiveau 1-2 : −10 %","scope":"Tous vos défenseurs.","note":"Actuels et futurs.","audience":"all"},
	{"code":"R-26","name":"Formation serrée","description":"+15 % à tous les dégâts d’un défenseur qui a un autre défenseur à 3 de distance ou moins.","effect":"Dégâts +15 %","scope":"Défenseurs groupés.","note":"Voisin à 3 de distance ou moins.","audience":"units"},
	{"code":"R-27","name":"Francs-tireurs","description":"+25 % à tous les dégâts et +0,5 de portée pour un défenseur sans autre défenseur à 4,2 de distance ou moins.","effect":"Dégâts +25 %\nPortée +0,5","scope":"Défenseurs isolés.","note":"Aucun voisin à 4,2 ou moins.","audience":"units"},
	{"code":"R-28","name":"Armée variée","description":"+5 % à tous les dégâts par type de défenseur différent déployé (jusqu’à +20 % avec quatre types).","effect":"Dégâts +5 % par type","scope":"Tous vos défenseurs.","note":"Quatre types au maximum.","audience":"all"},
	{"code":"R-29","name":"Dernier rempart","description":"+25 % aux dégâts contre les ennemis qui ont parcouru plus de 65 % de leur route.","effect":"Dégâts +25 %","scope":"Ennemis proches de la forteresse.","note":"Plus de 65 % du trajet.","audience":"all"},
	{"code":"R-30","name":"Embuscade","description":"+25 % aux dégâts contre les ennemis qui ont parcouru moins de 35 % de leur route.","effect":"Dégâts +25 %","scope":"Ennemis près de l’entrée.","note":"Moins de 35 % du trajet.","audience":"all"},
	{"code":"R-31","name":"Premier sang","description":"+25 % aux dégâts directs contre les ennemis qui n’ont encore perdu aucun PV.","effect":"Dégâts +25 %","scope":"Ennemis intacts.","note":"Les autres dégâts sont inchangés.","audience":"all"},
	{"code":"R-32","name":"Coup de grâce","description":"+30 % aux dégâts contre les ennemis dont les PV sont inférieurs à la moitié du maximum.","effect":"Dégâts +30 %","scope":"Ennemis gravement blessés.","note":"Moins de 50 % des PV.","audience":"all"},
	{"code":"R-33","name":"Moral montant","description":"+2 % à tous les dégâts par vague déjà jouée : le bonus grandit jusqu’à la dixième vague.","effect":"Dégâts +2 % par vague","scope":"Tous vos défenseurs.","note":"Cumul croissant, sans plafond propre.","audience":"all"},
	{"code":"R-34","name":"Chasseurs de rapides","description":"+30 % aux dégâts contre les ennemis rapides (grouillants, sprinters, maraudeurs et assimilés).","effect":"Dégâts +30 %","scope":"Ennemis rapides.","note":"Les autres cibles sont inchangées.","audience":"all"},
	{"code":"R-35","name":"Briseurs de hordes","description":"+25 % aux dégâts contre les petits ennemis (grouillants, pillards, sprinters, maraudeurs et assimilés).","effect":"Dégâts +25 %","scope":"Petits ennemis.","note":"Les autres cibles sont inchangées.","audience":"all"},
	{"code":"R-36","name":"Prime de butin","description":"+25 % à l’or gagné par chaque élimination (arrondi à l’or le plus proche), actuel et futur.","effect":"Or des éliminations +25 %","scope":"Toutes vos éliminations.","note":"Effet sur les futures éliminations.","audience":"all"}
]
## Nombre de bonus des règles précédentes (avant la v0.232) : les rapports plus anciens se rejouent avec ce seul catalogue.
const LEGACY_BONUS_COUNT := 12
# Chaque côté décrit ses gains propres [direct, secondaire, périodique, portée].
const PROXIMITY: Array[Dictionary] = [
	{"code":"P-ALL-01","types":[0,1],"effects":[[0.08,0,0,0],[0.08,0,0,0]]},
	{"code":"P-ALL-02","types":[0,2],"effects":[[0.08,0,0,0],[0,0.08,0,0]]},
	{"code":"P-ALL-03","types":[1,2],"effects":[[0,0,0,0.25],[0.06,0,0,0]]},
	{"code":"P-HOR-01","types":[3,4],"effects":[[0,0.08,0,0],[0,0.08,0,0]]},
	{"code":"P-HOR-02","types":[3,5],"effects":[[0.08,0,0,0],[0,0,0.08,0]]},
	{"code":"P-HOR-03","types":[4,5],"effects":[[0.08,0,0,0],[0.08,0,0,0]]}
]
const SPECIALISATIONS: Array[Dictionary] = [
	{"code":"S-ALL-01","types":[0,1],"branches":[0,1],"effects":[[0,0,0,0.25],[0,0,0,0.25]]},
	{"code":"S-ALL-02","types":[0,2],"branches":[1,0],"effects":[[0.08,0,0,0],[0.08,0,0,0]]},
	{"code":"S-ALL-03","types":[1,2],"branches":[0,1],"effects":[[0.06,0.06,0.06,0],[0.06,0.06,0.06,0]]},
	{"code":"S-HOR-01","types":[3,5],"branches":[0,0],"effects":[[0.08,0,0,0],[0.08,0,0,0]]},
	{"code":"S-HOR-02","types":[3,4],"branches":[1,1],"effects":[[0,0.08,0,0],[0,0.08,0,0]]},
	{"code":"S-HOR-03","types":[4,5],"branches":[0,1],"effects":[[0.06,0.06,0.06,0],[0.06,0.06,0.06,0]]}
]
const Banks = preload("res://scripts/bank_encounters.gd")
const Drowned = preload("res://scripts/drowned_encounters.gd")
const Garrison = preload("res://scripts/garrison_encounters.gd")
const Eagle = preload("res://scripts/eagle_encounters.gd")
const Revenant = preload("res://scripts/revenant_encounters.gd")

static func waves_for(set_id: String = "ford") -> Array:
	return Banks.WAVES if set_id == Banks.ID else Drowned.WAVES if set_id == Drowned.ID else Garrison.WAVES if set_id == Garrison.ID else Eagle.WAVES if set_id == Eagle.ID else Revenant.WAVES if set_id == Revenant.ID else WAVES

static func schedule(wave: int, set_id: String = "ford") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var time: float = 0.0
	for group in waves_for(set_id)[wave-1]:
		for index in range(group[1]):
			result.append({"type":group[0],"time":time+index*group[2]})
		time += (group[1]-1)*group[2]+4.0
	return result

static func bonus_description(code: int, faction: int) -> String:
	if code < 0 or code >= BONUSES.size() or faction not in [0,1]: return ""
	var data: Dictionary = BONUSES[code]
	return data.faction_descriptions[faction] if data.has("faction_descriptions") else data.description
