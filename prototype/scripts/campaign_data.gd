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
	{"code":"R-01","name":"Armes affûtées","description":"+10 % à tous les dégâts, directs, secondaires et périodiques."},
	{"code":"R-02","name":"Exercice de tir","description":"+12 % de fréquence d’attaque. Exclut le chaman et ses branches."},
	{"code":"R-03","name":"Postes d’observation","description":"Tous les défenseurs attaquent plus loin. Leur portée augmente de 0,5 : par exemple, de 4 à 4,5 (+12,5 %)."},
	{"code":"R-04","name":"Éclats meurtriers","description":"+20 % aux dégâts des explosions du mage et du sapeur, et des rebonds du lanceur de haches.","faction_descriptions":["+20 % aux dégâts des explosions du mage.","+20 % aux dégâts des rebonds du lanceur de haches et des explosions du sapeur."]},
	{"code":"R-05","name":"Propagation","description":"+0,2 au rayon des explosions et à la portée de chaque rebond. Le nombre maximal d’ennemis touchés reste inchangé."},
	{"code":"R-06","name":"Impacts appuyés","description":"+15 % aux dégâts principaux directs. Aucun gain secondaire ou périodique."},
	{"code":"R-07","name":"Recrues aguerries","description":"+15 % à tous les dégâts des défenseurs de niveaux 1 et 2, actuels et futurs. Le bonus cesse au niveau 3."},
	{"code":"R-08","name":"Vétérans","description":"+12 % à tous les dégâts des défenseurs de niveau 3 ou spécialisés (niveau 4), actuels et futurs."},
	{"code":"R-09","name":"Maçonnerie renforcée","description":"+4 PV actuels et maximum de forteresse. Aucun soin automatique ultérieur."},
	{"code":"R-10","name":"Ateliers efficaces","description":"Réduit de 10 % le coût des prochaines améliorations et spécialisations. Le prix final est arrondi à la pièce d’or supérieure."},
	{"code":"R-11","name":"Recrutement organisé","description":"−10 % au prix des achats futurs. Aucun effet rétroactif. Arrondi supérieur."},
	{"code":"R-12","name":"Chasse aux colosses","description":"+20 % à tous les dégâts contre Brutes, Colosses, Élites et boss : coups directs, explosions, rebonds et malédictions. Priorité des cibles inchangée."}
]
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
static func schedule(wave: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var time: float = 0.0
	for group in WAVES[wave-1]:
		for index in range(group[1]):
			result.append({"type":group[0],"time":time+index*group[2]})
		time += (group[1]-1)*group[2]+4.0
	return result
