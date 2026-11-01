extends RefCounted
## Essai d'appui dans l'espace du plateau, sans modification du modèle de combat.
static func sample(progress: float,stride: float,phase_offset: float,duty: float,lift: float,root_at: Callable,rest_offset: Vector2,next_offset: Vector2=Vector2.INF) -> Dictionary:
	if not is_finite(progress) or not is_finite(stride) or stride<=0.0 or duty<=0.0 or duty>=1.0 or not root_at.is_valid(): return {}
	var cycle_position: float=progress/stride+phase_offset
	var cycle: int=int(floor(cycle_position))
	var phase: float=cycle_position-cycle
	var planted_at: float=(cycle-phase_offset)*stride
	var first: Vector2=root_at.call(planted_at+stride*duty*0.5)
	first+=rest_offset
	if phase<=duty: return {"world":first,"support":true,"phase":phase,"cycle":cycle}
	var next: Vector2=root_at.call(planted_at+stride+stride*duty*0.5)
	next+=next_offset if next_offset.is_finite() else rest_offset
	var t: float=(phase-duty)/(1.0-duty)
	var blend: float=t*t*t*(10.0-15.0*t+6.0*t*t)
	var point: Vector2=first.lerp(next,blend)+Vector2(0,-lift*pow(sin(PI*t),2))
	return {"world":point,"support":false,"phase":phase,"cycle":cycle}
